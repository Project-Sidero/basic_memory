module sidero.base.text.ascii.readonly;
import sidero.base.text.ascii.builder;
import sidero.base.allocators;

/// Assumes that any initial string value will be null terminated
struct String_ASCII {
    package(sidero.base.text) LiteralType literal;

    private {
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

            int result;

            while (!empty) {
                Char temp = back();

                result = del(temp);
                if (result)
                    return result;

                popBack();
            }

            return result;
        }
    }

    ///
    alias Char = ubyte;
    ///
    alias LiteralType = const(ubyte)[];

    ///
    mixin OpApplyCombos!("Char", null, ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        static Text = "Hello there!";
        String_ASCII text = String_ASCII(Text);

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
        static Text = "Hello there!";
        String_ASCII text = String_ASCII(Text);

        size_t lastIndex = Text.length;

        foreach_reverse (c; text) {
            assert(lastIndex > 0);
            lastIndex--;
            assert(Text[lastIndex] == c);
        }

        assert(lastIndex == 0);
    }

nothrow @nogc:

    /// Makes no guarantee that the string is actually null terminated. Unsafe!!!
    const(ubyte)* ptr() @system {
        if (this.lifeTime !is null)
            return this.lifeTime.original.ptr;
        else
            return this.literal.ptr;
    }

    ///
    unittest {
        String_ASCII text;
        assert(text.ptr is null);

        text = String_ASCII("Me haz data!");
        assert(text.ptr !is null);
    }

    ///
    const(Char)[] unsafeGetLiteral() @system {
        return this.literal;
    }

    ///
    unittest {
        String_ASCII text;
        assert(text.ptr is null);

        text = String_ASCII("Me haz data!");
        assert(text.unsafeGetLiteral !is null);
    }

    ///
    String_ASCII opSlice() scope @trusted {
        if (isNull)
            return String_ASCII();

        String_ASCII ret;

        ret.lifeTime = this.lifeTime;
        if (ret.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        ret.literal = this.literal;
        ret.setupIterator();
        return ret;
    }

    ///
    unittest {
        static Text = "goods";

        String_ASCII str = Text;
        assert(!str.haveIterator);

        String_ASCII sliced = str[];
        assert(sliced.haveIterator);
        assert(sliced.length == Text.length);
    }

    ///
    String_ASCII opSlice(ptrdiff_t start, ptrdiff_t end) scope @trusted {
        changeIndexToOffset(start, end);
        assert(start <= end, "Start of slice must be before or equal to end.");
        assert(end <= this.literal.length, "End of slice must be before or equal to length.");

        if (start == end)
            return String_ASCII();

        String_ASCII ret;

        ret.lifeTime = this.lifeTime;
        if (ret.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        ret.literal = this.literal[start .. end];
        return ret;
    }

    ///
    unittest {
        String_ASCII original = String_ASCII("split me here");
        String_ASCII split = original[6 .. 8];
        assert(split.length == 2);
        assert(split.ptr is original.ptr + 6);
    }

    ///
    String_ASCII withoutIterator() scope @trusted {
        String_ASCII ret;
        ret.literal = this.literal;
        ret.lifeTime = this.lifeTime;

        if (this.lifeTime !is null)
            atomicOp!"+="(ret.lifeTime.refCount, 1);

        return ret;
    }

    ///
    unittest {
        String_ASCII stuff = String_ASCII("I have no iterator!");
        assert(stuff.tupleof == stuff.withoutIterator.tupleof);
    }

@safe:

    ///
    void opAssign(scope const(char)[] literal) scope @trusted {
        this = String_ASCII(cast(LiteralType)literal);
    }

    ///
    unittest {
        String_ASCII info;
        info = "abcd";
    }

    ///
    void opAssign(scope LiteralType literal) scope @trusted {
        this = String_ASCII(literal);
    }

    ///
    unittest {
        String_ASCII info;
        info = cast(LiteralType)['a', 'b', 'c', 'd'];
    }

    @disable void opAssign(scope const(char)[] other) scope const;
    @disable void opAssign(scope LiteralType other) scope const;

    ///
    this(ref return scope String_ASCII other) @trusted scope {
        import core.atomic : atomicOp;

        this.tupleof = other.tupleof;

        if (haveIterator)
            this.iterator.rc(true);
        if (this.lifeTime !is null)
            atomicOp!"+="(this.lifeTime.refCount, 1);
    }

    ///
    unittest {
        String_ASCII original = String_ASCII("stuff here");
        String_ASCII copied = original;
    }

    @disable this(ref return scope const String_ASCII other) scope const;
    @disable this(this) scope;

    @trusted {
        ///
        this(scope return string literal, scope return RCAllocator allocator = RCAllocator.init, scope return string toDeallocate = null) scope {
            this(cast(LiteralType)literal, allocator, cast(LiteralType)toDeallocate);
        }

        ///
        unittest {
            String_ASCII foobar = String_ASCII("abc");
        }

        ///
        this(scope return LiteralType literal, scope return RCAllocator allocator = RCAllocator.init,
                scope return LiteralType toDeallocate = null) scope {
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
            String_ASCII foobar = String_ASCII(cast(LiteralType)"Fds");
        }

        @disable this(scope return string literal, scope return RCAllocator allocator = RCAllocator.init,
                scope return string toDeallocate = null) scope const;
        @disable this(scope return LiteralType literal, scope return RCAllocator allocator = RCAllocator.init,
                scope return LiteralType toDeallocate = null) scope const;
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
    bool isNull() scope {
        return this.literal is null || this.literal.length == 0;
    }

    ///
    unittest {
        String_ASCII stuff;
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
        String_ASCII thing = String_ASCII("bar");
        assert(!thing.haveIterator);

        assert(!thing.empty);
        thing.popFront;

        assert(thing.haveIterator);
    }

    /**
    Returns: if ``ptr`` will return a null terminated string or not
    */
    bool isPtrNullTerminated() scope @trusted {
        if (isNull)
            return false;
        else if (this.literal[$ - 1] == '\0')
            return true;
        else if (this.lifeTime is null)
            return this.literal[$ - 1] == '\0';

        return this.lifeTime.original[$ - 1] == '\0' &&
            ((this.lifeTime.original.ptr + this.lifeTime.original.length) - (this.literal.length + 1)) is this.literal.ptr;
    }

    ///
    unittest {
        static String_ASCII global = String_ASCII("oh yeah\0");
        assert(global.isPtrNullTerminated());

        String_ASCII stack = String_ASCII("hmm...");
        assert(!stack.isPtrNullTerminated());

        string someText = "oh noes";
        String_ASCII someMoreStack = String_ASCII(someText);
        assert(!someMoreStack.isPtrNullTerminated());
    }

    ///
    alias opDollar = length;

    /// Removes null terminator at the end if it has one
    size_t length() const scope {
        size_t ret = this.literal.length;
        if (ret > 0 && this.literal[$ - 1] == '\0')
            ret--;
        return ret;
    }

    ///
    unittest {
        static String_ASCII global = String_ASCII("oh yeah\0");
        assert(global.length == 7);
        assert(global.literal.length == 8);

        String_ASCII stack = String_ASCII("hmm...");
        assert(stack.length == 6);
        assert(stack.literal.length == 6);
    }

    ///
    StringBuilder_ASCII asMutable(RCAllocator allocator = RCAllocator.init) scope {
        return StringBuilder_ASCII(allocator, this);
    }

    ///
    unittest {
        StringBuilder_ASCII got = String_ASCII("stuff goes here, or there, wazzup").asMutable();
        assert(got.length == 33);
    }

    ///
    String_ASCII dup(RCAllocator allocator = RCAllocator.init) scope @trusted {
        if (isNull)
            return String_ASCII();

        if (allocator.isNull) {
            if (lifeTime !is null)
                allocator = lifeTime.allocator;
            else
                allocator = globalAllocator();
        }

        ubyte[] zliteral;

        if (this.literal[$ - 1] == '\0')
            zliteral = allocator.makeArray!ubyte(this.literal);
        else if (this.lifeTime !is null && this.lifeTime.original.length >= this.literal.length &&
                this.lifeTime.original[$ - 1] == '\0' &&
                (this.lifeTime.original.ptr + this.lifeTime.original.length) - this.literal.length is this.literal.ptr)
            zliteral = allocator.makeArray!ubyte(cast(ubyte[])(this.literal.ptr[0 .. this.literal.length + 1]));
        else {
            zliteral = allocator.makeArray!ubyte(this.literal.length + 1);
            zliteral[$ - 1] = 0;

            foreach (i, v; this.literal) {
                zliteral[i] = v;
            }
        }

        return String_ASCII(cast(LiteralType)zliteral, allocator, cast(LiteralType)zliteral);
    }

    ///
    @system unittest {
        static String_ASCII original = String_ASCII("ok there goes nothin'\0");
        String_ASCII copy = original.dup;

        assert(copy.length == original.length);
        assert(copy.literal.length == original.literal.length);
        assert(original.ptr !is copy.ptr);
    }

    //

    ///
    String_ASCII opIndex(ptrdiff_t index) scope {
        changeIndexToOffset(index);
        return this[index .. index + 1];
    }

    @disable auto opCast(T)();

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope const(char)[] other) scope {
        return opCmp(cast(LiteralType)other) == 0;
    }

    ///
    unittest {
        String_ASCII first = String_ASCII("first");

        assert(first == "first");
        assert(first != "third");
    }

    ///
    bool opEquals(scope LiteralType other) scope {
        return opCmp(other) == 0;
    }

    ///
    unittest {
        String_ASCII first = String_ASCII("first");

        assert(first == cast(LiteralType)['f', 'i', 'r', 's', 't']);
        assert(first != cast(LiteralType)['t', 'h', 'i', 'r', 'd']);
    }

    ///
    bool opEquals(scope String_ASCII other) scope {
        return opCmp(other.literal) == 0;
    }

    ///
    unittest {
        String_ASCII first = String_ASCII("first");
        String_ASCII notFirst = String_ASCII("first");
        String_ASCII third = String_ASCII("third");

        assert(first == notFirst);
        assert(first != third);
    }

    ///
    bool opEquals(scope StringBuilder_ASCII other) scope {
        return other.opEquals(this);
    }

    ///
    bool ignoreCaseEquals(scope const(char)[] other) scope {
        return ignoreCaseCompare(cast(LiteralType)other) == 0;
    }

    ///
    unittest {
        String_ASCII first = String_ASCII("first");

        assert(first.ignoreCaseEquals("fIrst"));
        assert(!first.ignoreCaseEquals("third"));
    }

    ///
    bool ignoreCaseEquals(scope LiteralType other) scope {
        return ignoreCaseCompare(other) == 0;
    }

    ///
    unittest {
        String_ASCII first = String_ASCII("first");

        assert(first.ignoreCaseEquals(cast(LiteralType)['f', 'I', 'r', 's', 't']));
        assert(!first.ignoreCaseEquals(cast(LiteralType)['t', 'h', 'i', 'r', 'd']));
    }

    ///
    bool ignoreCaseEquals(scope String_ASCII other) scope {
        return ignoreCaseCompare(other.literal) == 0;
    }

    ///
    unittest {
        String_ASCII first = String_ASCII("first");
        String_ASCII notFirst = String_ASCII("fIrst");
        String_ASCII third = String_ASCII("third");

        assert(first.ignoreCaseEquals(notFirst));
        assert(!first.ignoreCaseEquals(third));
    }

    ///
    bool ignoreCaseEquals(scope StringBuilder_ASCII other) scope {
        return other.ignoreCaseEquals(this);
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope const(char)[] other) scope {
        return opCmp(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("a") < "z");
        assert(String_ASCII("z") > "a");
    }

    ///
    int opCmp(scope LiteralType other) scope {
        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (us < other)
            return -1;
        else if (us > other)
            return 1;
        else {
            assert(us == other);
            return 0;
        }
    }

    ///
    unittest {
        assert(String_ASCII("a") < cast(LiteralType)['z']);
        assert(String_ASCII("z") > cast(LiteralType)['a']);
    }

    ///
    int opCmp(scope String_ASCII other) scope {
        return opCmp(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("a") < String_ASCII("z"));
        assert(String_ASCII("z") > String_ASCII("a"));
    }

    ///
    int opCmp(scope StringBuilder_ASCII other) scope {
        return -other.opCmp(this);
    }

    ///
    int ignoreCaseCompare(scope const(char)[] other) scope {
        return ignoreCaseCompare(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("A").ignoreCaseCompare("z") < 0);
        assert(String_ASCII("Z").ignoreCaseCompare("a") > 0);
    }

    ///
    int ignoreCaseCompare(scope LiteralType other) scope {
        import sidero.base.text.ascii.characters : toLower;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (us.length < other.length)
            return -1;
        else if (us.length > other.length)
            return 1;

        foreach (i; 0 .. us.length) {
            ubyte a = us[i].toLower, b = other[i].toLower;

            if (a < b) {
                return -1;
            } else if (a > b) {
                return 1;
            }
        }

        return 0;
    }

    ///
    unittest {
        assert(String_ASCII("A").ignoreCaseCompare(cast(LiteralType)['z']) < 0);
        assert(String_ASCII("Z").ignoreCaseCompare(cast(LiteralType)['a']) > 0);
    }

    ///
    int ignoreCaseCompare(scope String_ASCII other) scope {
        return ignoreCaseCompare(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("A").ignoreCaseCompare(String_ASCII("z")) < 0);
        assert(String_ASCII("Z").ignoreCaseCompare(String_ASCII("a")) > 0);
    }

    ///
    int ignoreCaseCompare(scope StringBuilder_ASCII other) scope {
        return -other.ignoreCaseCompare(this);
    }

    ///
    ulong toHash() scope {
        import sidero.base.hash.utils : hashOf;
        return hashOf(this.literal);
    }

    //

    @property {
        ///
        bool empty() scope {
            return (haveIterator && this.iterator.literal.length == 0) || this.literal.length == 0 ||
                (this.literal.length == 1 && this.literal[0] == '\0');
        }

        ///
        unittest {
            String_ASCII thing;
            assert(thing.empty);
            thing = "bar";
            assert(!thing.empty);
        }

        ///
        Char front() scope {
            assert(!isNull);
            setupIterator;

            return this.iterator.literal[0];
        }

        ///
        unittest {
            static Text = "ok";
            String_ASCII text = String_ASCII(Text);

            foreach (i, c; Text) {
                assert(!text.empty);
                assert(text.front == c);
                text.popFront;
            }

            assert(text.empty);
        }

        ///
        Char back() scope {
            assert(!isNull);
            setupIterator;

            return this.iterator.literal[$ - 1];
        }

        ///
        unittest {
            static Text = "yea nah";
            String_ASCII text = String_ASCII(Text);

            foreach_reverse (i, c; Text) {
                assert(!text.empty);
                assert(text.back == c);
                text.popBack;
            }

            assert(text.empty);
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

    //

    version (none) {
        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope const(char)[] other...) scope @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret ~= other;

            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII got = String_ASCII("abc") ~ " def";
            assert(got == "abc def");
        }

        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope String_ASCII other) scope @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret ~= other;

            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII got = String_ASCII("abc") ~ String_ASCII(" def");
            assert(got == "abc def");
        }

        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope LiteralType other...) scope @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret ~= other;

            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII got = String_ASCII("abc") ~ cast(LiteralType)[' ', 'd', 'e', 'f'];
            assert(got == "abc def");
        }

        ///
        StringBuilder_ASCII opBinary(string op : "~")(scope StringBuilder_ASCII other) scope @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret ~= other;

            return ret;
        }

        ///
        unittest {
            StringBuilder_ASCII got = String_ASCII("abc") ~ StringBuilder_ASCII(" def");
            assert(got == "abc def");
        }

        //

        ///
        StringBuilder_ASCII prepend(scope const(char)[] other...) scope {
            return this.insert(0, other);
        }

        ///
        unittest {
            assert(String_ASCII("def").prepend("abc") == "abcdef");
        }

        ///
        StringBuilder_ASCII prepend(scope String_ASCII other) scope {
            return this.insert(0, other);
        }

        ///
        unittest {
            assert(String_ASCII("def").prepend(String_ASCII("abc")) == "abcdef");
        }

        ///
        StringBuilder_ASCII prepend(scope LiteralType other...) scope {
            return this.insert(0, other);
        }

        ///
        unittest {
            assert(String_ASCII("def").prepend(cast(LiteralType)['a', 'b', 'c']) == "abcdef");
        }

        ///
        StringBuilder_ASCII prepend(scope StringBuilder_ASCII other) scope {
            return this.insert(0, other);
        }

        ///
        unittest {
            assert(String_ASCII("def").prepend(StringBuilder_ASCII("abc")) == "abcdef");
        }

        ///
        StringBuilder_ASCII insert(size_t offset, scope const(char)[] input...) scope {
            return this.insert(offset, cast(LiteralType)input);
        }

        ///
        unittest {
            assert(String_ASCII("def").insert(1, "abc") == "dabcef");
        }

        ///
        StringBuilder_ASCII insert(size_t offset, scope String_ASCII other) scope {
            return this.insert(offset, other.literal);
        }

        ///
        unittest {
            assert(String_ASCII("def").insert(1, String_ASCII("abc")) == "dabcef");
        }

        ///
        StringBuilder_ASCII insert(size_t offset, scope LiteralType other...) scope @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret.insert(offset, other);

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("def").insert(cast(size_t)1, cast(LiteralType)['a', 'b', 'c']) == "dabcef");
        }

        ///
        StringBuilder_ASCII insert(size_t offset, scope StringBuilder_ASCII other) scope @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret.insert(offset, other);

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("def").insert(1, StringBuilder_ASCII("abc")) == "dabcef");
        }

        ///
        StringBuilder_ASCII append(scope const(char)[] input...) scope {
            return this.insert(size_t.max, cast(LiteralType)input);
        }

        ///
        unittest {
            assert(String_ASCII("abc").append("def") == "abcdef");
        }

        ///
        StringBuilder_ASCII append(scope String_ASCII other) scope {
            return this.insert(size_t.max, other.literal);
        }

        ///
        unittest {
            assert(String_ASCII("abc").append(String_ASCII("def")) == "abcdef");
        }

        ///
        StringBuilder_ASCII append(scope LiteralType other...) scope {
            return this.insert(size_t.max, other);
        }

        ///
        unittest {
            assert(String_ASCII("abc").append(cast(LiteralType)"def") == "abcdef");
        }

        ///
        StringBuilder_ASCII append(scope StringBuilder_ASCII other) scope {
            return this.insert(size_t.max, other);
        }

        ///
        unittest {
            assert(String_ASCII("abc").append(StringBuilder_ASCII("def")) == "abcdef");
        }

        ///
        StringBuilder_ASCII clobberPrepend(scope const(char)[] input...) {
            return this.clobberInsert(0, cast(LiteralType)input);
        }

        ///
        unittest {
            assert(String_ASCII("defg").clobberPrepend("abc") == "abcg");
        }

        ///
        StringBuilder_ASCII clobberPrepend(scope String_ASCII other) {
            return this.clobberInsert(0, other.literal);
        }

        ///
        unittest {
            assert(String_ASCII("defg").clobberPrepend(String_ASCII("abc")) == "abcg");
        }

        ///
        StringBuilder_ASCII clobberPrepend(scope LiteralType other...) {
            return this.clobberInsert(0, other);
        }

        ///
        unittest {
            assert(String_ASCII("defg").clobberPrepend(cast(LiteralType)['a', 'b', 'c']) == "abcg");
        }

        ///
        StringBuilder_ASCII clobberPrepend(scope StringBuilder_ASCII other) {
            return this.clobberInsert(0, other);
        }

        ///
        unittest {
            assert(String_ASCII("defg").clobberPrepend(StringBuilder_ASCII("abc")) == "abcg");
        }

        ///
        StringBuilder_ASCII clobberInsert(size_t offset, scope const(char)[] input...) {
            return this.clobberInsert(offset, cast(LiteralType)input);
        }

        ///
        unittest {
            assert(String_ASCII("defgd").clobberInsert(1, "abc") == "dabcd");
        }

        ///
        StringBuilder_ASCII clobberInsert(size_t offset, scope String_ASCII other) {
            return this.clobberInsert(offset, other.literal);
        }

        ///
        unittest {
            assert(String_ASCII("defgd").clobberInsert(1, String_ASCII("abc")) == "dabcd");
        }

        ///
        StringBuilder_ASCII clobberInsert(size_t offset, scope LiteralType other...) @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret.clobberInsert(offset, other);

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("defgd").clobberInsert(cast(size_t)1, cast(LiteralType)['a', 'b', 'c']) == "dabcd");
        }

        ///
        StringBuilder_ASCII clobberInsert(size_t offset, scope StringBuilder_ASCII other) @trusted {
            StringBuilder_ASCII ret;

            if (this.lifeTime !is null)
                ret = StringBuilder_ASCII(this.lifeTime.allocator);

            ret ~= this;
            ret.clobberInsert(offset, other);

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("defgd").clobberInsert(1, StringBuilder_ASCII("abc")) == "dabcd");
        }

        //

        ///
        StringBuilder_ASCII replace(scope const(char)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace("y", String_ASCII("ie")) == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope LiteralType toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(cast(LiteralType)"y", String_ASCII("ie")) == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope String_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(String_ASCII("y"), "ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope String_ASCII toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(String_ASCII("y"), cast(LiteralType)"ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope String_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(String_ASCII("y"), String_ASCII("ie")) == "mie haiestack text");
        }

        //

        ///
        StringBuilder_ASCII replace(scope LiteralType toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(cast(LiteralType)"y", cast(LiteralType)"ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope LiteralType toFind, scope const(char)[] toReplace, bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(cast(LiteralType)"y", "ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope const(char)[] toFind, scope LiteralType toReplace, bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace("y", cast(LiteralType)"ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope const(char)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace("y", "ie") == "mie haiestack text");
        }

        //

        ///
        StringBuilder_ASCII replace(scope LiteralType toFind, scope StringBuilder_ASCII toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(cast(LiteralType)"y", StringBuilder_ASCII("ie")) == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope const(char)[] toFind, scope StringBuilder_ASCII toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace("y", StringBuilder_ASCII("ie")) == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope StringBuilder_ASCII toFind, scope LiteralType toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(StringBuilder_ASCII("y"), cast(LiteralType)"ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope StringBuilder_ASCII toFind, scope const(char)[] toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(StringBuilder_ASCII("y"), "ie") == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope StringBuilder_ASCII toFind, scope StringBuilder_ASCII toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(StringBuilder_ASCII("y"), StringBuilder_ASCII("ie")) == "mie haiestack text");
        }

        //

        ///
        StringBuilder_ASCII replace(scope String_ASCII toFind, scope StringBuilder_ASCII toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(String_ASCII("y"), StringBuilder_ASCII("ie")) == "mie haiestack text");
        }

        ///
        StringBuilder_ASCII replace(scope StringBuilder_ASCII toFind, scope String_ASCII toReplace,
                bool caseSensitive = true, bool onceOnly = false) scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.replace(toFind, toReplace, caseSensitive, onceOnly);
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("my haystack text").replace(StringBuilder_ASCII("y"), String_ASCII("ie")) == "mie haiestack text");
        }

        //

        ///
        StringBuilder_ASCII toLower() scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.toLower();
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("Hello World!").toLower() == "hello world!");
        }

        ///
        StringBuilder_ASCII toUpper() scope @trusted {
            StringBuilder_ASCII ret = this.asMutable();
            ret.toUpper();
            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("Hello World!").toUpper() == "HELLO WORLD!");
        }
    }

    //

    ///
    bool startsWith(scope const(char)[] other...) scope {
        return this.startsWith(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("hello! whatzup").startsWith("hello!"));
        assert(!String_ASCII("hello! whatzup").startsWith("ello!"));
    }

    ///
    bool startsWith(scope LiteralType other...) scope {
        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length == 0 || other.length == 0 || other.length > us.length)
            return false;
        return this.literal[0 .. other.length] == other;
    }

    ///
    unittest {
        assert(String_ASCII("hello! whatzup").startsWith(cast(LiteralType)"hello!"));
        assert(!String_ASCII("hello! whatzup").startsWith(cast(LiteralType)"ello!"));
    }

    ///
    bool startsWith(scope String_ASCII other) scope {
        return this.startsWith(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("hello! whatzup").startsWith(String_ASCII("hello!")));
        assert(!String_ASCII("hello! whatzup").startsWith(String_ASCII("ello!")));
    }

    ///
    bool ignoreCaseStartsWith(scope const(char)[] other...) scope {
        return this.ignoreCaseStartsWith(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("heLLo! whatzup").ignoreCaseStartsWith("hello!"));
        assert(!String_ASCII("heLLo! whatzup").ignoreCaseStartsWith("ello!"));
    }

    ///
    bool ignoreCaseStartsWith(scope LiteralType other...) scope {
        import sidero.base.text.ascii.characters : toLower;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length == 0 || other.length == 0 || other.length > us.length)
            return false;

        foreach (i; 0 .. other.length) {
            if (other[i].toLower != us[i].toLower)
                return false;
        }

        return true;
    }

    ///
    unittest {
        assert(String_ASCII("heLLo! whatzup").ignoreCaseStartsWith(cast(LiteralType)"hello!"));
        assert(!String_ASCII("heLLo! whatzup").ignoreCaseStartsWith(cast(LiteralType)"ello!"));
    }

    ///
    bool ignoreCaseStartsWith(scope String_ASCII other) scope {
        return this.ignoreCaseStartsWith(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("heLLo! whatzup").ignoreCaseStartsWith(String_ASCII("hello!")));
        assert(!String_ASCII("heLLo! whatzup").ignoreCaseStartsWith(String_ASCII("ello!")));
    }

    version (none) {
        ///
        bool startsWith(scope StringBuilder_ASCII other) scope {
            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (us.length == 0 || other.isNull)
                return false;

            size_t offsetForUs;
            bool ret = true;

            other.foreachBlocks((data) {
                if (offsetForUs + data.length > us.length || us[offsetForUs .. offsetForUs + data.length] != data) {
                    ret = false;
                    return 1;
                }

                offsetForUs += data.length;
                return 0;
            }, null);

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("hello! whatzup").startsWith(StringBuilder_ASCII("hello!")));
            assert(!String_ASCII("hello! whatzup").startsWith(StringBuilder_ASCII("ello!")));
        }

        ///
        bool ignoreCaseStartsWith(scope StringBuilder_ASCII other) scope {
            import sidero.base.text.ascii.characters : toLower;

            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (us.length == 0 || other.isNull)
                return false;

            size_t offsetForUs;
            bool ret = true;

            other.foreachBlocks((data) {
                if (offsetForUs + data.length <= us.length) {
                    foreach (i; 0 .. data.length) {
                        if (data[i].toLower != us[offsetForUs + i].toLower) {
                            ret = false;
                            return 1;
                        }
                    }
                } else {
                    ret = false;
                    return 1;
                }

                offsetForUs += data.length;
                return 0;
            }, null);

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("heLLo! whatzup").ignoreCaseStartsWith(StringBuilder_ASCII("hello!")));
            assert(!String_ASCII("heLLo! whatzup").ignoreCaseStartsWith(StringBuilder_ASCII("ello!")));
        }
    }

    ///
    bool endsWith(scope const(char)[] other...) scope {
        return this.endsWith(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("bye bye aw").endsWith("e aw"));
        assert(!String_ASCII("bye bye aw").endsWith("e w"));
    }

    ///
    bool endsWith(scope LiteralType other...) scope {
        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (us.length == 0 || other.length == 0 || us.length < other.length)
            return false;
        return us[$ - other.length .. $] == other;
    }

    ///
    unittest {
        assert(String_ASCII("bye bye aw").endsWith(cast(LiteralType)"e aw"));
        assert(!String_ASCII("bye bye aw").endsWith(cast(LiteralType)"e w"));
    }

    ///
    bool endsWith(scope String_ASCII other) scope {
        return this.endsWith(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("bye bye aw").endsWith(String_ASCII("e aw")));
        assert(!String_ASCII("bye bye aw").endsWith(String_ASCII("e w")));
    }

    ///
    bool ignoreCaseEndsWith(scope const(char)[] other...) scope {
        return this.ignoreCaseEndsWith(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("bye bye Aw").ignoreCaseEndsWith("e aw"));
        assert(!String_ASCII("bye bye Aw").ignoreCaseEndsWith("e w"));
    }

    ///
    bool ignoreCaseEndsWith(scope LiteralType other...) scope {
        import sidero.base.text.ascii.characters : toLower;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (us.length == 0 || other.length == 0 || us.length < other.length)
            return false;

        size_t ourOffset = us.length - other.length;
        foreach (i; 0 .. other.length) {
            if (other[i].toLower != us[ourOffset++].toLower)
                return false;
        }

        return true;
    }

    ///
    unittest {
        assert(String_ASCII("bye bye Aw").ignoreCaseEndsWith(cast(LiteralType)"e aw"));
        assert(!String_ASCII("bye bye Aw").ignoreCaseEndsWith(cast(LiteralType)"e w"));
    }

    ///
    bool ignoreCaseEndsWith(scope String_ASCII other) scope {
        return this.ignoreCaseEndsWith(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("bye bye Aw").ignoreCaseEndsWith(String_ASCII("e aw")));
        assert(!String_ASCII("bye bye Aw").ignoreCaseEndsWith(String_ASCII("e w")));
    }

    version (none) {
        ///
        bool endsWith(scope StringBuilder_ASCII other) scope {
            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (us.length == 0 || other.isNull)
                return false;

            size_t offsetForUs = size_t.max, otherLength;
            bool ret = true;

            other.foreachBlocks((data) {
                if (offsetForUs == size_t.max) {
                    if (otherLength > us.length) {
                        ret = false;
                        return 1;
                    }

                    offsetForUs = us.length - otherLength;
                }

                if (us[offsetForUs .. offsetForUs + data.length] != data) {
                    ret = false;
                    return 1;
                }

                offsetForUs += data.length;
                return 0;
            }, (size_t otherLength2) { otherLength = otherLength2; });

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("bye bye aw").endsWith(StringBuilder_ASCII("e aw")));
            assert(!String_ASCII("bye bye aw").endsWith(StringBuilder_ASCII("e w")));
        }

        ///
        bool ignoreCaseEndsWith(scope StringBuilder_ASCII other) scope {
            import sidero.base.text.ascii.characters : toLower;

            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (us.length == 0 || other.isNull)
                return false;

            size_t offsetForUs = size_t.max, otherLength;
            bool ret = true;

            other.foreachBlocks((data) {
                if (offsetForUs == size_t.max) {
                    if (otherLength > us.length) {
                        ret = false;
                        return 1;
                    }

                    offsetForUs = us.length - otherLength;
                }

                foreach (i; 0 .. data.length) {
                    if (data[i].toLower != us[offsetForUs + i].toLower) {
                        ret = false;
                        return 1;
                    }
                }

                offsetForUs += data.length;
                return 0;
            }, (size_t otherLength2) { otherLength = otherLength2; });

            return ret;
        }

        ///
        unittest {
            assert(String_ASCII("bye bye Aw").ignoreCaseEndsWith(StringBuilder_ASCII("e aw")));
            assert(!String_ASCII("bye bye Aw").ignoreCaseEndsWith(StringBuilder_ASCII("e w")));
        }
    }

    //

    ///
    ptrdiff_t indexOf(scope const(char)[] other...) scope {
        return indexOf(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").indexOf("nothing") == -1);
        assert(String_ASCII("to find this").indexOf("i") == 4);
    }

    ///
    ptrdiff_t indexOf(scope LiteralType other...) scope {
        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length > us.length)
            return -1;

        foreach (i; 0 .. (us.length + 1) - other.length) {
            if (us[i .. i + other.length] == other)
                return i;
        }

        return -1;
    }

    ///
    unittest {
        assert(String_ASCII("to find this").indexOf(cast(LiteralType)"nothing") == -1);
        assert(String_ASCII("to find this").indexOf(cast(LiteralType)"i") == 4);
    }

    ///
    ptrdiff_t indexOf(scope String_ASCII other) scope {
        return indexOf(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").indexOf(String_ASCII("nothing")) == -1);
        assert(String_ASCII("to find this").indexOf(String_ASCII("i")) == 4);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope const(char)[] other...) scope {
        return ignoreCaseIndexOf(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").ignoreCaseIndexOf("nothing") == -1);
        assert(String_ASCII("to fInd this").ignoreCaseIndexOf("i") == 4);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope LiteralType other...) scope {
        import sidero.base.text.ascii.characters : toLower;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length > us.length)
            return -1;

        Loop: foreach (i; 0 .. (us.length + 1) - other.length) {
            foreach (j; 0 .. other.length) {
                if (us[i + j].toLower != other[j].toLower)
                    continue Loop;
            }

            return i;
        }

        return -1;
    }

    ///
    unittest {
        assert(String_ASCII("to find this").ignoreCaseIndexOf(cast(LiteralType)"nothing") == -1);
        assert(String_ASCII("to fInd this").ignoreCaseIndexOf(cast(LiteralType)"i") == 4);
    }

    ///
    ptrdiff_t ignoreCaseIndexOf(scope String_ASCII other) scope {
        return ignoreCaseIndexOf(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").ignoreCaseIndexOf(String_ASCII("nothing")) == -1);
        assert(String_ASCII("to fInd this").ignoreCaseIndexOf(String_ASCII("i")) == 4);
    }

    version (none) {
        ///
        ptrdiff_t indexOf(scope StringBuilder_ASCII other) scope {
            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (other.length > 0) {
                while (us.length >= other.length) {
                    size_t offsetIntoUs, otherLength;
                    bool matched = true;

                    other.foreachBlocks((data) {
                        if (data.length > us.length - offsetIntoUs || data != us[offsetIntoUs .. offsetIntoUs + data.length]) {
                            matched = false;
                            return 1;
                        }

                        offsetIntoUs += data.length;
                        return 0;
                    }, (size_t otherLength2) { otherLength = otherLength2; });

                    if (matched)
                        return &us[0] - &this.literal[0];
                    else
                        us = us[1 .. $];
                }
            }

            return -1;
        }

        ///
        unittest {
            assert(String_ASCII("to find this").indexOf(StringBuilder_ASCII("nothing")) == -1);
            assert(String_ASCII("to find this").indexOf(StringBuilder_ASCII("i")) == 4);
        }

        ///
        ptrdiff_t ignoreCaseIndexOf(scope StringBuilder_ASCII other) scope {
            import sidero.base.text.ascii.characters : toLower;

            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (other.length > 0) {
                while (us.length >= other.length) {
                    size_t offsetIntoUs, otherLength;
                    bool matched = true;

                    other.foreachBlocks((data) {
                        if (data.length <= us.length - offsetIntoUs) {
                            foreach (i; 0 .. data.length) {
                                if (data[i].toLower != us[offsetIntoUs + i].toLower) {
                                    matched = false;
                                    return 1;
                                }
                            }
                        } else {
                            matched = false;
                            return 1;
                        }

                        offsetIntoUs += data.length;
                        return 0;
                    }, (size_t otherLength2) { otherLength = otherLength2; });

                    if (matched)
                        return &us[0] - &this.literal[0];
                    else
                        us = us[1 .. $];
                }
            }

            return -1;
        }

        ///
        unittest {
            assert(String_ASCII("to find this").ignoreCaseIndexOf(StringBuilder_ASCII("nothing")) == -1);
            assert(String_ASCII("to fInd this").ignoreCaseIndexOf(StringBuilder_ASCII("i")) == 4);
        }
    }

    ///
    ptrdiff_t lastIndexOf(scope const(char)[] other...) scope {
        return lastIndexOf(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").lastIndexOf("nothing") == -1);
        assert(String_ASCII("to find this").lastIndexOf("i") == 10);
    }

    ///
    ptrdiff_t lastIndexOf(scope LiteralType other...) scope {
        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length > us.length)
            return -1;

        foreach_reverse (i; 0 .. (us.length + 1) - other.length) {
            if (us[i .. i + other.length] == other)
                return i;
        }

        return -1;
    }

    ///
    unittest {
        assert(String_ASCII("to find this").lastIndexOf(cast(LiteralType)"nothing") == -1);
        assert(String_ASCII("to find this").lastIndexOf(cast(LiteralType)"i") == 10);
    }

    ///
    ptrdiff_t lastIndexOf(scope String_ASCII other) scope {
        return lastIndexOf(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").lastIndexOf(String_ASCII("nothing")) == -1);
        assert(String_ASCII("to find this").lastIndexOf(String_ASCII("i")) == 10);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope const(char)[] other...) scope {
        return ignoreCaseLastIndexOf(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").ignoreCaseLastIndexOf("nothing") == -1);
        assert(String_ASCII("to find thIs").ignoreCaseLastIndexOf("i") == 10);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope LiteralType other...) scope {
        import sidero.base.text.ascii.characters : toLower;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length > us.length)
            return -1;

        Loop: foreach_reverse (i; 0 .. (us.length + 1) - other.length) {
            foreach (j; 0 .. other.length) {
                if (us[i + j].toLower != other[j].toLower)
                    continue Loop;
            }

            return i;
        }

        return -1;
    }

    ///
    unittest {
        assert(String_ASCII("to find this").ignoreCaseLastIndexOf(cast(LiteralType)"nothing") == -1);
        assert(String_ASCII("to find thIs").ignoreCaseLastIndexOf(cast(LiteralType)"i") == 10);
    }

    ///
    ptrdiff_t ignoreCaseLastIndexOf(scope String_ASCII other) scope {
        return ignoreCaseLastIndexOf(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("to find this").ignoreCaseLastIndexOf(String_ASCII("nothing")) == -1);
        assert(String_ASCII("to find thIs").ignoreCaseLastIndexOf(String_ASCII("i")) == 10);
    }

    version (none) {
        ///
        ptrdiff_t lastIndexOf(scope StringBuilder_ASCII other) scope {
            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (us.length == 0 || other.isNull)
                return -1;

            ptrdiff_t possibleValue = -1;

            if (other.length > 0) {
                while (us.length >= other.length) {
                    size_t offsetIntoUs, otherLength;
                    bool matched = true;

                    other.foreachBlocks((data) {
                        if (data.length > us.length - offsetIntoUs || data != us[offsetIntoUs .. offsetIntoUs + data.length]) {
                            matched = false;
                            return 1;
                        }

                        offsetIntoUs += data.length;
                        return 0;
                    }, (size_t otherLength2) { otherLength = otherLength2; });

                    if (matched) {
                        possibleValue = &us[0] - &this.literal[0];
                        us = us[other.length .. $];
                    } else
                        us = us[1 .. $];
                }
            }

            return possibleValue;
        }

        ///
        unittest {
            assert(String_ASCII("to find this").lastIndexOf(StringBuilder_ASCII("nothing")) == -1);
            assert(String_ASCII("to find this").lastIndexOf(StringBuilder_ASCII("i")) == 10);
        }

        ///
        ptrdiff_t ignoreCaseLastIndexOf(scope StringBuilder_ASCII other) scope {
            import sidero.base.text.ascii.characters : toLower;

            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (us.length == 0 || other.isNull)
                return -1;

            ptrdiff_t possibleValue = -1;

            if (other.length > 0) {
                while (us.length >= other.length) {
                    size_t offsetIntoUs, otherLength;
                    bool matched = true;

                    other.foreachBlocks((data) {
                        if (data.length <= us.length - offsetIntoUs) {
                            foreach (i; 0 .. data.length) {
                                if (data[i].toLower != us[offsetIntoUs + i].toLower) {
                                    matched = false;
                                    return 1;
                                }
                            }
                        } else {
                            matched = false;
                            return 1;
                        }

                        offsetIntoUs += data.length;
                        return 0;
                    }, (size_t otherLength2) { otherLength = otherLength2; });

                    if (matched) {
                        possibleValue = &us[0] - &this.literal[0];
                        us = us[other.length .. $];
                    } else
                        us = us[1 .. $];
                }
            }

            return possibleValue;
        }

        ///
        unittest {
            assert(String_ASCII("to find this").ignoreCaseLastIndexOf(StringBuilder_ASCII("nothing")) == -1);
            assert(String_ASCII("to find thIs").ignoreCaseLastIndexOf(StringBuilder_ASCII("i")) == 10);
        }
    }

    //

    ///
    size_t count(scope const(char)[] other...) scope {
        return count(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("congrats its alive").count("a") == 2);
        assert(String_ASCII("congrats its alive").count("b") == 0);
    }

    ///
    size_t count(scope LiteralType other...) scope {
        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

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
    unittest {
        assert(String_ASCII("congrats its alive").count(cast(LiteralType)"a") == 2);
        assert(String_ASCII("congrats its alive").count(cast(LiteralType)"b") == 0);
    }

    ///
    size_t count(scope String_ASCII other) scope {
        return count(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("congrats its alive").count(String_ASCII("a")) == 2);
        assert(String_ASCII("congrats its alive").count(String_ASCII("b")) == 0);
    }

    ///
    size_t ignoreCaseCount(scope const(char)[] other...) scope {
        return ignoreCaseCount(cast(LiteralType)other);
    }

    ///
    unittest {
        assert(String_ASCII("congrAts its alive").ignoreCaseCount("a") == 2);
        assert(String_ASCII("congrats its alive").ignoreCaseCount("b") == 0);
    }

    ///
    size_t ignoreCaseCount(scope LiteralType other...) scope {
        import sidero.base.text.ascii.characters : toLower;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];
        if (other.length > 0 && other[$ - 1] == '\0')
            other = other[0 .. $ - 1];

        if (other.length > us.length)
            return 0;

        size_t got;

        Loop: while (us.length >= other.length) {
            foreach (i; 0 .. other.length) {
                if (us[i].toLower != other[i].toLower) {
                    us = us[1 .. $];
                    continue Loop;
                }
            }

            got++;
            us = us[other.length .. $];
        }

        return got;
    }

    ///
    unittest {
        assert(String_ASCII("congrAts its alive").ignoreCaseCount(cast(LiteralType)"a") == 2);
        assert(String_ASCII("congrats its alive").ignoreCaseCount(cast(LiteralType)"b") == 0);
    }

    ///
    size_t ignoreCaseCount(scope String_ASCII other) scope {
        return ignoreCaseCount(other.literal);
    }

    ///
    unittest {
        assert(String_ASCII("congrats its alive").ignoreCaseCount(String_ASCII("a")) == 2);
        assert(String_ASCII("congrats its alive").ignoreCaseCount(String_ASCII("b")) == 0);
    }

    version (none) {
        ///
        size_t count(scope StringBuilder_ASCII other) scope {
            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (other.length == 0)
                return 0;

            size_t got;

            while (us.length >= other.length) {
                size_t offsetIntoUs, otherLength;
                bool matched = true;

                other.foreachBlocks((data) {
                    if (data.length > us.length - offsetIntoUs || data != us[offsetIntoUs .. offsetIntoUs + data.length]) {
                        matched = false;
                        return 1;
                    }

                    offsetIntoUs += data.length;
                    return 0;
                }, (size_t otherLength2) { otherLength = otherLength2; });

                if (matched) {
                    got++;
                    us = us[other.length .. $];
                } else
                    us = us[1 .. $];
            }

            return got;
        }

        ///
        unittest {
            assert(String_ASCII("congrats its alive").count(StringBuilder_ASCII("a")) == 2);
            assert(String_ASCII("congrats its alive").count(StringBuilder_ASCII("b")) == 0);
        }

        ///
        size_t ignoreCaseCount(scope StringBuilder_ASCII other) scope {
            import sidero.base.text.ascii.characters : toLower;

            LiteralType us = this.literal;
            if (us.length > 0 && us[$ - 1] == '\0')
                us = us[0 .. $ - 1];

            if (other.length == 0)
                return 0;

            size_t got;

            while (us.length >= other.length) {
                size_t offsetIntoUs, otherLength;
                bool matched = true;

                other.foreachBlocks((data) {
                    if (data.length <= us.length - offsetIntoUs) {
                        foreach (i; 0 .. data.length) {
                            if (data[i].toLower != us[offsetIntoUs + i].toLower) {
                                matched = false;
                                return 1;
                            }
                        }
                    } else {
                        matched = false;
                        return 1;
                    }

                    offsetIntoUs += data.length;
                    return 0;
                }, (size_t otherLength2) { otherLength = otherLength2; });

                if (matched) {
                    got++;
                    us = us[other.length .. $];
                } else
                    us = us[1 .. $];
            }

            return got;
        }

        ///
        unittest {
            assert(String_ASCII("congrAts its alive").ignoreCaseCount(StringBuilder_ASCII("a")) == 2);
            assert(String_ASCII("congrats its alive").ignoreCaseCount(StringBuilder_ASCII("b")) == 0);
        }
    }

    //

    ///
    bool contains(scope const(char)[] other...) scope {
        if (other is null)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    unittest {
        assert(String_ASCII("youwanna what?").contains("wanna"));
        assert(!String_ASCII("youwanna what?").contains("bahhhh"));
    }

    ///
    bool contains(scope LiteralType other...) scope {
        if (other is null)
            return 0;
        return indexOf(other) >= 0;
    }

    ///
    unittest {
        assert(String_ASCII("youwanna what?").contains(cast(LiteralType)"wanna"));
        assert(!String_ASCII("youwanna what?").contains(cast(LiteralType)"bahhhh"));
    }

    ///
    bool contains(scope String_ASCII other) scope {
        if (other.isNull)
            return 0;
        return indexOf(other.literal) >= 0;
    }

    ///
    unittest {
        assert(String_ASCII("youwanna what?").contains(String_ASCII("wanna")));
        assert(!String_ASCII("youwanna what?").contains(String_ASCII("bahhhh")));
    }

    ///
    bool ignoreCaseContains(scope const(char)[] other...) scope {
        if (other is null)
            return 0;
        return ignoreCaseIndexOf(other) >= 0;
    }

    ///
    unittest {
        assert(String_ASCII("youwaNNa what?").ignoreCaseContains("wanna"));
        assert(!String_ASCII("youwanna what?").ignoreCaseContains("bahhhh"));
    }

    ///
    bool ignoreCaseContains(scope LiteralType other...) scope {
        if (other is null)
            return 0;
        return ignoreCaseIndexOf(other) >= 0;
    }

    ///
    unittest {
        assert(String_ASCII("youwaNNa what?").ignoreCaseContains(cast(LiteralType)"wanna"));
        assert(!String_ASCII("youwanna what?").ignoreCaseContains(cast(LiteralType)"bahhhh"));
    }

    ///
    bool ignoreCaseContains(scope String_ASCII other) scope {
        if (other.isNull)
            return 0;
        return ignoreCaseIndexOf(other.literal) >= 0;
    }

    ///
    unittest {
        assert(String_ASCII("youwaNNa what?").ignoreCaseContains(String_ASCII("wanna")));
        assert(!String_ASCII("youwanna what?").ignoreCaseContains(String_ASCII("bahhhh")));
    }

    version (none) {
        ///
        bool contains(scope StringBuilder_ASCII other) scope {
            if (other.isNull)
                return 0;
            return indexOf(other) >= 0;
        }

        ///
        unittest {
            assert(String_ASCII("youwanna what?").contains(StringBuilder_ASCII("wanna")));
            assert(!String_ASCII("youwanna what?").contains(StringBuilder_ASCII("bahhhh")));
        }

        ///
        bool ignoreCaseContains(scope StringBuilder_ASCII other) scope {
            if (other.isNull)
                return 0;
            return ignoreCaseIndexOf(other) >= 0;
        }

        ///
        unittest {
            assert(String_ASCII("youwaNNa what?").ignoreCaseContains(StringBuilder_ASCII("wanna")));
            assert(!String_ASCII("youwanna what?").ignoreCaseContains(StringBuilder_ASCII("bahhhh")));
        }
    }

    //

    ///
    String_ASCII strip() scope return {
        stripLeft();
        stripRight();
        return this;
    }

    ///
    unittest {
        String_ASCII value = String_ASCII("  \t abc\t\r\n \0");
        value.strip;
        assert(value == "abc");

        assert(String_ASCII("  \t abc\t\r\n \0").strip == "abc");
    }

    ///
    String_ASCII stripLeft() scope return {
        import sidero.base.text.ascii.characters : isWhiteSpace;

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];

        size_t amount;

        foreach (c; us) {
            if (!c.isWhiteSpace && c != '\0')
                break;
            amount++;
        }

        this.literal = this.literal[amount .. $];
        return this;
    }

    ///
    unittest {
        String_ASCII value = String_ASCII("  \t abc\t\r\n \0");
        value.stripLeft;
        assert(value == "abc\t\r\n \0");

        assert(String_ASCII("  \t abc\t\r\n \0").stripLeft == "abc\t\r\n \0");
    }

    ///
    String_ASCII stripRight() scope return {
        import sidero.base.text.ascii.characters : isWhiteSpace;

        size_t amount;

        foreach_reverse (c; this.literal) {
            if (!c.isWhiteSpace && c != '\0')
                break;
            amount++;
        }

        this.literal = this.literal[0 .. $ - amount];
        return this;
    }

    ///
    unittest {
        String_ASCII value = String_ASCII("  \t abc\t\r\n \0");
        value.stripRight;
        assert(value == "  \t abc");

        assert(String_ASCII("  \t abc\t\r\n \0").stripRight == "  \t abc");
    }

    ///
    void stripZeroTerminator() scope {
        if (this.literal.length > 0 && this.literal[$ - 1] == 0)
            this.literal = this.literal[0 .. $ - 1];
    }

    ///
    unittest {
        String_ASCII value = String_ASCII("foobar\0");
        assert(value.literal.length == 7);
        value.stripZeroTerminator();
        assert(value.literal.length == 6);
    }

private:
    static struct LifeTime {
        shared(int) refCount;
        RCAllocator allocator;
        LiteralType original;
    }

    static struct Iterator {
        shared(int) refCount;
        RCAllocator allocator;
        LiteralType literal;

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

        LiteralType us = this.literal;
        if (us.length > 0 && us[$ - 1] == '\0')
            us = us[0 .. $ - 1];

        this.iterator = allocator.make!Iterator(1, allocator, us);
        assert(this.iterator !is null);
    }

    void changeIndexToOffset(ref ptrdiff_t a) scope {
        size_t actualLength = literal.length;

        if (a < 0) {
            assert(actualLength >= -a, "First offset must be smaller than length");
            a = actualLength + a;
        }
    }

    void changeIndexToOffset(ref ptrdiff_t a, ref ptrdiff_t b) scope {
        size_t actualLength = literal.length;

        if (a < 0) {
            assert(actualLength >= -a, "First offset must be smaller than length");
            a = actualLength + a;
        }

        if (b < 0) {
            assert(actualLength >= -b, "Second offset must be smaller than length");
            b = actualLength + b;
        }

        if (b < a) {
            ptrdiff_t temp = a;
            a = b;
            b = temp;
        }
    }
}

unittest {
    string SomeText = "Hi there!";
    String_ASCII str = SomeText;

    size_t seen;

    foreach (c; str) {
        bool matched;
        foreach (c2; str[seen]) {
            matched = c2 == c;
            break;
        }

        assert(matched);
        assert(SomeText[seen++] == cast(char)c);
    }

    assert(seen == SomeText.length);
    seen = 0;

    foreach (c; str) {
        assert(SomeText[seen++] == cast(char)c);
    }

    assert(seen == SomeText.length);
    seen = 0;

    foreach_reverse (ubyte c; str) {
        assert(seen < SomeText.length);
        assert(SomeText[$ - (seen + 1)] == cast(char)c);
        seen++;
    }

    assert(seen == SomeText.length);

    String_ASCII another = str[3 .. 3 + 5];
    assert(another.length == 5);
    assert(another == "there");

    assert(str.startsWith("Hi"));
    assert(str.endsWith("there!"));

    assert(str.indexOf("there") == 3);
    assert(str.indexOf("be") == -1);
    assert(str.indexOf("e") == 5);
    assert(str.lastIndexOf("there") == 3);
    assert(str.lastIndexOf("be") == -1);
    assert(str.lastIndexOf("e") == 7);

    assert(str.count("e") == 2);
    assert(str.count("t") == 1);
}

unittest {
    string SomeText = "  Hi there!  ";
    String_ASCII str = SomeText;

    str.strip;
    assert(str == SomeText[2 .. $ - 2]);
}

// verify that iteration doesn't change state of another copy of a string
unittest {
    void aFunction(String_ASCII input) {
        foreach (c; input) {
            assert(c != '\0');
        }
    }

    String_ASCII aString = "hello world";
    aString = aString[1 .. $ - 1];
    assert(aString.length == 9);

    aFunction(aString);
    assert(aString.length == 9);
}
