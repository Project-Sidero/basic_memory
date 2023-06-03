module sidero.base.text.internal.builder.iteratorlist;
import sidero.base.text.internal.builder.blocklist;
import sidero.base.allocators;
import sidero.base.attributes : hidden;

struct IteratorListImpl(Char, alias CustomIteratorContents) {
    Iterator* head;

@safe nothrow @nogc @hidden:

    Iterator* newIterator(return scope BlockListImpl!Char* blockList, size_t minimumOffsetFromHead = 0,
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

        assert(ret.forwards.block !is null);
        assert(ret.backwards.block !is null);
        assert(ret.forwards.offsetFromHead == ret.minimumOffsetFromHead);
        assert(ret.backwards.offsetFromHead == ret.maximumOffsetFromHead);

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

        ilt.blockList.numberOfItems = a.length + b.length;

        auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);
        ilt.iteratorList.rcIteratorInternal(false, iterator);
    }

    void rcIteratorInternal(bool addRef, scope Iterator* iterator) @trusted {
        assert(iterator !is null);

        if (addRef)
            iterator.refCount++;
        else if (iterator.refCount == 1) {
            if (iterator.next !is null)
                iterator.next.previous = iterator.previous;
            if (iterator.previous !is null)
                iterator.previous.next = iterator.next;
            else
                head = iterator.next;

            RCAllocator allocator = iterator.blockList.allocator;
            allocator.dispose(iterator);
        } else
            iterator.refCount--;
    }

    unittest {
        IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

        auto a = ilt.iteratorList.newIterator(&ilt.blockList), b = ilt.iteratorList.newIterator(&ilt.blockList);

        int seenA, seenB;

        foreach (iterator; ilt.iteratorList) {
            if (iterator is a)
                seenA++;
            else if (iterator is b)
                seenB++;
            else
                assert(0);
        }

        assert(seenA == 1);
        assert(seenB == 1);

        ilt.iteratorList.rcIteratorInternal(false, a);
        ilt.iteratorList.rcIteratorInternal(false, b);
    }

    int opApply(scope int delegate(scope Iterator*) @safe nothrow @nogc del) {
        Iterator* current = head;
        int result;

        while (current !is null) {
            result = del(current);
            if (result)
                return result;

            current = current.next;
        }

        return result;
    }

    struct Iterator {
        Iterator* previous, next;
        Cursor forwards, backwards;
        size_t minimumOffsetFromHead, maximumOffsetFromHead;

        BlockListImpl!Char* blockList;
        ptrdiff_t refCount;

        bool primedBackwards;

        static if (is(CustomIteratorContents == void)) {
        } else {
            mixin CustomIteratorContents;
        }

    @safe nothrow @nogc @hidden:

        export invariant () {
            assert(minimumOffsetFromHead <= forwards.offsetFromHead);
            assert(forwards.offsetFromHead <= backwards.offsetFromHead);
            assert(backwards.offsetFromHead <= maximumOffsetFromHead);

            assert(forwards.block !is null);
            assert(backwards.block !is null);
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
                blockList.mutex.pureLock;

                if (result)
                    break;
                popFrontInternal();
            }

            return result;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

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

            ilt.blockList.numberOfItems = Text1.length + Text2.length;
            auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);
            ptrdiff_t lastOffset = -1;

            foreach (i, v; &iterator.opApply!FET) {
                if (i >= Text1.length)
                    assert(Text2[i - Text1.length] == v);
                else
                    assert(Text1[i] == v);

                assert(lastOffset + 1 == i);
                lastOffset++;
            }

            assert(lastOffset == Text1.length + Text2.length - 1);
            ilt.iteratorList.rcIteratorInternal(false, iterator);
        }

        int opApplyReverse(Del)(scope Del del) @trusted {
            blockList.mutex.pureLock;
            scope (exit)
                blockList.mutex.unlock;

            int result;

            while (!emptyInternal()) {
                Char value = backInternal();
                size_t offset = this.backwards.offsetFromHead - (this.minimumOffsetFromHead + 1);

                blockList.mutex.unlock;
                result = del(offset, value);
                blockList.mutex.pureLock;

                if (result)
                    break;
                popBackInternal();
            }

            return result;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

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

            ilt.blockList.numberOfItems = Text1.length + Text2.length;
            auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);
            size_t lastOffset = Text1.length + Text2.length, numberOfZero, count;

            foreach (i, v; &iterator.opApplyReverse!FET) {
                if (i >= Text1.length)
                    assert(Text2[i - Text1.length] == v);
                else
                    assert(Text1[i] == v);

                if (i == 0) {
                    numberOfZero++;
                    assert(numberOfZero == 1);
                    assert(lastOffset - 1 == i);
                } else {
                    assert(lastOffset - 1 == i);
                    lastOffset--;
                }

                count++;
            }

            assert(count > 0);
            assert(count == Text1.length + Text2.length);
            assert(numberOfZero == 1);
            ilt.iteratorList.rcIteratorInternal(false, iterator);
        }

        bool empty() const @trusted {
            Iterator* self = cast(Iterator*)&this;

            self.blockList.mutex.pureLock;
            scope (exit)
                self.blockList.mutex.unlock;

            return self.emptyInternal();
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
            size_t offsetIntoB = forwards.offsetIntoBlock, canDo = backwards.offsetFromHead - forwards.offsetFromHead;

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
                auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);

                foreach (data; &iterator.foreachBlocks) {
                    seen += data.length;
                }

                assert(seen == Text1.length + Text2.length);
                ilt.iteratorList.rcIteratorInternal(false, iterator);
            }

            {
                size_t seen;
                auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);
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
                auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);

                foreach (data; &iterator.foreachReverseBlocks) {
                    seen += data.length;
                }

                assert(seen == Text1.length + Text2.length);
                ilt.iteratorList.rcIteratorInternal(false, iterator);
            }

            {
                size_t seen;
                auto iterator = ilt.iteratorList.newIterator(&ilt.blockList);
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

        void moveRange(scope Cursor.Block* ifThisBlock, size_t ifStartOffsetInBlock, scope Cursor.Block* movedIntoBlock,
                size_t movedIntoOffset, size_t amount) scope @trusted {
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
            auto iterator1 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator2 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator3 = ilt.iteratorList.newIterator(&ilt.blockList), iterator4 = ilt.iteratorList.newIterator(&ilt.blockList);

            {
                // we want all iterators to point to data entries
                iterator1.backInternal;
                iterator2.backInternal;
                iterator3.backInternal;
                iterator4.backInternal;

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

                    size_t amountOfData;
                    foreach (Char[] data; ilt.blockList) {
                        amountOfData += data.length;
                    }
                    assert(amountOfData == Text1.length + Text2.length);

                    iterator1.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator2.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator3.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator4.moveRange(from, oldOffset, into, newOffset, amountToMove);

                    assert(iterator2.forwards.offsetFromHead > 0);
                    assert(iterator4.forwards.offsetFromHead > 0);
                    assert(iterator1.backwards.offsetFromHead > 0);
                    assert(iterator2.backwards.offsetFromHead > 0);
                    assert(iterator3.backwards.offsetFromHead > 0);
                    assert(iterator4.backwards.offsetFromHead > 0);
                }

                {
                    size_t oldOffset = 0, newOffset = Text1.length - 1, amountToMove = Text2.length - 1,
                        amountIn = Text1.length + Text2.length - 2;
                    Cursor.Block* from = c, into = b;

                    from.moveFromInto(oldOffset, amountToMove, into, newOffset);
                    assert(from.length == 1);
                    assert(into.length == amountIn);

                    size_t amountOfData;
                    foreach (Char[] data; ilt.blockList) {
                        amountOfData += data.length;
                    }
                    assert(amountOfData == Text1.length + Text2.length);

                    iterator1.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator2.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator3.moveRange(from, oldOffset, into, newOffset, amountToMove);
                    iterator4.moveRange(from, oldOffset, into, newOffset, amountToMove);

                    assert(iterator2.forwards.offsetFromHead > 0);
                    assert(iterator4.forwards.offsetFromHead > 0);
                    assert(iterator1.backwards.offsetFromHead > 0);
                    assert(iterator2.backwards.offsetFromHead > 0);
                    assert(iterator3.backwards.offsetFromHead > 0);
                    assert(iterator4.backwards.offsetFromHead > 0);
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
            auto iterator1 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator2 = ilt.iteratorList.newIterator(&ilt.blockList), iterator3 = ilt.iteratorList.newIterator(&ilt.blockList);

            {
                // we want all iterators to point to data entries
                iterator1.backInternal;
                iterator2.backInternal;
                iterator3.backInternal;

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

        void onRemoveDecreaseFromHead(scope Cursor.Block* forBlock, size_t ifFromOffsetFromHead, size_t amount) {
            if (this.maximumOffsetFromHead < ifFromOffsetFromHead)
                return;

            if (this.minimumOffsetFromHead > ifFromOffsetFromHead) {
                size_t amountToGoBackwards = this.minimumOffsetFromHead - ifFromOffsetFromHead;

                if (amountToGoBackwards > amount)
                    amountToGoBackwards = amount;

                this.minimumOffsetFromHead -= amountToGoBackwards;
            }

            size_t newMaximumOffsetFromHead = this.maximumOffsetFromHead;

            {
                size_t amountToGoBackwards = this.maximumOffsetFromHead - ifFromOffsetFromHead;

                if (amountToGoBackwards > amount)
                    amountToGoBackwards = amount;

                newMaximumOffsetFromHead -= amountToGoBackwards;
            }

            forwards.onRemoveDecreaseFromHead(forBlock, ifFromOffsetFromHead, amount, this.maximumOffsetFromHead, false);
            backwards.onRemoveDecreaseFromHead(forBlock, ifFromOffsetFromHead, amount, this.maximumOffsetFromHead, true);
            this.maximumOffsetFromHead = newMaximumOffsetFromHead;
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            alias FET = int delegate(size_t, ref Char) @safe nothrow @nogc;

            enum Text1 = "what the cat";
            enum Text2 = "the ";
            enum Text3 = "what cat";
            enum OffsetStart = 4;
            enum OffsetEnd = 3;

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head);

            a.length = Text1.length;
            foreach (i, v; Text1)
                a.get()[i] = v;

            ilt.blockList.numberOfItems = Text1.length;
            auto iterator1 = ilt.iteratorList.newIterator(&ilt.blockList),
                iterator2 = ilt.iteratorList.newIterator(&ilt.blockList), iterator3 = ilt.iteratorList.newIterator(&ilt.blockList);

            {
                // we want all iterators to point to data entries
                iterator1.backInternal;
                iterator2.backInternal;
                iterator3.backInternal;

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

                iterator1.onRemoveDecreaseFromHead(a, OffsetStart, Text2.length);
                iterator2.onRemoveDecreaseFromHead(a, OffsetStart, Text2.length);
                iterator3.onRemoveDecreaseFromHead(a, OffsetStart, Text2.length);

                assert(iterator1.forwards.offsetIntoBlock == 0);
                assert(iterator2.forwards.offsetIntoBlock == OffsetStart);
                assert(iterator3.forwards.offsetIntoBlock == OffsetStart);
                assert(iterator1.forwards.block is a);
                assert(iterator2.forwards.block is a);
                assert(iterator3.forwards.block is a);

                assert(iterator1.backwards.offsetIntoBlock == Text3.length - 1);
                assert(iterator2.backwards.offsetFromHead == OffsetStart);
                assert(iterator2.backwards.offsetIntoBlock == OffsetStart - 1);
                assert(iterator3.backwards.offsetFromHead == OffsetStart + 1);
                assert(iterator3.backwards.offsetIntoBlock == OffsetStart);
                assert(iterator1.backwards.block is a);
                assert(iterator2.backwards.block is a);
                assert(iterator3.backwards.block is a);
            }

            ilt.iteratorList.rcIteratorInternal(false, iterator1);
            ilt.iteratorList.rcIteratorInternal(false, iterator2);
            ilt.iteratorList.rcIteratorInternal(false, iterator3);
        }

        void moveCursorsFromTail() {
            forwards.moveFromTail;
            backwards.moveFromTail;
        }

        bool emptyInternal() {
            const actualBack = backwards.offsetFromHead + 1;
            return forwards.offsetFromHead + 1 >= actualBack || actualBack <= forwards.offsetFromHead + 1;
        }

        Char frontInternal() {
            import std.algorithm : min;

            forwards.advanceForward(0, min(backwards.offsetFromHead + 1, maximumOffsetFromHead), true);
            return forwards.get();
        }

        Char backInternal() {
            primeBackwardsInternal;

            if (!backwards.inData)
                backwards.advanceBackwards(0, forwards.offsetFromHead, maximumOffsetFromHead, true, true);

            return backwards.get();
        }

        void popFrontInternal() {
            import std.algorithm : min;

            forwards.advanceForward(1, min(backwards.offsetFromHead + 1, maximumOffsetFromHead), true);
        }

        void primeBackwardsInternal() {
            if (!this.primedBackwards && backwards.inData) {
                backwards.advanceBackwards(1, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
            }

            primedBackwards = true;
        }

        void popBackInternal() {
            primeBackwardsInternal;
            backwards.advanceBackwards(1, forwards.offsetFromHead, maximumOffsetFromHead, true, true);
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
        auto iterator1 = ilt.iteratorList.newIterator(&ilt.blockList), iterator2 = ilt.iteratorList.newIterator(&ilt.blockList);

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

    @safe nothrow @nogc @hidden:

        Char get() scope {
            assert(inData());
            return block.get()[offsetIntoBlock];
        }

        Char[] get(size_t maximumOffsetFromHead) scope {
            if (block is null)
                return null;

            assert(offsetFromHead <= maximumOffsetFromHead);
            size_t canDo = maximumOffsetFromHead - offsetFromHead;

            if (canDo > block.length - offsetIntoBlock)
                canDo = block.length - offsetIntoBlock;

            return block.get()[offsetIntoBlock .. offsetIntoBlock + canDo];
        }

        bool isOutOfRange(size_t start, size_t end) scope {
            return offsetFromHead < start || offsetFromHead >= end;
        }

        bool inData() scope {
            assert(block !is null);
            return block.length > offsetIntoBlock;
        }

        void setup(scope BlockListImpl!Char* blockList, size_t offsetFromHead) scope {
            this.offsetFromHead = offsetFromHead;
            block = blockList.blockForOffset(this.offsetFromHead, this.offsetIntoBlock);
        }

        void advanceToNextBlock() scope {
            if (block is null)
                return;

            offsetFromHead += block.length - offsetIntoBlock;
            offsetIntoBlock = 0;

            if (this.block.next !is null)
                this.block = this.block.next;
        }

        void advanceForward(size_t amount, size_t maximumOffsetFromHead, bool limitToData) scope {
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

        void advanceBackwards(size_t amount, size_t minimumOffsetFromHead, size_t maximumOffsetFromHead, bool limitToData,
                bool backwardsIterator) scope {
            assert(block !is null);

            if (limitToData && offsetIntoBlock == this.block.length) {
                if (offsetIntoBlock == 0) {
                    this.block = this.block.previous;
                    offsetIntoBlock = this.block.length;
                }

                if (offsetIntoBlock > 0) {
                    offsetIntoBlock--;
                }
            }

            // until currentBlock's previous node is headBlock
            while (block.previous !is null && amount > 0 && (offsetFromHead + backwardsIterator) > minimumOffsetFromHead) {
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
                            offsetFromHead--;
                        }
                    } else {
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

            if (!limitToData && offsetIntoBlock == 0 && this.block.previous !is null) {
                this.block = this.block.previous;
                offsetIntoBlock = this.block.length;
            }

            assert(amount == 0 || this.offsetFromHead == minimumOffsetFromHead, "WHAT?");
            assert(this.block !is null);

            if (limitToData)
                assert(this.offsetIntoBlock < this.block.length || this.block.previous is null);
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            Cursor cursor;
            cursor.block = &ilt.blockList.tail;

            cursor.advanceBackwards(1, 0, 0, false, true);
            assert(cursor.block.next !is null);
        }

        // event hooks

        void moveRange(scope Block* ifThisBlock, size_t ifStartOffsetInBlock, scope Block* movedIntoBlock,
                size_t movedIntoOffset, size_t amount) scope @trusted {

            if (this.block is ifThisBlock) {
                if (this.offsetIntoBlock >= ifStartOffsetInBlock) {
                    if (this.offsetIntoBlock < ifStartOffsetInBlock + amount) {
                        this.block = movedIntoBlock;
                        this.offsetIntoBlock = (this.offsetIntoBlock - ifStartOffsetInBlock) + movedIntoOffset;
                    } else {
                        this.offsetIntoBlock -= amount;
                    }
                } else
                    assert(this.offsetIntoBlock < ifStartOffsetInBlock);
            }
        }

        void onInsertIncreaseFromHead(size_t ifFromOffsetFromHead, size_t amount, size_t maximumOffsetFromHead) scope {
            if (this.offsetFromHead >= ifFromOffsetFromHead) {
                advanceForward(amount, maximumOffsetFromHead, offsetFromHead + amount < maximumOffsetFromHead);
            }
        }

        void onRemoveDecreaseFromHead(scope Block* forBlock, size_t ifFromOffsetFromHead, size_t amount,
                size_t maximumOffsetFromHead, bool backwardsIterator) scope {
            if (this.offsetFromHead >= ifFromOffsetFromHead && this.block is forBlock) {
                size_t canDo = this.offsetFromHead - ifFromOffsetFromHead;
                if (canDo < amount)
                    amount = canDo;

                advanceBackwards(amount, ifFromOffsetFromHead, maximumOffsetFromHead,
                        offsetFromHead + amount < maximumOffsetFromHead, backwardsIterator);

                if (this.offsetFromHead == ifFromOffsetFromHead && this.offsetIntoBlock == 0)
                    advanceBackwards(0, ifFromOffsetFromHead, maximumOffsetFromHead, false, backwardsIterator);
            } else if (this.offsetFromHead >= ifFromOffsetFromHead + amount) {
                this.offsetFromHead -= amount;
            }

            assert(this.offsetFromHead <= maximumOffsetFromHead);
        }

        unittest {
            IteratorListTest!Char ilt = IteratorListTest!Char(globalAllocator());

            Cursor.Block* a = ilt.blockList.insert(&ilt.blockList.head), b = ilt.blockList.insert(a);
            a.length = 10;
            b.length = 10;
            ilt.blockList.numberOfItems = 20;

            Cursor cursor;
            cursor.setup(&ilt.blockList, 20);
            assert(cursor.offsetFromHead == 20);
            assert(cursor.offsetIntoBlock == 0);
            assert(cursor.block is &ilt.blockList.tail);

            cursor.advanceBackwards(0, 0, 20, false, true);
            assert(cursor.offsetFromHead == 20);
            assert(cursor.offsetIntoBlock == 10);
            assert(cursor.block is b);

            cursor.onRemoveDecreaseFromHead(b, 10, 10, 20, false);
            assert(cursor.block is a);
            assert(cursor.offsetFromHead == 10);
            assert(cursor.offsetIntoBlock == 10);
        }

        void moveFromTail() {
            if (block !is null && block.previous !is null && block.length == 0 && offsetIntoBlock == 0) {
                block = block.previous;
                offsetIntoBlock = block.length;
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

                while (!cursor.isOutOfRange(0, max)) {
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

    IteratorListImpl!(Char, void) iteratorList;
    alias Iterator = iteratorList.Iterator;

@safe nothrow @nogc @hidden:

    this(return scope RCAllocator allocator) scope @trusted {
        this.blockList = BlockList(allocator);
    }

    @disable this(this);

@safe nothrow @nogc:

     ~this() {
        blockList.clear;
        assert(iteratorList.head is null);
    }
}
