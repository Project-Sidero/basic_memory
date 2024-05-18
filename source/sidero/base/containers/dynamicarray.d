module sidero.base.containers.dynamicarray;
import sidero.base.containers.readonlyslice;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.text;
import sidero.base.attributes;

private {
    alias DAint = DynamicArray!int;
}

///
struct DynamicArray(T) {
    private @PrettyPrintIgnore {
        import sidero.base.internal.meta : OpApplyCombos;

        State!T* state;
        size_t _offset, _length;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            size_t offset;
            int result;

            DynamicArray self = this;

            while (!self.empty) {
                Result!T temp = self.front();
                if (!temp)
                    return result;

                T got = temp;

                static if (__traits(compiles, del(offset, got)))
                    result = del(offset, got);
                else static if (__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if (result)
                    return result;

                offset++;
                self.popFront();
            }

            return result;
        }

        int opApplyReverseImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            size_t offset = this.length - 1;
            int result;

            DynamicArray self = this;

            while (!self.empty) {
                Result!T temp = self.back();
                if (!temp)
                    return result;

                T got = temp;

                static if (__traits(compiles, del(offset, got)))
                    result = del(offset, got);
                else static if (__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if (result)
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
        if (state is null)
            return;

        assert(this._offset <= state.slice.length);

        if (this._length < size_t.max)
            assert(this._offset + this._length <= state.slice.length);
    }

    ///
    this(RCAllocator allocator) scope {
        this.ensureSetup(true, 0, allocator);
    }

    ///
    this(return scope T input, RCAllocator allocator = RCAllocator.init) scope @trusted {
        this.ensureSetup(true, 1, allocator);

        this.unsafeGetLiteral()[0] = input;
    }

    ///
    this(return scope T[] input, RCAllocator allocator = RCAllocator.init) scope @trusted {
        this.ensureSetup(true, input.length, allocator);
        assert(this.length == input.length);
        assert(this.capacity >= input.length);

        foreach (i, ref v; this.unsafeGetLiteral())
            v = input[i];
    }

    ///
    this(return scope Slice!T initial, RCAllocator allocator = RCAllocator.init) scope @trusted {
        this(cast(T[])initial.unsafeGetLiteral, allocator);
    }

    ///
    this(return scope ref DynamicArray other) scope {
        this.tupleof = other.tupleof;

        if (!isNull)
            this.state.rcExternal(true);
    }

    ///
    ~this() {
        if (isNull)
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
        if (isNull)
            return null;

        return &state.slice[this._offset];
    }

    ///
    inout(T)[] unsafeGetLiteral() return scope inout @system {
        if (isNull)
            return null;

        return state.slice[this._offset .. this._offset + this.length];
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope const {
        if (isNull)
            return 0;
        else if (this._length == size_t.max)
            return this.state.slice.length - this._offset;
        else
            return this._length;
    }

    ///
    void length(size_t newLength) scope {
        const currentLength = this.length;
        ensureSetup(true, newLength);

        this.state.expand(this._offset, currentLength, newLength);

        if (this._offset + newLength == this.state.slice.length)
            this._length = size_t.max;
        else
            this._length = newLength;
    }

    ///
    size_t capacity() scope const {
        if (isNull)
            return 0;

        const total = this.state.sliceMemory.original.length / T.sizeof;
        return total - this._offset;
    }

    ///
    void reserve(size_t amount) scope {
        const currentLength = this.length;
        const newLength = currentLength + amount;

        ensureSetup(true, currentLength);
        this.state.expand(this._offset, currentLength, newLength, false);
    }

    ///
    DynamicArray withoutIterator() return scope @trusted {
        if (isNull)
            return DynamicArray.init;

        DynamicArray ret = this;
        ret._offset = 0;
        ret._length = size_t.max;

        return ret;
    }

    ///
    void copyOnWrite() {
        if (state !is null)
            state.copyOnWrite = true;
    }

    ///
    void opAssign(return scope DynamicArray other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    void opAssign(scope T input) scope @trusted {
        foreach (ref v; this.unsafeGetLiteral)
            v = input;
    }

    ///
    void opAssign(scope T[] input...) scope @trusted {
        this.ensureSetup(true, input.length);

        if (this.length < input.length)
            length = input.length;

        auto original = this.unsafeGetLiteral();
        auto slice = original[0 .. input.length];

        foreach (i, ref v; slice)
            v = input[i];
    }

    ///
    void opAssign(scope const(T)[] input...) scope @trusted {
        this.ensureSetup(true, input.length);

        if (this.length < input.length)
            length = input.length;

        auto original = this.unsafeGetLiteral();
        auto slice = original[0 .. input.length];

        foreach (i, ref v; slice)
            v = *cast(T*)&input[i];
    }

    ///
    void opAssign(scope Slice!T input) scope @trusted {
        this.opAssign(input.unsafeGetLiteral);
    }

    ///
    Result!DynamicArray opSlice(ptrdiff_t start, ptrdiff_t end) {
        ErrorInfo errorInfo = changeIndexToOffset(start, end);
        if (errorInfo.isSet())
            return typeof(return)(errorInfo);

        DynamicArray ret = this;
        ret._offset = this._offset + start;
        ret._length = end - start;

        return typeof(return)(ret);
    }

    ///
    Result!T opIndex(ptrdiff_t index) scope @trusted {
        ErrorInfo errorInfo = changeIndexToOffset(index);
        if (errorInfo.isSet())
            return typeof(return)(errorInfo);

        return typeof(return)(this.state.slice[this._offset + index]);
    }

    ///
    ErrorResult opIndexAssign(T input, ptrdiff_t index) scope @trusted {
        ErrorInfo errorInfo = changeIndexToOffset(index);
        if (errorInfo.isSet())
            return typeof(return)(errorInfo);

        this.state.slice[this._offset + index] = input;
        return ErrorResult.init;
    }

    ///
    void opOpAssign(string op : "~")(return scope T input) scope @trusted {
        const oldLength = this.length;
        ensureSetup(true, oldLength + 1);

        this.state.expand(this._offset, oldLength, oldLength + 1);

        if (this._length == size_t.max) {
            this.state.slice[$ - 1] = input;
        } else {
            this.state.slice[this._offset + this._length] = input;
            this._length++;
        }
    }

    ///
    void opOpAssign(string op : "~")(return scope T[] input) scope @trusted {
        const oldLength = this.length;
        ensureSetup(true, oldLength + input.length);

        this.state.expand(this._offset, oldLength, oldLength + input.length);

        if (this._length == size_t.max) {
            const offset = this.state.slice.length - input.length;

            foreach (i, ref v; input) {
                this.state.slice[offset + i] = v;
            }
        } else {
            size_t offset = this._offset + this._length;

            foreach (ref v; input) {
                this.state.slice[offset++] = v;
            }

            this._length += input.length;
        }
    }

    ///
    void opOpAssign(string op : "~")(return scope Slice!T input) scope @trusted {
        this.opOpAssign!op(cast(T[])input.unsafeGetLiteral());
    }

    ///
    void opOpAssign(string op : "~")(return scope DynamicArray input) scope @trusted {
        ensureSetup(true, this.length + input.length);

        this.state.expand(this._offset, this._length, this._length + input.length);

        if (this._length == size_t.max) {
            const offset = this.state.slice.length - input.length;

            foreach (i, ref v; input.unsafeGetLiteral()) {
                this.state.slice[offset + i] = v;
            }
        } else {
            size_t offset = this._offset + this._length;

            foreach (ref v; input.unsafeGetLiteral()) {
                this.state.slice[offset++] = v;
            }

            this._length += input.length;
        }
    }

    ///
    DynamicArray opBinary(string op : "~")(return scope T input) scope @trusted {
        const newLength = this.length + 1;

        DynamicArray ret;
        ret.ensureSetup(true, newLength);
        ret.state.expand(0, newLength, newLength);
        ret._length = newLength;

        size_t offset;

        foreach (ref v; this.unsafeGetLiteral()) {
            ret.state.slice[offset++] = v;
        }

        ret.state.slice[offset++] = input;
        return ret;
    }

    ///
    DynamicArray opBinary(string op : "~")(return scope T[] input) scope @trusted {
        const newLength = this.length + input.length;

        DynamicArray ret;
        ret.ensureSetup(true, newLength);
        ret.state.expand(0, newLength, newLength);
        ret._length = newLength;

        size_t offset;

        foreach (ref v; this.unsafeGetLiteral()) {
            ret.state.slice[offset++] = v;
        }

        foreach (ref v; input) {
            ret.state.slice[offset++] = v;
        }

        return ret;
    }

    ///
    DynamicArray opBinary(string op : "~")(return scope Slice!T input) scope @trusted {
        return this.opBinary!op(input.unsafeGetLiteral);
    }

    ///
    DynamicArray opBinary(string op : "~")(return scope DynamicArray input) scope @trusted {
        const newLength = this.length + input.length;

        DynamicArray ret;
        ret.ensureSetup(true, newLength);
        ret.state.expand(0, newLength, newLength);
        ret._length = newLength;

        size_t offset;

        foreach (ref v; this.unsafeGetLiteral()) {
            ret.state.slice[offset++] = v;
        }

        foreach (ref v; input.unsafeGetLiteral()) {
            ret.state.slice[offset++] = v;
        }

        return ret;
    }

    ///
    DynamicArray dup(RCAllocator allocator = RCAllocator.init) scope @trusted {
        const newLength = this.length;

        DynamicArray ret;
        ret.ensureSetup(true, newLength, allocator);
        ret.state.expand(0, newLength, newLength);
        ret._length = newLength;

        size_t offset;

        foreach (ref v; this.unsafeGetLiteral()) {
            ret.state.slice[offset++] = v;
        }

        return ret;
    }

    ///
    Slice!T asReadOnly(RCAllocator allocator = RCAllocator.init) scope @trusted {
        if (isNull)
            return Slice!T();
        else if (allocator.isNull)
            allocator = globalAllocator();

        this.copyOnWrite;

        return Slice!T.fromDynamicArray(this.state.sliceMemory, this.unsafeGetLiteral());
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
            if (state is null)
                return;

            if (this._length == size_t.max)
                this._length = state.slice.length - this._offset;
            if (this._length == 0)
                return;

            this._offset++;
            this._length--;
        }

        ///
        void popBack() scope {
            if (state is null)
                return;
            if (this._length == size_t.max)
                this._length = state.slice.length - this._offset;
            if (this._length == 0)
                return;

            this._length--;
        }

        ///
        void put(return scope T value) scope {
            opOpAssign!"~"(value);
        }

        ///
        void put(return scope T[] values) scope {
            opOpAssign!"~"(values);
        }

        ///
        void put(return scope Slice!T values) scope @trusted {
            opOpAssign!"~"(cast(T[])values.unsafeGetLiteral);
        }

        ///
        void put(return scope DynamicArray values) scope {
            opOpAssign!"~"(values);
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
    bool opEquals(scope const Slice!T other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther) == 0;
    }

    ///
    bool opEquals(scope const DynamicArray other) scope const @trusted {
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
    int opCmp(scope const Slice!T other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther);
    }

    ///
    int opCmp(scope const DynamicArray other) scope const @trusted {
        import sidero.base.containers.utils : genericCompare;

        const dataUs = this.unsafeGetLiteral(), dataOther = other.unsafeGetLiteral();
        return genericCompare(dataUs, dataOther);
    }

    ///
    bool startsWith(scope DynamicArray other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope Slice!T other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return false;
        return genericCompare(us[0 .. other.length], other) == 0;
    }

    ///
    bool endsWith(scope DynamicArray other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope Slice!T other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if (us.length == 0 || other.length == 0 || us.length < other.length)
            return false;
        return genericCompare(us[$ - other.length .. $], other) == 0;
    }

    ///
    ptrdiff_t indexOf(scope DynamicArray other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope Slice!T other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return -1;

        foreach (i; 0 .. (us.length + 1) - other.length) {
            if (genericCompare(us[i .. i + other.length], other) == 0)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t lastIndexOf(scope DynamicArray other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope Slice!T other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return -1;

        foreach_reverse (i; 0 .. (us.length + 1) - other.length) {
            if (genericCompare(us[i .. i + other.length], other) == 0)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t count(scope DynamicArray other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t count(scope Slice!T other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    size_t count(scope LiteralType other...) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return 0;

        size_t got;

        while (us.length >= other.length) {
            if (genericCompare(us[0 .. other.length], other) == 0) {
                got++;
                us = us[other.length .. $];
            } else
                us = us[1 .. $];
        }

        return got;
    }

    ///
    bool contains(scope DynamicArray other) scope {
        if (other.isNull)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    bool contains(scope Slice!T other) scope {
        if (other.isNull)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    bool contains(scope LiteralType other...) scope {
        if (other is null)
            return 0;
        return indexOf(other) >= 0;
    }

private:

    void ensureSetup(bool willModify, size_t amountNeeded = 0, RCAllocator allocator = RCAllocator.init) scope @trusted {
        import sidero.base.allocators.utils : fillUninitializedWithInit;
        import sidero.base.internal.atomic;

        void createState() {
            if (allocator.isNull)
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

                foreach (ref v; array) {
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

                foreach (i; 0 .. from2.length) {
                    into2[i] = from2[i];
                }
            }

            this.state.sliceMemory.initElements = &initElements;
            this.state.sliceMemory.cleanup = &cleanup;
            this.state.sliceMemory.copyElements = &copyElements;
        }

        if (this.state is null) {
            // If we are currently null, we merely need to construct state

            createState();
            createSliceMemory();

            if (amountNeeded > 0)
                this.state.expand(0, 0, amountNeeded, true);

            return;
        } else {
            // Okay so we are not null, what is our current end point,
            //  if our end is what we are wanting, we're done.

            const actualEnd = this.state.slice.length;
            const actualLength = this._length < size_t.max ? this._length : (actualEnd - this._offset);
            const ourEnd = this._offset + actualLength;
            const wantedEnd = this._offset + amountNeeded;

            if (ourEnd == wantedEnd && !state.copyOnWrite)
                return; // Nothing needs to change
            else if (wantedEnd > 0 && wantedEnd < ourEnd)
                return; // Already allocated

            if (amountNeeded > 0 && ourEnd == actualEnd && !this.state.copyOnWrite) {
                this.state.expand(this._offset, this._length, amountNeeded);
                return;
            }

            const actualOffsetT = this._offset * T.sizeof;
            const amountWanted = amountNeeded == 0 ? actualLength : amountNeeded;
            const amountWantedT = amountWanted * T.sizeof;

            {
                State!T* oldState = this.state;

                createState();
                this.state.sliceMemory = oldState.sliceMemory.dup(actualOffsetT, amountWantedT, allocator);
                this.state.slice = cast(T[])this.state.sliceMemory.original[0 .. amountWantedT];

                oldState.rcExternal(false);
            }
        }
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a) scope @trusted {
        if (this.isNull)
            return ErrorInfo(NullPointerException("Dynamic array is null"));

        size_t actualLength = this.length;

        if (a < 0) {
            if (actualLength < -a)
                return ErrorInfo(RangeException("First index must be smaller than length"));
            a = actualLength + a;
        }

        if (a > actualLength) {
            if (a < ptrdiff_t.max)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength;
        }

        return ErrorInfo.init;
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a, ref ptrdiff_t b) scope @trusted {
        if (this.isNull)
            return ErrorInfo(NullPointerException("Dynamic array is null"));

        size_t actualLength = this.length;

        if (a < 0) {
            if (actualLength < -a)
                return ErrorInfo(RangeException("First index must be smaller than length"));
            a = actualLength + a;
        }

        if (b < 0) {
            if (actualLength < -b)
                return ErrorInfo(RangeException("Second index must be smaller than length"));
            b = actualLength + b;
        }

        if (b < a) {
            ptrdiff_t temp = a;
            a = b;
            b = temp;
        }

        if (a > actualLength) {
            if (a < ptrdiff_t.max)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength;
        }
        if (b > actualLength) {
            if (b < ptrdiff_t.max)
                return ErrorInfo(RangeException("Second offset must be smaller than length"));
            b = actualLength;
        }

        return ErrorInfo.init;
    }
}

///
unittest {
    import sidero.base.console;

    alias DA = DynamicArray!int;

    {
        DA da1;
        assert(da1.ptr is null);
        assert(da1.length == 0);
        assert(da1.isNull);
        assert(da1.capacity == 0);

        da1.length = 5;
        assert(da1 == [0, 0, 0, 0, 0]);
        assert(da1.length == 5);
        assert(da1.ptr !is null);
        assert(!da1.isNull);

        da1 = [1, 2, 3, 4, 5];
        assert(da1 == [1, 2, 3, 4, 5]);
        assert(da1.toString().endsWith("[1, 2, 3, 4, 5]"));

        da1.reserve(64);
        assert(da1.capacity == 64 + 5);
        assert(da1.length == 5);

        da1.reserve(32);
        assert(da1.capacity == 64 + 5);
        assert(da1.length == 5);

        da1 ~= 9;
        Result!int aValue = da1[$ - 1];
        assert(aValue);
        assert(aValue == 9);
        assert(da1.length == 6);
        assert(da1.capacity == 63 + 6);
    }

    {
        DA da2;
        da2 = [2, 6, 9, 1];
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

        Result!DA da2slice = da2[1 .. -1];
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
        DAint da3;
        da3.reserve(2);
        assert(da3.capacity == 2);
        assert(da3.length == 0);

        da3.length = 2;
        assert(da3.length == 2);
        assert(da3.capacity == 2);

        da3.length = 5;
        assert(da3.length == 5);
        assert(da3.capacity == 5);

        Result!DAint da3slice = da3[0 .. 3];
        assert(da3slice, da3slice.getError.toString().unsafeGetLiteral);
        assert(da3slice.length == 3);

        da3slice.length = 8;
        assert(da3slice.length == 8);
        assert(da3slice.capacity == 8);

        DAint da3dup = da3.dup;
        assert(da3dup.length == da3.length);
        assert(da3dup.capacity == da3.capacity);
        assert(da3dup.unsafeGetLiteral == da3.unsafeGetLiteral);
    }

    {
        DAint da4a, da4b, da4c;
        da4a = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
        da4b = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19];

        da4c = da4a ~ da4b;
        assert(da4a.length == 10);
        assert(da4b.length == 10);
        assert(da4c.length == 20);

        // we don't want state to be duplicated for these tests
        da4c.reserve(34);

        assert(da4a.capacity == 10);
        assert(da4b.capacity == 10);
        assert(da4c.capacity >= 34);
        assert(da4c == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]);

        Result!DAint da4cslice = da4c[-1 .. -2];
        assert(da4cslice);
        assert(da4cslice.length == 1);
        assert(da4cslice.assumeOkay == [18]);

        assert(da4c[-4 .. -2].assumeOkay == [16, 17]);
        assert(da4c.length == 20);
        assert(da4c.state is da4cslice.state);

        da4cslice ~= 42;
        assert(da4c.state !is da4cslice.state);
        assert(da4cslice.length == 2);
        assert(da4c.length == 20);

        da4c ~= 64;
        assert(da4c[$ - 1].assumeOkay == 64);
        assert(da4c.length == 21);

        da4c ~= [72, 74];
        assert(da4c[-2 .. $].assumeOkay == [72, 74]);
        assert(da4c.length == 23);

        da4c ~= [53, 52, 85, 41, 12, 12, 12, 7, 0, 1];
        assert(da4c.length == 33);

        da4c.copyOnWrite;
        DAint da4d = da4c;
        da4d ~= 2;

        assert(!da4c.isNull);
        assert(!da4d.isNull);
        assert(da4d.ptr !is da4c.ptr);
        assert(da4d.length == da4c.length + 1);
    }

    {
        assert(DAint([1, 2, 3]) < [4, 5, 6]);
        assert(DAint([1, 2, 3]) < [1, 2, 3, 4]);
        assert(DAint([1, 2, 3]) < [1, 2, 4]);
        assert(DAint([1, 2, 3]) > [1, 2]);
        assert(DAint([1, 2, 3]) > [1, 2, 1]);
        assert(DAint([1, 2, 3]) == [1, 2, 3]);

        assert(DAint([1, 2, 3]) < DAint([4, 5, 6]));
        assert(DAint([1, 2, 3]) < DAint([1, 2, 3, 4]));
        assert(DAint([1, 2, 3]) < DAint([1, 2, 4]));
        assert(DAint([1, 2, 3]) > DAint([1, 2]));
        assert(DAint([1, 2, 3]) > DAint([1, 2, 1]));
        assert(DAint([1, 2, 3]) == DAint([1, 2, 3]));
    }

    {
        int[] data = [4, 5, 6, 9, 22, 7, 13, 10000000];
        ptrdiff_t lastSeen = -1, seen;

        foreach (i, v; DAint(data)) {
            assert(lastSeen + 1 == i);
            assert(data[i] == v);

            lastSeen = i;
            seen++;
        }
        assert(seen == data.length);

        lastSeen = 8;
        seen = 0;
        foreach_reverse (i, v; DAint(data)) {
            assert(lastSeen - 1 == i);
            assert(data[i] == v);

            lastSeen = i;
            seen++;
        }
        assert(seen == data.length);

        seen = 0;
        foreach (v; DAint(data)) {
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

    bool copyOnWrite;

export @safe nothrow @nogc:

    void rcExternal(bool addRef) scope @trusted {
        import sidero.base.internal.atomic;

        if (addRef)
            atomicIncrementAndLoad(this.refCount, 1);
        else if (atomicDecrementAndLoad(this.refCount, 1) == 0) {
            sliceMemory.rcExternal(false);

            RCAllocator allocator = this.allocator;
            allocator.dispose(&this);
        }
    }

    void expand(size_t offset, size_t length, size_t newLength, bool adjustToNewSize = true) scope @trusted {
        if (newLength <= this.slice.length)
            return;
        else if (length == size_t.max)
            length = this.slice.length;

        const resultingLength = this.sliceMemory.expand!ElementType(offset, length, newLength, adjustToNewSize);
        this.slice = cast(ElementType[])(this.sliceMemory.original[0 .. resultingLength]);
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
