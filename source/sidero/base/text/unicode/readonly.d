module sidero.base.text.unicode.readonly;
import sidero.base.text.unicode.defs;
import sidero.base.text.unicode.characters.database;
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
        const(void)[] literal;
        UnicodeEncoding literalEncoding;
    }

    private {
        import sidero.base.internal.meta : OpApplyCombos;
        import core.atomic : atomicOp;

        LifeTime* lifeTime;
        Iterator* iterator;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
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

            int result;

            while (!empty) {
                Char temp = front();

                result = del(temp);
                if (result)
                    return result;

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

            Char temp;
            int result;

            while (!empty) {
                temp = back();

                result = del(temp);
                if (result)
                    return result;

                popBack();
            }

            return result;
        }
    }

    ///
    alias Char = Char_;
    ///
    alias LiteralType = immutable(Char)[];

    ///
    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        static Text = cast(LiteralType)"Hello there!";
        String_UTF text = String_UTF(Text);

        size_t lastIndex;

        foreach (c; text) {
            assert(Text[lastIndex] == c);
            lastIndex++;
        }

        assert(lastIndex == Text.length);
    }

    ///
    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"], "opApplyReverse");

    ///
    unittest {
        static Text = cast(LiteralType)"Hello there!";
        String_UTF text = String_UTF(Text);

        size_t lastIndex = Text.length;

        foreach_reverse (c; text) {
            assert(lastIndex > 0);
            lastIndex--;
            assert(Text[lastIndex] == c);
        }

        assert(lastIndex == 0);
    }

nothrow @nogc:

    /**
        Makes no guarantees that the const(char)[] is actually null terminated. Unsafe!!!

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
            auto actual = cast(const(char)[])this.literal;
            assert(end <= actual.length, "End of slice must be before or equal to length.");
            ret.literal = actual[start .. end];
        }, () {
            auto actual = cast(const(wchar)[])this.literal;
            assert(end <= actual.length, "End of slice must be before or equal to length.");
            ret.literal = actual[start .. end];
        }, () {
            auto actual = cast(const(dchar)[])this.literal;
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

        stuff.popFront;
        assert(stuff.tupleof != stuff.withoutIterator.tupleof);
    }

@safe:

    ///
    void opAssign(scope const(char)[] literal) scope @trusted {
        this = String_UTF(cast(const(char)[])literal);
    }

    ///
    unittest {
        String_UTF info;
        info = "abcd";
    }

    ///
    void opAssign(scope const(wchar)[] literal) scope @trusted {
        this = String_UTF(cast(const(wchar)[])literal);
    }

    ///
    unittest {
        String_UTF info;
        info = "abcd"w;
    }

    ///
    void opAssign(scope const(dchar)[] literal) scope @trusted {
        this = String_UTF(cast(const(dchar)[])literal);
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
        ///
        this(scope return const(char)[] literal, scope return RCAllocator allocator = RCAllocator.init,
                scope return const(char)[] toDeallocate = null) {
            initForLiteral(literal, allocator, toDeallocate);
        }

        ///
        this(scope return const(wchar)[] literal, scope return RCAllocator allocator = RCAllocator.init,
                scope return const(wchar)[] toDeallocate = null) {
            initForLiteral(literal, allocator, toDeallocate);
        }

        ///
        this(scope return const(dchar)[] literal, scope return RCAllocator allocator = RCAllocator.init,
                scope return const(dchar)[] toDeallocate = null) {
            initForLiteral(literal, allocator, toDeallocate);
        }

        private void initForLiteral(T, U)(scope return T literal, scope return RCAllocator allocator, scope return U toDeallocate) {
            if (literal.length > 0 || (toDeallocate.length > 0 && !allocator.isNull)) {
                version (D_BetterC) {
                } else {
                    if (__ctfe && literal[$ - 1] != '\0') {
                        static T justDoIt(T input) {
                            return input ~ '\0';
                        }

                        literal = (cast(T function(T)@safe nothrow @nogc)&justDoIt)(literal);
                    }
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

        ///
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

        assert(!thing.empty);
        thing.popFront;

        assert(thing.haveIterator);
    }

    /**
    Returns: if ``ptr`` will return a null terminated const(char)[] or not
    */
    bool isPtrNullTerminated() scope @trusted {
        if (isNull)
            return false;

        return literalEncoding.handle(() {
            auto actual = cast(const(char)[])this.literal;

            if (actual[$ - 1] == '\0')
                return true;
            else if (this.lifeTime is null)
                return actual[$ - 1] == '\0';

            auto actualOriginal = cast(const(char)[])this.lifeTime.original;

            return actualOriginal[$ - 1] == '\0' && ((actualOriginal.ptr + actualOriginal.length) - (actual.length + 1)) is actual.ptr;
        }, () {
            auto actual = cast(const(wchar)[])this.literal;

            if (actual[$ - 1] == '\0')
                return true;
            else if (this.lifeTime is null)
                return actual[$ - 1] == '\0';

            auto actualOriginal = cast(const(wchar)[])this.lifeTime.original;

            return actualOriginal[$ - 1] == '\0' && ((actualOriginal.ptr + actualOriginal.length) - (actual.length + 1)) is actual.ptr;
        }, () {
            auto actual = cast(const(dchar)[])this.literal;

            if (actual[$ - 1] == '\0')
                return true;
            else if (this.lifeTime is null)
                return actual[$ - 1] == '\0';

            auto actualOriginal = cast(const(dchar)[])this.lifeTime.original;

            return actualOriginal[$ - 1] == '\0' && ((actualOriginal.ptr + actualOriginal.length) - (actual.length + 1)) is actual.ptr;
        });
    }

    ///
    unittest {
        static String_UTF global = String_UTF("oh yeah");
        assert(global.isPtrNullTerminated());

        String_UTF stack = String_UTF("hmm...");
        assert(!stack.isPtrNullTerminated());

        const(char)[] someText = "oh noes";
        String_UTF someMoreStack = String_UTF(someText);
        assert(!someMoreStack.isPtrNullTerminated());
    }

    /// Returns: if the underlying encoding is different from the typed encoding.
    bool isEncodingChanged() const scope {
        return this.literalEncoding.codepointSize != Char.sizeof;
    }

    ///
    alias opDollar = length;

    /**
        The length of the const(char)[] in its native encoding.

        Removes null terminator at the end if it has one.
     */
    size_t length() const scope {
        return literalEncoding.handle(() {
            auto actual = cast(const(char)[])this.literal;

            size_t ret = actual.length;
            if (ret > 0 && actual[$ - 1] == '\0')
                ret--;
            return ret;
        }, () {
            auto actual = cast(const(wchar)[])this.literal;

            size_t ret = actual.length;
            if (ret > 0 && actual[$ - 1] == '\0')
                ret--;
            return ret;
        }, () {
            auto actual = cast(const(dchar)[])this.literal;

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
            auto actual = cast(const(char)[])this.literal[0 .. this.length];

            static if (is(Char == char))
                return actual.length;
            else static if (is(Char == wchar))
                return reEncodeLength(actual);
            else
                return decodeLength(actual);
        }, () {
            auto actual = (cast(const(wchar)[])this.literal)[0 .. this.length];

            static if (is(Char == char))
                return reEncodeLength(actual);
            else static if (is(Char == wchar))
                return actual.length;
            else
                return decodeLength(actual);
        }, () {
            auto actual = (cast(const(dchar)[])this.literal)[0 .. this.length];

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

        void copy(Source)(scope Source source) {
            foreach (i, Char c; source)
                zliteral[i] = c;
        }

        size_t soFar;
        literalEncoding.handle(() {
            auto actual = cast(const(char)[])this.literal[0 .. this.length];

            static if (is(Char == char))
                copy(actual);
            else static if (is(Char == wchar))
                reEncode(actual, (wchar got) { zliteral[soFar++] = got; });
            else
                decode(actual, (dchar got) { zliteral[soFar++] = got; });
        }, () {
            auto actual = (cast(const(wchar)[])this.literal)[0 .. this.length];

            static if (is(Char == char))
                reEncode(actual, (char got) { zliteral[soFar++] = got; });
            else static if (is(Char == wchar))
                copy(actual);
            else
                decode(actual, (dchar got) { zliteral[soFar++] = got; });
        }, () {
            auto actual = (cast(const(dchar)[])this.literal)[0 .. this.length];

            static if (is(Char == char))
                encodeUTF8(actual, (char got) { zliteral[soFar++] = got; });
            else static if (is(Char == wchar))
                encodeUTF16(actual, (wchar got) { zliteral[soFar++] = got; });
            else
                copy(actual);
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
    String_UTF normalize(RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown,
            bool compatibility = false, bool compose = false) scope @trusted {
        allocator = pickAllocator(allocator);
        scope us32 = this.byUTF32();

        import n = sidero.base.text.unicode.normalization;

        const(dchar)[] got = n.normalize(&us32.opApply, allocator, language.isTurkic, compatibility, compose);
        return String_UTF(got, allocator, got);
    }

    ///
    String_UTF opIndex(size_t index) scope {
        return this[index .. index + 1];
    }

    ///
    bool opCast(T : bool)() scope const {
        return !isNull;
    }

    @disable auto opCast(T)();

    const {
        ///
        alias equals = opEquals;

        ///
        int opEquals(scope const(char)[] other) scope {
            return opCmpImpl(other) == 0;
        }

        ///
        int opEquals(scope const(wchar)[] other) scope {
            return opCmpImpl(other) == 0;
        }

        ///
        int opEquals(scope const(dchar)[] other) scope {
            return opCmpImpl(other) == 0;
        }

        ///
        bool opEquals(scope String_UTF8 other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope String_UTF16 other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope String_UTF32 other) scope {
            return opCmp(other) == 0;
        }

        ///
        unittest {
            String_UTF first = String_UTF(cast(LiteralType)"first");
            String_UTF notFirst = String_UTF(cast(LiteralType)"first");
            String_UTF third = String_UTF(cast(LiteralType)"third");

            assert(first == notFirst);
            assert(first != third);
        }
    }

    const {
        ///
        int ignoreCaseEquals(scope const(char)[] other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplSlice(other, allocator, language.isTurkic) == 0;
        }

        ///
        int ignoreCaseEquals(scope const(wchar)[] other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplSlice(other, allocator, language.isTurkic) == 0;
        }

        ///
        int ignoreCaseEquals(scope const(dchar)[] other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplSlice(other, allocator, language.isTurkic) == 0;
        }

        ///
        bool ignoreCaseEquals(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseEqualsImplReadOnly(other, allocator, language);
        }

        ///
        bool ignoreCaseEquals(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseEqualsImplReadOnly(other, allocator, language);
        }

        ///
        bool ignoreCaseEquals(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseEqualsImplReadOnly(other, allocator, language);
        }
    }

    const {
        ///
        alias compare = opCmp;

        ///
        int opCmp(scope const(char)[] other) scope {
            return opCmpImpl(other);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"a").opCmp("z") < 0);
            assert(String_UTF(cast(LiteralType)"z").opCmp("a") > 0);
        }

        ///
        int opCmp(scope const(wchar)[] other) scope {
            return opCmpImpl(other);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"a").opCmp("z"w) < 0);
            assert(String_UTF(cast(LiteralType)"z").opCmp("a"w) > 0);
        }

        ///
        int opCmp(scope const(dchar)[] other) scope {
            return opCmpImpl(other);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"a").opCmp("z"d) < 0);
            assert(String_UTF(cast(LiteralType)"z").opCmp("a"d) > 0);
        }

        ///
        @trusted unittest {
            assert(String_UTF("a") < cast(LiteralType)['z']);
            assert(String_UTF("z") > cast(LiteralType)['a']);
        }

        ///
        int opCmp(scope String_UTF8 other) scope {
            return opCmpImplReadOnly(other);
        }

        ///
        unittest {
            assert(String_UTF8("a").opCmp(String_UTF8("z")) < 0);
            assert(String_UTF8("z").opCmp(String_UTF8("a")) > 0);
        }

        ///
        int opCmp(scope String_UTF16 other) scope {
            return opCmpImplReadOnly(other);
        }

        ///
        unittest {
            assert(String_UTF16("a"w).opCmp(String_UTF16("z"w)) < 0);
            assert(String_UTF16("z"w).opCmp(String_UTF16("a"w)) > 0);
        }

        ///
        int opCmp(scope String_UTF32 other) scope {
            return opCmpImplReadOnly(other);
        }

        ///
        unittest {
            assert(String_UTF32("a"d).opCmp(String_UTF32("z"d)) < 0);
            assert(String_UTF32("z"d).opCmp(String_UTF32("a"d)) > 0);
        }
    }

    const {
        ///
        int ignoreCaseCompare(scope const(char)[] other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplSlice(other, allocator, language.isTurkic);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"A").ignoreCaseCompare("z") < 0);
            assert(String_UTF(cast(LiteralType)"Z").ignoreCaseCompare("a") > 0);
        }

        ///
        int ignoreCaseCompare(scope const(wchar)[] other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplSlice(other, allocator, language.isTurkic);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"A").ignoreCaseCompare("z"w) < 0);
            assert(String_UTF(cast(LiteralType)"Z").ignoreCaseCompare("a"w) > 0);
        }

        ///
        int ignoreCaseCompare(scope const(dchar)[] other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplSlice(other, allocator, language.isTurkic);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"A").ignoreCaseCompare("z"d) < 0);
            assert(String_UTF(cast(LiteralType)"Z").ignoreCaseCompare("a"d) > 0);
        }

        ///
        int ignoreCaseCompare(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplReadOnly(other, allocator, language);
        }

        ///
        int ignoreCaseCompare(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplReadOnly(other, allocator, language);
        }

        ///
        int ignoreCaseCompare(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompareImplReadOnly(other, allocator, language);
        }

        ///
        unittest {
            assert(String_UTF(cast(LiteralType)"a").ignoreCaseCompare(String_UTF(cast(LiteralType)"Z")) < 0);
            assert(String_UTF(cast(LiteralType)"Z").ignoreCaseCompare(String_UTF(cast(LiteralType)"a")) > 0);
        }
    }

    ///
    bool empty() scope nothrow @nogc {
        return (haveIterator && this.iterator.literal.length == 0 && this.iterator.forwardItems.length == 0 &&
                this.iterator.backwardItems.length == 0) || this.length == 0;
    }

    ///
    unittest {
        String_UTF thing;
        assert(thing.empty);

        thing = cast(LiteralType)"bar";
        assert(!thing.empty);
    }

    ///
    Char front() scope @trusted {
        assert(!isNull);
        setupIterator;

        const canRefill = this.iterator.literal.length > 0;
        const needRefill = this.iterator.forwardItems.length == 0;
        const needToUseOtherBuffer = !canRefill && needRefill && this.iterator.backwardItems.length > 0;

        if (needToUseOtherBuffer) {
            // take first in backwards buffer
            assert(this.iterator.backwardItems.length > 0);
            return (cast(Char[])this.iterator.backwardItems)[0];
        } else if (needRefill) {
            popFront;
        }

        // take first in forwards buffer
        assert(this.iterator.forwardItems.length > 0);
        return (cast(Char[])this.iterator.forwardItems)[0];
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        String_UTF text = String_UTF(Text8);
        foreach (i, c; Text8) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);

        text = String_UTF(Text16);
        foreach (i, c; Text16) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);

        text = String_UTF(Text32);
        foreach (i, c; Text32) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);
    }

    ///
    Char back() scope @trusted {
        assert(!isNull);
        setupIterator;

        const canRefill = this.iterator.literal.length > 0;
        const needRefill = this.iterator.backwardItems.length == 0;
        const needToUseOtherBuffer = !canRefill && this.iterator.forwardItems.length > 0 && needRefill;

        if (needToUseOtherBuffer) {
            // take first in backwards buffer
            assert(this.iterator.forwardItems.length > 0);
            return (cast(Char[])this.iterator.forwardItems)[$ - 1];
        } else if (needRefill) {
            popBack;
        }

        // take first in forwards buffer
        assert(this.iterator.backwardItems.length > 0);
        return (cast(Char[])this.iterator.backwardItems)[$ - 1];
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        String_UTF text = String_UTF(Text8);
        foreach_reverse (i, c; Text8) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);

        text = String_UTF(Text16);
        foreach_reverse (i, c; Text16) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);

        text = String_UTF(Text32);
        foreach_reverse (i, c; Text32) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);
    }

    /// See_Also: front
    void popFront() scope @trusted {
        assert(!empty);

        setupIterator;

        const canRefill = this.iterator.literal.length > 0;
        const needRefill = this.iterator.forwardItems.length == 0;
        const needToUseOtherBuffer = !canRefill && this.iterator.forwardItems.length == 0 && this.iterator.backwardItems.length > 0;

        void copy(Destination, Source)(scope Destination destination, scope Source source) {
            foreach (i, c; source)
                destination[i] = c;
        }

        if (needToUseOtherBuffer) {
            this.iterator.backwardItems = (cast(Char[])this.iterator.backwardItems)[1 .. $];
        } else if (needRefill) {
            assert(canRefill);

            Char[4 / Char.sizeof] charBuffer;
            size_t amountFilled;

            literalEncoding.handle(() {
                auto actual = cast(const(char)[])this.iterator.literal;

                static if (is(Char == char)) {
                    // copy straight
                    size_t canDo = charBuffer.length;
                    if (canDo > actual.length)
                        canDo = actual.length;

                    copy(charBuffer[0 .. canDo], actual[0 .. canDo]);

                    actual = actual[canDo .. $];
                    amountFilled = canDo;
                } else static if (is(Char == wchar)) {
                    // need to reencode
                    const consumedGiven = reEncode(actual, charBuffer);

                    actual = actual[consumedGiven[0] .. $];
                    amountFilled = consumedGiven[1];
                } else static if (is(Char == dchar)) {
                    // decode
                    const consumed = decode(actual, charBuffer[0]);

                    actual = actual[consumed .. $];
                    amountFilled = 1;
                }

                this.iterator.literal = actual;
            }, () {
                auto actual = cast(const(wchar)[])this.iterator.literal;

                static if (is(Char == char)) {
                    // need to reencode
                    const consumedGiven = reEncode(actual, charBuffer);

                    actual = actual[consumedGiven[0] .. $];
                    amountFilled = consumedGiven[1];
                } else static if (is(Char == wchar)) {
                    // copy straight
                    size_t canDo = charBuffer.length;
                    if (canDo > actual.length)
                        canDo = actual.length;

                    copy(charBuffer[0 .. canDo], actual[0 .. canDo]);

                    actual = actual[canDo .. $];
                    amountFilled = canDo;
                } else static if (is(Char == dchar)) {
                    // decode
                    const consumed = decode(actual, charBuffer[0]);

                    actual = actual[consumed .. $];
                    amountFilled = 1;
                }

                this.iterator.literal = actual;
            }, () {
                auto actual = cast(const(dchar)[])this.iterator.literal;

                static if (is(Char == char)) {
                    // encode
                    amountFilled = encodeUTF8(actual[0], charBuffer);
                    actual = actual[1 .. $];
                } else static if (is(Char == wchar)) {
                    // encode
                    amountFilled = encodeUTF16(actual[0], charBuffer);
                    actual = actual[1 .. $];
                } else static if (is(Char == dchar)) {
                    // copy straight
                    size_t canDo = charBuffer.length;
                    if (canDo > actual.length)
                        canDo = actual.length;

                    copy(charBuffer[0 .. canDo], actual[0 .. canDo]);

                    actual = actual[canDo .. $];
                    amountFilled = canDo;
                }

                this.iterator.literal = actual;
            });

            this.iterator.forwardBuffer = charBuffer;
            this.iterator.forwardItems = (cast(Char[])this.iterator.forwardBuffer)[0 .. amountFilled];
        } else {
            this.iterator.forwardItems = (cast(Char[])this.iterator.forwardItems)[1 .. $];
        }
    }

    /// See_Also: back
    void popBack() scope @trusted {
        assert(!empty);

        setupIterator;

        const canRefill = this.iterator.literal.length > 0;
        const needRefill = this.iterator.backwardItems.length == 0;
        const needToUseOtherBuffer = !canRefill && this.iterator.forwardItems.length > 0 && needRefill;

        void copy(Destination, Source)(scope Destination destination, scope Source source) {
            foreach (i, c; source)
                destination[i] = c;
        }

        if (needToUseOtherBuffer) {
            this.iterator.forwardItems = (cast(Char[])this.iterator.forwardItems)[0 .. $ - 1];
        } else if (needRefill) {
            assert(canRefill);

            Char[4 / Char.sizeof] charBuffer;
            size_t amountFilled;

            literalEncoding.handle(() {
                auto actual = cast(const(char)[])this.iterator.literal;

                static if (is(Char == char)) {
                    // copy straight
                    size_t canDo = charBuffer.length;
                    if (canDo > actual.length)
                        canDo = actual.length;

                    copy(charBuffer[0 .. canDo], actual[$ - canDo .. $]);

                    actual = actual[0 .. $ - canDo];
                    amountFilled = canDo;
                } else static if (is(Char == wchar)) {
                    // need to reencode
                    const consumedGiven = reEncodeFromEnd(actual, charBuffer);

                    actual = actual[0 .. $ - consumedGiven[0]];
                    amountFilled = consumedGiven[1];
                } else static if (is(Char == dchar)) {
                    // decode
                    const consumed = decodeFromEnd(actual, charBuffer[0]);

                    actual = actual[0 .. $ - consumed];
                    amountFilled = 1;
                }

                this.iterator.literal = actual;
            }, () {
                auto actual = cast(const(wchar)[])this.iterator.literal;

                static if (is(Char == char)) {
                    // need to reencode
                    const consumedGiven = reEncodeFromEnd(actual, charBuffer);

                    actual = actual[0 .. $ - consumedGiven[0]];
                    amountFilled = consumedGiven[1];
                } else static if (is(Char == wchar)) {
                    // copy straight
                    size_t canDo = charBuffer.length;
                    if (canDo > actual.length)
                        canDo = actual.length;

                    copy(charBuffer[0 .. canDo], actual[$ - canDo .. $]);

                    actual = actual[0 .. $ - canDo];
                    amountFilled = canDo;
                } else static if (is(Char == dchar)) {
                    // decode
                    const consumed = decodeFromEnd(actual, charBuffer[0]);

                    actual = actual[0 .. $ - consumed];
                    amountFilled = 1;
                }

                this.iterator.literal = actual;
            }, () {
                auto actual = cast(const(dchar)[])this.iterator.literal;

                static if (is(Char == char)) {
                    // encode
                    amountFilled = encodeUTF8(actual[$ - 1], charBuffer);
                    actual = actual[0 .. $ - 1];
                } else static if (is(Char == wchar)) {
                    // encode
                    amountFilled = encodeUTF16(actual[$ - 1], charBuffer);
                    actual = actual[0 .. $ - 1];
                } else static if (is(Char == dchar)) {
                    // copy straight
                    size_t canDo = charBuffer.length;
                    if (canDo > actual.length)
                        canDo = actual.length;

                    copy(charBuffer[0 .. canDo], actual[$ - canDo .. $]);

                    actual = actual[0 .. $ - canDo];
                    amountFilled = canDo;
                }

                this.iterator.literal = actual;
            });

            this.iterator.backwardBuffer = charBuffer;
            this.iterator.backwardItems = (cast(Char[])this.iterator.backwardBuffer)[0 .. amountFilled];
        } else {
            this.iterator.backwardItems = (cast(Char[])this.iterator.backwardItems)[0 .. $ - 1];
        }
    }

    ///
    String_UTF8 byUTF8() scope return @trusted {
        String_UTF8 ret;
        ret.lifeTime = cast(String_UTF8.LifeTime*)this.lifeTime;
        ret.literal = this.literal;
        ret.literalEncoding = this.literalEncoding;

        if (this.lifeTime !is null)
            atomicOp!"+="(this.lifeTime.refCount, 1);

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        String_UTF text = String_UTF(Text8);
        assert(text.length == text.byUTF8().length);

        text = String_UTF(Text16);
        assert(text.length == text.byUTF8().length);

        text = String_UTF(Text32);
        assert(text.length == text.byUTF8().length);
    }

    ///
    String_UTF16 byUTF16() scope return @trusted {
        String_UTF16 ret;
        ret.lifeTime = cast(String_UTF16.LifeTime*)this.lifeTime;
        ret.literal = this.literal;
        ret.literalEncoding = this.literalEncoding;

        if (this.lifeTime !is null)
            atomicOp!"+="(this.lifeTime.refCount, 1);

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        String_UTF text = String_UTF(Text8);
        assert(text.length == text.byUTF16().length);

        text = String_UTF(Text16);
        assert(text.length == text.byUTF16().length);

        text = String_UTF(Text32);
        assert(text.length == text.byUTF16().length);
    }

    ///
    String_UTF32 byUTF32() scope return @trusted {
        String_UTF32 ret;
        ret.lifeTime = cast(String_UTF32.LifeTime*)this.lifeTime;
        ret.literal = this.literal;
        ret.literalEncoding = this.literalEncoding;

        if (this.lifeTime !is null)
            atomicOp!"+="(this.lifeTime.refCount, 1);

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        String_UTF text = String_UTF(Text8);
        assert(text.length == text.byUTF32().length);

        text = String_UTF(Text16);
        assert(text.length == text.byUTF32().length);

        text = String_UTF(Text32);
        assert(text.length == text.byUTF32().length);
    }

    ///
    bool startsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init) scope {
        return startsWithImplSlice(input, allocator, true);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!");
        assert(text.startsWith("hello"));
        assert(!text.startsWith("world!"));
        assert(!text.startsWith("Hello"));
    }

    ///
    bool startsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init) scope {
        return startsWithImplSlice(input, allocator, true);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"w);
        assert(text.startsWith("hello"w));
        assert(!text.startsWith("world!"w));
        assert(!text.startsWith("Hello"w));
    }

    ///
    bool startsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init) scope {
        return startsWithImplSlice(input, allocator, true);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"d);
        assert(text.startsWith("hello"d));
        assert(!text.startsWith("world!"d));
        assert(!text.startsWith("Hello"d));
    }

    ///
    bool ignoreCaseStartsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!");
        assert(text.ignoreCaseStartsWith("hello"));
        assert(!text.ignoreCaseStartsWith("world!"));
    }

    ///
    bool ignoreCaseStartsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"w);
        assert(text.ignoreCaseStartsWith("hello"w));
        assert(!text.ignoreCaseStartsWith("world!"w));
    }

    ///
    bool ignoreCaseStartsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"d);
        assert(text.ignoreCaseStartsWith("hello"d));
        assert(!text.ignoreCaseStartsWith("world!"d));
    }

    ///
    bool startsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplStrReadOnly(other, allocator, true, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!");
        assert(text.startsWith("hello"));
        assert(!text.startsWith("world!"));
    }

    ///
    bool startsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplStrReadOnly(other, allocator, true, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"w);
        assert(text.startsWith("hello"w));
        assert(!text.startsWith("world!"w));
    }

    ///
    bool startsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplStrReadOnly(other, allocator, true, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"d);
        assert(text.startsWith("hello"d));
        assert(!text.startsWith("world!"d));
    }

    ///
    bool ignoreCaseStartsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplStrReadOnly(other, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!");
        assert(text.ignoreCaseStartsWith("hello"));
        assert(!text.ignoreCaseStartsWith("world!"));
    }

    ///
    bool ignoreCaseStartsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplStrReadOnly(other, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"w);
        assert(text.ignoreCaseStartsWith("hello"w));
        assert(!text.ignoreCaseStartsWith("world!"w));
    }

    ///
    bool ignoreCaseStartsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return startsWithImplStrReadOnly(other, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"d);
        assert(text.ignoreCaseStartsWith("hello"d));
        assert(!text.ignoreCaseStartsWith("world!"d));
    }

    ///
    bool endsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init) scope {
        return endsWithImplSlice(input, allocator, true);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!");
        assert(text.endsWith("world!"));
        assert(!text.endsWith("hello"));
        assert(!text.endsWith("Hello"));
    }

    ///
    bool endsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init) scope {
        return endsWithImplSlice(input, allocator, true);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"w);
        assert(text.endsWith("world!"w));
        assert(!text.endsWith("hello"w));
        assert(!text.endsWith("Hello"w));
    }

    ///
    bool endsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init) scope {
        return endsWithImplSlice(input, allocator, true);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"d);
        assert(text.endsWith("world!"d));
        assert(!text.endsWith("hello"d));
        assert(!text.endsWith("Hello"d));
    }

    ///
    bool ignoreCaseEndsWith(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!");
        assert(text.ignoreCaseEndsWith("world!"));
        assert(!text.ignoreCaseEndsWith("hello"));
    }

    ///
    bool ignoreCaseEndsWith(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"w);
        assert(text.ignoreCaseEndsWith("world!"w));
        assert(!text.ignoreCaseEndsWith("hello"w));
    }

    ///
    bool ignoreCaseEndsWith(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"d);
        assert(text.ignoreCaseEndsWith("world!"d));
        assert(!text.ignoreCaseEndsWith("hello"d));
    }

    ///
    bool endsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
            .Unknown) scope {
        return endsWithImplReadOnly(other, allocator, true, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!");
        assert(text.endsWith("world!"));
        assert(!text.endsWith("hello"));
    }

    ///
    bool endsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplReadOnly(other, allocator, true, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"w);
        assert(text.endsWith("world!"w));
        assert(!text.endsWith("hello"w));
    }

    ///
    bool endsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplReadOnly(other, allocator, true, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("hello world!"d);
        assert(text.endsWith("world!"d));
        assert(!text.endsWith("hello"d));
    }

    ///
    bool ignoreCaseEndsWith(scope String_UTF8 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplReadOnly(other, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!");
        assert(text.ignoreCaseEndsWith("world!"));
        assert(!text.ignoreCaseEndsWith("hello"));
    }

    ///
    bool ignoreCaseEndsWith(scope String_UTF16 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplReadOnly(other, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"w);
        assert(text.ignoreCaseEndsWith("world!"w));
        assert(!text.ignoreCaseEndsWith("hello"w));
    }

    ///
    bool ignoreCaseEndsWith(scope String_UTF32 other, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return endsWithImplReadOnly(other, allocator, false, language);
    }

    ///
    unittest {
        String_UTF text = String_UTF("Hello World!"d);
        assert(text.ignoreCaseEndsWith("world!"d));
        assert(!text.ignoreCaseEndsWith("hello"d));
    }

    ///
    size_t count(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").count("a") == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").count("b") == 0);
    }

    ///
    size_t count(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").count("a"w) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").count("b"w) == 0);
    }

    ///
    size_t count(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").count("a"d) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").count("b"d) == 0);
    }

    ///
    size_t ignoreCaseCount(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseCount("a") == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseCount("b") == 0);
    }

    ///
    size_t ignoreCaseCount(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseCount("a"w) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseCount("b"w) == 0);
    }

    ///
    size_t ignoreCaseCount(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseCount("a"d) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseCount("b"d) == 0);
    }

    ///
    size_t count(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
            .Unknown) scope {
        return countImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").count(String_UTF8("a")) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").count(String_UTF8("b")) == 0);
    }

    ///
    size_t count(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
            .Unknown) scope {
        return countImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").count(String_UTF16("a")) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").count(String_UTF16("b")) == 0);
    }

    ///
    size_t count(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
            .Unknown) scope {
        return countImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").count(String_UTF32("a")) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").count(String_UTF32("b")) == 0);
    }

    ///
    size_t ignoreCaseCount(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseCount(String_UTF8("a")) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseCount(String_UTF8("b")) == 0);
    }

    ///
    size_t ignoreCaseCount(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseCount(String_UTF16("a")) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseCount(String_UTF16("b")) == 0);
    }

    ///
    size_t ignoreCaseCount(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return countImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseCount(String_UTF32("a")) == 2);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseCount(String_UTF32("b")) == 0);
    }

    ///
    bool contains(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").contains("a"));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").contains("b"));
    }

    ///
    bool contains(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").contains("a"w));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").contains("b"w));
    }

    ///
    bool contains(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").contains("a"d));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").contains("b"d));
    }

    ///
    bool ignoreCaseContains(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseContains("a"));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseContains("b"));
    }

    ///
    bool ignoreCaseContains(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseContains("a"w));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseContains("b"w));
    }

    ///
    bool ignoreCaseContains(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseContains("a"d));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseContains("b"d));
    }

    ///
    bool contains(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
            .Unknown) scope {
        return containsImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").contains(String_UTF8("a")));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").contains(String_UTF8("b")));
    }

    ///
    bool contains(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").contains(String_UTF16("a")));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").contains(String_UTF16("b")));
    }

    ///
    bool contains(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").contains(String_UTF32("a")));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").contains(String_UTF32("b")));
    }

    ///
    bool ignoreCaseContains(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseContains(String_UTF8("a")));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseContains(String_UTF8("b")));
    }

    ///
    bool ignoreCaseContains(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseContains(String_UTF16("a")));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseContains(String_UTF16("b")));
    }

    ///
    bool ignoreCaseContains(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return containsImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseContains(String_UTF32("a")));
        assert(!String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseContains(String_UTF32("b")));
    }

    ///
    ptrdiff_t indexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImpl(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf("a") == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf("b") == -1);
    }

    ///
    ptrdiff_t indexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImpl(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf("a"w) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf("b"w) == -1);
    }

    ///
    ptrdiff_t indexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImpl(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf("a"d) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf("b"d) == -1);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImpl(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseIndexOf("a") == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseIndexOf("b") == -1);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImpl(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseIndexOf("a"w) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseIndexOf("b"w) == -1);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImpl(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseIndexOf("a"d) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseIndexOf("b"d) == -1);
    }

    ///
    ptrdiff_t indexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf(String_UTF8("a")) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf(String_UTF8("b")) == -1);
    }

    ///
    ptrdiff_t indexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf(String_UTF16("a")) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf(String_UTF16("b")) == -1);
    }

    ///
    ptrdiff_t indexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf(String_UTF32("a")) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").indexOf(String_UTF32("b")) == -1);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseIndexOf(String_UTF8("a")) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseIndexOf(String_UTF8("b")) == -1);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseIndexOf(String_UTF16("a")) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseIndexOf(String_UTF16("b")) == -1);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return indexOfImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseIndexOf(String_UTF32("a")) == 5);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseIndexOf(String_UTF32("b")) == -1);
    }

    ///
    ptrdiff_t lastIndexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf("a") == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf("b") == -1);
    }

    ///
    ptrdiff_t lastIndexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf("a"w) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf("b"w) == -1);
    }

    ///
    ptrdiff_t lastIndexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplSlice(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf("a"d) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf("b"d) == -1);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope const(char)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseLastIndexOf("a") == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseLastIndexOf("b") == -1);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope const(wchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseLastIndexOf("a"w) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseLastIndexOf("b"w) == -1);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope const(dchar)[] input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplSlice(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseLastIndexOf("a"d) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseLastIndexOf("b"d) == -1);
    }

    ///
    ptrdiff_t lastIndexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf(String_UTF8("a")) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf(String_UTF8("b")) == -1);
    }

    ///
    ptrdiff_t lastIndexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf(String_UTF16("a")) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf(String_UTF16("b")) == -1);
    }

    ///
    ptrdiff_t lastIndexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplReadOnly(input, allocator, true, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf(String_UTF32("a")) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").lastIndexOf(String_UTF32("b")) == -1);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF8 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseLastIndexOf(String_UTF8("a")) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseLastIndexOf(String_UTF8("b")) == -1);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF16 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseLastIndexOf(String_UTF16("a")) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseLastIndexOf(String_UTF16("b")) == -1);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF32 input, scope RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
        return lastIndexOfImplReadOnly(input, allocator, false, language);
    }

    ///
    unittest {
        assert(String_UTF(cast(LiteralType)"congrAts its alive").ignoreCaseLastIndexOf(String_UTF32("a")) == 13);
        assert(String_UTF(cast(LiteralType)"congrats its alive").ignoreCaseLastIndexOf(String_UTF32("b")) == -1);
    }

    ///
    String_UTF strip() scope return {
        stripLeft();
        stripRight();
        return this;
    }

    ///
    unittest {
        String_UTF value = String_UTF(cast(LiteralType)"  \t abc\t\r\n \0");
        value.strip;
        assert(value == cast(LiteralType)"abc");

        assert(String_UTF(cast(LiteralType)"  \t abc\t\r\n \0").strip == cast(LiteralType)"abc");
    }

    ///
    String_UTF stripLeft() scope return {
        literalEncoding.handle(() @trusted {
            auto actual = cast(const(char)[])this.literal;
            size_t amount;

            while (amount < actual.length) {
                dchar c;
                size_t got = decode(actual[amount .. $], c);

                if (!isWhiteSpace(c))
                    break;
                amount += got;
            }

            this.literal = actual[amount .. $];
        }, () @trusted {
            auto actual = cast(const(wchar)[])this.literal;
            size_t amount;

            while (amount < actual.length) {
                dchar c;
                size_t got = decode(actual[amount .. $], c);

                if (!isWhiteSpace(c))
                    break;
                amount += got;
            }

            this.literal = actual[amount .. $];
        }, () @trusted {
            auto actual = cast(const(dchar)[])this.literal;
            size_t amount;

            foreach (c; actual) {
                if (!c.isWhiteSpace)
                    break;

                amount++;
            }

            this.literal = actual[amount .. $];
        });

        return this;
    }

    ///
    unittest {
        String_UTF value = String_UTF(cast(LiteralType)"  \t abc\t\r\n \0");
        value.stripLeft;
        assert(value == cast(LiteralType)"abc\t\r\n \0");

        assert(String_UTF(cast(LiteralType)"  \t abc\t\r\n \0").stripLeft == cast(LiteralType)"abc\t\r\n \0");
    }

    ///
    String_UTF stripRight() scope return {
        literalEncoding.handle(() @trusted {
            auto actual = cast(const(char)[])this.literal[0 .. this.length];
            size_t amount, soFar;

            while (soFar < actual.length) {
                dchar c;
                size_t got = decodeFromEnd(actual[0 .. $ - soFar], c);

                if (isWhiteSpace(c))
                    amount += got;
                else
                    break;

                soFar += got;
            }

            if (amount > 0)
                this.literal = actual[0 .. $ - amount];
        }, () @trusted {
            auto actual = (cast(const(wchar)[])this.literal)[0 .. this.length];
            size_t amount, soFar;

            while (soFar < actual.length) {
                dchar c;
                size_t got = decodeFromEnd(actual[0 .. $ - soFar], c);

                if (isWhiteSpace(c))
                    amount += got;
                else
                    break;

                soFar += got;
            }

            if (amount > 0)
                this.literal = actual[0 .. $ - amount];
        }, () @trusted {
            auto actual = (cast(const(dchar)[])this.literal)[0 .. this.length];
            size_t amount;

            foreach_reverse (c; actual) {
                if (!c.isWhiteSpace) {
                    break;
                }

                amount++;
            }

            if (amount > 0)
                this.literal = actual[0 .. $ - amount];
        });

        return this;
    }

    ///
    unittest {
        String_UTF value = String_UTF(cast(LiteralType)"  \t abc\t\r\n \0");
        value.stripRight;
        assert(value == cast(LiteralType)"  \t abc");

        assert(String_UTF(cast(LiteralType)"  \t abc\t\r\n \0").stripRight == cast(LiteralType)"  \t abc");
    }

    ///
    ulong toHash() const scope @trusted {
        import sidero.base.hash.fnv : fnv_64_1a;

        return fnv_64_1a(cast(ubyte[])this.literal);
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        String_UTF text = String_UTF(Text8);
        assert(text.toHash() == 1586511100919779533);

        text = String_UTF(Text16);
        assert(text.toHash() == 10386160303096007217);

        text = String_UTF(Text32);
        assert(text.toHash() == 3495845543429281309);
    }

private:
    static struct LifeTime {
        shared(int) refCount;
        RCAllocator allocator;
        const(void)[] original;
    }

    static struct Iterator {
        shared(int) refCount;
        RCAllocator allocator;
        const(void)[] literal;

        void[4] forwardBuffer, backwardBuffer;
        void[] forwardItems, backwardItems;

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
            auto actual = cast(const(char)[])this.literal;

            if (actual.length > 0 && actual[$ - 1] == '\0')
                actual = actual[0 .. $ - 1];

            this.iterator.literal = actual;
        }, () {
            auto actual = cast(const(wchar)[])this.literal;

            if (actual.length > 0 && actual[$ - 1] == '\0')
                actual = actual[0 .. $ - 1];

            this.iterator.literal = actual;
        }, () {
            auto actual = cast(const(dchar)[])this.literal;

            if (actual.length > 0 && actual[$ - 1] == '\0')
                actual = actual[0 .. $ - 1];

            this.iterator.literal = actual;
        });
    }

    RCAllocator pickAllocator(scope return RCAllocator given) const @trusted {
        if (!given.isNull)
            return given;
        if (this.lifeTime !is null)
            return cast()this.lifeTime.allocator;
        return globalAllocator();
    }

    const scope {
        bool ignoreCaseEqualsImplReadOnly(Char2)(scope String_UTF!Char2 other,
                scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown) {

            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return ignoreCaseCompareImplSlice(actual, allocator, language.isTurkic);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return ignoreCaseCompareImplSlice(actual, allocator, language.isTurkic);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return ignoreCaseCompareImplSlice(actual, allocator, language.isTurkic);
            }) == 0;
        }

        int opCmpImpl(Other)(scope Other other) {
            int matches(Type)(Type us) {
                if (us.length < other.length)
                    return -1;
                else if (us.length > other.length)
                    return 1;

                foreach (i; 0 .. us.length) {
                    if (us[i] < other[i])
                        return -1;
                    else if (us[i] > other[i])
                        return 1;
                }

                return 0;
            }

            int needDecode(Type)(Type us) {
                while (us.length > 0 && other.length > 0) {
                    dchar usC, otherC;

                    static if (typeof(us[0]).sizeof == 4) {
                        usC = us[0];
                        us = us[1 .. $];
                    } else
                        us = us[decode(us, usC) .. $];

                    static if (typeof(other[0]).sizeof == 4) {
                        otherC = other[0];
                        other = other[1 .. $];
                    } else
                        other = other[decode(other, otherC) .. $];

                    if (usC < otherC)
                        return -1;
                    else if (usC > otherC)
                        return 1;
                }

                if (us.length == 0)
                    return other.length == 0 ? 0 : -1;
                else
                    return 1;
            }

            return literalEncoding.handle(() {
                auto actual = cast(const(char)[])this.literal;

                static if (typeof(other[0]).sizeof == char.sizeof) {
                    return matches(actual);
                } else
                    return needDecode(actual);
            }, () {
                auto actual = cast(const(wchar)[])this.literal;

                static if (typeof(other[0]).sizeof == wchar.sizeof) {
                    return matches(actual);
                } else
                    return needDecode(actual);
            }, () {
                auto actual = cast(const(dchar)[])this.literal;

                static if (typeof(other[0]).sizeof == dchar.sizeof) {
                    return matches(actual);
                } else
                    return needDecode(actual);
            });
        }

        int opCmpImplReadOnly(Char2)(scope String_UTF!Char2 other) {
            return other.literalEncoding.handle(() { auto actual = cast(const(char)[])other.literal; return opCmp(actual); }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return opCmp(actual);
            }, () { auto actual = cast(const(dchar)[])other.literal; return opCmp(actual); });
        }

        int ignoreCaseCompareImplReadOnly(Char2)(scope String_UTF!Char2 other,
                scope RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.Unknown) {

            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return ignoreCaseCompareImplSlice(actual, allocator, language.isTurkic);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return ignoreCaseCompareImplSlice(actual, allocator, language.isTurkic);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return ignoreCaseCompareImplSlice(actual, allocator, language.isTurkic);
            });
        }

        int ignoreCaseCompareImplSlice(Other)(scope Other other, scope RCAllocator allocator = RCAllocator.init, bool turkic = false) @trusted {
            import sidero.base.text.unicode.comparison;

            allocator = pickAllocator(allocator);
            scope ForeachOverAnyUTF usH, otherH = foreachOverAnyUTF(other);

            literalEncoding.handle(() @trusted {
                auto actual = cast(const(char)[])this.literal;
                usH = foreachOverAnyUTF(actual);
            }, () { auto actual = cast(const(wchar)[])this.literal; usH = foreachOverAnyUTF(actual); }, () {
                auto actual = cast(const(dchar)[])this.literal;
                usH = foreachOverAnyUTF(actual);
            });

            return icmpUTF32_NFD(&usH.opApply, &otherH.opApply, allocator, turkic);
        }
    }

    scope {
        bool startsWithImplSlice(String)(scope String input, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) @trusted {
            import sidero.base.text.unicode.comparison : CaseAwareComparison;

            allocator = pickAllocator(allocator);

            scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(input);
            scope comparison = CaseAwareComparison(allocator, language.isTurkic);
            scope tempUs = this.byUTF32();

            // Most likely we are longer than the input const(char)[].
            // Therefore we must set the input as what to compare against (to try and prevent memory allocations).
            // We also need to tell the comparator to ignore if we are longer.

            comparison.setAgainst(&inputOpApply.opApply, caseSensitive);
            return comparison.compare(&tempUs.opApply, true) == 0;
        }

        bool startsWithImplStrReadOnly(Char2)(scope String_UTF!Char2 other, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) {

            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return startsWithImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return startsWithImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return startsWithImplSlice(actual, allocator, caseSensitive, language);
            });
        }

        bool endsWithImplSlice(String)(scope String input, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) @trusted {
            import sidero.base.text.unicode.comparison : CaseAwareComparison;

            allocator = pickAllocator(allocator);

            scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(input);
            scope comparison = CaseAwareComparison(allocator, language.isTurkic);

            // Most likely we are longer than the input const(char)[].
            // Therefore we must set the input as what to compare against (to try and prevent memory allocations).
            // We also need to tell the comparator to ignore if we are longer.

            comparison.setAgainst(&inputOpApply.opApply, caseSensitive);

            // it is not enough to compare, we need to set an offset for us to make it match up to the end.
            const numberOfCharactersNeeded = comparison.againstLength();
            const toConsumeLength = literalEncoding.handle(() {
                auto actual = cast(const(char)[])this.literal;
                return codePointsFromEnd(actual, numberOfCharactersNeeded);
            }, () {
                auto actual = cast(const(wchar)[])this.literal;
                return codePointsFromEnd(actual, numberOfCharactersNeeded);
            }, () {
                auto actual = cast(const(dchar)[])this.literal;
                return codePointsFromEnd(actual, numberOfCharactersNeeded);
            });

            if (toConsumeLength == 0) {
                // we are smaller or equal in size
                return toConsumeLength == input.length;
            }

            const offsetForUs = this.length - toConsumeLength;
            scope tempUs = this[offsetForUs .. offsetForUs + toConsumeLength].byUTF32();
            return comparison.compare(&tempUs.opApply, true) == 0;
        }

        bool endsWithImplReadOnly(Char2)(scope String_UTF!Char2 other, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) {

            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return endsWithImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return endsWithImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return endsWithImplSlice(actual, allocator, caseSensitive, language);
            });
        }

        size_t countImplSlice(String)(scope String input, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) @trusted {
            import sidero.base.text.unicode.comparison : CaseAwareComparison;

            allocator = pickAllocator(allocator);

            scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(input);
            scope comparison = CaseAwareComparison(allocator, language.isTurkic);
            comparison.setAgainst(&inputOpApply.opApply, caseSensitive);

            String_UTF us = this;
            size_t total;
            const lengthOfOther = comparison.againstLength();

            while (us.length > 0) {
                size_t toIncrease = 1;
                scope tempUs = us.byUTF32();

                if (comparison.compare(&tempUs.opApply, true) == 0) {
                    // GOTCHA
                    toIncrease = lengthOfOther;
                    total++;
                }

                foreach (i; 0 .. toIncrease) {
                    const size_t characterLength = us.literalEncoding.handle(() {
                        return decodeLength(cast(const(char)[])us.literal);
                    }, () { return decodeLength(cast(const(wchar)[])us.literal); }, () {
                        return decodeLength(cast(const(dchar)[])us.literal);
                    });

                    us = us[characterLength .. $];
                }
            }

            return total;
        }

        size_t countImplReadOnly(Char2)(scope String_UTF!Char2 other, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return countImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return countImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return countImplSlice(actual, allocator, caseSensitive, language);
            });
        }

        bool containsImplSlice(String)(scope String input, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) @trusted {
            import sidero.base.text.unicode.comparison : CaseAwareComparison;

            allocator = pickAllocator(allocator);

            scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(input);
            scope comparison = CaseAwareComparison(allocator, language.isTurkic);
            comparison.setAgainst(&inputOpApply.opApply, caseSensitive);

            String_UTF us = this;
            const lengthOfOther = comparison.againstLength();

            while (us.length > 0) {
                size_t toIncrease = 1;
                scope tempUs = us.byUTF32();

                if (comparison.compare(&tempUs.opApply, true) == 0) {
                    return true;
                }

                foreach (i; 0 .. toIncrease) {
                    const size_t characterLength = us.literalEncoding.handle(() {
                        return decodeLength(cast(const(char)[])us.literal);
                    }, () { return decodeLength(cast(const(wchar)[])us.literal); }, () {
                        return decodeLength(cast(const(dchar)[])us.literal);
                    });

                    us = us[characterLength .. $];
                }
            }

            return false;
        }

        bool containsImplReadOnly(Char2)(scope String_UTF!Char2 other, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return containsImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return containsImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return containsImplSlice(actual, allocator, caseSensitive, language);
            });
        }

        ptrdiff_t indexOfImpl(String)(scope String input, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) @trusted {
            import sidero.base.text.unicode.comparison : CaseAwareComparison;

            allocator = pickAllocator(allocator);

            scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(input);
            scope comparison = CaseAwareComparison(allocator, language.isTurkic);
            comparison.setAgainst(&inputOpApply.opApply, caseSensitive);

            ptrdiff_t ret;
            String_UTF us = this;
            const lengthOfOther = comparison.againstLength();

            while (us.length > 0) {
                size_t toIncrease = 1;
                scope tempUs = us.byUTF32();

                if (comparison.compare(&tempUs.opApply, true) == 0) {
                    return ret;
                }

                foreach (i; 0 .. toIncrease) {
                    const size_t characterLength = us.literalEncoding.handle(() {
                        return decodeLength(cast(const(char)[])us.literal);
                    }, () { return decodeLength(cast(const(wchar)[])us.literal); }, () {
                        return decodeLength(cast(const(dchar)[])us.literal);
                    });

                    us = us[characterLength .. $];
                    ret += characterLength;
                }
            }

            return -1;
        }

        ptrdiff_t indexOfImplReadOnly(String)(scope String other, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return indexOfImpl(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return indexOfImpl(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return indexOfImpl(actual, allocator, caseSensitive, language);
            });
        }

        ptrdiff_t lastIndexOfImplSlice(String)(scope String input, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) @trusted {
            import sidero.base.text.unicode.comparison : CaseAwareComparison;

            allocator = pickAllocator(allocator);

            scope ForeachOverAnyUTF inputOpApply = foreachOverAnyUTF(input);
            scope comparison = CaseAwareComparison(allocator, language.isTurkic);
            comparison.setAgainst(&inputOpApply.opApply, caseSensitive);

            ptrdiff_t ret = -1, soFar;
            String_UTF us = this;
            const lengthOfOther = comparison.againstLength();

            while (us.length > 0) {
                size_t toIncrease = 1;
                scope tempUs = us.byUTF32();

                if (comparison.compare(&tempUs.opApply, true) == 0) {
                    ret = soFar;
                    toIncrease = lengthOfOther;
                }

                foreach (i; 0 .. toIncrease) {
                    const size_t characterLength = us.literalEncoding.handle(() {
                        return decodeLength(cast(const(char)[])us.literal);
                    }, () { return decodeLength(cast(const(wchar)[])us.literal); }, () {
                        return decodeLength(cast(const(dchar)[])us.literal);
                    });

                    us = us[characterLength .. $];
                    soFar += characterLength;
                }
            }

            return ret;
        }

        ptrdiff_t lastIndexOfImplReadOnly(String)(scope String other, scope RCAllocator allocator = RCAllocator.init,
                bool caseSensitive = true, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            return other.literalEncoding.handle(() {
                auto actual = cast(const(char)[])other.literal;
                return lastIndexOfImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(wchar)[])other.literal;
                return lastIndexOfImplSlice(actual, allocator, caseSensitive, language);
            }, () {
                auto actual = cast(const(dchar)[])other.literal;
                return lastIndexOfImplSlice(actual, allocator, caseSensitive, language);
            });
        }
    }
}
