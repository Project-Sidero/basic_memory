module sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.text;
import sidero.base.attributes;

private {
    alias Sint = Slice!int;
}

///
struct Slice(T) {
    private @PrettyPrintIgnore {
        import sidero.base.internal.meta : OpApplyCombos;

        State!T* state;
        size_t _offset, _length;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            if(isNull)
                return 0;

            size_t offset;
            int result;

            Slice self = this;

            while(!self.empty) {
                Result!T temp = self.front();
                if(!temp)
                    return result;

                T got = temp;

                static if(__traits(compiles, del(offset, got)))
                    result = del(offset, got);
                else static if(__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if(result)
                    return result;

                offset++;
                self.popFront();
            }

            return result;
        }

        int opApplyReverseImpl(Del)(scope Del del) @trusted scope {
            if(isNull)
                return 0;

            size_t offset = this.length - 1;
            int result;

            Slice self = this;

            while(!self.empty) {
                Result!T temp = self.back();
                if(!temp)
                    return result;

                T got = temp;

                static if(__traits(compiles, del(offset, got)))
                    result = del(offset, got);
                else static if(__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if(result)
                    return result;

                offset--;
                self.popBack();
            }

            return result;
        }
    }

export:

    ///
    mixin OpApplyCombos!("T", "size_t", ["@safe", "nothrow", "@nogc"]);
    ///
    mixin OpApplyCombos!("T", "size_t", ["@safe", "nothrow", "@nogc"], "opApplyReverse");

    ///
    alias ElementType = T;
    ///
    alias LiteralType = const(T)[];

@safe nothrow @nogc:

    invariant () {
        if(state is null)
            return;

        assert(this._offset <= state.slice.length);

        if(this._length < size_t.max)
            assert(this._offset + this._length <= state.slice.length);
    }

    ///
    this(RCAllocator allocator) scope {
        this.ensureSetup(true, 0, allocator);
    }

    ///
    this(return scope T input, RCAllocator allocator = RCAllocator.init) scope @trusted {
        this.ensureSetup(true, 1, allocator);

        (cast(T[])this.unsafeGetLiteral())[0] = input;
    }

    ///
    this(return scope T[] input, RCAllocator allocator = RCAllocator.init) scope @trusted {
        this.ensureSetup(true, input.length, allocator);
        assert(this.length == input.length);

        foreach(i, ref v; cast(T[])this.unsafeGetLiteral())
            v = input[i];
    }

    ///
    this(return scope ref Slice other) scope {
        this.tupleof = other.tupleof;

        if(!isNull)
            this.state.rcExternal(true);
    }

    ///
    ~this() {
        if(isNull)
            return;

        this.state.rcExternal(false);
    }

    @disable auto opCast(T)();

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    inout(T)* ptr() scope inout @system {
        if(isNull)
            return null;

        return &state.slice[this._offset];
    }

    ///
    const(T)[] unsafeGetLiteral() return scope inout @system {
        if(isNull)
            return null;

        return state.slice[this._offset .. this._offset + this.length];
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope const {
        if(isNull)
            return 0;
        else if(this._length == size_t.max)
            return this.state.slice.length - this._offset;
        else
            return this._length;
    }

    ///
    Slice withoutIterator() return scope @trusted {
        if(isNull)
            return Slice.init;

        Slice ret = this;
        ret._offset = 0;
        ret._length = size_t.max;

        return ret;
    }

    ///
    void opAssign(return scope Slice other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    Result!Slice opSlice(ptrdiff_t start, ptrdiff_t end) {
        ErrorInfo errorInfo = changeIndexToOffset(start, end);
        if(errorInfo.isSet())
            return typeof(return)(errorInfo);

        Slice ret = this;
        ret._offset = this._offset + start;
        ret._length = end - start;

        return typeof(return)(ret);
    }

    ///
    Result!T opIndex(ptrdiff_t index) scope @trusted {
        ErrorInfo errorInfo = changeIndexToOffset(index);
        if(errorInfo.isSet())
            return typeof(return)(errorInfo);

        return typeof(return)(this.state.slice[this._offset + index]);
    }

    ///
    Slice dup(RCAllocator allocator = RCAllocator.init) scope @trusted {
        const newLength = this.length;

        Slice ret;
        ret.ensureSetup(true, newLength, allocator);
        ret.state.expand(0, newLength, newLength);
        ret._length = newLength;

        size_t offset;

        foreach(ref v; cast(T[])this.unsafeGetLiteral()) {
            ret.state.slice[offset++] = v;
        }

        return ret;
    }

    ///
    DynamicArray!ElementType asMutable(RCAllocator allocator = RCAllocator.init) scope @trusted {
        DynamicArray!ElementType temp = DynamicArray!ElementType(cast(T[])this.unsafeGetLiteral, allocator);
        return temp;
    }

    @property {
        ///
        bool empty() scope const {
            return this.length == 0;
        }

        ///
        Result!T front() scope {
            return this[0];
        }

        ///
        Result!T back() scope {
            return this[-1];
        }

        ///
        void popFront() scope {
            if(state is null)
                return;

            if(this._length == size_t.max)
                this._length = state.slice.length - this._offset;
            if(this._length == 0)
                return;

            this._offset++;
            this._length--;
        }

        ///
        void popBack() scope {
            if(state is null)
                return;
            if(this._length == size_t.max)
                this._length = state.slice.length - this._offset;
            if(this._length == 0)
                return;

            this._length--;
        }
    }

    @PrintIgnore @PrettyPrintIgnore {
        ///
        String_UTF8 toString(RCAllocator allocator = RCAllocator.init) @trusted {
            StringBuilder_UTF8 ret = StringBuilder_UTF8(allocator);
            toString(ret);
            return ret.asReadOnly;
        }

        ///
        void toString(Sink)(scope ref Sink sink) @trusted {
            sink.formattedWrite("", this.unsafeGetLiteral());
        }

        ///
        String_UTF8 toStringPretty(RCAllocator allocator = RCAllocator.init) @trusted {
            StringBuilder_UTF8 ret = StringBuilder_UTF8(allocator);
            toStringPretty(ret);
            return ret.asReadOnly;
        }

        ///
        void toStringPretty(Sink)(scope ref Sink sink) @trusted {
            PrettyPrint prettyPrint = PrettyPrint.defaults;
            prettyPrint(sink, this.unsafeGetLiteral());
        }
    }

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils : hashOf;

        const data = this.unsafeGetLiteral();
        return hashOf(data);
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope const T[] other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral();
        return genericCompare(dataUs, other) == 0;
    }

    ///
    bool opEquals(scope const Slice other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther) == 0;
    }

    ///
    bool opEquals(scope const DynamicArray!T other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther) == 0;
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope const T[] other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral();
        return genericCompare(dataUs, other);
    }

    ///
    int opCmp(scope const Slice other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther);
    }

    ///
    int opCmp(scope const DynamicArray!T other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther);
    }

    ///
    bool startsWith(scope DynamicArray!T other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope Slice other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if(other.length > us.length)
            return false;
        return genericCompare(us[0 .. other.length], other) == 0;
    }

    ///
    bool endsWith(scope DynamicArray!T other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope Slice other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if(us.length == 0 || other.length == 0 || us.length < other.length)
            return false;
        return genericCompare(us[$ - other.length .. $], other) == 0;
    }

    ///
    ptrdiff_t indexOf(scope DynamicArray!T other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope Slice other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if(other.length > us.length)
            return -1;

        foreach(i; 0 .. (us.length + 1) - other.length) {
            if(genericCompare(us[i .. i + other.length], other) == 0)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t lastIndexOf(scope DynamicArray!T other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope Slice other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if(other.length > us.length)
            return -1;

        foreach_reverse(i; 0 .. (us.length + 1) - other.length) {
            if(genericCompare(us[i .. i + other.length], other) == 0)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t count(scope DynamicArray!T other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t count(scope Slice other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    size_t count(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if(other.length > us.length)
            return 0;

        size_t got;

        while(us.length >= other.length) {
            if(genericCompare(us[0 .. other.length], other) == 0) {
                got++;
                us = us[other.length .. $];
            } else
                us = us[1 .. $];
        }

        return got;
    }

    ///
    bool contains(scope DynamicArray!T other) scope {
        if(other.isNull)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    bool contains(scope Slice other) scope {
        if(other.isNull)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    bool contains(scope LiteralType other...) scope {
        if(other is null)
            return 0;
        return indexOf(other) >= 0;
    }

    package(sidero.base.containers) static Slice fromDynamicArray(RCAllocator allocator, SliceMemory* sliceMemory, T[] slice) @trusted {
        // This is almost guaranteed to be initialized with the DynamicArray,
        //  so don't worry too much about exports.
        import sidero.base.internal.atomic;

        Slice ret;

        ret.state = allocator.make!(State!T);
        ret.state.allocator = allocator;
        atomicStore(ret.state.refCount, 1);

        ret._offset = slice.ptr - (cast(T*)sliceMemory.original.ptr);
        ret._length = slice.length;

        ret.state.sliceMemory = sliceMemory;
        sliceMemory.rcExternal(true);

        ret.state.slice = slice;
        return ret;
    }

private:

    void ensureSetup(bool willModify, size_t amountNeeded = 0, RCAllocator allocator = RCAllocator.init) scope @trusted {
        import sidero.base.allocators.utils : fillUninitializedWithInit;
        import sidero.base.internal.atomic;

        void createState() {
            if(allocator.isNull)
                allocator = globalAllocator();

            this.state = allocator.make!(State!T);
            this.state.allocator = allocator;
            atomicStore(this.state.refCount, 1);

            this._offset = 0;
            this._length = size_t.max;
        }

        void createSliceMemory() {
            this.state.sliceMemory = allocator.make!SliceMemory;
            this.state.sliceMemory.allocator = allocator;
            atomicStore(this.state.sliceMemory.refCount, 1);

            static void cleanup(void[] slice) @trusted {
                T[] array = cast(T[])slice;

                foreach(ref v; array) {
                    v.destroy;
                }
            }

            static void initElements(void[] slice) @trusted {
                T[] array = cast(T[])slice;

                fillUninitializedWithInit(array);
            }

            static void copyElements(void[] from, void[] into) @trusted {
                T[] from2 = cast(T[])from;
                T[] into2 = cast(T[])into;
                assert(from2.length <= into2.length);

                foreach(i; 0 .. from2.length) {
                    into2[i] = from2[i];
                }
            }

            this.state.sliceMemory.initElements = &initElements;
            this.state.sliceMemory.cleanup = &cleanup;
            this.state.sliceMemory.copyElements = &copyElements;
        }

        if(this.state is null) {
            // If we are currently null, we merely need to construct state

            createState();
            createSliceMemory();

            if(amountNeeded > 0)
                this.state.expand(0, 0, amountNeeded, true);

            return;
        } else
            assert(0);
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a) scope @trusted {
        if(this.isNull)
            return ErrorInfo(NullPointerException("Dynamic array is null"));

        size_t actualLength = this.length;

        if(a < 0) {
            if(actualLength < -a)
                return ErrorInfo(RangeException("First index must be smaller than length"));
            a = actualLength + a;
        }

        if(a > actualLength) {
            if(a < ptrdiff_t.max)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength;
        }

        return ErrorInfo.init;
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a, ref ptrdiff_t b) scope @trusted {
        if(this.isNull)
            return ErrorInfo(NullPointerException("Dynamic array is null"));

        size_t actualLength = this.length;

        if(a < 0) {
            if(actualLength < -a)
                return ErrorInfo(RangeException("First index must be smaller than length"));
            a = actualLength + a;
        }

        if(b < 0) {
            if(actualLength < -b)
                return ErrorInfo(RangeException("Second index must be smaller than length"));
            b = actualLength + b;
        }

        if(b < a) {
            ptrdiff_t temp = a;
            a = b;
            b = temp;
        }

        if(a > actualLength) {
            if(a < ptrdiff_t.max)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength;
        }
        if(b > actualLength) {
            if(b < ptrdiff_t.max)
                return ErrorInfo(RangeException("Second offset must be smaller than length"));
            b = actualLength;
        }

        return ErrorInfo.init;
    }
}

///
unittest {
    alias SliceI = Slice!int;

    {
        SliceI da2 = SliceI([2, 6, 9, 1]);
        assert(da2 == [2, 6, 9, 1]);

        Result!int aValue = da2[1];
        assert(aValue, aValue.getError.toString().unsafeGetLiteral);
        assert(aValue == 6);
        aValue = da2[-2];
        assert(aValue, aValue.getError.toString().unsafeGetLiteral);
        assert(aValue == 9);
        aValue = da2[$ - 2];
        assert(aValue, aValue.getError.toString().unsafeGetLiteral);
        assert(aValue == 9);

        Result!SliceI da2slice = da2[1 .. -1];
        assert(da2slice, da2slice.getError.toString().unsafeGetLiteral);
        assert(da2slice.length == 2);
        assert(da2slice.assumeOkay == [6, 9]);

        aValue = da2slice[0];
        assert(aValue, aValue.getError.toString().unsafeGetLiteral);
        assert(aValue == 6);
        aValue = da2slice[-1];
        assert(aValue, aValue.getError.toString().unsafeGetLiteral);
        assert(aValue == 9);
        aValue = da2slice[$ - 1];
        assert(aValue, aValue.getError.toString().unsafeGetLiteral);
        assert(aValue == 9);

        ErrorResult didAssign = da2[2] = 6270;
        assert(didAssign);
        Result!int checkValue = da2[2];
        assert(checkValue);
        assert(checkValue == 6270);
        assert(da2 == [2, 6, 6270, 1]);
    }

    {
        assert(SliceI([1, 2, 3]) < [4, 5, 6]);
        assert(SliceI([1, 2, 3]) < [1, 2, 3, 4]);
        assert(SliceI([1, 2, 3]) < [1, 2, 4]);
        assert(SliceI([1, 2, 3]) > [1, 2]);
        assert(SliceI([1, 2, 3]) > [1, 2, 1]);
        assert(SliceI([1, 2, 3]) == [1, 2, 3]);

        assert(SliceI([1, 2, 3]) < SliceI([4, 5, 6]));
        assert(SliceI([1, 2, 3]) < SliceI([1, 2, 3, 4]));
        assert(SliceI([1, 2, 3]) < SliceI([1, 2, 4]));
        assert(SliceI([1, 2, 3]) > SliceI([1, 2]));
        assert(SliceI([1, 2, 3]) > SliceI([1, 2, 1]));
        assert(SliceI([1, 2, 3]) == SliceI([1, 2, 3]));
    }

    {
        int[] data = [4, 5, 6, 9, 22, 7, 13, 10000000];
        ptrdiff_t lastSeen = -1, seen;

        foreach(i, v; SliceI(data)) {
            assert(lastSeen + 1 == i);
            assert(data[i] == v);

            lastSeen = i;
            seen++;
        }
        assert(seen == data.length);

        lastSeen = 8;
        seen = 0;
        foreach_reverse(i, v; SliceI(data)) {
            assert(lastSeen - 1 == i);
            assert(data[i] == v);

            lastSeen = i;
            seen++;
        }
        assert(seen == data.length);

        seen = 0;
        foreach(v; SliceI(data)) {
            assert(data[seen] == v);
            seen++;
        }
        assert(seen == data.length);
    }
}

private:
import sidero.base.containers.internal.slice;

struct State(ElementType) {
    RCAllocator allocator;
    shared(ptrdiff_t) refCount;

    SliceMemory* sliceMemory;
    ElementType[] slice;

export @safe nothrow @nogc:

    void rcExternal(bool addRef) scope @trusted {
        import sidero.base.internal.atomic;

        if(addRef)
            atomicIncrementAndLoad(this.refCount, 1);
        else if(atomicDecrementAndLoad(this.refCount, 1) == 0) {
            sliceMemory.rcExternal(false);

            RCAllocator allocator = this.allocator;
            allocator.dispose(&this);
        }
    }

    void expand(size_t offset, size_t length, size_t newLength, bool sliceIt = true) scope @trusted {
        if(newLength <= this.slice.length)
            return;
        else if(length == size_t.max)
            length = this.slice.length;

        bool canExpandIntoOriginal() scope const {
            size_t temp = offset;
            temp += length;
            temp *= ElementType.sizeof;

            if(temp != this.sliceMemory.amountUsed)
                return false;

            temp = offset;
            temp += newLength;
            temp *= ElementType.sizeof;

            return temp <= this.sliceMemory.original.length;
        }

        const offsetT = offset * ElementType.sizeof;
        const oldLengthT = length * ElementType.sizeof;
        const newLengthT = newLength * ElementType.sizeof;

        const oldEndOffsetT = offsetT + oldLengthT;
        const newEndOffsetT = offsetT + newLengthT;

        if(canExpandIntoOriginal()) {
        } else {
            sliceMemory.expandInternal(newEndOffsetT);
        }

        if(sliceIt) {
            this.slice = cast(ElementType[])(this.sliceMemory.original[offsetT .. newEndOffsetT]);
            sliceMemory.amountUsed = newEndOffsetT;
        } else {
            this.slice = cast(ElementType[])(this.sliceMemory.original[offsetT .. oldEndOffsetT]);
        }
    }

    ulong toHash() scope const {
        assert(0);
    }

    bool opEquals(scope const State other) scope const {
        assert(0);
    }

    int opCmp(scope const State other) scope const {
        assert(0);
    }
}
