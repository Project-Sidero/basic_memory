module sidero.base.text.ascii.builder;
import sidero.base.text;
import sidero.base.allocators.api;
import sidero.base.attributes : hidden;

export:

///
struct StringBuilder_ASCII {
export:
    ///
    alias Char = ubyte;
    ///
    alias LiteralType = const(Char)[];

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(scope Del del) @trusted scope @hidden {
            if (isNull)
                return 0;

            auto oldIterator = this.iterator;
            iterator = state.newIterator(oldIterator);
            state.rc(true);

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

        int opApplyReverseImpl(Del)(scope Del del) @trusted scope @hidden {
            if (isNull)
                return 0;

            auto oldIterator = this.iterator;
            iterator = state.newIterator(oldIterator);
            state.rc(true);

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
export:

    mixin OpApplyCombos!(Char, void, "opApply", true, true, true, false, false);

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

    mixin OpApplyCombos!(Char, void, "opApplyReverse", true, true, true, false, false);

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

    void opAssign(ref return scope StringBuilder_ASCII other) scope @nogc {
        this.destroy;
        this.__ctor(other);
    }

    void opAssign(return scope StringBuilder_ASCII other) scope @nogc {
        this.destroy;
        this.__ctor(other);
    }

    @disable void opAssign(ref StringBuilder_ASCII other) const;
    @disable void opAssign(StringBuilder_ASCII other) const;

    this(ref return scope StringBuilder_ASCII other) @trusted scope @nogc {
        this.tupleof = other.tupleof;

        if (state !is null)
            state.rcIterator(true, iterator);
    }

    @disable this(ref return scope StringBuilder_ASCII other) @safe scope const;

    @disable this(ref const StringBuilder_ASCII other) const;
    //@disable this(this);

    ///
    this(RCAllocator allocator) scope @nogc {
        this.__ctor(LiteralType.init, allocator);
    }

    ///
    this(InputChar)(RCAllocator allocator, scope const(InputChar)[] input...) @trusted scope @nogc
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
    this(RCAllocator allocator, scope String_ASCII input) scope @nogc {
        this.__ctor(input, allocator);
    }

    ///
    unittest {
        static Text = cast(LiteralType)"it is negilible";

        assert(StringBuilder_ASCII(RCAllocator.init, String_ASCII(Text)).length == Text.length);
    }

    ///
    this(InputChar)(scope const(InputChar)[] input, RCAllocator allocator = RCAllocator.init) @trusted scope @nogc
            if (is(InputChar == ubyte) || is(InputChar == char)) {
        setupState(allocator);
        assert(state !is null);

        if (input.length > 0) {
            ASCII_State.LiteralAsTarget latc;
            latc.literal = cast(LiteralType)input;
            auto osat = latc.get;

            state.externalInsert(iterator, 0, osat, false);
        }
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
    this(scope String_ASCII input, RCAllocator allocator = RCAllocator.init) scope @nogc {
        input.stripZeroTerminator;

        this.__ctor(input.literal, allocator);
    }

    ///
    unittest {
        static Text = cast(LiteralType)"it is negilible";

        assert(StringBuilder_ASCII(String_ASCII(Text)).length == Text.length);
    }

    ///
    ~this() scope @nogc {
        if (state !is null)
            state.rcIterator(false, iterator);
    }

    ///
    bool isNull() scope const @nogc {
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
    StringBuilder_ASCII opIndex(ptrdiff_t index) scope @nogc {
        ptrdiff_t end = index < 0 ? ptrdiff_t.max : index + 1;
        return this[index .. end];
    }

    ///
    StringBuilder_ASCII save() scope @trusted @nogc {
        if (isNull)
            return StringBuilder_ASCII();

        state.rc(true);

        StringBuilder_ASCII ret;
        ret.state = state;
        ret.iterator = state.newIterator(iterator);
        return ret;
    }

    ///
    unittest {
        auto builder = typeof(this)("Smile! You don't want to see my other side.");
        builder.popFront;

        assert(builder.length == 42);
        assert(builder.front == 'm');
        assert(builder.back == '.');

        builder.popBack;

        assert(builder.length == 41);
        assert(builder.front == 'm');
        assert(builder.back == 'e');

        builder = builder.save;
        assert(builder.length == 41);
        assert(builder.front == 'm');
        assert(builder.back == 'e');
    }

    ///
    alias opSlice = save;

    ///
    unittest {
        static Text = "goods";

        StringBuilder_ASCII str = Text;
        assert(!str.haveIterator);

        StringBuilder_ASCII sliced = str[];
        assert(sliced.haveIterator);
        assert(sliced.length == Text.length);
    }

    ///
    StringBuilder_ASCII opSlice(ptrdiff_t start, ptrdiff_t end) scope @trusted @nogc {
        StringBuilder_ASCII ret;

        if (state !is null) {
            state.rc(true);

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
    alias encodingLength = length;

    ///
    ptrdiff_t length() scope const @nogc @trusted {
        auto state = cast(ASCII_State*)state;
        return state !is null ? state.externalLength(cast(ASCII_State.Iterator*)iterator) : 0;
    }

    ///
    unittest {
        StringBuilder_ASCII stack = StringBuilder_ASCII(cast(LiteralType)"hmm...");
        assert(stack.length == 6);
    }

    ///
    StringBuilder_ASCII dup(scope return RCAllocator allocator = RCAllocator.init) scope const @nogc @trusted {
        StringBuilder_ASCII ret = StringBuilder_ASCII(allocator);
        ret.insertImplBuilder(*cast(StringBuilder_ASCII*)&this);
        return ret;
    }

    ///
    unittest {
        static Text = cast(LiteralType)"can't be done.";

        StringBuilder_ASCII builder = StringBuilder_ASCII(Text);
        assert(builder.dup.length == Text.length);
    }

    ///
    String_ASCII asReadOnly(RCAllocator allocator = RCAllocator.init) scope @nogc {
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
            return String_ASCII.init;

        assert(array.length == soFar + 1, "Encoding length != Encoded");
        array[$ - 1] = 0;
        return String_ASCII(array, allocator);
    }

    ///
    unittest {
        static Text = "hey mr. helpful.";
        String_ASCII readOnly = StringBuilder_ASCII(Text).asReadOnly();

        assert(readOnly.length == 16);
        assert(readOnly.literal.length == 17);
        assert(readOnly == Text);
    }

    ///
    StringBuilder_ASCII asMutable(scope return RCAllocator allocator = RCAllocator.init) scope const @nogc {
        return this.dup(allocator);
    }

    ///
    bool opCast(T : bool)() scope const @nogc {
        return !isNull;
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope const(char)[] other) scope const @nogc {
        return opCmpImplSlice(other, true) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first == "first");
        assert(first != "third");
    }

    ///
    bool opEquals(scope LiteralType other) scope const @nogc {
        return opCmp(other) == 0;
    }

    ///
    @trusted unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first == cast(LiteralType)['f', 'i', 'r', 's', 't']);
        assert(first != cast(LiteralType)['t', 'h', 'i', 'r', 'd']);
    }

    ///
    bool opEquals(scope String_ASCII other) scope const @nogc {
        other.stripZeroTerminator;
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
    bool opEquals(scope StringBuilder_ASCII other) scope const @nogc {
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
    bool ignoreCaseEquals(scope const(char)[] other) scope const @nogc {
        return opCmpImplSlice(other, false) == 0;
    }

    ///
    unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first.ignoreCaseEquals("fIrst"));
        assert(!first.ignoreCaseEquals("third"));
    }

    ///
    bool ignoreCaseEquals(scope LiteralType other) scope const @nogc {
        return ignoreCaseCompare(other) == 0;
    }

    ///
    @trusted unittest {
        StringBuilder_ASCII first = StringBuilder_ASCII("first");

        assert(first.ignoreCaseEquals(cast(LiteralType)['f', 'I', 'r', 's', 't']));
        assert(!first.ignoreCaseEquals(cast(LiteralType)['t', 'h', 'i', 'r', 'd']));
    }

    ///
    bool ignoreCaseEquals(scope String_ASCII other) scope const @nogc {
        other.stripZeroTerminator;
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
    bool ignoreCaseEquals(scope StringBuilder_ASCII other) scope const @nogc {
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
    int opCmp(scope const(char)[] other) scope const @nogc {
        return opCmpImplSlice(other, true);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("a") < "z");
        assert(StringBuilder_ASCII("z") > "a");
    }

    ///
    int opCmp(scope LiteralType other) scope const @nogc {
        return opCmpImplSlice(other, true);
    }

    ///
    @trusted unittest {
        assert(StringBuilder_ASCII("a") < cast(LiteralType)['z']);
        assert(StringBuilder_ASCII("z") > cast(LiteralType)['a']);
    }

    ///
    int opCmp(scope String_ASCII other) scope const @nogc {
        other.stripZeroTerminator;
        return opCmpImplSlice(other.literal, true);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("a") < String_ASCII("z"));
        assert(StringBuilder_ASCII("z") > String_ASCII("a"));
    }

    ///
    int opCmp(scope StringBuilder_ASCII other) scope const @nogc {
        return opCmpImplBuilder(other, true);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("a") < StringBuilder_ASCII("z"));
        assert(StringBuilder_ASCII("z") > StringBuilder_ASCII("a"));
    }

    ///
    int ignoreCaseCompare(scope const(char)[] other) scope const @nogc {
        return opCmpImplSlice(other, false);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare("z") < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare("a") > 0);
    }

    ///
    int ignoreCaseCompare(scope LiteralType other) scope const @nogc {
        return opCmpImplSlice(other, false);
    }

    ///
    @trusted unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare(cast(LiteralType)['z']) < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare(cast(LiteralType)['a']) > 0);
    }

    ///
    int ignoreCaseCompare(scope String_ASCII other) scope const @nogc {
        other.stripZeroTerminator;
        return opCmpImplSlice(other.literal, false);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare(String_ASCII("z")) < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare(String_ASCII("a")) > 0);
    }

    ///
    int ignoreCaseCompare(scope StringBuilder_ASCII other) scope const @nogc {
        return opCmpImplBuilder(other, false);
    }

    ///
    unittest {
        assert(StringBuilder_ASCII("A").ignoreCaseCompare(StringBuilder_ASCII("z")) < 0);
        assert(StringBuilder_ASCII("Z").ignoreCaseCompare(StringBuilder_ASCII("a")) > 0);
    }

    ///
    alias put = append;

    ///
    bool empty() scope const @nogc {
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
        }

        iterator.popFront;
    }

    ///
    void popBack() scope @nogc {
        assert(state !is null);

        if (iterator is null) {
            iterator = state.newIterator();
        }

        iterator.popBack;
    }

    @nogc {
        ///
        bool startsWith(scope const(char[]) input) scope {
            return startsWithImplSlice(input, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").startsWith("Imma"));
            assert(!StringBuilder_ASCII("Imma do").startsWith("do"));
        }

        ///
        bool startsWith(scope LiteralType input) scope {
            return startsWithImplSlice(input, true);
        }

        ///
        @trusted unittest {
            assert(StringBuilder_ASCII("Imma do").startsWith(cast(LiteralType)"Imma"));
            assert(!StringBuilder_ASCII("Imma do").startsWith(cast(LiteralType)"do"));
        }

        ///
        bool startsWith(scope String_ASCII other) scope {
            other.stripZeroTerminator;

            return startsWithImplSlice(other.literal, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").startsWith(String_ASCII("Imma")));
            assert(!StringBuilder_ASCII("Imma do").startsWith(String_ASCII("do")));
        }

        ///
        bool startsWith(scope StringBuilder_ASCII input) scope {
            return startsWithImplBuilder(input, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").startsWith(StringBuilder_ASCII("Imma")));
            assert(!StringBuilder_ASCII("Imma do").startsWith(StringBuilder_ASCII("do")));
        }
    }

    @nogc {
        ///
        bool ignoreCaseStartsWith(scope const(char[]) input) scope {
            return startsWithImplSlice(input, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseStartsWith("imma"));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseStartsWith("do"));
        }

        ///
        bool ignoreCaseStartsWith(scope LiteralType input) scope {
            return startsWithImplSlice(input, false);
        }

        ///
        @trusted unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseStartsWith(cast(LiteralType)"imma"));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseStartsWith(cast(LiteralType)"do"));
        }

        ///
        bool ignoreCaseStartsWith(scope String_ASCII other) scope {
            other.stripZeroTerminator;

            return startsWithImplSlice(other.literal, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseStartsWith(String_ASCII("imma")));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseStartsWith(String_ASCII("do")));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_ASCII input) scope {
            return startsWithImplBuilder(input, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseStartsWith(StringBuilder_ASCII("imma")));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseStartsWith(StringBuilder_ASCII("do")));
        }
    }

    @nogc {
        ///
        bool endsWith(scope const(char[]) input) scope {
            return endsWithImplSlice(input, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").endsWith("do"));
            assert(!StringBuilder_ASCII("Imma do").endsWith("imma"));
        }

        ///
        bool endsWith(scope LiteralType input) scope {
            return endsWithImplSlice(input, true);
        }

        ///
        @trusted unittest {
            assert(StringBuilder_ASCII("Imma do").endsWith(cast(LiteralType)"do"));
            assert(!StringBuilder_ASCII("Imma do").endsWith(cast(LiteralType)"imma"));
        }

        ///
        bool endsWith(scope String_ASCII other) scope {
            other.stripZeroTerminator;

            return endsWithImplSlice(other.literal, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").endsWith(String_ASCII("do")));
            assert(!StringBuilder_ASCII("Imma do").endsWith(String_ASCII("imma")));
        }

        ///
        bool endsWith(scope StringBuilder_ASCII input) scope {
            return endsWithImplBuilder(input, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").endsWith(StringBuilder_ASCII("do")));
            assert(!StringBuilder_ASCII("Imma do").endsWith(StringBuilder_ASCII("imma")));
        }
    }

    @nogc {
        ///
        bool ignoreCaseEndsWith(scope const(char[]) input) scope {
            return endsWithImplSlice(input, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseEndsWith("Do"));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseEndsWith("imma"));
        }

        ///
        bool ignoreCaseEndsWith(scope LiteralType input) scope {
            return endsWithImplSlice(input, false);
        }

        ///
        @trusted unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseEndsWith(cast(LiteralType)"Do"));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseEndsWith(cast(LiteralType)"imma"));
        }

        ///
        bool ignoreCaseEndsWith(scope String_ASCII other) scope {
            other.stripZeroTerminator;

            return endsWithImplSlice(other.literal, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseEndsWith(String_ASCII("Do")));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseEndsWith(String_ASCII("imma")));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_ASCII input) scope {
            return endsWithImplBuilder(input, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("Imma do").ignoreCaseEndsWith(StringBuilder_ASCII("Do")));
            assert(!StringBuilder_ASCII("Imma do").ignoreCaseEndsWith(StringBuilder_ASCII("imma")));
        }
    }

    @nogc {
        ///
        ptrdiff_t count(scope const(char)[] toFind) scope {
            return countImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").count("hello"c) == 1);
        }

        ///
        ptrdiff_t count(scope LiteralType toFind) scope {
            return countImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").count(cast(LiteralType)"hello") == 1);
        }

        ///
        ptrdiff_t count(scope String_ASCII toFind) scope {
            return countImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").count(String_ASCII("hello")) == 1);
        }

        ///
        ptrdiff_t count(scope StringBuilder_ASCII toFind) scope {
            return countImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").count(StringBuilder_ASCII("hello")) == 1);
        }

        ///
        ptrdiff_t ignoreCaseCount(scope const(char)[] toFind) scope {
            return countImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").ignoreCaseCount("hello"c) == 2);
        }

        ///
        ptrdiff_t ignoreCaseCount(scope LiteralType toFind) scope {
            return countImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").ignoreCaseCount(cast(LiteralType)"hello") == 2);
        }

        ///
        ptrdiff_t ignoreCaseCount(scope String_ASCII toFind) scope {
            return countImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").ignoreCaseCount(String_ASCII("hello")) == 2);
        }

        ///
        ptrdiff_t ignoreCaseCount(scope StringBuilder_ASCII toFind) scope {
            return countImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").ignoreCaseCount(StringBuilder_ASCII("hello")) == 2);
        }

        ///
        ptrdiff_t contains(scope const(char)[] toFind) scope {
            return containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").contains("hello"c));
        }

        ///
        ptrdiff_t contains(scope LiteralType toFind) scope {
            return containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").contains(cast(LiteralType)"hello"));
        }

        ///
        ptrdiff_t contains(scope String_ASCII toFind) scope {
            return containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").contains(String_ASCII("hello")));
        }

        ///
        ptrdiff_t contains(scope StringBuilder_ASCII toFind) scope {
            return containsImpl(toFind, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").contains(StringBuilder_ASCII("hello")));
        }

        ///
        ptrdiff_t ignoreCaseContains(scope const(char)[] toFind) scope {
            return containsImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseContains("hello"c));
        }

        ///
        ptrdiff_t ignoreCaseContains(scope LiteralType toFind) scope {
            return containsImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseContains(cast(LiteralType)"hello"));
        }

        ///
        ptrdiff_t ignoreCaseContains(scope String_ASCII toFind) scope {
            return containsImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseContains(String_ASCII("hello")));
        }

        ///
        ptrdiff_t ignoreCaseContains(scope StringBuilder_ASCII toFind) scope {
            return containsImpl(toFind, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseContains(StringBuilder_ASCII("hello")));
        }

        ///
        ptrdiff_t indexOf(scope const(char)[] toFind) scope {
            return offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").indexOf("hello"c) == 5);
        }

        ///
        ptrdiff_t indexOf(scope LiteralType toFind) scope {
            return offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").indexOf(cast(LiteralType)"hello") == 5);
        }

        ///
        ptrdiff_t indexOf(scope String_ASCII toFind) scope {
            return offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").indexOf(String_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t indexOf(scope StringBuilder_ASCII toFind) scope {
            return offsetOfImpl(toFind, true, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").indexOf(StringBuilder_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope const(char)[] toFind) scope {
            return offsetOfImpl(toFind, false, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseIndexOf("hello"c) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope LiteralType toFind) scope {
            return offsetOfImpl(toFind, false, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseIndexOf(cast(LiteralType)"hello") == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope String_ASCII toFind) scope {
            return offsetOfImpl(toFind, false, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseIndexOf(String_ASCII("hello")) == 0);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_ASCII toFind) scope {
            return offsetOfImpl(toFind, false, true);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLo").ignoreCaseIndexOf(StringBuilder_ASCII("hello")) == 0);
        }

        ///
        ptrdiff_t lastIndexOf(scope const(char)[] toFind) scope {
            return offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").lastIndexOf("hello"c) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope LiteralType toFind) scope {
            return offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").lastIndexOf(cast(LiteralType)"hello") == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope String_ASCII toFind) scope {
            return offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").lastIndexOf(String_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t lastIndexOf(scope StringBuilder_ASCII toFind) scope {
            return offsetOfImpl(toFind, true, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("heLLohello").lastIndexOf(StringBuilder_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope const(char)[] toFind) scope {
            return offsetOfImpl(toFind, false, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("helloheLLo").ignoreCaseLastIndexOf("hello"c) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope LiteralType toFind) scope {
            return offsetOfImpl(toFind, false, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("helloheLLo").ignoreCaseLastIndexOf(cast(LiteralType)"hello") == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope String_ASCII toFind) scope {
            return offsetOfImpl(toFind, false, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("helloheLLo").ignoreCaseLastIndexOf(String_ASCII("hello")) == 5);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_ASCII toFind) scope {
            return offsetOfImpl(toFind, false, false);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("helloheLLo").ignoreCaseLastIndexOf(StringBuilder_ASCII("hello")) == 5);
        }
    }

    @nogc {
        ///
        StringBuilder_ASCII strip() return scope {
            stripLeft;
            stripRight;
            return this;
        }

        ///
        /+unittest {
            typeof(this) value = typeof(this)(cast(LiteralType)"  \t abc\t\r\n \0");
            value.strip;
            assert(value == cast(LiteralType)"abc");

            assert(typeof(this)(cast(LiteralType)"  \t abc\t\r\n \0").strip == cast(LiteralType)"abc");
        }+/

        ///
        StringBuilder_ASCII stripLeft() return scope {
            import sidero.base.text.ascii.characters : toLower;

            if (isNull)
                return this;

            state.externalStripLeft(iterator);
            return this;
        }

        ///
        unittest {
            typeof(this) value = typeof(this)(cast(LiteralType)"  \t abc\t\r\n \0");
            value.stripLeft;
            assert(value == cast(LiteralType)"abc\t\r\n \0");

            assert(typeof(this)(cast(LiteralType)"  \t abc\t\r\n \0").stripLeft == cast(LiteralType)"abc\t\r\n \0");
        }

        ///
        StringBuilder_ASCII stripRight() return scope {
            if (isNull)
                return this;

            state.externalStripRight(iterator);
            return this;
        }

        ///
        unittest {
            typeof(this) value = typeof(this)(cast(LiteralType)"  \t abc\t\r\n \0");
            value.stripRight;
            assert(value == cast(LiteralType)"  \t abc");

            assert(typeof(this)(cast(LiteralType)"  \t abc\t\r\n \0").stripRight == cast(LiteralType)"  \t abc");
        }
    }

    @nogc {
        ///
        StringBuilder_ASCII toLower() return scope {
            import sidero.base.text.ascii.characters : toLower;

            foreachContiguous((scope ref ubyte[] data) {
                foreach (ref c; data) {
                    c = c.toLower;
                }

                return 0;
            }, null);

            return this;
        }

        ///
        unittest {
            auto builder = typeof(this)("BADFTyZE");
            builder[1 .. $ - 1].toLower;
            assert(builder == "BadftyzE");
        }

        ///
        StringBuilder_ASCII toUpper() return scope {
            import sidero.base.text.ascii.characters : toUpper;

            foreachContiguous((scope ref ubyte[] data) {
                foreach (ref c; data) {
                    c = c.toUpper;
                }

                return 0;
            }, null);

            return this;
        }

        ///
        unittest {
            auto builder = typeof(this)("badftyze");
            builder[1 .. $ - 1].toUpper;
            assert(builder == "bADFTYZe");
        }

        ///
        StringBuilder_ASCII toTitle() return scope {
            import sidero.base.text.ascii.characters : isAlpha, toLower, toUpper;

            bool wasAlpha;

            foreachContiguous((scope ref ubyte[] data) {
                foreach (ref c; data) {
                    bool currentAlpha = c.isAlpha;

                    if (wasAlpha)
                        c = c.toLower;
                    else
                        c = c.toUpper;

                    wasAlpha = currentAlpha;
                }

                return 0;
            }, null);

            return this;
        }

        ///
        unittest {
            auto builder = typeof(this)("baDfTyZe");
            builder[1 .. $ - 1].toTitle;
            assert(builder == "bAdftyze");

            builder = typeof(this)("bA DfTyZe");
            builder[1 .. $ - 1].toTitle;
            assert(builder == "bA Dftyze");
        }
    }

    ///
    void remove(ptrdiff_t index, size_t amount) scope @nogc {
        if (state !is null)
            state.externalRemove(iterator, index, amount);
    }

    ///
    unittest {
        StringBuilder_ASCII builder = "hello world!";

        builder.remove(-1, 2);
        builder.remove(2, 2);

        assert(builder == "heo world");
    }

    ///
    void clear() scope @nogc {
        this.remove(0, size_t.max);
    }

    ///
    unittest {
        StringBuilder_ASCII builder = "hello world!";
        builder.clear;
        assert(builder.length == 0);
    }

    @nogc {
        ///
        StringBuilder_ASCII insert(ptrdiff_t index, scope const(char)[] input...) return scope {
            this.insertImplSlice(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").insert(-1, "def") == "abdefc");
        }

        ///
        StringBuilder_ASCII insert(ptrdiff_t index, scope LiteralType input...) return scope {
            this.insertImplSlice(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").insert(-1, cast(LiteralType)"def") == "abdefc");
        }

        ///
        StringBuilder_ASCII insert(ptrdiff_t index, scope String_ASCII other) return scope {
            other.stripZeroTerminator;

            this.insertImplReadOnly(other, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").insert(-1, String_ASCII("def")) == "abdefc");
        }

        ///
        StringBuilder_ASCII insert(ptrdiff_t index, scope StringBuilder_ASCII input) return scope {
            this.insertImplBuilder(input, index);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").insert(-1, StringBuilder_ASCII("def")) == "abdefc");
        }
    }

    @nogc {
        ///
        StringBuilder_ASCII prepend(scope const(char)[] input...) return scope @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("world").prepend("hello ") == "hello world");
        }

        ///
        StringBuilder_ASCII prepend(scope LiteralType input...) return scope @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("world").prepend(cast(LiteralType)"hello ") == "hello world");
        }

        ///
        StringBuilder_ASCII prepend(scope String_ASCII other) return scope @trusted {
            other.stripZeroTerminator;

            return this.insert(0, other);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("world").prepend(String_ASCII("hello ")) == "hello world");
        }

        ///
        StringBuilder_ASCII prepend(scope StringBuilder_ASCII input) return scope @trusted {
            return this.insert(0, input);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("world").prepend(StringBuilder_ASCII("hello ")) == "hello world");
        }
    }

    @nogc {
        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope const(char)[] input) scope @trusted {
            StringBuilder_ASCII ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            assert((builder ~ " world") == "hello world");
        }

        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope LiteralType input) scope @trusted {
            StringBuilder_ASCII ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            assert((builder ~ cast(LiteralType)" world") == "hello world");
        }

        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope String_ASCII other) scope @trusted {
            other.stripZeroTerminator;

            StringBuilder_ASCII ret = this.dup;
            ret.append(other);
            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            assert((builder ~ String_ASCII(" world")) == "hello world");
        }

        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope StringBuilder_ASCII input) scope @trusted {
            StringBuilder_ASCII ret = this.dup;
            ret.append(input);
            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            assert((builder ~ StringBuilder_ASCII(" world")) == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope const(char)[] input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            builder ~= " world";
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope LiteralType input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            builder ~= cast(LiteralType)" world";
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope String_ASCII other) scope return @trusted {
            other.stripZeroTerminator;

            this.append(other);
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            builder ~= String_ASCII(" world");
            assert(builder == "hello world");
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_ASCII input) scope return @trusted {
            this.append(input);
        }

        ///
        unittest {
            StringBuilder_ASCII builder = "hello";
            builder ~= StringBuilder_ASCII(" world");
            assert(builder == "hello world");
        }

        ///
        StringBuilder_ASCII append(scope const(char)[] input...) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("hello").append(" world") == "hello world");
        }

        ///
        StringBuilder_ASCII append(scope LiteralType input...) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("hello").append(cast(LiteralType)" world") == "hello world");
        }

        ///
        StringBuilder_ASCII append(scope String_ASCII other) scope return @trusted {
            other.stripZeroTerminator;

            return this.insert(ptrdiff_t.max, other);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("hello").append(String_ASCII(" world")) == "hello world");
        }

        ///
        StringBuilder_ASCII append(scope StringBuilder_ASCII input) scope return @trusted {
            return this.insert(ptrdiff_t.max, input);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("hello").append(StringBuilder_ASCII(" world")) == "hello world");
        }
    }

    @nogc {
        ///
        StringBuilder_ASCII clobberInsert(ptrdiff_t index, scope const(char)[] input...) return scope {
            this.insertImplSlice(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").clobberInsert(-1, "def") == "abdef");
        }

        ///
        StringBuilder_ASCII clobberInsert(ptrdiff_t index, scope LiteralType input...) return scope {
            this.insertImplSlice(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").clobberInsert(-1, cast(LiteralType)"def") == "abdef");
        }

        ///
        StringBuilder_ASCII clobberInsert(ptrdiff_t index, scope String_ASCII other) return scope {
            other.stripZeroTerminator;

            this.insertImplReadOnly(other, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").clobberInsert(-1, String_ASCII("def")) == "abdef");
        }

        ///
        StringBuilder_ASCII clobberInsert(ptrdiff_t index, scope StringBuilder_ASCII input) return scope {
            this.insertImplBuilder(input, index, true);
            return this;
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("abc").clobberInsert(-1, StringBuilder_ASCII("def")) == "abdef");
        }
    }

    @nogc {
        ///
        size_t replace(scope const(char)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace("la", "woof") == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace("la", cast(LiteralType)"woof") == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace("la", String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope const(char)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace("la", StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope LiteralType toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(cast(LiteralType)"la", "woof") == 2);
        }

        ///
        size_t replace(scope LiteralType toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(cast(LiteralType)"la", cast(LiteralType)"woof") == 2);
        }

        ///
        size_t replace(scope LiteralType toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(cast(LiteralType)"la", String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope LiteralType toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(cast(LiteralType)"la", StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(String_ASCII("la"), "woof") == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(String_ASCII("la"), cast(LiteralType)"woof") == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(String_ASCII("la"), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope String_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(String_ASCII("la"), StringBuilder_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(StringBuilder_ASCII("la"), "woof") == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(StringBuilder_ASCII("la"), cast(LiteralType)"woof") == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(StringBuilder_ASCII("la"), String_ASCII("woof")) == 2);
        }

        ///
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false) scope {
            return replaceImpl(toFind, toReplace, caseSensitive, onlyOnce);
        }

        ///
        unittest {
            assert(StringBuilder_ASCII("its a lala world").replace(StringBuilder_ASCII("la"), StringBuilder_ASCII("woof")) == 2);
        }
    }

    ///
    ulong toHash() scope const @trusted @nogc {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();
        StringBuilder_ASCII* sba = cast(StringBuilder_ASCII*)&this;

        sba.foreachContiguous((scope ref data) { ret = hashOf(data, ret); return 0; });

        return ret;
    }

package(sidero.base.text):
    ASCII_State* state;
    ASCII_State.Iterator* iterator;

    int foreachContiguous(scope int delegate(ref scope Char[] data) @safe nothrow @nogc del,
            scope void delegate(size_t length) @safe nothrow @nogc lengthDel = null) scope @nogc @trusted @hidden {
        if (state is null)
            return 0;

        ASCII_State.OtherStateIsUs osiu;
        osiu.state = state;
        osiu.iterator = iterator;

        osiu.mutex(true);

        if (lengthDel !is null)
            lengthDel(osiu.length());
        int result = osiu.foreachContiguous(del);

        osiu.mutex(false);
        return result;
    }

private @hidden:
    void setupState(RCAllocator allocator = RCAllocator.init) scope @nogc @trusted {
        if (allocator.isNull)
            allocator = globalAllocator();

        if (state is null)
            state = allocator.make!ASCII_State(allocator);
    }

    @disable void setupState(RCAllocator allocator = RCAllocator.init) scope const @nogc;

    void debugPosition() scope @nogc {
        assert(state !is null);
        state.debugPosition(iterator);
    }

    scope @nogc {
        int opCmpImplSlice(scope const(char)[] other, bool caseSensitive) const @trusted {
            return opCmpImplSlice(cast(LiteralType)other, caseSensitive);
        }

        int opCmpImplSlice(scope const(Char)[] other, bool caseSensitive) const @trusted {
            ASCII_State.LiteralAsTarget lat;
            lat.literal = other;

            scope osiu = lat.get;
            scope state = cast(ASCII_State*)this.state;

            if (isNull) {
                if (other.length > 0)
                    return -1;
                else
                    return 0;
            } else
                return state.externalOpCmp(cast(ASCII_State.Iterator*)iterator, osiu, caseSensitive);
        }

        int opCmpImplBuilder(scope StringBuilder_ASCII other, bool caseSensitive) const @trusted {
            ASCII_State.OtherStateIsUs asiu;
            asiu.state = other.state;
            asiu.iterator = other.iterator;

            scope osiu = asiu.get;
            scope state = cast(ASCII_State*)this.state;

            if (isNull) {
                if (other.length > 0)
                    return -1;
                else
                    return 0;
            } else
                return state.externalOpCmp(cast(ASCII_State.Iterator*)iterator, osiu, caseSensitive);
        }

        void insertImplReadOnly(scope String_ASCII other, ptrdiff_t offset = 0, bool clobber = false) @trusted {
            setupState;

            ASCII_State.LiteralAsTarget alat;
            alat.literal = other.literal;
            scope osiu = alat.get;

            state.externalInsert(iterator, offset, osiu, clobber);
        }

        void insertImplSlice(Char2)(scope const(Char2)[] other, ptrdiff_t offset = 0, bool clobber = false) @trusted {
            setupState;

            ASCII_State.LiteralAsTarget lat;
            lat.literal = cast(LiteralType)other;
            scope osiu = lat.get;

            state.externalInsert(iterator, offset, osiu, clobber);
        }

        void insertImplBuilder(scope StringBuilder_ASCII other, ptrdiff_t offset = 0, bool clobber = false) @trusted {
            setupState;

            ASCII_State.OtherStateIsUs asat;
            asat.state = other.state;
            asat.iterator = other.iterator;
            scope osiu = asat.get;

            state.externalInsert(iterator, offset, osiu, clobber);
        }

        bool startsWithImplSlice(scope const(char)[] other, bool caseSensitive) @trusted {
            return startsWithImplSlice(cast(LiteralType)other, caseSensitive);
        }

        bool startsWithImplSlice(scope const(Char)[] other, bool caseSensitive) @trusted {
            ASCII_State.LiteralAsTarget lat;
            lat.literal = other;
            scope osiu = lat.get;

            if (isNull)
                return false;
            else
                return state.externalStartsWith(iterator, osiu, caseSensitive);
        }

        bool startsWithImplBuilder(scope StringBuilder_ASCII other, bool caseSensitive) @trusted {
            ASCII_State.OtherStateIsUs asiu;
            asiu.state = other.state;
            asiu.iterator = other.iterator;
            scope osiu = asiu.get;

            if (isNull)
                return false;
            else
                return state.externalStartsWith(iterator, osiu, caseSensitive);
        }

        bool endsWithImplSlice(scope const(char)[] other, bool caseSensitive) @trusted {
            return endsWithImplSlice(cast(LiteralType)other, caseSensitive);
        }

        bool endsWithImplSlice(scope const(Char)[] other, bool caseSensitive) @trusted {
            ASCII_State.LiteralAsTarget lat;
            lat.literal = other;
            scope osiu = lat.get;

            if (isNull)
                return false;
            else
                return state.externalEndsWith(iterator, osiu, caseSensitive);
        }

        bool endsWithImplBuilder(scope StringBuilder_ASCII other, bool caseSensitive) @trusted {
            ASCII_State.OtherStateIsUs asiu;
            asiu.state = other.state;
            asiu.iterator = other.iterator;
            scope osiu = asiu.get;

            if (isNull)
                return false;
            else
                return state.externalEndsWith(iterator, osiu, caseSensitive);
        }

        size_t replaceImpl(ToFind, ToReplace)(scope ToFind toFind, scope ToReplace toReplace, bool caseSensitive, bool onceOnly) {
            if (isNull)
                return 0;

            scope ASCII_State.OtherStateIsUs toFindOSIU, toReplaceOSIU;
            scope ASCII_State.LiteralAsTarget toFindLAT, toReplaceLAT;
            scope ASCII_State.OtherStateAsTarget!ubyte toFindOSAT, toReplaceOSAT;

            static void handle(Input)(scope ref Input input, scope out ASCII_State.OtherStateAsTarget!ubyte osat,
                    scope out ASCII_State.OtherStateIsUs osiu, scope out ASCII_State.LiteralAsTarget lat) @trusted {
                static if (is(Input == String_ASCII)) {
                    input.stripZeroTerminator;
                    scope actualInput = input.literal;
                } else {
                    scope actualInput = input;
                }

                static if (is(Input == StringBuilder_ASCII)) {
                    osiu.state = input.state;
                    osiu.iterator = input.iterator;
                    osat = osiu.get();
                } else {
                    lat.literal = cast(LiteralType)actualInput;
                    osat = lat.get();
                }
            }

            handle(toFind, toFindOSAT, toFindOSIU, toFindLAT);
            handle(toReplace, toReplaceOSAT, toReplaceOSIU, toReplaceLAT);

            return state.externalReplace(iterator, toFindOSAT, toReplaceOSAT, caseSensitive, onceOnly);
        }
    }

    bool containsImpl(ToFind)(scope ToFind toFind, bool caseSensitive) {
        return countImpl(toFind, caseSensitive, true) == 1;
    }

    size_t countImpl(ToFind)(scope ToFind toFind, bool caseSensitive, bool onceOnly = false) {
        if (isNull)
            return 0;

        scope ASCII_State.OtherStateIsUs toFindOSIU;
        scope ASCII_State.LiteralAsTarget toFindLAT;
        scope ASCII_State.OtherStateAsTarget!ubyte toFindOSAT;

        static void handle(Input)(scope ref Input input, scope out ASCII_State.OtherStateAsTarget!ubyte osat,
                scope out ASCII_State.OtherStateIsUs osiu, scope out ASCII_State.LiteralAsTarget lat) @trusted {
            static if (is(Input == String_ASCII)) {
                input.stripZeroTerminator;
                scope actualInput = input.literal;
            } else {
                scope actualInput = input;
            }

            static if (is(Input == StringBuilder_ASCII)) {
                osiu.state = input.state;
                osiu.iterator = input.iterator;
                osat = osiu.get();
            } else {
                lat.literal = cast(LiteralType)actualInput;
                osat = lat.get();
            }
        }

        handle(toFind, toFindOSAT, toFindOSIU, toFindLAT);
        return state.externalCount(iterator, toFindOSAT, caseSensitive, onceOnly);
    }

    ptrdiff_t offsetOfImpl(ToFind)(scope ToFind toFind, bool caseSensitive, bool onceOnly) {
        if (isNull)
            return -1;

        scope ASCII_State.OtherStateIsUs toFindOSIU;
        scope ASCII_State.LiteralAsTarget toFindLAT;
        scope ASCII_State.OtherStateAsTarget!ubyte toFindOSAT;

        static void handle(Input)(scope ref Input input, scope out ASCII_State.OtherStateAsTarget!ubyte osat,
                scope out ASCII_State.OtherStateIsUs osiu, scope out ASCII_State.LiteralAsTarget lat) @trusted {
            static if (is(Input == String_ASCII)) {
                input.stripZeroTerminator;
                scope actualInput = input.literal;
            } else {
                scope actualInput = input;
            }

            static if (is(Input == StringBuilder_ASCII)) {
                osiu.state = input.state;
                osiu.iterator = input.iterator;
                osat = osiu.get();
            } else {
                lat.literal = cast(LiteralType)actualInput;
                osat = lat.get();
            }
        }

        handle(toFind, toFindOSAT, toFindOSIU, toFindLAT);
        return state.externalOffsetOf(iterator, toFindOSAT, caseSensitive, onceOnly);
    }
}

package(sidero.base.text) @hidden:

struct ASCII_State {
    import sidero.base.text.internal.builder.blocklist;
    import sidero.base.text.internal.builder.iteratorlist;
    import sidero.base.text.internal.builder.operations;
    import sidero.base.allocators.api;

    alias Char = ubyte;

    mixin template CustomIteratorContents() {
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

    void onInsert(scope const Char[] input) scope {
    }

    void onRemove(scope const Char[] input) scope {
    }

    static struct LiteralMatcher {
        const(Char)[] literal;

    @safe nothrow @nogc @hidden:

        bool matches(scope Cursor cursor, size_t maximumOffsetFromHead) scope {
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

        int compare(scope Cursor cursor, size_t maximumOffsetFromHead) scope {
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

    @safe nothrow @nogc @hidden:

        void mutex(bool) scope {
        }

        int foreachContiguous(scope int delegate(scope ref  /* ignore this */ Char[] data) @safe @nogc nothrow del) scope @trusted @nogc nothrow {
            // don't mutate during testing
            Char[] temp = cast(Char[])literal;
            return del(temp);
        }

        int foreachValue(scope int delegate(ref  /* ignore this */ Char) @safe @nogc nothrow del) scope @safe @nogc nothrow {
            int result;

            foreach (Char c; literal) {
                result = del(c);
                if (result)
                    break;
            }

            return result;
        }

        ptrdiff_t length() scope {
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

    @safe nothrow @nogc @hidden:

        void mutex(bool lock) scope {
            assert(state !is null);

            if (lock)
                state.blockList.mutex.pureLock;
            else
                state.blockList.mutex.unlock;
        }

        int foreachContiguous(scope int delegate(scope ref  /* ignore this */ Char[] data) @safe @nogc nothrow del) scope @trusted {
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

        int foreachValue(scope int delegate(ref  /* ignore this */ Char) @safe @nogc nothrow del) scope {
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

        ptrdiff_t length() scope {
            return iterator is null ? state.blockList.numberOfItems : (iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead);
        }

        OtherStateAsTarget!Char get() scope return @trusted {
            return OtherStateAsTarget!Char(cast(void*)state, &mutex, &foreachContiguous, &foreachValue, &length);
        }
    }

    void debugPosition(scope Cursor cursor) scope {
        debugPosition(cursor.block, cursor.offsetIntoBlock);
    }

    void debugPosition(scope Block* cursorBlock, size_t offsetIntoBlock) scope @trusted {
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

    void debugPosition(scope Iterator* iterator) scope @trusted {
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

    // /\ internal
    // \/ external

    int externalOpCmp(scope Iterator* iterator, scope ref OtherStateAsTarget!Char other, bool caseSensitive) scope @trusted {
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
                maximumOffsetFromHead = blockList.numberOfItems;
            } else {
                forwardsCursor = iterator.forwards;
                maximumOffsetFromHead = iterator.backwards.offsetFromHead;
            }

            bool emptyInternal() {
                return forwardsCursor.offsetFromHead >= maximumOffsetFromHead;
            }

            Char frontInternal() {
                forwardsCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsCursor.get();
            }

            void popFrontInternal() {
                import sidero.base.algorithm : min;

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

    bool externalStartsWith(scope Iterator* iterator, scope ref OtherStateAsTarget!Char other, bool caseSensitive) scope @trusted {
        import sidero.base.text.ascii.characters : toLower;

        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        bool result = true;

        {
            Cursor forwardsCursor;
            size_t maximumOffsetFromHead;

            if (iterator is null) {
                forwardsCursor.setup(&blockList, 0);
                maximumOffsetFromHead = blockList.numberOfItems;
            } else {
                forwardsCursor = iterator.forwards;
                maximumOffsetFromHead = iterator.backwards.offsetFromHead;
            }

            bool emptyInternal() {
                return forwardsCursor.offsetFromHead >= maximumOffsetFromHead;
            }

            Char frontInternal() {
                forwardsCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsCursor.get();
            }

            void popFrontInternal() {
                import sidero.base.algorithm : min;

                forwardsCursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            foreach (c2; other.foreachValue) {
                if (emptyInternal()) {
                    result = false;
                    break;
                }

                Char c1 = frontInternal();

                if (!caseSensitive) {
                    c1 = c1.toLower;
                    c2 = c2.toLower;
                }

                if (c1 < c2) {
                    result = false;
                    break;
                } else if (c1 > c2) {
                    result = false;
                    break;
                }

                popFrontInternal();
            }
        }

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);

        return result;
    }

    bool externalEndsWith(scope Iterator* iterator, scope ref OtherStateAsTarget!Char other, bool caseSensitive) scope @trusted {
        import sidero.base.text.ascii.characters : toLower;

        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        bool result = true;

        {
            Cursor forwardsCursor;
            ptrdiff_t maximumOffsetFromHead;

            {
                size_t otherLength = other.length();

                if (iterator !is null)
                    maximumOffsetFromHead = iterator.backwards.offsetFromHead;
                else
                    maximumOffsetFromHead = blockList.numberOfItems;

                if (otherLength > maximumOffsetFromHead) {
                    blockList.mutex.unlock;
                    if (other.obj !is &this)
                        other.mutex(false);

                    return false;
                }

                ptrdiff_t minimumOffsetFromHead = otherLength;
                minimumOffsetFromHead = -minimumOffsetFromHead;

                changeIndexToOffset(iterator, minimumOffsetFromHead);
                forwardsCursor.setup(&blockList, minimumOffsetFromHead);
            }

            bool emptyInternal() {
                return forwardsCursor.offsetFromHead >= maximumOffsetFromHead;
            }

            Char frontInternal() {
                forwardsCursor.advanceForward(0, maximumOffsetFromHead, true);
                return forwardsCursor.get();
            }

            void popFrontInternal() {
                import sidero.base.algorithm : min;

                forwardsCursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            foreach (c2; other.foreachValue) {
                if (emptyInternal()) {
                    result = false;
                    break;
                }

                Char c1 = frontInternal();

                if (!caseSensitive) {
                    c1 = c1.toLower;
                    c2 = c2.toLower;
                }

                if (c1 != c2) {
                    result = false;
                    break;
                }

                popFrontInternal();
            }
        }

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);

        return result;
    }

    size_t externalReplace(scope Iterator* iterator, scope ref OtherStateAsTarget!Char toFind,
            scope ref OtherStateAsTarget!Char toReplace, bool caseSensitive, bool onlyOnce) scope @trusted {
        import sidero.base.text.ascii.characters : toLower;

        blockList.mutex.pureLock;
        if (toFind.obj !is &this)
            toFind.mutex(true);
        if (toReplace.obj !is &this && toReplace.obj !is toFind.obj)
            toReplace.mutex(true);

        size_t maximumOffsetFromHead;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);

        size_t ret = replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) {
            size_t matched;

            foreach (value; toFind.foreachValue) {
                if (cursor.isOutOfRange(0, maximumOffsetFromHead))
                    return false;

                ubyte c1 = value, c2 = cursor.get();

                if (!caseSensitive) {
                    c1 = c1.toLower;
                    c2 = c2.toLower;
                }

                if (c1 != c2)
                    return 0;

                matched++;
                cursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            return matched;
        }, (scope Iterator* iterator, scope ref Cursor cursor) @trusted {
            size_t oldOffsetFromHead = cursor.offsetFromHead;
            return insertOperation(iterator, cursor, toReplace);
        }, true, onlyOnce);

        blockList.mutex.unlock;
        if (toFind.obj !is &this)
            toFind.mutex(false);
        if (toReplace.obj !is &this && toReplace.obj !is toFind.obj)
            toReplace.mutex(false);

        return ret;
    }

    size_t externalCount(scope Iterator* iterator, scope ref OtherStateAsTarget!Char toFind, bool caseSensitive, bool onlyOnce) scope @trusted {
        import sidero.base.text.ascii.characters : toLower;

        blockList.mutex.pureLock;
        if (toFind.obj !is &this)
            toFind.mutex(true);

        size_t maximumOffsetFromHead, lastConsumed;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);

        size_t ret = replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) {
            lastConsumed = 0;

            foreach (value; toFind.foreachValue) {
                if (cursor.isOutOfRange(0, maximumOffsetFromHead))
                    return false;

                ubyte c1 = value, c2 = cursor.get();

                if (!caseSensitive) {
                    c1 = c1.toLower;
                    c2 = c2.toLower;
                }

                if (c1 != c2)
                    return 0;

                lastConsumed++;
                cursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            return lastConsumed;
        }, (scope Iterator* iterator, scope ref Cursor cursor) @trusted {
            cursor.advanceForward(lastConsumed, maximumOffsetFromHead, true);
            return size_t(0);
        }, false, onlyOnce);

        blockList.mutex.unlock;
        if (toFind.obj !is &this)
            toFind.mutex(false);

        return ret;
    }

    ptrdiff_t externalOffsetOf(scope Iterator* iterator, scope ref OtherStateAsTarget!Char toFind, bool caseSensitive, bool onlyOnce) scope @trusted {
        import sidero.base.text.ascii.characters : toLower;

        blockList.mutex.pureLock;
        if (toFind.obj !is &this)
            toFind.mutex(true);

        size_t maximumOffsetFromHead, lastConsumed;
        scope Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, 0);
        size_t startingOffset = cursor.offsetFromHead;

        ptrdiff_t ret = -1;
        replaceOperation(iterator, cursor, (scope Cursor cursor, size_t maximumOffsetFromHead) {
            lastConsumed = 0;

            foreach (value; toFind.foreachValue) {
                if (cursor.isOutOfRange(0, maximumOffsetFromHead))
                    return false;

                Char c1 = value, c2 = cursor.get();

                if (!caseSensitive) {
                    c1 = c1.toLower;
                    c2 = c2.toLower;
                }

                if (c1 != c2)
                    return 0;

                lastConsumed++;
                cursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            return lastConsumed;
        }, (scope Iterator* iterator, scope ref Cursor cursor) @trusted {
            ret = cursor.offsetFromHead;
            cursor.advanceForward(lastConsumed, maximumOffsetFromHead, true);
            return size_t(0);
        }, false, onlyOnce);

        blockList.mutex.unlock;
        if (toFind.obj !is &this)
            toFind.mutex(false);

        if (ret >= 0)
            ret -= startingOffset;

        return ret;
    }

    void externalStripLeft(scope Iterator* iterator) scope @trusted {
        import sidero.base.text.ascii.characters : isControl, isWhiteSpace;

        blockList.mutex.pureLock;

        {
            Cursor forwardsCursor;
            size_t amount, maximumOffsetFromHead;

            if (iterator is null) {
                forwardsCursor.setup(&blockList, 0);
                maximumOffsetFromHead = blockList.numberOfItems;
            } else {
                forwardsCursor = iterator.forwards;
                maximumOffsetFromHead = iterator.backwards.offsetFromHead;
            }

            Cursor toRemoveCursor = forwardsCursor;

            bool emptyInternal() {
                return toRemoveCursor.offsetFromHead >= maximumOffsetFromHead;
            }

            Char frontInternal() {
                toRemoveCursor.advanceForward(0, maximumOffsetFromHead, true);
                return toRemoveCursor.get();
            }

            void popFrontInternal() {
                import sidero.base.algorithm : min;

                toRemoveCursor.advanceForward(1, maximumOffsetFromHead, true);
            }

            while (!emptyInternal) {
                size_t advance = 1;
                ubyte c = frontInternal();

                if (!(isWhiteSpace(c) || isControl(c)))
                    break;

                amount += advance;
                popFrontInternal();
            }

            if (amount > 0)
                removeOperation(forwardsCursor, maximumOffsetFromHead, amount);
        }

        blockList.mutex.unlock;
    }

    void externalStripRight(scope Iterator* iterator) scope @trusted {
        import sidero.base.text.ascii.characters : isControl, isWhiteSpace;

        blockList.mutex.pureLock;

        ptrdiff_t endOffsetFromHead = -1;
        {
            auto result = changeIndexToOffset(iterator, endOffsetFromHead);
            assert(!result.isSet);

            if (iterator !is null)
                endOffsetFromHead -= iterator.minimumOffsetFromHead;
        }

        size_t minimumOffsetFromHead, maximumOffsetFromHead, lastConsumed;
        scope Cursor toRemoveCursor = cursorFor(iterator, minimumOffsetFromHead, maximumOffsetFromHead, endOffsetFromHead);
        const startingOffset = toRemoveCursor.offsetFromHead;

        {
            size_t amount;

            bool emptyInternal() {
                return toRemoveCursor.offsetFromHead < minimumOffsetFromHead || !toRemoveCursor.inData;
            }

            Char backInternal() {
                toRemoveCursor.advanceBackwards(0, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
                return toRemoveCursor.get();
            }

            void popBackInternal() {
                import sidero.base.algorithm : min;

                toRemoveCursor.advanceBackwards(1, minimumOffsetFromHead, maximumOffsetFromHead, false, false);
            }

            Cursor lastSuccessRemove = toRemoveCursor;

            while (!emptyInternal) {
                Cursor currentLocation = toRemoveCursor;
                ubyte c = backInternal();

                if (!(isWhiteSpace(c) || isControl(c)))
                    break;

                amount++;
                popBackInternal();
                lastSuccessRemove = currentLocation;
            }

            if (amount > 0)
                removeOperation(lastSuccessRemove, maximumOffsetFromHead, amount);
        }

        blockList.mutex.unlock;
    }
}
