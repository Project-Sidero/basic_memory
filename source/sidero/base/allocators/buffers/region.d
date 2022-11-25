/**
Fixed region memory allocation strategy.
Can allocate and deallocate by using another memory mapper if one is provided.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.buffers.region;
import sidero.base.allocators.mapping : GoodAlignment;
import std.typecons : Ternary;

private {
    import sidero.base.allocators.api;

    alias RegionRC = Region!RCAllocator;
}

export:

/// A bump the pointer allocator for a set slice of memory, will automically allocate if required and can guarantee alignment.
struct Region(PoolAllocator = void, size_t DefaultAlignment = GoodAlignment, size_t DefaultSize = 0) {
export:
    ///
    void[] memory;

    static if (!is(PoolAllocator == void)) {
        /// Automatically deallocation of memory using this allocator
        PoolAllocator poolAllocator;
    }

    ///
    size_t alignedTo = DefaultAlignment;
    ///
    size_t defaultSize = DefaultSize;

    ///
    enum NeedsLocking = true;

    private size_t allocated;

@safe @nogc scope pure nothrow:

    ///
    this(void[] memory, size_t alignedTo = DefaultAlignment, size_t defaultSize = DefaultSize) {
        this.memory = memory;
        this.alignedTo = alignedTo;
        this.defaultSize = defaultSize;
    }

    ///
    bool isNull() const {
        static if (!is(PoolAllocator == void)) {
            if (!poolAllocator.isNull)
                return false;
            else
                return memory is null;
        } else
            return memory is null;
    }

@trusted:

    static if (!is(PoolAllocator == void)) {
        ///
        this(void[] memory, PoolAllocator poolAllocator, size_t alignedTo = DefaultAlignment, size_t defaultSize = DefaultSize) {
            this.memory = memory;
            this.poolAllocator = poolAllocator;
            this.alignedTo = alignedTo;
            this.defaultSize = defaultSize;
        }
    }

    ///
    this(scope return ref Region other) {
        this.tupleof = other.tupleof;
        this.allocated = other.allocated;
        other.memory = null;
        other = Region.init;
    }

    ~this() {
        deallocateAll();
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        return allocate_(size, ti);
    }

    private void[] allocate_(size_t size, TypeInfo ti = null) @system {
        static if (!is(PoolAllocator == void)) {
            if (memory is null) {
                import sidero.base.allocators.mapping.vars : PAGESIZE;

                if (defaultSize == 0)
                    defaultSize = PAGESIZE;

                size_t toAllocateSize = defaultSize;
                if (toAllocateSize < size + alignedTo)
                    toAllocateSize = size + alignedTo;

                memory = poolAllocator.allocate(toAllocateSize, null);
            }
        }

        if (allocated + size > memory.length)
            return null;

        void[] toGo = memory[allocated .. $];

        if (fitsAlignment(toGo, size, alignedTo)) {
            size_t toAddAlignment = alignedTo > 0 ? (alignedTo - ((cast(size_t)toGo.ptr) % alignedTo)) : 0;
            if (toAddAlignment == alignedTo)
                toAddAlignment = 0;

            allocated += toAddAlignment + size;
            return toGo[toAddAlignment .. toAddAlignment + size];
        } else
            return null;
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if (memory is null || (array.ptr + array.length !is &memory[allocated]) || (allocated + (newSize - array.length) > memory.length))
            return false;
        else if (newSize < array.length) {
            array = array[0 .. newSize];
            return true;
        } else if (newSize > array.length) {
            size_t extra = newSize - array.length;
            allocated += extra;
            array = array.ptr[0 .. newSize];
            return true;
        } else
            return true;
    }

    ///
    bool deallocate(scope void[] array) {
        if (array !is null && allocated >= array.length && array.ptr is memory.ptr + (allocated - array.length)) {
            allocated -= array.length;
            return true;
        }

        return false;
    }

    ///
    Ternary owns(scope void[] array) {
        return (memory.ptr <= array.ptr && (array.ptr < memory.ptr + memory.length)) ? Ternary.yes : Ternary.no;
    }

    ///
    bool deallocateAll() {
        allocated = 0;
        void[] temp = memory;
        memory = null;

        static if (!is(PoolAllocator == void)) {
            return temp is null || poolAllocator.deallocate(temp);
        } else
            return false;
    }

    ///
    bool empty() {
        static if (!is(PoolAllocator == void) && __traits(hasMember, PoolAllocator, "empty")) {
            return (memory is null || allocated == memory.length) && poolAllocator.empty;
        } else
            return memory is null || allocated == memory.length;
    }

    package(sidero.base.allocators) {
        bool isOnlyOneAllocationOfSize(size_t size) {
            size_t padding = alignedTo - ((cast(size_t)memory.ptr) % alignedTo);
            if (padding == alignedTo)
                padding = 0;

            return padding + size == allocated;
        }
    }

private:
    bool fitsAlignment(void[] into, size_t needed, size_t alignedTo) @trusted {
        if (alignedTo == 0)
            return into.length >= needed;

        size_t padding = alignedTo - ((cast(size_t)into.ptr) % alignedTo);
        if (padding == alignedTo)
            padding = 0;

        return needed + padding <= into.length;
    }
}

///
unittest {
    alias R = Region!();

    R region;
    assert(region.empty);
    assert(region.isNull);

    void[] rawMemory = new void[64 * 1024];
    region = R(rawMemory);
    assert(!region.empty);
    assert(!region.isNull);

    void[] got = region.allocate(1024);
    assert(got !is null);
    assert(got.length == 1024);
    assert(region.owns(got) == Ternary.yes);
    assert(region.owns(got[10 .. 20]) == Ternary.yes);

    R region2 = region;
    region = region2;

    void* rootGot = got.ptr;
    size_t alignmentCheck = region.alignedTo - (cast(size_t)region.memory.ptr % region.alignedTo);
    if (alignmentCheck == region.alignedTo)
        alignmentCheck = 0;
    assert(rootGot - alignmentCheck is region.memory.ptr);

    bool success = region.reallocate(got, 2048);
    assert(success);
    assert(got.length == 2048);
    assert(got.ptr is rootGot);

    assert(region.owns(null) == Ternary.no);
    assert(region.owns(got) == Ternary.yes);
    assert(region.owns(got[10 .. 20]) == Ternary.yes);

    success = region.deallocate(got);
    assert(success);
}

///
unittest {
    import sidero.base.allocators.mapping.malloc;

    alias R = Region!(Mallocator);

    R region;
    assert(!region.empty);
    assert(!region.isNull);

    region = R(null, Mallocator());
    assert(!region.empty);
    assert(!region.isNull);

    void[] got = region.allocate(1024);
    assert(got !is null);
    assert(got.length == 1024);
    assert(region.owns(got) == Ternary.yes);
    assert(region.owns(got[10 .. 20]) == Ternary.yes);

    void* rootGot = got.ptr;
    size_t alignmentCheck = region.alignedTo - (cast(size_t)region.memory.ptr % region.alignedTo);
    if (alignmentCheck == region.alignedTo)
        alignmentCheck = 0;
    assert(rootGot - alignmentCheck is region.memory.ptr);

    bool success = region.reallocate(got, 2048);
    assert(success);
    assert(got.length == 2048);
    assert(got.ptr is rootGot);

    assert(region.owns(null) == Ternary.no);
    assert(region.owns(got) == Ternary.yes);
    assert(region.owns(got[10 .. 20]) == Ternary.yes);

    success = region.deallocate(got);
    assert(success);
}
