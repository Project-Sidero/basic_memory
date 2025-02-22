module sidero.base.containers.appender;
import sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.encoding.utf;

private alias A8 = Appender!ubyte;

///
alias Appender_UTF8 = Appender!char;
///
alias Appender_UTF16 = Appender!wchar;
///
alias Appender_UTF32 = Appender!dchar;

///
struct Appender(Type) {
    private @PrettyPrintIgnore {
        import sidero.base.internal.meta : OpApplyCombos;

        static struct Block {
            Block* previous, next;
            size_t used;
            Type[0] data;
        }

        Block* head, tail;
        RCAllocator allocator;
        size_t count;

        int opApplyImpl(Del)(scope Del del) scope @trusted {
            Block* current = head;
            size_t offset;
            int result;

            while(current !is null) {
                foreach(i; 0 .. current.used) {
                    Type got = current.data[i];

                    static if(__traits(compiles, del(offset, got)))
                        result = del(offset, got);
                    else static if(__traits(compiles, del(got)))
                        result = del(got);
                    else
                        static assert(0);

                    if(result)
                        return result;
                    offset++;
                }

                current = current.next;
            }

            return result;
        }

        int opApplyReverseImpl(Del)(scope Del del) scope @trusted {
            Block* current = tail;
            size_t offset = count - 1;
            int result;

            while(current !is null) {
                foreach_reverse(i; 0 .. current.used) {
                    Type got = current.data[i];

                    static if(__traits(compiles, del(offset, got)))
                        result = del(offset, got);
                    else static if(__traits(compiles, del(got)))
                        result = del(got);
                    else
                        static assert(0);

                    if(result)
                        return result;
                    offset--;
                }

                current = current.previous;
            }

            return result;
        }
    }

export:

    ///
    mixin OpApplyCombos!(ElementType, size_t, "opApply", true, true, true, true, false);
    ///
    mixin OpApplyCombos!(ElementType, size_t, "opApplyReverse", true, true, true, true, false);

@safe nothrow @nogc:

    ///
    alias ElementType = Type;
    ///
    alias LiteralType = const(Type)[];

    static if(is(Type == char)) {
        ///
        alias ReadOnlyType = String_UTF8;
        ///
        alias MutableType = StringBuilder_UTF8;
    } else static if(is(Type == wchar)) {
        ///
        alias ReadOnlyType = String_UTF16;
        ///
        alias MutableType = StringBuilder_UTF16;
    } else static if(is(Type == dchar)) {
        ///
        alias ReadOnlyType = String_UTF32;
        ///
        alias MutableType = StringBuilder_UTF32;
    } else {
        ///
        alias ReadOnlyType = Slice!Type;
        ///
        alias MutableType = DynamicArray!Type;
    }

    ///
    this(RCAllocator allocator) {
        this.allocator = allocator;
    }

    //@disable this(this);

    ~this() @trusted {
        Block* current = head;

        while(current !is null) {
            Block* next = current.next;
            allocator.dispose(current);
            current = next;
        }

        head = null;
    }

    ///
    bool isNull() scope const {
        return allocator.isNull;
    }

    ///
    ptrdiff_t length() scope const {
        return count;
    }

    ///
    ptrdiff_t opDollar() scope const {
        return count;
    }

    /// Traversal (consuming) of the underlying storage, returning of data
    const(Type)[] peekFirstBlock() scope return @system {
        if(head is null)
            return null;
        return head.data.ptr[0 .. head.used];
    }

    /// Traversal (consuming) of the underlying storage, consumption
    void consumeFirstBlock() scope @system {
        Block* block = this.head;

        if(block !is null) {
            this.head = block.next;
            allocator.dispose(block);

            if (this.head is null)
                this.tail = null;
        }
    }

    ///
    @system unittest {
        Appender appender;
        appender ~= Type.init;

        assert(appender.peekFirstBlock.length == 1);
        appender.consumeFirstBlock;
        assert(appender.peekFirstBlock.length == 0);
    }

    ///
    Result!Type opIndex(ptrdiff_t index) scope @trusted const {
        auto error = changeIndexToOffset(index);
        if(error.isSet)
            return typeof(return)(error);

        Block* current = cast(Block*)head;
        while(current !is null && index >= current.used) {
            index -= current.used;
            current = current.next;
        }

        assert(current.used > index);
        return typeof(return)(current.data.ptr[index]);
    }

    ///
    alias put = append;

    ///
    void opOpAssign(string op : "~")(scope ref Appender other) scope {
        this.append(other);
    }

    ///
    void append(scope ref Appender other, size_t offset = 0, size_t length = size_t.max) @trusted {
        const canDoLength = length > other.count ? other.count : length;
        if(canDoLength <= offset)
            return;
        length = canDoLength;

        Block* current = cast(Block*)other.head;
        size_t soFar;

        while(current !is null && current.used <= offset) {
            offset -= current.used;
            soFar += current.used;
            current = current.next;
        }

        while(current !is null && length > 0) {
            const canDo = length < current.used ? length : current.used;
            this.append(current.data.ptr[offset .. canDo]);

            if(offset > current.used)
                offset -= current.used;
            else
                offset = 0;

            if(length > 0)
                length -= canDo;
            current = current.next;
        }
    }

    ///
    void opOpAssign(string op : "~")(scope const(Type)[] input...) scope {
        this.append(input);
    }

    ///
    void append(scope const(Type)[] input...) scope @trusted {
        while(input.length > 0) {
            Block* into = tail;

            if(into is null || into.used == Count)
                into = newNode();

            size_t canDo = Count - into.used;
            assert(canDo > 0);

            if(input.length < canDo)
                canDo = input.length;

            foreach(offset; 0 .. canDo) {
                into.data.ptr[into.used + offset] = cast(Type)input[offset];
            }

            into.used += canDo;
            count += canDo;
            input = input[canDo .. $];
        }
    }

    ///
    void opOpAssign(string op : "~")(scope ReadOnlyType input) scope {
        this.append(input);
    }

    ///
    void append(scope ReadOnlyType input) scope @trusted {
        static if(is(Type == char) || is(Type == wchar) || is(Type == dchar)) {
            if(!input.isEncodingChanged())
                append(input.unsafeGetLiteral());
            else {
                foreach(c; input) {
                    append(c);
                }
            }
        } else {
            append(input.unsafeGetLiteral());
        }
    }

    ///
    void opOpAssign(string op : "~")(scope MutableType input) scope {
        this.append(input);
    }

    ///
    void append(scope MutableType input) scope {
        foreach(v; input) {
            append(v);
        }
    }

    static if(is(Type == char)) {
        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF16 input) scope {
            this.append(input.byUTF8);
        }

        ///
        void append(scope StringBuilder_UTF16 input) scope {
            this.append(input.byUTF8);
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF32 input) scope {
            this.append(input.byUTF8);
        }

        ///
        void append(scope StringBuilder_UTF32 input) scope {
            this.append(input.byUTF8);
        }

        ///
        void opOpAssign(string op : "~")(scope string input) scope {
            this.append(input);
        }

        ///
        void append(scope string input) scope @trusted {
            append(cast(LiteralType)input);
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF16 input) scope @trusted {
            this.append(input.byUTF8);
        }

        ///
        void append(scope String_UTF16 input) scope @trusted {
            append(input.byUTF8);
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF32 input) scope @trusted {
            this.append(input.byUTF8);
        }

        ///
        void append(scope String_UTF32 input) scope @trusted {
            append(input.byUTF8);
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!char input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!char input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!wchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!wchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!dchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!dchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!char input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!char input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!wchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!wchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!dchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!dchar input) scope @trusted {
            this.append(String_UTF8(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(dchar input) scope @trusted {
            char[4] buffer = void;
            const count = encodeUTF8(input, buffer[]);

            this.append(String_UTF8(buffer[0 .. count]));
        }

        ///
        void append(dchar input) scope @trusted {
            char[4] buffer = void;
            const count = encodeUTF8(input, buffer[]);

            this.append(String_UTF8(buffer[0 .. count]));
        }
    } else static if(is(Type == wchar)) {
        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF8 input) scope {
            this.append(input.byUTF16);
        }

        ///
        void append(scope StringBuilder_UTF8 input) scope {
            this.append(input.byUTF16);
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF32 input) scope {
            this.append(input.byUTF16);
        }

        ///
        void append(scope StringBuilder_UTF32 input) scope {
            this.append(input.byUTF16);
        }

        ///
        void opOpAssign(string op : "~")(scope wstring input) scope {
            this.append(input);
        }

        ///
        void append(scope wstring input) scope @trusted {
            append(cast(LiteralType)input);
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF8 input) scope @trusted {
            this.append(input.byUTF16);
        }

        ///
        void append(scope String_UTF8 input) scope @trusted {
            append(input.byUTF16);
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF32 input) scope @trusted {
            this.append(input.byUTF16);
        }

        ///
        void append(scope String_UTF32 input) scope @trusted {
            append(input.byUTF16);
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!char input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!char input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!wchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!wchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!dchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!dchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!char input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!char input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!wchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!wchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!dchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!dchar input) scope @trusted {
            this.append(String_UTF16(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(dchar input) scope @trusted {
            char[2] buffer = void;
            const count = encodeUTF16(input, buffer[]);

            this.append(String_UTF16(buffer[0 .. count]));
        }

        ///
        void append(dchar input) scope @trusted {
            wchar[2] buffer = void;
            const count = encodeUTF16(input, buffer[]);

            this.append(String_UTF16(buffer[0 .. count]));
        }
    } else static if(is(Type == dchar)) {
        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF8 input) scope {
            this.append(input.byUTF32);
        }

        ///
        void append(scope StringBuilder_UTF8 input) scope {
            this.append(input.byUTF32);
        }

        ///
        void opOpAssign(string op : "~")(scope StringBuilder_UTF16 input) scope {
            this.append(input.byUTF32);
        }

        ///
        void append(scope StringBuilder_UTF16 input) scope {
            this.append(input.byUTF32);
        }

        ///
        void opOpAssign(string op : "~")(scope dstring input) scope {
            this.append(input);
        }

        ///
        void append(scope dstring input) scope @trusted {
            append(cast(LiteralType)input);
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF8 input) scope @trusted {
            this.append(input.byUTF32);
        }

        ///
        void append(scope String_UTF8 input) scope @trusted {
            append(input.byUTF32);
        }

        ///
        void opOpAssign(string op : "~")(scope String_UTF16 input) scope @trusted {
            this.append(input.byUTF32);
        }

        ///
        void append(scope String_UTF16 input) scope @trusted {
            append(input.byUTF32);
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!char input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!char input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!wchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!wchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope Slice!dchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void append(scope Slice!dchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!char input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!char input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!wchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!wchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void opOpAssign(string op : "~")(scope DynamicArray!dchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }

        ///
        void append(scope DynamicArray!dchar input) scope @trusted {
            this.append(String_UTF32(input.unsafeGetLiteral()));
        }
    }

    ///
    ReadOnlyType asReadOnly(RCAllocator allocator = RCAllocator.init) scope @trusted const {
        return this.asReadOnly(0, size_t.max, allocator);
    }

    ///
    ReadOnlyType asReadOnly(size_t offset, size_t length, RCAllocator allocator = RCAllocator.init) scope @trusted const {
        if(allocator.isNull)
            allocator = globalAllocator();

        const canDoLength = length > this.count ? this.count : length;
        if(canDoLength <= offset)
            return typeof(return).init;

        Type[] ret = allocator.makeArray!Type(canDoLength - offset);
        Block* current = cast(Block*)head;
        size_t soFar;

        while(current !is null && current.used <= offset) {
            offset -= current.used;
            soFar += current.used;
            current = current.next;
        }

        while(current !is null && length > 0) {
            const canDo = (length > 0 && length < current.used) ? length : current.used;

            foreach(i; offset .. canDo)
                ret[soFar++] = current.data.ptr[i];

            if(offset > current.used)
                offset -= current.used;
            else
                offset = 0;

            if(length > 0)
                length -= canDo;
            current = current.next;
        }

        return ReadOnlyType(ret, allocator);
    }

    ///
    MutableType asMutable(RCAllocator allocator = RCAllocator.init) scope @trusted const {
        MutableType ret = MutableType(allocator);
        assert(!ret.isNull);

        static if(__traits(hasMember, MutableType, "reserve"))
            ret.reserve(count);

        Block* current = cast(Block*)head;

        while(current !is null) {
            ret ~= current.data.ptr[0 .. current.used];
            current = current.next;
        }

        return ret;
    }

    @disable int opCmp(scope const ref Appender) scope const;
    @disable bool opEquals(scope const ref Appender) scope const;

private:
    Block* newNode() @trusted {
        if(allocator.isNull)
            allocator = globalAllocator();

        Block* block = cast(Block*)allocator.allocate(Block.sizeof + ByteLength).ptr;
        (*block).tupleof = Block.init.tupleof;

        block.previous = tail;

        if(tail !is null)
            tail.next = block;
        if(head is null)
            head = block;

        tail = block;
        return block;
    }

    ErrorInfo changeIndexToOffset(scope ref ptrdiff_t a) scope const {
        import sidero.base.errors.stock;

        const actualLength = count;

        if(a < 0) {
            if(actualLength < -a) {
                a = actualLength;
                return ErrorInfo(RangeException("Offset must be smaller than length"));
            }

            a = actualLength + a;
        }

        return ErrorInfo.init;
    }

    enum CacheSize = 64;
    enum Count = () {
        enum Minimum = 128;

        size_t accumulator;

        accumulator = CacheSize - (Block.sizeof % CacheSize);

        while(accumulator < Type.sizeof * Minimum) {
            accumulator += CacheSize;
        }

        return accumulator / Type.sizeof;
    }();

    enum ByteLength = Count * Type.sizeof;
}

///
unittest {
    Appender_UTF8 appender;
    assert(appender.isNull);
    assert(appender.length == 0);

    appender ~= "Hello";
    assert(appender.length == 5);

    auto c = appender[$ - 4];
    assert(c);
    assert(c == 'e');

    c = appender[-1];
    assert(c);
    assert(c == 'o');

    appender.put(" World!");
    assert(appender.length == "Hello World!".length);

    auto readOnly = appender.asReadOnly;
    assert(readOnly == "Hello World!");

    auto mutable = appender.asMutable;
    assert(mutable == "Hello World!");
}
