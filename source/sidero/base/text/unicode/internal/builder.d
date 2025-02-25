module sidero.base.text.unicode.internal.builder;
import sidero.base.text.unicode.characters.database : UnicodeLanguage;
import sidero.base.text.internal.builder.operations;
import sidero.base.text;
import sidero.base.allocators.api;
import sidero.base.traits : isUTFReadOnly, isUTFBuilder;
import sidero.base.attributes : hidden;

package(sidero.base.text.unicode) @hidden:

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

    int opApplyImpl(Char, Del)(scope Del del) scope @trusted {
        if(isNull)
            return 0;

        StateIterator oldState = this;

        this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);
            iterator = state.newIterator(iterator);
            state.rc(true);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);
            iterator = state.newIterator(iterator);
            state.rc(true);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);
            iterator = state.newIterator(iterator);
            state.rc(true);
        });

        scope(exit) {
            this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
                assert(state !is null);
                state.rcIterator(false, iterator);
            }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
                assert(state !is null);
                state.rcIterator(false, iterator);
            }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
                assert(state !is null);
                state.rcIterator(false, iterator);
            });

            this = oldState;
        }

        int result;

        while(!empty) {
            Char temp = front!Char();

            result = del(temp);
            if(result)
                return result;

            popFront!Char();
        }

        return result;
    }

    int opApplyReverseImpl(Char, Del)(scope Del del) scope @trusted {
        if(isNull)
            return 0;

        StateIterator oldState = this;

        this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);
            iterator = state.newIterator(iterator);
            state.rc(true);
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);
            iterator = state.newIterator(iterator);
            state.rc(true);
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);
            iterator = state.newIterator(iterator);
            state.rc(true);
        });

        scope(exit) {
            this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
                assert(state !is null);
                state.rcIterator(false, iterator);
            }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
                assert(state !is null);
                state.rcIterator(false, iterator);
            }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
                assert(state !is null);
                state.rcIterator(false, iterator);
            });

            this = oldState;
        }

        int result;

        while(!empty) {
            Char temp = back!Char();

            result = del(temp);
            if(result)
                return result;

            popBack!Char();
        }

        return result;
    }

scope nothrow @nogc @safe @hidden:

    ///
    auto handle(T, U, V)(scope T utf8Del, scope U utf16Del, scope V utf32Del) @trusted {
        assert(utf8Del !is null);
        assert(utf16Del !is null);
        assert(utf32Del !is null);

        if(encoding.codepointSize == 8)
            return utf8Del(u8, i8);
        else if(encoding.codepointSize == 16)
            return utf16Del(u16, i16);
        else if(encoding.codepointSize == 32)
            return utf32Del(u32, i32);
        else static if(!is(typeof(return) == void))
            return typeof(return).init;
    }

    ///
    auto handle(T, U, V, W)(scope T utf8Del, scope U utf16Del, scope V utf32Del, scope W nullDel) @trusted {
        import std.traits : ReturnType;

        assert(utf8Del !is null);
        assert(utf16Del !is null);
        assert(utf32Del !is null);

        if(encoding.codepointSize == 8)
            return utf8Del(u8, i8);
        else if(encoding.codepointSize == 16)
            return utf16Del(u16, i16);
        else if(encoding.codepointSize == 32)
            return utf32Del(u32, i32);
        else {
            static if(is(ReturnType!W == void)) {
                nullDel();
                static if(!is(typeof(return) == void))
                    return typeof(return).init;
            } else {
                return nullDel();
            }
        }
    }

    void setup(uint charSize, RCAllocator allocator = RCAllocator.init) @nogc {
        if(allocator.isNull)
            allocator = globalAllocator();

        if(this.encoding.codepointSize == 0)
            this.encoding.codepointSize = charSize * 8;

        this.handle((ref StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
            if(state is null)
                state = allocator.make!(typeof(*state))(allocator);
        }, (ref StateIterator.S16 state, StateIterator.I16 iterator) @trusted {
            if(state is null)
                state = allocator.make!(typeof(*state))(allocator);
        }, (ref StateIterator.S32 state, StateIterator.I32 iterator) @trusted {
            if(state is null)
                state = allocator.make!(typeof(*state))(allocator);
        });
    }

    void construct(InputChar)(scope const(InputChar)[] input, RCAllocator allocator = RCAllocator.init,
            UnicodeLanguage language = UnicodeLanguage.init) {
        if(input.length > 0) {
            this.handle((StateIterator.S8 state, StateIterator.I8 iterator) @trusted {
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

    void construct(Other)(scope Other input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted
            if (isUTFReadOnly!Other) {
        input.stripZeroTerminator;

        input.literalEncoding.handle(() { this.construct(cast(const(char)[])input.literal, allocator, input.language); }, () {
            this.construct(cast(const(wchar)[])input.literal, allocator, input.language);
        }, () { this.construct(cast(const(dchar)[])input.literal, allocator, input.language); }, () {});
    }

    void debugPosition() {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);

            state.debugPosition(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) { assert(state !is null); state.debugPosition(iterator); },
                (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);

            state.debugPosition(iterator);
        }, () { assert(0); });
    }

    bool isNull() scope @nogc {
        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) { assert(state !is null); return false; },
                (StateIterator.S16 state, StateIterator.I16 iterator) { assert(state !is null); return false; },
                (StateIterator.S32 state, StateIterator.I32 iterator) { assert(state !is null); return false; }, () {
            return true;
        });
    }

    ptrdiff_t length() scope @nogc {
        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
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

    int opCmpImpl(Other)(scope Other other, bool caseSensitive, UnicodeLanguage language = UnicodeLanguage.Unknown) const @trusted {
        scope otherState = AnyAsTargetChar!dchar(other);

        StateIterator* self = cast(StateIterator*)&this;

        if(other.length == 0)
            return self.length == 0 ? 0 : 1;

        return self.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return state.externalOpCmp(iterator, otherState.osat, caseSensitive, language);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return state.externalOpCmp(iterator, otherState.osat, caseSensitive, language);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return state.externalOpCmp(iterator, otherState.osat, caseSensitive, language);
        }, () {
            if(other.length > 0)
                return -1;
            else
                return 0;
        });
    }

    void insertImpl(Other)(scope Other other, ptrdiff_t offset = 0, bool clobber = false) {
        if(other.length == 0)
            return;

        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
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

        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
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

        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
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

    size_t replaceImpl(ToFind, ToReplace)(scope ToFind toFind, scope ToReplace toReplace, bool caseSensitive, bool onlyOnce,
            UnicodeLanguage language) {
        if(isNull)
            return 0;

        scope toFindState = AnyAsTargetChar!dchar(toFind);

        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
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

    size_t countImpl(ToFind)(scope ToFind toFind, bool caseSensitive, UnicodeLanguage language = UnicodeLanguage.Unknown) {
        if(isNull)
            return 0;

        scope toFindState = AnyAsTargetChar!dchar(toFind);

        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return state.externalCount(iterator, toFindState.osat, caseSensitive, false, language);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return state.externalCount(iterator, toFindState.osat, caseSensitive, false, language);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return state.externalCount(iterator, toFindState.osat, caseSensitive, false, language);
        }, () { return 0; });
    }

    bool containsImpl(ToFind)(scope ToFind toFind, bool caseSensitive, UnicodeLanguage language = UnicodeLanguage.Unknown) {
        if(isNull)
            return false;

        scope toFindState = AnyAsTargetChar!dchar(toFind);

        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return state.externalCount(iterator, toFindState.osat, caseSensitive, true, language) == 1;
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return state.externalCount(iterator, toFindState.osat, caseSensitive, true, language) == 1;
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return state.externalCount(iterator, toFindState.osat, caseSensitive, true, language) == 1;
        }, () { return false; });
    }

    ptrdiff_t offsetOfImpl(ToFind)(scope ToFind toFind, bool caseSensitive, bool onlyOnce,
            UnicodeLanguage language = UnicodeLanguage.Unknown) {
        if(isNull)
            return -1;

        scope toFindState = AnyAsTargetChar!dchar(toFind);

        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            return state.externalOffsetOf(iterator, toFindState.osat, caseSensitive, onlyOnce, language);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            return state.externalOffsetOf(iterator, toFindState.osat, caseSensitive, onlyOnce, language);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            return state.externalOffsetOf(iterator, toFindState.osat, caseSensitive, onlyOnce, language);
        }, () { return -1; });
    }

    void strip() {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalStrip(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) { assert(state !is null); state.externalStrip(iterator); },
                (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalStrip(iterator);
        }, () {});
    }

    void stripLeft() {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalStripLeft(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.externalStripLeft(iterator);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalStripLeft(iterator);
        }, () {});
    }

    void stripRight() {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalStripRight(iterator);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.externalStripRight(iterator);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalStripRight(iterator);
        }, () {});
    }

    void toLower(UnicodeLanguage language = UnicodeLanguage.Unknown) {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalToLower(iterator, language);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.externalToLower(iterator, language);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalToLower(iterator, language);
        }, () {});
    }

    void toUpper(UnicodeLanguage language = UnicodeLanguage.Unknown) {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalToUpper(iterator, language);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.externalToUpper(iterator, language);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalToUpper(iterator, language);
        }, () {});
    }

    void toTitle(UnicodeLanguage language = UnicodeLanguage.Unknown) {
        this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
            assert(state !is null);
            state.externalToTitle(iterator, language);
        }, (StateIterator.S16 state, StateIterator.I16 iterator) {
            assert(state !is null);
            state.externalToTitle(iterator, language);
        }, (StateIterator.S32 state, StateIterator.I32 iterator) {
            assert(state !is null);
            state.externalToTitle(iterator, language);
        }, () {});
    }

    bool empty() {
        return this.handle((StateIterator.S8 state, StateIterator.I8 iterator) {
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

    Char front(Char)() {
        return this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            return iterator.frontUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            return iterator.frontUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            return iterator.frontUTF!Char;
        }, () { assert(0); });
    }

    Char back(Char)() {
        return this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            return iterator.backUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            return iterator.backUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            return iterator.backUTF!Char;
        }, () { assert(0); });
    }

    void popFront(Char)() {
        this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            iterator.popFrontUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            iterator.popFrontUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            iterator.popFrontUTF!Char;
        }, () { assert(0); });
    }

    void popBack(Char)() {
        this.handle((StateIterator.S8 state, ref StateIterator.I8 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            iterator.popBackUTF!Char;
        }, (StateIterator.S16 state, ref StateIterator.I16 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            iterator.popBackUTF!Char;
        }, (StateIterator.S32 state, ref StateIterator.I32 iterator) {
            assert(state !is null);

            if(iterator is null) {
                iterator = state.newIterator();
            }

            iterator.popBackUTF!Char;
        }, () { assert(0); });
    }
}

struct UTF_State(Char) {
    import sidero.base.text.internal.builder.blocklist;
    import sidero.base.text.internal.builder.iteratorlist;
    import sidero.base.allocators.api;
    import sidero.base.text.unicode.casing : toUnicodeLowerCase, toUnicodeUpperCase, toUnicodeTitleCase;

    mixin template CustomIteratorContents() {
        void[4] forwardBuffer, backwardBuffer;
        void[] forwardItems, backwardItems;
        bool primedForwardsUTF, primedBackwardsUTF;
        bool primedForwardsNeedPop, primedBackwardsNeedPop;
        size_t amountFromInputForwards, amountFromInputBackwards;

        bool emptyUTF() {
            blockList.mutex.pureLock;
            scope(exit)
                blockList.mutex.unlock;

            version(none) {
                debug {
                    import std.stdio;

                    try {
                        writeln(forwardItems.length, " ", backwardItems.length, " ", emptyInternal(), " ",
                                primedForwards, " ", primedBackwards, " ", this.minimumOffsetFromHead, " <= ",
                                forwards.offsetFromHead, " <= ", backwards.offsetFromHead, " <= ", this.maximumOffsetFromHead);
                        stdout.flush;
                    } catch(Exception) {
                    }
                }
            }

            return forwardItems.length == 0 && backwardItems.length == 0 && emptyInternal();
        }

        TargetChar frontUTF(TargetChar)() @trusted {
            blockList.mutex.pureLock;
            scope(exit)
                blockList.mutex.unlock;

            const canRefill = !this.emptyInternal;
            const needRefill = this.forwardItems.length == 0;
            const needToUseOtherBuffer = !canRefill && needRefill && this.backwardItems.length > 0;
            assert(canRefill || !needRefill || needToUseOtherBuffer);

            if(needToUseOtherBuffer) {
                // take first in backwards buffer
                assert(this.backwardItems.length > 0);
                return (cast(TargetChar[])this.backwardItems)[0];
            } else if(!this.primedForwardsUTF) {
                primeForwardsUTF!TargetChar;
            }

            // take first in forwards buffer
            assert(this.forwardItems.length > 0);
            return (cast(TargetChar[])this.forwardItems)[0];
        }

        TargetChar backUTF(TargetChar)() @trusted {
            blockList.mutex.pureLock;
            scope(exit)
                blockList.mutex.unlock;

            const canRefill = !this.emptyInternal;
            const needRefill = this.backwardItems.length == 0;
            const needToUseOtherBuffer = !canRefill && needRefill && this.forwardItems.length > 0;
            assert(canRefill || !needRefill || needToUseOtherBuffer);

            if(needToUseOtherBuffer) {
                // take first in backwards buffer
                assert(this.forwardItems.length > 0);
                return (cast(TargetChar[])this.forwardItems)[$ - 1];
            } else if(!primedBackwardsUTF) {
                primeBackwardsUTF!TargetChar;
            }

            // take first in forwards buffer
            assert(this.backwardItems.length > 0);
            return (cast(TargetChar[])this.backwardItems)[$ - 1];
        }

        void popFrontUTF(TargetChar)() {
            blockList.mutex.pureLock;
            scope(exit)
                blockList.mutex.unlock;

            popFrontInternalUTF!TargetChar;
        }

        void popBackUTF(TargetChar)() {
            blockList.mutex.pureLock;
            scope(exit)
                blockList.mutex.unlock;

            popBackInternalUTF!TargetChar;
        }

        void primeForwardsUTF(TargetChar)() @trusted {
            import sidero.base.encoding.utf;

            const needRefill = this.forwardItems.length == 0;
            const needToUseOtherBuffer = this.emptyInternal && this.forwardItems.length == 0 && this.backwardItems.length > 0;

            Cursor forwardsTempDecodeCursor = forwards;

            bool emptyInternal() {
                if(primedBackwards) {
                    return backwards.offsetFromHead < forwardsTempDecodeCursor.offsetFromHead ||
                        forwardsTempDecodeCursor.offsetFromHead >= this.maximumOffsetFromHead;
                } else {
                    return forwardsTempDecodeCursor.offsetFromHead >= this.maximumOffsetFromHead;
                }
            }

            Char frontInternal() {
                forwardsTempDecodeCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsTempDecodeCursor.get();
            }

            void popFrontInternal() {
                if(primedBackwards) {
                    forwardsTempDecodeCursor.advanceForward(1, backwards.offsetFromHead + 1, true);
                } else {
                    forwardsTempDecodeCursor.advanceForward(1, maximumOffsetFromHead, true);
                }
            }

            if(needToUseOtherBuffer) {
                this.backwardItems = (cast(TargetChar[])this.backwardItems)[1 .. $];
                this.primedForwardsUTF = true;
                return;
            } else if(needRefill) {
                assert(!this.emptyInternal);

                TargetChar[4 / TargetChar.sizeof] charBuffer = void;
                size_t amountFilled;

                static if(is(Char == TargetChar)) {
                    // copy straight

                    if(!emptyInternal()) {
                        charBuffer[amountFilled++] = frontInternal();
                        popFrontInternal();
                        this.amountFromInputForwards = 1;
                    }
                } else static if(is(Char == char)) {
                    this.amountFromInputForwards = 0;
                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, this.amountFromInputForwards);

                    static if(is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if(is(Char == wchar)) {
                    this.amountFromInputForwards = 0;
                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, this.amountFromInputForwards);

                    static if(is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if(is(Char == dchar)) {
                    dchar decoded = this.frontInternal;
                    this.amountFromInputForwards = 1;

                    static if(is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else static if(is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    }
                }

                this.forwardBuffer = charBuffer;
                this.forwardItems = (cast(TargetChar[])this.forwardBuffer)[0 .. amountFilled];
                this.primedForwardsNeedPop = true;
            } else {
                this.forwardItems = (cast(TargetChar[])this.forwardItems)[1 .. $];
            }

            this.primedForwardsUTF = true;
            assert(this.forwardItems.length > 0 || this.emptyInternal());
        }

        void popFrontInternalUTF(TargetChar)() @trusted {
            foreach(_; 0 .. 1 + !this.primedForwardsUTF) {
                if(this.primedForwardsNeedPop) {
                    forwards.advanceForward(this.amountFromInputForwards, maximumOffsetFromHead, true);
                    this.primedForwardsNeedPop = false;
                    this.primedForwards = true;
                }

                const needRefill = this.forwardItems.length == 0;
                const needToUseOtherBuffer = this.emptyInternal && this.forwardItems.length == 0 && this.backwardItems.length > 0;

                if(needToUseOtherBuffer) {
                    auto items = cast(Char[])this.backwardItems;
                    assert(items.length > 0);
                    this.backwardItems = cast(void[])items[1 .. $];
                } else if(this.forwardItems.length > 0) {
                    auto items = cast(Char[])this.forwardItems;
                    this.forwardItems = cast(void[])items[1 .. $];
                }

                if(this.forwardItems.length == 0 && !this.emptyInternal) {
                    primeForwardsUTF!TargetChar();
                }
            }
        }

        void primeBackwardsUTF(TargetChar)() @trusted {
            import sidero.base.encoding.utf;

            primeBackwardsInternal;

            const canRefill = !this.emptyInternal;
            const needRefill = this.backwardItems.length == 0;
            const needToUseOtherBuffer = !canRefill && needRefill && this.forwardItems.length > 0;

            Cursor backwardsTempDecodeCursor = backwards;

            bool emptyInternal() {
                return backwardsTempDecodeCursor.offsetFromHead < forwards.offsetFromHead ||
                    forwards.offsetFromHead >= this.maximumOffsetFromHead;
            }

            Char backInternal() {
                if(!backwardsTempDecodeCursor.inData)
                    backwardsTempDecodeCursor.advanceBackwards(0, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
                return backwardsTempDecodeCursor.get();
            }

            void popBackInternal() {
                backwardsTempDecodeCursor.advanceBackwards(1, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
            }

            if(needToUseOtherBuffer) {
                this.forwardItems = (cast(TargetChar[])this.forwardItems)[0 .. $ - 1];
            } else if(needRefill) {
                assert(!this.emptyInternal);

                TargetChar[4 / TargetChar.sizeof] charBuffer = void;
                size_t amountFilled, offsetFilled;

                static if(is(Char == TargetChar)) {
                    // copy straight

                    if(!emptyInternal()) {
                        amountFilled++;
                        this.amountFromInputBackwards = 1;

                        charBuffer[$ - amountFilled] = backInternal();

                        popBackInternal();
                    }

                    offsetFilled = charBuffer.length - amountFilled;
                } else static if(is(Char == char)) {
                    this.amountFromInputBackwards = 0;
                    dchar decoded = decodeFromEnd(&emptyInternal, &backInternal, &popBackInternal, this.amountFromInputBackwards);

                    static if(is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if(is(Char == wchar)) {
                    this.amountFromInputBackwards = 0;
                    dchar decoded = decodeFromEnd(&emptyInternal, &backInternal, &popBackInternal, this.amountFromInputBackwards);

                    static if(is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else {
                        charBuffer[amountFilled++] = decoded;
                    }
                } else static if(is(Char == dchar)) {
                    dchar decoded = backInternal();
                    this.amountFromInputBackwards = 1;

                    static if(is(TargetChar == char)) {
                        amountFilled = encodeUTF8(decoded, charBuffer);
                    } else static if(is(TargetChar == wchar)) {
                        amountFilled = encodeUTF16(decoded, charBuffer);
                    }
                }

                this.backwardBuffer = charBuffer;
                this.backwardItems = (cast(TargetChar[])this.backwardBuffer)[offsetFilled .. offsetFilled + amountFilled];
                this.primedBackwardsNeedPop = true;
            } else {
                this.backwardItems = (cast(TargetChar[])this.backwardItems)[0 .. $ - 1];
            }

            this.primedBackwardsUTF = true;
        }

        void popBackInternalUTF(TargetChar)() @trusted {
            foreach(_; 0 .. 1 + !this.primedBackwardsUTF) {
                if(this.primedBackwardsNeedPop) {
                    backwards.advanceBackwards(this.amountFromInputBackwards, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
                    this.primedBackwardsNeedPop = false;
                    this.primedBackwards = true;
                }

                const canRefill = !this.emptyInternal;
                const needRefill = this.backwardItems.length == 0;
                const needToUseOtherBuffer = !canRefill && needRefill && this.forwardItems.length > 0;

                if(needToUseOtherBuffer) {
                    auto items = cast(Char[])this.forwardItems;
                    assert(items.length > 0);
                    this.forwardItems = cast(void[])(items[0 .. $ - 1]);
                    assert(items.length > (cast(Char[])this.forwardItems).length);
                } else if(this.backwardItems.length > 0) {
                    auto items = cast(Char[])this.backwardItems;
                    this.backwardItems = cast(void[])(items[0 .. $ - 1]);
                    assert(items.length > (cast(Char[])this.backwardItems).length);
                }

                if(this.backwardItems.length == 0 && !this.emptyInternal) {
                    primeBackwardsUTF!TargetChar();
                }
            }
        }
    }

    mixin StringBuilderOperations;

@safe nothrow @nogc @hidden:

    this(return scope RCAllocator allocator) scope @trusted {
        this.blockList = BlockList(allocator);
        this.blockList.refCount = 1;
    }

    //@disable this(this);

    ~this() {
    }

    void deallocateAllState() {
        RCAllocator allocator = blockList.allocator;
        blockList.clear;

        assert(iteratorList.head is null);
        assert(blockList.head.next.next is null);

        allocator.dispose(&this);
    }

    UnicodeLanguage language;

    UnicodeLanguage pickLanguage(UnicodeLanguage input = UnicodeLanguage.Unknown) const scope {
        import sidero.base.system : unicodeLanguage;

        if(input != UnicodeLanguage.Unknown)
            return input;
        else if(language != UnicodeLanguage.Unknown)
            return language;

        return unicodeLanguage();
    }

    void onInsert(scope const Char[] input) scope {
    }

    void onRemove(scope const Char[] input) scope {
    }

    static struct LiteralMatcher {
        const(Char)[] literal;

    @safe nothrow @nogc @hidden:

        bool matches(scope Cursor cursor, size_t maximumOffsetFromHead) {
            auto temp = literal;

            while(!cursor.isOutOfRange(0, maximumOffsetFromHead) && temp.length > 0) {
                size_t canDo = cursor.block.length - cursor.offsetIntoBlock;
                if(canDo > temp.length)
                    canDo = temp.length;

                auto got = cursor.block.get()[cursor.offsetIntoBlock .. $];
                foreach(i, c; temp[0 .. canDo])
                    if(got[i] != c)
                        return false;

                temp = temp[canDo .. $];
                cursor.advanceForward(canDo, maximumOffsetFromHead, true);
            }

            return temp.length == 0;
        }

        int compare(scope Cursor cursor, size_t maximumOffsetFromHead) {
            auto temp = literal;

            while(!cursor.isOutOfRange(0, maximumOffsetFromHead) && temp.length > 0) {
                size_t canDo = cursor.block.length - cursor.offsetIntoBlock;
                if(canDo > temp.length)
                    canDo = temp.length;

                auto got = cursor.block.get()[cursor.offsetIntoBlock .. $];
                foreach(i, a; temp[0 .. canDo]) {
                    Char b = got[i];

                    if(a < b)
                        return 1;
                    else if(a > b)
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

    @safe nothrow @nogc @hidden:

        void mutex(bool lock) {
            assert(state !is null);

            if(lock)
                state.blockList.mutex.pureLock;
            else
                state.blockList.mutex.unlock;
        }

        int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted {
            int result;

            static if(is(Char == TargetChar)) {
                if(iterator !is null) {
                    iterator.foreachBlocks((scope TargetChar[] data) {
                        if(data.length > 0)
                            result = del(data);
                        return result;
                    });
                } else {
                    foreach(Char[] data; state.blockList) {
                        if(data.length > 0)
                            result = del(data);

                        if(result)
                            break;
                    }
                }
            } else {
                import sidero.base.encoding.utf : decode, encode;

                Cursor forwards;

                if(iterator is null)
                    forwards.setup(&state.blockList, 0);
                else
                    forwards = iterator.forwards;

                size_t maximum() {
                    return iterator is null ? state.blockList.numberOfItems : (iterator.primedBackwards ?
                            iterator.backwards.offsetFromHead + 1 : iterator.maximumOffsetFromHead);
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

                while(!emptyInternal()) {
                    size_t consumed;
                    dchar got = decode(&emptyInternal, &frontInternal, &popFrontInternal, consumed);

                    static if(is(TargetChar == dchar)) {
                        dchar[1] buffer = [got];
                        TargetChar[] temp = buffer[];

                        result = del(temp);
                        if(result)
                            return result;
                    } else {
                        // encode
                        TargetChar[4 / TargetChar.sizeof] buffer = void;
                        TargetChar[] temp = buffer[0 .. encode(got, buffer)];

                        result = del(temp);
                        if(result)
                            return result;
                    }
                }
            }

            return result;
        }

        int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) {
            int result;

            static if(is(Char == TargetChar)) {
                if(iterator !is null) {
                    foreach(data; &iterator.foreachBlocks) {
                        foreach(c; data) {
                            result = del(c);

                            if(result)
                                return result;
                        }
                    }
                } else {
                    foreach(Char[] data; state.blockList) {
                        foreach(c; data) {
                            result = del(c);

                            if(result)
                                return result;
                        }
                    }
                }
            } else {
                import sidero.base.encoding.utf : decode, encode;

                Cursor forwards;

                if(iterator is null)
                    forwards.setup(&state.blockList, 0);
                else
                    forwards = iterator.forwards;

                size_t maximum() {
                    return iterator is null ? state.blockList.numberOfItems : (iterator.primedBackwards ?
                    iterator.backwards.offsetFromHead + 1 : iterator.maximumOffsetFromHead);
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

                while(!emptyInternal()) {
                    size_t consumed;
                    dchar got = decode(&emptyInternal, &frontInternal, &popFrontInternal, consumed);

                    static if(is(TargetChar == dchar)) {
                        result = del(got);
                        if(result)
                            return result;
                    } else {
                        // encode
                        TargetChar[4 / TargetChar.sizeof] buffer = void;
                        TargetChar[] temp = buffer[0 .. encode(got, buffer)];

                        foreach(c; temp) {
                            result = del(c);
                            if(result)
                                return result;
                        }
                    }
                }
            }

            return result;
        }

        ptrdiff_t length() {
            Cursor forwards;

            if(iterator is null)
                forwards.setup(&state.blockList, 0);
            else
                forwards = iterator.forwards;

            size_t maximum() {
                return iterator is null ? state.blockList.numberOfItems : (iterator.primedBackwards ?
                iterator.backwards.offsetFromHead + 1 : iterator.maximumOffsetFromHead);
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

            static if(is(Char == TargetChar)) {
                return iterator is null ? state.blockList.numberOfItems
                    : (iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead);
            } else {
                import sidero.base.encoding.utf : decode, encodeLengthUTF8, encodeLengthUTF16;

                size_t ret;

                while(!emptyInternal()) {
                    size_t consumed;
                    dchar got = decode(&emptyInternal, &frontInternal, &popFrontInternal, consumed);

                    static if(is(TargetChar == char)) {
                        // decode then encode
                        ret += encodeLengthUTF8(got);
                    } else static if(is(TargetChar == wchar)) {
                        // decode then encode
                        ret += encodeLengthUTF16(got);
                    } else static if(is(TargetChar == dchar)) {
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
        version(D_BetterC) {
        } else {
            debug {
                try {
                    import std.stdio;

                    Block* block = &blockList.head;
                    size_t offsetFromHead;

                    writeln("====================");

                    while(block !is null) {
                        if(block is cursorBlock)
                            write(">");
                        writef!"%s:%X@(%s)"(offsetFromHead, block, *block);
                        if(block is cursorBlock)
                            writef!":%s<"(offsetIntoBlock);
                        write("    [[[", cast(char[])block.get(), "]]]\n");

                        offsetFromHead += block.length;
                        block = block.next;
                    }

                    writeln;

                    foreach(iterator; iteratorList) {
                        try {
                            writef!"%X@"(iterator);
                            foreach(v; (*iterator).tupleof)
                                write(" ", v);
                            writeln;
                        } catch(Exception) {
                        }
                    }
                } catch(Exception) {
                }
            }
        }
    }

    void debugPosition(scope Iterator* iterator) @trusted {
        version(D_BetterC) {
        } else {
            debug {
                try {
                    import std.stdio;

                    writeln("====================");

                    if(iterator !is null) {
                        writef!">>%X@"(iterator);
                        foreach(v; (*iterator).tupleof)
                            write(" ", v);
                        writeln;
                    }

                    Block* block = &blockList.head;
                    size_t offsetFromHead;

                    while(block !is null) {
                        if(iterator !is null && block is iterator.forwards.block)
                            write(iterator.forwards.offsetIntoBlock, ">");
                        writef!"%s:%X@(%s)"(offsetFromHead, block, *block);
                        if(iterator !is null && block is iterator.backwards.block)
                            writef!":%s<"(iterator.backwards.offsetIntoBlock);
                        write("    [[[", cast(char[])block.get(), "]]]\n");

                        offsetFromHead += block.length;
                        block = block.next;
                    }

                    writeln;

                    foreach(iterator2; iteratorList) {
                        try {
                            if(iterator is iterator2)
                                write(">>>");
                            writef!"%X@"(iterator2);
                            foreach(v; (*iterator2).tupleof)
                                write(" ", v);
                            writeln;
                        } catch(Exception) {
                        }
                    }
                } catch(Exception) {
                }
            }
        }
    }

    static struct ForeachUTF32 {
        Cursor cursor;
        size_t maximumOffsetFromHead;
        // when delegate == 0
        size_t lastIteratedCount0;

    @safe nothrow @nogc @hidden:

        this(return scope Cursor cursor, size_t maximumOffsetFromHead) scope {
            this.cursor = cursor;
            this.maximumOffsetFromHead = maximumOffsetFromHead;
        }

        this(scope ref UTF_State state, scope Iterator* iterator, size_t offset, bool fromHead) scope {
            if(fromHead)
                cursor = state.cursorFor(iterator, maximumOffsetFromHead, offset);
            else {
                size_t offsetFromEnd = iterator is null ? state.blockList.numberOfItems : iterator.maximumOffsetFromHead;
                if(offsetFromEnd <= offset)
                    offsetFromEnd = 0;
                else
                    offsetFromEnd -= offset;

                cursor = state.cursorFor(iterator, maximumOffsetFromHead, offsetFromEnd);
            }

            cursor.advanceForward(0, maximumOffsetFromHead, true);
        }

        int opApply(scope int delegate(ref dchar) @safe nothrow @nogc del) scope {
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
                forwardsTempDecodeCursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            while(!emptyInternal() && result == 0) {
                static if(is(Char == dchar)) {
                    dchar decoded = frontInternal();
                    popFrontInternal();
                    assert(advance == 1);
                } else {
                    import sidero.base.encoding.utf : decode;

                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, advance);
                }

                result = del(decoded);
                if(result == 0)
                    lastIteratedCount0 += advance;
            }

            return result;
        }

        void advance1Forwards() {
            void popFrontInternal() {
                cursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            static if(is(Char == dchar)) {
                popFrontInternal();
            } else {
                import sidero.base.encoding.utf : decode;

                bool emptyInternal() {
                    return cursor.offsetFromHead >= maximumOffsetFromHead;
                }

                Char frontInternal() {
                    cursor.advanceForward(0, maximumOffsetFromHead, true);
                    return cursor.get();
                }

                size_t advance;
                dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, advance);
            }
        }
    }

    void checkForNullIterator() {
        foreach(iterator; iteratorList) {
            if(iterator.forwards.block is null && iterator.backwards.block is null) {
                assert(0);
            }
        }
    }

    // /\ Internal
    // \/ Exposed

    int externalOpCmp(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar other, bool caseSensitive, UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if(other.obj !is &this)
            other.mutex(true);

        debug checkForNullIterator;

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
        if(other.obj !is &this)
            other.mutex(false);

        debug checkForNullIterator;
        return result;
    }

    void externalNormalization(scope Iterator* iterator, UnicodeLanguage language, bool compatibility, bool composition) @trusted {
        import sidero.base.text.unicode.characters.database : isTurkic;
        import sidero.base.text.unicode.normalization : normalize;

        blockList.mutex.pureLock;
        debug checkForNullIterator;

        language = pickLanguage(language);
        RCAllocator allocator = blockList.allocator;

        ForeachUTF32 foreachUTF32 = ForeachUTF32(this, iterator, 0, true);
        Cursor cursor;
        size_t lengthToRemove;

        if(iterator !is null) {
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

        insertOperation(iterator, cursor, lengthToRemove, osat);
        removeOperation(iterator, cursor, lengthToRemove);

        allocator.dispose(cast(void[])got);
        debug checkForNullIterator;
        blockList.mutex.unlock;
    }

    bool externalStartsWith(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar other, bool caseSensitive,
            UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if(other.obj !is &this)
            other.mutex(true);
        debug checkForNullIterator;

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
        if(other.obj !is &this)
            other.mutex(false);

        debug checkForNullIterator;
        return result == 0;
    }

    bool externalEndsWith(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar other, bool caseSensitive, UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if(other.obj !is &this)
            other.mutex(true);
        debug checkForNullIterator;

        language = pickLanguage(language);
        int result;

        // this may be costly, but this is in fact the best way to do it
        {
            size_t otherLength = other.length(), usLength;

            if(iterator !is null)
                usLength = iterator.backwards.offsetFromHead;
            else
                usLength = blockList.numberOfItems;

            if(otherLength > usLength) {
                debug checkForNullIterator;
                blockList.mutex.unlock;
                if(other.obj !is &this)
                    other.mutex(false);

                return false;
            }

            ptrdiff_t minimumOffsetFromHead = otherLength, maximumOffsetFromHead = usLength;
            minimumOffsetFromHead = -minimumOffsetFromHead;
            changeIndexToOffset(iterator, minimumOffsetFromHead, maximumOffsetFromHead);

            iterator = iteratorList.newIterator(&blockList, minimumOffsetFromHead, maximumOffsetFromHead);
            debug checkForNullIterator;
        }

        OtherStateIsUs!dchar osiu;
        osiu.state = &this;
        osiu.iterator = iterator;
        scope osat = osiu.get;

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(other.foreachValue, caseSensitive);
        result = cac.compare(osat.foreachValue, true);

        iteratorList.rcIteratorInternal(false, iterator);

        debug checkForNullIterator;
        blockList.mutex.unlock;
        if(other.obj !is &this)
            other.mutex(false);

        return result == 0;
    }

    size_t externalReplace(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar toFind,
            scope ref OtherStateAsTarget!Char toReplace, bool caseSensitive, bool onlyOnce, UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if(toFind.obj !is &this)
            toFind.mutex(true);
        if(toReplace.obj !is &this && toReplace.obj !is toFind.obj)
            toReplace.mutex(true);
        debug checkForNullIterator;

        language = pickLanguage(language);

        size_t maximumOffsetFromHead;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(toFind.foreachValue, caseSensitive);

        size_t ret = replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) @trusted nothrow @nogc {
            ForeachUTF32 f32 = ForeachUTF32(cursor, maximumOffsetFromHead);

            auto got = cac.compare(&f32.opApply, true);
            if(got != 0)
                return 0;

            return f32.lastIteratedCount0;
        }, (scope Iterator* iterator, scope ref Cursor cursor) @trusted {
            return insertOperation(iterator, cursor, toReplace);
        }, true, onlyOnce);

        debug checkForNullIterator;
        blockList.mutex.unlock;
        if(toFind.obj !is &this)
            toFind.mutex(false);
        if(toReplace.obj !is &this && toReplace.obj !is toFind.obj)
            toReplace.mutex(false);

        return ret;
    }

    size_t externalCount(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar toFind, bool caseSensitive,
            bool onlyOnce, UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if(toFind.obj !is &this)
            toFind.mutex(true);
        debug checkForNullIterator;

        language = pickLanguage(language);

        size_t maximumOffsetFromHead, lastConsumed;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(toFind.foreachValue, caseSensitive);

        size_t ret = replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) @trusted nothrow @nogc {
            ForeachUTF32 f32 = ForeachUTF32(cursor, maximumOffsetFromHead);

            auto got = cac.compare(&f32.opApply, true);
            if(got != 0)
                return 0;

            lastConsumed = f32.lastIteratedCount0;
            assert(lastConsumed != 0);
            return lastConsumed;
        }, (scope Iterator* iterator, scope ref Cursor cursor) {
            cursor.advanceForward(lastConsumed, maximumOffsetFromHead, true);
            return size_t(0);
        }, false, onlyOnce);

        debug checkForNullIterator;
        blockList.mutex.unlock;
        if(toFind.obj !is &this)
            toFind.mutex(false);

        return ret;
    }

    ptrdiff_t externalOffsetOf(scope Iterator* iterator, scope ref OtherStateAsTarget!dchar toFind, bool caseSensitive,
            bool onlyOnce, UnicodeLanguage language) @trusted {
        import sidero.base.text.unicode.comparison : CaseAwareComparison;
        import sidero.base.text.unicode.characters.database : isTurkic;

        blockList.mutex.pureLock;
        if(toFind.obj !is &this)
            toFind.mutex(true);
        debug checkForNullIterator;

        language = pickLanguage(language);

        size_t maximumOffsetFromHead, lastConsumed;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);
        const startingOffset = cursor.offsetFromHead;

        CaseAwareComparison cac = CaseAwareComparison(blockList.allocator, language.isTurkic);
        cac.setAgainst(toFind.foreachValue, caseSensitive);

        ptrdiff_t ret = -1;
        replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) @trusted nothrow @nogc {
            ForeachUTF32 f32 = ForeachUTF32(cursor, maximumOffsetFromHead);

            auto got = cac.compare(&f32.opApply, true);
            if(got != 0)
                return 0;

            lastConsumed = f32.lastIteratedCount0;
            assert(lastConsumed != 0);
            return lastConsumed;
        }, (scope Iterator* iterator, scope ref Cursor cursor) {
            ret = cursor.offsetFromHead;
            cursor.advanceForward(lastConsumed, maximumOffsetFromHead, true);
            return size_t(0);
        }, false, onlyOnce);

        debug checkForNullIterator;
        blockList.mutex.unlock;
        if(toFind.obj !is &this)
            toFind.mutex(false);

        if(ret >= 0)
            ret -= startingOffset;

        return ret;
    }

    void externalStrip(scope Iterator* iterator) scope {
        externalStripLeft(iterator);
        externalStripRight(iterator);
    }

    void externalStripLeft(scope Iterator* iterator) scope {
        import sidero.base.text.unicode.characters.database : isWhiteSpace, isControl;

        blockList.mutex.pureLock;

        size_t maximumOffsetFromHead, lastConsumed;
        scope Cursor toRemoveCursor = cursorFor(iterator, maximumOffsetFromHead, 0);
        const startingOffset = toRemoveCursor.offsetFromHead;

        {
            ForeachUTF32 f32 = ForeachUTF32(toRemoveCursor, maximumOffsetFromHead);

            foreach(dchar c; f32) {
                if(!(isWhiteSpace(c) || isControl(c)))
                    break;
            }

            if(f32.lastIteratedCount0 > 0)
                removeOperation(toRemoveCursor, maximumOffsetFromHead, f32.lastIteratedCount0);
        }

        blockList.mutex.unlock;
    }

    void externalStripRight(scope Iterator* iterator) scope @trusted {
        import sidero.base.text.unicode.characters.database : isWhiteSpace, isControl;

        blockList.mutex.pureLock;

        ptrdiff_t endOffsetFromHead = -1;
        {
            auto result = changeIndexToOffset(iterator, endOffsetFromHead);
            assert(!result.isSet);

            if(iterator !is null)
                endOffsetFromHead -= iterator.minimumOffsetFromHead;
        }

        size_t minimumOffsetFromHead, maximumOffsetFromHead, lastConsumed;
        scope Cursor toRemoveCursor = cursorFor(iterator, minimumOffsetFromHead, maximumOffsetFromHead, endOffsetFromHead);
        const startingOffset = toRemoveCursor.offsetFromHead;

        {
            Cursor lastSuccessRemove = toRemoveCursor;
            size_t amount;

            bool emptyInternal() {
                return toRemoveCursor.offsetFromHead < minimumOffsetFromHead || !toRemoveCursor.inData;
            }

            Char backInternal() {
                toRemoveCursor.advanceBackwards(0, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
                return toRemoveCursor.get();
            }

            void popBackInternal() {
                toRemoveCursor.advanceBackwards(1, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
            }

            while(!emptyInternal) {
                Cursor currentLocation = toRemoveCursor;
                size_t advance = 1;

                static if(is(Char == dchar)) {
                    dchar decoded = backInternal();
                    popBackInternal();
                } else {
                    import sidero.base.encoding.utf : decodeFromEnd;

                    dchar decoded = decodeFromEnd(&emptyInternal, &backInternal, &popBackInternal, advance);
                }

                if(!(isWhiteSpace(decoded) || isControl(decoded)))
                    break;
                amount += advance;
                lastSuccessRemove = currentLocation;
            }

            if(amount > 0)
                removeOperation(lastSuccessRemove, maximumOffsetFromHead, amount);
        }

        blockList.mutex.unlock;
    }

    alias externalToLower = casingImpl!toUnicodeLowerCase;
    alias externalToUpper = casingImpl!toUnicodeUpperCase;
    alias externalToTitle = casingImpl!toUnicodeTitleCase;

    void casingImpl(alias UNIcaseFunc)(scope Iterator* iterator, UnicodeLanguage language) @trusted {
        blockList.mutex.pureLock;
        language = pickLanguage(language);

        size_t minimumOffsetFromHead, maximumOffsetFromHead;
        scope Cursor cursor = cursorFor(iterator, minimumOffsetFromHead, maximumOffsetFromHead, 0);
        size_t primaryAdvance = 1;
        bool removedOrInserted;

        int primaryForwardsFunc(scope int delegate(ref dchar) @safe nothrow @nogc del) @trusted {
            int ret;

            bool emptyInternal() {
                cursor.advanceForward(0, maximumOffsetFromHead, true);
                return cursor.isOutOfRange(minimumOffsetFromHead, maximumOffsetFromHead);
            }

            Char frontInternal() {
                cursor.advanceForward(0, maximumOffsetFromHead, true);
                return cursor.get();
            }

            void popFrontInternal() {
                cursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            while(ret == 0 && cursor.inData && !emptyInternal) {
                static if(is(Char == dchar)) {
                    dchar decoded = frontInternal();
                    assert(primaryAdvance == 1);
                } else {
                    import sidero.base.encoding.utf : decode;

                    Cursor restoreCursor = cursor, otherCursor;
                    dchar decoded = decode(&emptyInternal, &frontInternal, &popFrontInternal, primaryAdvance);
                    otherCursor = cursor;
                    cursor = restoreCursor;
                }

                ret = del(decoded);

                if(!removedOrInserted) {
                    static if(is(Char == dchar)) {
                        popFrontInternal();
                    } else {
                        cursor = otherCursor;
                    }
                }

                removedOrInserted = false;
            }

            return ret;
        }

        int secondaryForwardsFunc(scope int delegate(ref dchar) @safe nothrow @nogc del) {
            ForeachUTF32 f32 = ForeachUTF32(cursor, maximumOffsetFromHead);
            f32.advance1Forwards();
            return f32.opApply(del);
        }

        int secondaryBackwardsFunc(scope int delegate(ref dchar) @safe nothrow @nogc del) {
            // first we need a cursor position prior to our current cursor location

            Cursor backwardsCursor = cursor;
            backwardsCursor.advanceBackwards(1, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
            if(backwardsCursor.offsetFromHead >= cursor.offsetFromHead)
                return 0;

            bool emptyInternal() {
                return backwardsCursor.offsetFromHead < minimumOffsetFromHead || !backwardsCursor.inData;
            }

            Char backInternal() {
                backwardsCursor.advanceBackwards(0, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
                return backwardsCursor.get();
            }

            void popBackInternal() {
                backwardsCursor.advanceBackwards(1, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
            }

            int result;

            while(result == 0 && !emptyInternal) {
                static if(is(Char == dchar)) {
                    dchar decoded = backInternal();
                    popBackInternal();
                } else {
                    import sidero.base.encoding.utf : decodeFromEnd;

                    size_t advance;
                    dchar decoded = decodeFromEnd(&emptyInternal, &backInternal, &popBackInternal, advance);
                }

                result = del(decoded);
            }

            return result;
        }

        void removeThis() {
            removeOperation(cursor, maximumOffsetFromHead, primaryAdvance);
            maximumOffsetFromHead -= primaryAdvance;
            removedOrInserted = true;
        }

        void insertHere(scope dstring text) @trusted {
            scope LiteralAsTargetChar!(dchar, Char) latc;
            latc.literal = text;
            auto osat = latc.get;
            maximumOffsetFromHead += insertOperation(iterator, cursor, maximumOffsetFromHead, osat);
            removedOrInserted = true;
        }

        auto result = UNIcaseFunc(&primaryForwardsFunc, &secondaryForwardsFunc, &secondaryBackwardsFunc,
                &removeThis, &insertHere, language);
        blockList.mutex.unlock;
    }
}

struct LiteralAsTargetChar(SourceChar, TargetChar) {
    const(SourceChar)[] literal;

@safe nothrow @nogc:

    void mutex(bool) {
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
        static if(is(SourceChar == TargetChar)) {
            // don't mutate during testing
            TargetChar[] temp = cast(TargetChar[])literal;
            if(temp.length > 0)
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

        static if(is(SourceChar == TargetChar) || is(SourceChar == dchar)) {
            foreach(SourceChar c; literal) {
                static if(is(SourceChar == TargetChar)) {
                    result = del(c);
                } else if(is(SourceChar == dchar)) {
                    // just encode
                    TargetChar[4 / TargetChar.sizeof] buffer = void;
                    TargetChar[] temp = buffer[0 .. encode(c, buffer)];

                    foreach(c2; temp) {
                        result = del(c2);
                        if(result)
                            break;
                    }
                }

                if(result)
                    break;
            }
        } else {
            // decode then encode
            decode(literal, (dchar got) {
                static if(is(TargetChar == dchar)) {
                    result = del(got);
                    if(result)
                        return true;
                } else {
                    TargetChar[4 / TargetChar.sizeof] buffer = void;
                    scope temp = buffer[0 .. encode(got, buffer)];

                    foreach(TargetChar c; temp) {
                        result = del(c);
                        if(result)
                            return true;
                    }
                }

                return false;
            });
        }

        return result;
    }

    ptrdiff_t length() {
        import sidero.base.encoding.utf : encodeLengthUTF8, encodeLengthUTF16, decode;

        static if(is(SourceChar == TargetChar)) {
            return literal.length;
        } else static if(is(SourceChar == dchar)) {
            // just encode
            static if(is(TargetChar == char)) {
                return encodeLengthUTF8(literal);
            } else static if(is(TargetChar == wchar)) {
                return encodeLengthUTF16(literal);
            }
        } else {
            // decode then encode
            size_t ret;

            decode(literal, (dchar got) {
                static if(is(TargetChar == char)) {
                    ret += encodeLengthUTF8(got);
                } else static if(is(TargetChar == wchar)) {
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

@safe nothrow @nogc @hidden:

    void mutex(bool) {
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted {
        // don't mutate during testing
        static if(is(TargetChar == char)) {
            TargetChar[] temp = cast(TargetChar[])literal;
            if(temp.length > 0)
                return del(temp);
            else
                return 0;
        } else {
            TargetChar[1] temp1 = void;
            TargetChar[] temp2;
            int result;

            foreach(c; literal) {
                temp2 = temp1[];
                temp1[0] = cast(TargetChar)c;

                result = del(temp2);

                if(result)
                    break;
            }

            return result;
        }
    }

    int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) @safe {
        int result;

        foreach(c; literal) {
            TargetChar temp = cast(TargetChar)c;
            result = del(temp);

            if(result)
                break;
        }

        return result;
    }

    ptrdiff_t length() {
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

@safe nothrow @nogc @hidden:

    void mutex(bool lock) {
        assert(state !is null);

        if(lock)
            state.blockList.mutex.pureLock;
        else
            state.blockList.mutex.unlock;
    }

    int foreachContiguous(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @trusted {
        int result;

        if(iterator !is null) {
            iterator.foreachBlocks((scope data) {
                if(data.length == 0)
                    return 0;

                static if(is(TargetChar == char)) {
                    TargetChar[] temp = cast(TargetChar[])data;
                    result = del(temp);
                } else {
                    TargetChar[1] temp1 = void;
                    TargetChar[] temp2;

                    foreach(c; data) {
                        temp2 = temp1[];
                        temp1[0] = cast(TargetChar)c;

                        result = del(temp2);
                        if(result)
                            break;
                    }
                }

                return result;
            });
        } else {
            foreach(ubyte[] data; state.blockList) {
                static if(is(TargetChar == char)) {
                    TargetChar[] temp = cast(TargetChar[])data;
                    result = del(temp);
                } else {
                    TargetChar[1] temp1 = void;
                    TargetChar[] temp2;

                    foreach(c; data) {
                        temp2 = temp1[];
                        temp1[0] = cast(TargetChar)c;

                        result = del(temp2);
                        if(result)
                            break;
                    }
                }

                if(result)
                    break;
            }
        }

        return result;
    }

    int foreachValue(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) {
        int result;

        if(iterator !is null) {
            iterator.foreachBlocks((scope data) {
                foreach(c; data) {
                    TargetChar temp = cast(TargetChar)c;
                    result = del(temp);

                    if(result)
                        break;
                }

                return result;
            });
        } else {
            foreach(ubyte[] data; state.blockList) {
                foreach(c; data) {
                    TargetChar temp = cast(TargetChar)c;
                    result = del(temp);

                    if(result)
                        return result;
                }
            }
        }

        return result;
    }

    ptrdiff_t length() {
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

@safe nothrow @nogc @hidden:

    this(Input)(scope ref Input input) @trusted {
        static if(is(Input == String_ASCII)) {
            input.stripZeroTerminator;
            scope actualInput = input.literal;
        } else {
            scope actualInput = input;
        }

        static if(is(Input == StringBuilder_ASCII)) {
            asat.state = input.state;
            asat.iterator = input.iterator;
            osat = asat.get();
        } else static if(isUTFBuilder!Input) {
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
            }, () {});
        } else static if(isUTFReadOnly!Input) {
            input.stripZeroTerminator;

            input.literalEncoding.handle(() @trusted { latc8.literal = cast(string)input.literal; osat = latc8.get(); }, () @trusted {
                latc16.literal = cast(wstring)input.literal;
                osat = latc16.get();
            }, () @trusted { latc32.literal = cast(dstring)input.literal; osat = latc32.get(); }, () @trusted {});
        } else static if(is(typeof(actualInput) == const(char)[])) {
            latc8.literal = input;
            osat = latc8.get();
        } else static if(is(typeof(actualInput) == const(wchar)[])) {
            latc16.literal = input;
            osat = latc16.get();
        } else static if(is(typeof(actualInput) == const(dchar)[])) {
            latc32.literal = input;
            osat = latc32.get();
        } else static if(is(typeof(actualInput) == const(ubyte)[])) {
            alat.literal = cast(const(ubyte)[])actualInput;
            osat = alat.get();
        } else
            static assert(0, typeof(actualInput).stringof);
    }
}
