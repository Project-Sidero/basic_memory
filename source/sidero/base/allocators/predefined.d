/**
A set of predefined but useful memory allocators.

There are multiple categories of allocators defined here, they are:

- Mapping: Raw memory mapping, for configuring address ranges to hardware.
- House keeping: used for fixed sized memory allocations (not arrays) and are meant for internals to data structures.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.memory.allocators.predefined;
import sidero.base.memory.allocators.api;
import sidero.base.memory.allocators.buffers.region;
import sidero.base.memory.allocators.buffers.freelist;
import sidero.base.memory.allocators.alternatives.allocatorlist;

private {
    alias HouseKeepingAllocatorTest = HouseKeepingAllocator!RCAllocator;
}

public import sidero.base.memory.allocators.mapping : DefaultMapper, GoodAlignment;

/// An allocator specializing in fixed size allocations that can be deallocated all at once.
alias HouseKeepingAllocator(MappingAllocator = DefaultMapper, size_t AlignedTo = 0) = HouseKeepingFreeList!(
        AllocatorList!(MappingAllocator, (poolAllocator) => Region!(typeof(poolAllocator), AlignedTo)(null, poolAllocator)));

/**
A house keeping allocator that will ensure there are LSB bits available for tags

Use ``(pointer & TaggedPointerHouseKeepingAllocator.Mask)`` to get tags and ``(pointer & TaggedPointerHouseKeepingAllocator.PointerMask)`` to get the pointer.

Warning: ensure that the memory returned has been added as a root to any GC you use, if you store GC memory in it.
*/
template TaggedPointerHouseKeepingAllocator(MappingAllocator = DefaultMapper, int BitsToTag = 1) {
    static assert(BitsToTag > 0, "Zero bits to tag is equivalent to packing memory without any alignment. Must be above zero.");
    static assert(BitsToTag < size_t.sizeof * 4, "The number of bits in the tag should be less than half the bits in a pointer...");

    ///
    alias TaggedPointerHouseKeepingAllocator = HouseKeepingAllocator!(MappingAllocator, 2 ^^ BitsToTag);

    /// Mask to get the bits that contain the tag(s)
    enum Mask = (2 ^^ BitsToTag) - 1;
    /// Mask to get the bits that contain the pointer
    enum PointerMask = ~Mask;
}

/// Aligns all memory returned to GoodAlignment.
struct GeneralPurposeAllocator {
    import sidero.base.memory.allocators.buffers.defs : FitsStrategy;
    import sidero.base.memory.allocators.buffers.freetree : FreeTree;
    import sidero.base.memory.allocators.buffers.buddylist : BuddyList;
    import sidero.base.memory.allocators.buffers.region : Region;
    import sidero.base.memory.allocators.mapping.malloc;
    import sidero.base.memory.allocators.alternatives.bucketizer;
    import sidero.base.memory.allocators.alternatives.segregator;
    import sidero.base.memory.allocators.locking;

    private {
        alias ALRegion(size_t DefaultSize) = AllocatorList!(Region!(Mallocator, GoodAlignment, DefaultSize), () => Region!(Mallocator, GoodAlignment, DefaultSize)());
    }

    // this will automatically bump up to the next power 2 size, and will always be a good size allocated based upon the PAGESIZE.
    // it'll hold up to 4gb of blocks quite happily. If you need more... yeah you're gonna have a problem anyway.
    alias GeneralPurposeAllocatorImpl = AllocatorLocking!(BuddyList!(ALRegion!(0), 6, 22));
    GeneralPurposeAllocatorImpl impl;

    alias impl this;

    ///
    __gshared GeneralPurposeAllocator instance;
}
