/**
Provides an allocator wrapper that performs locking to make it thread-safe.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.locking;
import sidero.base.attributes;
import std.typecons : Ternary;

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
        scope (exit)
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
        scope (exit)
            mutex.unlock;

        return poolAllocator.allocate(size, ti);
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        mutex.pureLock;
        scope (exit)
            mutex.unlock;

        return poolAllocator.reallocate(array, newSize);
    }

    ///
    bool deallocate(scope void[] array) {
        if (array is null)
            return false;

        mutex.pureLock;
        scope (exit)
            mutex.unlock;

        return poolAllocator.deallocate(array);
    }

    static if (__traits(hasMember, PoolAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            mutex.pureLock;
            scope (exit)
                mutex.unlock;

            return poolAllocator.owns(array);
        }
    }

    static if (__traits(hasMember, PoolAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            mutex.pureLock;
            scope (exit)
                mutex.unlock;

            return poolAllocator.deallocateAll();
        }
    }

    static if (__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            mutex.pureLock;
            scope (exit)
                mutex.unlock;

            return poolAllocator.empty();
        }
    }
}

/**
    Hooks allocations and add then remove ranges as allocations/deallocations/reallocations occur.
 */
struct GCAllocatorLock(PoolAllocator) {
    private import sidero.base.allocators.gc;

    ///
    PoolAllocator poolAllocator;

    ///
    enum NeedsLocking = false;

scope @safe @nogc pure nothrow:

    ///
    this(return scope ref GCAllocatorLock other) @trusted {
        readLockImpl;
        scope (exit)
            readUnlockImpl;

        this.poolAllocator = other.poolAllocator;
        other.poolAllocator = PoolAllocator.init;
    }

    ///
    bool isNull() const {
        return poolAllocator.isNull;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        readLockImpl;
        scope (exit)
            readUnlockImpl;

        void[] got = poolAllocator.allocate(size, ti);

        if (got !is null)
            addRangeImpl(got, ti);

        return got;
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        readLockImpl;
        scope (exit)
            readUnlockImpl;

        void[] original = array;

        bool got = poolAllocator.reallocate(array, newSize);

        if (got) {
            removeRangeImpl(original);
            addRangeImpl(array);
        }

        return got;
    }

    ///
    bool deallocate(scope void[] array) {
        if (array is null)
            return false;

        readLockImpl;
        scope (exit)
            readUnlockImpl;

        bool got = poolAllocator.deallocate(array);
        if (got)
            removeRangeImpl(array);

        return got;
    }

    static if (__traits(hasMember, PoolAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            readLockImpl;
            scope (exit)
                readUnlockImpl;

            return poolAllocator.owns(array);
        }
    }

    static if (__traits(hasMember, PoolAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            readLockImpl;
            scope (exit)
                readUnlockImpl;

            return poolAllocator.deallocateAll();
        }
    }

    static if (__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            readLockImpl;
            scope (exit)
                readUnlockImpl;

            return poolAllocator.empty();
        }
    }
}
