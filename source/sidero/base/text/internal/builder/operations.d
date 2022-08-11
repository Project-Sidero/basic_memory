module sidero.base.text.internal.builder.operations;
import sidero.base.text.internal.builder.iteratorlist;
import sidero.base.text.internal.builder.blocklist;
import sidero.base.allocators;

mixin template StringBuilderOperations() {
    alias BlockList = BlockListImpl!Char;

    BlockList blockList;

    IteratorListImpl!Char iteratorList;
    alias Iterator = iteratorList.Iterator;
    alias Cursor = iteratorList.Cursor;
    alias Block = BlockList.Block;

@safe nothrow @nogc:

    void rc(bool addRef) {
        blockList.mutex.pureLock;
        if (this.rcInternal(addRef))
            blockList.mutex.unlock;
    }

    void rcIterator(bool addRef, scope Iterator* iterator) {
        assert(iterator !is null);
        blockList.mutex.pureLock;

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
            assert(blockList.head.next is null);

            allocator.dispose(&this);
            return false;
        } else
            blockList.refCount--;

        return true;
    }

    Iterator* newIterator(scope Iterator* iterator = null, size_t minimumOffsetFromHead = 0, size_t maximumOffsetFromHead = size_t.max) {
        if (iterator !is null) {
            minimumOffsetFromHead += iterator.minimumOffsetFromHead;

            if (maximumOffsetFromHead == size_t.max)
                maximumOffsetFromHead = iterator.maximumOffsetFromHead;
            else
                maximumOffsetFromHead += iterator.minimumOffsetFromHead;
        }

        return iteratorList.newIterator(&blockList, minimumOffsetFromHead, maximumOffsetFromHead);
    }

    // keeps position the same position
    void removeOperation(scope Iterator* iterator, scope ref Cursor cursor, size_t amount) {
        size_t minimumOffsetFromHead = 0, maximumOffsetFromHead = blockList.numberOfItems;

        if (iterator !is null) {
            minimumOffsetFromHead = iterator.minimumOffsetFromHead;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        if (cursor.offsetFromHead + amount > maximumOffsetFromHead) {
            assert(cursor.offsetFromHead < maximumOffsetFromHead);
            amount = maximumOffsetFromHead - cursor.offsetFromHead;
        }

        // nothing to do
        if (minimumOffsetFromHead == maximumOffsetFromHead || amount == 0)
            return;

        size_t amountRemoved = amount;

        //debugPosition(cursor);
        foreach (iterator; iteratorList) {
            iterator.onRemoveDecreaseFromHead(cursor.offsetFromHead, amount);
        }

        if (cursor.offsetIntoBlock == 0) {
            cursor.advanceBackwards(0, cursor.offsetFromHead, maximumOffsetFromHead, false);
            assert(cursor.offsetIntoBlock == cursor.block.length);
            assert(cursor.block.next !is null);
        }

        while (amount > 0) {
            Block* block = cursor.block;
            size_t offsetIntoBlock = cursor.offsetIntoBlock, offsetFromHead = cursor.offsetFromHead;

            if (offsetIntoBlock == block.length) {
                block = block.next;
                offsetIntoBlock = 0;
                assert(block.next !is null);
            }

            size_t canDo = block.length - offsetIntoBlock;
            if (canDo > amount)
                canDo = amount;

            //debugPosition(block, offsetIntoBlock);

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

        Iterator* iterator1, iterator2, iterator3, iterator4, iterator5, iterator6;
        iterator6 = opTest.newIterator(null, opTest.blockList.numberOfItems, opTest.blockList.numberOfItems);

        void test(size_t offsetFromHead, scope Char[] expected, return ref Iterator* iterator) @trusted {
            iterator = opTest.newIterator(null, offsetFromHead, offsetFromHead + expected.length);

            Cursor cursor = iterator.forwards;
            opTest.removeOperation(null, cursor, opTest.blockList.numberOfItems - expected.length);

            {
                scope LiteralMatcher literalMatcher;
                literalMatcher.literal = expected;

                Cursor literalCursor;
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

    // advances to end of inserted content
    size_t insertOperation(scope Iterator* iterator, scope ref Cursor cursor, scope ref OtherStateAsTarget!Char toInsert) {
        const amountInserted = toInsert.length();
        size_t amountToInsert = amountInserted, startOffsetFromHead = cursor.offsetFromHead, minimumOffsetFromHead = 0,
            maximumOffsetFromHead = blockList.numberOfItems;

        if (iterator !is null) {
            minimumOffsetFromHead = iterator.minimumOffsetFromHead;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        {
            // sanitize cursor locations (head/tail) to ensure we have a place to actually store stuff

            if (cursor.block.next is null) {
                // is tail oh noes...
                cursor.advanceBackwards(1, cursor.offsetFromHead, maximumOffsetFromHead, false);
                assert(cursor.offsetIntoBlock == cursor.block.length);
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

        foreach (cA; toInsert.foreachBlocks) {
            while (cA.length > 0) {
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

                {
                    size_t canDo = BlockList.Count - cursor.offsetIntoBlock;
                    if (canDo > cA.length)
                        canDo = cA.length;
                    assert(canDo > 0);

                    if (cursor.offsetIntoBlock + 1 < cursor.block.length) {
                        // oh noes, there stuff on the right!
                        const oldOffsetInBlock = cursor.offsetIntoBlock, newOffsetInBlock = cursor.offsetIntoBlock + canDo;
                        cursor.block.moveRight(oldOffsetInBlock, newOffsetInBlock);
                    } else
                        cursor.block.length += canDo;

                    Char[] got = cursor.block.get()[cursor.offsetIntoBlock .. $];
                    foreach (i, c; cA[0 .. canDo])
                        got[i] = c;

                    cA = cA[canDo .. $];
                    assert(amountToInsert >= canDo);
                    amountToInsert -= canDo;

                    maximumOffsetFromHead += canDo;
                    cursor.advanceForward(canDo, maximumOffsetFromHead, false);
                    blockList.numberOfItems += canDo;
                }
            }
        }

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
        Iterator* iterator1, iterator2, iterator3, iterator4;

        void test(size_t offsetFromHead, scope Char[] input, scope Char[] expected, scope out Iterator* iterator) @trusted {
            assert(offsetFromHead <= opTest.blockList.numberOfItems);
            iterator = opTest.newIterator(null, offsetFromHead, opTest.blockList.numberOfItems);

            Cursor cursor = iterator.forwards;

            {
                scope LiteralAsTarget literalAsTarget;
                literalAsTarget.literal = input;
                scope osat = literalAsTarget.get;

                size_t originalLength = opTest.blockList.numberOfItems, amountInserted = opTest.insertOperation(iterator, cursor, osat);
                assert(amountInserted + originalLength == opTest.blockList.numberOfItems);
            }

            {
                scope LiteralMatcher literalMatcher;
                literalMatcher.literal = expected;

                Cursor literalCursor;
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

    size_t replaceOperation(scope Iterator* iterator, scope ref Cursor cursor, scope size_t delegate(scope Cursor,
            size_t maximumOffsetFromHead) @safe nothrow @nogc isToFind, scope size_t delegate(scope Iterator* iterator,
            scope ref Cursor) @safe nothrow @nogc onMatch, bool doRemove = true, bool onceOnly = false) {
        size_t count, maximumOffsetFromHead = blockList.numberOfItems;

        if (iterator !is null) {
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        while (!cursor.isEmpty(0, maximumOffsetFromHead)) {
            size_t matchedAmount = isToFind(cursor, maximumOffsetFromHead);

            if (matchedAmount > 0) {
                count++;

                if (doRemove) {
                    removeOperation(iterator, cursor, matchedAmount);
                    maximumOffsetFromHead -= matchedAmount;
                }

                if (onMatch !is null) {
                    maximumOffsetFromHead += onMatch(iterator, cursor);
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
        enum Result = cast(Char[])"Hezzo, worzd!Hezzo, worzd!Hezzo, worzd!Hezzo, worzd!";

        OpTest!Char opTest = OpTest!Char(globalAllocator());

        {
            Cursor insertCursor;
            opTest.LiteralAsTarget lAT;
            lAT.literal = StartText;
            scope target = lAT.get();

            insertCursor.setup(&opTest.blockList, 0);
            opTest.insertOperation(null, insertCursor, target);
        }

        {
            Cursor replaceCursor;
            replaceCursor.setup(&opTest.blockList, 0);

            size_t matched = opTest.replaceOperation(null, replaceCursor, (scope Cursor cursor, size_t maximumOffsetFromHead) {
                return cast(size_t)(cursor.get() == 'l' ? 1 : 0);
            }, (scope Iterator* iterator, scope ref Cursor cursor) @trusted {
                opTest.LiteralAsTarget lAT;
                lAT.literal = cast(Char[])"z";
                scope target = lAT.get();

                opTest.insertOperation(null, cursor, target);
                return cast(size_t)1;
            });
            assert(matched == 12);
        }

        {
            scope LiteralMatcher literalMatcher;
            literalMatcher.literal = cast(Char[])Result;

            Cursor literalCursor;
            literalCursor.setup(&opTest.blockList, 0);

            bool matched = literalMatcher.matches(literalCursor, opTest.blockList.numberOfItems);
            assert(matched);
            assert(opTest.blockList.numberOfItems == Result.length);
        }
    }
}

private:

alias OpTb = OpTest!ubyte;
alias OpTc = OpTest!char;
alias OpTw = OpTest!wchar;
alias OpTd = OpTest!dchar;

struct OpTest(Char) {
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
                    if (block is iterator.forwards.block)
                        write(iterator.forwards.offsetIntoBlock, ">");
                    writef!"%s:%X@(%s)"(offsetFromHead, block, *block);
                    if (block is iterator.backwards.block)
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

    static struct LiteralMatcher {
        const(Char)[] literal;

        bool matches(scope Cursor cursor, size_t maximumOffsetFromHead) {
            auto temp = literal;

            while (!cursor.isEmpty(0, maximumOffsetFromHead) && temp.length > 0) {
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

            while (!cursor.isEmpty(0, maximumOffsetFromHead) && temp.length > 0) {
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

        int foreachBlocks(scope int delegate(ref Char[] data) @safe @nogc nothrow del) @trusted @nogc nothrow {
            // don't mutate during testing
            Char[] temp = cast(Char[])literal;
            return del(temp);
        }

        int foreachValue(scope int delegate(ref Char) @safe @nogc nothrow del) @safe @nogc nothrow {
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
            return OtherStateAsTarget!Char(cast(void*)literal.ptr, &mutex, &foreachBlocks, &foreachValue, &length);
        }
    }
}

struct OtherStateAsTarget(TargetChar) {
    void* obj;

    void delegate(bool lockNotUnlock) @safe @nogc nothrow mutex;
    int delegate(scope int delegate(ref TargetChar[] data) @safe @nogc nothrow del) @safe @nogc nothrow foreachBlocks;
    int delegate(scope int delegate(ref TargetChar) @safe @nogc nothrow del) @safe @nogc nothrow foreachValue;
    size_t delegate() @safe nothrow @nogc length;

    bool isNull() @safe nothrow @nogc {
        return obj is null;
    }
}
