/**
A buddy list for general purpose memory allocation.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.buffers.buddylist;
import sidero.base.attributes : hidden;
import std.typecons : Ternary;

private {
    import sidero.base.allocators.api;

    alias BL = BuddyList!(RCAllocator);
}

export:

/**
    The famous buddy list!
    It keeps your memory close to its buddies!
    Perfact for all of your allocations needs.

    Default exponent range is designed for 32bit coverage, with a maximum allocation size for internal storage at 1gb.

    https://en.wikipedia.org/wiki/Buddy_memory_allocation
 */
struct BuddyList(PoolAllocator, size_t minExponent = 3, size_t maxExponent = 20) {
export:
    static assert(minExponent >= calculatePower2Size((void*).sizeof, 0)[1], "Minimum exponent must be large enough to fit a pointer in.");
    static assert(minExponent < maxExponent, "Maxinum exponent must be larger than minimum exponent.");

    /// Source for all memory
    PoolAllocator poolAllocator;

    ///
    enum NeedsLocking = true;

    invariant {
        assert(!poolAllocator.isNull);

        foreach (block; blocks) {
            assert(block is null);
        }

        version (none) {
            foreach (offset; 0 .. NumberOfBlocks) {
                Block* current = cast(Block*)blocks[offset];

                while (current !is null) {
                    current = current.next;
                }
            }
        }
    }

    private {
        import sidero.base.allocators.buffers.freetree : AllocatedTree;

        enum NumberOfBlocks = maxExponent - minExponent;

        Block*[NumberOfBlocks] blocks;
        AllocatedTree!() allocations, fullAllocations;

        static struct Block {
            Block* next;
        }
    }

scope @safe @nogc pure nothrow:

    ///
     ~this() {
        deallocateAll();
    }

    ///
    bool isNull() const {
        return poolAllocator.isNull;
    }

@trusted:

    ///
    this(return scope ref BuddyList other) {
        this.tupleof = other.tupleof;
        other.blocks = typeof(blocks).init;
        other = BuddyList.init;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        import sidero.base.allocators.mapping.vars : PAGESIZE;

        void[] splitUntilSize(Block* current, size_t available, size_t blockOffset) {
            void* ret = cast(void*)current;

            while (blockOffset > 0 && available / 2 >= size) {
                assert(blockOffset > 0);
                blockOffset--;
                available /= 2;

                Block* splitAs = cast(Block*)((cast(void*)current) + available);

                splitAs.next = blocks[blockOffset];
                blocks[blockOffset] = splitAs;
            }

            assert(available >= size);
            return ret[0 .. available];
        }

        size_t[2] blockSizeAndOffsetSource = calculatePower2Size(size, minExponent);
        void[] ret;

        if (blockSizeAndOffsetSource[1] < NumberOfBlocks) {
            size_t[2] blockSizeAndOffset = blockSizeAndOffsetSource;
            Block** parent = &blocks[blockSizeAndOffset[1]];

            while (blockSizeAndOffset[1] + 1 < NumberOfBlocks && *parent is null) {
                parent++;
                blockSizeAndOffset[0] *= 2;
                blockSizeAndOffset[1]++;
            }

            assert(blockSizeAndOffset[0] < 2 ^^ maxExponent);
            assert(blockSizeAndOffset[1] < maxExponent);
            if (blockSizeAndOffset[1] < NumberOfBlocks && *parent !is null) {
                Block* got = *parent;
                *parent = got.next;
                ret = splitUntilSize(got, blockSizeAndOffset[0], blockSizeAndOffset[1]);
            }
        }

        if (ret is null) {
            enum MaxShouldPower2 = 2 * 1024 * 1024 * 1024;

            size_t allocateSize = PAGESIZE();
            if (allocateSize < size)
                allocateSize = size;
            if (allocateSize < MaxShouldPower2 && allocateSize < blockSizeAndOffsetSource[0])
                allocateSize = blockSizeAndOffsetSource[0];

            ret = poolAllocator.allocate(allocateSize, ti);
            if (ret !is null)
                fullAllocations.store(ret);
            else
                assert(0);
        }

        if (ret !is null) {
            assert(ret.length >= size);

            allocations.store(ret);
            return ret[0 .. size];
        } else
            return null;
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if (void[] trueArray = allocations.getTrueRegionOfMemory(array)) {
            if (trueArray.length >= newSize) {
                array = trueArray[0 .. newSize];
                return true;
            }
        }

        return false;
    }

    ///
    bool deallocate(scope void[] array) {
        if (void[] trueArray = allocations.getTrueRegionOfMemory(array)) {
            size_t[2] blockSizeAndOffset = calculatePower2Size(trueArray.length, minExponent);
            allocations.remove(trueArray);

            if (blockSizeAndOffset[1] >= NumberOfBlocks) {
                fullAllocations.remove(trueArray);
                poolAllocator.deallocate(trueArray);
            } else {
                void[] fullSizeArray = fullAllocations.getTrueRegionOfMemory(trueArray);

                Loop: do {
                    void* startOfPrevious, startOfNext;

                    if (trueArray.ptr > fullSizeArray.ptr && cast(size_t)trueArray.ptr > trueArray.length)
                        startOfPrevious = trueArray.ptr - trueArray.length;

                    if (trueArray.ptr + trueArray.length < fullSizeArray.ptr + fullSizeArray.length)
                        startOfNext = trueArray.ptr + trueArray.length;

                    Block** parent = &blocks[blockSizeAndOffset[1]];
                    const taL2 = trueArray.length * 2;

                    for (;;) {
                        Block* current = *parent;
                        if (current is null)
                            break Loop;

                        assert(current.next is null || current.next.next is null || current.next.next !is null);

                        if (current is startOfPrevious) {
                            trueArray = startOfPrevious[0 .. taL2];
                            *parent = current.next;
                            break;
                        } else if (current is startOfNext) {
                            trueArray = trueArray.ptr[0 .. taL2];
                            *parent = current.next;
                            break;
                        }

                        parent = &current.next;
                    }

                    blockSizeAndOffset[0] *= 2;
                    blockSizeAndOffset[1]++;
                }
                while (blockSizeAndOffset[1] + 1 < NumberOfBlocks);

                {
                    void[] trueArrayOrigin = fullAllocations.getTrueRegionOfMemory(trueArray);

                    if (trueArrayOrigin.ptr is trueArray.ptr && trueArrayOrigin.length == trueArray.length) {
                        fullAllocations.remove(trueArray);
                        poolAllocator.deallocate(trueArray);
                    } else {
                        Block* blockToAdd = cast(Block*)trueArray.ptr;
                        blockToAdd.next = blocks[blockSizeAndOffset[1]];

                        blocks[blockSizeAndOffset[1]] = blockToAdd;
                    }
                }
            }

            return true;
        }

        return false;
    }

    ///
    Ternary owns(scope void[] array) {
        return allocations.owns(array) ? Ternary.yes : Ternary.no;
    }

    ///
    bool deallocateAll() {
        allocations.deallocateAll(null);
        fullAllocations.deallocateAll(&poolAllocator.deallocate);
        blocks = typeof(blocks).init;
        return true;
    }

    static if (__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            return blocks[$ - 1] is null && poolAllocator.empty();
        }
    }
}

///
unittest {
    import sidero.base.allocators.mapping.malloc;
    import sidero.base.allocators.buffers.region;

    alias BL = BuddyList!(Region!Mallocator);

    BL bl;
    assert(!bl.empty);
    assert(!bl.isNull);

    bl = BL();
    assert(!bl.empty);
    assert(!bl.isNull);

    auto tempAllocation = bl.poolAllocator.allocate(1024 * 1024);
    bl.poolAllocator.deallocate(tempAllocation[1 .. $]);

    void[] got1 = bl.allocate(1024);
    assert(got1 !is null);
    assert(got1.length == 1024);
    assert(bl.owns(null) == Ternary.no);
    assert(bl.owns(got1) == Ternary.yes);
    assert(bl.owns(got1[10 .. 20]) == Ternary.yes);

    void[] got2 = bl.allocate(512);
    assert(got2 !is null);
    assert(got2.length == 512);
    assert(bl.owns(null) == Ternary.no);
    assert(bl.owns(got2) == Ternary.yes);
    assert(bl.owns(got2[10 .. 20]) == Ternary.yes);

    void[] got3 = bl.allocate(1024);
    assert(got3 !is null);
    assert(got3.length == 1024);
    assert(bl.owns(null) == Ternary.no);
    assert(bl.owns(got3) == Ternary.yes);
    assert(bl.owns(got3[10 .. 20]) == Ternary.yes);

    bool success = bl.reallocate(got1, 2048);
    assert(success);
    assert(got1.length == 2048);

    success = bl.deallocate(got1);
    assert(success);
    success = bl.deallocate(got2);
    assert(success);
    success = bl.deallocate(got3);
    assert(success);

    got1 = bl.allocate(512);
    assert(got1 !is null);
    assert(got1.length == 512);
    assert(bl.owns(null) == Ternary.no);
    assert(bl.owns(got1) == Ternary.yes);
    assert(bl.owns(got1[10 .. 20]) == Ternary.yes);
}

private @hidden:

size_t[2] calculatePower2Size()(size_t requested, size_t minExponent) @safe nothrow @nogc pure {
    size_t value = 1, power;

    while (value < requested || power < minExponent) {
        value <<= 1;
        power++;
    }

    power -= minExponent;
    return [value, power];
}
