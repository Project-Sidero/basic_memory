module sidero.base.text.unicode.builder;
import sidero.base.text.unicode.characters.database : UnicodeLanguage;
import sidero.base.text;
import sidero.base.allocators.api;

export:

///
struct StringBuilder_UTF(Char_) {
    ///
    alias Char = Char_;
    ///
    alias LiteralType = immutable(Char)[];

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            StateIterator oldState = this.state;

            state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
                assert(state !is null);
                iterator = state.newIterator(iterator);
            }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
                assert(state !is null);
                iterator = state.newIterator(iterator);
            }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
                assert(state !is null);
                iterator = state.newIterator(iterator);
            });

            scope (exit) {
                state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
                    assert(state !is null);
                    state.rcIterator(false, iterator);
                }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
                    assert(state !is null);
                    state.rcIterator(false, iterator);
                }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
                    assert(state !is null);
                    state.rcIterator(false, iterator);
                });

                this.state = oldState;
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

            StateIterator oldState = this.state;

            state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);
                iterator = state.newIterator(iterator);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);
                iterator = state.newIterator(iterator);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);
                iterator = state.newIterator(iterator);
            });

            scope (exit) {
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

                this.state = oldState;
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

        void construct(InputChar)(scope const(InputChar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
        .init) {
            setupState(allocator);

            if (input.length > 0) {
                state.handle((StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
                    assert(state !is null);

                    LiteralAsTargetChar!(InputChar, char) latc;
                    latc.literal = input;
                    auto osat = latc.get;

                    state.language = language;
                    assert(osat.length() > 0);
                    state.externalInsert(iterator, 0, osat, false);
                    assert(osat.length() > 0);
                }, (StateIterator.S16 state, StateIterator.I16 iterator) @trusted {
                    assert(state !is null);

                    LiteralAsTargetChar!(InputChar, wchar) latc;
                    latc.literal = input;
                    auto osat = latc.get;

                    state.language = language;
                    state.externalInsert(iterator, 0, osat, false);
                }, (StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
                    assert(state !is null);

                    LiteralAsTargetChar!(InputChar, dchar) latc;
                    latc.literal = input;
                    auto osat = latc.get;

                    state.language = language;
                    state.externalInsert(iterator, 0, osat, false);
                });
            }
        }

        void construct(Char2)(scope String_UTF!Char2 input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
            input.stripZeroTerminator;

            input.literalEncoding.handle(() { this.__ctor(cast(const(char)[])input.literal, allocator, input.language); }, () {
                this.__ctor(cast(const(wchar)[])input.literal, allocator, input.language);
            }, () { this.__ctor(cast(const(dchar)[])input.literal, allocator, input.language); }, () {
                this.__ctor(LiteralType.init, allocator);
            });
        }
    }

export:
    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        static Text = cast(LiteralType)"Hello there!";
        StringBuilder_UTF text = StringBuilder_UTF(Text);

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
        StringBuilder_UTF text = StringBuilder_UTF(Text);

        size_t lastIndex = Text.length;

        foreach_reverse (c; text) {
            assert(lastIndex > 0);
            lastIndex--;
            assert(Text[lastIndex] == c);
        }

        assert(lastIndex == 0);
    }

nothrow @safe:

    void opAssign(ref StringBuilder_UTF other) @nogc {
        __ctor(other);
    }

    void opAssign(StringBuilder_UTF other) @nogc {
        __ctor(other);
    }

    @disable void opAssign(ref StringBuilder_UTF other) const;
    @disable void opAssign(StringBuilder_UTF other) const;

    @disable auto opCast(T)();

    this(ref return scope StringBuilder_UTF other) @trusted scope @nogc {
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

    @disable this(ref return scope StringBuilder_UTF other) @safe scope const;

    @disable this(ref const StringBuilder_UTF other) const;
    @disable this(this);

    ///
    this(RCAllocator allocator) scope @nogc {
        this.__ctor(LiteralType.init, allocator);
    }

    ///
    this(RCAllocator allocator, scope const(char)[] input...) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope const(wchar)[] input...) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope const(dchar)[] input...) scope @nogc {
        this.__ctor(input, allocator);
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

                StringBuilder_UTF builder = StringBuilder_UTF(RCAllocator.init, input);

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

                StringBuilder_UTF builder = StringBuilder_UTF(RCAllocator.init, input);

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

                StringBuilder_UTF builder = StringBuilder_UTF(RCAllocator.init, input);

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

        assert(StringBuilder_UTF(RCAllocator.init, String_ASCII(Text8)).length == Text8.length);
    }

    ///
    this(RCAllocator allocator, scope String_UTF!char input = String_UTF!char.init) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope String_UTF!wchar input = String_UTF!wchar.init) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    this(RCAllocator allocator, scope String_UTF!dchar input = String_UTF!dchar.init) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    unittest {
        static Text = cast(LiteralType)"it is negilible";

        assert(StringBuilder_UTF(RCAllocator.init, String_UTF!Char(Text)).length == Text.length);
    }

    ///
    this(scope const(char)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
            .init) {
        this.construct(input, allocator, language);
    }

    ///
    this(scope const(wchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
    .init) {
        this.construct(input, allocator, language);
    }

    ///
    this(scope const(dchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage
    .init) {
        this.construct(input, allocator, language);
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

                StringBuilder_UTF builder = StringBuilder_UTF(input);

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

                StringBuilder_UTF builder = StringBuilder_UTF(input);

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

                StringBuilder_UTF builder = StringBuilder_UTF(input);

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

        this.__ctor(cast(const(char)[])input.literal, allocator);
    }

    ///
    unittest {
        static Text8 = "it is negilible";

        assert(StringBuilder_UTF(String_ASCII(Text8)).length == Text8.length);
    }

    ///
    this(scope String_UTF!char input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        this.construct(input, allocator);
    }

    ///
    this(scope String_UTF!wchar input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        this.construct(input, allocator);
    }

    ///
    this(scope String_UTF!dchar input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        this.construct(input, allocator);
    }

    ///
    unittest {
        static Text = cast(LiteralType)"it is negilible";

        assert(StringBuilder_UTF(String_UTF!Char(Text)).length == Text.length);
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
        return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return state.externalLength(iterator) == 0 || (iterator !is null && iterator.empty);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return state.externalLength(iterator) == 0 || (iterator !is null && iterator.empty);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return state.externalLength(iterator) == 0 || (iterator !is null && iterator.empty);
        }, () { return true; });
    }

    ///
    unittest {
        StringBuilder_UTF stuff;
        assert(stuff.isNull);

        stuff = StringBuilder_UTF("Abc");
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
        StringBuilder_UTF thing = StringBuilder_UTF("bar");
        assert(!thing.haveIterator);

        assert(!thing.empty);
        thing.popFront;

        assert(thing.haveIterator);
    }

    ///
    StringBuilder_UTF withoutIterator() scope @trusted @nogc {
        StringBuilder_UTF ret;

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
        StringBuilder_UTF stuff = StringBuilder_UTF("I have no iterator!");
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
    StringBuilder_UTF opIndex(ptrdiff_t index) scope @nogc {
        ptrdiff_t end = index < 0 ? ptrdiff_t.max : index + 1;
        return this[index .. end];
    }

    ///
    StringBuilder_UTF opSlice() scope @trusted {
        if (isNull)
            return StringBuilder_UTF();

        StringBuilder_UTF ret;

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
    unittest {
        static Text = cast(LiteralType)"goods";

        StringBuilder_UTF str = Text;
        assert(!str.haveIterator);

        StringBuilder_UTF sliced = str[];
        assert(sliced.haveIterator);
        assert(sliced.length == Text.length);
    }

    ///
    StringBuilder_UTF opSlice(ptrdiff_t start, ptrdiff_t end) scope @nogc {
        StringBuilder_UTF ret;

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
            StringBuilder_UTF original = StringBuilder_UTF("split me here");
            StringBuilder_UTF split = original[6 .. 8];

            assert(split.length == 2);
        } else static if (is(Char == wchar)) {
            StringBuilder_UTF original = StringBuilder_UTF("split me here"w);
            StringBuilder_UTF split = original[6 .. 8];

            assert(split.length == 2);
        } else static if (is(Char == dchar)) {
            StringBuilder_UTF original = StringBuilder_UTF("split me here"d);
            StringBuilder_UTF split = original[6 .. 8];

            assert(split.length == 2);
        }
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope @nogc {
        return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return state.externalLength(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return state.externalLength(iterator);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return state.externalLength(iterator);
        }, () { return 0; });
    }

    ///
    unittest {
        StringBuilder_UTF stack = StringBuilder_UTF(cast(LiteralType)"hmm...");
        assert(stack.length == 6);
    }

    ///
    StringBuilder_UTF dup(RCAllocator allocator = RCAllocator.init) scope @nogc {
        StringBuilder_UTF ret = StringBuilder_UTF(allocator);
        ret.insertImpl(this);
        return ret;
    }

    ///
    unittest {
        static Text = cast(LiteralType)"can't be done.";

        StringBuilder_UTF builder = StringBuilder_UTF(Text);
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
        String_UTF!Char readOnly = StringBuilder_UTF(Text).asReadOnly();

        assert(readOnly.length == 16);
        assert((cast(LiteralType)readOnly.literal).length == 17);
        assert(readOnly == Text);
    }

    @nogc {
        ///
        StringBuilder_UTF normalize(bool compatibility, bool composition, UnicodeLanguage language) scope @trusted {
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
        StringBuilder_UTF toNFD(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(false, false, language);
        }

        ///
        StringBuilder_UTF toNFC(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(false, true, language);
        }

        ///
        StringBuilder_UTF toNFKD(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return this.normalize(true, false, language);
        }

        ///
        StringBuilder_UTF toNFKC(UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
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
            StringBuilder_UTF first = StringBuilder_UTF(cast(LiteralType)"first");
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
            StringBuilder_UTF first = StringBuilder_UTF(cast(LiteralType)"first");
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
            StringBuilder_UTF first = StringBuilder_UTF(cast(LiteralType)"first");
            StringBuilder_ASCII notFirst = StringBuilder_ASCII("first");
            StringBuilder_ASCII third = StringBuilder_ASCII("third");

            assert(first == notFirst);
            assert(first != third);
        }

        ///
        bool opEquals(scope StringBuilder_UTF!char other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope StringBuilder_UTF!wchar other) scope {
            return opCmp(other) == 0;
        }

        ///
        bool opEquals(scope StringBuilder_UTF!dchar other) scope {
            return opCmp(other) == 0;
        }

        ///
        unittest {
            StringBuilder_UTF first = StringBuilder_UTF(cast(LiteralType)"first");
            StringBuilder_UTF notFirst = StringBuilder_UTF(cast(LiteralType)"first");
            StringBuilder_UTF third = StringBuilder_UTF(cast(LiteralType)"third");

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
        bool ignoreCaseEquals(scope StringBuilder_UTF!char other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope StringBuilder_UTF!wchar other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }

        ///
        bool ignoreCaseEquals(scope StringBuilder_UTF!dchar other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return ignoreCaseCompare(other, language) == 0;
        }
    }

    ///
    alias compare = opCmp;

    @nogc {
        ///
        int opCmp(scope const(char)[] other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"a").opCmp("z") < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"z").opCmp("a") > 0);
        }

        ///
        int opCmp(scope const(wchar)[] other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"a").opCmp("z"w) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"z").opCmp("a"w) > 0);
        }

        ///
        int opCmp(scope const(dchar)[] other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"a").opCmp("z"d) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"z").opCmp("a"d) > 0);
        }

        ///
        int opCmp(scope String_ASCII other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a").opCmp(String_ASCII("z")) < 0);
            assert(StringBuilder_UTF("z").opCmp(String_ASCII("a")) > 0);
        }

        ///
        int opCmp(scope String_UTF8 other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a").opCmp(String_UTF8("z")) < 0);
            assert(StringBuilder_UTF("z").opCmp(String_UTF8("a")) > 0);
        }

        ///
        int opCmp(scope String_UTF16 other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a"w).opCmp(String_UTF16("z"w)) < 0);
            assert(StringBuilder_UTF("z"w).opCmp(String_UTF16("a"w)) > 0);
        }

        ///
        int opCmp(scope String_UTF32 other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a"d).opCmp(String_UTF32("z"d)) < 0);
            assert(StringBuilder_UTF("z"d).opCmp(String_UTF32("a"d)) > 0);
        }

        ///
        int opCmp(scope StringBuilder_ASCII other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a").opCmp(StringBuilder_ASCII("z")) < 0);
            assert(StringBuilder_UTF("z").opCmp(StringBuilder_ASCII("a")) > 0);
        }

        ///
        int opCmp(scope StringBuilder_UTF!char other) scope {
            return opCmpImpl(other, true);
        }

        ///
        int opCmp(scope StringBuilder_UTF!wchar other) scope {
            return opCmpImpl(other, true);
        }

        ///
        int opCmp(scope StringBuilder_UTF!dchar other) scope {
            return opCmpImpl(other, true);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a"d).opCmp(StringBuilder_UTF("z"d)) < 0);
            assert(StringBuilder_UTF("z"d).opCmp(StringBuilder_UTF("a"d)) > 0);
        }
    }

    @nogc {
        ///
        int ignoreCaseCompare(scope const(char)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"A").ignoreCaseCompare("z") < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"Z").ignoreCaseCompare("a") > 0);
        }

        ///
        int ignoreCaseCompare(scope const(wchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"A").ignoreCaseCompare("z"w) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"Z").ignoreCaseCompare("a"w) > 0);
        }

        ///
        int ignoreCaseCompare(scope const(dchar)[] other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"A").ignoreCaseCompare("z"d) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"Z").ignoreCaseCompare("a"d) > 0);
        }

        ///
        int ignoreCaseCompare(scope String_UTF8 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope String_UTF16 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope String_UTF32 other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"a").ignoreCaseCompare(String_UTF!Char(cast(LiteralType)"Z")) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"Z").ignoreCaseCompare(String_UTF!Char(cast(LiteralType)"a")) > 0);
        }

        ///
        int ignoreCaseCompare(scope String_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"a").ignoreCaseCompare(String_ASCII("Z")) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"Z").ignoreCaseCompare(String_ASCII("a")) > 0);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_ASCII other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF(cast(LiteralType)"a").ignoreCaseCompare(StringBuilder_ASCII("Z")) < 0);
            assert(StringBuilder_UTF(cast(LiteralType)"Z").ignoreCaseCompare(StringBuilder_ASCII("a")) > 0);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_UTF!char other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_UTF!wchar other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        int ignoreCaseCompare(scope StringBuilder_UTF!dchar other, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return opCmpImpl(other, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("a"d).ignoreCaseCompare(StringBuilder_UTF("Z"d)) < 0);
            assert(StringBuilder_UTF("Z"d).ignoreCaseCompare(StringBuilder_UTF("a"d)) > 0);
        }
    }

    ///
    alias put = append;

    ///
    bool empty() scope @nogc {
        return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return iterator is null ? (this.length == 0) : iterator.emptyUTF;
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return iterator is null ? (this.length == 0) : iterator.emptyUTF;
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return iterator is null ? (this.length == 0) : iterator.emptyUTF;
        }, () { return true; });
    }

    ///
    unittest {
        StringBuilder_UTF thing;
        assert(thing.empty);

        thing = StringBuilder_UTF(cast(LiteralType)"bar");
        assert(!thing.empty);
    }

    ///
    Char front() scope @nogc {
        return state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            return iterator.frontUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            return iterator.frontUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            return iterator.frontUTF!Char;
        }, () { assert(0); });
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        StringBuilder_UTF text = StringBuilder_UTF(Text8);
        foreach (i, c; Text8) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);

        text = StringBuilder_UTF(Text16);
        foreach (i, c; Text16) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }
        assert(text.empty);

        text = StringBuilder_UTF(Text32);
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
        return state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            return iterator.backUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            return iterator.backUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            return iterator.backUTF!Char;
        }, () { assert(0); });
    }

    ///
    unittest {
        static Text8 = "ok it's a live";
        static Text16 = "I'm up to the"w;
        static Text32 = "walls can't talk"d;

        StringBuilder_UTF text = StringBuilder_UTF(Text8);

        foreach_reverse (i, c; Text8) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);

        text = StringBuilder_UTF(Text16);
        foreach_reverse (i, c; Text16) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }
        assert(text.empty);

        text = StringBuilder_UTF(Text32);
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
        state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            iterator.popFrontUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            iterator.popFrontUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            iterator.popFrontUTF!Char;
        }, () { assert(0); });
    }

    ///
    void popBack() scope @nogc {
        state.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            iterator.popBackUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            iterator.popBackUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null) {
                iterator = state.newIterator();
                state.rc(false);
            }

            iterator.popBackUTF!Char;
        }, () { assert(0); });
    }

    ///
    StringBuilder_UTF!char byUTF8() @trusted scope @nogc {
        StringBuilder_UTF!char ret;
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

        StringBuilder_UTF text = StringBuilder_UTF(Text8);
        assert(text.length == text.byUTF8().length);

        text = StringBuilder_UTF(Text16);
        assert(text.length == text.byUTF8().length);

        text = StringBuilder_UTF(Text32);
        assert(text.length == text.byUTF8().length);
    }

    ///
    StringBuilder_UTF!wchar byUTF16() @trusted scope @nogc {
        StringBuilder_UTF!wchar ret;
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

        StringBuilder_UTF text = StringBuilder_UTF(Text8);
        assert(text.length == text.byUTF16().length);

        text = StringBuilder_UTF(Text16);
        assert(text.length == text.byUTF16().length);

        text = StringBuilder_UTF(Text32);
        assert(text.length == text.byUTF16().length);
    }

    ///
    StringBuilder_UTF!dchar byUTF32() @trusted scope @nogc {
        StringBuilder_UTF!dchar ret;
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

        StringBuilder_UTF text = StringBuilder_UTF(Text8);
        assert(text.length == text.byUTF32().length);

        text = StringBuilder_UTF(Text16);
        assert(text.length == text.byUTF32().length);

        text = StringBuilder_UTF(Text32);
        assert(text.length == text.byUTF32().length);
    }

    @nogc {
        ///
        bool startsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith("don't"));
            assert(!StringBuilder_UTF("don't cha").startsWith("cha"));
        }

        ///
        bool startsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith("don't"w));
            assert(!StringBuilder_UTF("don't cha").startsWith("cha"w));
        }

        ///
        bool startsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith("don't"d));
            assert(!StringBuilder_UTF("don't cha").startsWith("cha"d));
        }

        ///
        bool startsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(String_ASCII("don't")));
            assert(!StringBuilder_UTF("don't cha").startsWith(String_ASCII("cha")));
        }

        ///
        bool startsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(String_UTF8("don't")));
            assert(!StringBuilder_UTF("don't cha").startsWith(String_UTF8("cha")));
        }

        ///
        bool startsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(String_UTF16("don't"w)));
            assert(!StringBuilder_UTF("don't cha").startsWith(String_UTF16("cha"w)));
        }

        ///
        bool startsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(String_UTF32("don't"d)));
            assert(!StringBuilder_UTF("don't cha").startsWith(String_UTF32("cha"d)));
        }

        ///
        bool startsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(StringBuilder_ASCII("don't")));
            assert(!StringBuilder_UTF("don't cha").startsWith(StringBuilder_ASCII("cha")));
        }

        ///
        bool startsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(StringBuilder_UTF8("don't")));
            assert(!StringBuilder_UTF("don't cha").startsWith(StringBuilder_UTF8("cha")));
        }

        ///
        bool startsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(StringBuilder_UTF16("don't"w)));
            assert(!StringBuilder_UTF("don't cha").startsWith(StringBuilder_UTF16("cha"w)));
        }

        ///
        bool startsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").startsWith(StringBuilder_UTF32("don't"d)));
            assert(!StringBuilder_UTF("don't cha").startsWith(StringBuilder_UTF32("cha"d)));
        }
    }

    @nogc {
        ///
        bool ignoreCaseStartsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith("dOn't"));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith("cha"));
        }

        ///
        bool ignoreCaseStartsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith("dOn't"w));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith("cha"w));
        }

        ///
        bool ignoreCaseStartsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith("dOn't"d));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith("cha"d));
        }

        ///
        bool ignoreCaseStartsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_ASCII("dOn't")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_ASCII("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_UTF8("dOn't")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_UTF8("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_UTF16("dOn't"w)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_UTF16("cha"w)));
        }

        ///
        bool ignoreCaseStartsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_UTF32("dOn't"d)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(String_UTF32("cha"d)));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_ASCII("dOn't")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_ASCII("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_UTF8("dOn't")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_UTF8("cha")));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_UTF16("dOn't"w)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_UTF16("cha"w)));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return startsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_UTF32("dOn't"d)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseStartsWith(StringBuilder_UTF32("cha"d)));
        }
    }

    @nogc {
        ///
        bool endsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith("cha"));
            assert(!StringBuilder_UTF("don't cha").endsWith("don't"));
        }

        ///
        bool endsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith("cha"w));
            assert(!StringBuilder_UTF("don't cha").endsWith("don't"w));
        }

        ///
        bool endsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith("cha"d));
            assert(!StringBuilder_UTF("don't cha").endsWith("don't"d));
        }

        ///
        bool endsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(String_ASCII("cha")));
            assert(!StringBuilder_UTF("don't cha").endsWith(String_ASCII("don't")));
        }

        ///
        bool endsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(String_UTF8("cha")));
            assert(!StringBuilder_UTF("don't cha").endsWith(String_UTF8("don't")));
        }

        ///
        bool endsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(String_UTF16("cha"w)));
            assert(!StringBuilder_UTF("don't cha").endsWith(String_UTF16("don't"w)));
        }

        ///
        bool endsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(String_UTF32("cha"d)));
            assert(!StringBuilder_UTF("don't cha").endsWith(String_UTF32("don't"d)));
        }

        ///
        bool endsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(StringBuilder_ASCII("cha")));
            assert(!StringBuilder_UTF("don't cha").endsWith(StringBuilder_ASCII("don't")));
        }

        ///
        bool endsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(StringBuilder_UTF8("cha")));
            assert(!StringBuilder_UTF("don't cha").endsWith(StringBuilder_UTF8("don't")));
        }

        ///
        bool endsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(StringBuilder_UTF16("cha"w)));
            assert(!StringBuilder_UTF("don't cha").endsWith(StringBuilder_UTF16("don't"w)));
        }

        ///
        bool endsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, true, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").endsWith(StringBuilder_UTF32("cha"d)));
            assert(!StringBuilder_UTF("don't cha").endsWith(StringBuilder_UTF32("don't"d)));
        }
    }

    @nogc {
        ///
        bool ignoreCaseEndsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith("cHa"));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith("don't"));
        }

        ///
        bool ignoreCaseEndsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith("cHa"w));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith("don't"w));
        }

        ///
        bool ignoreCaseEndsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith("cHa"d));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith("don't"d));
        }

        ///
        bool ignoreCaseEndsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_ASCII("cHa")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_ASCII("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_UTF8("cHa")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_UTF8("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_UTF16("cHa"w)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_UTF16("don't"w)));
        }

        ///
        bool ignoreCaseEndsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_UTF32("cHa"d)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(String_UTF32("don't"d)));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_ASCII("cHa")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_ASCII("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_UTF8("cHa")));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_UTF8("don't")));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_UTF16("cHa"w)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_UTF16("don't"w)));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return endsWithImpl(input, false, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_UTF32("cHa"d)));
            assert(!StringBuilder_UTF("don't cha").ignoreCaseEndsWith(StringBuilder_UTF32("don't"d)));
        }
    }

    // TODO: count
    // TODO: ignoreCaseCount
    // TODO: contains
    // TODO: ignoreCaseContains
    // TODO: indexOf
    // TODO: caseIgnoreIndexOf
    // TODO: lastIndexOf
    // TODO: caseIgnoreLastIndexOf
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
        StringBuilder_UTF builder = "hello world!";

        builder.remove(-1, 2);
        builder.remove(2, 2);

        assert(builder == "heo world");
    }

    @nogc {
        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope const(char)[] input...) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, "def"c) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope const(wchar)[] input...) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, "def"w) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope const(dchar)[] input...) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, "def"d) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope String_ASCII input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        @trusted unittest {
            assert(StringBuilder_UTF("abc").insert(-1, String_ASCII("def")) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope String_UTF8 input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, String_UTF8("def")) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope String_UTF16 input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, String_UTF16("def"w)) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope String_UTF32 input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, String_UTF32("def"d)) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_ASCII input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, StringBuilder_ASCII("def")) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_UTF8 input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc"d).insert(-1, StringBuilder_UTF8("def")) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_UTF16 input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, StringBuilder_UTF16("def"w)) == "abdefc");
        }

        ///
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_UTF32 input) scope return {
            insertImpl(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").insert(-1, StringBuilder_UTF32("def"d)) == "abdefc");
        }
    }

    @nogc {
        ///
        StringBuilder_UTF prepend(scope const(char)[] input...) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend("hello "c) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope const(wchar)[] input...) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend("hello "w) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope const(dchar)[] input...) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend("hello "d) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope String_ASCII input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(String_ASCII("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope String_UTF8 input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(String_UTF8("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope String_UTF16 input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(String_UTF16("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope String_UTF32 input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(String_UTF32("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope StringBuilder_ASCII input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(StringBuilder_ASCII("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope StringBuilder_UTF8 input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(StringBuilder_UTF8("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope StringBuilder_UTF16 input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(StringBuilder_UTF16("hello ")) == "hello world");
        }

        ///
        StringBuilder_UTF prepend(scope StringBuilder_UTF32 input) scope return {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("world").prepend(StringBuilder_UTF32("hello ")) == "hello world");
        }
    }

    @nogc {
        ///
        void opOpAssign(string op : "~")(scope const(char)[] input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= " world";
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope const(wchar)[] input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= " world"w;
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope const(dchar)[] input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= " world"d;
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_ASCII input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= String_ASCII(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF8 input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= String_UTF8(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF16 input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= String_UTF16(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF32 input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= String_UTF32(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_ASCII input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= StringBuilder_ASCII(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF8 input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= StringBuilder_UTF8(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF16 input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= StringBuilder_UTF16(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF32 input) scope return {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            builder ~= StringBuilder_UTF32(" world");
            assert(builder == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope const(char)[] input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ " world") == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope const(wchar)[] input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ " world"w) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope const(dchar)[] input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ " world"d) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope String_ASCII input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ String_ASCII(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope String_UTF8 input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ String_UTF8(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope String_UTF16 input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ String_UTF16(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope String_UTF32 input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ String_UTF32(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_ASCII input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ StringBuilder_ASCII(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_UTF8 input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ StringBuilder_UTF8(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_UTF16 input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ StringBuilder_UTF16(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_UTF32 input) scope {
            StringBuilder_UTF ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_UTF builder = "hello";
            assert((builder ~ StringBuilder_UTF32(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope const(char)[] input...) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(" world"c) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope const(wchar)[] input...) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(" world"w) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope const(dchar)[] input...) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(" world"d) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope String_ASCII input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(String_ASCII(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope String_UTF8 input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(String_UTF8(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope String_UTF16 input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(String_UTF16(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope String_UTF32 input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(String_UTF32(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope StringBuilder_ASCII input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(StringBuilder_ASCII(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope StringBuilder_UTF8 input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(StringBuilder_UTF8(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope StringBuilder_UTF16 input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(StringBuilder_UTF16(" world")) == "hello world");
        }

        ///
        StringBuilder_UTF append(scope StringBuilder_UTF32 input) scope return {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("hello").append(StringBuilder_UTF32(" world")) == "hello world");
        }
    }

    @nogc {
        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope const(char)[] input...) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, "def"c) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope const(wchar)[] input...) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, "def"w) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope const(dchar)[] input...) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, "def"d) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_ASCII input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        @trusted unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, String_ASCII("def")) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_UTF8 input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, String_UTF8("def")) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_UTF16 input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, String_UTF16("def"w)) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_UTF32 input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, String_UTF32("def"d)) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_ASCII input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, StringBuilder_ASCII("def")) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_UTF8 input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc"d).clobberInsert(-1, StringBuilder_UTF8("def")) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_UTF16 input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, StringBuilder_UTF16("def"w)) == "abdef");
        }

        ///
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_UTF32 input) scope return {
            insertImpl(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_UTF("abc").clobberInsert(-1, StringBuilder_UTF32("def"d)) == "abdef");
        }
    }

    @nogc {
        ///
        size_t replace(scope String_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            StringBuilder_UTF builder = StringBuilder_UTF("its a lala world");
            size_t count = builder.replace(String_ASCII("la"), String_ASCII("woof"));
            assert(count == 2);
            assert(builder == "its a woofwoof world");
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), "woof"c) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), "woof"w) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), "woof"d) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(String_ASCII("la"), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, "woof"c) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, "woof"w) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, "woof"d) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"c, StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, "woof"c) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, "woof"w) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, "woof"d) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"w, StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, "woof"c) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, "woof"w) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, "woof"d) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace("la"d, StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF8("la"), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF16("la"w), StringBuilder_UTF32("woof"d)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), "woof"c) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), "woof"w) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), "woof"d) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_UTF8("woof"c)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_UTF16("woof"w)) == 2);
        }

        ///
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce, language);
        }

        ///
        unittest {
            assert(StringBuilder_UTF("its a lala world").replace(StringBuilder_UTF32("la"d), StringBuilder_UTF32("woof"d)) == 2);
        }
    }

    ///
    ulong toHash() scope @trusted @nogc {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();

        foreachContiguous((scope ref data) { ret = hashOf(data, ret); return 0; });

        return ret;
    }

package(sidero.base.text):
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

private:
    StateIterator state;

    void setupState(RCAllocator allocator = RCAllocator.init) @nogc {
        if (allocator.isNull)
            allocator = globalAllocator();

        if (state.encoding.codepointSize == 0)
            state.encoding.codepointSize = Char.sizeof * 8;

        state.handle((ref StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
            if (state is null)
                state = allocator.make!(typeof(*state))(allocator);
        }, (ref StateIterator.S16 state, StateIterator.I16 iterator) @trusted {
            if (state is null)
                state = allocator.make!(typeof(*state))(allocator);
        }, (ref StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
            if (state is null)
                state = allocator.make!(typeof(*state))(allocator);
        });
    }

    @disable void setupState(RCAllocator allocator = RCAllocator.init) const @nogc;

    void debugPosition() @nogc {
        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);

            state.debugPosition(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) { assert(state !is null); state.debugPosition(iterator); },
                (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);

            state.debugPosition(iterator);
        }, () { assert(0); });
    }

    scope @nogc {
        int opCmpImpl(Other)(scope Other other, bool caseSensitive, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            scope otherState = AnyAsTargetChar!dchar(other);

            if (other.length == 0)
                return this.length == 0 ? 0 : 1;

            return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);
                return state.externalOpCmp(iterator, otherState.osat, caseSensitive, language);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);
                return state.externalOpCmp(iterator, otherState.osat, caseSensitive, language);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);
                return state.externalOpCmp(iterator, otherState.osat, caseSensitive, language);
            }, () {
                if (other.length > 0)
                    return -1;
                else
                    return 0;
            });
        }

        void insertImpl(Other)(scope Other other, ptrdiff_t offset = 0, bool clobber = false) {
            setupState;

            if (other.length == 0)
                return;

            state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);
                scope otherState = AnyAsTargetChar!char(other);
                state.externalInsert(iterator, offset, otherState.osat, clobber);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);
                scope otherState = AnyAsTargetChar!wchar(other);
                state.externalInsert(iterator, offset, otherState.osat, clobber);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);
                scope otherState = AnyAsTargetChar!dchar(other);
                state.externalInsert(iterator, offset, otherState.osat, clobber);
            });
        }

        bool startsWithImpl(Other)(scope Other other, bool caseSensitive, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            scope otherState = AnyAsTargetChar!dchar(other);

            return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);
                return state.externalStartsWith(iterator, otherState.osat, caseSensitive, language);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);
                return state.externalStartsWith(iterator, otherState.osat, caseSensitive, language);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);
                return state.externalStartsWith(iterator, otherState.osat, caseSensitive, language);
            }, () { return false; });
        }

        bool endsWithImpl(Other)(scope Other other, bool caseSensitive, UnicodeLanguage language = UnicodeLanguage.Unknown) {
            scope otherState = AnyAsTargetChar!dchar(other);

            return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);
                return state.externalEndsWith(iterator, otherState.osat, caseSensitive, language);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);
                return state.externalEndsWith(iterator, otherState.osat, caseSensitive, language);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);
                return state.externalEndsWith(iterator, otherState.osat, caseSensitive, language);
            }, () { return false; });
        }

        size_t replaceImpl(ToFind, ToReplace)(scope ToFind toFind, scope ToReplace toReplace, bool caseSensitive,
                bool onlyOnce, UnicodeLanguage language) {
            if (isNull)
                return 0;

            scope toFindState = AnyAsTargetChar!dchar(toFind);

            return state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);

                scope toReplaceState = AnyAsTargetChar!char(toReplace);
                return state.externalReplace(iterator, toFindState.osat, toReplaceState.osat, caseSensitive, onlyOnce, language);
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);

                scope toReplaceState = AnyAsTargetChar!wchar(toReplace);
                return state.externalReplace(iterator, toFindState.osat, toReplaceState.osat, caseSensitive, onlyOnce, language);
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);

                scope toReplaceState = AnyAsTargetChar!dchar(toReplace);
                return state.externalReplace(iterator, toFindState.osat, toReplaceState.osat, caseSensitive, onlyOnce, language);
            }, () { return 0; });
        }
    }
}

private:
import sidero.base.text.internal.builder.operations;

struct StateIterator {
    import sidero.base.text.unicode.defs;

    UnicodeEncoding encoding;

    alias S8 = typeof(u8);
    alias S16 = typeof(u16);
    alias S32 = typeof(u32);
    alias I8 = typeof(i8);
    alias I16 = typeof(i16);
    alias I32 = typeof(i32);

    union {
        struct {
            UTF_State!char* u8;
            typeof(u8).Iterator* i8;
        }

        struct {
            UTF_State!wchar* u16;
            typeof(u16).Iterator* i16;
        }

        struct {
            UTF_State!dchar* u32;
            typeof(u32).Iterator* i32;
        }
    }

scope nothrow @nogc:

    ///
    auto handle(T, U, V)(scope T utf8Del, scope U utf16Del, scope V utf32Del) @trusted {
        assert(utf8Del !is null);
        assert(utf16Del !is null);
        assert(utf32Del !is null);

        if (encoding.codepointSize == 8)
            return utf8Del(u8, i8);
        else if (encoding.codepointSize == 16)
            return utf16Del(u16, i16);
        else if (encoding.codepointSize == 32)
            return utf32Del(u32, i32);
        else static if (!is(typeof(return) == void))
            return typeof(return).init;
    }

    ///
    auto handle(T, U, V, W)(scope T utf8Del, scope U utf16Del, scope V utf32Del, scope W nullDel) @trusted {
        import std.traits : ReturnType;

        assert(utf8Del !is null);
        assert(utf16Del !is null);
        assert(utf32Del !is null);

        if (encoding.codepointSize == 8)
            return utf8Del(u8, i8);
        else if (encoding.codepointSize == 16)
            return utf16Del(u16, i16);
        else if (encoding.codepointSize == 32)
            return utf32Del(u32, i32);
        else {
            static if (is(ReturnType!W == void)) {
                nullDel();
                static if (!is(typeof(return) == void))
                    return typeof(return).init;
            } else {
                return nullDel();
            }
        }
    }
}

struct UTF_State(Char) {
    import sidero.base.text.internal.builder.blocklist;
    import sidero.base.text.internal.builder.iteratorlist;
    import sidero.base.allocators.api;

    mixin template CustomIteratorContents() {
        void[4] forwardBuffer, backwardBuffer;
        void[] forwardItems, backwardItems;

        bool emptyUTF() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            return forwardItems.length == 0 && backwardItems.length == 0 && emptyInternal();
        }

        TargetChar frontUTF(TargetChar)() @trusted {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            const needRefill = this.forwardItems.length == 0;
            const needToUseOtherBuffer = this.emptyInternal && needRefill && this.backwardItems.length > 0;

            if (needToUseOtherBuffer) {
                // take first in backwards buffer
                assert(this.backwardItems.length > 0);
                return (cast(TargetChar[])this.backwardItems)[0];
            } else if (needRefill) {
                popFrontInternalUTF!TargetChar;
            }

            // take first in forwards buffer
            assert(this.forwardItems.length > 0);
            return (cast(TargetChar[])this.forwardItems)[0];
        }

        TargetChar backUTF(TargetChar)() @trusted {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            const needRefill = this.backwardItems.length == 0;
            const needToUseOtherBuffer = this.emptyInternal && this.forwardItems.length > 0 && needRefill;

            if (needToUseOtherBuffer) {
                // take first in backwards buffer
                assert(this.forwardItems.length > 0);
                return (cast(TargetChar[])this.forwardItems)[$ - 1];
            } else if (needRefill) {
                popBackInternalUTF!TargetChar;
            }

            // take first in forwards buffer
            assert(this.backwardItems.length > 0);
            return (cast(TargetChar[])this.backwardItems)[$ - 1];
        }

        void popFrontUTF(TargetChar)() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            popFrontInternalUTF!TargetChar;
        }

        void popBackUTF(TargetChar)() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            popBackInternalUTF!TargetChar;
        }

        void popFrontInternalUTF(TargetChar)() @trusted {
            import sidero.base.encoding.utf;

            const needRefill = this.forwardItems.length == 0;
            const needToUseOtherBuffer = this.emptyInternal && this.forwardItems.length == 0 && this.backwardItems.length > 0;

            Cursor forwardsTempDecodeCursor = forwards;
            size_t advance;

            bool emptyInternal() {
                size_t actualBack = backwards.offsetFromHead + 1;
                return forwardsTempDecodeCursor.offsetFromHead + 1 >= actualBack || actualBack <= forwardsTempDecodeCursor.offsetFromHead +
                    1;
            }

            Char frontInternal() {
                forwardsTempDecodeCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsTempDecodeCursor.get();
            }

            void popFrontInternal() {
                import std.algorithm : min;

                forwardsTempDecodeCursor.advanceForward(1, min(backwards.offsetFromHead + 1, maximumOffsetFromHead), true);
            }

            if (needToUseOtherBuffer) {
                this.backwardItems = (cast(TargetChar[])this.backwardItems)[1 .. $];
            } else if (needRefill) {
                assert(!this.emptyInternal);

                TargetChar[4 / TargetChar.sizeof] charBuffer = void;
                size_t amountFilled;

                static if (is(Char == TargetChar)) {
                    // copy straight

                    while (amountFilled < charBuffer.length && !emptyInternal()) {
                        charBuffer[amountFilled++] = frontInternal();
                        popFrontInternal();
                        advance++;
                    }
                } else static if (is(Char == char)) {
                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, advance);

                    static if (is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if (is(Char == wchar)) {
                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, advance);

                    static if (is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if (is(Char == dchar)) {
                    dchar decoded = this.frontInternal;
                    advance = 1;

                    static if (is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else static if (is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    }
                }

                this.forwardBuffer = charBuffer;
                this.forwardItems = (cast(TargetChar[])this.forwardBuffer)[0 .. amountFilled];
            } else {
                this.forwardItems = (cast(TargetChar[])this.forwardItems)[1 .. $];
            }

            if (advance > 0)
                forwards.advanceForward(advance, maximumOffsetFromHead, true);
        }

        void popBackInternalUTF(TargetChar)() @trusted {
            import sidero.base.encoding.utf;

            const needRefill = this.backwardItems.length == 0;
            const needToUseOtherBuffer = this.emptyInternal && this.forwardItems.length > 0 && needRefill;

            Cursor backwardsTempDecodeCursor = backwards;
            size_t advance;

            bool emptyInternal() {
                size_t actualBack = backwardsTempDecodeCursor.offsetFromHead + 1;
                return forwards.offsetFromHead + 1 >= actualBack || actualBack <= forwards.offsetFromHead + 1;
            }

            Char backInternal() {
                if (!backwardsTempDecodeCursor.inData)
                    backwardsTempDecodeCursor.advanceBackwards(0, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
                return backwardsTempDecodeCursor.get();
            }

            void popBackInternal() {
                backwardsTempDecodeCursor.advanceBackwards(1, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
            }

            if (needToUseOtherBuffer) {
                this.forwardItems = (cast(TargetChar[])this.forwardItems)[0 .. $ - 1];
            } else if (needRefill) {
                assert(!this.emptyInternal);

                TargetChar[4 / TargetChar.sizeof] charBuffer = void;
                size_t amountFilled, offsetFilled;

                static if (is(Char == TargetChar)) {
                    // copy straight

                    while (amountFilled < charBuffer.length && !emptyInternal()) {
                        amountFilled++;
                        advance++;

                        charBuffer[$ - amountFilled] = backInternal();

                        popBackInternal();
                    }

                    offsetFilled = charBuffer.length - amountFilled;
                } else static if (is(Char == char)) {
                    dchar decoded = decodeFromEnd(&emptyInternal, &backInternal, &popBackInternal, advance);

                    static if (is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if (is(Char == wchar)) {
                    dchar decoded = decodeFromEnd(&emptyInternal, &backInternal, &popBackInternal, advance);

                    static if (is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if (is(Char == dchar)) {
                    dchar decoded = backInternal();
                    advance = 1;

                    static if (is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else static if (is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    }
                }

                this.backwardBuffer = charBuffer;
                this.backwardItems = (cast(TargetChar[])this.backwardBuffer)[offsetFilled .. offsetFilled + amountFilled];
            } else {
                this.backwardItems = (cast(TargetChar[])this.backwardItems)[0 .. $ - 1];
            }

            if (advance > 0) {
                backwards.advanceBackwards(advance, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
            }
        }
    }

    mixin StringBuilderOperations;

@safe nothrow @nogc:

    this(scope return RCAllocator allocator) scope @trusted {
        this.blockList = BlockList(allocator);
    }

    @disable this(this);

    ~this() {
        blockList.clear;
        assert(iteratorList.head is null);
    }

    UnicodeLanguage language;

    UnicodeLanguage pickLanguage(UnicodeLanguage input = UnicodeLanguage.Unknown) const scope {
        import sidero.base.system : unicodeLanguage;

        if (input != UnicodeLanguage.Unknown)
            return input;
        else if (language != UnicodeLanguage.Unknown)
            return language;

        return unicodeLanguage();
    }

    void onInsert(scope const Char[] input) scope {
    }

    void onRemove(scope const Char[] input) scope {
    }

    static struct LiteralMatcher {
        const(Char)[] literal;

        bool matches(scope Cursor cursor, size_t maximumOffsetFromHead) {
            auto temp = literal;

            while (!cursor.isOutOfRange(0, maximumOffsetFromHead) && temp.length > 0) {
                size_t canDo = cursor.block.length - cursor.offsetIntoBlock;
                if (canDo > temp.length)
                    canDo = temp.length;

                auto got = cursor.block.get()[cursor.offsetIntoBlock .. $];
                foreach (i, c; temp[0 .. canDo])
                    if (got[i] != c)
                        return false;

                temp = temp[canDo .. $];
                cursor.advanceForward(canDo, maximumOffsetFromHead, true);
            }

            return temp.length == 0;
        }

        int compare(scope Cursor cursor, size_t maximumOffsetFromHead) {
            auto temp = literal;

            while (!cursor.isOutOfRange(0, maximumOffsetFromHead) && temp.length > 0) {
                size_t canDo = cursor.block.length - cursor.offsetIntoBlock;
                if (canDo > temp.length)
                    canDo = temp.length;

                auto got = cursor.block.get()[cursor.offsetIntoBlock .. $];
                foreach (i, a; temp[0 .. canDo]) {
                    Char b = got[i];

                    if (a < b)
                        return 1;
                    else if (a > b)
                        return -1;
                }

                temp = temp[canDo .. $];
                cursor.advanceForward(canDo, maximumOffsetFromHead, true);
            }

            return temp.length == 0 ? 0 : -1;
        }
    }

    alias LiteralAsTarget = LiteralAsTargetChar!(Char, Char);

    static struct OtherStateIsUs(TargetChar) {
        UTF_State* state;
        Iterator* iterator;

        void mutex(bool lock) {
            assert(state !is null);

            if (lock)
                state.blockList.mutex.pureLock;
            else
                state.blockList.mutex.unlock;
        }

        int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
            int result;

            static if (is(Char == TargetChar)) {
                if (iterator !is null) {
                    iterator.foreachBlocks((scope TargetChar[] data) {
                        if (data.length > 0)
                            result = del(data);
                        return result;
                    });
                } else {
                    foreach (Char[] data; state.blockList) {
                        if (data.length > 0)
                            result = del(data);

                        if (result)
                            break;
                    }
                }
            } else {
                import sidero.base.encoding.utf : decode, encode;

                Cursor forwards;

                if (iterator is null)
                    forwards.setup(&state.blockList, 0);
                else
                    forwards = iterator.forwards;

                size_t maximum() {
                    return iterator is null ? state.blockList.numberOfItems : iterator.backwards.offsetFromHead;
                }

                bool emptyInternal() {
                    return forwards.isOutOfRange(0, maximum());
                }

                Char frontInternal() {
                    forwards.advanceForward(0, maximum(), true);
                    return forwards.get();
                }

                void popFrontInternal() {
                    forwards.advanceForward(1, maximum(), true);
                }

                while (!emptyInternal()) {
                    size_t consumed;
                    dchar got = decode(&emptyInternal, &frontInternal, &popFrontInternal, consumed);

                    static if (is(TargetChar == dchar)) {
                        dchar[1] buffer = [got];
                        TargetChar[] temp = buffer[];

                        result = del(temp);
                        if (result)
                            return result;
                    } else {
                        // encode
                        TargetChar[4 / TargetChar.sizeof] buffer = void;
                        TargetChar[] temp = buffer[0 .. encode(got, buffer)];

                        result = del(temp);
                        if (result)
                            return result;
                    }
                }
            }

            return result;
        }

        int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) @safe @nogc nothrow {
            int result;

            static if (is(Char == TargetChar)) {
                if (iterator !is null) {
                    foreach (data; &iterator.foreachBlocks) {
                        foreach (c; data) {
                            result = del(c);

                            if (result)
                                return result;
                        }
                    }
                } else {
                    foreach (Char[] data; state.blockList) {
                        foreach (c; data) {
                            result = del(c);

                            if (result)
                                return result;
                        }
                    }
                }
            } else {
                import sidero.base.encoding.utf : decode, encode;

                Cursor forwards;

                if (iterator is null)
                    forwards.setup(&state.blockList, 0);
                else
                    forwards = iterator.forwards;

                size_t maximum() {
                    return iterator is null ? state.blockList.numberOfItems : iterator.backwards.offsetFromHead;
                }

                bool emptyInternal() {
                    return forwards.isOutOfRange(0, maximum());
                }

                Char frontInternal() {
                    forwards.advanceForward(0, maximum(), true);
                    return forwards.get();
                }

                void popFrontInternal() {
                    forwards.advanceForward(1, maximum(), true);
                }

                while (!emptyInternal()) {
                    size_t consumed;
                    dchar got = decode(&emptyInternal, &frontInternal, &popFrontInternal, consumed);

                    static if (is(TargetChar == dchar)) {
                        result = del(got);
                        if (result)
                            return result;
                    } else {
                        // encode
                        TargetChar[4 / TargetChar.sizeof] buffer = void;
                        TargetChar[] temp = buffer[0 .. encode(got, buffer)];

                        foreach (c; temp) {
                            result = del(c);
                            if (result)
                                return result;
                        }
                    }
                }
            }

            return result;
        }

        size_t length() @safe @nogc nothrow {
            Cursor forwards;

            if (iterator is null)
                forwards.setup(&state.blockList, 0);
            else
                forwards = iterator.forwards;

            size_t maximum() {
                return iterator is null ? state.blockList.numberOfItems : iterator.backwards.offsetFromHead;
            }

            bool emptyInternal() {
                return forwards.isOutOfRange(0, maximum());
            }

            Char frontInternal() {
                forwards.advanceForward(0, maximum(), true);
                return forwards.get();
            }

            void popFrontInternal() {
                forwards.advanceForward(1, maximum(), true);
            }

            static if (is(Char == TargetChar)) {
                return iterator is null ? state.blockList.numberOfItems
                    : (iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead);
            } else {
                import sidero.base.encoding.utf : decode, encodeLengthUTF8, encodeLengthUTF16;

                size_t ret;

                while (!emptyInternal()) {
                    size_t consumed;
                    dchar got = decode(&emptyInternal, &frontInternal, &popFrontInternal, consumed);

                    static if (is(TargetChar == char)) {
                        // decode then encode
                        ret += encodeLengthUTF8(got);
                    } else static if (is(TargetChar == wchar)) {
                        // decode then encode
                        ret += encodeLengthUTF16(got);
                    } else static if (is(TargetChar == dchar)) {
                        ret++;
                    }
                }

                return ret;
            }
        }

        OtherStateAsTarget!TargetChar get() scope return @trusted {
            return OtherStateAsTarget!TargetChar(cast(void*)state, &mutex, &foreachContiguous, &foreachValue, &length);
        }
    }

    void debugPosition(scope Cursor cursor) {
        debugPosition(cursor.block, cursor.offsetIntoBlock);
    }

    void debugPosition(scope Block* cursorBlock, size_t offsetIntoBlock) @trusted {
        version (D_BetterC) {
        } else {
            debug {
                try {
                    import std.stdio;

                    Block* block = &blockList.head;
                    size_t offsetFromHead;

                    writeln("====================");

                    while (block !is null) {
                        if (block is cursorBlock)
                            write(">");
                        writef!"%s:%X@(%s)"(offsetFromHead, block, *block);
                        if (block is cursorBlock)
                            writef!":%s<"(offsetIntoBlock);
                        write("    [[[", cast(char[])block.get(), "]]]\n");

                        offsetFromHead += block.length;
                        block = block.next;
                    }

                    writeln;

                    foreach (iterator; iteratorList) {
                        try {
                            writef!"%X@"(iterator);
                            foreach (v; (*iterator).tupleof)
                                write(" ", v);
                            writeln;
                        } catch (Exception) {
                        }
                    }
                } catch (Exception) {
                }
            }
        }
    }

    void debugPosition(scope Iterator* iterator) @trusted {
        version (D_BetterC) {
        } else {
            debug {
                try {
                    import std.stdio;

                    Block* block = &blockList.head;
                    size_t offsetFromHead;

                    writeln("====================");

                    while (block !is null) {
                        if (iterator !is null && block is iterator.forwards.block)
                            write(iterator.forwards.offsetIntoBlock, ">");
                        writef!"%s:%X@(%s)"(offsetFromHead, block, *block);
                        if (iterator !is null && block is iterator.backwards.block)
                            writef!":%s<"(iterator.backwards.offsetIntoBlock);
                        write("    [[[", cast(char[])block.get(), "]]]\n");

                        offsetFromHead += block.length;
                        block = block.next;
                    }

                    writeln;

                    foreach (iterator; iteratorList) {
                        try {
                            writef!"%X@"(iterator);
                            foreach (v; (*iterator).tupleof)
                                write(" ", v);
                            writeln;
                        } catch (Exception) {
                        }
                    }
                } catch (Exception) {
                }
            }
        }
    }

    static struct ForeachUTF32 {
        Cursor cursor;
        size_t maximumOffsetFromHead;
        // when delegate == 0
        size_t lastIteratedCount0;

        this(return scope Cursor cursor, size_t maximumOffsetFromHead) scope @safe nothrow @nogc {
            this.cursor = cursor;
            this.maximumOffsetFromHead = maximumOffsetFromHead;
        }

        this(scope ref UTF_State state, scope Iterator* iterator, size_t offset, bool fromHead) scope @safe nothrow @nogc {
            if (fromHead)
                cursor = state.cursorFor(iterator, maximumOffsetFromHead, offset);
            else {
                size_t offsetFromEnd = iterator is null ? state.blockList.numberOfItems : iterator.maximumOffsetFromHead;
                if (offsetFromEnd <= offset)
                    offsetFromEnd = 0;
                else
                    offsetFromEnd -= offset;

                cursor = state.cursorFor(iterator, maximumOffsetFromHead, offsetFromEnd);
            }

            cursor.advanceForward(0, maximumOffsetFromHead, true);
        }

        int opApply(scope int delegate(ref dchar) @safe nothrow @nogc del) scope @safe nothrow @nogc {
            int result;

            lastIteratedCount0 = 0;
            Cursor forwardsTempDecodeCursor = cursor;
            size_t advance = 1;

            bool emptyInternal() {
                return forwardsTempDecodeCursor.offsetFromHead >= maximumOffsetFromHead;
            }

            Char frontInternal() {
                forwardsTempDecodeCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsTempDecodeCursor.get();
            }

            void popFrontInternal() {
                import std.algorithm : min;

                forwardsTempDecodeCursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            while (!emptyInternal() && result == 0) {
                static if (is(Char == dchar)) {
                    dchar decoded = frontInternal();
                    popFrontInternal();
                } else {
                    import sidero.base.encoding.utf : decode;

                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, advance);
                }

                result = del(decoded);
                if (result == 0)
                    lastIteratedCount0 += advance;
            }

            return result;
        }
    }

    // /\ Internal
    // \/ Exposed

    int externalOpCmp(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar other, bool caseSensitive, UnicodeLanguage language) {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        language = pickLanguage(language);
        int result;

        OtherStateIsUs!dchar osiu;
        osiu.state = &this;
        osiu.iterator = iterator;
        scope osat = osiu.get;

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(other.foreachValue, caseSensitive);
        result = cac.compare(osat.foreachValue, false);

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);

        return result;
    }

    void externalNormalization(scope Iterator* iterator, UnicodeLanguage language, bool compatibility, bool composition) @trusted {
        import sidero.base.text.unicode.characters.database : isTurkic;
        import sidero.base.text.unicode.normalization : normalize;

        blockList.mutex.pureLock;

        language = pickLanguage(language);
        RCAllocator allocator = blockList.allocator;

        ForeachUTF32 foreachUTF32 = ForeachUTF32(this, iterator, 0, true);
        Cursor cursor;
        size_t lengthToRemove;

        if (iterator !is null) {
            cursor = iterator.forwards;
            lengthToRemove = iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead;
        } else {
            cursor.setup(&blockList, 0);
            lengthToRemove = blockList.numberOfItems;
        }

        dstring got = normalize(&foreachUTF32.opApply, allocator, language.isTurkic, compatibility, composition);
        LiteralAsTargetChar!(dchar, Char) latc;
        latc.literal = got;
        scope osat = latc.get;

        // Replicate the behavior of replaceOperation,
        //  we unfortunately cannot call it, since this is dependent on the iterator,
        //  rather than using any comparison.

        insertOperation(cursor, lengthToRemove, osat);
        removeOperation(iterator, cursor, lengthToRemove);

        allocator.dispose(cast(void[])got);
        blockList.mutex.unlock;
    }

    bool externalStartsWith(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar other, bool caseSensitive,
            UnicodeLanguage language) {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        language = pickLanguage(language);
        int result;

        OtherStateIsUs!dchar osiu;
        osiu.state = &this;
        osiu.iterator = iterator;
        scope osat = osiu.get;

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(other.foreachValue, caseSensitive);
        result = cac.compare(osat.foreachValue, true);

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);

        return result == 0;
    }

    bool externalEndsWith(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar other, bool caseSensitive, UnicodeLanguage language) {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        language = pickLanguage(language);
        int result;

        // this may be costly, but this is in fact the best way to do it
        {
            size_t otherLength = other.length(), usLength;

            if (iterator !is null)
                usLength = iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead;
            else
                usLength = blockList.numberOfItems;

            if (otherLength > usLength) {
                blockList.mutex.unlock;
                if (other.obj !is &this)
                    other.mutex(false);

                return false;
            }

            ptrdiff_t minimumOffsetFromHead = otherLength, maximumOffsetFromHead = usLength;
            minimumOffsetFromHead = -minimumOffsetFromHead;

            changeIndexToOffset(iterator, minimumOffsetFromHead);
            iterator = iteratorList.newIterator(&blockList, minimumOffsetFromHead, maximumOffsetFromHead);
        }

        OtherStateIsUs!dchar osiu;
        osiu.state = &this;
        osiu.iterator = iterator;
        scope osat = osiu.get;

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(other.foreachValue, caseSensitive);
        result = cac.compare(osat.foreachValue, true);

        {
            iteratorList.rcIteratorInternal(false, iterator);
            this.rcInternal(false);
        }

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);

        return result == 0;
    }

    size_t externalReplace(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar toFind,
            scope ref OtherStateAsTarget!Char toReplace, bool caseSensitive, bool onlyOnce, UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if (toFind.obj !is &this)
            toFind.mutex(true);
        if (toReplace.obj !is &this && toReplace.obj !is toFind.obj)
            toReplace.mutex(true);

        language = pickLanguage(language);

        size_t maximumOffsetFromHead;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(toFind.foreachValue, caseSensitive);

        size_t ret = replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) @trusted nothrow @nogc {
            ForeachUTF32 f32 = ForeachUTF32(cursor, maximumOffsetFromHead);

            auto got = cac.compare(&f32.opApply, true);
            if (got != 0)
                return 0;

            assert(f32.lastIteratedCount0 != 0);
            return f32.lastIteratedCount0;
        }, (scope Iterator* iterator, scope ref Cursor cursor) @trusted {
            return insertOperation(iterator, cursor, toReplace);
        }, true, onlyOnce);

        blockList.mutex.unlock;
        if (toFind.obj !is &this)
            toFind.mutex(false);
        if (toReplace.obj !is &this && toReplace.obj !is toFind.obj)
            toReplace.mutex(false);

        return ret;
    }
}

struct LiteralAsTargetChar(SourceChar, TargetChar) {
    const(SourceChar)[] literal;

@safe nothrow @nogc:

    void mutex(bool) {
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
        static if (is(SourceChar == TargetChar)) {
            // don't mutate during testing
            TargetChar[] temp = cast(TargetChar[])literal;
            if (temp.length > 0)
                return del(temp);
            else
                return 0;
        } else {
            return foreachValue((ref TargetChar value) {
                TargetChar[1] temp1 = [value];
                auto temp2 = temp1[];
                return del(temp2);
            });
        }
    }

    int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) @safe @nogc nothrow {
        import sidero.base.encoding.utf : decode, encode;

        int result;

        static if (is(SourceChar == TargetChar) || is(SourceChar == dchar)) {
            foreach (SourceChar c; literal) {
                static if (is(SourceChar == TargetChar)) {
                    result = del(c);
                } else if (is(SourceChar == dchar)) {
                    // just encode
                    TargetChar[4 / TargetChar.sizeof] buffer = void;
                    TargetChar[] temp = buffer[0 .. encode(c, buffer)];

                    foreach (c2; temp) {
                        result = del(c2);
                        if (result)
                            break;
                    }
                }

                if (result)
                    break;
            }
        } else {
            // decode then encode
            decode(literal, (dchar got) {
                static if (is(TargetChar == dchar)) {
                    result = del(got);
                    if (result)
                        return true;
                } else {
                    TargetChar[4 / TargetChar.sizeof] buffer = void;
                    scope temp = buffer[0 .. encode(got, buffer)];

                    foreach (TargetChar c; temp) {
                        result = del(c);
                        if (result)
                            return true;
                    }
                }

                return false;
            });
        }

        return result;
    }

    size_t length() {
        import sidero.base.encoding.utf : encodeLengthUTF8, encodeLengthUTF16, decode;

        static if (is(SourceChar == TargetChar)) {
            return literal.length;
        } else static if (is(SourceChar == dchar)) {
            // just encode
            static if (is(TargetChar == char)) {
                return encodeLengthUTF8(literal);
            } else static if (is(TargetChar == wchar)) {
                return encodeLengthUTF16(literal);
            }
        } else {
            // decode then encode
            size_t ret;

            decode(literal, (dchar got) {
                static if (is(TargetChar == char)) {
                    ret += encodeLengthUTF8(got);
                } else static if (is(TargetChar == wchar)) {
                    ret += encodeLengthUTF16(got);
                } else
                    ret++;
            });

            return ret;
        }
    }

    OtherStateAsTarget!TargetChar get() scope return @trusted {
        return OtherStateAsTarget!TargetChar(cast(void*)literal.ptr, &mutex, &foreachContiguous, &foreachValue, &length);
    }
}

struct ASCIILiteralAsTarget(TargetChar) {
    const(ubyte)[] literal;

@safe nothrow @nogc:

    void mutex(bool) {
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
        // don't mutate during testing
        static if (is(TargetChar == char)) {
            TargetChar[] temp = cast(TargetChar[])literal;
            if (temp.length > 0)
                return del(temp);
            else
                return 0;
        } else {
            TargetChar[1] temp1 = void;
            TargetChar[] temp2;
            int result;

            foreach (c; literal) {
                temp2 = temp1[];
                temp1[0] = cast(TargetChar)c;

                result = del(temp2);

                if (result)
                    break;
            }

            return result;
        }
    }

    int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) @safe @nogc nothrow {
        int result;

        foreach (c; literal) {
            TargetChar temp = cast(TargetChar)c;
            result = del(temp);

            if (result)
                break;
        }

        return result;
    }

    size_t length() {
        // we are not mixing types during testing so meh
        return literal.length;
    }

    OtherStateAsTarget!TargetChar get() scope return @trusted {
        return OtherStateAsTarget!TargetChar(cast(void*)literal.ptr, &mutex, &foreachContiguous, &foreachValue, &length);
    }
}

static struct ASCIIStateAsTarget(TargetChar) {
    ASCII_State* state;
    state.Iterator* iterator;

    void mutex(bool lock) {
        assert(state !is null);

        if (lock)
            state.blockList.mutex.pureLock;
        else
            state.blockList.mutex.unlock;
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
        int result;

        if (iterator !is null) {
            iterator.foreachBlocks((scope data) {
                if (data.length == 0)
                    return 0;

                static if (is(TargetChar == char)) {
                    TargetChar[] temp = cast(TargetChar[])data;
                    result = del(temp);
                } else {
                    TargetChar[1] temp1 = void;
                    TargetChar[] temp2;

                    foreach (c; data) {
                        temp2 = temp1[];
                        temp1[0] = cast(TargetChar)c;

                        result = del(temp2);
                        if (result)
                            break;
                    }
                }

                return result;
            });
        } else {
            foreach (ubyte[] data; state.blockList) {
                static if (is(TargetChar == char)) {
                    TargetChar[] temp = cast(TargetChar[])data;
                    result = del(temp);
                } else {
                    TargetChar[1] temp1 = void;
                    TargetChar[] temp2;

                    foreach (c; data) {
                        temp2 = temp1[];
                        temp1[0] = cast(TargetChar)c;

                        result = del(temp2);
                        if (result)
                            break;
                    }
                }

                if (result)
                    break;
            }
        }

        return result;
    }

    int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) @safe @nogc nothrow {
        int result;

        if (iterator !is null) {
            iterator.foreachBlocks((scope data) {
                foreach (c; data) {
                    TargetChar temp = cast(TargetChar)c;
                    result = del(temp);

                    if (result)
                        break;
                }

                return result;
            });
        } else {
            foreach (ubyte[] data; state.blockList) {
                foreach (c; data) {
                    TargetChar temp = cast(TargetChar)c;
                    result = del(temp);

                    if (result)
                        return result;
                }
            }
        }

        return result;
    }

    size_t length() @safe @nogc nothrow {
        return iterator is null ? state.blockList.numberOfItems : (iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead);
    }

    OtherStateAsTarget!TargetChar get() scope return @trusted {
        return OtherStateAsTarget!TargetChar(cast(void*)state, &mutex, &foreachContiguous, &foreachValue, &length);
    }
}

struct AnyAsTargetChar(TargetChar) {
    union {
        UTF_State!char.OtherStateIsUs!TargetChar osiu8;
        UTF_State!wchar.OtherStateIsUs!TargetChar osiu16;
        UTF_State!dchar.OtherStateIsUs!TargetChar osiu32;

        LiteralAsTargetChar!(char, TargetChar) latc8;
        LiteralAsTargetChar!(wchar, TargetChar) latc16;
        LiteralAsTargetChar!(dchar, TargetChar) latc32;

        ASCIIStateAsTarget!TargetChar asat;
        ASCIILiteralAsTarget!TargetChar alat;
    }

    OtherStateAsTarget!TargetChar osat;

    this(Input)(scope ref Input input) @trusted {
        static if (is(Input == String_ASCII)) {
            input.stripZeroTerminator;
            scope actualInput = input.literal;
        } else {
            scope actualInput = input;
        }

        static if (is(Input == StringBuilder_ASCII)) {
            asat.state = input.state;
            asat.iterator = input.iterator;
            osat = asat.get();
        } else static if (is(Input == StringBuilder_UTF!Char2, Char2)) {
            input.state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
                assert(state !is null);

                osiu8.state = state;
                osiu8.iterator = iterator;
                osat = osiu8.get;
            }, (StateIterator.S16 state, StateIterator.I16 iterator) {
                assert(state !is null);

                osiu16.state = state;
                osiu16.iterator = iterator;
                osat = osiu16.get;
            }, (StateIterator.S32 state, StateIterator.I32 iterator) {
                assert(state !is null);

                osiu32.state = state;
                osiu32.iterator = iterator;
                osat = osiu32.get;
            }, () { assert(0); });
        } else static if (is(Input == String_UTF!Char2, Char2)) {
            input.stripZeroTerminator;

            input.literalEncoding.handle(() @trusted { latc8.literal = cast(string)input.literal; osat = latc8.get(); }, () @trusted {
                latc16.literal = cast(wstring)input.literal;
                osat = latc16.get();
            }, () @trusted { latc32.literal = cast(dstring)input.literal; osat = latc32.get(); }, () @trusted {
                assert(0);
            });
        } else static if (is(typeof(actualInput) == const(char)[])) {
            latc8.literal = input;
            osat = latc8.get();
        } else static if (is(typeof(actualInput) == const(wchar)[])) {
            latc16.literal = input;
            osat = latc16.get();
        } else static if (is(typeof(actualInput) == const(dchar)[])) {
            latc32.literal = input;
            osat = latc32.get();
        } else static if (is(typeof(actualInput) == const(ubyte)[])) {
            alat.literal = cast(const(ubyte)[])actualInput;
            osat = alat.get();
        } else
            static assert(0, typeof(actualInput).stringof);
    }
}
