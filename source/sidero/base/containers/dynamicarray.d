module sidero.base.containers.dynamicarray;
import sidero.base.containers.readonlyslice;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.text;

export:

private {
    alias DAint = DynamicArray!int;
}

/// Not thread safe dynamic array ElementType
struct DynamicArray(Type) {
    private {
        import sidero.base.internal.meta : OpApplyCombos;
        import core.atomic : atomicOp;

        struct State {
            ElementType[] slice;
            size_t amountUsed;
            RCAllocator allocator;
            shared(int) refCount;
            bool copyOnWrite;

            invariant {
                assert(!allocator.isNull);
            }
        }

        State* state;
        size_t minimumOffset, maximumOffset = size_t.max;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            size_t offset;
            int result;

            while (!empty) {
                Result!ElementType temp = front();
                if (!temp)
                    return result;

                ElementType got = temp;

                static if (__traits(compiles, del(offset, got)))
                    result = del(offset, got);
                else static if (__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if (result)
                    return result;

                offset++;
                popFront();
            }

            return result;
        }

        int opApplyReverseImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            size_t offset = this.length - 1;
            int result;

            while (!empty) {
                Result!ElementType temp = back();
                if (!temp)
                    return result;

                ElementType got = temp;

                static if (__traits(compiles, del(offset, got)))
                    result = del(offset, got);
                else static if (__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if (result)
                    return result;

                offset--;
                popBack();
            }

            return result;
        }
    }
export:

    ///
    mixin OpApplyCombos!("ElementType", "size_t", ["@safe", "nothrow", "@nogc"]);
    ///
    mixin OpApplyCombos!("ElementType", "size_t", ["@safe", "nothrow", "@nogc"], "opApplyReverse");

    ///
    alias ElementType = Type;
    ///
    alias LiteralType = const(ElementType)[];

    /// UNSAFE
    ElementType* ptr() @system nothrow @nogc {
        if (state is null)
            return null;
        return &state.slice[minimumOffset];
    }

    ///
    ElementType[] unsafeGetLiteral() @system nothrow return @nogc {
        if (state is null)
            return null;
        else if (maximumOffset == size_t.max)
            return this.state.slice[minimumOffset .. state.amountUsed];
        else
            return this.state.slice[minimumOffset .. maximumOffset];
    }

scope nothrow @nogc:

    @trusted {
        ///
        this(RCAllocator allocator) {
            this(0, allocator);
        }

        @disable this(RCAllocator allocator) const;

        ///
        this(scope Slice!ElementType initial, RCAllocator allocator = RCAllocator.init) {
            this(initial.unsafeGetLiteral, allocator);
        }

        ///
        this(scope const(ElementType)[] initial, RCAllocator allocator = RCAllocator.init) {
            this(initial.length, allocator);

            if (!isNull)
                this = initial;
        }

        @disable this(scope ElementType[] initial, RCAllocator allocator) const;

        ///
        this(size_t initialSize, RCAllocator allocator = RCAllocator.init) {
            if (allocator.isNull)
                allocator = globalAllocator();

            ElementType[] slice = initialSize > 0 ? allocator.makeArray!ElementType(initialSize) : null;
            this.state = allocator.make!State(slice, initialSize, allocator, 1);

            assert(this.state !is null);
            assert(!this.state.allocator.isNull);
            assert(this.state.slice.length == initialSize);
        }

        @disable this(size_t initialSize, RCAllocator allocator) const;

        this(ref DynamicArray other) {
            assert(other.state is null || !other.state.allocator.isNull);

            this.tupleof = other.tupleof;
            if (this.state !is null)
                atomicOp!"+="(state.refCount, 1);
        }

        @disable this(scope return ref const DynamicArray other) const;

        ~this() {
            if (state !is null && atomicOp!"-="(state.refCount, 1) == 0) {
                RCAllocator allocator = state.allocator;
                assert(!allocator.isNull);

                if (state.slice !is null)
                    allocator.dispose(this.state.slice);
                assert(!allocator.isNull);
                allocator.dispose(this.state);
                assert(!allocator.isNull);
                this.state = null;
            }
        }
    }

@safe:

    invariant {
        if (this.state !is null) {
            assert(!this.state.allocator.isNull);
        }
    }

    void opAssign(scope DynamicArray other) {
        this.__xdtor;
        this.tupleof = other.tupleof;
        other.state = null;
    }

    ///
    void opAssign(scope ElementType input) @trusted {
        foreach (ref v; this.unsafeGetLiteral)
            v = input;
    }

    ///
    void opAssign(scope const(ElementType)[] input...) @trusted {
        checkInit;

        if (this.length < input.length)
            length = input.length;

        auto original = this.unsafeGetLiteral();
        auto slice = original[0 .. input.length];

        foreach (i, ref v; slice[])
            v = input[i];
    }

    //@disable void opAssign(ref DynamicArray other) const;
    //@disable void opAssign(DynamicArray other) const;

    @disable auto opCast(T)();

    ///
    bool isNull() {
        return state is null;
    }

    /// The true length of the underlying storage
    size_t capacity() {
        return state !is null ? state.slice.length : 0;
    }

    /// Ensure amount of entries are available to expand into
    void reserve(size_t amount) @trusted {
        checkInit;
        RCAllocator allocator = this.state.allocator;
        size_t newLength = maximumOffset != size_t.max ? maximumOffset + amount : state.amountUsed + amount;

        if (state.slice.length == 0) {
            this.state = allocator.make!State(allocator.makeArray!ElementType(newLength), 0, allocator, 1);
            assert(this.state !is null);
            assert(this.state.slice.length == newLength);

            this.minimumOffset = 0;
            this.maximumOffset = size_t.max;
        } else if (newLength <= this.state.slice.length) {
            return;
        } else {
            DynamicArray old = this;

            if (!allocator.expandArray(state.slice, amount)) {
                newLength = old.maximumOffset != size_t.max ? old.maximumOffset : old.state.amountUsed;
                if (newLength >= old.minimumOffset)
                    newLength -= old.minimumOffset;
                else
                    newLength = 0;

                this.state = allocator.make!State(allocator.makeArray!ElementType(newLength + amount), newLength, allocator, 1);
                assert(this.state !is null);
                assert(this.state.slice.length == newLength + amount);

                this.minimumOffset = 0;
                this.maximumOffset = newLength;

                assert(old.state.slice.length >= old.minimumOffset + newLength);
                this = old.state.slice[old.minimumOffset .. old.minimumOffset + newLength];
            }
        }
    }

    ///
    alias opDollar = length;

    ///
    size_t length() {
        if (state is null)
            return 0;
        else if (maximumOffset == size_t.max)
            return this.state.amountUsed - minimumOffset;
        else
            return maximumOffset - minimumOffset;
    }

    ///
    void length(size_t newLength) @trusted {
        checkInit;
        RCAllocator allocator = this.state.allocator;

        newLength += this.minimumOffset;

        if (this.length == newLength)
            return;
        else if (state.slice.length == 0) {
            this.state = allocator.make!State(allocator.makeArray!ElementType(newLength), newLength, allocator, 1);
            assert(this.state !is null);
            assert(this.state.slice.length == newLength);

            this.minimumOffset = 0;
            this.maximumOffset = size_t.max;
        } else if (newLength <= this.state.slice.length - minimumOffset && (maximumOffset == size_t.max ||
                maximumOffset == this.state.amountUsed)) {
            this.state.amountUsed = minimumOffset + newLength;
            if (maximumOffset < size_t.max)
                maximumOffset = this.state.amountUsed;
        } else {
            size_t amount = newLength - state.slice.length;
            if ((this.maximumOffset == size_t.max || this.maximumOffset == state.amountUsed) && allocator.expandArray(state.slice, amount)) {
                state.amountUsed += amount;
                if (this.maximumOffset != size_t.max)
                    this.maximumOffset = newLength;
            } else {
                DynamicArray old = this;

                this.state = allocator.make!State(allocator.makeArray!ElementType(newLength), newLength, allocator, 1);
                assert(this.state !is null);
                assert(this.state.slice.length == newLength);

                if (old.maximumOffset != size_t.max)
                    this.maximumOffset = newLength;

                this = old.state.slice[0 .. old.state.amountUsed];
            }
        }
    }

    ///
    Result!ElementType opIndex(ptrdiff_t index) {
        ErrorInfo errorInfo = changeIndexToOffset(index);
        if (errorInfo.isSet)
            return typeof(return)(errorInfo);

        return Result!ElementType(this.state.slice[minimumOffset + index]);
    }

    ///
    ErrorResult opIndexAssign(ElementType value, ptrdiff_t index) {
        ErrorInfo errorInfo = changeIndexToOffset(index);
        if (errorInfo.isSet)
            return typeof(return)(errorInfo);

        this.state.slice[minimumOffset + index] = value;
        return ErrorResult();
    }

    ///
    DynamicArray opSlice() return {
        return this;
    }

    ///
    Result!DynamicArray opSlice(ptrdiff_t startIndex, ptrdiff_t endIndex) return @trusted {
        if (isNull)
            return Result!DynamicArray();

        ErrorInfo errorInfo = changeIndexToOffset(startIndex, endIndex);
        if (errorInfo.isSet)
            return typeof(return)(errorInfo);

        DynamicArray ret = this;
        ret.minimumOffset = startIndex;
        ret.maximumOffset = endIndex;
        return Result!DynamicArray(ret);
    }

    @property {
        ///
        bool empty() {
            return this.length == 0;
        }

        ///
        Result!ElementType front() {
            return this[0];
        }

        ///
        Result!ElementType back() {
            return this[$ - 1];
        }

        ///
        void popFront() {
            if (state is null)
                return;

            this.minimumOffset++;
        }

        ///
        void popBack() {
            if (state is null)
                return;

            if (this.maximumOffset == size_t.max)
                this.maximumOffset = state.amountUsed;
            this.maximumOffset--;
        }

        ///
        void put(scope ElementType value) {
            opOpAssign!"~"(value);
        }

        ///
        void put(scope Slice!ElementType values) @trusted {
            opOpAssign!"~"(values.unsafeGetLiteral);
        }

        ///
        void put(scope const(ElementType)[] values) {
            opOpAssign!"~"(values);
        }

        ///
        void put(scope DynamicArray values) {
            opOpAssign!"~"(values);
        }
    }

    ///
    void opOpAssign(string op : "~")(scope ElementType value) @trusted {
        checkInit;
        bool expand;

        if (maximumOffset != size_t.max)
            expand = state.amountUsed != maximumOffset || state.amountUsed + 1 > state.slice.length;
        else
            expand = state.amountUsed == state.slice.length;

        if (expand) {
            reserve(8);
        }

        assert(state.amountUsed < state.slice.length);
        this.state.slice[state.amountUsed++] = value;

        if (this.maximumOffset != size_t.max)
            this.maximumOffset++;
    }

    ///
    void opOpAssign(string op : "~")(scope DynamicArray values) @trusted {
        opOpAssign!"~"(values.unsafeGetLiteral);
    }

    ///
    void opOpAssign(string op : "~")(scope Slice!ElementType values) @trusted {
        this.opOpAssign!"~"(values.unsafeGetLiteral);
    }

    ///
    void opOpAssign(string op : "~")(scope const(ElementType)[] values) {
        if (values.length == 0)
            return;

        checkInit;
        bool expand;

        if (maximumOffset != size_t.max)
            expand = state.amountUsed != maximumOffset || state.amountUsed + values.length > state.slice.length;
        else
            expand = state.amountUsed + values.length > state.slice.length;

        if (expand) {
            reserve(values.length + 8);
        }

        assert(state.amountUsed + values.length <= state.slice.length);
        foreach (i, ref v; this.state.slice[state.amountUsed .. state.amountUsed + values.length])
            v = values[i];
        state.amountUsed += values.length;

        if (this.maximumOffset != size_t.max)
            this.maximumOffset += values.length;
    }

    ///
    DynamicArray opBinary(string op : "~")(scope Slice!ElementType other) @trusted {
        return opBinary!"~"(other.unsafeGetLiteral);
    }

    ///
    DynamicArray opBinary(string op : "~")(scope const(ElementType)[] other) {
        if (isNull && other.isNull)
            return DynamicArray();
        else if (isNull) {
            return other.dup;
        } else if (other.isNull) {
            return this.dup;
        }

        DynamicArray ret = DynamicArray(0, state.allocator);
        ret.reserve(this.length + other.length);

        ret ~= this;
        ret ~= other;
        return ret;
    }

    ///
    DynamicArray opBinary(string op : "~")(DynamicArray other) @trusted {
        if (isNull && other.isNull)
            return DynamicArray();
        else if (isNull) {
            return other.dup;
        } else if (other.isNull) {
            return this.dup;
        }

        DynamicArray ret = DynamicArray(0, state.allocator);
        ret.reserve(this.length + other.length);

        ret ~= this;
        ret ~= other;
        return ret;
    }

    ///
    DynamicArray dup(RCAllocator allocator = RCAllocator()) @trusted {
        if (isNull)
            return DynamicArray();
        else if (allocator.isNull)
            allocator = globalAllocator();

        return DynamicArray(this.unsafeGetLiteral(), allocator);
    }

    ///
    Slice!ElementType asReadOnly(RCAllocator allocator = RCAllocator.init) @trusted {
        if (isNull)
            return Slice!ElementType();
        else if (allocator.isNull)
            allocator = globalAllocator();

        return Slice!ElementType(allocator.makeArray!ElementType(this.unsafeGetLiteral), allocator);
    }

    ///
    @PrintIgnore String_UTF8 toString(RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_UTF8 ret = StringBuilder_UTF8(allocator);
        toString(ret);
        return ret.asReadOnly;
    }

    ///
    @PrintIgnore void toString(Sink)(scope ref Sink sink) @trusted {
        sink.formattedWrite(String_ASCII.init, this.unsafeGetLiteral());
    }

    ///
    @PrettyPrintIgnore String_UTF8 toStringPretty(RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_UTF8 ret = StringBuilder_UTF8(allocator);
        toString(ret);
        return ret.asReadOnly;
    }

    ///
    @PrettyPrintIgnore void toStringPretty(Sink)(scope ref Sink sink) @trusted {
        PrettyPrint!String_ASCII prettyPrint;
        prettyPrint(sink, this.unsafeGetLiteral());
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope Slice!ElementType other) @trusted scope {
        return this.opCmp(other.unsafeGetLiteral);
    }

    ///
    int opCmp(scope const(ElementType)[] other) @trusted scope {
        import sidero.base.containers.utils : genericCompare;
        auto us = unsafeGetLiteral();
        return genericCompare(us, other);
    }

    ///
    int opCmp(scope DynamicArray other) @trusted scope {
        return opCmp(other.unsafeGetLiteral());
    }

    ///
    bool opEquals(scope Slice!ElementType other) scope {
        return opCmp(other) == 0;
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope const(ElementType)[] other) scope {
        return opCmp(other) == 0;
    }

    ///
    bool opEquals(scope DynamicArray other) scope {
        return opCmp(other) == 0;
    }

    ///
    ulong toHash() @trusted scope {
        import sidero.base.hash.utils : hashOf;

        scope temp = this.unsafeGetLiteral();
        return hashOf(temp);
    }

    ///
    bool startsWith(scope DynamicArray!ElementType other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope Slice!ElementType other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope LiteralType other...) scope @trusted {
        LiteralType us = unsafeGetLiteral();

        if (other.length == 0 || other.length == 0 || other.length > us.length)
            return false;
        return us[0 .. other.length] == other;
    }

    ///
    bool endsWith(scope DynamicArray!ElementType other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope Slice!ElementType other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope LiteralType other...) scope @trusted {
        LiteralType us = unsafeGetLiteral();

        if (us.length == 0 || other.length == 0 || us.length < other.length)
            return false;
        return us[$ - other.length .. $] == other;
    }

    ///
    ptrdiff_t indexOf(scope DynamicArray!ElementType other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope Slice!ElementType other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope LiteralType other...) scope @trusted {
        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return -1;

        foreach (i; 0 .. (us.length + 1) - other.length) {
            if (us[i .. i + other.length] == other)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t lastIndexOf(scope DynamicArray!ElementType other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope Slice!ElementType other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope LiteralType other...) scope @trusted {
        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return -1;

        foreach_reverse (i; 0 .. (us.length + 1) - other.length) {
            if (us[i .. i + other.length] == other)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t count(scope DynamicArray!ElementType other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t count(scope Slice!ElementType other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    size_t count(scope LiteralType other...) scope @trusted {
        LiteralType us = unsafeGetLiteral();

        if (other.length > us.length)
            return 0;

        size_t got;

        while (us.length >= other.length) {
            if (us[0 .. other.length] == other) {
                got++;
                us = us[other.length .. $];
            } else
                us = us[1 .. $];
        }

        return got;
    }

    ///
    bool contains(scope DynamicArray!ElementType other) scope {
        if (other.isNull)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    bool contains(scope Slice!ElementType other) scope {
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

    ///
    void copyOnWrite() {
        if (state !is null)
            state.copyOnWrite = true;
    }

private:
    void checkInit() @trusted {
        if (!isNull) {
            if (state.copyOnWrite)
                this = this.dup;
            return;
        }

        RCAllocator allocator = globalAllocator();

        this.state = allocator.make!State(null, 0, allocator, 1);
        assert(this.state !is null);
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a) scope @trusted {
        size_t actualLength = this.unsafeGetLiteral().length;

        if (a < 0) {
            if (actualLength < -a)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength + a;
        }

        return ErrorInfo.init;
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a, ref ptrdiff_t b) scope @trusted {
        size_t actualLength = this.unsafeGetLiteral().length;

        if (a < 0) {
            if (actualLength < -a)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength + a;
        }

        if (b < 0) {
            if (actualLength < -b)
                return ErrorInfo(RangeException("Second offset must be smaller than length"));
            b = actualLength + b;
        }

        if (b < a) {
            ptrdiff_t temp = a;
            a = b;
            b = temp;
        }

        return ErrorInfo.init;
    }
}

///
unittest {
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
        assert(da1.toString() == "[1, 2, 3, 4, 5]");

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
        assert(aValue, aValue.error.toString().unsafeGetLiteral);
        assert(aValue == 6);
        aValue = da2[-2];
        assert(aValue, aValue.error.toString().unsafeGetLiteral);
        assert(aValue == 9);
        aValue = da2[$ - 2];
        assert(aValue, aValue.error.toString().unsafeGetLiteral);
        assert(aValue == 9);

        Result!DA da2slice = da2[1 .. -1];
        assert(da2slice, da2slice.error.toString().unsafeGetLiteral);
        assert(da2slice.length == 2);
        assert(da2slice.assumeOkay == [6, 9]);

        aValue = da2slice[0];
        assert(aValue, aValue.error.toString().unsafeGetLiteral);
        assert(aValue == 6);
        aValue = da2slice[-1];
        assert(aValue, aValue.error.toString().unsafeGetLiteral);
        assert(aValue == 9);
        aValue = da2slice[$ - 1];
        assert(aValue, aValue.error.toString().unsafeGetLiteral);
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
        assert(da3slice, da3slice.error.toString().unsafeGetLiteral);
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

        assert(da4a.capacity == 10);
        assert(da4b.capacity == 10);
        assert(da4c.capacity == 20);
        assert(da4c == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19]);

        Result!DAint da4cslice = da4c[-1 .. -2];
        assert(da4cslice);
        assert(da4cslice.length == 1);
        assert(da4cslice.assumeOkay == [18]);

        assert(da4c[-4 .. -2].assumeOkay == [16, 17]);

        da4cslice ~= 42;
        assert(da4cslice.length == 2);
        assert(da4c.length == 21);

        da4c ~= 64;
        assert(da4c[$ - 1].assumeOkay == 64);
        assert(da4c.length == 22);

        da4c ~= [72, 74];
        assert(da4c[-2 .. $].assumeOkay == [72, 74]);
        assert(da4c.length == 24);

        da4c ~= [53, 52, 85, 41, 12, 12, 12, 7, 0, 1];
        assert(da4c.length == 34);

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
