/**
A set of predefined but useful memory allocators.

There are multiple categories of allocators defined here, they are:

- Mapping: Raw memory mapping, for configuring address ranges to hardware.
- House keeping: used for fixed sized memory allocations (not arrays) and are meant for internals to data structures.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.predefined;
import sidero.base.allocators.api;
import sidero.base.allocators.buffers.region;
import sidero.base.allocators.buffers.freelist;
import sidero.base.allocators.alternatives.allocatorlist;

private {
    alias HouseKeepingAllocatorTest = HouseKeepingAllocator!RCAllocator;
}

export:

public import sidero.base.allocators.mapping : DefaultMapper, GoodAlignment;

/// An allocator specializing in fixed size allocations that can be deallocated all at once.
alias HouseKeepingAllocator(MappingAllocator = DefaultMapper, size_t AlignedTo = 0) = HouseKeepingFreeList!(
        AllocatorList!(MappingAllocator, (poolAllocator) => Region!(typeof(poolAllocator), AlignedTo)(null, poolAllocator)));

/// Accumulator of memory regions that can be deallocated all at once, not thread safe.
alias MemoryRegionsAllocator(size_t DefaultSize = 0, MappingAllocator = DefaultMapper) = AllocatorList!(
        Region!(MappingAllocator, GoodAlignment, DefaultSize), () => Region!(MappingAllocator, GoodAlignment, DefaultSize)());

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
    import sidero.base.allocators.buffers.buddylist : BuddyList;
    import sidero.base.allocators.buffers.freetree : FreeTree;
    import sidero.base.allocators.mapping.malloc;
    import sidero.base.allocators.locking : GCAllocatorLock;

    // this will automatically bump up to the next power 2 size, and will always be a good size allocated based upon the PAGESIZE.
    // it'll hold up to 4gb of blocks quite happily. If you need more... yeah you're gonna have a problem anyway.
    version (none) {
        alias GeneralPurposeAllocatorImpl = GCAllocatorLock!(BuddyList!(MemoryRegionsAllocator!(0), 6, 22, false));
    }

    // This is the best possible use of a free tree, which should be more efficient than a buddylist.
    version (all) {
        alias GeneralPurposeAllocatorImpl = GCAllocatorLock!(FreeTree!(MemoryRegionsAllocator!(0),
                FitsStrategy.BestFit, GoodAlignment, 0, false));
    }

    // for debugging issues
    version (none) {
        alias GeneralPurposeAllocatorImpl = GCAllocatorLock!Mallocator;
    }

    GeneralPurposeAllocatorImpl impl;

    alias impl this;

    ///
    __gshared RCAllocatorInstance!GeneralPurposeAllocator instance;
}
