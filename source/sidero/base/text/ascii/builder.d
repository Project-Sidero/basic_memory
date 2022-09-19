module sidero.base.text.ascii.builder;
import sidero.base.text.ascii.readonly;
import sidero.base.allocators.api;

///
struct StringBuilder_ASCII {
    ///
    alias Char = ubyte;
    ///
    alias LiteralType = immutable(Char)[];

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            auto oldIterator = this.iterator;
            iterator = state.newIterator(oldIterator);

            scope (exit) {
                state.rcIterator(false, iterator);
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

            auto oldIterator = this.iterator;
            iterator = state.newIterator(oldIterator);

            scope (exit) {
                state.rcIterator(false, iterator);
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

    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        static Text = cast(LiteralType)"Hello there!";
        StringBuilder_ASCII text = StringBuilder_ASCII(Text);

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
        StringBuilder_ASCII text = StringBuilder_ASCII(Text);

        size_t lastIndex = Text.length;

        foreach_reverse (c; text) {
            assert(lastIndex > 0);
            lastIndex--;
            assert(Text[lastIndex] == c);
        }

        assert(lastIndex == 0);
    }

nothrow @safe:

    void opAssign(ref StringBuilder_ASCII other) @nogc {
        __ctor(other);
    }

    void opAssign(StringBuilder_ASCII other) @nogc {
        __ctor(other);
    }

    @disable void opAssign(ref StringBuilder_ASCII other) const;
    @disable void opAssign(StringBuilder_ASCII other) const;

    @disable auto opCast(T)();

    this(ref return scope StringBuilder_ASCII other) @trusted scope @nogc {
        import core.atomic : atomicOp;

        this.tupleof = other.tupleof;

        if (state !is null)
            state.rcIterator(true, iterator);
    }

    @disable this(ref return scope StringBuilder_ASCII other) @safe scope const;

    @disable this(ref const StringBuilder_ASCII other) const;
    @disable this(this);

    ///
    this(InputChar)(RCAllocator allocator, scope const(InputChar)[] input) @trusted
            if (is(InputChar == ubyte) || is(InputChar == char)) {
        this.__ctor(input, allocator);
    }

    ///
    @trusted unittest {
        static literal8 = ["Ding dong gonna bang it", "gimmie dat coco now", "so we'll want that coco now"];

        foreach (entry; 0 .. literal8.length) {
            auto input = literal8[entry];
            auto output = literal8[entry];

            StringBuilder_ASCII builder = StringBuilder_ASCII(RCAllocator.init, input);

            foreach (c; builder) {
                assert(c == output[0]);
                output = output[1 .. $];
            }

            assert(output.length == 0);
        }
    }

    ///
    this(InputChar)(scope const(InputChar)[] input, RCAllocator allocator = RCAllocator.init) @trusted
            if (is(InputChar == ubyte) || is(InputChar == char)) {
        setupState(allocator);
        assert(state !is null);

        ASCII_State.LiteralAsTarget latc;
        latc.literal = cast(LiteralType)input;
        auto osat = latc.get;

        state.externalInsert(iterator, 0, osat);
    }

    ///
    @trusted unittest {
        static literal8 = ["Ding dong gonna bang it", "gimmie dat coco now", "so we'll want that coco now"];

        foreach (entry; 0 .. literal8.length) {
            auto input = literal8[entry];
            auto output = literal8[entry];

            StringBuilder_ASCII builder = StringBuilder_ASCII(input);

            foreach (c; builder) {
                assert(c == output[0]);
                output = output[1 .. $];
            }

            assert(output.length == 0);
        }
    }

    ///
    ~this() scope @nogc {
        if (state !is null)
            state.rcIterator(false, iterator);
    }

    ///
    bool isNull() scope @nogc {
        return state is null || (iterator !is null && iterator.empty);
    }

    ///
    unittest {
        StringBuilder_ASCII stuff;
        assert(stuff.isNull);

        stuff = StringBuilder_ASCII("Abc");
        assert(!stuff.isNull);

        stuff = stuff[1 .. 1];
        assert(stuff.isNull);
    }

    ///
    bool haveIterator() scope @nogc {
        return iterator !is null;
    }

    ///
    unittest {
        StringBuilder_ASCII thing = StringBuilder_ASCII("bar");
        assert(!thing.haveIterator);

        assert(!thing.empty);
        thing.popFront;

        assert(thing.haveIterator);
    }

    ///
    StringBuilder_ASCII withoutIterator() scope @trusted @nogc {
        StringBuilder_ASCII ret;

        if (state !is null) {
            state.rc(true);
            ret.state = state;
        }

        return ret;
    }

    ///
    unittest {
        StringBuilder_ASCII stuff = StringBuilder_ASCII("I have no iterator!");
        assert(stuff.tupleof == stuff.withoutIterator.tupleof);

        stuff.popFront;
        assert(stuff.tupleof != stuff.withoutIterator.tupleof);
    }

    ///
    StringBuilder_ASCII opIndex(size_t index) scope @nogc {
        return this[index .. index + 1];
    }

    ///
    StringBuilder_ASCII opSlice(size_t start, size_t end) scope @trusted @nogc {
        StringBuilder_ASCII ret;

        if (state !is null) {
            ret.state = state;
            ret.iterator = state.newIterator(iterator, start, end);
        }

        return ret;
    }

    ///
    unittest {
        StringBuilder_ASCII original = StringBuilder_ASCII("split me here");
        StringBuilder_ASCII split = original[6 .. 8];

        assert(split.length == 2);
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope @nogc {
        return state !is null ? state.externalLength(iterator) : 0;
    }

    ///
    unittest {
        StringBuilder_ASCII stack = StringBuilder_ASCII(cast(LiteralType)"hmm...");
        assert(stack.length == 6);
    }

    // TODO: dup
    // TODO: asReadOnly

    ///
    bool opCast(T : bool)() scope const @nogc {
        return !isNull;
    }

    @disable auto opCast(T)();

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope const(char)[] other) scope @nogc {
        return opCmpImplSlice(other, true) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first == "first");
        assert(first != "third");
    }

    ///
    bool opEquals(scope LiteralType other) scope @nogc {
        return opCmp(other) == 0;
    }

    ///
    @trusted unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first == cast(LiteralType)['f', 'i', 'r', 's', 't']);
        assert(first != cast(LiteralType)['t', 'h', 'i', 'r', 'd']);
    }

    ///
    bool opEquals(scope String_ASCII other) scope @nogc {
        return opCmpImplSlice(other.literal, true) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");
        String_ASCII notFirst = String_ASCII("first");
        String_ASCII third = String_ASCII("third");

        assert(first == notFirst);
        assert(first != third);
    }

    ///
    bool opEquals(scope StringBuilder_ASCII other) scope @nogc {
        return opCmpImplBuilder(other, true) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");
        StringBuilder_ASCII notFirst = StringBuilder_ASCII("first");
        StringBuilder_ASCII third = StringBuilder_ASCII("third");

        assert(first == notFirst);
        assert(first != third);
    }

    ///
    bool ignoreCaseEquals(scope const(char)[] other) scope @nogc {
        return opCmpImplSlice(other, false) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first.ignoreCaseEquals("fIrst"));
        assert(!first.ignoreCaseEquals("third"));
    }

    ///
    bool ignoreCaseEquals(scope LiteralType other) scope @nogc {
        return ignoreCaseCompare(other) == 0;
    }

    ///
    @trusted unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first.ignoreCaseEquals(cast(LiteralType)['f', 'I', 'r', 's', 't']));
        assert(!first.ignoreCaseEquals(cast(LiteralType)['t', 'h', 'i', 'r', 'd']));
    }

    ///
    bool ignoreCaseEquals(scope String_ASCII other) scope @nogc {
        return opCmpImplSlice(other.literal, false) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");
        String_ASCII notFirst = String_ASCII("fIrst");
        String_ASCII third = String_ASCII("third");

        assert(first.ignoreCaseEquals(notFirst));
        assert(!first.ignoreCaseEquals(third));
    }

    ///
    bool ignoreCaseEquals(scope StringBuilder_ASCII other) scope @nogc {
        return opCmpImplBuilder(other, false) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");
        StringBuilder_ASCII notFirst = StringBuilder_ASCII("fIrst");
        StringBuilder_ASCII third = StringBuilder_ASCII("third");

        assert(first.ignoreCaseEquals(notFirst));
        assert(!first.ignoreCaseEquals(third));
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope const(char)[] other) scope @nogc {
        return opCmpImplSlice(other, true);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("a") < "z");
        assert(StringBuilder_ASCII("z") > "a");
    }

    ///
    int opCmp(scope LiteralType other) scope @nogc {
        return opCmpImplSlice(other, true);
    }

    ///
    @trusted unittest {
        assert(StringBuilder_ASCII("a") < cast(LiteralType)['z']);
        assert(StringBuilder_ASCII("z") > cast(LiteralType)['a']);
    }

    ///
    int opCmp(scope String_ASCII other) scope @nogc {
        return opCmpImplSlice(other.literal, true);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("a") < String_ASCII("z"));
        assert(StringBuilder_ASCII("z") > String_ASCII("a"));
    }

    ///
    int opCmp(scope StringBuilder_ASCII other) scope @nogc {
        return opCmpImplBuilder(other, true);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("a") < StringBuilder_ASCII("z"));
        assert(StringBuilder_ASCII("z") > StringBuilder_ASCII("a"));
    }

    ///
    int ignoreCaseCompare(scope const(char)[] other) scope @nogc {
        return opCmpImplSlice(other, false);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare("z") < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare("a") > 0);
    }

    ///
    int ignoreCaseCompare(scope LiteralType other) scope @nogc {
        return opCmpImplSlice(other, false);
    }

    ///
    @trusted unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare(cast(LiteralType)['z']) < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare(cast(LiteralType)['a']) > 0);
    }

    ///
    int ignoreCaseCompare(scope String_ASCII other) scope @nogc {
        return opCmpImplSlice(other.literal, false);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare(String_ASCII("z")) < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare(String_ASCII("a")) > 0);
    }

    ///
    int ignoreCaseCompare(scope StringBuilder_ASCII other) scope @nogc {
        return opCmpImplBuilder(other, false);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare(StringBuilder_ASCII("z")) < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare(StringBuilder_ASCII("a")) > 0);
    }

    ///
    bool empty() scope @nogc {
        return state is null ? true : (iterator is null ? (this.length == 0) : iterator.empty);
    }

    ///
    unittest {
        StringBuilder_ASCII thing;
        assert(thing.empty);

        thing = StringBuilder_ASCII(cast(LiteralType)"bar");
        assert(!thing.empty);
    }

    ///
    Char front() scope @nogc {
        assert(state !is null);

        if (iterator is null) {
            iterator = state.newIterator();
            state.rc(false);
        }

        return iterator.front;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";

        StringBuilder_ASCII text = StringBuilder_ASCII(Text8);

        foreach (i, c; Text8) {
            auto got = text.front;

            assert(!text.empty);
            assert(got == c);
            text.popFront;
        }

        assert(text.empty);
    }

    ///
    Char back() scope @nogc {
        assert(state !is null);

        if (iterator is null) {
            iterator = state.newIterator();
            state.rc(false);
        }

        return iterator.back;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";

        StringBuilder_ASCII text = StringBuilder_ASCII(Text8);

        foreach_reverse (i, c; Text8) {
            auto got = text.back;

            assert(!text.empty);
            assert(got == c);
            text.popBack;
        }

        assert(text.empty);
    }

    ///
    void popFront() scope @nogc {
        assert(state !is null);

        if (iterator is null) {
            iterator = state.newIterator();
            state.rc(false);
        }

        iterator.popFront;
    }

    ///
    void popBack() scope @nogc {
        assert(state !is null);

        if (iterator is null) {
            iterator = state.newIterator();
            state.rc(false);
        }

        iterator.popBack;
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

    ///
    ulong toHash() scope @trusted @nogc {
        import sidero.base.hash.fnv : fnv_64_1a;

        ulong ret = fnv_64_1a(null);

        foreachContiguous((scope ref data) { ret = fnv_64_1a(cast(ubyte[])data); return 0; });

        return ret;
    }

    ///
    unittest {
        static Text8 = "ok it's a live";

        StringBuilder_ASCII text = StringBuilder_ASCII(Text8);
        assert(text.toHash() == 1586511100919779533);
    }

package(sidero.base.text):
    ASCII_State* state;
    ASCII_State.Iterator* iterator;

    int foreachContiguous(scope int delegate(ref scope Char[] data) @safe nothrow @nogc del) scope @nogc {
        if (state is null)
            return 0;

        ASCII_State.OtherStateIsUs osiu;
        osiu.state = state;
        osiu.iterator = iterator;

        scope osat = osiu.get;

        osat.mutex(true);
        int result = osat.foreachContiguous(del);
        osat.mutex(false);

        return result;
    }

private:
    void setupState(RCAllocator allocator = RCAllocator.init) @nogc @trusted {
        if (allocator.isNull)
            allocator = globalAllocator();

        if (state is null)
            state = allocator.make!ASCII_State(allocator);
    }

    @disable void setupState(RCAllocator allocator = RCAllocator.init) const @nogc;

    void debugPosition() @nogc {
        assert(state !is null);
        state.debugPosition(iterator);
    }

    scope @nogc {
        int opCmpImplSlice(scope const(char)[] other, bool caseSensitive) @trusted {
            return opCmpImplSlice(cast(LiteralType)other, caseSensitive);
        }

        int opCmpImplSlice(scope const(Char)[] other, bool caseSensitive) @trusted {
            ASCII_State.LiteralAsTarget lat;
            lat.literal = other;
            scope osiu = lat.get;

            if (isNull) {
                if (other.length > 0)
                    return -1;
                else
                    return 0;
            } else
                return state.externalOpCmp(iterator, osiu, caseSensitive);
        }

        int opCmpImplBuilder(scope StringBuilder_ASCII other, bool caseSensitive) @trusted {
            ASCII_State.OtherStateIsUs asiu;
            asiu.state = other.state;
            asiu.iterator = other.iterator;
            scope osiu = asiu.get;

            if (isNull) {
                if (other.length > 0)
                    return -1;
                else
                    return 0;
            } else
                return state.externalOpCmp(iterator, osiu, caseSensitive);
        }
    }
}

package(sidero.base.text):

struct ASCII_State {
    import sidero.base.text.internal.builder.blocklist;
    import sidero.base.text.internal.builder.iteratorlist;
    import sidero.base.text.internal.builder.operations;
    import sidero.base.allocators.api;

    alias Char = ubyte;

    mixin template CustomIteratorContents() {
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

    struct LiteralAsTarget {
        const(Char)[] literal;

    @safe nothrow @nogc:

        void mutex(bool) {
        }

        int foreachContiguous(scope int delegate(scope ref  /* ignore this */ Char[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
            // don't mutate during testing
            Char[] temp = cast(Char[])literal;
            return del(temp);
        }

        int foreachValue(scope int delegate(ref  /* ignore this */ Char) @safe @nogc nothrow del) @safe @nogc nothrow {
            int result;

            foreach (Char c; literal) {
                result = del(c);
                if (result)
                    break;
            }

            return result;
        }

        size_t length() {
            // we are not mixing types during testing so meh
            return literal.length;
        }

        OtherStateAsTarget!Char get() scope return @trusted {
            return OtherStateAsTarget!Char(cast(void*)literal.ptr, &mutex, &foreachContiguous, &foreachValue, &length);
        }
    }

    static struct OtherStateIsUs {
        ASCII_State* state;
        Iterator* iterator;

        void mutex(bool lock) @safe nothrow @nogc {
            assert(state !is null);

            if (lock)
                state.blockList.mutex.pureLock;
            else
                state.blockList.mutex.unlock;
        }

        int foreachContiguous(scope int delegate(scope ref  /* ignore this */ Char[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
            int result;

            if (iterator !is null) {
                foreach (data; &iterator.foreachBlocks) {
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

            return result;
        }

        int foreachValue(scope int delegate(ref  /* ignore this */ Char) @safe @nogc nothrow del) @safe @nogc nothrow {
            int result;

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

            return result;
        }

        size_t length() @safe @nogc nothrow {
            return iterator is null ? state.blockList.numberOfItems : (iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead);
        }

        OtherStateAsTarget!Char get() scope return nothrow @trusted @nogc {
            return OtherStateAsTarget!Char(cast(void*)state, &mutex, &foreachContiguous, &foreachValue, &length);
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

    // /\ internal
    // \/ external

    int externalOpCmp(scope Iterator* iterator, scope ref OtherStateAsTarget!Char other, bool caseSensitive) {
        import sidero.base.text.ascii.characters : toLower;

        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        int result;

        {
            Cursor forwardsCursor;
            size_t maximumOffsetFromHead;

            if (iterator is null) {
                forwardsCursor.setup(&blockList, 0);
                maximumOffsetFromHead = blockList.numberOfItems + 1;
            } else {
                forwardsCursor = iterator.forwards;
                maximumOffsetFromHead = iterator.backwards.offsetFromHead + 1;
            }

            bool emptyInternal() {
                return forwardsCursor.offsetFromHead + 1 >= maximumOffsetFromHead;
            }

            Char frontInternal() {
                forwardsCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsCursor.get();
            }

            void popFrontInternal() {
                import std.algorithm : min;

                forwardsCursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            foreach (c2; other.foreachValue) {
                if (emptyInternal()) {
                    result = -1;
                    break;
                }

                Char c1 = frontInternal();

                if (!caseSensitive) {
                    c1 = c1.toLower;
                    c2 = c2.toLower;
                }

                if (c1 < c2) {
                    result = -1;
                    break;
                } else if (c1 > c2) {
                    result = 1;
                    break;
                }

                popFrontInternal();
            }

            if (result == 0 && !emptyInternal()) {
                result = 1;
            }
        }

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);

        return result;
    }
}
