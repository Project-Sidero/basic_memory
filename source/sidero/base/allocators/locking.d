/**
Provides an allocator wrapper that performs locking to make it thread-safe.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.memory.allocators.locking;
import std.typecons : Ternary;

/**
    Adds a lock around all allocator operations to make it thread safe.
 */
struct AllocatorLocking(PoolAllocator) {
    ///
    PoolAllocator poolAllocator;

    ///
    enum NeedsLocking = false;

    private {
        import sidero.base.parallelism.mutualexclusion : TestTestSetLockInline;

        TestTestSetLockInline mutex;
    }

scope @safe @nogc pure nothrow:

    ///
    this(scope return ref AllocatorLocking other) @trusted {
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
