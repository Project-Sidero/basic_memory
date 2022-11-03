module sidero.base.containers.list.ConcurrentLinkedList;
import sidero.base.containers.readonlyslice;
import sidero.base.allocators;
import sidero.base.traits;
import sidero.base.errors;

private {
    alias CLLI = ConcurrentLinkedList!int;
}

///
struct ConcurrentLinkedList(Type) {
    private {
        ConcurrentLinkedListImpl!(Type)* state;
        typeof(state).Iterator* iterator;

        // TODO: opApplyImpl
        // TODO: opApplyReverseImpl
    }

    // FIXME: actually no, its not Type, its a wrapper around it!
    alias ElementType = Type;
    ///
    alias LiteralType = const(Type)[];

nothrow @nogc:

    ///
    ConcurrentLinkedList opSlice() scope @trusted {
        setupState;

        ConcurrentLinkedList ret;
        ret.tupleof = this.tupleof;

        if (!isNull)
            ret.iterator = state.createIteratorExternal(iterator);

        return ret;
    }

    unittest {
        ConcurrentLinkedList ll = ConcurrentLinkedList(globalAllocator());
        assert(!ll.isNull);
        assert(ll.length == 0);
        assert(!ll.haveIterator());

        ConcurrentLinkedList ll2 = ll[];
        assert(ll2.length == 0);
        assert(ll2.haveIterator());
        assert(ll2.iterator.forwards.node is &ll2.state.nodeList.head);
        assert(ll2.iterator.backwards.node is &ll.state.nodeList.tail);
    }

    ///
    ConcurrentLinkedList opSlice(ptrdiff_t start, ptrdiff_t end) scope @trusted {
        setupState;

        ConcurrentLinkedList ret;
        ret.tupleof = this.tupleof;

        if (!isNull)
            ret.iterator = state.createIteratorExternal(iterator, start, end);

        return ret;
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll.insert(0, Type.init, Type.init, Type.init);
        assert(cll.length == 3);

        ConcurrentLinkedList cll2 = cll[1 .. -1];
        assert(cll2.length == 1);
    }

@safe:

    ///
    ConcurrentLinkedList withoutIterator() {
        ConcurrentLinkedList ret;
        ret.state = this.state;

        if (state !is null)
            state.rcExternal(true, null);

        return ret;
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll.insert(0, Type.init, Type.init, Type.init);
        assert(cll.length == 3);

        ConcurrentLinkedList cll2 = cll[1 .. -1];
        assert(cll2.length == 1);
        assert(cll2.withoutIterator.tupleof == cll.tupleof);
    }

    ///
    void opAssign(scope Type[] value...) scope @trusted {
        this = ConcurrentLinkedList(value);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll = Type.init;
    }

    ///
    this(ref return scope ConcurrentLinkedList other) @trusted scope {
        import core.atomic : atomicOp;

        this.tupleof = other.tupleof;

        if (!isNull)
            state.rcExternal(true, iterator);
    }

    ///
    unittest {
        ConcurrentLinkedList original = ConcurrentLinkedList(globalAllocator());
        ConcurrentLinkedList copied = original;
    }

    @disable this(ref return scope const ConcurrentLinkedList other) scope const;
    @disable this(this) scope;

    @trusted {
        ///
        this(RCAllocator allocator, RCAllocator valueAllocator = RCAllocator.init) scope {
            if (allocator.isNull)
                allocator = globalAllocator();

            state = allocator.make!(ConcurrentLinkedListImpl!Type)(allocator, valueAllocator);
        }

        ///
        this(scope Type[] input, RCAllocator allocator = RCAllocator.init, RCAllocator valueAllocator = RCAllocator.init) scope {
            this(allocator, valueAllocator);

            foreach (i, ref v; input) {
                state.insertExternal(iterator, i, v);
            }
        }

        ///
        unittest {
            static Values = [Type.init];
            ConcurrentLinkedList ll = ConcurrentLinkedList(Values);
            assert(!ll.isNull);
            assert(ll.length == Values.length);
        }
    }

    ~this() {
        if (!isNull)
            state.rcExternal(false, iterator);
    }

    ///
    bool isNull() {
        return this.state is null;
    }

    ///
    bool haveIterator() scope {
        return this.iterator !is null;
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope {
        if (isNull)
            return 0;
        else
            return state.lengthExternal(iterator);
    }

    ///
    unittest {
        ConcurrentLinkedList ll = ConcurrentLinkedList(globalAllocator());
        assert(!ll.isNull);
        assert(ll.length == 0);
    }

    ///
    Slice!Type asReadOnly(RCAllocator allocator = RCAllocator.init) scope {
        if (isNull)
            return typeof(return).init;

        if (allocator.isNull)
            allocator = globalAllocator();

        return state.asReadOnlyExternal(iterator, allocator);
    }

    ///
    unittest {
        static Values = [Type.init, Type.init];
        ConcurrentLinkedList ll = ConcurrentLinkedList(Values);

        auto slice = ll.asReadOnly;
        assert(slice.length == 2);
        assert(slice[0] == Values[0]);
        assert(slice[1] == Values[1]);
    }

    ///
    ConcurrentLinkedList!Type dup(RCAllocator allocator = RCAllocator.init) scope {
        if (isNull)
            return typeof(return).init;

        if (allocator.isNull)
            allocator = globalAllocator();

        return state.dupExternal(iterator, allocator);
    }

    ///
    unittest {
        static Values = [Type.init, Type.init];
        ConcurrentLinkedList ll = ConcurrentLinkedList(Values);

        auto ll2 = ll.dup;
        assert(ll2.length == 2);
        assert(ll2[0] == Values[0]);
        assert(ll2[1] == Values[1]);
    }

    ///
    ResultReference!Type opIndex(ptrdiff_t index) scope {
        if (isNull)
            return ResultReference!Type(NullPointerException);

        return state.indexExternal(iterator, index);
    }

    @disable auto opCast(T)();

    // TODO: alias equals = opEquals;
    // TODO: opEquals;

    // TODO: alias compare = opCmp;
    // TODO: opCmp

    @property {
        // TODO: empty
        // TODO: front
        // TODO: back
        // TODO: put
    }

    // TODO: popFront
    // TODO: popBack

    // TODO: startsWith
    // TODO: endsWith
    // TODO: indexOf
    // TODO: lastIndexOf
    // TODO: count
    // TODO: contains

    ///
    void clear() scope {
        if (isNull)
            return;

        state.clearExternal(iterator);
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);

        ConcurrentLinkedList cll2 = cll[1 .. $ - 1];
        assert(cll2.length == 2);

        cll2.clear;
        assert(cll.length == 2);
        assert(cll2.length == 0);
    }

    ///
    void insert(Input)(ptrdiff_t index, scope Input input) scope if (HaveOpApply!(Input, Type)) {
        this.insert(index, GetOpApply!Type(input));
    }

    ///
    unittest {
        struct Thing {
            int opApply(scope int delegate(ref Type) @safe nothrow @nogc del) @safe nothrow @nogc {
                Type temp;
                return del(temp);
            }
        }

        ConcurrentLinkedList cll;
        Thing thing;

        cll.insert(1, thing);
        assert(cll.length == 1);
        cll.insert(-1, thing);
        assert(cll.length == 2);
    }

    /// Takes in an opApply
    void insert(ptrdiff_t index, scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) scope {
        setupState;

        state.insertExternal(iterator, index, del);
    }

    ///
    unittest {
        int handle(scope int delegate(ref Type) @safe nothrow @nogc del) @safe nothrow @nogc {
            Type temp;
            return del(temp);
        }

        ConcurrentLinkedList cll;
        cll.insert(1, &handle);
        assert(cll.length == 1);
        cll.insert(-1, &handle);
        assert(cll.length == 2);
    }

    ///
    void insert(ptrdiff_t index, scope Type[] input...) scope {
        setupState;

        foreach_reverse (i, ref v; input)
            state.insertExternal(iterator, index, v);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll.insert(1, Type.init);
        assert(cll.length == 1);
        cll.insert(-1, Type.init);
        assert(cll.length == 2);
    }

    /// Takes in an opApply
    void prepend(scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) scope {
        setupState;

        state.insertExternal(iterator, 0, del);
    }

    ///
    void prepend(scope Type[] input...) scope {
        setupState;

        foreach_reverse (i, ref v; input)
            state.insertExternal(iterator, 0, v);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll.prepend(Type.init);
        cll.prepend(Type.init);
        assert(cll.length == 2);
    }

    /// Takes in an opApply
    void append(scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) scope {
        setupState;

        state.insertExternal(iterator, ptrdiff_t.max, del);
    }

    ///
    void opOpAssign(string s : "~")(scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) scope {
        this.append(del);
    }

    ///
    void append(scope Type[] input...) scope {
        setupState;

        foreach_reverse (i, ref v; input)
            state.insertExternal(iterator, ptrdiff_t.max, v);
    }

    ///
    void opOpAssign(string s : "~")(scope Type[] input...) scope {
        this.append(input);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll ~= Type.init;
        cll ~= Type.init;
        assert(cll.length == 2);
    }

    ///
    void remove(scope Type value) scope {
        if (isNull)
            return;

        state.removeExternal(iterator, value);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll ~= Type.init;
        cll ~= Type.init;
        cll ~= Type.init;
        assert(cll.length == 3);

        cll[1 .. 2].remove(Type.init);
        assert(cll.length == 2);

        cll.remove(Type.init);
        assert(cll.length == 0);
    }

    ///
    void remove(ptrdiff_t index, size_t count) scope {
        if (isNull)
            return;

        state.removeExternal(iterator, index, count);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll ~= Type.init;
        cll ~= Type.init;
        cll ~= Type.init;
        assert(cll.length == 3);

        cll.remove(-1, 1);
        assert(cll.length == 2);

        cll.remove(0, 2);
        assert(cll.length == 0);
    }

private:
    void setupState() scope @trusted {
        if (!isNull)
            return;

        RCAllocator allocator = globalAllocator();
        state = allocator.make!(ConcurrentLinkedListImpl!Type)(allocator, RCAllocator.init);
    }

    void debugPosition() scope {
        if (!isNull)
            state.debugPosition(iterator);
    }
}

private:
import sidero.base.parallelism.mutualexclusion : TestTestSetLockInline;
import sidero.base.traits : isAnyPointer;

struct ConcurrentLinkedListImpl(Type) {
    ConcurrentLinkedListNodeList!Type nodeList;
    ConcurrentLinkedListIteratorList!Type iteratorList;

    TestTestSetLockInline mutex;
    alias Node = typeof(nodeList).Node;
    alias Iterator = typeof(iteratorList).Iterator;
    alias Cursor = typeof(iteratorList).Cursor;

@safe nothrow @nogc:

    this(RCAllocator allocator, RCAllocator valueAllocator) scope @trusted {
        nodeList = typeof(nodeList)(allocator, valueAllocator);
    }

    void rcExternal(bool addRef, scope Iterator* iterator) scope {
        mutex.pureLock;
        if (rcInternal(addRef, iterator))
            mutex.unlock;
    }

    void rcNodeExternal(bool addRef, scope Node* node) scope {
        mutex.pureLock;

        if (node !is null) {
            if (addRef)
                node.onIteratorIn;
            else
                node.onIteratorOut;

            if (node.refCount == 0 && node.isDeleted)
                nodeList.removeNode(node);

        }
        if (rcInternal(addRef, null))
            mutex.unlock;
    }

    size_t lengthExternal(scope Iterator* iterator) scope {
        mutex.pureLock;
        size_t ret = iterator is null ? nodeList.aliveNodes : (iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead);
        mutex.unlock;
        return ret;
    }

    Iterator* createIteratorExternal(scope Iterator* iterator, ptrdiff_t minimumOffsetFromHead = 0,
            ptrdiff_t maximumOffsetFromHead = ptrdiff_t.max) scope @trusted {
        mutex.pureLock;

        changeIndexToOffset(iterator, minimumOffsetFromHead, maximumOffsetFromHead);
        Iterator* ret = iteratorList.createIterator(nodeList, minimumOffsetFromHead, maximumOffsetFromHead);

        this.rcInternal(true, ret);

        mutex.unlock;
        return ret;
    }

    void insertExternal(scope Iterator* iterator, ptrdiff_t index, ref Type value) scope {
        mutex.pureLock;

        changeIndexToOffset(iterator, index);
        Cursor cursor = iteratorList.cursorFor(nodeList, index);

        Node* current = nodeList.createNode(cursor.node);
        current.value = value;

        foreach (iterator; iteratorList) {
            iterator.forwards.onInsertIncreaseFromHead(index, 1);
            iterator.backwards.onInsertIncreaseFromHead(index, 1);
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
    }

    void insertExternal(scope Iterator* iterator, ptrdiff_t index,
            scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) scope {
        mutex.pureLock;

        changeIndexToOffset(iterator, index);
        Cursor cursor = iteratorList.cursorFor(nodeList, index);

        Node* prior = cursor.node;
        size_t count;

        foreach (ref v; del) {
            Node* current = nodeList.createNode(prior);

            current.value = v;
            count++;

            prior = current;
        }

        if (count > 0) {
            foreach (iterator; iteratorList) {
                iterator.forwards.onInsertIncreaseFromHead(index, count);
                iterator.backwards.onInsertIncreaseFromHead(index, count);
            }
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
    }

    void clearExternal(scope Iterator* iterator) scope @trusted {
        mutex.pureLock;
        size_t count = nodeList.aliveNodes, offset = 0;

        if (iterator !is null) {
            count = iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead;
            offset = iterator.minimumOffsetFromHead;
        }

        Node** currentPtr;
        {
            Cursor cursor = iteratorList.cursorFor(nodeList, offset);
            currentPtr = &cursor.node.previous.next;
            cursor.onEOL(nodeList);
        }

        foreach (iterator; iteratorList) {
            iterator.onRemoveDecreaseFromHead(offset, count, null);
        }

        while (*currentPtr !is &nodeList.tail && count > 0) {
            Node* current = *currentPtr;

            if (current.refCount == 0) {
                nodeList.removeNode(current);
            } else {
                appendDeletedNodeToList(current.next, current);
                nodeList.aliveNodes--;
            }

            count--;
        }

        mutex.unlock;
    }

    Slice!Type asReadOnlyExternal(scope Iterator* iterator, RCAllocator allocator) scope @trusted {
        assert(!allocator.isNull);
        mutex.pureLock;

        size_t count = nodeList.aliveNodes, offset = 0, maximumOffsetFromHead = count;

        if (iterator !is null) {
            count = iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead;
            offset = iterator.minimumOffsetFromHead;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        Cursor cursor = iteratorList.cursorFor(nodeList, offset);
        Type[] ret = allocator.makeArray!Type(count);
        size_t outputOffset;

        while (cursor.node !is &nodeList.tail && count > 0) {
            ret[outputOffset++] = cursor.node.value;

            cursor.advanceForwards(1, maximumOffsetFromHead);
            count--;
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
        return Slice!Type(ret, allocator);
    }

    ConcurrentLinkedList!Type dupExternal(scope Iterator* iterator, RCAllocator allocator) scope @trusted {
        assert(!allocator.isNull);
        mutex.pureLock;

        size_t count = nodeList.aliveNodes, offset = 0, maximumOffsetFromHead = count;

        if (iterator !is null) {
            count = iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead;
            offset = iterator.minimumOffsetFromHead;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        Cursor cursor = iteratorList.cursorFor(nodeList, offset);
        size_t outputOffset;
        ConcurrentLinkedList!Type ret = ConcurrentLinkedList!Type(allocator);
        Node* previous = &ret.state.nodeList.head;

        while (cursor.node !is &nodeList.tail && count > 0) {
            previous = ret.state.nodeList.createNode(previous);
            previous.value = cursor.node.value;

            cursor.advanceForwards(1, maximumOffsetFromHead);
            count--;
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
        return ret;
    }

    ResultReference!Type indexExternal(scope Iterator* iterator, ptrdiff_t index) scope @trusted {
        mutex.pureLock;

        size_t maximumOffsetFromHead = nodeList.aliveNodes;

        auto error = changeIndexToOffset(iterator, index);
        if (error.isSet)
            return typeof(return)(error);

        Cursor cursor = iteratorList.cursorFor(nodeList, index);
        ResultReference!Type ret = ResultReference!Type(&cursor.node.value, cursor.node, cast(typeof(return).RCHandle)&rcNodeExternal);

        cursor.node.onIteratorIn;
        this.rcInternal(true, null);

        cursor.onEOL(nodeList);
        mutex.unlock;
        return ret;
    }

    void removeExternal(scope Iterator* iterator, scope Type filterValue) scope @trusted {
        mutex.pureLock;
        size_t count = nodeList.aliveNodes, offset = 0;

        if (iterator !is null) {
            count = iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead;
            offset = iterator.minimumOffsetFromHead;
        }

        Node** currentPtr;
        {
            Cursor cursor = iteratorList.cursorFor(nodeList, offset);
            currentPtr = &cursor.node.previous.next;
            cursor.onEOL(nodeList);
        }

        while (*currentPtr !is &nodeList.tail && count > 0) {
            Node* current = *currentPtr;

            if (current.value == filterValue) {
                foreach (iterator; iteratorList) {
                    iterator.onRemoveDecreaseFromHead(offset, 1, null);
                }

                if (current.refCount == 0) {
                    nodeList.removeNode(current);
                } else {
                    appendDeletedNodeToList(current.next, current);
                    nodeList.aliveNodes--;
                }
            } else {
                currentPtr = &current.next;
                offset++;
            }

            count--;
        }

        mutex.unlock;
    }

    void removeExternal(scope Iterator* iterator, ptrdiff_t index, size_t countInput) scope @trusted {
        mutex.pureLock;

        size_t maximumOffsetFromHead = nodeList.aliveNodes;

        auto error = changeIndexToOffset(iterator, index);
        if (error.isSet)
            return;
        if (iterator !is null)
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;

        size_t count = maximumOffsetFromHead - index;
        if (count > countInput)
            count = countInput;

        Node** currentPtr;
        {
            Cursor cursor = iteratorList.cursorFor(nodeList, index);
            currentPtr = &cursor.node.previous.next;
            cursor.onEOL(nodeList);
        }

        foreach (iterator; iteratorList) {
            iterator.onRemoveDecreaseFromHead(index, count, null);
        }

        while (*currentPtr !is &nodeList.tail && count > 0) {
            Node* current = *currentPtr;

            if (current.refCount == 0) {
                nodeList.removeNode(current);
            } else {
                appendDeletedNodeToList(current.next, current);
                nodeList.aliveNodes--;
            }

            count--;
        }

        mutex.unlock;
    }

    bool rcInternal(bool addRef, scope Iterator* iterator) scope @trusted {
        if (addRef) {
            nodeList.refCount++;
            if (iterator !is null)
                iterator.rc(true, nodeList, iteratorList);
        } else if (nodeList.refCount == 1) {
            this.clearAllInternal;

            if (iterator !is null)
                iterator.rc(false, nodeList, iteratorList);

            assert(iteratorList.head is null);
            assert(nodeList.allNodes == 0);

            RCAllocator allocator = nodeList.allocator;
            allocator.dispose(&this);
            return false;
        } else {
            nodeList.refCount--;
            if (iterator !is null)
                iterator.rc(false, nodeList, iteratorList);
        }

        return true;
    }

    void clearAllInternal() scope @trusted {
        Node** currentPtr = &nodeList.head.next;

        foreach (iterator; iteratorList) {
            iterator.onRemoveDecreaseFromHead(0, nodeList.aliveNodes, null);
        }

        while (*currentPtr !is &nodeList.tail) {
            Node* current = *currentPtr;

            if (current.refCount == 0) {
                nodeList.removeNode(current);
            } else {
                appendDeletedNodeToList(current.next, current);
                nodeList.aliveNodes--;
            }
        }
    }

    void appendDeletedNodeToList(scope Node* parent, scope Node* toAdd) scope @trusted {
        assert(parent !is null);
        assert(!parent.isDeleted);
        assert(toAdd !is null);
        assert(!toAdd.isDeleted);

        if (toAdd.previousReadyToBeDeleted !is null)
            nodeList.mergeDeletedListToNewParent(toAdd, parent);
        assert(toAdd.previousReadyToBeDeleted is null);

        assert(toAdd.previous !is null);
        assert(toAdd.next !is null);
        toAdd.previous.next = toAdd.next;
        toAdd.next.previous = toAdd.previous;

        if (parent.previousReadyToBeDeleted !is null) {
            // we already have a list of nodes
            // we just need to inject on the end

            Node* previous = parent.previousReadyToBeDeleted;

            previous.next = toAdd;
            toAdd.previous = previous;
        } else
            toAdd.previous = null;

        toAdd.next = parent;
        toAdd.isDeleted = true;
        parent.previousReadyToBeDeleted = toAdd;

        assert(toAdd.isDeleted);
    }

    void mergeDeletedListToNewParent(scope Node* oldParent, scope Node* newParent) scope @trusted {
        assert(oldParent !is null);
        assert(!oldParent.isDeleted);
        assert(newParent !is null);
        assert(!newParent.isDeleted);

        Node* endOfOldList = oldParent.previousReadyToBeDeleted;
        assert(endOfOldList !is null);
        assert(endOfOldList.isDeleted);
        assert(endOfOldList.previousReadyToBeDeleted is null);

        Node* endOfNewList = newParent.previousReadyToBeDeleted;

        if (endOfNewList !is null) {
            assert(endOfNewList.isDeleted);
            assert(endOfNewList.previousReadyToBeDeleted is null);

            // we have a list on the new parent
            // so we have to get the start of the old list
            // which allows us to append it to the new list
            Node* startOfOldList = endOfOldList;

            while (startOfOldList.previous !is null)
                startOfOldList = startOfOldList.previous;
            assert(startOfOldList !is null);

            endOfNewList.next = startOfOldList;
            startOfOldList.previous = endOfNewList;
        }

        // patch end of old list into new parent
        newParent.previousReadyToBeDeleted = endOfOldList;
        endOfOldList.next = newParent;

        // patch out old list from old parent
        oldParent.previousReadyToBeDeleted = null;
    }

    ErrorInfo changeIndexToOffset(scope Iterator* iterator, ref ptrdiff_t a) scope {
        size_t actualLength = iterator is null ? nodeList.aliveNodes : (iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead);

        if (a < 0) {
            if (actualLength < -a) {
                a = actualLength;
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            }

            a = actualLength + a;
        }

        if (iterator !is null) {
            a += iterator.minimumOffsetFromHead;
        }

        if (a > actualLength) {
            a = actualLength;
            return ErrorInfo(RangeException("First offset must be smaller than length"));
        }

        return ErrorInfo.init;
    }

    ErrorInfo changeIndexToOffset(scope Iterator* iterator, ref ptrdiff_t a, ref ptrdiff_t b) scope {
        size_t actualLength = iterator is null ? nodeList.aliveNodes : (iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead);

        if (a < 0) {
            if (actualLength < -a) {
                a = actualLength;
                b = actualLength;
                return ErrorInfo(RangeException("First offset must be smaller than length"));
            }
            a = actualLength + a;
        }

        if (b < 0) {
            if (actualLength < -b) {
                b = actualLength;
                return ErrorInfo(RangeException("Second offset must be smaller than length"));
            }
            b = actualLength + b;
        }

        if (iterator !is null) {
            a += iterator.minimumOffsetFromHead;
            b += iterator.minimumOffsetFromHead;
        }

        if (b < a) {
            ptrdiff_t temp = a;
            a = b;
            b = temp;
        }

        if (a > actualLength)
            a = actualLength;
        if (b > actualLength)
            b = actualLength;

        return ErrorInfo.init;
    }

    void debugPosition(scope Iterator* iterator = null) scope @trusted {
        version (D_BetterC) {
        } else {
            import std.stdio;

            Node* current = &nodeList.head;

            try {
                if (iterator !is null)
                    debug writeln("min: ", iterator.minimumOffsetFromHead, " forwards: ", iterator.forwards.offsetFromHead,
                            " backwards: ", iterator.backwards.offsetFromHead, " max: ", iterator.maximumOffsetFromHead);

                while (current !is null) {
                    if (iterator !is null && iterator.forwards.node is current)
                        debug write(">");

                    if (current is &nodeList.head) {
                        debug writef!"0x%X HEAD "(current);
                    } else if (current is &nodeList.tail) {
                        debug writef!"0x%X TAIL "(current);
                    } else {
                        debug writef!"0x%X = %s "(current, current.value);
                    }

                    if (current.previousReadyToBeDeleted !is null)
                        debug writef!" prtbd 0x%X"(current.previousReadyToBeDeleted);

                    if (iterator !is null && iterator.backwards.node is current)
                        debug write("<");

                    debug writeln;
                    current = current.next;
                }

                debug stdout.flush;
                debug stderr.flush;
            } catch (Exception) {
            }
        }
    }
}

struct ConcurrentLinkedListIteratorList(Type) {
    alias IteratorList = ConcurrentLinkedListIteratorList;
    alias NodeList = ConcurrentLinkedListNodeList!Type;

    Iterator* head;

@safe nothrow @nogc:

    @disable this(this);

    Iterator* createIterator(scope return ref NodeList nodeList, size_t minimumOffsetFromHead = 0, size_t maximumOffsetFromHead = size_t
            .max) scope @trusted {

        Iterator* ret = nodeList.allocator.make!Iterator;

        ret.next = head;
        if (head !is null)
            head.previous = ret;
        head = ret;

        ret.minimumOffsetFromHead = minimumOffsetFromHead;
        ret.maximumOffsetFromHead = maximumOffsetFromHead;

        ret.forwards = cursorFor(nodeList, minimumOffsetFromHead);
        ret.backwards = cursorFor(nodeList, maximumOffsetFromHead);

        if (ret.forwards.node is &nodeList.tail) {
            nodeList.tail.onIteratorOut;
            ret.forwards.node = &nodeList.head;
            nodeList.head.onIteratorIn;
        }

        return ret;
    }

    Cursor cursorFor(scope ref NodeList impl, size_t offsetFromHead) scope @trusted {
        Cursor ret;
        ret.node = impl.head.next;

        while (ret.node.next !is null && ret.offsetFromHead < offsetFromHead) {
            ret.node = ret.node.next;
            ret.offsetFromHead++;
        }

        ret.node.onIteratorIn;
        return ret;
    }

    int opApply(scope int delegate(scope Iterator* iterator) @safe nothrow @nogc del) scope {
        Iterator* iterator = head;
        int result;

        while (iterator !is null && result == 0) {
            result = del(iterator);
            iterator = iterator.next;
        }

        return result;
    }

    static struct Iterator {
        Iterator* previous, next;
        size_t minimumOffsetFromHead, maximumOffsetFromHead;
        int refCount;

        Cursor forwards, backwards;

    @safe nothrow @nogc:

        void rc(bool addRef, scope ref NodeList nodeList, scope ref IteratorList iteratorList) scope @trusted {
            if (addRef)
                refCount++;
            else {
                refCount--;

                if (refCount == 0) {
                    forwards.onEOL(nodeList);
                    backwards.onEOL(nodeList);

                    if (iteratorList.head is &this) {
                        iteratorList.head = this.next;
                        assert(this.previous is null);
                    }

                    if (this.previous !is null)
                        this.previous.next = this.next;
                    if (this.next !is null)
                        this.next.previous = this.previous;

                    nodeList.allocator.dispose(&this);
                }
            }
        }

        void onRemoveDecreaseFromHead(size_t ifFromOffsetFromHead, size_t amount, scope NodeList.Node* node) scope {
            if (maximumOffsetFromHead < ifFromOffsetFromHead)
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

            forwards.onRemoveDecreaseFromHead(ifFromOffsetFromHead, amount, node);
            backwards.onRemoveDecreaseFromHead(ifFromOffsetFromHead, amount, node);

            this.maximumOffsetFromHead = newMaximumOffsetFromHead;
        }
    }

    static struct Cursor {
        NodeList.Node* node;
        size_t offsetFromHead;

    @safe nothrow @nogc:

         ~this() {
            assert(node is null);
        }

        void onEOL(scope ref NodeList nodeList) {
            node.onIteratorOut;

            if (node.isDeleted) {
                nodeList.removeNode(node);
            }

            this.node = null;
        }

        void advanceForwards(size_t amount, size_t maximumOffsetFromHead) {
            node.onIteratorOut;

            while (node.next !is null && node.next.next !is null && amount > 0 && offsetFromHead < maximumOffsetFromHead) {
                node = node.next;
                amount--;
                offsetFromHead++;
            }

            node.onIteratorIn;
        }

        void advanceBackwards(size_t amount, size_t minimumOffsetFromHead) {
            node.onIteratorOut;

            while (node.previous !is null && node.previous.previous !is null && amount > 0 && offsetFromHead >= minimumOffsetFromHead) {
                node = node.previous;
                amount--;
                offsetFromHead--;
            }

            node.onIteratorIn;
        }

        void ifDeletedBringIntoLife() scope {
            assert(node !is null);
            node.onIteratorOut;

            while (node.isDeleted && node.next !is null) {
                node = node.next;
            }

            node.onIteratorIn;
        }

        void onInsertIncreaseFromHead(size_t ifOffsetFromHead, size_t amount) scope {
            if (this.offsetFromHead >= ifOffsetFromHead) {
                this.offsetFromHead += amount;
            }
        }

        void onRemoveDecreaseFromHead(size_t ifFromOffsetFromHead, size_t amount, scope NodeList.Node* node) scope {
            if (this.offsetFromHead > ifFromOffsetFromHead) {
                size_t amountToGoBackwards = this.offsetFromHead - ifFromOffsetFromHead;

                if (amountToGoBackwards > amount)
                    amountToGoBackwards = amount;

                this.offsetFromHead -= amountToGoBackwards;
            } else if (this.node is node && this.offsetFromHead == ifFromOffsetFromHead) {
                this.offsetFromHead++;
            }
        }
    }
}

struct ConcurrentLinkedListNodeList(Type) {
    RCAllocator allocator, valueAllocator;
    Node head, tail;
    size_t allNodes, aliveNodes;
    int refCount;

    @disable this(this);

@safe nothrow @nogc:

    this(RCAllocator allocator, RCAllocator valueAllocator) scope @trusted {
        this.allocator = allocator;
        this.valueAllocator = valueAllocator;
        this.refCount = 1;
        head.next = &tail;
        tail.previous = &head;
    }

    Node* createNode(scope Node* prior) scope @trusted {
        assert(prior !is null);

        // obivously we can't append to the tail node
        // so we move to the previous one and append to that
        if (prior is &tail)
            prior = prior.previous;

        Node* ret = allocator.make!Node();

        ret.previous = prior;
        ret.next = prior.next;
        prior.next.previous = ret;
        prior.next = ret;

        this.allNodes++;
        this.aliveNodes++;
        return ret;
    }

    void removeNode(scope Node* node) @trusted scope {
        assert(node !is null);
        assert(node !is &head);
        assert(node !is &tail);

        if (node.previous !is null)
            node.previous.next = node.next;
        node.next.previous = node.previous;

        if (node.previousReadyToBeDeleted !is null)
            mergeDeletedListToNewParent(node, node.next);

        if (!node.isDeleted)
            this.aliveNodes--;

        static if (isAnyPointer!Type) {
            if (!valueAllocator.isNull)
                valueAllocator.dispose(node.value);
        }

        this.allNodes--;
        allocator.dispose(node);
    }

    Node* nodeFor(size_t offset) scope @trusted {
        Node* ret = head.next;

        while (ret.next !is null && offset > 0) {
            ret = ret.next;
        }

        assert(offset == 0);
        return ret;
    }

    void mergeDeletedListToNewParent(scope Node* oldParent, scope Node* newParent) scope @trusted {
        assert(oldParent !is null);
        assert(!oldParent.isDeleted);
        assert(newParent !is null);
        assert(!newParent.isDeleted);

        Node* endOfOldList = oldParent.previousReadyToBeDeleted;
        assert(endOfOldList !is null);
        assert(endOfOldList.isDeleted);
        assert(endOfOldList.previousReadyToBeDeleted is null);

        Node* endOfNewList = newParent.previousReadyToBeDeleted;

        if (endOfNewList !is null) {
            assert(endOfNewList.isDeleted);
            assert(endOfNewList.previousReadyToBeDeleted is null);

            // we have a list on the new parent
            // so we have to get the start of the old list
            // which allows us to append it to the new list
            Node* startOfOldList = endOfOldList;

            while (startOfOldList.previous !is null)
                startOfOldList = startOfOldList.previous;
            assert(startOfOldList !is null);

            endOfNewList.next = startOfOldList;
            startOfOldList.previous = endOfNewList;
        }

        // patch end of old list into new parent
        newParent.previousReadyToBeDeleted = endOfOldList;
        endOfOldList.next = newParent;

        // patch out old list from old parent
        oldParent.previousReadyToBeDeleted = null;
    }

    static struct Node {
        Node* previous, previousReadyToBeDeleted, next;
        int refCount;
        bool isDeleted;
        Type value;

    @trusted nothrow @nogc:

        void onIteratorIn() {
            refCount++;
        }

        void onIteratorOut() {
            refCount--;
            assert(refCount >= 0);
        }
    }
}
