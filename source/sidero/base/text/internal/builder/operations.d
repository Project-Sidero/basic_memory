module sidero.base.text.internal.builder.operations;
import sidero.base.text.internal.builder.iteratorlist;
import sidero.base.text.internal.builder.blocklist;
import sidero.base.allocators;

mixin template StringBuilderOperations() {
    alias BlockList = BlockListImpl!Char;

    BlockList blockList;

    IteratorListImpl!(Char, CustomIteratorContents) iteratorList;
    alias Iterator = iteratorList.Iterator;
    alias Cursor = iteratorList.Cursor;
    alias Block = BlockList.Block;
    alias OpTest = sidero.base.text.internal.builder.operations.OpTest;

@safe nothrow @nogc:

    void rc(bool addRef) {
        blockList.mutex.pureLock;
        if (this.rcInternal(addRef))
            blockList.mutex.unlock;
    }

    void rcIterator(bool addRef, scope Iterator* iterator) {
        blockList.mutex.pureLock;

        if (iterator !is null)
            iteratorList.rcIteratorInternal(addRef, iterator);
        if (this.rcInternal(addRef))
            blockList.mutex.unlock;
    }

    bool rcInternal(bool addRef) @trusted {
        if (addRef)
            blockList.refCount++;
        else if (blockList.refCount == 1) {
            RCAllocator allocator = blockList.allocator;
            blockList.clear;

            assert(iteratorList.head is null);
            assert(blockList.head.next.next is null);

            allocator.dispose(&this);
            return false;
        } else
            blockList.refCount--;

        return true;
    }

    Iterator* newIterator(scope Iterator* iterator = null, ptrdiff_t minimumOffsetFromHead = 0,
            ptrdiff_t maximumOffsetFromHead = ptrdiff_t.max) @trusted {
        blockList.mutex.pureLock;
        changeIndexToOffset(iterator, minimumOffsetFromHead, maximumOffsetFromHead);

        this.rcInternal(true);
        Iterator* ret = iteratorList.newIterator(&blockList, minimumOffsetFromHead, maximumOffsetFromHead);

        blockList.mutex.unlock;
        return ret;
    }

    size_t externalLength(scope Iterator* iterator = null) {
        blockList.mutex.pureLock;

        size_t ret;

        if (iterator is null)
            ret = blockList.numberOfItems;
        else
            ret = iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead;

        blockList.mutex.unlock;
        return ret;
    }

    void externalInsert(scope Iterator* iterator, ptrdiff_t offset, scope ref OtherStateAsTarget!Char other, bool clobber) @trusted {
        blockList.mutex.pureLock;
        if (other.obj !is &this)
            other.mutex(true);

        assert(other.length() > 0);
        changeIndexToOffset(iterator, offset);

        size_t maximumOffsetFromHead;
        Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, offset);
        assert(other.length() > 0);
        insertOperation(cursor, maximumOffsetFromHead, other, clobber);
        assert(other.length() > 0);

        blockList.mutex.unlock;
        if (other.obj !is &this)
            other.mutex(false);
    }

    void externalRemove(scope Iterator* iterator, ptrdiff_t offset, size_t amount) @trusted {
        blockList.mutex.pureLock;

        changeIndexToOffset(iterator, offset);

        size_t maximumOffsetFromHead;
        Cursor cursor = cursorFor(iterator, maximumOffsetFromHead, offset);
        removeOperation(cursor, maximumOffsetFromHead, amount);

        blockList.mutex.unlock;
    }

    // exposed /\/\/\/\/\
    // internal \/\/\/\/

    void changeIndexToOffset(scope Iterator* iterator, scope ref ptrdiff_t a) {
        size_t actualLength;

        if (iterator is null)
            actualLength = blockList.numberOfItems;
        else
            actualLength = iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead;

        if (a < 0) {
            assert(actualLength > -a, "First offset must be smaller than length");
            a = actualLength + a;
        }
    }

    void changeIndexToOffset(scope Iterator* iterator, scope ref ptrdiff_t a, scope ref ptrdiff_t b) {
        size_t actualLength;

        if (iterator !is null) {
            actualLength = iterator.backwards.offsetFromHead - iterator.forwards.offsetFromHead;
            if (a == ptrdiff_t.max)
                a = iterator.maximumOffsetFromHead;
            if (b == ptrdiff_t.max)
                b = iterator.maximumOffsetFromHead;
        } else
            actualLength = blockList.numberOfItems;

        if (a < 0) {
            assert(actualLength > -a, "First offset must be smaller than length");
            a = actualLength + a;
        }

        if (b < 0) {
            assert(actualLength > -b, "First offset must be smaller than length");
            b = actualLength + b;
        }

        if (b < a) {
            ptrdiff_t temp = a;
            a = b;
            b = temp;
        }

        if (iterator !is null) {
            a += iterator.minimumOffsetFromHead;

            if (b + iterator.minimumOffsetFromHead <= iterator.maximumOffsetFromHead)
                b += iterator.minimumOffsetFromHead;
        }
    }

    Cursor cursorFor(scope Iterator* iterator, out size_t maximumOffsetFromHead, size_t offset = 0) scope @trusted {
        if (iterator !is null) {
            offset += iterator.forwards.offsetFromHead;
            maximumOffsetFromHead = iterator.backwards.offsetFromHead;
        } else
            maximumOffsetFromHead = blockList.numberOfItems;

        Cursor ret;
        ret.setup(&blockList, offset);

        return ret;
    }

    // keeps position the same position
    void removeOperation(scope Iterator* iterator, scope ref Cursor cursor, size_t amount) {
        size_t maximumOffsetFromHead = blockList.numberOfItems;

        if (iterator !is null) {
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        removeOperation(cursor, maximumOffsetFromHead, amount);
    }

    // keeps position the same position
    void removeOperation(scope ref Cursor cursor, size_t maximumOffsetFromHead, size_t amount) {
        if (amount > maximumOffsetFromHead || cursor.offsetFromHead + amount > maximumOffsetFromHead) {
            assert(cursor.offsetFromHead < maximumOffsetFromHead);
            amount = maximumOffsetFromHead - cursor.offsetFromHead;
        }

        size_t amountRemoved = amount;

        // nothing to do
        if (cursor.offsetFromHead >= maximumOffsetFromHead || amount == 0)
            return;

        foreach (iterator; iteratorList) {
            iterator.onRemoveDecreaseFromHead(cursor.offsetFromHead, amount);
        }

        if (cursor.offsetIntoBlock == 0) {
            cursor.advanceBackwards(0, cursor.offsetFromHead, maximumOffsetFromHead, false, false);
            assert(cursor.offsetIntoBlock == cursor.block.length);
            assert(cursor.block.next !is null);
        }

        while (amount > 0) {
            Block* block = cursor.block;
            size_t offsetIntoBlock = cursor.offsetIntoBlock, offsetFromHead = cursor.offsetFromHead;

            if (offsetIntoBlock == block.length) {
                block = block.next;
                offsetIntoBlock = 0;

                if (block.next is null) {
                    // we are at tail block, done!
                    break;
                }
            }

            size_t canDo = block.length - offsetIntoBlock;
            if (canDo > amount)
                canDo = amount;
            onRemove(block.get()[offsetIntoBlock .. offsetIntoBlock + canDo]);

            if (canDo + offsetIntoBlock == block.length) {
                // might have a prefix, no suffix, so this is either the first node or a middle node
                // either way we at at the end of the block
                amount -= canDo;

                if (offsetIntoBlock == 0) {
                    // nothing is left, ok so we will deallocate here
                    Block* toFree = block, next = block.next;

                    blockList.remove(toFree);

                    block = next;
                } else {
                    // we have a prefix, this is only applicable to the first block

                    block.length -= canDo;
                    block = block.next;
                }

                offsetIntoBlock = 0;
            } else {
                // we have a suffix
                amount -= canDo;

                size_t amountBeingMoved = block.length - (canDo + offsetIntoBlock), newOffset;
                Block* intoBlock;

                if (offsetIntoBlock == 0) {
                    // we have no prefix

                    if (block.previous.previous !is null && block.previous.length + (block.length - canDo) < BlockList.Count) {
                        // merge into previous block
                        newOffset = block.previous.length;
                        intoBlock = block.previous;
                    } else {
                        // keep suffix in current node

                        newOffset = 0;
                        intoBlock = block;
                    }
                } else {
                    // we have both a prefix and a suffix

                    intoBlock = block;
                    newOffset = offsetIntoBlock;
                }

                if (intoBlock is block)
                    block.moveLeft(offsetIntoBlock + canDo, newOffset);
                else
                    block.moveFromInto(offsetIntoBlock + canDo, amountBeingMoved, intoBlock, newOffset);

                iteratorList.opApply((scope iterator) @trusted {
                    iterator.moveRange(block, offsetIntoBlock, intoBlock, newOffset, amountBeingMoved);
                    return 0;
                });

                if (block.length == 0) {
                    assert(cursor.block !is block);
                    // no prefix or suffix left in this block, so deallocate block
                    blockList.remove(block);

                    foreach (iterator; iteratorList) {
                        assert(iterator.forwards.block !is block);
                        assert(iterator.backwards.block !is block);
                    }
                }
            }
        }

        assert(amount == 0);
        blockList.numberOfItems -= amountRemoved;
    }

    unittest {
        OpTest!Char opTest = OpTest!Char(globalAllocator());

        Char[BlockList.Count * 3] StartText;
        foreach (i, ref c; StartText) {
            if (i < BlockList.Count)
                c = 'A' + (i % 26);
            else
                c = (i % 2 == 0 ? 'Z' : 'z') - ((i - BlockList.Count) % 26);
        }

        size_t[5] sizeOf = [
            BlockList.Count * 2, BlockList.Count / 4, BlockList.Count / 4, BlockList.Count / 4,
            BlockList.Count - ((BlockList.Count / 4) * 3)
        ];
        size_t[5] expectedLengths = [
            BlockList.Count, sizeOf[2] + sizeOf[3] + sizeOf[4], sizeOf[2] + sizeOf[4], sizeOf[2], 0
        ];
        size_t[5] offsetOf = [BlockList.Count, 0, sizeOf[2], sizeOf[2], 0];

        Char[BlockList.Count][3] Expected;

        {
            // ABCDEFGHIJ KLMNOPQRSTUVWXYZABCDEFGHIJKLMN
            foreach (i, ref c; Expected[0]) {
                c = 'A' + (i % 26);
            }

            //KLMNOPQRSTUVWXYZABCDEFGHIJKLMN
            foreach (i, ref c; Expected[1]) {
                size_t actual = i + sizeOf[1];
                c = 'A' + (actual % 26);
            }

            //KLMNOPQRST UVWXYZABCD EFGHIJKLMN
            foreach (i, ref c; Expected[2]) {
                size_t actual = i + sizeOf[1];

                if (i >= sizeOf[2])
                    actual += sizeOf[2];

                c = 'A' + (actual % 26);
            }
        }

        {
            Block* block1 = opTest.blockList.insert(&opTest.blockList.head), block2 = opTest.blockList.insert(block1),
                block3 = opTest.blockList.insert(block2);
            Char[] todo = StartText[];

            block1.length = BlockList.Count;
            block2.length = BlockList.Count;
            block3.length = BlockList.Count;

            foreach (i, ref c; block1.get())
                c = todo[i];
            todo = todo[BlockList.Count .. $];

            foreach (i, ref c; block2.get())
                c = todo[i];
            todo = todo[BlockList.Count .. $];

            foreach (i, ref c; block3.get())
                c = todo[i];

            opTest.blockList.numberOfItems = BlockList.Count * 3;
        }

        opTest.Iterator* iterator1, iterator2, iterator3, iterator4, iterator5, iterator6;
        iterator6 = opTest.newIterator(null, opTest.blockList.numberOfItems, opTest.blockList.numberOfItems);

        void test(size_t offsetFromHead, scope Char[] expected, return ref opTest.Iterator* iterator) @trusted {
            iterator = opTest.newIterator(null, offsetFromHead, offsetFromHead + expected.length);

            opTest.Cursor cursor = iterator.forwards;
            opTest.removeOperation(null, cursor, opTest.blockList.numberOfItems - expected.length);

            {
                scope opTest.LiteralMatcher literalMatcher;
                literalMatcher.literal = expected;

                opTest.Cursor literalCursor;
                literalCursor.setup(&opTest.blockList, 0);

                bool matched = literalMatcher.matches(literalCursor, opTest.blockList.numberOfItems);
                assert(matched);
                assert(opTest.blockList.numberOfItems == expected.length);
            }

            {
                // verify the block iterator cursors is pointing at

                bool foundBlockForwards = iterator.forwards.block is &opTest.blockList.head ||
                    iterator.forwards.block is &opTest.blockList.tail,
                    foundBlockBackwards = iterator.backwards.block is &opTest.blockList.head ||
                    iterator.backwards.block is &opTest.blockList.tail;
                foreach (Block* block; opTest.blockList) {
                    if (iterator.forwards.block is block) {
                        foundBlockForwards = true;
                        assert(iterator.forwards.offsetIntoBlock <= block.length);
                    }

                    if (iterator.backwards.block is block) {
                        foundBlockBackwards = true;
                        assert(iterator.backwards.offsetIntoBlock <= block.length);
                    }
                }

                assert(foundBlockForwards);
                assert(foundBlockBackwards);
                assert(iterator.forwards.offsetFromHead == offsetFromHead);
            }
        }

        // [ a, b, c, d ] [ e ] [ f ] remove e and f
        test(offsetOf[0], Expected[0][0 .. expectedLengths[0]], iterator1);

        // suffix no prefix
        // [ a, b, c, d ] remove a
        test(offsetOf[1], Expected[1][0 .. expectedLengths[1]], iterator2);

        // suffix with prefix
        // [ b, c, d ] remove c
        test(offsetOf[2], Expected[2][0 .. expectedLengths[2]], iterator3);

        // no suffix with prefix
        // [ b, d ] remove d
        test(offsetOf[3], Expected[2][0 .. expectedLengths[3]], iterator4);

        // no suffix no prefix
        // [ b ] remove b
        test(offsetOf[4], null, iterator5);

        {
            // verify & cleanup iterators
            foreach (iterator; [iterator1, iterator2, iterator3, iterator4, iterator5, iterator6]) {
                assert(iterator.forwards.block is &opTest.blockList.head);
                assert(iterator.forwards.offsetIntoBlock == 0);
                assert(iterator.forwards.offsetFromHead == 0);
                assert(iterator.backwards.block is &opTest.blockList.head);
                assert(iterator.backwards.offsetIntoBlock == 0);
                assert(iterator.backwards.offsetFromHead == 0);

                opTest.iteratorList.rcIteratorInternal(false, iterator);
            }
        }
    }

    size_t insertOperation(scope Iterator* iterator, scope ref Cursor cursor, scope ref OtherStateAsTarget!Char toInsert,
            bool clobber = false) {
        size_t maximumOffsetFromHead = blockList.numberOfItems;

        if (iterator !is null)
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;

        return insertOperation(cursor, maximumOffsetFromHead, toInsert, clobber);
    }

    // advances to end of inserted content
    size_t insertOperation(scope ref Cursor cursor, size_t maximumOffsetFromHead,
            scope ref OtherStateAsTarget!Char toInsert, bool clobber = false) {
        size_t amountInserted = toInsert.length(), amountToInsert = amountInserted, startOffsetFromHead = cursor.offsetFromHead;

        {
            // sanitize cursor locations (head/tail) to ensure we have a place to actually store stuff

            if (cursor.block.next is null) {
                // is tail oh noes...
                cursor.moveFromTail;
                // could be head, but we handle that in next statement.
                assert(cursor.block.next !is null);
            }

            if (cursor.block.previous is null) {
                // is head oh noes...

                // don't forget to check if next is tail
                if (cursor.block.next !is null && cursor.block.next.next !is null && cursor.block.next.length < BlockList.Count) {
                    // move into next block
                    cursor.advanceForward(0, maximumOffsetFromHead, true);
                    assert(cursor.block.length > 0);
                } else {
                    // create new block, move into it
                    Block* newBlock = blockList.insert(cursor.block);
                    cursor.advanceForward(1, maximumOffsetFromHead, true);

                    assert(cursor.offsetIntoBlock == 0);
                    assert(cursor.block is newBlock);
                    assert(cursor.block.length == 0);
                    assert(cursor.block.previous !is null);
                }
            }

            // cannot be at head or tail at this point
            assert(cursor.block.previous !is null);
            assert(cursor.block.next !is null);
        }

        foreach (iterator; iteratorList) {
            // prevent all cursors from being at the tail node
            iterator.moveCursorsFromTail;
        }

        void ensureNotInFullBlock() {
            if (cursor.block.length == BlockList.Count) {
                // we are maxed out, oh noes

                if (cursor.offsetIntoBlock == BlockList.Count) {
                    // at end of the current block,
                    // new block time!
                    Block* newBlock = blockList.insert(cursor.block);
                    cursor.block = newBlock;
                    cursor.offsetIntoBlock = 0;
                } else {
                    // split everything at and to the right
                    Block* splitInto = blockList.insert(cursor.block);
                    cursor.block.moveFromInto(cursor.offsetIntoBlock, cursor.block.length - cursor.offsetIntoBlock, splitInto, 0);

                    assert(cursor.offsetIntoBlock == cursor.block.length);
                    assert(splitInto.length == BlockList.Count - cursor.offsetIntoBlock);
                }
            }
        }

        toInsert.foreachContiguous((scope ref Char[] cA) @trusted {
            // clobbering only
            {
                if (cursor.offsetFromHead >= maximumOffsetFromHead)
                    clobber = false;

                if (clobber) {
                    size_t canDo = maximumOffsetFromHead - cursor.offsetFromHead;
                    if (canDo > cA.length)
                        canDo = cA.length;

                    while (cA.length > 0 && canDo > 0) {
                        size_t canDoBlock = canDo;
                        if (canDoBlock > cursor.block.length - cursor.offsetIntoBlock)
                            canDoBlock = cursor.block.length - cursor.offsetIntoBlock;

                        if (canDoBlock == 0)
                            break;

                        Char[] got = cursor.block.get()[cursor.offsetIntoBlock .. $];

                        onRemove(got[0 .. canDoBlock]);
                        foreach (i, c; cA[0 .. canDoBlock])
                            got[i] = c;

                        onInsert(cA[0 .. canDoBlock]);
                        cA = cA[canDoBlock .. $];

                        assert(amountToInsert >= canDoBlock);
                        canDo -= canDoBlock;
                        cursor.advanceForward(canDoBlock, maximumOffsetFromHead, false);

                        amountToInsert -= canDoBlock;
                        amountInserted -= canDoBlock;
                        startOffsetFromHead += canDoBlock;
                    }

                    if (cA.length > 0)
                        clobber = false;
                }
            }

            // insertion only
            {
                assert(cA.length == 0 || !clobber);

                while (cA.length > 0) {
                    ensureNotInFullBlock;

                    {
                        size_t canDo = BlockList.Count - cursor.block.length;
                        if (canDo > cA.length)
                            canDo = cA.length;
                        assert(canDo > 0);

                        if (cursor.offsetIntoBlock < cursor.block.length) {
                            // oh noes, there stuff on the right!
                            const oldOffsetInBlock = cursor.offsetIntoBlock, newOffsetInBlock = cursor.offsetIntoBlock + canDo;
                            cursor.block.moveRight(oldOffsetInBlock, newOffsetInBlock);
                        } else
                            cursor.block.length += canDo;

                        assert(cursor.block.length <= BlockList.Count);

                        Char[] got = cursor.block.get()[cursor.offsetIntoBlock .. $];
                        assert(got.length >= canDo);
                        assert(cA.length >= canDo);

                        foreach (i, c; cA[0 .. canDo])
                            got[i] = c;

                        onInsert(cA[0 .. canDo]);

                        cA = cA[canDo .. $];
                        assert(amountToInsert >= canDo);
                        amountToInsert -= canDo;

                        maximumOffsetFromHead += canDo;
                        blockList.numberOfItems += canDo;

                        size_t oldOffsetFromHead = cursor.offsetFromHead;
                        cursor.advanceForward(canDo, maximumOffsetFromHead, false);
                        assert(cursor.offsetFromHead == oldOffsetFromHead + canDo);
                    }
                }
            }

            return 0;
        });

        if (amountInserted > 0) {
            foreach (iterator; iteratorList) {
                iterator.onInsertIncreaseFromHead(startOffsetFromHead, amountInserted);
            }
        }

        // brings it back into data if it needs to be
        cursor.advanceForward(0, maximumOffsetFromHead, true);

        assert(cursor.offsetIntoBlock < cursor.block.length || cursor.offsetFromHead == maximumOffsetFromHead);
        return amountInserted;
    }

    unittest {
        enum FullCount = BlockList.Count;
        enum HalfCount = BlockList.Count / 2;

        Char[BlockList.Count] FullText1, HalfText1, HalfText2, FullText2;
        foreach (i, ref c; FullText1)
            c = (i % 26) + 'A';
        foreach (i, ref c; HalfText1)
            c = (i % 13) + 'a';
        foreach (i, ref c; HalfText2)
            c = 'z' - (i % 13);
        foreach (i, ref c; FullText2)
            c = 'Z' - (i % 26);

        Char[FullCount * 3] Against2, Against3, Against4;

        foreach (i, ref c; Against2) {
            if (i >= FullCount)
                c = ((i - HalfCount) % 26) + 'A';
            else if (i >= HalfCount)
                c = ((i - HalfCount) % 13) + 'a';
            else
                c = (i % 26) + 'A';
        }

        foreach (i, ref c; Against3) {
            if (i >= FullCount + HalfCount)
                c = 'z' - ((i - (FullCount + HalfCount)) % 13);
            else if (i >= FullCount)
                c = ((i - HalfCount) % 26) + 'A';
            else if (i >= HalfCount)
                c = ((i - HalfCount) % 13) + 'a';
            else
                c = (i % 26) + 'A';
        }

        foreach (i, ref c; Against4) {
            if (i >= FullCount * 2)
                c = 'Z' - ((i - (FullCount * 2)) % 26);
            else if (i >= FullCount + HalfCount)
                c = 'z' - ((i - (FullCount + HalfCount)) % 13);
            else if (i >= FullCount)
                c = ((i - HalfCount) % 26) + 'A';
            else if (i >= HalfCount)
                c = ((i - HalfCount) % 13) + 'a';
            else
                c = (i % 26) + 'A';
        }

        OpTest!Char opTest = OpTest!Char(globalAllocator());
        opTest.Iterator* iterator1, iterator2, iterator3, iterator4;

        void test(size_t offsetFromHead, scope Char[] input, scope Char[] expected, scope out opTest.Iterator* iterator) @trusted {
            assert(offsetFromHead <= opTest.blockList.numberOfItems);
            iterator = opTest.newIterator(null, offsetFromHead, opTest.blockList.numberOfItems);

            opTest.Cursor cursor = iterator.forwards;

            {
                scope opTest.LiteralAsTarget literalAsTarget;
                literalAsTarget.literal = input;
                scope osat = literalAsTarget.get;

                size_t originalLength = opTest.blockList.numberOfItems, amountInserted = opTest.insertOperation(iterator, cursor, osat);
                assert(amountInserted + originalLength == opTest.blockList.numberOfItems);
            }

            {
                scope opTest.LiteralMatcher literalMatcher;
                literalMatcher.literal = expected;

                opTest.Cursor literalCursor;
                literalCursor.setup(&opTest.blockList, 0);

                bool matched = literalMatcher.matches(literalCursor, opTest.blockList.numberOfItems);

                assert(matched);
                assert(opTest.blockList.numberOfItems == expected.length);
            }
        }

        // test insert at head
        test(0, FullText1[], FullText1, iterator1);
        // test insert Count / 2 at Count / 2
        test(HalfCount, HalfText1[0 .. HalfCount], Against2[0 .. HalfCount + FullCount], iterator2);
        // test insert Count / 2 at Count * 1.5
        test(FullCount + HalfCount, HalfText2[0 .. HalfCount], Against3[0 .. FullCount * 2], iterator3);
        // test insert at tail
        test(FullCount + FullCount, FullText2[], Against4[], iterator4);

        // cleanup iterators
        opTest.iteratorList.rcIteratorInternal(false, iterator1);
        opTest.iteratorList.rcIteratorInternal(false, iterator2);
        opTest.iteratorList.rcIteratorInternal(false, iterator3);
        opTest.iteratorList.rcIteratorInternal(false, iterator4);
    }

    @trusted unittest {
        enum StartText = cast(Char[])"Hello, world!Hello, world!Hello, world!Hello, world!";
        enum ReplaceFor = cast(Char[])"stop it";
        enum Result = cast(Char[])"Hello, world!Hello, world!Hello, stop itHello, world!";
        enum Offset = 33;
        enum Max = 39;

        OpTest!Char opTest = OpTest!Char(globalAllocator());

        {
            opTest.Cursor insertCursor;
            opTest.LiteralAsTarget lAT;
            lAT.literal = StartText;
            scope target = lAT.get();

            insertCursor.setup(&opTest.blockList, 0);
            opTest.insertOperation(null, insertCursor, target);
        }

        {
            opTest.Cursor cursor;
            cursor.setup(&opTest.blockList, Offset);

            scope opTest.LiteralAsTarget literalAsTarget;
            literalAsTarget.literal = ReplaceFor;
            scope osat = literalAsTarget.get;

            opTest.insertOperation(cursor, Max, osat, true);
        }

        {
            scope opTest.LiteralMatcher literalMatcher;
            literalMatcher.literal = cast(Char[])Result;

            opTest.Cursor literalCursor;
            literalCursor.setup(&opTest.blockList, 0);

            bool matched = literalMatcher.matches(literalCursor, opTest.blockList.numberOfItems);
            assert(matched);
            assert(opTest.blockList.numberOfItems == Result.length);
        }
    }

    size_t replaceOperation(scope Iterator* iterator, scope ref Cursor cursor, scope size_t delegate(scope Cursor,
            size_t maximumOffsetFromHead) @safe nothrow @nogc isToFind, scope size_t delegate(scope Iterator* iterator,
            scope ref Cursor) @safe nothrow @nogc onMatch, bool doRemove = true, bool onceOnly = false) {
        size_t count, maximumOffsetFromHead = blockList.numberOfItems;

        if (iterator !is null) {
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        while (!cursor.isOutOfRange(0, maximumOffsetFromHead)) {
            // Unfortunately this is required when doing insert then remove.
            // The remove does not guarantee that it'll point to data
            if (doRemove)
                cursor.advanceForward(0, maximumOffsetFromHead, true);

            size_t matchedAmount = isToFind(cursor, maximumOffsetFromHead);
            if (matchedAmount > 0) {
                count++;

                // Do matching before removal, this is needed if you are inserting
                //  you can end up with iterators that no longer point to the same
                //  effective range.
                // By doing insert first you increase range, and only then decrease
                //  to the desired range.
                if (onMatch !is null) {
                    maximumOffsetFromHead += onMatch(iterator, cursor);
                }

                if (doRemove) {
                    removeOperation(iterator, cursor, matchedAmount);
                    maximumOffsetFromHead -= matchedAmount;
                }

                if (onceOnly)
                    return count;
            } else
                cursor.advanceForward(1, maximumOffsetFromHead, true);
        }

        return count;
    }

    @trusted unittest {
        enum StartText = cast(Char[])"Hello, world!Hello, world!Hello, world!Hello, world!";
        enum Result = cast(Char[])"Hezzo, worzdzHezzo, worzdzHezzo, worzdzHezzo, worzdz";

        OpTest!Char opTest = OpTest!Char(globalAllocator());

        {
            opTest.Cursor insertCursor;
            opTest.LiteralAsTarget lAT;
            lAT.literal = StartText;
            scope target = lAT.get();

            insertCursor.setup(&opTest.blockList, 0);
            opTest.insertOperation(null, insertCursor, target);
        }

        opTest.Iterator* iterator = opTest.newIterator();
        assert(iterator.maximumOffsetFromHead == StartText.length);

        {
            opTest.Cursor replaceCursor;
            replaceCursor.setup(&opTest.blockList, 0);

            size_t matched = opTest.replaceOperation(null, replaceCursor, (scope opTest.Cursor cursor, size_t maximumOffsetFromHead) {
                return cast(size_t)((cursor.get() == 'l' || cursor.get() == '!') ? 1 : 0);
            }, (scope opTest.Iterator* iterator, scope ref opTest.Cursor cursor) @trusted {
                opTest.LiteralAsTarget lAT;
                lAT.literal = cast(Char[])"z";
                scope target = lAT.get();

                opTest.insertOperation(null, cursor, target);
                return cast(size_t)1;
            });
            assert(matched == 16);
        }

        {
            scope opTest.LiteralMatcher literalMatcher;
            literalMatcher.literal = cast(Char[])Result;

            opTest.Cursor literalCursor;
            literalCursor.setup(&opTest.blockList, 0);

            bool matched = literalMatcher.matches(literalCursor, opTest.blockList.numberOfItems);
            assert(matched);
            assert(opTest.blockList.numberOfItems == Result.length);
        }

        assert(iterator.maximumOffsetFromHead == Result.length);
        opTest.rcIterator(false, iterator);
    }

    @trusted unittest {
        enum StartText = cast(Char[])"llll";
        enum Result = cast(Char[])"zzzz";

        OpTest!Char opTest = OpTest!Char(globalAllocator());

        {
            opTest.Cursor insertCursor;
            opTest.LiteralAsTarget lAT;
            lAT.literal = StartText;
            scope target = lAT.get();

            insertCursor.setup(&opTest.blockList, 0);
            opTest.insertOperation(null, insertCursor, target);
        }

        opTest.Iterator* iterator = opTest.newIterator();
        assert(iterator.maximumOffsetFromHead == StartText.length);

        {
            opTest.Cursor replaceCursor;
            replaceCursor.setup(&opTest.blockList, 0);

            size_t matched = opTest.replaceOperation(null, replaceCursor, (scope opTest.Cursor cursor, size_t maximumOffsetFromHead) {
                return cast(size_t)(cursor.get() == 'l' ? 1 : 0);
            }, (scope opTest.Iterator* iterator, scope ref opTest.Cursor cursor) @trusted {
                opTest.LiteralAsTarget lAT;
                lAT.literal = cast(Char[])"z";
                scope target = lAT.get();

                opTest.insertOperation(null, cursor, target);
                return cast(size_t)1;
            });
            assert(matched == 4);
        }

        {
            scope opTest.LiteralMatcher literalMatcher;
            literalMatcher.literal = cast(Char[])Result;

            opTest.Cursor literalCursor;
            literalCursor.setup(&opTest.blockList, 0);

            bool matched = literalMatcher.matches(literalCursor, opTest.blockList.numberOfItems);
            assert(matched);
            assert(opTest.blockList.numberOfItems == Result.length);
        }

        assert(iterator.maximumOffsetFromHead == Result.length);
        opTest.rcIterator(false, iterator);
    }
}

struct OtherStateAsTarget(TargetChar) {
    void* obj;

    void delegate(bool lockNotUnlock) @safe @nogc nothrow mutex;
    int delegate(scope int delegate(scope ref  /* ignore this */ TargetChar[] data) @safe @nogc nothrow del) @safe @nogc nothrow foreachContiguous;
    int delegate(scope int delegate(ref  /* ignore this */ TargetChar) @safe @nogc nothrow del) @safe @nogc nothrow foreachValue;
    size_t delegate() @safe nothrow @nogc length;

    bool isNull() @safe nothrow @nogc {
        return obj is null;
    }
}

alias OpTb = OpTest!ubyte;
alias OpTc = OpTest!char;
alias OpTw = OpTest!wchar;
alias OpTd = OpTest!dchar;

struct OpTest(Char) {
    alias CustomIteratorContents = void;
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

    void onInsert(scope const Char[]) scope {
    }

    void onRemove(scope const Char[]) scope {
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

    static struct LiteralAsTarget {
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
}
