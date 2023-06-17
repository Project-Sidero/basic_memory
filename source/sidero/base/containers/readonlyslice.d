///
module sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.allocators;
import sidero.base.text;
import sidero.base.text.format;
import sidero.base.errors;
import sidero.base.attributes;

export:

private alias SliceI = Slice!int;

///
struct Slice(Type) {
    package(sidero.base.containers) @PrettyPrintIgnore LiteralType literal;

    private @PrettyPrintIgnore {
        import sidero.base.internal.meta : OpApplyCombos;
        import core.atomic : atomicOp;

        LifeTime* lifeTime;
        Iterator* iterator;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            bool deallocateAllocator;

            if (isNull)
                return 0;

            Iterator* oldIterator = this.iterator;

            this.iterator = null;
            setupIterator;

            if (oldIterator !is null)
                this.iterator.literal = oldIterator.literal;

            scope (exit) {
                this.iterator.rc(false);
                this.iterator = oldIterator;
            }

            size_t offset;
            int result;

            while (!empty) {
                Result!Type temp = front();
                if (!temp)
                    return result;

                Type got = temp;

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

            Iterator* oldIterator = this.iterator;

            this.iterator = null;
            setupIterator;

            if (oldIterator !is null)
                this.iterator.literal = oldIterator.literal;

            scope (exit) {
                this.iterator.rc(false);
                this.iterator = oldIterator;
            }

            size_t offset = this.length - 1;
            int result;

            while (!empty) {
                Result!Type temp = back();
                if (!temp)
                    return result;

                Type got = temp;

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
    alias ElementType = Type;
    ///
    alias LiteralType = const(Type)[];

    ///
    mixin OpApplyCombos!("ElementType", "size_t", ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        static Literal = [ElementType.init];
        Slice literal = Slice(Literal);

        size_t lastIndex;

        foreach (c; literal) {
            assert(Literal[lastIndex] == c);
            lastIndex++;
        }

        assert(lastIndex == Literal.length);
    }

    ///
    mixin OpApplyCombos!("ElementType", "size_t", ["@safe", "nothrow", "@nogc"], "opApplyReverse");

    ///
    unittest {
        static Literal = [ElementType.init];
        Slice literal = Slice(Literal);

        size_t lastIndex = Literal.length;

        foreach_reverse (c; literal) {
            lastIndex--;
            assert(Literal[lastIndex] == c);
        }

        assert(lastIndex == 0);
    }

nothrow @nogc:
    const(ElementType)* ptr() @system {
        if (this.lifeTime !is null)
            return this.lifeTime.original.ptr;
        else
            return this.literal.ptr;
    }

    ///
    const(ElementType)[] unsafeGetLiteral() @system {
        return this.literal;
    }

    ///
    Slice opSlice() scope @trusted {
        if (isNull)
            return Slice();

        Slice ret;

        ret.lifeTime = this.lifeTime;
        if (ret.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        ret.literal = this.literal;
        ret.setupIterator();
        return ret;
    }

    ///
    Result!Slice opSlice(ptrdiff_t startIndex, ptrdiff_t endIndex) scope @trusted {
        ErrorInfo errorInfo = changeIndexToOffset(startIndex, endIndex);
        if (errorInfo.isSet)
            return typeof(return)(errorInfo);
        if (startIndex == endIndex)
            return Result!Slice();

        Slice ret;

        ret.lifeTime = this.lifeTime;
        if (ret.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        ret.literal = this.literal[startIndex .. endIndex];
        return Result!Slice(ret);
    }

    ///
    Slice withoutIterator() scope @trusted {
        Slice ret;
        ret.literal = this.literal;
        ret.lifeTime = this.lifeTime;

        if (this.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        return ret;
    }

    ///
    unittest {
        static Literal = [ElementType.init];
        Slice stuff = Slice(Literal);
        assert(stuff == stuff.withoutIterator);
    }

@safe:

    ///
    void opAssign(scope LiteralType literal) scope @trusted {
        this = Slice(literal);
    }

    ///
    unittest {
        Slice info;
        info = [ElementType.init];
    }

    @disable void opAssign(scope LiteralType other) scope const;

    ///
    this(return scope ref Slice other) scope @trusted {
        this.tupleof = other.tupleof;

        if (haveIterator)
            this.iterator.rc(true);
        if (this.lifeTime !is null)
            atomicOp!"+="(this.lifeTime.refCount, 1);
    }

    ///
    unittest {
        static Literal = [ElementType.init];
        Slice original = Slice(Literal);
        Slice copied = original;
    }

    @disable this(ref return scope const Slice other) scope const;

    @trusted {
        ///
        this(return scope LiteralType literal, return scope RCAllocator allocator = RCAllocator.init,
                return scope LiteralType toDeallocate = null) scope {
            if (literal.length > 0 || (toDeallocate.length > 0 && !allocator.isNull)) {
                this.literal = literal;

                if (!allocator.isNull) {
                    if (toDeallocate is null)
                        toDeallocate = literal;

                    lifeTime = allocator.make!LifeTime(1, allocator, toDeallocate);
                    assert(this.lifeTime !is null);
                }
            }
        }

        ///
        unittest {
            static Literal = [ElementType.init];
            Slice foobar = Slice(Literal);
        }

        @disable this(return scope LiteralType literal, return scope RCAllocator allocator = RCAllocator.init,
                return scope LiteralType toDeallocate = null) scope const;
    }

    ~this() scope @trusted {
        if (haveIterator)
            this.iterator.rc(false);

        if (this.lifeTime !is null && atomicOp!"-="(lifeTime.refCount, 1) == 0) {
            RCAllocator allocator = lifeTime.allocator;
            allocator.dispose(cast(void[])lifeTime.original);
            allocator.dispose(lifeTime);
        }
    }

    ///
    bool isNull() scope const {
        return this.literal is null || this.literal.length == 0;
    }

    ///
    @trusted unittest {
        Slice stuff;
        assert(stuff.isNull);

        stuff = [ElementType.init];
        assert(!stuff.isNull);

        stuff = stuff[1 .. 1].assumeOkay;
        assert(stuff.isNull);
    }

    ///
    bool haveIterator() scope {
        return this.iterator !is null;
    }

    ///
    unittest {
        static Literal = [ElementType.init];
        Slice thing = Slice(Literal);
        assert(!thing.haveIterator);

        assert(!thing.empty);
        thing.popFront;

        assert(thing.haveIterator);
    }

    ///
    alias opDollar = length;

    ///
    size_t length() const scope nothrow @nogc {
        return this.literal.length;
    }

    ///
    unittest {
        static Slice global = Slice([ElementType.init]);
        assert(global.length == 1);
        assert(global.literal.length == 1);
    }

    ///
    Slice dup(RCAllocator allocator = RCAllocator.init) scope @trusted {
        if (isNull)
            return Slice();

        if (allocator.isNull) {
            allocator = globalAllocator();
        }

        LiteralType literal = allocator.makeArray!ElementType(this.literal);
        return Slice(literal, allocator, literal);
    }

    ///
    @system unittest {
        static Slice original = Slice([ElementType.init]);
        Slice copy = original.dup;

        assert(copy.length == original.length);
        assert(copy.literal.length == original.literal.length);
        assert(original.ptr !is copy.ptr);
    }

    ///
    DynamicArray!ElementType asMutable(RCAllocator allocator = RCAllocator.init) scope {
        return DynamicArray!ElementType(this, allocator);
    }

    ///
    unittest {
        static Literal = [ElementType.init];
        DynamicArray!ElementType got = Slice(Literal).asMutable();
        assert(got.length == Literal.length);
    }

    ///
    Result!Type opIndex(ptrdiff_t index) scope @trusted {
        ErrorInfo errorInfo = changeIndexToOffset(index);
        if (errorInfo.isSet)
            return typeof(return)(errorInfo);

        return Result!Type(*cast(Type*)&this.literal[index]);
    }

    @disable auto opCast(Type)();

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope DynamicArray!Type other) scope const {
        return opCmp(other) == 0;
    }

    ///
    bool opEquals(scope Slice!Type other) scope const {
        return opCmp(other) == 0;
    }

    ///
    bool opEquals(scope LiteralType other) scope const {
        return opCmp(other) == 0;
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope DynamicArray!Type other) scope @trusted const {
        return opCmp(other.unsafeGetLiteral);
    }

    ///
    int opCmp(scope Slice!Type other) scope @trusted const {
        return opCmp(other.unsafeGetLiteral);
    }

    ///
    int opCmp(scope LiteralType other) scope const @trusted {
        import sidero.base.containers.utils;

        LiteralType us = this.literal;
        return genericCompare(us, other);
    }

    ///
    ulong toHash() scope const {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();

        foreach (ref v; this.literal) {
            ret = hashOf(v);
        }

        return ret;
    }

    @property {
        ///
        bool empty() scope {
            return (haveIterator && this.iterator.literal.length == 0) || this.literal.length == 0;
        }

        ///
        Result!ElementType front() scope @trusted {
            assert(!isNull);
            setupIterator;

            if (empty)
                return typeof(return)(RangeException);

            return typeof(return)(*cast(ElementType*)&this.iterator.literal[0]);
        }

        ///
        Result!ElementType back() scope @trusted {
            assert(!isNull);
            setupIterator;

            if (empty)
                return typeof(return)(RangeException);

            return typeof(return)(*cast(ElementType*)&this.iterator.literal[$ - 1]);
        }
    }

    /// See_Also: front
    void popFront() scope {
        assert(!empty);
        setupIterator;

        this.iterator.literal = this.iterator.literal[1 .. $];
    }

    /// See_Also: back
    void popBack() scope {
        assert(!empty);
        setupIterator;

        this.iterator.literal = this.iterator.literal[0 .. $ - 1];
    }

    ///
    bool startsWith(scope DynamicArray!Type other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope Slice!Type other) scope @trusted {
        return startsWith(other.unsafeGetLiteral);
    }

    ///
    bool startsWith(scope LiteralType other...) scope @trusted {
        LiteralType us = this.literal;

        if (other.length == 0 || other.length == 0 || other.length > us.length)
            return false;
        return cast(Type[])us[0 .. other.length] == cast(Type[])other;
    }

    ///
    bool endsWith(scope DynamicArray!Type other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope Slice!Type other) scope @trusted {
        return endsWith(other.unsafeGetLiteral);
    }

    ///
    bool endsWith(scope LiteralType other...) scope @trusted {
        LiteralType us = this.literal;

        if (us.length == 0 || other.length == 0 || us.length < other.length)
            return false;
        return cast(Type[])us[$ - other.length .. $] == cast(Type[])other;
    }

    ///
    ptrdiff_t indexOf(scope DynamicArray!Type other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope Slice!Type other) scope @trusted {
        return indexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t indexOf(scope LiteralType other...) scope @trusted {
        LiteralType us = this.literal;

        if (other.length > us.length)
            return -1;

        foreach (i; 0 .. (us.length + 1) - other.length) {
            if (cast(Type[])us[i .. i + other.length] == cast(Type[])other)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t lastIndexOf(scope DynamicArray!Type other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope Slice!Type other) scope @trusted {
        return lastIndexOf(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t lastIndexOf(scope LiteralType other...) scope @trusted {
        LiteralType us = this.literal;

        if (other.length > us.length)
            return -1;

        foreach_reverse (i; 0 .. (us.length + 1) - other.length) {
            if (cast(Type[])us[i .. i + other.length] == cast(Type[])other)
                return i;
        }

        return -1;
    }

    ///
    ptrdiff_t count(scope DynamicArray!Type other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    ptrdiff_t count(scope Slice!Type other) scope @trusted {
        return count(other.unsafeGetLiteral);
    }

    ///
    size_t count(scope LiteralType other...) scope @trusted {
        LiteralType us = this.literal;

        if (other.length > us.length)
            return 0;

        size_t got;

        while (us.length >= other.length) {
            if (cast(Type[])us[0 .. other.length] == cast(Type[])other) {
                got++;
                us = us[other.length .. $];
            } else
                us = us[1 .. $];
        }

        return got;
    }

    ///
    bool contains(scope DynamicArray!Type other) scope {
        if (other.isNull)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    bool contains(scope Slice!Type other) scope {
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

    @PrintIgnore @PrettyPrintIgnore {
        ///
        String_UTF8 toString(RCAllocator allocator = globalAllocator()) @trusted {
            StringBuilder_UTF8 ret = StringBuilder_UTF8(allocator);
            toString(ret);
            return ret.asReadOnly;
        }

        ///
        void toString(Sink)(scope ref Sink sink) @trusted {
            sink.formattedWrite("", this.unsafeGetLiteral);
        }

        ///
        String_UTF8 toStringPretty(RCAllocator allocator = globalAllocator()) @trusted {
            StringBuilder_UTF8 ret = StringBuilder_UTF8(allocator);
            this.toStringPretty(ret);
            return ret.asReadOnly;
        }

        ///
        void toStringPretty(Sink)(scope ref Sink sink) {
            PrettyPrint prettyPrint;
            prettyPrint(sink, cast(Slice)this);
        }
    }

private:
    static struct LifeTime {
        shared(ptrdiff_t) refCount;
        RCAllocator allocator;
        LiteralType original;

        @disable bool opEquals(ref const LifeTime other) const;
    }

    static struct Iterator {
        shared(ptrdiff_t) refCount;
        RCAllocator allocator;
        LiteralType literal;

    export scope @nogc nothrow:

        void rc(bool add) @trusted {
            if (add)
                atomicOp!"+="(refCount, 1);
            else if (atomicOp!"-="(refCount, 1) == 0) {
                RCAllocator allocator2 = this.allocator;
                allocator2.dispose(&this);
            }

        }
        @disable bool opEquals(ref const Iterator other) const;
    }

    void setupIterator() @trusted scope {
        if (isNull || haveIterator)
            return;

        RCAllocator allocator;

        if (lifeTime is null)
            allocator = globalAllocator();
        else
            allocator = lifeTime.allocator;

        this.iterator = allocator.make!Iterator(1, allocator, this.literal);
        assert(this.iterator !is null);
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a) scope {
        size_t actualLength = literal.length;

        if (a < 0) {
            if (actualLength < -a)
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            a = actualLength + a;
        }

        return ErrorInfo.init;
    }

    ErrorInfo changeIndexToOffset(ref ptrdiff_t a, ref ptrdiff_t b) scope {
        size_t actualLength = literal.length;

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

unittest {
    SliceI slice = SliceI([1, 2, 3, 4, 5]);
    assert(slice.toString() == "[1, 2, 3, 4, 5]");
}
