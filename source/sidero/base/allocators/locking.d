/**
Provides an allocator wrapper that performs locking to make it thread-safe.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.locking;
import sidero.base.attributes;
import sidero.base.typecons : Ternary;

export:

/**
    Adds a lock around all allocator operations to make it thread safe.
 */
struct AllocatorLocking(PoolAllocator) {
    ///
    PoolAllocator poolAllocator;

    ///
    enum NeedsLocking = false;

    private @PrettyPrintIgnore {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

        TestTestSetLockInline mutex;
    }

scope @safe @nogc pure nothrow:

    ///
    this(return scope ref AllocatorLocking other) @trusted {
        other.mutex.pureLock;
        scope(exit)
            other.mutex.unlock;

        this.poolAllocator = other.poolAllocator;
        other.poolAllocator = PoolAllocator.init;
    }

    ///
    bool isNull() const {
        return poolAllocator.isNull;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        mutex.pureLock;
        scope(exit)
            mutex.unlock;

        return poolAllocator.allocate(size, ti);
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        mutex.pureLock;
        scope(exit)
            mutex.unlock;

        return poolAllocator.reallocate(array, newSize);
    }

    ///
    bool deallocate(scope void[] array) {
        if(array is null)
            return false;

        mutex.pureLock;
        scope(exit)
            mutex.unlock;

        return poolAllocator.deallocate(array);
    }

    static if(__traits(hasMember, PoolAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            return poolAllocator.owns(array);
        }
    }

    static if(__traits(hasMember, PoolAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            return poolAllocator.deallocateAll();
        }
    }

    static if(__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            return poolAllocator.empty();
        }
    }
}

/**
    Hooks allocations and add then remove ranges as allocations/deallocations/reallocations occur.
 */
struct GCAllocatorLock(PoolAllocator) {
    import sidero.base.allocators.gc;
    import sidero.base.allocators.buffers.freetree : AllocatedTree;
    import sidero.base.allocators.mapping.malloc;

    ///
    PoolAllocator poolAllocator;

    private AllocatedTree!(Mallocator) allocatedTree;

    ///
    enum NeedsLocking = false;

scope @safe @nogc nothrow:

    ///
    this(return scope ref GCAllocatorLock other) @trusted {
        writeLockImpl;
        scope(exit)
            writeUnlockImpl;

        this.poolAllocator = other.poolAllocator;
        other.poolAllocator = PoolAllocator.init;

        this.allocatedTree = other.allocatedTree;
        other.allocatedTree = typeof(allocatedTree).init;
    }

    ~this() {
        writeLockImpl;
        scope(exit)
            writeUnlockImpl;

        allocatedTree.deallocateAll((array) { removeRangeImpl(array); return true; });
    }

pure:

    ///
    bool isNull() const {
        return poolAllocator.isNull;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        writeLockImpl;
        scope(exit)
            writeUnlockImpl;

        void[] got = poolAllocator.allocate(size, ti);

        if(got !is null) {
            allocatedTree.store(got);
            addRangeImpl(got, ti);
            return got[0 .. size];
        }

        return null;
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        writeLockImpl;
        scope(exit)
            writeUnlockImpl;

        auto trueArray = allocatedTree.getTrueRegionOfMemory(array);
        if(trueArray is null)
            return false;
        array = trueArray;

        const got = poolAllocator.reallocate(array, newSize);

        if(got) {
            allocatedTree.remove(trueArray);
            removeRangeImpl(trueArray);

            allocatedTree.store(array);
            addRangeImpl(array);

            array = array[0 .. newSize];
        }

        return got;
    }

    ///
    bool deallocate(scope void[] array) {
        if(array is null)
            return false;

        writeLockImpl;
        scope(exit)
            writeUnlockImpl;

        debug {
            auto trueArray = allocatedTree.getTrueRegionOfMemory(array);
            if(trueArray is null)
                return false;

            assert(trueArray.ptr is array.ptr);
            assert(trueArray.length >= array.length);
        }

        const got = poolAllocator.deallocate(array);

        if(got) {
            allocatedTree.remove(array);
            removeRangeImpl(array);
        }

        return got;
    }

    static if(__traits(hasMember, PoolAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            readLockImpl;
            scope(exit)
                readUnlockImpl;

            return poolAllocator.owns(array);
        }
    }

    static if(__traits(hasMember, PoolAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            writeLockImpl;
            scope(exit)
                writeUnlockImpl;

            allocatedTree.deallocateAll((array) { removeRangeImpl(array); return true; });
            return poolAllocator.deallocateAll();
        }
    }

    static if(__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            readLockImpl;
            scope(exit)
                readUnlockImpl;

            return poolAllocator.empty();
        }
    }
}
