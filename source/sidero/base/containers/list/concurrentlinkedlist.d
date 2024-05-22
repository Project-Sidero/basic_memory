module sidero.base.containers.list.concurrentlinkedlist;
import sidero.base.containers.readonlyslice;
import sidero.base.allocators;
import sidero.base.traits;
import sidero.base.errors;
import sidero.base.attributes;

export:

private {
    alias CLLI = ConcurrentLinkedList!int;
}

///
struct ConcurrentLinkedList(Type) {
    private @PrettyPrintIgnore {
        import sidero.base.internal.meta : OpApplyCombos;

        ConcurrentLinkedListImpl!(Type)* state;
        typeof(state).Iterator* iterator;

        int opApplyImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            int result;

            while (!empty) {
                ElementType got = front();
                if (!got)
                    return result;

                static if (__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if (result)
                    return result;

                popFront();
            }

            return result;
        }

        int opApplyReverseImpl(Del)(scope Del del) @trusted scope {
            if (isNull)
                return 0;

            int result;

            while (!empty) {
                ElementType got = back();
                if (!got)
                    return result;

                static if (__traits(compiles, del(got)))
                    result = del(got);
                else
                    static assert(0);

                if (result)
                    return result;

                popBack();
            }

            return result;
        }
    }
export:

    ///
    mixin OpApplyCombos!("ElementType", null, ["@safe", "nothrow", "@nogc"]);

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll ~= Type.init;

        int count;

        foreach (v; cll) {
            assert(v);
            assert(v == Type.init);
            count++;
        }

        assert(count == 1);
    }

    ///
    mixin OpApplyCombos!("ElementType", null, ["@safe", "nothrow", "@nogc"], "opApplyReverse");

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll ~= Type.init;

        int count;

        foreach_reverse (v; cll) {
            assert(v);
            assert(v == Type.init);
            count++;
        }

        assert(count == 1);
    }

    ///
    alias ElementType = ResultReference!Type;
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
    this(return scope ref ConcurrentLinkedList other) scope @trusted {
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
    bool isNull() scope {
        return this.state is null;
    }

    ///
    bool haveIterator() scope {
        return this.iterator !is null;
    }

    ///
    alias opDollar = length;

    ///
    ptrdiff_t length() scope {
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

    ///
    alias equals = opEquals;

    ///
    bool opEquals(Input)(scope Input other) scope if (HaveOpApply!(Input, Type)) {
        return opCmp(other) == 0;
    }

    ///
    unittest {
        struct Thing {
            int opApply(scope int delegate(ref Type) @safe nothrow @nogc del) @safe nothrow @nogc {
                Type temp;
                return del(temp);
            }
        }

        Thing thing;
        ConcurrentLinkedList cll;

        cll ~= Type.init;
        assert(cll.equals(thing));
    }

    /// Takes in an opApply
    bool opEquals(scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) {
        return opCmp(del) == 0;
    }

    ///
    unittest {
        int handle(scope int delegate(ref Type) @safe nothrow @nogc del) @safe nothrow @nogc {
            Type temp;
            return del(temp);
        }

        ConcurrentLinkedList cll;
        cll ~= Type.init;
        assert(cll.equals(&handle));
    }

    ///
    bool opEquals(scope Type other) {
        return opCmp(other) == 0;
    }

    ///
    unittest {
        ConcurrentLinkedList ccl;
        ccl ~= Type.init;
        assert(ccl.equals(Type.init));
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(Input)(scope Input other) scope @trusted if (HaveOpApply!(Input, Type)) {
        return this.opCmp(GetOpApply!Type(other));
    }

    ///
    unittest {
        struct Thing {
            int opApply(scope int delegate(ref Type) @safe nothrow @nogc del) @safe nothrow @nogc {
                Type temp;
                return del(temp);
            }
        }

        Thing thing;
        ConcurrentLinkedList cll;

        cll ~= Type.init;
        assert(cll.compare(thing) == 0);
    }

    /// Takes in an opApply
    int opCmp(scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) {
        if (isNull)
            return del is null ? 0 : (del((ref Type) => 1) ? -1 : 0);
        return state.opCmpExternal(iterator, del);
    }

    ///
    unittest {
        int handle(scope int delegate(ref Type) @safe nothrow @nogc del) @safe nothrow @nogc {
            Type temp;
            return del(temp);
        }

        ConcurrentLinkedList cll;
        cll ~= Type.init;
        assert(cll.compare(&handle) == 0);
    }

    ///
    int opCmp(scope Type[] other...) scope {
        if (isNull)
            return other.length == 0 ? 0 : -1;
        return state.opCmpExternal(iterator, other);
    }

    ///
    unittest {
        ConcurrentLinkedList cll;
        cll ~= Type.init;
        assert(cll.compare(Type.init) == 0);
    }

    ///
    ulong toHash() scope const @trusted {
        scope ConcurrentLinkedList* cll = cast(ConcurrentLinkedList*)&this;
        cll.setupState;
        cll.setupIterator;

        return cll.state.hashExternal(cast(typeof(cll.iterator))iterator);
    }

    @property {
        ///
        bool empty() scope {
            if (this.isNull())
                return true;

            setupIterator;
            return state.emptyExternal(iterator);
        }

        ///
        unittest {
            ConcurrentLinkedList thing;
            assert(thing.empty);

            thing ~= Type.init;
            assert(!thing.empty);
        }

        ///
        ResultReference!Type front() scope {
            if (this.isNull())
                return ResultReference!Type(NullPointerException);

            setupIterator;
            return state.frontExternal(iterator);
        }

        ///
        unittest {
            ConcurrentLinkedList thing;
            assert(thing.empty);

            thing ~= Type.init;
            assert(!thing.empty);

            auto got = thing.front;

            assert(got);
            assert(got == Type.init);
            thing.popFront;

            assert(thing.empty);
        }

        ///
        ResultReference!Type back() scope {
            if (this.isNull())
                return ResultReference!Type(NullPointerException);

            setupIterator;
            return state.backExternal(iterator);
        }

        ///
        unittest {
            ConcurrentLinkedList thing;
            assert(thing.empty);

            thing ~= Type.init;
            assert(!thing.empty);

            auto got = thing.back;

            assert(got);
            assert(got == Type.init);
            thing.popBack;

            assert(thing.empty);
        }

        ///
        alias put = append;
    }

    ///
    void popFront() scope {
        if (this.isNull())
            return;

        setupIterator;
        state.popFrontExternal(iterator);
    }

    ///
    void popBack() scope {
        if (this.isNull())
            return;

        setupIterator;
        state.popBackExternal(iterator);
    }

    ///
    bool startsWith(scope Type input) scope {
        if (isNull)
            return false;
        return state.startsWithExternal(iterator, input);
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);
        assert(cll.startsWith(Type.init));
    }

    ///
    bool endsWith(scope Type input) scope {
        if (isNull)
            return false;
        return state.endsWithExternal(iterator, input);
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);
        assert(cll.endsWith(Type.init));
    }

    ///
    ptrdiff_t indexOf(scope Type input) scope {
        if (isNull)
            return -1;
        return state.indexOfExternal(iterator, input, true);
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);
        assert(cll.indexOf(Type.init) == 0);
    }

    ///
    ptrdiff_t lastIndexOf(scope Type input) scope {
        if (isNull)
            return -1;
        return state.indexOfExternal(iterator, input, false);
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);
        assert(cll.lastIndexOf(Type.init) == 3);
    }

    ///
    size_t count(scope Type input) scope {
        if (isNull)
            return 0;
        return state.countExternal(iterator, input);
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);
        assert(cll.count(Type.init) == 4);
    }

    ///
    bool contains(scope Type input) scope {
        return this.indexOf(input) >= 0;
    }

    ///
    unittest {
        ConcurrentLinkedList cll = [Type.init, Type.init, Type.init, Type.init];
        assert(cll.length == 4);
        assert(cll.contains(Type.init));
    }

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
    void insert(Input)(ptrdiff_t index, scope Input input) scope @trusted if (HaveOpApply!(Input, Type)) {
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

    void setupIterator() scope {
        if (state is null || iterator !is null)
            return;

        iterator = state.createIteratorExternal(null);
        state.rcExternal(false, null);
    }

    void debugPosition() scope {
        if (!isNull)
            state.debugPosition(iterator);
    }
}

private:
import sidero.base.synchronization.system.lock;
import sidero.base.traits : isAnyPointer;
import sidero.base.internal.logassert;

struct ConcurrentLinkedListImpl(Type) {
    ConcurrentLinkedListNodeList!Type nodeList;
    ConcurrentLinkedListIteratorList!Type iteratorList;

    SystemLock mutex;
    alias Node = typeof(nodeList).Node;
    alias Iterator = typeof(iteratorList).Iterator;
    alias Cursor = typeof(iteratorList).Cursor;

@safe nothrow @nogc:

    this(RCAllocator allocator, RCAllocator valueAllocator) scope @trusted {
        nodeList = typeof(nodeList)(allocator, valueAllocator);
    }

    void rcExternal(bool addRef, scope Iterator* iterator) scope @trusted {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        if (rcInternal(addRef, iterator))
            mutex.unlock;
    }

    void rcNodeExternal(bool addRef, scope Node* node) scope @trusted {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t ret = iterator is null ? nodeList.aliveNodes : (iterator.maximumOffsetFromHead - iterator.minimumOffsetFromHead);
        mutex.unlock;
        return ret;
    }

    Iterator* createIteratorExternal(scope Iterator* iterator, ptrdiff_t minimumOffsetFromHead = 0,
            ptrdiff_t maximumOffsetFromHead = ptrdiff_t.max) scope @trusted {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        changeIndexToOffset(iterator, minimumOffsetFromHead, maximumOffsetFromHead);
        Iterator* ret = iteratorList.createIterator(nodeList, minimumOffsetFromHead, maximumOffsetFromHead);

        this.rcInternal(true, ret);

        mutex.unlock;
        return ret;
    }

    void insertExternal(scope Iterator* iterator, ptrdiff_t index, ref Type value) scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

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

    ulong hashExternal(scope Iterator* iterator) scope @trusted {
        import sidero.base.hash.utils : hashOf;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        ulong ret = hashOf();
        foreachValue(iterator, (scope ref Type value) { ret = hashOf(value, ret); return 0; });

        mutex.unlock;
        return ret;
    }

    ResultReference!Type frontExternal(scope Iterator* iterator) scope @trusted {
        assert(iterator !is null);

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        ResultReference!Type ret = ResultReference!Type(&iterator.forwards.node.value, iterator.forwards.node,
                cast(typeof(return).RCHandle)&rcNodeExternal);
        iterator.forwards.node.onIteratorIn;
        this.rcInternal(true, null);

        mutex.unlock;
        return ret;
    }

    ResultReference!Type backExternal(scope Iterator* iterator) scope @trusted {
        assert(iterator !is null);

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        if (iterator.backwards.offsetFromHead == iterator.maximumOffsetFromHead)
            iterator.backwards.advanceBackwards(1, iterator.forwards.offsetFromHead);

        ResultReference!Type ret = ResultReference!Type(&iterator.backwards.node.value, iterator.backwards.node,
                cast(typeof(return).RCHandle)&rcNodeExternal);
        iterator.backwards.node.onIteratorIn;
        this.rcInternal(true, null);

        mutex.unlock;
        return ret;
    }

    bool emptyExternal(scope Iterator* iterator) scope {
        assert(iterator !is null);

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        bool ret = iterator.forwards.offsetFromHead == iterator.backwards.offsetFromHead;

        mutex.unlock;
        return ret;
    }

    void popFrontExternal(scope Iterator* iterator) scope {
        assert(iterator !is null);

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        iterator.forwards.advanceForwards(1, iterator.backwards.offsetFromHead);
        mutex.unlock;
    }

    void popBackExternal(scope Iterator* iterator) scope {
        assert(iterator !is null);

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        if (iterator.backwards.offsetFromHead == iterator.maximumOffsetFromHead)
            iterator.backwards.advanceBackwards(1, iterator.forwards.offsetFromHead);

        iterator.backwards.advanceBackwards(1, iterator.forwards.offsetFromHead);
        mutex.unlock;
    }

    int opCmpExternal(scope Iterator* iterator, scope Type[] other) {
        int ret;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t offset, count = nodeList.aliveNodes, maximumOffsetFromHead = count;

        if (iterator !is null) {
            offset = iterator.minimumOffsetFromHead;
            count = iterator.maximumOffsetFromHead - offset;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        if (other.length < count)
            ret = -1;
        else if (other.length > count)
            ret = 1;
        else {
            Cursor cursor = iteratorList.cursorFor(nodeList, offset);

            while (ret == 0 && !cursor.isOutOfRange(offset, maximumOffsetFromHead)) {
                if (cursor.node.value < other[0])
                    ret = -1;
                else if (cursor.node.value > other[0])
                    ret = 1;

                other = other[1 .. $];
                cursor.advanceForwards(1, maximumOffsetFromHead);
            }

            assert(other.length == 0);
            cursor.onEOL(nodeList);
        }

        mutex.unlock;
        return ret;
    }

    int opCmpExternal(scope Iterator* iterator, scope int delegate(scope int delegate(ref Type) @safe nothrow @nogc) @safe nothrow @nogc del) {
        int ret;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t offset, count = nodeList.aliveNodes, maximumOffsetFromHead = count;

        if (iterator !is null) {
            offset = iterator.minimumOffsetFromHead;
            count = iterator.maximumOffsetFromHead - offset;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        Cursor cursor = iteratorList.cursorFor(nodeList, offset);

        foreach (ref otherValue; del) {
            if (ret != 0)
                break;
            else if (cursor.isOutOfRange(offset, maximumOffsetFromHead)) {
                ret = -1;
                break;
            }

            if (cursor.node.value < otherValue) {
                ret = -1;
                break;
            } else if (cursor.node.value > otherValue) {
                ret = 1;
                break;
            }

            cursor.advanceForwards(1, maximumOffsetFromHead);
        }

        if (ret == 0 && !cursor.isOutOfRange(offset, maximumOffsetFromHead)) {
            ret = 1;
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
        return ret;
    }

    ptrdiff_t indexOfExternal(scope Iterator* iterator, scope Type input, bool doOne = true) scope {
        ptrdiff_t ret = -1;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t offset, count = nodeList.aliveNodes, maximumOffsetFromHead = count;

        if (iterator !is null) {
            offset = iterator.minimumOffsetFromHead;
            count = iterator.maximumOffsetFromHead - offset;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        Cursor cursor = iteratorList.cursorFor(nodeList, offset);

        while (!cursor.isOutOfRange(offset, maximumOffsetFromHead)) {
            if (cursor.node.value == input) {
                ret = cursor.offsetFromHead;
                if (doOne)
                    break;
            }

            cursor.advanceForwards(1, maximumOffsetFromHead);
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
        return ret;
    }

    size_t countExternal(scope Iterator* iterator, scope Type input) scope {
        size_t ret;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t offset, count = nodeList.aliveNodes, maximumOffsetFromHead = count;

        if (iterator !is null) {
            offset = iterator.minimumOffsetFromHead;
            count = iterator.maximumOffsetFromHead - offset;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        Cursor cursor = iteratorList.cursorFor(nodeList, offset);

        while (!cursor.isOutOfRange(offset, maximumOffsetFromHead)) {
            if (cursor.node.value == input) {
                ret++;
            }

            cursor.advanceForwards(1, maximumOffsetFromHead);
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
        return ret;
    }

    bool startsWithExternal(scope Iterator* iterator, scope Type input) scope {
        bool ret;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t offset, count = nodeList.aliveNodes, maximumOffsetFromHead = count;

        if (iterator !is null) {
            offset = iterator.minimumOffsetFromHead;
            count = iterator.maximumOffsetFromHead - offset;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        Cursor cursor = iteratorList.cursorFor(nodeList, offset);

        while (!cursor.isOutOfRange(offset, maximumOffsetFromHead)) {
            ret = cursor.node.value == input;
            break;
        }

        cursor.onEOL(nodeList);
        mutex.unlock;
        return ret;
    }

    bool endsWithExternal(scope Iterator* iterator, scope Type input) scope {
        bool ret;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());

        size_t offset, count = nodeList.aliveNodes, maximumOffsetFromHead = count;

        if (iterator !is null) {
            offset = iterator.minimumOffsetFromHead;
            count = iterator.maximumOffsetFromHead - offset;
            maximumOffsetFromHead = iterator.maximumOffsetFromHead;
        }

        if (maximumOffsetFromHead > offset) {
            Cursor cursor = iteratorList.cursorFor(nodeList, maximumOffsetFromHead - 1);
            ret = cursor.node.value == input;
            cursor.onEOL(nodeList);
        }

        mutex.unlock;
        return ret;
    }

    // /\ external
    // \/ internal

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

    int foreachValue(scope Iterator* iterator, scope int delegate(scope ref Type value) @safe nothrow @nogc del) scope {
        int result;

        if (iterator !is null) {
            Cursor cursor = iteratorList.cursorFor(nodeList, iterator.minimumOffsetFromHead);
            cursor.node.onIteratorIn;

            while (result == 0 && !cursor.isOutOfRange(0, iterator.maximumOffsetFromHead)) {
                result = del(cursor.node.value);
                cursor.advanceForwards(1, iterator.maximumOffsetFromHead);
            }

            cursor.onEOL(nodeList);
        }

        return result;
    }

    void debugPosition(scope Iterator* iterator = null) scope @trusted {
        version (D_BetterC) {
        } else {
            version (unittest)
                debug {
                    import std.stdio;

                    Node* current = &nodeList.head;

                    try {
                        debug writeln("aliveNodes: ", nodeList.aliveNodes, " allNodes: ", nodeList.allNodes);
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

                            debug write("refcount ", current.refCount);
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
}

struct ConcurrentLinkedListIteratorList(Type) {
    alias IteratorList = ConcurrentLinkedListIteratorList;
    alias NodeList = ConcurrentLinkedListNodeList!Type;

    Iterator* head;

@safe nothrow @nogc:

    //@disable this(this);

    Iterator* createIterator(return scope ref NodeList nodeList, size_t minimumOffsetFromHead = 0, size_t maximumOffsetFromHead = size_t
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
        ptrdiff_t refCount;

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

            if (node.isDeleted && node.refCount == 0) {
                nodeList.removeNode(node);
            }

            this.node = null;
        }

        bool isOutOfRange(size_t start, size_t end) scope {
            return offsetFromHead < start || offsetFromHead >= end;
        }

        void advanceForwards(size_t amount, size_t maximumOffsetFromHead) {
            ifDeletedBringIntoLife();
            node.onIteratorOut;

            while (node.next !is null && amount > 0 && offsetFromHead < maximumOffsetFromHead) {
                node = node.next;
                amount--;
                offsetFromHead++;
            }

            node.onIteratorIn;
        }

        void advanceBackwards(size_t amount, size_t minimumOffsetFromHead) {
            ifDeletedBringIntoLife();
            node.onIteratorOut;

            while (node.previous !is null && amount > 0 && offsetFromHead > minimumOffsetFromHead) {
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
    ptrdiff_t refCount;

    //@disable this(this);

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

    void removeNode(scope Node* node) scope @trusted {
        assert(node !is null);
        assert(node !is &head);
        assert(node !is &tail);

        if (node.previous !is null)
            node.previous.next = node.next;

        if (node.next.previousReadyToBeDeleted is node)
            node.next.previousReadyToBeDeleted = node.previous;
        else {
            node.next.previous = node.previous;

            if (node.previousReadyToBeDeleted !is null)
                mergeDeletedListToNewParent(node, node.next);
        }

        if (!node.isDeleted)
            this.aliveNodes--;

        static if (isAnyPointer!Type) {
            if (!valueAllocator.isNull)
                valueAllocator.dispose(node.value);
        }

        this.allNodes--;
        allocator.dispose(node);
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
        ptrdiff_t refCount;
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
