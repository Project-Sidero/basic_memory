/**
Groups similar sized allocations together into buckets.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.alternatives.bucketizer;
import sidero.base.attributes : hidden;
import std.typecons : Ternary;

private {
    import sidero.base.allocators.api;

    alias BRC = Bucketizer!(RCAllocator, 0, 10, 1);
}

export:

/**
    Uses buckets to segregate memory.
 */
struct Bucketizer(PoolAllocator, size_t min, size_t max, size_t step) {
export:
    PoolAllocator[((max + 1) - min) / step] poolAllocators;

    static if (__traits(hasMember, PoolAllocator, "NeedsLocking")) {
        ///
        enum NeedsLocking = PoolAllocator.NeedsLocking;
    } else {
        ///
        enum NeedsLocking = false;
    }

scope @trusted @nogc pure nothrow:

    this(scope return ref Bucketizer other) @trusted {
        foreach (i, ref v; this.poolAllocators)
            v = other.poolAllocators[i];
        other = Bucketizer.init;
    }

    ///
    bool isNull() const {
        foreach (ref bucket; poolAllocators)
            if (bucket.isNull)
                return true;
        return false;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        if (isNull)
            return null;
        else {
            void[] ret = bucketFor(size).allocate(size, ti);
            return ret[0 .. size];
        }
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if (!isNull && bucketFor(array.length).reallocate(array, newSize)) {
            array = array[0 .. newSize];
            return true;
        } else
            return false;
    }

    ///
    bool deallocate(scope void[] array) {
        if (isNull)
            return false;

        if (bucketFor(array.length).deallocate(array))
            return true;

        foreach (ref bucket; poolAllocators) {
            if (bucket.deallocate(array))
                return true;
        }

        return false;
    }

    static if (__traits(hasMember, PoolAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            if (isNull)
                return Ternary.no;
            else {
                if (bucketFor(array.length).owns(array) == Ternary.yes)
                    return Ternary.yes;

                foreach (ref bucket; poolAllocators)
                    if (bucket.owns(array) == Ternary.yes)
                        return Ternary.yes;
                return Ternary.no;
            }
        }
    }

    static if (__traits(hasMember, PoolAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            if (isNull)
                return false;
            else {
                foreach (ref bucket; poolAllocators)
                    bucket.deallocateAll();
                return true;
            }
        }
    }

private @hidden:
    ref PoolAllocator bucketFor(size_t size) {
        if (size < min)
            return poolAllocators[0];
        else {
            size_t ret = (size - min) / step;

            if (ret >= poolAllocators.length)
                ret = poolAllocators.length - 1;

            return poolAllocators[ret];
        }
    }
}
