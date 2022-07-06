module sidero.base.text.unicode.readonly;
import sidero.base.text.unicode.defs;
import sidero.base.encoding.utf;
import sidero.base.allocators;
import sidero.base.errors;

///
alias String_UTF8 = String_UTF!char;
///
alias String_UTF16 = String_UTF!wchar;
///
alias String_UTF32 = String_UTF!dchar;

///
struct String_UTF(Char_) {
    package(sidero.base.text.unicode) {
        immutable(void)[] literal;
        UnicodeEncoding literalEncoding;
    }

    private {
        import sidero.base.internal.meta : OpApplyCombos;
        import core.atomic : atomicOp;

        LifeTime* lifeTime;
        Iterator* iterator;
    }

    ///
    alias Char = Char_;
    ///
    alias LiteralType = immutable(Char)[];

    // TODO: opApply

nothrow @nogc:

    /**
        Makes no guarantees that the string is actually null terminated. Unsafe!!!

        Will only return a pointer if the underlying memory is encoded approprietely.
     */
    const(Char)* ptr() @system {
        if (UnicodeEncoding.For!Char != literalEncoding)
            return null;
        else if (this.lifeTime !is null)
            return cast(const(Char)*)this.lifeTime.original.ptr;
        else
            return cast(const(Char)*)this.literal.ptr;
    }

    ///
    unittest {
        String_UTF text;
        assert(text.ptr is null);

        static if (is(Char == char)) {
            text = String_UTF("Me haz data!");
            assert(text.ptr !is null);
            text = String_UTF("Me haz data!"w);
            assert(text.ptr is null);
            text = String_UTF("Me haz data!"d);
            assert(text.ptr is null);
        } else static if (is(Char == wchar)) {
            text = String_UTF("Me haz data!"w);
            assert(text.ptr !is null);
            text = String_UTF("Me haz data!");
            assert(text.ptr is null);
            text = String_UTF("Me haz data!"d);
            assert(text.ptr is null);
        } else static if (is(Char == dchar)) {
            text = String_UTF("Me haz data!"d);
            assert(text.ptr !is null);
            text = String_UTF("Me haz data!");
            assert(text.ptr is null);
            text = String_UTF("Me haz data!"w);
            assert(text.ptr is null);
        }
    }

    ///
    String_UTF opSlice(size_t start, size_t end) scope @trusted {
        assert(start <= end, "Start of slice must be before or equal to end.");

        if (start == end)
            return String_UTF();

        String_UTF ret;

        ret.lifeTime = this.lifeTime;
        ret.literalEncoding = this.literalEncoding;
        if (ret.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        literalEncoding.handle(() {
            auto actual = cast(string)this.literal;
            assert(end <= actual.length, "End of slice must be before or equal to length.");
            ret.literal = actual[start .. end];
        }, () {
            auto actual = cast(wstring)this.literal;
            assert(end <= actual.length, "End of slice must be before or equal to length.");
            ret.literal = actual[start .. end];
        }, () {
            auto actual = cast(dstring)this.literal;
            assert(end <= actual.length, "End of slice must be before or equal to length.");
            ret.literal = actual[start .. end];
        });

        return *&ret;
    }

    ///
    unittest {
        static if (is(Char == char)) {
            String_UTF original = String_UTF("split me here");
            String_UTF split = original[6 .. 8];

            assert(split.length == 2);
            assert(split.ptr is original.ptr + 6);
        } else static if (is(Char == wchar)) {
            String_UTF original = String_UTF("split me here"w);
            String_UTF split = original[6 .. 8];

            assert(split.length == 2);
            assert(split.ptr is original.ptr + 6);
        } else static if (is(Char == dchar)) {
            String_UTF original = String_UTF("split me here"d);
            String_UTF split = original[6 .. 8];

            assert(split.length == 2);
            assert(split.ptr is original.ptr + 6);
        }
    }

    ///
    String_UTF withoutIterator() scope @trusted {
        String_UTF ret;
        ret.literal = this.literal;
        ret.literalEncoding = this.literalEncoding;
        ret.lifeTime = this.lifeTime;

        if (this.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        return ret;
    }

    ///
    unittest {
        String_UTF stuff = String_UTF("I have no iterator!");
        assert(stuff.tupleof == stuff.withoutIterator.tupleof);
    }

@safe:

    ///
    void opAssign(scope const(char)[] literal) scope @trusted {
        this = String_UTF(cast(string)literal);
    }

    ///
    unittest {
        String_UTF info;
        info = "abcd";
    }

    ///
    void opAssign(scope const(wchar)[] literal) scope @trusted {
        this = String_UTF(cast(wstring)literal);
    }

    ///
    unittest {
        String_UTF info;
        info = "abcd"w;
    }

    ///
    void opAssign(scope const(dchar)[] literal) scope @trusted {
        this = String_UTF(cast(dstring)literal);
    }

    ///
    unittest {
        String_UTF info;
        info = "abcd"d;
    }

    @disable void opAssign(scope const(char)[] other) scope const;
    @disable void opAssign(scope const(wchar)[] other) scope const;
    @disable void opAssign(scope const(dchar)[] other) scope const;

    ///
    this(ref return scope String_UTF other) @trusted scope {
        import core.atomic : atomicOp;

        this.tupleof = other.tupleof;

        if (haveIterator)
            this.iterator.rc(true);

        if (this.lifeTime !is null)
            atomicOp!"+="(this.lifeTime.refCount, 1);
    }

    ///
    unittest {
        String_UTF original = String_UTF("stuff here");
        String_UTF copied = original;
    }

    @disable this(ref return scope const String_UTF other) scope const;
    @disable this(this) scope;

    @trusted scope {
        this(scope return string literal, scope return RCAllocator allocator = RCAllocator.init, scope return string toDeallocate = null) {
            initForLiteral(literal, allocator, toDeallocate);
        }

        this(scope return wstring literal, scope return RCAllocator allocator = RCAllocator.init, scope return wstring toDeallocate = null) {
            initForLiteral(literal, allocator, toDeallocate);
        }

        this(scope return dstring literal, scope return RCAllocator allocator = RCAllocator.init, scope return dstring toDeallocate = null) {
            initForLiteral(literal, allocator, toDeallocate);
        }

        private void initForLiteral(T, U)(scope return T literal, scope return RCAllocator allocator, scope return U toDeallocate) {
            if (literal.length > 0 || (toDeallocate.length > 0 && !allocator.isNull)) {
                if (__ctfe && literal[$ - 1] != '\0') {
                    static T justDoIt(T input) {
                        return input ~ '\0';
                    }

                    literal = (cast(T function(T)@safe nothrow @nogc)&justDoIt)(literal);
                }

                this.literal = literal;
                this.literalEncoding = UnicodeEncoding.For!T;

                if (!allocator.isNull) {
                    if (toDeallocate is null)
                        toDeallocate = literal;

                    lifeTime = allocator.make!LifeTime(1, allocator, toDeallocate);
                    assert(this.lifeTime !is null);
                }
            }
        }

        ~this() {
            if (haveIterator)
                this.iterator.rc(false);

            if (this.lifeTime !is null && atomicOp!"-="(lifeTime.refCount, 1) == 0) {
                RCAllocator allocator = lifeTime.allocator;
                allocator.dispose(cast(void[])lifeTime.original);
                allocator.dispose(lifeTime);
            }
        }
    }

    ///
    bool isNull() scope {
        return this.literal is null || this.literal.length == 0;
    }

    ///
    unittest {
        String_UTF stuff;
        assert(stuff.isNull);

        stuff = "Abc";
        assert(!stuff.isNull);

        stuff = stuff[1 .. 1];
        assert(stuff.isNull);
    }

    ///
    bool haveIterator() scope {
        return this.iterator !is null;
    }

    ///
    unittest {
        String_UTF thing = String_UTF("bar");
        assert(!thing.haveIterator);

        version (none) {
            assert(!thing.empty);
            thing.popFront;

            assert(thing.haveIterator);
        }
    }

    /**
    Returns: if ``ptr`` will return a null terminated string or not
    */
    bool isPtrNullTerminated() scope @trusted {
        if (isNull)
            return false;

        return literalEncoding.handle(() {
            auto actual = cast(string)this.literal;

            if (actual[$ - 1] == '\0')
                return true;
            else if (this.lifeTime is null)
                return actual[$ - 1] == '\0';

            auto actualOriginal = cast(string)this.lifeTime.original;

            return actualOriginal[$ - 1] == '\0' && ((actualOriginal.ptr + actualOriginal.length) - (actual.length + 1)) is actual.ptr;
        }, () {
            auto actual = cast(wstring)this.literal;

            if (actual[$ - 1] == '\0')
                return true;
            else if (this.lifeTime is null)
                return actual[$ - 1] == '\0';

            auto actualOriginal = cast(wstring)this.lifeTime.original;

            return actualOriginal[$ - 1] == '\0' && ((actualOriginal.ptr + actualOriginal.length) - (actual.length + 1)) is actual.ptr;
        }, () {
            auto actual = cast(dstring)this.literal;

            if (actual[$ - 1] == '\0')
                return true;
            else if (this.lifeTime is null)
                return actual[$ - 1] == '\0';

            auto actualOriginal = cast(dstring)this.lifeTime.original;

            return actualOriginal[$ - 1] == '\0' && ((actualOriginal.ptr + actualOriginal.length) - (actual.length + 1)) is actual.ptr;
        });
    }

    ///
    unittest {
        static String_UTF global = String_UTF("oh yeah");
        assert(global.isPtrNullTerminated());

        String_UTF stack = String_UTF("hmm...");
        assert(!stack.isPtrNullTerminated());

        string someText = "oh noes";
        String_UTF someMoreStack = String_UTF(someText);
        assert(!someMoreStack.isPtrNullTerminated());
    }

    ///
    alias opDollar = length;

    /**
        The length of the string in its native encoding.

        Removes null terminator at the end if it has one.
     */
    size_t length() const scope nothrow @nogc {
        return literalEncoding.handle(() {
            auto actual = cast(string)this.literal;

            size_t ret = actual.length;
            if (ret > 0 && actual[$ - 1] == '\0')
                ret--;
            return ret;
        }, () {
            auto actual = cast(wstring)this.literal;

            size_t ret = actual.length;
            if (ret > 0 && actual[$ - 1] == '\0')
                ret--;
            return ret;
        }, () {
            auto actual = cast(dstring)this.literal;

            size_t ret = actual.length;
            if (ret > 0 && actual[$ - 1] == '\0')
                ret--;
            return ret;
        }, () { return size_t.init; });
    }

    ///
    unittest {
        static String_UTF global = String_UTF("oh yeah");
        assert(global.length == 7);
        assert(global.literal.length == 8);

        String_UTF stack = String_UTF("hmm...");
        assert(stack.length == 6);
        assert(stack.literal.length == 6);
    }

    version (none) {
        ///
        StringBuilder_ASCII asMutable(RCAllocator allocator = RCAllocator.init) scope {
            return StringBuilder_ASCII(allocator, literal);
        }

        ///
        unittest {
            StringBuilder_ASCII got = String_ASCII("stuff goes here, or there, wazzup").asMutable();
            assert(got.length == 33);
        }
    }

    ///
    String_UTF dup(RCAllocator allocator = RCAllocator.init) scope @trusted {
        if (isNull)
            return String_UTF();

        if (allocator.isNull) {
            if (lifeTime !is null)
                allocator = lifeTime.allocator;
            else
                allocator = globalAllocator();
        }

        size_t needsLength = literalEncoding.handle(() {
            auto actual = cast(string)this.literal[0 .. this.length];

            static if (is(Char == char))
                return actual.length;
            else static if (is(Char == wchar))
                return reEncodeLength(actual);
            else
                return decodeLength(actual);
        }, () {
            auto actual = (cast(wstring)this.literal)[0 .. this.length];

            static if (is(Char == char))
                return reEncodeLength(actual);
            else static if (is(Char == wchar))
                return actual.length;
            else
                return decodeLength(actual);
        }, () {
            auto actual = (cast(dstring)this.literal)[0 .. this.length];

            static if (is(Char == char))
                return encodeLengthUTF8(actual);
            else static if (is(Char == wchar))
                return encodeLengthUTF16(actual);
            else
                return actual.length;
        });

        // zero termination
        needsLength++;

        Char[] zliteral = allocator.makeArray!Char(needsLength);
        zliteral[$ - 1] = '\0';

        size_t soFar;
        literalEncoding.handle(() {
            auto actual = cast(string)this.literal[0 .. this.length];

            static if (is(Char == char))
                zliteral[0 .. $ - 1] = actual[];
            else static if (is(Char == wchar))
                reEncode(actual, (wchar got) { zliteral[soFar++] = got; });
            else
                decode(actual, (dchar got) { zliteral[soFar++] = got; });
        }, () {
            auto actual = (cast(wstring)this.literal)[0 .. this.length];

            static if (is(Char == char))
                reEncode(actual, (char got) { zliteral[soFar++] = got; });
            else static if (is(Char == wchar))
                zliteral[0 .. $ - 1] = actual[];
            else
                decode(actual, (dchar got) { zliteral[soFar++] = got; });
        }, () {
            auto actual = (cast(dstring)this.literal)[0 .. this.length];

            static if (is(Char == char))
                encodeUTF8(actual, (char got) { zliteral[soFar++] = got; });
            else static if (is(Char == wchar))
                encodeUTF16(actual, (wchar got) { zliteral[soFar++] = got; });
            else
                zliteral[0 .. $ - 1] = actual[];
        });

        return String_UTF(cast(LiteralType)zliteral, allocator, cast(LiteralType)zliteral);
    }

    ///
    @system unittest {
        LiteralType text = cast(LiteralType)"ok there goes nothin'\0";
        String_UTF original = String_UTF(text);
        String_UTF copy = original.dup;

        assert(copy.length == original.length);
        assert(copy.literal.length == original.literal.length);
        assert(original.ptr !is copy.ptr);
    }

    ///
    Result!Char opIndex(size_t index) const scope {
        if (this.length < index)
            return Result!Char(RangeException);

        return literalEncoding.handle(() {
            auto actual = cast(string)this.literal;

            static if (is(Char == char))
                return Result!Char(actual[index]);
            else
                return Result!Char(WrongUnicodeEncodingException);
        }, () {
            auto actual = cast(wstring)this.literal;

            static if (is(Char == wchar))
                return Result!Char(actual[index]);
            else
                return Result!Char(WrongUnicodeEncodingException);
        }, () {
            auto actual = cast(dstring)this.literal;

            static if (is(Char == dchar))
                return Result!Char(actual[index]);
            else
                return Result!Char(WrongUnicodeEncodingException);
        });
    }

    ///
    unittest {
        static LiteralType SomeText = cast(LiteralType)"lotsa text goes here ya?";
        String_UTF lotsaText = String_UTF(SomeText);

        foreach (i, c; SomeText) {
            auto got = lotsaText[i];
            assert(got, got.error.info.message);
            assert(got == c);
        }
    }

    @disable auto opCast(T)();

    version (none) {
        // TODO: string comparison

        // NFD(toCasefold(NFD(X))) = NFD(toCasefold(NFD(Y)))
        // toCasefold needs Language to be passed in
        // needs a way to refill, not just take buffer
    }

    version (none) {
        // TODO: ranges
    }

    version (none) {
        // TODO: startsWith/endsWith/indexOf/lastIndexOf/count/contains
    }

    version (none) {
        // TODO: strip
        // needs isWhitespace (easy)
    }

private:
    static struct LifeTime {
        shared(int) refCount;
        RCAllocator allocator;
        immutable(void)[] original;
    }

    static struct Iterator {
        shared(int) refCount;
        RCAllocator allocator;
        immutable(void)[] literal;

    scope @nogc nothrow:

        void rc(bool add) @trusted {
            import core.atomic : atomicOp;

            if (add)
                atomicOp!"+="(refCount, 1);
            else if (atomicOp!"-="(refCount, 1) == 0) {
                RCAllocator allocator2 = this.allocator;
                allocator2.dispose(&this);
            }
        }
    }

    void setupIterator() @trusted scope {
        if (isNull || haveIterator)
            return;

        RCAllocator allocator;

        if (lifeTime is null)
            allocator = globalAllocator();
        else
            allocator = lifeTime.allocator;

        this.iterator = allocator.make!Iterator(1, allocator);
        assert(this.iterator !is null);

        literalEncoding.handle(() {
            auto actual = cast(string)this.literal;

            if (actual.length > 0 && actual[$ - 1] == '\0')
                actual = actual[0 .. $ - 1];

            this.iterator.literal = actual;
        }, () {
            auto actual = cast(wstring)this.literal;

            if (actual.length > 0 && actual[$ - 1] == '\0')
                actual = actual[0 .. $ - 1];

            this.iterator.literal = actual;
        }, () {
            auto actual = cast(dstring)this.literal;

            if (actual.length > 0 && actual[$ - 1] == '\0')
                actual = actual[0 .. $ - 1];

            this.iterator.literal = actual;
        });
    }
}
