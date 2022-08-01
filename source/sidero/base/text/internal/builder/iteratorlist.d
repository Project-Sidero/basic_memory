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
        ret.empty;
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

        //

        int foreachBlocks(scope int delegate(scope Char[] data) @safe nothrow @nogc del) {
            Cursor.Block* current = forwards.block;
            size_t offsetIntoB = forwards.offsetIntoBlock, canDo = size_t.max;

            if (this.maximumOffsetFromHead != size_t.max)
                canDo = backwards.offsetFromHead - forwards.offsetFromHead;

            int result;

            while (current.next !is null && canDo > 0) {
                size_t willDo = canDo;
                auto slice = current.get()[offsetIntoB .. current.length];

                if (willDo > slice.length)
                    willDo = slice.length;
                if (slice.length > willDo)
                    slice = slice[0 .. willDo];

                result = del(slice);
                if (slice.length > 0 && result)
                    break;

                offsetIntoB = 0;
                canDo -= willDo;
                current = current.next;
            }

            return result;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "Dolls kill";
            enum Text2 = "don't provoke us";

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
            Cursor.Block* b = ilt.blockList.insert(a);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            b.length = Text2.length;
            foreach (i, v; Text2)
                b.get()[i] = v;

            ilt.blockList.numberOfItems = Text1.length + Text2.length;

            {
                size_t seen;
                Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);

                foreach (data; &iterator.foreachBlocks) {
                    seen += data.length;
                }

                assert(seen == Text1.length + Text2.length);
                ilt.iteratorList.rcIteratorInternal(false, iterator);
            }

            {
                size_t seen;
                Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);
                iterator.popFront;
                iterator.popBack;

                foreach (data; &iterator.foreachBlocks) {
                    seen += data.length;
                }

                assert(seen == Text1.length + Text2.length - 2);
                ilt.iteratorList.rcIteratorInternal(false, iterator);
            }
        }

        int foreachReverseBlocks(scope int delegate(Char[] data) @safe nothrow @nogc del) {
            Cursor.Block* current = backwards.block;
            size_t offsetIntoB = backwards.offsetIntoBlock, canDo = size_t.max;

            if (this.maximumOffsetFromHead != size_t.max)
                canDo = backwards.offsetFromHead - forwards.offsetFromHead;

            int result;

            while (current.previous !is null && canDo > 0) {
                size_t willDo = canDo;
                auto slice = current.get()[0 .. offsetIntoB];

                if (willDo > slice.length)
                    willDo = slice.length;
                if (slice.length > canDo)
                    slice = slice[$ - willDo .. $];

                result = del(slice);
                if (slice.length > 0 && result)
                    break;

                canDo -= willDo;
                current = current.previous;
                offsetIntoB = current.length;
            }

            return result;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "Dolls kill";
            enum Text2 = "don't provoke us";

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
            Cursor.Block* b = ilt.blockList.insert(a);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            b.length = Text2.length;
            foreach (i, v; Text2)
                b.get()[i] = v;

            ilt.blockList.numberOfItems = Text1.length + Text2.length;

            {
                size_t seen;
                Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);

                foreach (data; &iterator.foreachReverseBlocks) {
                    seen += data.length;
                }

                assert(seen == Text1.length + Text2.length);
                ilt.iteratorList.rcIteratorInternal(false, iterator);
            }

            {
                size_t seen;
                Iterator* iterator = ilt.iteratorList.newIterator(&ilt.blockList);
                iterator.popFront;
                iterator.popBack;

                foreach (data; &iterator.foreachReverseBlocks) {
                    seen += data.length;
                }

                assert(seen == Text1.length + Text2.length - 2);
                ilt.iteratorList.rcIteratorInternal(false, iterator);
            }
        }

        // event hooks

        void moveRange(Cursor.Block* ifThisBlock, size_t ifStartOffsetInBlock, Cursor.Block* movedIntoBlock,
                size_t movedIntoOffset, size_t amount) {
            forwards.moveRange(ifThisBlock, ifStartOffsetInBlock, movedIntoBlock, movedIntoOffset, amount);
            backwards.moveRange(ifThisBlock, ifStartOffsetInBlock, movedIntoBlock, movedIntoOffset, amount);
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "bang bang";
            enum Text2 = "wait a minute";

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
            Cursor.Block* c = ilt.blockList.insert(a);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            c.length = Text2.length;
            foreach (i, v; Text2)
                c.get()[i] = v;

            ilt.blockList.numberOfItems = Text1.length + Text2.length;
            Iterator* iterator1 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator2 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator3 = ilt.iteratorList.newIterator(&ilt.blockList), iterator4 = ilt.iteratorList.newIterator(&ilt.blockList);

            {
                // we want all iterators to point to data entries
                iterator1.back;
                iterator2.back;
                iterator3.back;
                iterator4.back;

                // move iterators around so that we can test that positions are correct regardless of initial configuration
                iterator2.popFront;
                iterator3.popBack;
                iterator4.popFront;
                iterator4.popBack;

                // verify

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == 1);
                assert(iterator3.forwards.offsetIntoBlock == 0);
                assert(iterator4.forwards.offsetIntoBlock == 1);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is a);
                assert(iterator3.forwards.block is a);
                assert(iterator4.forwards.block is a);

                assert(iterator1.backwards.offsetIntoBlock == Text2.length - 1);
                assert(iterator2.backwards.offsetIntoBlock == Text2.length - 1);
                assert(iterator3.backwards.offsetIntoBlock == Text2.length - 2);
                assert(iterator4.backwards.offsetIntoBlock == Text2.length - 2);
                assert(iterator1.backwards.block is c);
                assert(iterator2.backwards.block is c);
                assert(iterator3.backwards.block is c);
                assert(iterator4.backwards.block is c);
            }

            {

                Cursor.Block* b = ilt.blockList.insert(a);

                {
                    size_t oldOffset = 1, newOffset = 0, amountToMove = Text1.length - 1, amountIn = amountToMove;
                    Cursor.Block* from = a, into = b;

                    from.moveFromInto(oldOffset, amountToMove, into, newOffset);
                    assert(from.length == 1);
                    assert(into.length == amountIn);

                    iterator1.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator2.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator3.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator4.moveRange(from, oldOffset, into, newOffset, amountToMove);
                }

                {
                    size_t oldOffset = 0, newOffset = Text1.length - 1, amountToMove = Text2.length - 1,
                        amountIn = Text1.length + Text2.length - 2;
                    Cursor.Block* from = c, into = b;

                    from.moveFromInto(oldOffset, amountToMove, into, newOffset);
                    assert(from.length == 1);
                    assert(into.length == amountIn);

                    iterator1.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator2.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator3.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator4.moveRange(from, oldOffset, into, newOffset, amountToMove);
                }

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == 0);
                assert(iterator3.forwards.offsetIntoBlock == 0);
                assert(iterator4.forwards.offsetIntoBlock == 0);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is b);
                assert(iterator3.forwards.block is a);
                assert(iterator4.forwards.block is b);

                assert(iterator1.backwards.offsetIntoBlock == 0);
                assert(iterator2.backwards.offsetIntoBlock == 0);
                assert(iterator3.backwards.offsetIntoBlock == Text1.length + Text2.length - 3);
                assert(iterator4.backwards.offsetIntoBlock == Text1.length + Text2.length - 3);
                assert(iterator1.backwards.block is c);
                assert(iterator2.backwards.block is c);
                assert(iterator3.backwards.block is b);
                assert(iterator4.backwards.block is b);
            }

            ilt.iteratorList.rcIteratorInternal(false, iterator1);
            ilt.iteratorList.rcIteratorInternal(false, iterator2);
            ilt.iteratorList.rcIteratorInternal(false, iterator3);
            ilt.iteratorList.rcIteratorInternal(false, iterator4);
        }

        void onInsertIncreaseFromHead(size_t ifFromOffsetFromHead, size_t amount) {
            if (this.maximumOffsetFromHead <= ifFromOffsetFromHead)
                return;

            if (this.minimumOffsetFromHead >= ifFromOffsetFromHead)
                this.minimumOffsetFromHead += amount;
            this.maximumOffsetFromHead += amount;

            forwards.onInsertIncreaseFromHead(ifFromOffsetFromHead, amount, this.maximumOffsetFromHead);
            backwards.onInsertIncreaseFromHead(ifFromOffsetFromHead, amount, this.maximumOffsetFromHead);
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "what cat";
            enum Text2 = " the";
            enum Text3 = "what the cat";
            enum OffsetStart = 4;
            enum OffsetEnd = 2;

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            ilt.blockList.numberOfItems = Text1.length;
            Iterator* iterator1 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator2 = ilt.iteratorList.newIterator(&ilt.blockList), iterator3 = ilt.iteratorList.newIterator(&ilt.blockList);

            {
                // we want all iterators to point to data entries
                iterator1.back;
                iterator2.back;
                iterator3.back;

                // move iterators around so that we can test that positions are correct regardless of initial configuration
                foreach (i; 0 .. OffsetStart) {
                    iterator2.popFront;
                    iterator3.popFront;
                }

                foreach (i; 0 .. OffsetEnd) {
                    iterator2.popBack;
                    iterator3.popBack;
                }

                iterator2.popBack;
                iterator3.popFront;

                // verify

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == OffsetStart);
                assert(iterator3.forwards.offsetIntoBlock == OffsetStart + 1);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is a);
                assert(iterator3.forwards.block is a);

                assert(iterator1.backwards.offsetIntoBlock == Text1.length - 1);
                assert(iterator2.backwards.offsetIntoBlock == Text1.length - (OffsetEnd + 2));
                assert(iterator3.backwards.offsetIntoBlock == Text1.length - (OffsetEnd + 1));
                assert(iterator1.backwards.block is a);
                assert(iterator2.backwards.block is a);
                assert(iterator3.backwards.block is a);
            }

            {
                ilt.blockList.numberOfItems += Text2.length;
                a.moveRight(OffsetStart, OffsetStart + Text2.length);

                foreach (i, v; Text2)
                    a.get()[i + OffsetStart] = v;
                assert(a.get() == Text3);

                iterator1.onInsertIncreaseFromHead(OffsetStart, Text2.length);
                iterator2.onInsertIncreaseFromHead(OffsetStart, Text2.length);
                iterator3.onInsertIncreaseFromHead(OffsetStart, Text2.length);

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == OffsetStart + Text2.length);
                assert(iterator3.forwards.offsetIntoBlock == OffsetStart + 1 + Text2.length);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is a);
                assert(iterator3.forwards.block is a);

                assert(iterator1.backwards.offsetIntoBlock == Text3.length - 1);
                assert(iterator2.backwards.offsetIntoBlock == Text3.length - (OffsetEnd + 2));
                assert(iterator3.backwards.offsetIntoBlock == Text3.length - (OffsetEnd + 1));
                assert(iterator1.backwards.block is a);
                assert(iterator2.backwards.block is a);
                assert(iterator3.backwards.block is a);
            }

            ilt.iteratorList.rcIteratorInternal(false, iterator1);
            ilt.iteratorList.rcIteratorInternal(false, iterator2);
            ilt.iteratorList.rcIteratorInternal(false, iterator3);
        }

        void onRemoveDecreaseFromHead(size_t ifFromOffsetFromHead, size_t amount) {
            if (this.maximumOffsetFromHead <= ifFromOffsetFromHead)
                return;

            if (this.minimumOffsetFromHead > ifFromOffsetFromHead) {
                size_t amountToGoBackwards = this.minimumOffsetFromHead - ifFromOffsetFromHead;

                if (amountToGoBackwards > amount)
                    amountToGoBackwards = amount;

                this.minimumOffsetFromHead -= amountToGoBackwards;
            }

            forwards.onRemoveDecreaseFromHead(ifFromOffsetFromHead, amount, this.maximumOffsetFromHead);
            backwards.onRemoveDecreaseFromHead(ifFromOffsetFromHead, amount, this.maximumOffsetFromHead);

            {
                size_t amountToGoBackwards = this.maximumOffsetFromHead - ifFromOffsetFromHead;

                if (amountToGoBackwards > amount)
                    amountToGoBackwards = amount;

                this.maximumOffsetFromHead -= amountToGoBackwards;
            }
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "what the cat";
            enum Text2 = " the";
            enum Text3 = "what cat";
            enum OffsetStart = 4;
            enum OffsetEnd = 3;

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            ilt.blockList.numberOfItems = Text1.length;
            Iterator* iterator1 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator2 = ilt.iteratorList.newIterator(&ilt.blockList), iterator3 = ilt.iteratorList.newIterator(&ilt.blockList);

            {
                // we want all iterators to point to data entries
                iterator1.back;
                iterator2.back;
                iterator3.back;

                // move iterators around so that we can test that positions are correct regardless of initial configuration
                foreach (i; 0 .. OffsetStart) {
                    iterator2.popFront;
                    iterator3.popFront;
                }

                foreach (i; 0 .. OffsetEnd) {
                    iterator2.popBack;
                    iterator3.popBack;
                }

                iterator2.popBack;
                iterator3.popFront;

                // verify

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == OffsetStart);
                assert(iterator3.forwards.offsetIntoBlock == OffsetStart + 1);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is a);
                assert(iterator3.forwards.block is a);

                assert(iterator1.backwards.offsetIntoBlock == Text1.length - 1);
                assert(iterator2.backwards.offsetIntoBlock == Text1.length - (OffsetEnd + 2));
                assert(iterator3.backwards.offsetIntoBlock == Text1.length - (OffsetEnd + 1));
                assert(iterator1.backwards.block is a);
                assert(iterator2.backwards.block is a);
                assert(iterator3.backwards.block is a);
            }

            {
                ilt.blockList.numberOfItems -= Text2.length;
                a.moveLeft(OffsetStart + Text2.length, OffsetStart);
                assert(a.get() == Text3);

                iterator1.onRemoveDecreaseFromHead(OffsetStart, Text2.length);
                iterator2.onRemoveDecreaseFromHead(OffsetStart, Text2.length);
                iterator3.onRemoveDecreaseFromHead(OffsetStart, Text2.length);

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == OffsetStart);
                assert(iterator3.forwards.offsetIntoBlock == OffsetStart);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is a);
                assert(iterator3.forwards.block is a);

                assert(iterator1.backwards.offsetIntoBlock == Text3.length - 1);
                assert(iterator2.backwards.offsetIntoBlock == OffsetStart);
                assert(iterator3.backwards.offsetIntoBlock == OffsetStart);
                assert(iterator1.backwards.block is a);
                assert(iterator2.backwards.block is a);
                assert(iterator3.backwards.block is a);
            }

            ilt.iteratorList.rcIteratorInternal(false, iterator1);
            ilt.iteratorList.rcIteratorInternal(false, iterator2);
            ilt.iteratorList.rcIteratorInternal(false, iterator3);
        }

    private:
        bool emptyInternal() {
            return forwards.isEmpty(minimumOffsetFromHead, backwards.offsetFromHead);
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

        bool isEmpty(size_t start, size_t end) {
            return offsetFromHead < start || offsetFromHead >= end;
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

        // event hooks

        void moveRange(Block* ifThisBlock, size_t ifStartOffsetInBlock, Block* movedIntoBlock, size_t movedIntoOffset, size_t amount) {
            if (this.block is ifThisBlock) {
                if (this.offsetIntoBlock >= ifStartOffsetInBlock && this.offsetIntoBlock < ifStartOffsetInBlock + amount) {
                    this.block = movedIntoBlock;
                    this.offsetIntoBlock = (this.offsetIntoBlock - ifStartOffsetInBlock) + movedIntoOffset;
                } else if (this.offsetIntoBlock >= ifStartOffsetInBlock + amount) {
                    this.offsetIntoBlock -= amount;
                }
            }
        }

        void onInsertIncreaseFromHead(size_t ifFromOffsetFromHead, size_t amount, size_t maximumOffsetFromHead) {
            if (this.offsetFromHead >= ifFromOffsetFromHead) {
                advanceForward(amount, maximumOffsetFromHead, offsetFromHead + amount < maximumOffsetFromHead);
            }
        }

        void onRemoveDecreaseFromHead(size_t ifFromOffsetFromHead, size_t amount, size_t maximumOffsetFromHead) {
            if (this.offsetFromHead > ifFromOffsetFromHead) {
                advanceBackwards(amount, ifFromOffsetFromHead, maximumOffsetFromHead, offsetFromHead + amount < maximumOffsetFromHead);
            }
        }
    }

    unittest {
        IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());
        alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

        enum Text1 = "take me to";
        enum Text2 = "do or die";

        Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);
        Cursor.Block* b = ilt.blockList.insert(a);

        a.length = Text1.length;
        foreach (i, v; Text1)
            a.get()[i] = v;

        b.length = Text2.length;
        foreach (i, v; Text2)
            b.get()[i] = v;

        ilt.blockList.numberOfItems = Text1.length + Text2.length;

        static struct CustomIterator {
            Cursor cursor;
            size_t max;

            int opApply(Del)(scope Del del) {
                int result;

                while (!cursor.isEmpty(0, max)) {
                    Char c = cursor.get();

                    result = del(c);
                    if (result)
                        return result;

                    cursor.advanceForward(1, max, true);
                }

                return result;
            }
        }

        CustomIterator ci;
        ci.max = ilt.blockList.numberOfItems;

        () @trusted { ci.cursor.setup(&ilt.blockList, 0); }();

        bool matches(CustomIterator iterator) {
            size_t count;

            foreach (Char c; iterator) {
                if (count == 0 && !(c == 't' || c == 'd'))
                    return false;
                else if (count == 1 && c != 'o')
                    return false;
                else if (count > 1)
                    break;

                count++;
            }

            return true;
        }

        size_t matched;

        foreach (Char c; ci) {
            if (matches(ci)) {
                matched++;
            }
        }

        assert(matched == 2);
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
