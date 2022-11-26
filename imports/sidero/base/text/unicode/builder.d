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
        import sidero.base.internal.meta : OpApplyComboInterfaces;
    }

export:
    mixin OpApplyComboInterfaces!("Char", null, ["@safe", "nothrow", "@nogc"]);
    mixin OpApplyComboInterfaces!("Char", null, ["@safe", "nothrow", "@nogc"], "opApplyReverse");

nothrow @safe:

    void opAssign(ref StringBuilder_UTF other) @nogc;
    void opAssign(StringBuilder_UTF other) @nogc;
    @disable void opAssign(ref StringBuilder_UTF other) const;
    @disable void opAssign(StringBuilder_UTF other) const;

    @disable auto opCast(T)();

    this(ref return scope StringBuilder_UTF other) @trusted scope @nogc pure;
    @disable this(ref return scope StringBuilder_UTF other) @safe scope const;

    @disable this(ref const StringBuilder_UTF other) const;
    @disable this(this);

    this(RCAllocator allocator) scope @nogc;
    this(RCAllocator allocator, scope const(char)[] input...) scope @nogc;
    this(RCAllocator allocator, scope const(wchar)[] input...) scope @nogc;
    this(RCAllocator allocator, scope const(dchar)[] input...) scope @nogc;
    this(RCAllocator allocator, scope String_ASCII input) scope @nogc;
    this(RCAllocator allocator, scope String_UTF!char input = String_UTF!char.init) scope @nogc;
    this(RCAllocator allocator, scope String_UTF!wchar input = String_UTF!wchar.init) scope @nogc;
    this(RCAllocator allocator, scope String_UTF!dchar input = String_UTF!dchar.init) scope @nogc;
    this(scope const(char)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init);
    this(scope const(wchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init);
    this(scope const(dchar)[] input, RCAllocator allocator = RCAllocator.init, UnicodeLanguage language = UnicodeLanguage.init);
    this(scope String_ASCII input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted;
    this(scope String_UTF!char input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted;
    this(scope String_UTF!wchar input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted;
    this(scope String_UTF!dchar input, RCAllocator allocator = RCAllocator.init) scope @nogc @trusted;

    ~this() scope @nogc pure;
    bool isNull() scope @nogc pure;
    bool haveIterator() scope @nogc;
    StringBuilder_UTF withoutIterator() scope @trusted @nogc;
    bool isEncodingChanged() const scope;
    UnicodeLanguage unicodeLanguage() scope;
    StringBuilder_UTF opIndex(ptrdiff_t index) scope @nogc;
    StringBuilder_UTF opSlice() scope @trusted;
    StringBuilder_UTF opSlice(ptrdiff_t start, ptrdiff_t end) scope @nogc;
    alias opDollar = length;

    @nogc {
        size_t length() scope pure;
        StringBuilder_UTF dup(RCAllocator allocator = RCAllocator.init) scope;
        String_UTF!Char asReadOnly(RCAllocator allocator = RCAllocator.init) scope;
    }

    @nogc {
        StringBuilder_UTF normalize(bool compatibility, bool composition, UnicodeLanguage language) scope @trusted;
        StringBuilder_UTF toNFD(UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        StringBuilder_UTF toNFC(UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        StringBuilder_UTF toNFKD(UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        StringBuilder_UTF toNFKC(UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    bool opCast(T : bool)() scope const @nogc;
    @disable auto opCast(T)();
    alias equals = opEquals;

    @nogc {
        bool opEquals(scope const(char)[] input) scope;
        bool opEquals(scope const(wchar)[] input) scope;
        bool opEquals(scope const(dchar)[] input) scope;
        bool opEquals(scope String_ASCII input) scope;
        bool opEquals(scope String_UTF8 input) scope;
        bool opEquals(scope String_UTF16 input) scope;
        bool opEquals(scope String_UTF32 input) scope;
        bool opEquals(scope StringBuilder_ASCII input) scope;
        bool opEquals(scope StringBuilder_UTF8 input) scope;
        bool opEquals(scope StringBuilder_UTF16 input) scope;
        bool opEquals(scope StringBuilder_UTF32 input) scope;
    }

    @nogc {
        bool ignoreCaseEquals(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEquals(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    alias compare = opCmp;

    @nogc {
        int opCmp(scope const(char)[] input) scope;
        int opCmp(scope const(wchar)[] input) scope;
        int opCmp(scope const(dchar)[] input) scope;
        int opCmp(scope String_ASCII input) scope;
        int opCmp(scope String_UTF8 input) scope;
        int opCmp(scope String_UTF16 input) scope;
        int opCmp(scope String_UTF32 input) scope;
        int opCmp(scope StringBuilder_ASCII input) scope;
        int opCmp(scope StringBuilder_UTF8 input) scope;
        int opCmp(scope StringBuilder_UTF16 input) scope;
        int opCmp(scope StringBuilder_UTF32 input) scope;
    }

    @nogc {
        int ignoreCaseCompare(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        int ignoreCaseCompare(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    alias put = append;
    bool empty() scope @nogc pure;
    Char front() scope @nogc;
    Char back() scope @nogc;
    void popFront() scope @nogc;
    void popBack() scope @nogc;

    StringBuilder_UTF!char byUTF8() @trusted scope @nogc;
    StringBuilder_UTF!wchar byUTF16() @trusted scope @nogc;
    StringBuilder_UTF!dchar byUTF32() @trusted scope @nogc;

    @nogc {
        bool startsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool startsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    @nogc {
        bool ignoreCaseStartsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseStartsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    @nogc {
        bool endsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool endsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    @nogc {
        bool ignoreCaseEndsWith(scope const(char)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope const(wchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope const(dchar)[] input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope String_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope String_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope String_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope String_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope StringBuilder_ASCII input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope StringBuilder_UTF8 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope StringBuilder_UTF16 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        bool ignoreCaseEndsWith(scope StringBuilder_UTF32 input, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    void remove(ptrdiff_t index, size_t amount) scope @nogc;

    @nogc {
        StringBuilder_UTF insert(ptrdiff_t index, scope const(char)[] input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope const(wchar)[] input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope const(dchar)[] input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope String_ASCII input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope String_UTF8 input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope String_UTF16 input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope String_UTF32 input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_ASCII input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_UTF8 input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_UTF16 input) scope return;
        StringBuilder_UTF insert(ptrdiff_t index, scope StringBuilder_UTF32 input) scope return;
    }

    @nogc {
        StringBuilder_UTF prepend(scope const(char)[] input...) scope return;
        StringBuilder_UTF prepend(scope const(wchar)[] input...) scope return;
        StringBuilder_UTF prepend(scope const(dchar)[] input...) scope return;
        StringBuilder_UTF prepend(scope String_ASCII input) scope return;
        StringBuilder_UTF prepend(scope String_UTF8 input) scope return;
        StringBuilder_UTF prepend(scope String_UTF16 input) scope return;
        StringBuilder_UTF prepend(scope String_UTF32 input) scope return;
        StringBuilder_UTF prepend(scope StringBuilder_ASCII input) scope return;
        StringBuilder_UTF prepend(scope StringBuilder_UTF8 input) scope return;
        StringBuilder_UTF prepend(scope StringBuilder_UTF16 input) scope return;
        StringBuilder_UTF prepend(scope StringBuilder_UTF32 input) scope return;
    }

    @nogc {
        void opOpAssign(string op : "~")(scope const(char)[] input) scope return;
        void opOpAssign(string op : "~")(scope const(wchar)[] input) scope return;
        void opOpAssign(string op : "~")(scope const(dchar)[] input) scope return;
        void opOpAssign(string op : "~")(scope String_ASCII input) scope return;
        void opOpAssign(string op : "~")(scope String_UTF8 input) scope return;
        void opOpAssign(string op : "~")(scope String_UTF16 input) scope return;
        void opOpAssign(string op : "~")(scope String_UTF32 input) scope return;
        void opOpAssign(string op : "~")(scope StringBuilder_ASCII input) scope return;
        void opOpAssign(string op : "~")(scope StringBuilder_UTF8 input) scope return;
        void opOpAssign(string op : "~")(scope StringBuilder_UTF16 input) scope return;
        void opOpAssign(string op : "~")(scope StringBuilder_UTF32 input) scope return;
        StringBuilder_UTF opBinary(string op : "~")(scope const(char)[] input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope const(wchar)[] input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope const(dchar)[] input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope String_ASCII input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope String_UTF8 input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope String_UTF16 input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope String_UTF32 input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_ASCII input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_UTF8 input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_UTF16 input) scope;
        StringBuilder_UTF opBinary(string op : "~")(scope StringBuilder_UTF32 input) scope;
        StringBuilder_UTF append(scope const(char)[] input...) scope return;
        StringBuilder_UTF append(scope const(wchar)[] input...) scope return;
        StringBuilder_UTF append(scope const(dchar)[] input...) scope return;
        StringBuilder_UTF append(scope String_ASCII input) scope return;
        StringBuilder_UTF append(scope String_UTF8 input) scope return;
        StringBuilder_UTF append(scope String_UTF16 input) scope return;
        StringBuilder_UTF append(scope String_UTF32 input) scope return;
        StringBuilder_UTF append(scope StringBuilder_ASCII input) scope return;
        StringBuilder_UTF append(scope StringBuilder_UTF8 input) scope return;
        StringBuilder_UTF append(scope StringBuilder_UTF16 input) scope return;
        StringBuilder_UTF append(scope StringBuilder_UTF32 input) scope return;
    }

    @nogc {
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope const(char)[] input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope const(wchar)[] input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope const(dchar)[] input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_ASCII input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_UTF8 input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_UTF16 input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope String_UTF32 input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_ASCII input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_UTF8 input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_UTF16 input) scope return;
        StringBuilder_UTF clobberInsert(ptrdiff_t index, scope StringBuilder_UTF32 input) scope return;
    }

    @nogc {
        size_t replace(scope const(char)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(char)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(wchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope const(dchar)[] toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope String_UTF8 toReplace, bool caseSensitive = true, bool onlyOnce = false,
                UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF8 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF16 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope String_UTF32 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_ASCII toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF8 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF16 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(char)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(wchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope const(dchar)[] toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope String_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope String_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope String_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope String_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_ASCII toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF8 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF16 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
        size_t replace(scope StringBuilder_UTF32 toFind, scope StringBuilder_UTF32 toReplace, bool caseSensitive = true,
                bool onlyOnce = false, UnicodeLanguage language = UnicodeLanguage.Unknown) scope;
    }

    ///
    ulong toHash() scope @trusted @nogc;

package(sidero.base.text):
    int foreachContiguous(scope int delegate(ref scope Char[] data) @safe nothrow @nogc del,
            scope void delegate(size_t length) @safe nothrow @nogc lengthDel = null) scope @nogc;

private:
    StateIterator state;

    void setupState(RCAllocator allocator = RCAllocator.init) @nogc;

    @disable void setupState(RCAllocator allocator = RCAllocator.init) const @nogc;

    void debugPosition() @nogc;
}

private:

struct StateIterator {
    int encoding;

    void* state;
    void* iterator;
}
