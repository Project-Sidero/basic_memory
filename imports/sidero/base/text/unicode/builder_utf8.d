module sidero.base.text.unicode.builder_utf8;
import sidero.base.text.unicode.internal.builder;
import sidero.base.text.unicode.characters.database : UnicodeLanguage;
import sidero.base.text;
import sidero.base.allocators.api;

export:

///
struct StringBuilder_UTF8 {
    ///
    alias Char = char;
    ///
    alias LiteralType = immutable(Char)[];

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(scope Del del) scope {
            return state.opApplyImpl!Char(del);
        }

        int opApplyReverseImpl(Del)(scope Del del) scope {
            return state.opApplyReverseImpl!Char(del);
        }
    }

export:
    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        static Text = cast(LiteralType)"Hello there!";
        typeof(this) text = typeof(this)(Text);

        size_t lastIndex;

        foreach (c; text) {
            assert(Text[lastIndex] == c);
            lastIndex++;
        }

        assert(lastIndex == Text.length);
    }

    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"], "opApplyReverse");

    ///
    unittest {
        static Text = cast(LiteralType)"Hello there!";
        typeof(this) text = typeof(this)(Text);

        size_t lastIndex = Text.length;

        foreach_reverse (c; text) {
            assert(lastIndex > 0);
            lastIndex--;
            assert(Text[lastIndex] == c);
        }

        assert(lastIndex == 0);
    }

nothrow @safe:

    void opAssign(scope return ref typeof(this) other) scope @nogc {
        __ctor(other);
    }

    void opAssign(scope return typeof(this) other) scope @nogc {
        __ctor(other);
    }

    @disable void opAssign(scope return ref typeof(this) other) scope const;
    @disable void opAssign(scope return typeof(this) other) scope const;

    @disable auto opCast(T)();

    this(ref return scope typeof(this) other) @trusted scope @nogc {
        this.tupleof = other.tupleof;

        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.rcIterator(true, iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.rcIterator(true, iterator);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.rcIterator(true, iterator);
        });
    }

    @disable this(ref return scope typeof(this) other) @safe scope const;

    @disable this(ref const typeof(this) other) const;
    @disable this(this);

    ///
    this(RCAllocator allocator) scope @nogc {
        state.setup(Char.sizeof, allocator);
    }

    ///
    this(RCAllocator allocator, scope const(char)[] input...) scope @nogc {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope const(wchar)[] input...) scope @nogc {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope const(dchar)[] input...) scope @nogc {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator);
    }

    ///
    @trusted unittest {
        string[] literal8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
        wstring[] literal16 = [
            "\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"
        ];
        dstring[] literal32 = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

        static if (is(Char == char)) {
            auto expected = literal8;
        } else static if (is(Char == wchar)) {
            auto expected = literal16;
        } else static if (is(Char == dchar)) {
            auto expected = literal32;
        }

        {
            foreach (entry; 0 .. literal8.length) {
                auto input = literal8[entry];
                auto output = expected[entry];

                typeof(this) builder = typeof(this)(RCAllocator.init, input);

                foreach (c; builder) {
                    assert(c == output[0]);
                    output = output[1 .. $];
                }

                assert(output.length == 0);
            }
        }

        {
            foreach (entry; 0 .. literal16.length) {
                auto input = literal16[entry];
                auto output = expected[entry];

                typeof(this) builder = typeof(this)(RCAllocator.init, input);

                foreach (c; builder) {
                    assert(c == output[0]);
                    output = output[1 .. $];
                }

                assert(output.length == 0);
            }
        }

        {
            foreach (entry; 0 .. literal32.length) {
                auto input = literal32[entry];
                auto output = expected[entry];

                typeof(this) builder = typeof(this)(RCAllocator.init, input);

                foreach (c; builder) {
                    assert(c == output[0]);
                    output = output[1 .. $];
                }

                assert(output.length == 0);
            }
        }
    }

    ///
    this(RCAllocator allocator, scope String_ASCII input) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    unittest {
        static Text8 = "it is negilible";

        assert(typeof(this)(RCAllocator.init, String_ASCII(Text8)).length == Text8.length);
    }

    ///
    this(RCAllocator allocator, scope String_UTF8 input = String_UTF8.init) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope String_UTF16 input = String_UTF16.init) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope String_UTF32 input = String_UTF32.init) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    unittest {
        static Text = cast(LiteralType)"it is negilible";

        assert(typeof(this)(RCAllocator.init, String_UTF!Char(Text)).length == Text.length);
    }

    ///
    this(scope const(char)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init) scope @nogc {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator, language);
    }

    ///
    this(scope const(wchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init) scope @nogc {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator, language);
    }

    ///
    this(scope const(dchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init) scope @nogc {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator, language);
    }

    ///
    @trusted unittest {
        string[] literal8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
        wstring[] literal16 = [
            "\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"
        ];
        dstring[] literal32 = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

        static if (is(Char == char)) {
            auto expected = literal8;
        } else static if (is(Char == wchar)) {
            auto expected = literal16;
        } else static if (is(Char == dchar)) {
            auto expected = literal32;
        }

        {
            foreach (entry; 0 .. literal8.length) {
                auto input = literal8[entry];
                auto output = expected[entry];

                typeof(this) builder = typeof(this)(input);

                foreach (c; builder) {
                    assert(c == output[0]);
                    output = output[1 .. $];
                }

                assert(output.length == 0);
            }
        }

        {
            foreach (entry; 0 .. literal16.length) {
                auto input = literal16[entry];
                auto output = expected[entry];

                typeof(this) builder = typeof(this)(input);

                foreach (c; builder) {
                    assert(c == output[0]);
                    output = output[1 .. $];
                }

                assert(output.length == 0);
            }
        }

        {
            foreach (entry; 0 .. literal32.length) {
                auto input = literal32[entry];
                auto output = expected[entry];

                typeof(this) builder = typeof(this)(input);

                foreach (c; builder) {
                    assert(c == output[0]);
                    output = output[1 .. $];
                }

                assert(output.length == 0);
            }
        }
    }

    ///
    this(scope String_ASCII input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        input.stripZeroTerminator;

        state.setup(Char.sizeof, allocator);
        state.construct(cast(const(char)[])input.literal, allocator);
    }

    ///
    unittest {
        static Text8 = "it is negilible";

        assert(typeof(this)(String_ASCII(Text8)).length == Text8.length);
    }

    ///
    this(scope String_UTF8 input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator);
    }

    ///
    this(scope String_UTF16 input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator);
    }

    ///
    this(scope String_UTF32 input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        state.setup(Char.sizeof, allocator);
        state.construct(input, allocator);
    }

    ///
    unittest {
        static Text = cast(LiteralType)"it is negilible";

        assert(typeof(this)(String_UTF!Char(Text)).length == Text.length);
    }

    ///
    ~this() scope @nogc {
        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.rcIterator(false, iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.rcIterator(false, iterator);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.rcIterator(false, iterator);
        });
    }

    ///
    bool isNull() scope @nogc {
        return state.isNull;
    }

    ///
    unittest {
        typeof(this) stuff;
        assert(stuff.isNull);

        stuff = typeof(this)("Abc");
        assert(!stuff.isNull);

        stuff = stuff[1 .. 1];
        assert(stuff.isNull);
    }

    ///
    bool haveIterator() scope @nogc {
        return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return iterator !is null;
        }, (StateIterator.S16 state, StateIterator.I16 iterator) { assert(state !is null); return iterator !is null; },
                (StateIterator.S32 state, StateIterator.I32 iterator) { assert(state !is null); return iterator !is null; }, () {
            return false;
        });
    }

    ///
    unittest {
        typeof(this) thing = typeof(this)("bar");
        assert(!thing.haveIterator);

        assert(!thing.empty);
        thing.popFront;

        assert(thing.haveIterator);
    }

    ///
    typeof(this) withoutIterator() scope @trusted @nogc {
        typeof(this) ret;

        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u8 = state;
            state.rc(true);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u16 = state;
            state.rc(true);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u32 = state;
            state.rc(true);
        });

        return ret;
    }

    ///
    unittest {
        typeof(this) stuff = typeof(this)("I have no iterator!");
        assert(stuff.tupleof == stuff.withoutIterator.tupleof);

        stuff.popFront;
        assert(stuff.tupleof != stuff.withoutIterator.tupleof);
    }

    /// Returns: if the underlying encoding is different from the typed encoding.
    bool isEncodingChanged() const scope {
        return state.encoding.codepointSize != Char.sizeof;
    }

    ///
    UnicodeLanguage unicodeLanguage() scope {
        return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
            assert(state !is null);
            return state.language;
        }, (StateIterator.S16 state, StateIterator.I16 iterator) @trusted { assert(state !is null); return state.language; },
                (StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
            assert(state !is null);
            return state.language;
        }, () { return UnicodeLanguage.Unknown; });
    }

    ///
    typeof(this) opIndex(ptrdiff_t index) scope @nogc {
        ptrdiff_t end = index < 0 ? ptrdiff_t.max : index + 1;
        return this[index .. end];
    }

    ///
    typeof(this) save() scope @trusted {
        if (isNull)
            return typeof(this)();

        typeof(this) ret;

        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u8 = state;
            ret.state.i8 = state.newIterator(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) @trusted {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u16 = state;
            ret.state.i16 = state.newIterator(iterator);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u32 = state;
            ret.state.i32 = state.newIterator(iterator);
        });

        return ret;
    }

    ///
    alias opSlice = save;

    ///
    unittest {
        static Text = cast(LiteralType)"goods";

        typeof(this) str = Text;
        assert(!str.haveIterator);

        typeof(this) sliced = str[];
        assert(sliced.haveIterator);
        assert(sliced.length == Text.length);
    }

    ///
    typeof(this) opSlice(ptrdiff_t start, ptrdiff_t end) scope @nogc {
        typeof(this) ret;

        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u8 = state;
            ret.state.i8 = state.newIterator(iterator, start, end);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) @trusted {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u16 = state;
            ret.state.i16 = state.newIterator(iterator, start, end);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u32 = state;
            ret.state.i32 = state.newIterator(iterator, start, end);
        });

        return ret;
    }

    ///
    unittest {
        static if (is(Char == char)) {
            typeof(this) original = typeof(this)("split me here");
            typeof(this) split = original[6 .. 8];

            assert(split.length == 2);
        } else static if (is(Char == wchar)) {
            typeof(this) original = typeof(this)("split me here"w);
            typeof(this) split = original[6 .. 8];

            assert(split.length == 2);
        } else static if (is(Char == dchar)) {
            typeof(this) original = typeof(this)("split me here"d);
            typeof(this) split = original[6 .. 8];

            assert(split.length == 2);
        }
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope @nogc {
        return state.length;
    }

    ///
    unittest {
        typeof(this) stack = typeof(this)(cast(LiteralType)"hmm...");
        assert(stack.length == 6);
    }

    ///
    typeof(this) dup(RCAllocator allocator = RCAllocator.init) scope @nogc {
        typeof(this) ret = typeof(this)(allocator);
        ret.state.setup(Char.sizeof);
        ret.state.insertImpl(this);
        return ret;
    }

    ///
    unittest {
        static Text = cast(LiteralType)"can't be done.";

        typeof(this) builder = typeof(this)(Text);
        assert(builder.dup.length == Text.length);
    }

    ///
    String_UTF!Char asReadOnly(RCAllocator allocator = RCAllocator.init) scope @nogc {
        if (allocator.isNull)
            allocator = globalAllocator();

        Char[] array;
        size_t soFar;

        this.foreachContiguous((scope ref Char[] data) {
            assert(array.length > soFar + data.length, "Encoding length < Encoded");

            foreach (i, Char c; data)
                array[soFar + i] = c;

            soFar += data.length;
            return 0;
        }, (length) { array = allocator.makeArray!Char(length + 1); });

        if (array.length == 0)
            return typeof(return).init;

        assert(array.length == soFar + 1, "Encoding length != Encoded");
        array[$ - 1] = 0;
        return typeof(return)(array, allocator);
    }

    ///
    @trusted unittest {
        static Text = cast(LiteralType)"hey mr. helpful.";
        String_UTF!Char readOnly = typeof(this)(Text).asReadOnly();

        assert(readOnly.length == 16);
        assert((cast(LiteralType)readOnly.literal).length == 17);
        assert(readOnly == Text);
    }

    @nogc {
        ///
        typeof(this) normalize(bool compatibility, bool composition, UnicodeLanguage language) scope @trusted {
            state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);
                state.externalNormalization(iterator, language, compatibility, composition);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);
                state.externalNormalization(iterator, language, compatibility, composition);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);
                state.externalNormalization(iterator, language, compatibility, composition);
            });

            return this;
        }

        ///
        typeof(this) toNFD(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(false, false, language);
        }

        ///
        typeof(this) toNFC(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(false, true, language);
        }

        ///
        typeof(this) toNFKD(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(true, false, language);
        }

        ///
        typeof(this) toNFKC(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(true, true, language);
        }
    }

    ///
    bool opCast(T : bool)() scope const @nogc {
        return !isNull;
    }

    @disable auto opCast(T)();

    ///
    alias equals = opEquals;

    @nogc {
        ///
        bool opEquals(scope const(char)[] other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope const(wchar)[] other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope const(dchar)[] other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope String_ASCII other) scope {
            return opCmp(other) == 0;
        }

        ///
        unittest {
            typeof(this) first = typeof(this)(cast(LiteralType)"first");
            String_ASCII notFirst = String_ASCII("first");
            String_ASCII third = String_ASCII("third");

            assert(first == notFirst);
            assert(first != third);
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
            typeof(this) first = typeof(this)(cast(LiteralType)"first");
            String_UTF!Char notFirst = String_UTF!Char(cast(LiteralType)"first");
            String_UTF!Char third = String_UTF!Char(cast(LiteralType)"third");

            assert(first == notFirst);
            assert(first != third);
        }

        ///
        bool opEquals(scope StringBuilder_ASCII other) scope {
            return opCmp(other) == 0;
        }

        ///
        unittest {
            typeof(this) first = typeof(this)(cast(LiteralType)"first");
            StringBuilder_ASCII notFirst = StringBuilder_ASCII("first");
            StringBuilder_ASCII third = StringBuilder_ASCII("third");

            assert(first == notFirst);
            assert(first != third);
        }

        ///
        bool opEquals(scope StringBuilder_UTF8 other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope StringBuilder_UTF16 other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope StringBuilder_UTF32 other) scope {
            return opCmp(other) == 0;
        }

        ///
        unittest {
            typeof(this) first = typeof(this)(cast(LiteralType)"first");
            typeof(this) notFirst = typeof(this)(cast(LiteralType)"first");
            typeof(this) third = typeof(this)(cast(LiteralType)"third");

            assert(first == notFirst);
            assert(first != third);
        }
    }

    @nogc {
        ///
        bool ignoreCaseEquals(scope const(char)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope const(wchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope const(dchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope String_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope String_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope String_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope String_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope StringBuilder_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope StringBuilder_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope StringBuilder_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }
    }

    ///
    alias compare = opCmp;

    @nogc {
        ///
        int opCmp(scope const(char)[] other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"a").opCmp("z") < 0);
            assert(typeof(this)(cast(LiteralType)"z").opCmp("a") > 0);
        }

        ///
        int opCmp(scope const(wchar)[] other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"a").opCmp("z"w) < 0);
            assert(typeof(this)(cast(LiteralType)"z").opCmp("a"w) > 0);
        }

        ///
        int opCmp(scope const(dchar)[] other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"a").opCmp("z"d) < 0);
            assert(typeof(this)(cast(LiteralType)"z").opCmp("a"d) > 0);
        }

        ///
        int opCmp(scope String_ASCII other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)("a").opCmp(String_ASCII("z")) < 0);
            assert(typeof(this)("z").opCmp(String_ASCII("a")) > 0);
        }

        ///
        int opCmp(scope String_UTF8 other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)("a").opCmp(String_UTF8("z")) < 0);
            assert(typeof(this)("z").opCmp(String_UTF8("a")) > 0);
        }

        ///
        int opCmp(scope String_UTF16 other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)("a"w).opCmp(String_UTF16("z"w)) < 0);
            assert(typeof(this)("z"w).opCmp(String_UTF16("a"w)) > 0);
        }

        ///
        int opCmp(scope String_UTF32 other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)("a"d).opCmp(String_UTF32("z"d)) < 0);
            assert(typeof(this)("z"d).opCmp(String_UTF32("a"d)) > 0);
        }

        ///
        int opCmp(scope StringBuilder_ASCII other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)("a").opCmp(StringBuilder_ASCII("z")) < 0);
            assert(typeof(this)("z").opCmp(StringBuilder_ASCII("a")) > 0);
        }

        ///
        int opCmp(scope StringBuilder_UTF8 other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        int opCmp(scope StringBuilder_UTF16 other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        int opCmp(scope StringBuilder_UTF32 other) scope {
            return state.opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(typeof(this)("a"d).opCmp(typeof(this)("z"d)) < 0);
            assert(typeof(this)("z"d).opCmp(typeof(this)("a"d)) > 0);
        }
    }

    @nogc {
        ///
        int ignoreCaseCompare(scope const(char)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"A").ignoreCaseCompare("z") < 0);
            assert(typeof(this)(cast(LiteralType)"Z").ignoreCaseCompare("a") > 0);
        }

        ///
        int ignoreCaseCompare(scope const(wchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"A").ignoreCaseCompare("z"w) < 0);
            assert(typeof(this)(cast(LiteralType)"Z").ignoreCaseCompare("a"w) > 0);
        }

        ///
        int ignoreCaseCompare(scope const(dchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"A").ignoreCaseCompare("z"d) < 0);
            assert(typeof(this)(cast(LiteralType)"Z").ignoreCaseCompare("a"d) > 0);
        }

        ///
        int ignoreCaseCompare(scope String_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope String_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope String_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"a").ignoreCaseCompare(String_UTF!Char(cast(LiteralType)"Z")) < 0);
            assert(typeof(this)(cast(LiteralType)"Z").ignoreCaseCompare(String_UTF!Char(cast(LiteralType)"a")) > 0);
        }

        ///
        int ignoreCaseCompare(scope String_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"a").ignoreCaseCompare(String_ASCII("Z")) < 0);
            assert(typeof(this)(cast(LiteralType)"Z").ignoreCaseCompare(String_ASCII("a")) > 0);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)(cast(LiteralType)"a").ignoreCaseCompare(StringBuilder_ASCII("Z")) < 0);
            assert(typeof(this)(cast(LiteralType)"Z").ignoreCaseCompare(StringBuilder_ASCII("a")) > 0);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("a"d).ignoreCaseCompare(typeof(this)("Z"d)) < 0);
            assert(typeof(this)("Z"d).ignoreCaseCompare(typeof(this)("a"d)) > 0);
        }
    }

    ///
    alias put = append;

    ///
    bool empty() scope @nogc {
        return state.empty;
    }

    ///
    unittest {
        typeof(this) thing;
        assert(thing.empty);

        thing = typeof(this)(cast(LiteralType)"bar");
        assert(!thing.empty);
    }

    ///
    Char front() scope @nogc {
        return state.front!Char;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        typeof(this) text = typeof(this)(Text8);
        foreach (i, c; Text8) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);

        text = typeof(this)(Text16);
        foreach (i, c; Text16) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);

        text = typeof(this)(Text32);
        foreach (i, c; Text32) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);
    }

    ///
    Char back() scope @nogc {
        return state.back!Char;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        typeof(this) text = typeof(this)(Text8);

        foreach_reverse (i, c; Text8) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);

        text = typeof(this)(Text16);
        foreach_reverse (i, c; Text16) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);

        text = typeof(this)(Text32);
        foreach_reverse (i, c; Text32) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);
    }

    ///
    void popFront() scope @nogc {
        state.popFront!Char;
    }

    ///
    void popBack() scope @nogc {
        state.popBack!Char;
    }

    ///
    StringBuilder_UTF8 byUTF8() @trusted scope @nogc {
        StringBuilder_UTF8 ret;
        ret.state = this.state;

        ret.state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        });

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        typeof(this) text = typeof(this)(Text8);
        assert(text.length == text.byUTF8().length);

        text = typeof(this)(Text16);
        assert(text.length == text.byUTF8().length);

        text = typeof(this)(Text32);
        assert(text.length == text.byUTF8().length);
    }

    ///
    StringBuilder_UTF16 byUTF16() @trusted scope @nogc {
        StringBuilder_UTF16 ret;
        ret.state = this.state;

        ret.state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        });

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        typeof(this) text = typeof(this)(Text8);
        assert(text.length == text.byUTF16().length);

        text = typeof(this)(Text16);
        assert(text.length == text.byUTF16().length);

        text = typeof(this)(Text32);
        assert(text.length == text.byUTF16().length);
    }

    ///
    StringBuilder_UTF32 byUTF32() @trusted scope @nogc {
        StringBuilder_UTF32 ret;
        ret.state = this.state;

        ret.state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator !is null)
                iterator = state.newIterator(iterator);
            else
                state.rc(true);
        });

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        typeof(this) text = typeof(this)(Text8);
        assert(text.length == text.byUTF32().length);

        text = typeof(this)(Text16);
        assert(text.length == text.byUTF32().length);

        text = typeof(this)(Text32);
        assert(text.length == text.byUTF32().length);
    }

    @nogc {
        ///
        bool startsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith("don't"));
            assert(!typeof(this)("don't cha").startsWith("cha"));
        }

        ///
        bool startsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith("don't"w));
            assert(!typeof(this)("don't cha").startsWith("cha"w));
        }

        ///
        bool startsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith("don't"d));
            assert(!typeof(this)("don't cha").startsWith("cha"d));
        }

        ///
        bool startsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(String_ASCII("don't")));
            assert(!typeof(this)("don't cha").startsWith(String_ASCII("cha")));
        }

        ///
        bool startsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(String_UTF8("don't")));
            assert(!typeof(this)("don't cha").startsWith(String_UTF8("cha")));
        }

        ///
        bool startsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(String_UTF16("don't"w)));
            assert(!typeof(this)("don't cha").startsWith(String_UTF16("cha"w)));
        }

        ///
        bool startsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(String_UTF32("don't"d)));
            assert(!typeof(this)("don't cha").startsWith(String_UTF32("cha"d)));
        }

        ///
        bool startsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(StringBuilder_ASCII("don't")));
            assert(!typeof(this)("don't cha").startsWith(StringBuilder_ASCII("cha")));
        }

        ///
        bool startsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(StringBuilder_UTF8("don't")));
            assert(!typeof(this)("don't cha").startsWith(StringBuilder_UTF8("cha")));
        }

        ///
        bool startsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(StringBuilder_UTF16("don't"w)));
            assert(!typeof(this)("don't cha").startsWith(StringBuilder_UTF16("cha"w)));
        }

        ///
        bool startsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").startsWith(StringBuilder_UTF32("don't"d)));
            assert(!typeof(this)("don't cha").startsWith(StringBuilder_UTF32("cha"d)));
        }
    }

    @nogc {
        ///
        bool ignoreCaseStartsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith("dOn't"));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith("cha"));
        }

        ///
        bool ignoreCaseStartsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith("dOn't"w));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith("cha"w));
        }

        ///
        bool ignoreCaseStartsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith("dOn't"d));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith("cha"d));
        }

        ///
        bool ignoreCaseStartsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(String_ASCII("dOn't")));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(String_ASCII("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(String_UTF8("dOn't")));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(String_UTF8("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(String_UTF16("dOn't"w)));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(String_UTF16("cha"w)));
        }

        ///
        bool ignoreCaseStartsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(String_UTF32("dOn't"d)));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(String_UTF32("cha"d)));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_ASCII("dOn't")));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_ASCII("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_UTF8("dOn't")));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_UTF8("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_UTF16("dOn't"w)));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_UTF16("cha"w)));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_UTF32("dOn't"d)));
            assert(!typeof(this)("don't cha").ignoreCaseStartsWith(StringBuilder_UTF32("cha"d)));
        }
    }

    @nogc {
        ///
        bool endsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith("cha"));
            assert(!typeof(this)("don't cha").endsWith("don't"));
        }

        ///
        bool endsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith("cha"w));
            assert(!typeof(this)("don't cha").endsWith("don't"w));
        }

        ///
        bool endsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith("cha"d));
            assert(!typeof(this)("don't cha").endsWith("don't"d));
        }

        ///
        bool endsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(String_ASCII("cha")));
            assert(!typeof(this)("don't cha").endsWith(String_ASCII("don't")));
        }

        ///
        bool endsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(String_UTF8("cha")));
            assert(!typeof(this)("don't cha").endsWith(String_UTF8("don't")));
        }

        ///
        bool endsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(String_UTF16("cha"w)));
            assert(!typeof(this)("don't cha").endsWith(String_UTF16("don't"w)));
        }

        ///
        bool endsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(String_UTF32("cha"d)));
            assert(!typeof(this)("don't cha").endsWith(String_UTF32("don't"d)));
        }

        ///
        bool endsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(StringBuilder_ASCII("cha")));
            assert(!typeof(this)("don't cha").endsWith(StringBuilder_ASCII("don't")));
        }

        ///
        bool endsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(StringBuilder_UTF8("cha")));
            assert(!typeof(this)("don't cha").endsWith(StringBuilder_UTF8("don't")));
        }

        ///
        bool endsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(StringBuilder_UTF16("cha"w)));
            assert(!typeof(this)("don't cha").endsWith(StringBuilder_UTF16("don't"w)));
        }

        ///
        bool endsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").endsWith(StringBuilder_UTF32("cha"d)));
            assert(!typeof(this)("don't cha").endsWith(StringBuilder_UTF32("don't"d)));
        }
    }

    @nogc {
        ///
        bool ignoreCaseEndsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith("cHa"));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith("don't"));
        }

        ///
        bool ignoreCaseEndsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith("cHa"w));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith("don't"w));
        }

        ///
        bool ignoreCaseEndsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith("cHa"d));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith("don't"d));
        }

        ///
        bool ignoreCaseEndsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(String_ASCII("cHa")));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(String_ASCII("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(String_UTF8("cHa")));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(String_UTF8("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(String_UTF16("cHa"w)));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(String_UTF16("don't"w)));
        }

        ///
        bool ignoreCaseEndsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(String_UTF32("cHa"d)));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(String_UTF32("don't"d)));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_ASCII("cHa")));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_ASCII("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_UTF8("cHa")));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_UTF8("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_UTF16("cHa"w)));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_UTF16("don't"w)));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_UTF32("cHa"d)));
            assert(!typeof(this)("don't cha").ignoreCaseEndsWith(StringBuilder_UTF32("don't"d)));
        }
    }

    @nogc {
        ///
        size_t count(scope const(char)[] toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count("hello"c) == 2);
        }

        ///
        size_t count(scope const(wchar)[] toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count("hello"w) == 2);
        }

        ///
        size_t count(scope const(dchar)[] toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count("hello"d) == 2);
        }

        ///
        size_t count(scope String_ASCII toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(String_ASCII("hello")) == 2);
        }

        ///
        size_t count(scope String_UTF8 toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(String_UTF8("hello"c)) == 2);
        }

        ///
        size_t count(scope String_UTF16 toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(String_UTF16("hello"w)) == 2);
        }

        ///
        size_t count(scope String_UTF32 toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(String_UTF32("hello"d)) == 2);
        }

        ///
        size_t count(scope StringBuilder_ASCII toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(StringBuilder_ASCII("hello")) == 2);
        }

        ///
        size_t count(scope StringBuilder_UTF8 toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(StringBuilder_UTF8("hello"c)) == 2);
        }

        ///
        size_t count(scope StringBuilder_UTF16 toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(StringBuilder_UTF16("hello"w)) == 2);
        }

        ///
        size_t count(scope StringBuilder_UTF32 toFind) scope {
            return state.countImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLohello").count(StringBuilder_UTF32("hello"d)) == 2);
        }

        ///
        size_t ignoreCaseCount(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount("hello"c) == 3);
        }

        ///
        size_t ignoreCaseCount(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount("hello"w) == 3);
        }

        ///
        size_t ignoreCaseCount(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount("hello"d) == 3);
        }

        ///
        size_t ignoreCaseCount(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(String_ASCII("hello")) == 3);
        }

        ///
        size_t ignoreCaseCount(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(String_UTF8("hello"c)) == 3);
        }

        ///
        size_t ignoreCaseCount(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(String_UTF16("hello"w)) == 3);
        }

        ///
        size_t ignoreCaseCount(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(String_UTF32("hello"d)) == 3);
        }

        ///
        size_t ignoreCaseCount(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(StringBuilder_ASCII("hello")) == 3);
        }

        ///
        size_t ignoreCaseCount(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(StringBuilder_UTF8("hello"c)) == 3);
        }

        ///
        size_t ignoreCaseCount(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(StringBuilder_UTF16("hello"w)) == 3);
        }

        ///
        size_t ignoreCaseCount(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.countImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLoHELLO").ignoreCaseCount(StringBuilder_UTF32("hello"d)) == 3);
        }

        ///
        bool contains(scope const(char)[] toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains("hello"c));
        }

        ///
        bool contains(scope const(wchar)[] toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains("hello"w));
        }

        ///
        bool contains(scope const(dchar)[] toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains("hello"d));
        }

        ///
        bool contains(scope String_ASCII toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(String_ASCII("hello")));
        }

        ///
        bool contains(scope String_UTF8 toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(String_UTF8("hello"c)));
        }

        ///
        bool contains(scope String_UTF16 toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(String_UTF16("hello"w)));
        }

        ///
        bool contains(scope String_UTF32 toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(String_UTF32("hello"d)));
        }

        ///
        bool contains(scope StringBuilder_ASCII toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(StringBuilder_ASCII("hello")));
        }

        ///
        bool contains(scope StringBuilder_UTF8 toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(StringBuilder_UTF8("hello"c)));
        }

        ///
        bool contains(scope StringBuilder_UTF16 toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(StringBuilder_UTF16("hello"w)));
        }

        ///
        bool contains(scope StringBuilder_UTF32 toFind) scope {
            return state.containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").contains(StringBuilder_UTF32("hello"d)));
        }

        ///
        bool ignoreCaseContains(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains("hello"c));
        }

        ///
        bool ignoreCaseContains(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains("hello"w));
        }

        ///
        bool ignoreCaseContains(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains("hello"d));
        }

        ///
        bool ignoreCaseContains(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(String_ASCII("hello")));
        }

        ///
        bool ignoreCaseContains(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(String_UTF8("hello"c)));
        }

        ///
        bool ignoreCaseContains(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(String_UTF16("hello"w)));
        }

        ///
        bool ignoreCaseContains(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(String_UTF32("hello"d)));
        }

        ///
        bool ignoreCaseContains(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(StringBuilder_ASCII("hello")));
        }

        ///
        bool ignoreCaseContains(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(StringBuilder_UTF8("hello"c)));
        }

        ///
        bool ignoreCaseContains(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(StringBuilder_UTF16("hello"w)));
        }

        ///
        bool ignoreCaseContains(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.containsImpl(toFind, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseContains(StringBuilder_UTF32("hello"d)));
        }

        ///
        ptrdiff_t indexOf(scope const(char)[] toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf("hello"c) == 5);
        }

        ///
        ptrdiff_t indexOf(scope const(wchar)[] toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf("hello"w) == 5);
        }

        ///
        ptrdiff_t indexOf(scope const(dchar)[] toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf("hello"d) == 5);
        }

        ///
        ptrdiff_t indexOf(scope String_ASCII toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(String_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t indexOf(scope String_UTF8 toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(String_UTF8("hello"c)) == 5);
        }

        ///
        ptrdiff_t indexOf(scope String_UTF16 toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(String_UTF16("hello"w)) == 5);
        }

        ///
        ptrdiff_t indexOf(scope String_UTF32 toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(String_UTF32("hello"d)) == 5);
        }

        ///
        ptrdiff_t indexOf(scope StringBuilder_ASCII toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(StringBuilder_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t indexOf(scope StringBuilder_UTF8 toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(StringBuilder_UTF8("hello"c)) == 5);
        }

        ///
        ptrdiff_t indexOf(scope StringBuilder_UTF16 toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(StringBuilder_UTF16("hello"w)) == 5);
        }

        ///
        ptrdiff_t indexOf(scope StringBuilder_UTF32 toFind) scope {
            return state.offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").indexOf(StringBuilder_UTF32("hello"d)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf("hello"c) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf("hello"w) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf("hello"d) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(String_ASCII("hello")) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(String_UTF8("hello"c)) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(String_UTF16("hello"w)) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(String_UTF32("hello"d)) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(StringBuilder_ASCII("hello")) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(StringBuilder_UTF8("hello"c)) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(StringBuilder_UTF16("hello"w)) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, true, language);
        }

        ///
        unittest {
            assert(typeof(this)("heLLo").ignoreCaseIndexOf(StringBuilder_UTF32("hello"d)) == 0);
        }

        ///
        ptrdiff_t lastIndexOf(scope const(char)[] toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf("hello"c) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope const(wchar)[] toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf("hello"w) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope const(dchar)[] toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf("hello"d) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope String_ASCII toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(String_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope String_UTF8 toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(String_UTF8("hello"c)) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope String_UTF16 toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(String_UTF16("hello"w)) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope String_UTF32 toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(String_UTF32("hello"d)) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope StringBuilder_ASCII toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(StringBuilder_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope StringBuilder_UTF8 toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(StringBuilder_UTF8("hello"c)) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope StringBuilder_UTF16 toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(StringBuilder_UTF16("hello"w)) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope StringBuilder_UTF32 toFind) scope {
            return state.offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(typeof(this)("heLLohello").lastIndexOf(StringBuilder_UTF32("hello"d)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope const(char)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf("hello"c) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope const(wchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf("hello"w) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope const(dchar)[] toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf("hello"d) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope String_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(String_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(String_UTF8("hello"c)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(String_UTF16("hello"w)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope String_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(String_UTF32("hello"d)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_ASCII toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(StringBuilder_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_UTF8 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(StringBuilder_UTF8("hello"c)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_UTF16 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(StringBuilder_UTF16("hello"w)) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_UTF32 toFind, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.offsetOfImpl(toFind, false, false, language);
        }

        ///
        unittest {
            assert(typeof(this)("helloheLLo").ignoreCaseLastIndexOf(StringBuilder_UTF32("hello"d)) == 5);
        }
    }

    // TODO: stripLeft
    // TODO: stripRight

    ///
    void remove(ptrdiff_t index, size_t amount) scope @nogc {
        state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalRemove(iterator, index, amount);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);
            state.externalRemove(iterator, index, amount);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalRemove(iterator, index, amount);
        });
    }

    ///
    unittest {
        typeof(this) builder = "hello world!";

        builder.remove(-1, 2);
        builder.remove(2, 2);

        assert(builder == "heo world");
    }

    @nogc {
        ///
        typeof(this) insert(ptrdiff_t index, scope const(char)[] input...) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, "def"c) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope const(wchar)[] input...) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, "def"w) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope const(dchar)[] input...) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, "def"d) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope String_ASCII input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        @trusted unittest {
            assert(typeof(this)("abc").insert(-1, String_ASCII("def")) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope String_UTF8 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, String_UTF8("def")) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope String_UTF16 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, String_UTF16("def"w)) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope String_UTF32 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, String_UTF32("def"d)) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope StringBuilder_ASCII input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, StringBuilder_ASCII("def")) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope StringBuilder_UTF8 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc"d).insert(-1, StringBuilder_UTF8("def")) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope StringBuilder_UTF16 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, StringBuilder_UTF16("def"w)) == "abdefc");
        }

        ///
        typeof(this) insert(ptrdiff_t index, scope StringBuilder_UTF32 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").insert(-1, StringBuilder_UTF32("def"d)) == "abdefc");
        }
    }

    @nogc {
        ///
        typeof(this) prepend(scope const(char)[] input...) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend("hello "c) == "hello world");
        }

        ///
        typeof(this) prepend(scope const(wchar)[] input...) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend("hello "w) == "hello world");
        }

        ///
        typeof(this) prepend(scope const(dchar)[] input...) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend("hello "d) == "hello world");
        }

        ///
        typeof(this) prepend(scope String_ASCII input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(String_ASCII("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope String_UTF8 input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(String_UTF8("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope String_UTF16 input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(String_UTF16("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope String_UTF32 input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(String_UTF32("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope StringBuilder_ASCII input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(StringBuilder_ASCII("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope StringBuilder_UTF8 input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(StringBuilder_UTF8("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope StringBuilder_UTF16 input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(StringBuilder_UTF16("hello ")) == "hello world");
        }

        ///
        typeof(this) prepend(scope StringBuilder_UTF32 input) scope return @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(typeof(this)("world").prepend(StringBuilder_UTF32("hello ")) == "hello world");
        }
    }

    @nogc {
        ///
        void opOpAssign(string op : "~")(scope const(char)[] input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= " world";
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope const(wchar)[] input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= " world"w;
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope const(dchar)[] input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= " world"d;
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_ASCII input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= String_ASCII(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF8 input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= String_UTF8(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF16 input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= String_UTF16(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF32 input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= String_UTF32(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_ASCII input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= StringBuilder_ASCII(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF8 input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= StringBuilder_UTF8(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF16 input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= StringBuilder_UTF16(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF32 input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            builder ~= StringBuilder_UTF32(" world");
            assert(builder == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope const(char)[] input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ " world") == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope const(wchar)[] input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ " world"w) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope const(dchar)[] input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ " world"d) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope String_ASCII input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ String_ASCII(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope String_UTF8 input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ String_UTF8(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope String_UTF16 input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ String_UTF16(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope String_UTF32 input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ String_UTF32(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope StringBuilder_ASCII input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ StringBuilder_ASCII(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope StringBuilder_UTF8 input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ StringBuilder_UTF8(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope StringBuilder_UTF16 input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ StringBuilder_UTF16(" world")) == "hello world");
        }

        ///
        typeof(this) opBinary(string op : "~")(scope StringBuilder_UTF32 input) scope {
            typeof(this) ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            typeof(this) builder = "hello";
            assert((builder ~ StringBuilder_UTF32(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope const(char)[] input...) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(" world"c) == "hello world");
        }

        ///
        typeof(this) append(scope const(wchar)[] input...) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(" world"w) == "hello world");
        }

        ///
        typeof(this) append(scope const(dchar)[] input...) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(" world"d) == "hello world");
        }

        ///
        typeof(this) append(scope String_ASCII input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(String_ASCII(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope String_UTF8 input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(String_UTF8(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope String_UTF16 input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(String_UTF16(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope String_UTF32 input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(String_UTF32(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope StringBuilder_ASCII input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(StringBuilder_ASCII(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope StringBuilder_UTF8 input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(StringBuilder_UTF8(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope StringBuilder_UTF16 input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(StringBuilder_UTF16(" world")) == "hello world");
        }

        ///
        typeof(this) append(scope StringBuilder_UTF32 input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(typeof(this)("hello").append(StringBuilder_UTF32(" world")) == "hello world");
        }
    }

    @nogc {
        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope const(char)[] input...) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, "def"c) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope const(wchar)[] input...) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, "def"w) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope const(dchar)[] input...) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, "def"d) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope String_ASCII input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        @trusted unittest {
            assert(typeof(this)("abc").clobberInsert(-1, String_ASCII("def")) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope String_UTF8 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, String_UTF8("def")) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope String_UTF16 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, String_UTF16("def"w)) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope String_UTF32 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, String_UTF32("def"d)) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_ASCII input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, StringBuilder_ASCII("def")) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_UTF8 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc"d).clobberInsert(-1, StringBuilder_UTF8("def")) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_UTF16 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, StringBuilder_UTF16("def"w)) == "abdef");
        }

        ///
        typeof(this) clobberInsert(ptrdiff_t index, scope StringBuilder_UTF32 input) scope return {
            state.setup(Char.sizeof);
            state.insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(typeof(this)("abc").clobberInsert(-1, StringBuilder_UTF32("def"d)) == "abdef");
        }
    }

    @nogc {
        ///
        size_t replace(scope String_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            typeof(this) builder = typeof(this)("its a lala world");
            size_t count = builder.replace(String_ASCII("la"), String_ASCII("woof"));
            assert(count == 2);
            assert(builder == "its a woofwoof world");
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), "woof"c) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), "woof"w) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), "woof"d) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(String_ASCII("la"), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, "woof"c) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, "woof"w) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, "woof"d) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"c, StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, "woof"c) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, "woof"w) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, "woof"d) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"w, StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, "woof"c) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, "woof"w) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, "woof"d) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace("la"d, StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return state.replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(typeof(this)("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_UTF32("woof"d)) == 2);
        }
    }

    ///
    ulong toHash() scope @trusted @nogc {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();

        foreachContiguous((scope ref data) { ret = hashOf(data, ret); return 0; });

        return ret;
    }

package(sidero.base.text.unicode):
    StateIterator state;

    int foreachContiguous(scope int delegate(ref scope Char[] data) @safe nothrow @nogc del,
            scope void delegate(size_t length) @safe nothrow @nogc lengthDel = null) scope @nogc {
        return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);

            state.OtherStateIsUs!Char osiu;
            osiu.state = state;
            osiu.iterator = iterator;

            osiu.mutex(true);

            if (lengthDel !is null)
                lengthDel(osiu.length());
            int result = osiu.foreachContiguous(del);

            osiu.mutex(false);
            return result;
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);

            state.OtherStateIsUs!Char osiu;
            osiu.state = state;
            osiu.iterator = iterator;

            osiu.mutex(true);

            if (lengthDel !is null)
                lengthDel(osiu.length());
            int result = osiu.foreachContiguous(del);

            osiu.mutex(false);
            return result;
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);

            state.OtherStateIsUs!Char osiu;
            osiu.state = state;
            osiu.iterator = iterator;

            osiu.mutex(true);

            if (lengthDel !is null)
                lengthDel(osiu.length());
            int result = osiu.foreachContiguous(del);

            osiu.mutex(false);
            return result;
        }, () { return 0; });
    }
}
