module sidero.base.text.unicode.builder;
import sidero.base.allocators.api;

///
alias StringBuilder_UTF8 = StringBuilder_UTF!char;
///
alias StringBuilder_UTF16 = StringBuilder_UTF!wchar;
///
alias StringBuilder_UTF32 = StringBuilder_UTF!dchar;

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
    }

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
        import core.atomic : atomicOp;

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
    this(InputChar)(RCAllocator allocator, scope const(InputChar)[] input)
            if (is(InputChar == char) || is(InputChar == wchar) || is(InputChar == dchar)) {
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
    this(InputChar)(scope const(InputChar)[] input, RCAllocator allocator = RCAllocator.init)
            if (is(InputChar == char) || is(InputChar == wchar) || is(InputChar == dchar)) {
        setupState(allocator);

        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
            assert(state !is null);

            LiteralAsTargetChar!(InputChar, char) latc;
            latc.literal = input;
            auto osat = latc.get;

            state.externalInsert(iterator, 0, osat);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) @trusted {
            assert(state !is null);

            LiteralAsTargetChar!(InputChar, wchar) latc;
            latc.literal = input;
            auto osat = latc.get;

            state.externalInsert(iterator, 0, osat);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
            assert(state !is null);

            LiteralAsTargetChar!(InputChar, dchar) latc;
            latc.literal = input;
            auto osat = latc.get;

            state.externalInsert(iterator, 0, osat);
        });
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

    ///
    StringBuilder_UTF opIndex(size_t index) scope @nogc {
        return this[index .. index + 1];
    }

    ///
    StringBuilder_UTF opSlice(size_t start, size_t end) scope @trusted @nogc {
        StringBuilder_UTF ret;

        state.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u8 = state;
            ret.state.i8 = state.newIterator(iterator, start, end);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            ret.state.encoding = this.state.encoding;
            ret.state.u16 = state;
            ret.state.i16 = state.newIterator(iterator, start, end);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
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

    // dup
    // asReadOnly
    // normalize
    // opIndex
    // opCast
    // opEquals
    // opCmp
    // ignoreCaseEquals
    // ignoreCaseCompare

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

            if (iterator is null)
                iterator = state.newIterator(iterator);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null)
                iterator = state.newIterator(iterator);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null)
                iterator = state.newIterator(iterator);
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

            if (iterator is null)
                iterator = state.newIterator(iterator);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null)
                iterator = state.newIterator(iterator);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null)
                iterator = state.newIterator(iterator);
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

            if (iterator is null)
                iterator = state.newIterator(iterator);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if (iterator is null)
                iterator = state.newIterator(iterator);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if (iterator is null)
                iterator = state.newIterator(iterator);
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

    // startsWith
    // ignoreCaseStartsWith
    // endsWith
    // ignoreCaseEndsWith
    // count
    // ignoreCaseCount
    // contains
    // ignoreCaseContains
    // indexOf
    // caseIgnoreIndexOf
    // lastIndexOf
    // caseIgnoreLastIndexOf
    // stripLeft
    // stripRight
    // toHash

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
}

private:

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

    ///
    auto handle(T, U, V)(scope T utf8Del, scope U utf16Del, scope V utf32Del) {
        return encoding.handle(() { return utf8Del(u8, i8); }, () { return utf16Del(u16, i16); }, () {
            return utf32Del(u32, i32);
        });
    }

    ///
    auto handle(T, U, V, W)(scope T utf8Del, scope U utf16Del, scope V utf32Del, scope W nullDel) {
        import std.traits : ReturnType;

        ReturnType!utf8Del nullFunc() {
            static if (is(ReturnType!nullDel == void)) {
                nullDel();

                static if (!is(typeof(return) == void)) {
                    return typeof(return).init;
                }
            } else
                return nullDel();
        }

        return encoding.handle(() { return utf8Del(u8, i8); }, () { return utf16Del(u16, i16); }, () {
            return utf32Del(u32, i32);
        }, &nullFunc);
    }
}

struct UTF_State(Char) {
    import sidero.base.text.internal.builder.blocklist;
    import sidero.base.text.internal.builder.iteratorlist;
    import sidero.base.text.internal.builder.operations;
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

                TargetChar[4 / TargetChar.sizeof] charBuffer;
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

                TargetChar[4 / TargetChar.sizeof] charBuffer;
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
                    foreach (data; iterator.foreachBlocks) {
                        result = del(data);

                        if (result)
                            break;
                    }
                } else {
                    foreach (Char[] data; state.blockList) {
                        result = del(data);

                        if (result)
                            break;
                    }
                }
            } else {
                Cursor forwards;

                if (iterator is null)
                    forwards.setup(&state.blockList, 0);
                else
                    forwards = iterator.forwards;

                size_t maximum() {
                    return iterator is null ? state.blockList.numberOfItems : iterator.backwards.offsetFromHead;
                }

                bool emptyInternal() {
                    return forwards.isEmpty(0, maximum());
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

                    static if (is(Char == dchar)) {
                        dchar[1] temp = [got];

                        result = del(temp[]);
                        if (result)
                            return result;
                    } else {
                        // encode
                        TargetChar[4 / TargetChar.sizeof] buffer;
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
                Cursor forwards;

                if (iterator is null)
                    forwards.setup(&state.blockList, 0);
                else
                    forwards = iterator.forwards;

                size_t maximum() {
                    return iterator is null ? state.blockList.numberOfItems : iterator.backwards.offsetFromHead;
                }

                bool emptyInternal() {
                    return forwards.isEmpty(0, maximum());
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

                    static if (is(Char == dchar)) {
                        result = del(got);
                        if (result)
                            return result;
                    } else {
                        // encode
                        TargetChar[4 / TargetChar.sizeof] buffer;
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

        size_t length() {
            Cursor forwards;

            if (iterator is null)
                forwards.setup(&state.blockList, 0);
            else
                forwards = iterator.forwards;

            size_t maximum() {
                return iterator is null ? state.blockList.numberOfItems : iterator.backwards.offsetFromHead;
            }

            bool emptyInternal() {
                return forwards.isEmpty(0, maximum());
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
                    } else static if (is(Char == dchar)) {
                        ret++;
                    }
                }

                return ret;
            }
        }
    }

    void debugPosition(scope Cursor cursor) {
        debugPosition(cursor.block, cursor.offsetIntoBlock);
    }

    void debugPosition(scope Block* cursorBlock, size_t offsetIntoBlock) @trusted {
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

    void debugPosition(scope Iterator* iterator) @trusted {
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

struct LiteralAsTargetChar(SourceChar, TargetChar) {
    import sidero.base.text.internal.builder.operations;

    const(SourceChar)[] literal;

@safe nothrow @nogc:

    void mutex(bool) {
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
        static if (is(SourceChar == TargetChar)) {
            // don't mutate during testing
            SourceChar[] temp = cast(SourceChar[])literal;
            return del(temp);
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
                    TargetChar[4 / TargetChar.sizeof] buffer;
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
                    TargetChar[4 / TargetChar.sizeof] buffer;
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
