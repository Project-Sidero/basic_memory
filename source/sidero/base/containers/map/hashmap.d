module sidero.base.containers.map.hashmap;
import sidero.base.allocators;
import sidero.base.traits;
import sidero.base.errors;
import sidero.base.attributes;
import sidero.base.text;

export:

private {
    alias CHMPII = HashMap!(string, string);
}

/// Non-concurrent version of hash map, non-owning
struct HashMap(RealKeyType, ValueType) {
    /// If key type supports asReadOnly it is used instead of RealKeyType internally.
    alias KeyType = typeof(state).KeyType;

    private @PrettyPrintIgnore {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(scope Del del) scope @trusted {
            if(isNull)
                return 0;

            auto iterator = state.createIteratorExternal();
            assert(iterator !is null);
            scope(exit)
                state.rcIteratorExternal(false, iterator);

            int result;

            while(result == 0 && !state.iteratorEmptyExternal(iterator)) {
                Result!KeyType gotKey;
                Result!ValueType gotValue;

                if(state.iteratorGetExternal(iterator, gotKey, gotValue)) {
                    static if(__traits(compiles, del(gotKey, gotValue)))
                        result = del(gotKey, gotValue);
                    else
                        result = del(gotValue);

                    if(state.iteratorAdvanceExternal(iterator)) {
                        break;
                    }
                }
            }

            return result;
        }
    }

export:

    ///
    mixin OpApplyCombos!(Result!ValueType, Result!KeyType, "opApply", true, true, true, false, false);

    ///
    unittest {
        HashMap cll;
        cll[KeyType.init] = ValueType.init;

        int count;

        foreach(k, v; cll) {
            assert(k);
            assert(v);
            assert(k == KeyType.init);
            assert(v == ValueType.init);
            count++;
        }

        assert(count == 1);
    }

@safe nothrow @nogc:

    ///
    this(RCAllocator allocator, RCAllocator valueAllocator = RCAllocator.init) scope @trusted {
        if(allocator.isNull)
            allocator = globalAllocator();

        state = allocator.make!(HashMapImpl!(RealKeyType, ValueType))(allocator, valueAllocator);
    }

    ///
    unittest {
        HashMap map = HashMap(globalAllocator());
        assert(!map.isNull);
    }

    ///
    this(return scope ref HashMap other) scope @trusted {
        this.tupleof = other.tupleof;

        if(!isNull)
            state.rcExternal(true);
    }

    ///
    unittest {
        HashMap original = HashMap(globalAllocator());
        HashMap copied = original;
    }

    @disable this(ref return scope const HashMap other) scope const;

    ~this() scope {
        if(!isNull)
            state.rcExternal(false);
    }

    void opAssign(return scope HashMap other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    alias opDollar = length;

    ///
    size_t length() scope {
        if(isNull)
            return 0;
        return state.nodeList.aliveNodes;
    }

    ///
    HashMap dup(RCAllocator allocator = RCAllocator.init, RCAllocator valueAllocator = RCAllocator.init) scope {
        if(isNull)
            return HashMap.init;

        HashMap ret;
        ret.state = state.dupExternal(allocator, valueAllocator);

        return ret;
    }

    ///
    unittest {
        HashMap map;
        assert(map.isNull);

        map[RealKeyType.init] = ValueType.init;
        assert(!map.isNull);
        assert(map.length == 1);

        auto got = map.dup;
        assert(got.length == 1);
    }

    ///
    void copyOnWrite() {
        if(!isNull)
            state.copyOnWrite = true;
    }

    ///
    void cleanupUnreferencedNodes() {
        if(!isNull)
            state.keepNoExternalReferences = false;
    }

    /// Will insert if not already in map
    bool insert(return scope RealKeyType key, return scope ValueType value) scope {
        setupState;
        willModify;

        static if(!is(KeyType == RealKeyType)) {
            return this.insert(key.asReadOnly(), value);
        } else {
            return state.insertExternal(key, value, false);
        }
    }

    /// Will insert or update if already in map
    bool update(return scope RealKeyType key, return scope ValueType value) scope {
        setupState;
        willModify;

        static if(!is(KeyType == RealKeyType)) {
            return this.update(key.asReadOnly(), value);
        } else {
            return state.insertExternal(key, value, true);
        }
    }

    ///
    void opIndexAssign(return scope ValueType value, return scope RealKeyType key) scope {
        setupState;
        willModify;

        static if(!is(KeyType == RealKeyType)) {
            this.opIndexAssign(value, key.asReadOnly());
            return;
        } else {
            state.insertExternal(key, value);
        }
    }

    ///
    Result!ValueType opIndex(scope RealKeyType key) scope {
        if(isNull)
            return typeof(return)(NullPointerException);

        typeof(return) ret;

        static if(!is(KeyType == RealKeyType)) {
            ret = state.getValueExternal(key.asReadOnly);
        } else {
            ret = state.getValueExternal(key);
        }

        if(!ret)
            ret = typeof(return)(NonMatchingStateToArgumentException);

        return ret;
    }

    ///
    unittest {
        HashMap map;
        assert(map.isNull);

        map[RealKeyType.init] = ValueType.init;
        assert(!map.isNull);
        assert(map.length == 1);

        auto got = map[RealKeyType.init];
        assert(got);
        assert(got == ValueType.init);
    }

    ///
    Result!ValueType get(scope RealKeyType key, return scope ValueType fallback) scope @trusted {
        setupState;
        typeof(return) ret;

        static if(!is(KeyType == RealKeyType)) {
            ret = state.getValueExternal(key.asReadOnly);
        } else {
            ret = state.getValueExternal(key);
        }

        if(!ret || ret.isNull) {
            ret = typeof(return)(fallback);
        }

        return ret;
    }

    ///
    bool opBinaryRight(string op : "in")(scope RealKeyType key) scope {
        if(isNull)
            return false;

        static if(!is(KeyType == RealKeyType)) {
            return state.containsExternal(key.asReadOnly);
        } else {
            return state.containsExternal(key);
        }
    }

    ///
    unittest {
        HashMap map;
        assert(map.isNull);
        assert(RealKeyType.init !in map);

        map[RealKeyType.init] = ValueType.init;
        assert(!map.isNull);
        assert(map.length == 1);
        assert(RealKeyType.init in map);
    }

    ///
    bool remove(scope RealKeyType key) scope {
        if(isNull)
            return false;
        willModify;

        static if(!is(KeyType == RealKeyType)) {
            return state.removeExternal(key.asReadOnly);
        } else {
            return state.removeExternal(key);
        }
    }

    ///
    unittest {
        HashMap map;
        assert(map.isNull);
        assert(RealKeyType.init !in map);

        map[RealKeyType.init] = ValueType.init;
        assert(!map.isNull);
        assert(map.length == 1);
        assert(RealKeyType.init in map);

        auto got = map[RealKeyType.init];

        map.remove(RealKeyType.init);
        assert(map.length == 0);
        assert(RealKeyType.init !in map);
    }

    ///
    void clear() scope {
        if(!isNull)
            state.clearExternal;
    }

    static if(!is(KeyType == RealKeyType)) {
        /// Will insert if not already in map
        bool insert(return scope KeyType key, return scope ValueType value) scope {
            setupState;
            willModify;

            return state.insertExternal(key, value, false);
        }

        /// Will insert or update if in map
        bool update(return scope KeyType key, return scope ValueType value) scope {
            setupState;
            willModify;

            return state.insertExternal(key, value, true);
        }

        ///
        void opIndexAssign(return scope ValueType value, return scope KeyType key) scope {
            setupState;
            willModify;

            state.insertExternal(key, value);
        }

        ///
        Result!ValueType opIndex(scope KeyType key) scope {
            if(isNull)
                return typeof(return)(NullPointerException);

            Result!ValueType ret = state.getValueExternal(key);

            if(!ret || ret.isNull)
                ret = typeof(return)(NonMatchingStateToArgumentException);

            return ret;
        }

        ///
        Result!ValueType get(scope KeyType key, return scope ValueType fallback) scope @trusted {
            setupState;
            Result!ValueType ret = state.getValueExternal(key);

            if(!ret || ret.isNull)
                ret = fallback;

            return ret;
        }

        ///
        bool opBinaryRight(string op : "in")(scope KeyType key) scope {
            if(isNull)
                return false;

            return state.containsExternal(key);
        }

        ///
        bool remove(scope KeyType key) scope {
            if(isNull)
                return false;

            willModify;
            return state.removeExternal(key);
        }
    }

    @disable auto opCast(T)();

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils : hashOf;

        if(isNull)
            return hashOf();

        return (cast(HashMapImpl!(RealKeyType, ValueType)*)state).hashExternal;
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope HashMap other) scope const {
        return this.opCmp(other) == 0;
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope HashMap other) scope const @trusted {
        if(isNull)
            return other.isNull ? 0 : -1;
        else if(other.isNull)
            return 1;
        return (cast(HashMapImpl!(RealKeyType, ValueType)*)state).compareExternal((cast(HashMapImpl!(RealKeyType,
                ValueType)*)other.state));
    }

    ///
    String_UTF8 toString() @trusted {
        StringBuilder_UTF8 ret = StringBuilder_UTF8();
        toString(ret);
        return ret.asReadOnly;
    }

    ///
    void toString(scope ref StringBuilder_UTF8 builder) @trusted {
        if(isNull)
            builder ~= "HashMap!(" ~ KeyType.stringof ~ ", " ~ ValueType.stringof ~ ")@null";
        else
            builder.formattedWrite("HashMap!(" ~ KeyType.stringof ~ ", " ~ ValueType.stringof ~ ")@{:p}(length={:d}",
                    cast(void*)this.state, this.length);
    }

    ///
    String_UTF8 toStringPretty(PrettyPrint pp) @trusted {
        StringBuilder_UTF8 ret = StringBuilder_UTF8();
        toStringPretty(ret, pp);
        return ret.asReadOnly;
    }

    ///
    void toStringPretty(scope ref StringBuilder_UTF8 builder, PrettyPrint pp) @trusted {
        enum FQN = __traits(fullyQualifiedName, HashMap);
        pp.emitPrefix(builder);

        if(isNull) {
            builder ~= FQN ~ "@null";
            return;
        }

        builder.formattedWrite(FQN ~ "@{:p}(length={:d} =>\n", cast(void*)this.state, this.length);
        pp.depth++;

        bool haveOne;

        foreach(ref k, ref v; this) {
            assert(k);
            assert(v);

            if(haveOne)
                builder ~= "\n";
            haveOne = true;

            pp.startWithoutPrefix = false;
            pp.emitPrefix(builder);
            builder.formattedWrite("{:s}: ", k);

            pp.startWithoutPrefix = true;
            pp(builder, v);
        }

        pp.depth--;
        builder ~= ")";
    }

private:
    @PrettyPrintIgnore HashMapImpl!(RealKeyType, ValueType)* state;

    void setupState() scope @trusted {
        if(!isNull)
            return;

        RCAllocator allocator = globalAllocator();
        state = allocator.make!(HashMapImpl!(RealKeyType, ValueType))(allocator, RCAllocator.init);
    }

    void willModify() scope {
        if(state.copyOnWrite) {
            this = this.dup;
        }
    }

    void debugPosition() scope {
        if(!isNull)
            state.debugPosition(null);
    }
}

private:
import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;
import sidero.base.traits : isAnyPointer;

struct HashMapImpl(RealKeyType, ValueType) {
    HashMapNode!(RealKeyType, ValueType) nodeList;
    HashMapIterator!(RealKeyType, ValueType) iteratorList;

    bool copyOnWrite, keepNoExternalReferences;

    alias Node = typeof(nodeList).Node;
    alias KeyType = typeof(nodeList).KeyType;
    alias Iterator = typeof(iteratorList).Iterator;
    alias Cursor = typeof(iteratorList).Cursor;

@safe nothrow @nogc:

    this(return scope RCAllocator allocator, return scope RCAllocator valueAllocator) scope @trusted {
        nodeList = typeof(nodeList)(allocator, valueAllocator);
        keepNoExternalReferences = true;
    }

    void rcExternal(bool addRef) scope {
        rcInternal(addRef);
    }

    void rcIteratorExternal(bool addRef, scope Iterator* iterator) {
        assert(!addRef);

        if(!iterator.rc(addRef, nodeList, iteratorList) || rcInternal(addRef)) {
        }
    }

    void rcNodeExternal(bool addRef, scope Node* node) scope {
        if(node !is null) {
            if(addRef)
                node.onIteratorIn;
            else
                node.onIteratorOut;

            if(node.refCount == 0 && (node.isDeleted || !this.keepNoExternalReferences))
                nodeList.removeNode(node);
        }

        rcInternal(addRef);
    }

    Iterator* createIteratorExternal() scope @trusted {
        Iterator* ret = iteratorList.createIterator(nodeList);
        this.rcInternal(true);
        return ret;
    }

    bool iteratorEmptyExternal(scope Iterator* iterator) scope {
        bool ret = iterator.forwards.isOutOfRange();
        return ret;
    }

    bool iteratorGetExternal(scope Iterator* iterator, scope out Result!KeyType key, scope out Result!ValueType value) scope @trusted {
        if(iterator.forwards.isOutOfRange()) {
            return false;
        }

        Node* node = iterator.forwards.node;

        // key
        node.onIteratorIn;
        this.rcInternal(true);

        // value
        node.onIteratorIn;
        this.rcInternal(true);

        key = typeof(key)(node.key);
        value = typeof(value)(node.value);
        return true;
    }

    bool iteratorAdvanceExternal(scope Iterator* iterator) scope @trusted {
        Node* old = iterator.forwards.node;
        iterator.forwards.advanceForward(nodeList);
        bool ret = old is iterator.forwards.node;
        return ret;
    }

    int compareExternal(scope HashMapImpl* other) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        assert(other !is null);

        if(&this is other)
            return 0;

        int result = genericCompare(nodeList.aliveNodes, other.nodeList.aliveNodes);

        if(result != 0) {
            Cursor cursor = iteratorList.cursorFor(nodeList);

            foreach(otherNode; other.nodeList) {
                if(result != 0)
                    break;

                if(!cursor.isOutOfRange()) {
                    result = genericCompare(cursor.node.hash, otherNode.hash);

                    if(result == 0)
                        result = genericCompare(cursor.node.key, otherNode.key);
                    if(result == 0)
                        result = genericCompare(cursor.node.value, otherNode.value);

                    cursor.advanceForward(nodeList);
                }
            }

            cursor.onEOL(nodeList);
        }

        return result;
    }

    void clearExternal() scope {
        this.clearAllInternal();
    }

    bool insertExternal(scope KeyType key, return scope ValueType value, bool canUpdate = true) scope {
        bool ret = tryInsertInternal(key, value, canUpdate);
        return ret;
    }

    bool removeExternal(scope KeyType key) scope {
        const hash = nodeList.getHash(key);
        bool ret = tryRemoveInternal(hash);
        return ret;
    }

    HashMapImpl* dupExternal(scope RCAllocator allocator, scope RCAllocator valueAllocator) scope @trusted {
        if(allocator.isNull)
            allocator = globalAllocator();

        HashMapImpl* ret = allocator.make!HashMapImpl(allocator, valueAllocator);

        foreach(node; nodeList) {
            ret.tryInsertInternal(node.key, node.value);
        }
        return ret;
    }

    bool containsExternal(scope KeyType key) scope {
        const hash = nodeList.getHash(key);
        Node* ret = nodeList.nodeFor(hash);
        return ret !is null;
    }

    Result!ValueType getValueExternal(scope KeyType key) scope @trusted {
        const hash = nodeList.getHash(key);
        Node* node = nodeList.nodeFor(hash);

        typeof(return) ret;

        if(node is null) {
            ret = typeof(return)(NullPointerException);
        } else {
            ret = typeof(return)(node.value);
        }

        return ret;
    }

    ulong hashExternal() scope @trusted {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();

        foreach(node; nodeList) {
            ret = hashOf(node.key, ret);
            ret = hashOf(node.value, ret);
        }
        return ret;
    }

    // /\ external
    // \/ internal

    bool rcInternal(bool addRef) scope @trusted {
        if(addRef) {
            nodeList.refCount++;
        } else if(nodeList.refCount == 1) {
            this.clearAllInternal;

            assert(iteratorList.head is null);
            assert(nodeList.allNodes == 0);

            nodeList.cleanup;

            RCAllocator allocator = nodeList.allocator;
            allocator.dispose(&this);
            return false;
        } else {
            nodeList.refCount--;
        }

        return true;
    }

    void clearAllInternal() scope @trusted {
        foreach(ref bucket; nodeList.buckets) {
            Node** currentPtr = &bucket.head.next;

            while(*currentPtr !is &bucket.tail) {
                Node* current = *currentPtr;
                nodeList.removeNode(current);
            }
        }
    }

    bool tryInsertInternal(scope KeyType key, return scope ValueType value, bool canUpdate = true) scope @trusted {
        const hash = nodeList.getHash(key);
        Node* prior = nodeList.priorNodeFor(hash);

        if(prior.next.next !is null && prior.next.hash == hash) {
            // just update

            if(canUpdate) {
                prior.next.key = key;

                static if(isAnyPointer!ValueType) {
                    if(!nodeList.valueAllocator.isNull)
                        nodeList.valueAllocator.dispose(prior.next.value);
                }

                prior.next.value = value;
                return true;
            } else
                return false;
        }

        Node* current = nodeList.createNode(prior, hash);
        current.key = key;
        current.value = value;

        return true;
    }

    bool tryRemoveInternal(ulong hash) {
        Node* node = nodeList.nodeFor(hash);

        if(node !is null) {
            nodeList.removeNode(node);
            return true;
        } else
            return false;
    }

    void appendDeletedNodeToList(scope Node* parent, scope Node* toAdd) scope @trusted {
        assert(parent !is null);
        assert(!parent.isDeleted);
        assert(toAdd !is null);
        assert(!toAdd.isDeleted);

        if(toAdd.previousReadyToBeDeleted !is null)
            nodeList.mergeDeletedListToNewParent(toAdd, parent);
        assert(toAdd.previousReadyToBeDeleted is null);

        assert(toAdd.previous !is null);
        assert(toAdd.next !is null);
        toAdd.previous.next = toAdd.next;
        toAdd.next.previous = toAdd.previous;

        if(parent.previousReadyToBeDeleted !is null) {
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

    int foreachKeyValue(scope Iterator* iterator, scope int delegate(scope KeyType key, scope ref ValueType value) @safe nothrow @nogc del) scope {
        int result;
        Cursor cursor;

        if(iterator is null)
            cursor = iteratorList.cursorFor(nodeList);
        else {
            cursor = iterator.forwards;
            cursor.node.onIteratorIn;
        }

        while(result == 0 && !cursor.isOutOfRange()) {
            result = del(cursor.node.key, cursor.node.value);
            cursor.advanceForward(nodeList);
        }

        cursor.onEOL(nodeList);
        return result;
    }

    void checkForNodes(string func = __FUNCTION__, int line = __LINE__) scope @trusted {
        import core.stdc.stdio : printf;

        size_t seenAlive, seenTotal;

        foreach(ref bucket; nodeList.buckets) {
            Node* currentInBucket = &bucket.head;

            while(currentInBucket !is null) {
                if(currentInBucket.previous !is null && currentInBucket.next !is null) {
                    seenAlive++;
                    seenTotal++;
                }

                Node* currentInDeleted = currentInBucket.previousReadyToBeDeleted;
                while(currentInDeleted !is null) {
                    seenTotal++;
                    currentInDeleted = currentInDeleted.previous;
                }

                currentInBucket = currentInBucket.next;
            }
        }

        if(seenAlive != nodeList.aliveNodes || seenTotal != nodeList.allNodes) {
            printf("seen alive: %zd total: %zd at %s:%d\n", seenAlive, seenTotal, func.ptr, line);
            debugPosition;
            assert(0);
        }
    }

    void debugPosition(scope Iterator* iterator = null) scope @trusted {
        import core.stdc.stdio : printf, stdout, fflush;

        printf("refCount: %zd aliveNodes: %zd allNodes: %zd\n", nodeList.refCount, nodeList.aliveNodes, nodeList.allNodes);

        void printNode(Node* node) {
            if((node.previous is null || node.previous.previous is null) && (node.next is null || node.next.next is null))
                printf("%p = refcount %zd", node, node.refCount);
            else if(node.previous is null || node.previous.previous is null)
                printf("%p =$ refcount %zd", node, node.refCount);
            else if(node.next is null || node.next.next is null)
                printf("%p $= refcount %zd", node, node.refCount);
            else
                printf("%p $=$ refcount %zd", node, node.refCount);

            printf("\n");
        }

        foreach(ref bucket; nodeList.buckets) {
            Node* currentInBucket = &bucket.head;

            if(iterator !is null && iterator.forwards.node is currentInBucket)
                printf(">");

            while(currentInBucket !is null) {
                if(currentInBucket.previous !is null && currentInBucket.next !is null)
                    printNode(currentInBucket);

                Node* currentInDeleted = currentInBucket.previousReadyToBeDeleted;
                while(currentInDeleted !is null) {
                    printf("    DEL ");
                    printNode(currentInDeleted);

                    currentInDeleted = currentInDeleted.previous;
                }

                currentInBucket = currentInBucket.next;
            }
        }

        fflush(stdout);
    }
}

struct HashMapIterator(RealKeyType, ValueType) {
    alias IteratorList = HashMapIterator;
    alias NodeList = HashMapNode!(RealKeyType, ValueType);

    Iterator* head;

@safe nothrow @nogc:

    //@disable this(this);

    Iterator* createIterator(return scope ref NodeList nodeList) scope @trusted {
        Iterator* ret = nodeList.allocator.make!Iterator;
        ret.refCount = 1;

        ret.next = head;
        if(head !is null)
            head.previous = ret;
        head = ret;

        ret.forwards = cursorFor(nodeList);
        return ret;
    }

    Cursor cursorFor(scope ref NodeList nodeList) scope @trusted {
        Cursor ret;
        ret.node = &nodeList.buckets[0].head;

        ret.node.onIteratorIn;
        ret.advanceForward(nodeList);
        return ret;
    }

    int opApply(scope int delegate(scope Iterator* iterator) @safe nothrow @nogc del) scope {
        Iterator* iterator = head;
        int result;

        while(iterator !is null && result == 0) {
            result = del(iterator);
            iterator = iterator.next;
        }

        return result;
    }

    static struct Iterator {
        Iterator* previous, next;
        Cursor forwards;
        ptrdiff_t refCount;

    @safe nothrow @nogc:

        bool rc(bool addRef, scope ref NodeList nodeList, scope ref IteratorList iteratorList) scope @trusted {
            if(addRef)
                refCount++;
            else {
                refCount--;

                if(refCount == 0) {
                    forwards.onEOL(nodeList);

                    if(iteratorList.head is &this) {
                        iteratorList.head = this.next;
                        assert(this.previous is null);
                    }

                    if(this.previous !is null)
                        this.previous.next = this.next;
                    if(this.next !is null)
                        this.next.previous = this.previous;

                    nodeList.allocator.dispose(&this);
                    return true;
                }
            }

            return false;
        }
    }

    static struct Cursor {
        NodeList.Node* node;

    @safe nothrow @nogc:

         export ~this() scope {
            assert(node is null);
        }

        bool isOutOfRange() scope {
            return node is null || node.next is null;
        }

        void onEOL(scope ref NodeList nodeList) scope {
            node.onIteratorOut;

            if(node.isDeleted && node.refCount == 0) {
                nodeList.removeNode(node);
            }

            this.node = null;
        }

        void advanceForward(scope ref NodeList nodeList) scope @trusted {
            ifDeletedBringIntoLife();
            node.onIteratorOut;

            if(node.next !is null && node.next.next !is null) {
                // well that was easy :D
                node = node.next;
            } else {
                // okay we are at the end, gotta skip to the next buckets first item
                size_t bucketId = nodeList.getBucketId(node.hash) + 1;
                // just in case we are already at the end.
                node = &nodeList.buckets[$ - 1].tail;

                while(bucketId < nodeList.buckets.length) {
                    auto bucket = &nodeList.buckets[bucketId];

                    if(bucket.head.next.next !is null) {
                        node = bucket.head.next;
                        break;
                    }

                    bucketId++;
                }
            }

            node.onIteratorIn;
        }

        void ifDeletedBringIntoLife() scope {
            assert(node !is null);
            node.onIteratorOut;

            while(node.isDeleted && node.next !is null) {
                node = node.next;
            }

            node.onIteratorIn;
        }
    }
}

struct HashMapNode(RealKeyType, ValueType) {
    static if(__traits(hasMember, RealKeyType, "asReadOnly")) {
        alias KeyType = typeof(RealKeyType.init.asReadOnly());
        enum KeyIsReadOnly = !is(RealKeyType == KeyType);
    } else {
        alias KeyType = RealKeyType;
        enum KeyIsReadOnly = false;
    }

    RCAllocator allocator, valueAllocator;
    ptrdiff_t refCount;

    Bucket[] buckets;
    size_t allNodes, aliveNodes;

    Bucket[16] smallBucketOptimization;

@safe nothrow @nogc:

    //@disable this(this);

    this(return scope RCAllocator allocator, return scope RCAllocator valueAllocator) scope @trusted {
        this.allocator = allocator;
        this.valueAllocator = valueAllocator;
        this.refCount = 1;

        this.moveIntoBiggerBuckets();
        assert(buckets.length > 0);
    }

    export ~this() {
    }

    void cleanup() scope {
        if(buckets.ptr !is smallBucketOptimization.ptr)
            allocator.dispose(buckets);
    }

    size_t getBucketId(ulong hash, scope Bucket[] buckets = null) scope {
        if(buckets.length == 0)
            buckets = this.buckets;
        assert(buckets.length > 0);

        // modulas may be attractive, but it won't allow for contiguous iteration

        // hash is 0 .. ulong.max
        // must be mapped into
        // buckets is 0 .. buckets.length
        const percentage = hash / cast(float)ulong.max;
        return cast(size_t)(buckets.length * percentage);
    }

    ulong getHash(RealKeyType key) scope {
        import sidero.base.hash.utils : hashOf;

        assert(buckets.length > 0);

        moveIntoBiggerBuckets;
        return hashOf(key);
    }

    static if(KeyIsReadOnly) {
        ulong getHash(KeyType key) scope {
            import sidero.base.hash.utils : hashOf;

            assert(buckets.length > 0);

            moveIntoBiggerBuckets;
            return hashOf(key);
        }
    }

    Node* createNode(ulong hash) scope @trusted {
        return createNode(priorNodeFor(hash), hash);
    }

    Node* createNode(scope Node* prior, ulong hash) scope @trusted {
        assert(prior !is null);
        assert(buckets.length > 0);

        // obivously we can't append to the tail node
        // so we move to the previous one and append to that
        if(prior.next is null)
            prior = prior.previous;

        Node* ret = allocator.make!Node();
        ret.hash = hash;

        ret.previous = prior;
        ret.next = prior.next;
        ret.next.previous = ret;
        prior.next = ret;

        this.allNodes++;
        this.aliveNodes++;
        return ret;
    }

    void removeNode(scope Node* node) scope @trusted {
        assert(node !is null);
        assert(node.previous !is null);
        assert(node.next !is null);

        if(node.previous !is null)
            node.previous.next = node.next;

        if(node.next.previousReadyToBeDeleted is node)
            node.next.previousReadyToBeDeleted = node.previous;
        else {
            node.next.previous = node.previous;

            if(node.previousReadyToBeDeleted !is null)
                mergeDeletedListToNewParent(node, node.next);
        }

        if(node.refCount > 0) {
            node.isDeleted = true;
            this.aliveNodes--;
        } else {
            static if(isAnyPointer!ValueType) {
                if(!valueAllocator.isNull)
                    valueAllocator.dispose(node.value);
            }

            if(!node.isDeleted)
                this.aliveNodes--;

            this.allNodes--;
            allocator.dispose(node);
        }
    }

    Node* nodeFor(ulong hash) scope @trusted {
        assert(buckets.length > 0);

        Bucket* bucket = &buckets[getBucketId(hash)];
        Node* currentNode = &bucket.head;

        // Putting all conditions in while condition,
        //  has a tendency to cause bad codegen.
        while(currentNode.next !is null) {
            if(currentNode.next.next is null)
                break;
            else if(currentNode.next.hash > hash)
                break;

            currentNode = currentNode.next;
        }

        return (currentNode.previous !is null && currentNode.hash == hash) ? currentNode : null;
    }

    Node* priorNodeFor(ulong hash) scope @trusted {
        assert(buckets.length > 0);

        Bucket* bucket = &buckets[getBucketId(hash)];
        Node* currentNode = &bucket.head;

        while(currentNode.next.next !is null && currentNode.next.hash < hash) {
            currentNode = currentNode.next;
        }

        return currentNode;
    }

    void moveIntoBiggerBuckets() scope @trusted {
        size_t nextCountOfBuckets() {
            switch(buckets.length) {
            case 0:
                return 16;
            case 16:
                return 0xFF;
            case 0xFF:
                return 0xFFF;
            case 0xFFF:
                return 0xFFFF;
            default:
                if(buckets.length > 0xFFFF && buckets.length < 0xFFFFFF)
                    return buckets.length * 2;
                else
                    return buckets.length;
            }
        }

        void copyOldIntoNew(scope Bucket[] old, scope Bucket[] into) {
            Bucket* lastIntoBucket;
            Node* priorNode;

            foreach(ref oldBucket; old) {
                Node* currentNode = oldBucket.head.next;

                while(currentNode.next !is null) {
                    Node* nextNode = currentNode.next;
                    Bucket* intoBucket = &into[getBucketId(currentNode.hash, into)];

                    if(intoBucket is lastIntoBucket) {
                        intoBucket.tail.previous = currentNode;
                        priorNode.next = currentNode;

                        currentNode.previous = priorNode;
                        currentNode.next = &intoBucket.tail;

                        priorNode = currentNode;
                    } else {
                        intoBucket.head.next = currentNode;
                        intoBucket.tail.previous = currentNode;
                        currentNode.previous = &intoBucket.head;
                        currentNode.next = &intoBucket.tail;

                        lastIntoBucket = intoBucket;
                        priorNode = currentNode;
                    }

                    currentNode = nextNode;
                }

                if(oldBucket.head.previousReadyToBeDeleted !is null) {
                    mergeDeletedListToNewParent(&oldBucket.head, &into[0].head);
                }

                if(oldBucket.tail.previousReadyToBeDeleted !is null) {
                    mergeDeletedListToNewParent(&oldBucket.tail, &into[$ - 1].tail);
                }
            }
        }

        if(buckets.length * 32 <= aliveNodes) {
            size_t nextCount = nextCountOfBuckets();

            if(nextCount == buckets.length)
                return;

            Bucket[] oldBuckets = buckets;
            Bucket[] newBuckets = buckets.length == 0 ? this.smallBucketOptimization[] : allocator.makeArray!Bucket(nextCount);

            {
                buckets = newBuckets;

                foreach(ref b; newBuckets) {
                    b.head.next = &b.tail;
                    b.tail.previous = &b.head;
                }
            }

            if(oldBuckets.length > 0) {
                copyOldIntoNew(oldBuckets, newBuckets);

                if(oldBuckets.ptr !is smallBucketOptimization.ptr) {
                    allocator.dispose(oldBuckets);
                }
            }
        }
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

        if(endOfNewList !is null) {
            assert(endOfNewList.isDeleted);
            assert(endOfNewList.previousReadyToBeDeleted is null);

            // we have a list on the new parent
            // so we have to get the start of the old list
            // which allows us to append it to the new list
            Node* startOfOldList = endOfOldList;

            while(startOfOldList.previous !is null)
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

    int opApply(int delegate(scope Node* node) @safe nothrow @nogc del) scope @trusted {
        int result;

        foreach(ref bucket; buckets) {
            Node* currentNode = bucket.head.next;

            while(result == 0 && currentNode.next !is null) {
                result = del(currentNode);
                currentNode = currentNode.next;
            }

            if(result != 0)
                break;
        }

        return result;
    }

    static struct Bucket {
        Node head, tail;
    }

    static struct Node {
        Node* previous, previousReadyToBeDeleted, next;
        ulong hash;

        ptrdiff_t refCount;
        bool isDeleted;

        KeyType key;
        ValueType value;

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
