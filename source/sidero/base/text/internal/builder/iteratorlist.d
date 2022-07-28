module sidero.base.text.internal.builder.iteratorlist;
import sidero.base.text.internal.builder.blocklist;
import sidero.base.allocators;

struct IteratorListImpl(Char) {
    Iterator* head;

@safe nothrow @nogc:

    Iterator* newIterator(scope return BlockListImpl!Char* blockList, size_t minimumOffsetFromHead = 0,
            size_t maximumOffsetFromHead = size_t.max) @trusted {
        assert(blockList !is null);

        Iterator* ret = blockList.allocator.make!Iterator;
        ret.blockList = blockList;
        ret.next = head;

        ret.refCount = 1;
        blockList.refCount++;

        if (minimumOffsetFromHead > blockList.numberOfItems)
            minimumOffsetFromHead = blockList.numberOfItems;
        if (maximumOffsetFromHead > blockList.numberOfItems)
            maximumOffsetFromHead = blockList.numberOfItems;
        assert(minimumOffsetFromHead <= maximumOffsetFromHead);

        ret.minimumOffsetFromHead = minimumOffsetFromHead;
        ret.maximumOffsetFromHead = maximumOffsetFromHead;

        if (head !is null)
            head.previous = ret;
        head = ret;

        ret.forwards.setup(blockList, minimumOffsetFromHead);
        ret.backwards.setup(blockList, maximumOffsetFromHead);
        return ret;
    }

    unittest {
        IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());
        Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
        Cursor.Block* b = ilt.blockList.insert(a);

        a.length = 6;
        b.length = 6;

        foreach (i, c; "hello ")
            a.get()[i] = c;
        foreach (i, c; "world!")
            b.get()[i] = c;

        Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);
        ilt.iteratorList.rcIteratorInternal(false, iterator);
    }

    void rcIteratorInternal(bool addRef, scope Iterator* iterator) @trusted {
        if (addRef)
            iterator.refCount++;
        else if (iterator.refCount == 1) {
            if (iterator.previous is null)
                head = iterator.next;
            else
                iterator.previous.next = iterator.next;

            if (iterator.next !is null)
                iterator.next.previous = iterator.previous;

            RCAllocator allocator = iterator.blockList.allocator;
            allocator.dispose(iterator);
        } else
            iterator.refCount--;
    }

    unittest {
        IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

        Iterator* a = ilt.iteratorList.newIterator(&ilt.blockList);
        Iterator* b = ilt.iteratorList.newIterator(&ilt.blockList);
        ilt.iteratorList.rcIteratorInternal(false, a);
        ilt.iteratorList.rcIteratorInternal(false, b);
    }

    struct Iterator {
        Iterator* previous, next;
        Cursor forwards, backwards;
        size_t minimumOffsetFromHead, maximumOffsetFromHead;

        BlockListImpl!Char* blockList;
        int refCount;

    @safe nothrow @nogc:

        invariant () {
            assert(minimumOffsetFromHead <= forwards.offsetFromHead);
            assert(forwards.offsetFromHead <= backwards.offsetFromHead);
            assert(backwards.offsetFromHead <= maximumOffsetFromHead);

            assert(forwards.block !is null);
            assert(backwards.block.previous !is null);
        }

        int opApply(Del)(scope Del del) @trusted {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            int result;

            while (!emptyInternal()) {
                // front_ does extra house keeping working, so order to calculate offset is important!
                Char value = frontInternal();
                size_t offset = this.forwards.offsetFromHead - this.minimumOffsetFromHead;

                blockList.mutex.unlock;
                result = del(offset, value);
                blockList.mutex.lock;

                if (result)
                    break;
                popFrontInternal();
            }

            return result;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());
            Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "Keep Yer Hands";
            enum Text2 = "Off My PBR";

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
            Cursor.Block* b = ilt.blockList.insert(a);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            b.length = Text2.length;
            foreach (i, v; Text2)
                b.get()[i] = v;

            size_t lastOffset;

            foreach (i, v; &iterator.opApply!FET) {
                if (i >= Text1.length)
                    assert(Text2[i - Text1.length] == v);
                else
                    assert(Text1[i] == v);

                assert(lastOffset + 1 == i);
                lastOffset++;
            }

            ilt.iteratorList.rcIteratorInternal(false, iterator);
        }

        int opApplyReverse(Del)(scope Del del) @trusted {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            int result;

            while (!emptyInternal()) {
                Char value = backInternal();
                size_t offset = this.backwards.offsetFromHead - this.minimumOffsetFromHead;

                blockList.mutex.unlock;
                result = del(offset, value);
                blockList.mutex.lock;

                if (result)
                    break;
                popBackInternal();
            }

            return result;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());
            Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "Keep Yer Hands";
            enum Text2 = "Off My PBR";

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
            Cursor.Block* b = ilt.blockList.insert(a);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            b.length = Text2.length;
            foreach (i, v; Text2)
                b.get()[i] = v;

            size_t lastOffset = Text1.length + Text2.length - 1, numberOfZero;

            foreach (i, v; &iterator.opApplyReverse!FET) {
                if (i >= Text1.length)
                    assert(Text2[i - Text1.length] == v);
                else
                    assert(Text1[i] == v);

                if (lastOffset == 0) {
                    numberOfZero++;
                    assert(numberOfZero == 1);
                } else {
                    assert(lastOffset - 1 == i);
                    lastOffset--;
                }
            }

            ilt.iteratorList.rcIteratorInternal(false, iterator);
        }

        bool empty() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;
            return emptyInternal();
        }

        Char front() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            return frontInternal();
        }

        Char back() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            return backInternal();
        }

        void popFront() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            popFrontInternal();
        }

        void popBack() {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            popBackInternal();
        }

    private:
        bool emptyInternal() {
            return forwards.offsetFromHead >= backwards.offsetFromHead;
        }

        Char frontInternal() {
            forwards.advanceForward(0, maximumOffsetFromHead, true);
            return forwards.get();
        }

        Char backInternal() {
            backwards.advanceBackwards(0, minimumOffsetFromHead, maximumOffsetFromHead, true);
            return backwards.get();
        }

        void popFrontInternal() {
            forwards.advanceForward(1, maximumOffsetFromHead, true);
        }

        void popBackInternal() {
            backwards.advanceBackwards(1, minimumOffsetFromHead, maximumOffsetFromHead, true);
        }
    }

    unittest {
        IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());
        alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

        enum Text1 = "Party like";
        enum Text2 = "I ain't joking";

        Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
        Cursor.Block* b = ilt.blockList.insert(a);

        a.length = Text1.length;
        foreach (i, v; Text1)
            a.get()[i] = v;

        b.length = Text2.length;
        foreach (i, v; Text2)
            b.get()[i] = v;

        ilt.blockList.numberOfItems = Text1.length + Text2.length;
        Iterator* iterator1 = ilt.iteratorList.newIterator(&ilt.blockList), iterator2 = ilt.iteratorList.newIterator(&ilt.blockList);

        {
            size_t seen;
            bool seenZero;

            iterator1.popBack;

            foreach (i, v; &iterator1.opApply!FET) {
                if (i == 0)
                    seenZero = true;
                seen++;
            }

            assert(seenZero);
            assert(seen == Text1.length + Text2.length - 1);
        }

        {
            size_t seen;

            iterator2.popFront;
            iterator2.popBack;

            foreach (i, v; &iterator2.opApplyReverse!FET) {
                seen++;
            }

            assert(seen == Text1.length + Text2.length - 2);
        }

        ilt.iteratorList.rcIteratorInternal(false, iterator1);
        ilt.iteratorList.rcIteratorInternal(false, iterator2);
    }

    struct Cursor {
        alias Block = BlockListImpl!Char.Block;
        Block* block;
        size_t offsetIntoBlock, offsetFromHead;

        Char get() {
            assert(block !is null);
            assert(block.length > offsetIntoBlock);
            return block.get()[offsetIntoBlock];
        }

        void setup(scope BlockListImpl!Char* blockList, size_t offsetFromHead) {
            this.offsetFromHead = offsetFromHead;
            block = blockList.blockForOffset(this.offsetFromHead, this.offsetIntoBlock);
        }

        void advanceToNextBlock() {
            if (block is null)
                return;

            offsetFromHead -= offsetIntoBlock;
            offsetIntoBlock = 0;

            if (this.block.next !is null)
                this.block = this.block.next;
        }

        void advanceForward(size_t amount, size_t maximumOffsetFromHead, bool limitToData) {
            assert(block !is null);

            // if we are at the end of our current block, skip to the start of next
            if (offsetIntoBlock == block.length && offsetFromHead < maximumOffsetFromHead && block.next !is null && block.next.next !is null) {
                block = block.next;
                offsetIntoBlock = 0;
            }

            // until currentBlock's next node is tailBlock
            while (block.next !is null && amount > 0 && offsetFromHead + 1 <= maximumOffsetFromHead) {
                size_t canDo = block.length - offsetIntoBlock;

                if (canDo > amount)
                    canDo = amount;
                else if (canDo == 0) {
                    // don't go forward beyond the tail node
                    if (block.next.next is null && limitToData)
                        return;

                    block = block.next;
                    offsetIntoBlock = 0;
                    continue;
                }

                if (offsetFromHead + canDo > maximumOffsetFromHead + 1)
                    canDo = maximumOffsetFromHead - (offsetFromHead + 1);

                if (canDo == 0)
                    break;

                offsetIntoBlock += canDo;
                offsetFromHead += canDo;
                amount -= canDo;
            }

            if (offsetIntoBlock == block.length && block.next !is null && block.next.next !is null && limitToData) {
                block = block.next;
                offsetIntoBlock = 0;
            }
        }

        void advanceBackwards(size_t amount, size_t minimumOffsetFromHead, size_t maximumOffsetFromHead, bool limitToData) {
            assert(block !is null);

            if (amount == 0 && limitToData && (offsetFromHead == maximumOffsetFromHead || offsetIntoBlock == block.length))
                amount = 1;

            // until currentBlock's previous node is headBlock
            while (block.previous !is null && amount > 0 && offsetFromHead > minimumOffsetFromHead) {
                size_t canDo = offsetIntoBlock;

                if (canDo > amount) {
                    canDo = amount;
                } else if (canDo == 0) {
                    block = block.previous;
                    assert(block !is null);

                    if (limitToData) {
                        amount--;

                        if (block.length > 0) {
                            assert(offsetFromHead > 0);

                            offsetIntoBlock = block.length - 1;
                            assert(offsetFromHead > 0);
                            offsetFromHead--;
                        } else {
                            offsetIntoBlock = 0;
                            if (offsetFromHead > 0)
                                offsetFromHead--;
                        }
                    } else {
                        amount--;
                        offsetIntoBlock = block.length;
                    }

                    continue;
                }

                if (canDo > offsetFromHead - minimumOffsetFromHead)
                    canDo = offsetFromHead - minimumOffsetFromHead;

                if (canDo == 0)
                    break;

                assert(offsetFromHead >= canDo);
                assert(offsetIntoBlock >= canDo);
                offsetIntoBlock -= canDo;
                assert(offsetFromHead > 0);
                offsetFromHead -= canDo;
                amount -= canDo;
            }
        }
    }
}

private:

alias ILTb = IteratorListTest!ubyte;
alias ILTc = IteratorListTest!char;
alias ILTw = IteratorListTest!wchar;
alias ILTd = IteratorListTest!dchar;

struct IteratorListTest(Char) {
    alias BlockList = BlockListImpl!Char;

    BlockList blockList;

    IteratorListImpl!Char iteratorList;
    alias Iterator = iteratorList.Iterator;

@safe nothrow @nogc:

    this(scope return RCAllocator allocator) scope @trusted {
        this.blockList = BlockList(allocator);
    }

    @disable this(this);

@safe nothrow @nogc:

     ~this() {
        blockList.clear;
        assert(iteratorList.head is null);
    }
}
