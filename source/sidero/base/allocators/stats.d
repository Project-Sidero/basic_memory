/**
Provides statistics about a given allocator that it wraps.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.stats;
import sidero.base.attributes;
import sidero.base.typecons : Ternary;
import sidero.base.internal.atomic;

private {
    import sidero.base.allocators.api;

    alias Stats = StatsAllocator!RCAllocator;
}

export:

/// Tracks some information related to allocation
struct StatsAllocator(PoolAllocator) {
    ///
    PoolAllocator poolAllocator;

    static if(__traits(hasMember, PoolAllocator, "NeedsLocking")) {
        ///
        enum NeedsLocking = PoolAllocator.NeedsLocking;
    } else {
        ///
        enum NeedsLockin = false;
    }

    ///
    __gshared RCAllocatorInstance!StatsAllocator instance;

    ///
    struct Info {
        ///
        size_t callsToOwns, callsToAllocate, callsToAllocateSuccessful, callsToReallocate, callsToReallocateSuccessful,
            callsToDeallocation, callsToDeallocationSuccessful, callsToEmpty;
        ///
        size_t numberOfReallocationsInPlace;
        ///
        size_t bytesAllocated, maximumBytesAllocatedOverTime;
    }

    private @PrettyPrintIgnore {
        shared(Info) info;
    }

@safe @nogc scope pure nothrow:

    ///
    bool isNull() const {
        return poolAllocator.isNull;
    }

@trusted:

    ///
    this(return scope ref StatsAllocator other) {
        this.tupleof = other.tupleof;
        other = StatsAllocator.init;
    }

    private {
        void updateCAS() {
            size_t bytes, max;

            for(bytes = atomicLoad(info.bytesAllocated), max = atomicLoad(info.maximumBytesAllocatedOverTime); bytes < max;
                    cas(info.maximumBytesAllocatedOverTime, bytes, max)) {
            }
        }
    }

    ///
    Info get() {
        return info;
    }

    ///
    void[] allocate(size_t length, TypeInfo ti = null) {
        atomicIncrementAndLoad(info.callsToAllocate, 1);
        void[] ret = poolAllocator.allocate(length, ti);

        if(ret !is null) {
            atomicIncrementAndLoad(info.callsToAllocateSuccessful, 1);
            atomicIncrementAndLoad(info.bytesAllocated, ret.length);
        }

        updateCAS;
        return ret;
    }

    ///
    bool deallocate(scope void[] data) {
        atomicIncrementAndLoad(info.callsToDeallocation, 1);
        bool ret = poolAllocator.deallocate(data);

        if(ret) {
            atomicIncrementAndLoad(info.callsToDeallocationSuccessful, 1);
            atomicDecrementAndLoad(info.bytesAllocated, data.length);
        }

        return ret;
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        atomicIncrementAndLoad(info.callsToReallocate, 1);
        void[] original = array;

        bool ret = poolAllocator.reallocate(array, newSize);

        if(ret)
            atomicIncrementAndLoad(info.callsToReallocateSuccessful, 1);

        if(array.ptr !is null && array.ptr !is original.ptr)
            atomicIncrementAndLoad(info.numberOfReallocationsInPlace, 1);

        if(array.ptr !is original.ptr) {
            atomicDecrementAndLoad(info.bytesAllocated, original.length);
            atomicIncrementAndLoad(info.bytesAllocated, array.length);
        }

        updateCAS;
        return ret;
    }

    static if(__traits(hasMember, PoolAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            atomicIncrementAndLoad(info.callsToOwns, 1);
            return poolAllocator.owns(array);
        }
    }

    static if(__traits(hasMember, PoolAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            atomicStore(info.bytesAllocated, 0);
            return poolAllocator.deallocateAll();
        }
    }

    static if(__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            atomicIncrementAndLoad(info.callsToEmpty, 1);
            return poolAllocator.empty();
        }
    }
}
