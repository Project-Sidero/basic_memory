module sidero.base.text.internal.builder.blocklist;
import sidero.base.allocators;
import sidero.base.synchronization.mutualexclusion;
import sidero.base.attributes : hidden;

alias BLIb = BlockListImpl!ubyte;
alias BLIc = BlockListImpl!char;
alias BLIw = BlockListImpl!wchar;
alias BLId = BlockListImpl!dchar;

struct BlockListImpl(Char) {
    alias LiteralType = const(Char)[];
    //@disable this(this);

    RCAllocator allocator;
    TestTestSetLockInline mutex;
    Block head, tail;
    size_t numberOfItems, numberOfBlocks;
    int refCount = 1;

@safe nothrow @nogc @hidden:

    this(return scope RCAllocator allocator) scope @trusted {
        this.allocator = allocator;

        head.next = &tail;
        tail.previous = &head;
    }

    Block* insert(scope Block* previous) pure @trusted {
        assert(previous !is null, "Must provide previous block for insertion into a block list");
        assert(previous !is &tail, "Why is this the tail?");

        Block* ret = cast(Block*)(allocator.allocate(ByteLength + Block.sizeof).ptr);
        assert(ret !is null);
        ret.length = 0;

        ret.next = previous.next;
        previous.next.previous = ret;

        previous.next = ret;
        ret.previous = previous;

        this.numberOfBlocks++;
        return ret;
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);
        Block* b = bl.insert(a);
        assert(b !is null);

        bl.clear;
    }

    void remove(scope Block* block) pure @trusted {
        if(block is null || block is &head || block is &tail)
            return;

        block.next.previous = block.previous;
        block.previous.next = block.next;

        allocator.deallocate((cast(void*)block)[0 .. ByteLength + Block.sizeof]);
        this.numberOfBlocks--;
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);
        Block* b = bl.insert(a);
        assert(b !is null);

        assert(a.next.next !is null);
        bl.remove(b);
        assert(a.next.next is null);

        bl.clear;
    }

    void clear() pure {
        Block* block = head.next;

        while(block !is &tail) {
            assert(block !is null);
            numberOfItems -= block.length;

            Block* temp = block.next;
            remove(block);
            block = temp;
        }
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);

        bl.clear;
        assert(bl.head.next.next is null);
    }

    Block* blockForOffset(ref size_t offset, out size_t offsetIntoBlock) @trusted {
        size_t retActualOffsetFromHead;
        Block* ret = &head;
        size_t canDo = ret.length;

        // until currentBlock's next node is tailBlock
        do {
            if(canDo <= offset) {
                retActualOffsetFromHead += canDo;
                offset -= canDo;
                offsetIntoBlock = canDo;

                ret = ret.next;
                offsetIntoBlock = 0;
                canDo = ret.length;
            } else if(canDo > offset) {
                offsetIntoBlock = offset;
                break;
            } else
                assert(0);
        }
        while((ret.next !is null || canDo > 0) && offset > 0);

        if(ret.length == offsetIntoBlock && ret.next !is null) {
            offsetIntoBlock = 0;
            ret = ret.next;
        }

        offset = retActualOffsetFromHead + offsetIntoBlock;

        assert(ret !is null);
        assert(ret.length >= offsetIntoBlock);

        if(offset > 0)
            assert(ret !is &head);

        return ret;
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);
        Block* b = bl.insert(a);
        assert(b !is null);

        a.length = 10;
        b.length = 5;
        bl.numberOfItems = a.length + b.length;

        size_t adjustedOffset, offsetIntoBlock;
        Block* got;

        adjustedOffset = 5;
        got = bl.blockForOffset(adjustedOffset, offsetIntoBlock);
        assert(got is a);
        assert(adjustedOffset == 5);
        assert(offsetIntoBlock == 5);

        adjustedOffset = 9;
        got = bl.blockForOffset(adjustedOffset, offsetIntoBlock);
        assert(got is a);
        assert(adjustedOffset == 9);
        assert(offsetIntoBlock == 9);

        adjustedOffset = 10;
        got = bl.blockForOffset(adjustedOffset, offsetIntoBlock);
        assert(got is b);
        assert(adjustedOffset == 10);
        assert(offsetIntoBlock == 0);

        adjustedOffset = 11;
        got = bl.blockForOffset(adjustedOffset, offsetIntoBlock);
        assert(got is b);
        assert(adjustedOffset == 11);
        assert(offsetIntoBlock == 1);

        adjustedOffset = 16;
        got = bl.blockForOffset(adjustedOffset, offsetIntoBlock);
        assert(got is &bl.tail);
        assert(adjustedOffset == 15);
        assert(offsetIntoBlock == 0);

        adjustedOffset = 18;
        got = bl.blockForOffset(adjustedOffset, offsetIntoBlock);
        assert(got is &bl.tail);
        assert(adjustedOffset == 15);
        assert(offsetIntoBlock == 0);

        bl.clear;
    }

    bool canFindEverything() @safe nothrow @nogc {
        size_t found;

        foreach(Block* block; this) {
            found += block.length;
        }

        return found == this.numberOfItems;
    }

    int opApply(scope int delegate(Block* block) @safe nothrow @nogc del) @safe nothrow @nogc {
        Block* current = head.next;
        int result;

        while(current.next !is null) {
            Block* next = current.next;
            result = del(current);

            if(result)
                return result;

            current = next;
        }

        return result;
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);
        Block* b = bl.insert(a);
        assert(b !is null);

        a.length = 10;
        b.length = 5;

        int seenA, seenB;

        foreach(Block* block; bl) {
            if(block is a)
                seenA++;
            else if(block is b)
                seenB++;
            else
                assert(0);
        }

        assert(seenA == 1);
        assert(seenB == 1);
        bl.clear;
    }

    int opApply(scope int delegate(Char[] data) @safe nothrow @nogc del) {
        return this.opApply((blockOffset, data) { return del(data); });
    }

    int opApply(scope int delegate(size_t blockOffset, Char[] data) @safe nothrow @nogc del) {
        assert(head.length == 0);
        assert(tail.length == 0);

        Block* current = head.next;
        size_t id;
        int result;

        while(current.next !is null) {
            result = del(id, current.get()[0 .. current.length]);

            if(result)
                return result;

            current = current.next;
            id++;
        }

        return result;
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);
        Block* b = bl.insert(a);
        assert(b !is null);

        a.length = 10;
        b.length = 5;

        int seenA, seenB;

        ptrdiff_t lastOffset = -1;
        foreach(offset, data; bl) {
            assert(offset == lastOffset + 1);

            if(data is a.get())
                seenA++;
            else if(data is b.get())
                seenB++;
            else
                assert(0);

            lastOffset++;
        }

        assert(seenA == 1);
        assert(seenB == 1);
        bl.clear;
    }

    int opApplyReverse(scope int delegate(size_t blockOffset, Char[] data) @safe nothrow @nogc del) {
        assert(head.length == 0);
        assert(tail.length == 0);

        Block* current = tail.previous;
        ptrdiff_t id = this.numberOfBlocks - 1;
        int result;

        while(current.previous !is null) {
            assert(id >= 0);
            result = del(id, current.get()[0 .. current.length]);

            if(result)
                return result;

            current = current.previous;
            id--;
        }

        return result;
    }

    unittest {
        BlockListImpl bl = BlockListImpl(globalAllocator());

        Block* a = bl.insert(&bl.head);
        assert(a !is null);
        Block* b = bl.insert(a);
        assert(b !is null);

        a.length = 10;
        b.length = 5;

        int seenA, seenB;

        ptrdiff_t lastOffset = 2;
        foreach_reverse(offset, data; bl) {
            assert(offset == lastOffset - 1);

            if(data is a.get())
                seenA++;
            else if(data is b.get())
                seenB++;
            else
                assert(0);

            lastOffset--;
        }

        assert(seenA == 1);
        assert(seenB == 1);
        bl.clear;
    }

    void debugMe() @trusted {
        version(none) {
            version(D_BetterC) {
            } else {
                debug {
                    try {
                        import std.stdio;

                        Block* current = &head;

                        while(current !is null) {
                            writefln!"Block(0x%X) length=%s"(current, current.length);

                            current = current.next;
                        }

                    } catch(Exception) {
                    }
                }
            }
        }
    }

    static struct Block {
        Block* previous, next;
        size_t length;

    @trusted nothrow @nogc @hidden:

        Char* dataPtr() pure {
            return cast(Char*)((cast(void*)&this) + Block.sizeof);
        }

        Char[] get() pure {
            return dataPtr()[0 .. length];
        }

        Char[] getFull() pure {
            return dataPtr()[0 .. Count];
        }

    @safe:

        void padStart(size_t amount) pure {
            moveRight(0, amount);
        }

        unittest {
            BlockListImpl bl = BlockListImpl(globalAllocator());

            Block* block = bl.insert(&bl.head);
            assert(block !is null);
            block.length = 1;

            block.get()[0] = 'a';
            block.padStart(1);

            assert(block.length == 2);
            assert(block.get()[1] == 'a');

            bl.clear;
        }

        void unpadStart(size_t amount) pure {
            moveLeft(amount, 0);
        }

        unittest {
            BlockListImpl bl = BlockListImpl(globalAllocator());

            Block* block = bl.insert(&bl.head);
            assert(block !is null);
            block.length = 2;

            block.get()[1] = 'a';
            block.unpadStart(1);

            assert(block.length == 1);
            assert(block.get()[0] == 'a');

            bl.clear;
        }

        void moveFromInto(size_t oldOffset, size_t amount, scope Block* into, size_t newOffset) pure {
            assert(into !is null);
            assert(into !is &this);
            assert(this.length >= oldOffset + amount);
            assert(Count >= newOffset + amount);

            Char[] ourData = this.getFull();
            Char[] intoData = into.getFull();

            if(newOffset < into.length)
                into.moveRight(newOffset, newOffset + amount);

            foreach(i; 0 .. amount) {
                intoData[newOffset + i] = ourData[oldOffset + i];
            }

            if(into.length < newOffset + amount)
                into.length = newOffset + amount;

            size_t amountRightOfMoved = (this.length - oldOffset) - amount;
            if(amountRightOfMoved > 0)
                moveLeft(oldOffset + amount, oldOffset);
            else
                this.length -= amount;
        }

        unittest {
            BlockListImpl bl = BlockListImpl(globalAllocator());

            Block* a = bl.insert(&bl.head);
            assert(a !is null);
            Block* b = bl.insert(&bl.head);
            assert(b !is null);

            a.length = 2;
            a.get()[0] = 'a';
            a.get()[1] = 'z';

            b.length = 2;
            b.get()[0] = 'b';
            b.get()[1] = 'c';

            a.moveFromInto(0, 1, b, 0);
            assert(b.length == 3);
            assert(b.get()[0] == 'a');
            assert(b.get()[1] == 'b');
            assert(b.get()[2] == 'c');

            assert(a.length == 1);
            assert(a.get()[0] == 'z');

            bl.clear;
        }

        void moveLeft(size_t oldOffset, size_t newOffset) pure {
            if(oldOffset == this.length) {
                this.length = newOffset;
                return;
            }

            assert(newOffset < oldOffset);
            assert(oldOffset < this.length);

            size_t diff = oldOffset - newOffset;
            size_t amountOnTheRight = this.length - oldOffset;
            Char[] data = this.getFull();

            foreach(index; 0 .. amountOnTheRight)
                data[newOffset + index] = data[oldOffset + index];

            this.length -= diff;
        }

        unittest {
            BlockListImpl bl = BlockListImpl(globalAllocator());

            Block* block = bl.insert(&bl.head);
            assert(block !is null);
            block.length = 3;

            block.get()[2] = 'a';
            block.moveLeft(2, 1);

            assert(block.length == 2);
            assert(block.get()[1] == 'a');

            bl.clear;
        }

        void moveRight(size_t oldOffset, size_t newOffset) pure {
            assert(oldOffset < newOffset);

            size_t diff = newOffset - oldOffset;
            size_t newEndOffset = this.length + diff;
            assert(newEndOffset <= Count);

            Char[] data = this.getFull();

            foreach_reverse(offset; oldOffset .. this.length) {
                data[offset + diff] = data[offset];
            }

            this.length += diff;
        }

        unittest {
            BlockListImpl bl = BlockListImpl(globalAllocator());

            Block* block = bl.insert(&bl.head);
            assert(block !is null);
            block.length = 2;

            block.get()[1] = 'a';
            block.moveRight(1, 2);

            assert(block.length == 3);
            assert(block.get()[2] == 'a');

            bl.clear;
        }
    }

    enum CacheSize = 64;
    enum Count = () {
        enum Minimum = 16;

        size_t accumulator;

        accumulator = CacheSize - (Block.sizeof % CacheSize);

        while(accumulator < Char.sizeof * Minimum) {
            accumulator += CacheSize;
        }

        return accumulator / Char.sizeof;
    }();

    enum ByteLength = Count * Char.sizeof;

    static assert((ByteLength + Block.sizeof) % CacheSize == 0, "Block + string data must be a multiply of cache size");
}
