module sidero.base.containers.internal.slice;
import sidero.base.allocators;

package(sidero.base):

struct SliceMemory {
    shared(ptrdiff_t) refCount;
    RCAllocator allocator;

    void[] original;
    size_t amountUsed;

    void function(void[] slice) @safe nothrow @nogc initElements, cleanup;
    void function(void[] from, void[] into) @safe nothrow @nogc copyElements;

export @safe nothrow @nogc:

    void rcExternal(bool addRef) scope @trusted {
        import sidero.base.internal.atomic;

        if (addRef) {
            atomicIncrementAndLoad(this.refCount, 1);
        } else if (atomicDecrementAndLoad(this.refCount, 1) == 0) {
            RCAllocator allocator = this.allocator;

            if (this.cleanup !is null)
                this.cleanup(original[0 .. this.amountUsed]);

            if (this.original.length > 0)
                allocator.dispose(this.original);
            allocator.dispose(&this);
        }
    }

    void expandInternal(size_t newSize) scope @trusted {
        import sidero.base.internal.logassert : logAssert;

        const oldSize = this.original.length;
        logAssert(oldSize < newSize, "New size of slice is smaller than existing size");

        if (newSize > 0) {
            if (oldSize == 0) {
                this.original = this.allocator.allocate(newSize);
                this.initElements(this.original);
            } else if (this.allocator.reallocate(this.original, newSize)) {
                this.initElements(this.original[oldSize .. $]);
            } else {
                void[] temp = this.allocator.allocate(newSize);
                this.initElements(temp);

                this.copyElements(this.original[0 .. this.amountUsed], temp[0 .. this.amountUsed]);
                this.cleanup(this.original);

                this.allocator.deallocate(this.original);
                this.original = temp;
            }
        }
    }

    SliceMemory* dup(size_t amountNotNeeded, size_t amountNeeded, RCAllocator allocator) scope @trusted {
        import sidero.base.internal.atomic : atomicStore;

        assert(!allocator.isNull);

        // First we need to know what the offset into the original buffer size,
        //  then we must calculate how much of the original buffer is available to copy over,
        //  lastly calculate the amount that will be copied over
        const offsetIntoOriginalBuffer = amountNotNeeded;
        const availableFromOriginalBuffer = this.amountUsed - offsetIntoOriginalBuffer;
        const amountFromOriginalBuffer = amountNeeded > availableFromOriginalBuffer ? availableFromOriginalBuffer : amountNeeded;
        // [offsetIntoOriginalBuffer .. offsetIntoOriginalBuffer + amountFromOriginalBuffer]

        // So how much are we going to allocate?
        const amountForNewBuffer = amountNeeded;

        SliceMemory* ret = allocator.make!SliceMemory;
        ret.allocator = allocator;
        ret.amountUsed = amountFromOriginalBuffer;

        atomicStore(ret.refCount, 1);

        ret.initElements = this.initElements;
        ret.cleanup = this.cleanup;
        ret.copyElements = this.copyElements;

        ret.original = allocator.makeArray!void(amountForNewBuffer);
        ret.initElements(ret.original);
        ret.copyElements(this.original[offsetIntoOriginalBuffer .. offsetIntoOriginalBuffer + amountFromOriginalBuffer],
                ret.original[0 .. amountFromOriginalBuffer]);

        return ret;
    }

    size_t expand(ElementType)(size_t offset, size_t length, size_t newLength, bool adjustToNewSize = true) scope @trusted {
        bool canExpandIntoOriginal() scope const {
            size_t temp = offset;
            temp += length;
            temp *= ElementType.sizeof;

            if (temp != this.amountUsed)
                return false;

            temp = offset;
            temp += newLength;
            temp *= ElementType.sizeof;

            return temp <= this.original.length;
        }

        const offsetT = offset * ElementType.sizeof;
        const oldLengthT = length * ElementType.sizeof;
        const newLengthT = newLength * ElementType.sizeof;

        const oldEndOffsetT = offsetT + oldLengthT;
        const newEndOffsetT = offsetT + newLengthT;

        if (canExpandIntoOriginal()) {
        } else {
            this.expandInternal(newEndOffsetT);
        }

        if (adjustToNewSize) {
            this.amountUsed = newEndOffsetT;
            return newEndOffsetT;
        } else
            return oldEndOffsetT;
    }

    void opAssign(SliceMemory other) scope {
        this.tupleof = other.tupleof;
    }

    ulong toHash() scope const {
        assert(0);
    }

    bool opEquals(scope const SliceMemory other) scope const {
        assert(0);
    }

    int opCmp(scope const SliceMemory other) scope const {
        assert(0);
    }

    static SliceMemory configureFor(Type)(RCAllocator allocator, void[] block=null, size_t amountUsed=0) {
        SliceMemory ret = SliceMemory(1, allocator, block, amountUsed);

        static void cleanup(void[] slice) @trusted {
            Type[] array = (cast(Type*)slice.ptr)[0 .. slice.length / Type.sizeof];

            foreach (ref v; array) {
                v.destroy;
            }
        }

        static void initElements(void[] slice) @trusted {
            import sidero.base.allocators.utils : fillUninitializedWithInit;
            Type[] array = (cast(Type*)slice.ptr)[0 .. slice.length / Type.sizeof];

            fillUninitializedWithInit(array);
        }

        static void copyElements(void[] from, void[] into) @trusted {
            Type[] from2 = (cast(Type*)from.ptr)[0 .. from.length / Type.sizeof];
            Type[] into2 = (cast(Type*)into.ptr)[0 .. into.length / Type.sizeof];
            assert(from2.length <= into2.length);

            foreach (i; 0 .. from2.length) {
                into2[i] = from2[i];
            }
        }

        ret.initElements = &initElements;
        ret.cleanup = &cleanup;
        ret.copyElements = &copyElements;

        return ret;
    }
}
