module sidero.base.containers.map.duplicatehashmap;
import sidero.base.allocators;
import sidero.base.attributes;
import sidero.base.traits;
import sidero.base.errors;
import sidero.base.text;

export:

private {
    alias DCHMPII = DuplicateHashMap!(string, string);
}

/// Warning: does no locking
struct DuplicateHashMap(RealKeyType, ValueType) {
    /// If key type supports asReadOnly it is used instead of RealKeyType internally.
    alias KeyType = typeof(state).KeyType;

    private {
        int opApplyImpl(Del)(scope Del del) scope @trusted {
            if(isNull)
                return 0;

            auto iterator = state.createIteratorExternal();
            assert(iterator !is null);
            scope(exit)
                state.rcIteratorExternal(false, iterator);

            int result;

            static if(__traits(compiles, del(gotKey, gotValue))) {
                while(result == 0 && !state.iteratorEmptyExternal(iterator)) {
                    Result!KeyType gotKey;
                    Result!ValueType gotValue;

                    if(state.iteratorGetExternal(iterator, gotKey, gotValue)) {
                        result = del(gotKey, gotValue);

                        if(state.iteratorAdvanceExternal(iterator)) {
                            break;
                        }
                    }
                }
            } else {
                while(result == 0 && !state.iteratorEmptyExternal(iterator)) {
                    Result!KeyType gotKey;
                    Result!ValueType gotValue;

                    if(state.iteratorGetExternal(iterator, gotKey, gotValue)) {
                        result = del(gotKey);

                        if(state.iteratorAdvanceKeyOnlyExternal(iterator)) {
                            break;
                        }
                    }
                }
            }

            return result;
        }
    }

export:

    ///
    mixin OpApplyCombos!(KeyType, void, "opApply", true, true, true, false, false);

@safe nothrow @nogc:

    ///
    this(RCAllocator allocator, RCAllocator valueAllocator = RCAllocator.init) scope @trusted {
        if(allocator.isNull)
            allocator = globalAllocator();

        state = allocator.make!(DuplicateHashMapImpl!(RealKeyType, ValueType))(allocator, valueAllocator);
    }

    ///
    unittest {
        DuplicateHashMap map = DuplicateHashMap(globalAllocator());
        assert(!map.isNull);
    }

    ///
    this(return scope ref DuplicateHashMap other) scope @trusted {
        this.tupleof = other.tupleof;

        if(!isNull)
            state.rcExternal(true);
    }

    ///
    unittest {
        DuplicateHashMap original = DuplicateHashMap(globalAllocator());
        DuplicateHashMap copied = original;
    }

    @disable this(ref return scope const DuplicateHashMap other) scope const;

    ~this() scope {
        if(!isNull)
            state.rcExternal(false);
    }

    void opAssign(return scope DuplicateHashMap other) scope {
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
        return state.nodeList.aliveValues;
    }

    ///
    DuplicateHashMap dup(RCAllocator allocator = RCAllocator.init, RCAllocator valueAllocator = RCAllocator.init) scope {
        if(isNull)
            return DuplicateHashMap.init;

        DuplicateHashMap ret;
        ret.state = state.dupExternal(allocator, valueAllocator);

        return ret;
    }

    ///
    unittest {
        DuplicateHashMap map;
        assert(map.isNull);

        map[RealKeyType.init] ~= ValueType.init;
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

    ///
    DuplicateHashMapByKey opIndex(return scope RealKeyType key) scope return @trusted {
        return DuplicateHashMapByKey(this, key);
    }

    static if(!is(KeyType == RealKeyType)) {
        DuplicateHashMapByKey opIndex(return scope KeyType key) scope return @trusted {
            return DuplicateHashMapByKey(this, key.asReadOnl());
        }
    }

    ///
    void opIndexOpAssign(string op : "~")(return scope ValueType value, return scope RealKeyType key) scope @trusted {
        setupState;
        willModify;

        static if(!is(KeyType == RealKeyType)) {
            state.insertExternal(key.asReadOnly(), value);
        } else {
            state.insertExternal(key, value);
        }
    }

    ///
    bool opBinaryRight(string op : "in")(scope RealKeyType key) scope @trusted {
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
        DuplicateHashMap map;
        assert(map.isNull);
        assert(RealKeyType.init !in map);

        map[RealKeyType.init] ~= ValueType.init;
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
        DuplicateHashMap map;
        assert(map.isNull);
        assert(RealKeyType.init !in map);

        map[RealKeyType.init] ~= ValueType.init;
        assert(!map.isNull);
        assert(map.length == 1);
        assert(RealKeyType.init in map);

        auto got = map[RealKeyType.init];

        map.remove(RealKeyType.init);
        assert(map.length == 0);
        assert(RealKeyType.init !in map);
    }

    ///
    bool remove(scope RealKeyType key, scope ValueType value) scope @trusted {
        if(isNull)
            return false;
        willModify;

        static if(!is(KeyType == RealKeyType)) {
            return state.removeExternal(key.asReadOnly, value);
        } else {
            return state.removeExternal(key, value);
        }
    }

    ///
    unittest {
        DuplicateHashMap map;
        assert(map.isNull);
        assert(RealKeyType.init !in map);

        map[RealKeyType.init] ~= ValueType.init;
        assert(!map.isNull);
        assert(map.length == 1);
        assert(RealKeyType.init in map);

        map[RealKeyType.init] ~= ValueType.init;
        assert(map.length == 2);

        auto got = map[RealKeyType.init];

        map.remove(RealKeyType.init, ValueType.init);
        assert(map.length == 0);
        assert(RealKeyType.init !in map);
    }

    ///
    void clear() scope {
        if(!isNull)
            state.clearExternal;
    }

    @disable auto opCast(T)();

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils : hashOf;

        if(isNull)
            return hashOf();

        return (cast(DuplicateHashMapImpl!(RealKeyType, ValueType)*)state).hashExternal;
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope DuplicateHashMap other) scope const {
        return this.opCmp(other) == 0;
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope DuplicateHashMap other) scope const @trusted {
        if(isNull)
            return other.isNull ? 0 : -1;
        else if(other.isNull)
            return 1;
        return (cast(DuplicateHashMapImpl!(RealKeyType, ValueType)*)state).compareExternal((cast(DuplicateHashMapImpl!(RealKeyType,
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
            builder ~= "DuplicateHashMap!(" ~ KeyType.stringof ~ ", " ~ ValueType.stringof ~ ")@null";
        else
            builder.formattedWrite("DuplicateHashMap!(" ~ KeyType.stringof ~ ", " ~ ValueType.stringof ~ ")@{:p}(length={:d}",
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
        enum FQN = __traits(fullyQualifiedName, DuplicateHashMap);
        pp.emitPrefix(builder);

        if(isNull) {
            builder ~= FQN ~ "@null";
            return;
        }

        builder.formattedWrite(FQN ~ "@{:p}(length={:d} =>\n", cast(void*)this.state, this.length);
        pp.depth++;

        bool haveOne;

        foreach(ref k; this) {
            if(haveOne)
                builder ~= "\n";
            haveOne = true;

            pp.startWithoutPrefix = false;
            pp.emitPrefix(builder);
            builder.formattedWrite("{:s}: ", k);

            foreach(ref v; this[k]) {
                pp.depth++;

                pp.startWithoutPrefix = true;
                pp(builder, v);
                builder ~= "\n";

                pp.depth--;
            }
        }

        pp.depth--;
        builder ~= ")";
    }

    ///
    static struct DuplicateHashMapByKey {
        private {
            DuplicateHashMap hashmap;
            RealKeyType key;

            int opApplyImpl(Del)(scope Del del) scope @trusted {
                if(hashmap.isNull)
                    return 0;

                auto cursor = hashmap.state.iteratorList.cursorFor(hashmap.state.nodeList, key);
                scope(exit)
                    cursor.onEOL(hashmap.state.nodeList);

                int result;
                while(result == 0 && !cursor.isOutOfRange()) {
                    auto value = cursor.valueNode.value;
                    result = del(value);
                    cursor.advanceForward(hashmap.state.nodeList, false, true);
                }

                return result;
            }
        }

    export:

        this(return scope ref DuplicateHashMapByKey other) scope {
            this.tupleof = other.tupleof;
        }

        ~this() scope {
        }

        void opAssign(return scope DuplicateHashMapByKey other) scope {
            this.destroy;
            this.__ctor(other);
        }

        ///
        mixin OpApplyCombos!(ValueType, void, "opApply", true, true, true, false, false);

        ///
        unittest {
            DuplicateHashMap cll;
            cll[KeyType.init] ~= ValueType.init;
            cll[KeyType.init] ~= ValueType.init;

            int count;

            foreach(v; cll[KeyType.init]) {
                assert(v == ValueType.init);
                count++;
            }

            assert(count == 2);
        }
    }

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        @PrettyPrintIgnore DuplicateHashMapImpl!(RealKeyType, ValueType)* state;

        void setupState() scope @trusted {
            if(!isNull)
                return;

            RCAllocator allocator = globalAllocator();
            state = allocator.make!(DuplicateHashMapImpl!(RealKeyType, ValueType))(allocator, RCAllocator.init);
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
}

private:

struct DuplicateHashMapImpl(RealKeyType, ValueType) {
    DuplicativeHashMapNode!(RealKeyType, ValueType) nodeList;
    DuplicativeHashMapIterator!(RealKeyType, ValueType) iteratorList;

    bool copyOnWrite, keepNoExternalReferences;

    alias Bucket = typeof(nodeList).Bucket;
    alias KeyType = typeof(nodeList).KeyType;
    alias KeyNode = typeof(nodeList).KeyNode;
    alias ValueNode = typeof(nodeList).ValueNode;
    alias Iterator = typeof(iteratorList).Iterator;
    alias Cursor = typeof(iteratorList).Cursor;

export @safe nothrow @nogc:

    this(return scope RCAllocator allocator, return scope RCAllocator valueAllocator) scope @trusted {
        nodeList = typeof(nodeList)(allocator, valueAllocator);
        keepNoExternalReferences = true;
    }

    void rcExternal(bool addRef) scope @trusted {
        rcInternal(addRef);
    }

    void rcIteratorExternal(bool addRef, scope Iterator* iterator) {
        assert(!addRef);

        if(!iterator.rc(addRef, nodeList, iteratorList) || rcInternal(addRef)) {
        }
    }

    void rcNodeExternal(bool addRef, scope KeyNode* keyNode, scope ValueNode* valueNode) scope {
        if(valueNode !is null) {
            if(addRef)
                valueNode.onIteratorIn;
            else
                valueNode.onIteratorOut;

            if(valueNode.refCount == 0 && (valueNode.isDeleted || !this.keepNoExternalReferences)) {
                if(!nodeList.removeValue(keyNode, valueNode))
                    keyNode = null;
            }
        }

        if(keyNode !is null) {
            if(addRef)
                keyNode.onIteratorIn;
            else
                keyNode.onIteratorOut;

            if(keyNode.refCount == 0 && (keyNode.isDeleted || !this.keepNoExternalReferences))
                nodeList.removeKey(keyNode);
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

        KeyNode* keyNode = iterator.forwards.keyNode;
        ValueNode* valueNode = iterator.forwards.valueNode;

        // key
        keyNode.onIteratorIn;
        this.rcInternal(true);

        // value
        valueNode.onIteratorIn;
        this.rcInternal(true);

        key = typeof(key)(keyNode.key);
        value = typeof(value)(valueNode.value);
        return true;
    }

    bool iteratorAdvanceExternal(scope Iterator* iterator) scope @trusted {
        KeyNode* oldKeyNode = iterator.forwards.keyNode;
        ValueNode* oldValueNode = iterator.forwards.valueNode;

        iterator.forwards.advanceForward(nodeList, false, false);

        bool ret = oldKeyNode is iterator.forwards.keyNode && oldValueNode is iterator.forwards.valueNode;
        return ret;
    }

    bool iteratorAdvanceKeyOnlyExternal(scope Iterator* iterator) scope @trusted {
        KeyNode* oldKeyNode = iterator.forwards.keyNode;

        iterator.forwards.advanceForward(nodeList, true, false);

        bool ret = oldKeyNode is iterator.forwards.keyNode;
        return ret;
    }

    void insertExternal(scope KeyType key, scope ValueType value) scope {
        nodeList.insertInternal(key, value);
    }

    bool removeExternal(scope KeyType key) scope {
        const hash = nodeList.getHash(key);
        KeyNode* node = nodeList.nodeFor(hash, key);

        if(node !is null) {
            nodeList.removeKey(node);
            return true;
        } else
            return false;
    }

    bool removeExternal(scope KeyType key, ValueType value) scope {
        const hash = nodeList.getHash(key);
        KeyNode* node = nodeList.nodeFor(hash, key);
        ValueNode* valueNode = node.head.next;
        bool doneOne;

        while(valueNode.next !is null) {
            ValueNode* next = valueNode.next;

            if(valueNode.value == value) {
                nodeList.removeValue(node, valueNode);
                doneOne = true;
            }

            valueNode = next;
        }

        return doneOne;
    }

    void clearExternal() scope @trusted {
        this.clearAllInternal();
    }

    bool containsExternal(scope KeyType key) scope {
        const hash = nodeList.getHash(key);
        KeyNode* ret = nodeList.nodeFor(hash, key);
        return ret !is null;
    }

    int compareExternal(scope DuplicateHashMapImpl* other) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        assert(other !is null);

        if(&this is other)
            return 0;

        int result = genericCompare(nodeList.aliveValues, other.nodeList.aliveValues);
        if(result != 0)
            return result;

        ptrdiff_t ourBucketId, otherBucketId;
        Bucket* ourBucket, otherBucket;
        KeyNode* ourKeyNode, otherKeyNode;
        ValueNode* ourValueNode, otherValueNode;

        int advanceBuckets() {
            ourBucketId++;
            otherBucketId++;

            if(ourBucketId < nodeList.buckets.length) {
                ourBucket = &nodeList.buckets[ourBucketId];
            } else
                return otherBucketId < other.nodeList.buckets.length ? -1 : 0;

            if(otherBucketId < other.nodeList.buckets.length) {
                otherBucket = &other.nodeList.buckets[otherBucketId];
            } else
                return 1;

            ourKeyNode = ourBucket.head.next;
            otherKeyNode = otherBucket.head.next;

            if(ourKeyNode.next is null && otherKeyNode.next !is null)
                return -1;
            else if(ourKeyNode.next !is null && otherKeyNode.next is null)
                return 1;

            ourValueNode = ourKeyNode.head.next;
            otherValueNode = otherKeyNode.head.next;
            return 0;
        }

        int advanceKeys() {
            ourKeyNode = ourKeyNode.next;
            otherKeyNode = otherKeyNode.next;

            if(ourKeyNode.next is null && otherKeyNode.next !is null)
                return -1;
            else if(ourKeyNode.next !is null && otherKeyNode.next is null)
                return 1;

            ourValueNode = ourKeyNode.head.next;
            otherValueNode = otherKeyNode.head.next;
            return 0;
        }

        int advanceValues() {
            ourValueNode = ourValueNode.next;
            otherValueNode = otherValueNode.next;

            if(ourValueNode.next is null && otherValueNode.next !is null)
                return -1;
            else if(ourValueNode.next !is null && otherValueNode.next is null)
                return 1;

            return 0;
        }

        while((result = advanceBuckets()) == 0 && ourBucket !is null) {
            assert(otherBucket !is null);

            do {
                assert(ourKeyNode !is null);
                assert(otherKeyNode !is null);

                result = genericCompare(ourKeyNode.key, otherKeyNode.key);
                if(result != 0)
                    return result;

                do {
                    assert(ourValueNode !is null);
                    assert(otherValueNode !is null);

                    result = genericCompare(ourValueNode.value, otherValueNode.value);
                    if(result != 0)
                        return result;
                }
                while((result = advanceValues()) == 0 && ourValueNode !is null);

            }
            while((result = advanceKeys()) == 0 && ourKeyNode !is null);
        }

        return result;
    }

    ulong hashExternal() scope @trusted {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();

        foreach(ref bucket; nodeList.buckets) {
            KeyNode* currentKeyNode = bucket.head.next;
            ret = hashOf(currentKeyNode.key, ret);

            while(currentKeyNode !is &bucket.tail) {
                ValueNode* currentValueNode = currentKeyNode.head.next;

                while(currentValueNode.next !is null) {
                    ret = hashOf(currentValueNode.value, ret);

                    currentValueNode = currentValueNode.next;
                }
            }
        }

        return ret;
    }

    DuplicateHashMapImpl* dupExternal(scope RCAllocator allocator, scope RCAllocator valueAllocator) scope @trusted {
        if(allocator.isNull)
            allocator = globalAllocator();

        DuplicateHashMapImpl* ret = allocator.make!DuplicateHashMapImpl(allocator, valueAllocator);

        foreach(ref bucket; nodeList.buckets) {
            KeyNode* currentKeyNode = bucket.head.next;

            while(currentKeyNode !is &bucket.tail) {
                ValueNode* currentValueNode = currentKeyNode.head.next;

                while(currentValueNode.next !is null) {
                    ret.insertExternal(currentKeyNode.key, currentValueNode.value);

                    currentValueNode = currentValueNode.next;
                }

                currentKeyNode = currentKeyNode.next;
            }
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
            KeyNode* keyNode = bucket.head.next;

            while(keyNode.next !is null) {
                KeyNode* next = keyNode.next;
                nodeList.removeKey(keyNode);
                keyNode = next;
            }
        }
    }

    void debugPosition(scope Iterator* iterator = null) scope @trusted {
        import core.stdc.stdio : printf, stdout, fflush;

        printf("refCount: %zd, aliveKeys: %zd, aliveValues: %zd, allNodes: %zd, allKeys: %zd, allValues: %zd\n",
                nodeList.refCount, nodeList.aliveKeys, nodeList.aliveValues, nodeList.allNodes, nodeList.allKeys, nodeList.allValues);

        void printValueNode(ValueNode* valueNode) {
            if(iterator !is null && iterator.forwards.valueNode is valueNode)
                printf("    > ");
            else
                printf("    - ");

            if(valueNode.previous is null)
                printf("%p $= refcount %zd\n", valueNode, valueNode.refCount);
            else if(valueNode.next is null)
                printf("%p =$ refcount %zd\n", valueNode, valueNode.refCount);
            else
                printf("%p = refcount %zd\n", valueNode, valueNode.refCount);
        }

        void printKeyNode(KeyNode* keyNode) {
            if((keyNode.previous is null || keyNode.previous.previous is null) && (keyNode.next is null || keyNode.next.next is null))
                printf("%p = refcount %zd\n", keyNode, keyNode.refCount);
            else if(keyNode.previous is null || keyNode.previous.previous is null)
                printf("%p =$ refcount %zd\n", keyNode, keyNode.refCount);
            else if(keyNode.next is null || keyNode.next.next is null)
                printf("%p $= refcount %zd\n", keyNode, keyNode.refCount);
            else
                printf("%p $=$ refcount %zd\n", keyNode, keyNode.refCount);

            ValueNode* valueNode = &keyNode.head;

            while(valueNode !is null) {
                printValueNode(valueNode);
                valueNode = valueNode.next;
            }
        }

        foreach(ref bucket; nodeList.buckets) {
            KeyNode* currentInBucket = &bucket.head;

            if(iterator !is null && iterator.forwards.keyNode is currentInBucket)
                printf(">");

            while(currentInBucket !is null) {
                if(currentInBucket.previous !is null && currentInBucket.next !is null)
                    printKeyNode(currentInBucket);

                KeyNode* currentInDeleted = currentInBucket.previousReadyToBeDeleted;
                while(currentInDeleted !is null) {
                    printf("    DEL ");
                    printKeyNode(currentInDeleted);

                    currentInDeleted = currentInDeleted.previous;
                }

                currentInBucket = currentInBucket.next;
            }
        }

        fflush(stdout);
    }
}

struct DuplicativeHashMapIterator(RealKeyType, ValueType) {
    alias IteratorList = DuplicativeHashMapIterator;
    alias NodeList = DuplicativeHashMapNode!(RealKeyType, ValueType);

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
        ret.keyNode = &nodeList.buckets[0].head;
        ret.valueNode = &ret.keyNode.head;

        ret.keyNode.onIteratorIn;
        ret.valueNode.onIteratorIn;
        ret.advanceForward(nodeList, false, false);
        return ret;
    }

    Cursor cursorFor(scope ref NodeList nodeList, RealKeyType key) scope @trusted {
        Cursor ret;

        const hash = nodeList.getHash(key);

        auto keyNode = nodeList.nodeFor(hash, key);
        if (keyNode is null)
            return ret;

        ret.keyNode = keyNode;
        ret.valueNode = &ret.keyNode.head;

        ret.keyNode.onIteratorIn;
        ret.valueNode.onIteratorIn;
        ret.advanceForward(nodeList, false, false);
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
        NodeList.KeyNode* keyNode;
        NodeList.ValueNode* valueNode;

    @safe nothrow @nogc:

         ~this() scope {
            assert(keyNode is null);
        }

        bool isOutOfRange() scope {
            return keyNode is null || keyNode.next is null || valueNode is null || valueNode.next is null;
        }

        void onEOL(scope ref NodeList nodeList) scope {
            if (keyNode is null)
                return;

            keyNode.onIteratorOut;
            valueNode.onIteratorOut;

            bool keyNodeExists = true;

            if(valueNode.isDeleted && valueNode.refCount == 0)
                keyNodeExists = nodeList.removeValue(keyNode, valueNode);

            if(keyNodeExists && keyNode.isDeleted)
                nodeList.removeKey(keyNode);

            this.keyNode = null;
            this.valueNode = null;
        }

        void advanceForward(scope ref NodeList nodeList, bool advanceKeyOnly, bool advanceValueOnly) scope @trusted {
            ifDeletedBringIntoLife();
            keyNode.onIteratorOut;
            valueNode.onIteratorOut;

            if(!advanceKeyOnly && valueNode.next !is null) {
                // move to the next value
                valueNode = valueNode.next;
            } else if(!advanceValueOnly) {
                if(keyNode.next !is null && keyNode.next.next !is null) {
                    // move to the next key
                    keyNode = keyNode.next;
                    valueNode = keyNode.head.next;
                } else {
                    // okay we are at the end, gotta skip to the next buckets first item
                    size_t bucketId = nodeList.getBucketId(keyNode.hash) + 1;

                    if(bucketId == nodeList.buckets.length) {
                        keyNode = null;
                        valueNode = null;
                        return;
                    }

                    // just in case we are already at the end.
                    keyNode = &nodeList.buckets[$ - 1].tail;

                    while(bucketId < nodeList.buckets.length) {
                        auto bucket = &nodeList.buckets[bucketId];

                        if(bucket.head.next.next !is null) {
                            keyNode = bucket.head.next;
                            valueNode = keyNode.head.next;
                            break;
                        }

                        bucketId++;
                    }
                }
            } else {
                keyNode = null;
                valueNode = null;
                return;
            }

            keyNode.onIteratorIn;
            valueNode.onIteratorIn;
        }

        void ifDeletedBringIntoLife() scope {
            assert(keyNode !is null);
            assert(valueNode !is null);

            keyNode.onIteratorOut;
            valueNode.onIteratorOut;

            if(keyNode.isDeleted) {
                while(keyNode.isDeleted && keyNode.next !is null) {
                    keyNode = keyNode.next;
                }

                valueNode = keyNode.head.next;
            } else if(valueNode.isDeleted) {
                while(valueNode.isDeleted && valueNode.next !is null) {
                    valueNode = valueNode.next;
                }
            }

            keyNode.onIteratorIn;
            valueNode.onIteratorIn;
        }
    }
}

struct DuplicativeHashMapNode(RealKeyType, ValueType) {
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
    size_t allNodes;
    size_t allKeys, allValues;
    size_t aliveKeys, aliveValues;

    Bucket[16] smallBucketOptimization;

@safe nothrow @nogc:

    this(return scope RCAllocator allocator, return scope RCAllocator valueAllocator) scope @trusted {
        this.allocator = allocator;
        this.valueAllocator = valueAllocator;
        this.refCount = 1;

        this.moveIntoBiggerBuckets();
        assert(buckets.length > 0);
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

    KeyNode* nodeFor(ulong hash, scope KeyType key) scope @trusted {
        assert(buckets.length > 0);

        Bucket* bucket = &buckets[getBucketId(hash)];
        KeyNode* currentNode = &bucket.head;

        while(currentNode.next.next !is null && currentNode.next.hash <= hash && currentNode.next.key <= key) {
            currentNode = currentNode.next;
        }

        return (currentNode.previous !is null && currentNode.hash == hash && currentNode.key == key) ? currentNode : null;
    }

    KeyNode* priorNodeFor(ulong hash, scope KeyType key) scope @trusted {
        assert(buckets.length > 0);

        Bucket* bucket = &buckets[getBucketId(hash)];
        KeyNode* currentNode = &bucket.head;

        while(currentNode.next.next !is null && (currentNode.next.hash < hash || currentNode.next.key < key)) {
            currentNode = currentNode.next;
        }

        return currentNode;
    }

    void insertInternal(return scope KeyType key, return scope ValueType value) scope @trusted {
        const hash = getHash(key);
        KeyNode* priorKeyNode = priorNodeFor(hash, key);
        KeyNode* currentKeyNode;

        if(priorKeyNode.next.hash != hash || priorKeyNode.next.key != key) {
            currentKeyNode = allocator.make!KeyNode();
            currentKeyNode.hash = hash;
            currentKeyNode.key = key;

            currentKeyNode.head.next = &currentKeyNode.tail;
            currentKeyNode.tail.previous = &currentKeyNode.head;

            currentKeyNode.previous = priorKeyNode;
            currentKeyNode.next = priorKeyNode.next;
            priorKeyNode.next = currentKeyNode;

            this.aliveKeys++;
            this.allKeys++;
            this.allNodes++;
        } else
            currentKeyNode = priorKeyNode.next;

        {
            auto newValueNode = allocator.make!ValueNode();
            newValueNode.value = value;

            newValueNode.next = currentKeyNode.head.next;
            newValueNode.previous = &currentKeyNode.head;

            currentKeyNode.head.next.previous = newValueNode;
            currentKeyNode.head.next = newValueNode;

            this.aliveValues++;
            this.allValues++;
            this.allNodes++;
        }
    }

    void removeKey(scope KeyNode* keyNode) scope @trusted {
        assert(keyNode !is null);
        assert(keyNode.previous !is null);
        assert(keyNode.next !is null);

        if(keyNode.previous !is null)
            keyNode.previous.next = keyNode.next;

        if(keyNode.next.previousReadyToBeDeleted is keyNode)
            keyNode.next.previousReadyToBeDeleted = keyNode.previous;
        else {
            keyNode.next.previous = keyNode.previous;

            if(keyNode.previousReadyToBeDeleted !is null)
                mergeDeletedListToNewParent(keyNode, keyNode.next);
        }

        if(keyNode.refCount > 0) {
            keyNode.isDeleted = true;
            this.aliveKeys--;
        } else {
            ValueNode* currentValueNode = keyNode.head.next;

            while(currentValueNode.next !is null) {
                assert(currentValueNode.refCount == 0);
                ValueNode* next = currentValueNode.next;

                static if(isAnyPointer!ValueType) {
                    if(!valueAllocator.isNull)
                        valueAllocator.dispose(currentValueNode.value);
                }

                if(!currentValueNode.isDeleted)
                    this.aliveValues--;

                this.allValues--;
                this.allNodes--;
                allocator.dispose(currentValueNode);
                currentValueNode = next;
            }

            if(!keyNode.isDeleted)
                this.aliveKeys--;

            this.allKeys--;
            this.allNodes--;
            allocator.dispose(keyNode);
        }
    }

    bool removeValue(scope KeyNode* keyNode, scope ValueNode* valueNode) scope @trusted {
        assert(keyNode !is null);
        assert(keyNode.previous !is null);
        assert(keyNode.next !is null);

        if(valueNode.previous !is null)
            valueNode.previous.next = valueNode.next;

        if(valueNode.next.previousReadyToBeDeleted is valueNode)
            valueNode.next.previousReadyToBeDeleted = valueNode.previous;
        else {
            valueNode.next.previous = valueNode.previous;

            if(valueNode.previousReadyToBeDeleted !is null)
                mergeDeletedListToNewParent(valueNode, valueNode.next);
        }

        if(valueNode.refCount > 0) {
            valueNode.isDeleted = true;
            this.aliveValues--;
        } else {
            if(keyNode.tail.previous is valueNode) {
                keyNode.tail.previous = valueNode.previous;
                keyNode.tail.previous.next = &keyNode.tail;
            }

            if(keyNode.head.next is valueNode) {
                keyNode.head.next = valueNode.next;
                keyNode.head.next.previous = &keyNode.head;
            }

            static if(isAnyPointer!ValueType) {
                if(!valueAllocator.isNull)
                    valueAllocator.dispose(valueNode.value);
            }

            if(!valueNode.isDeleted)
                this.aliveValues--;

            this.allNodes--;
            allocator.dispose(valueNode);

            if(keyNode.head.next.next is null) {
                this.removeKey(keyNode);
                return false;
            }
        }

        return true;
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
            KeyNode* priorNode;

            foreach(ref oldBucket; old) {
                KeyNode* currentNode = oldBucket.head.next;

                while(currentNode.next !is null) {
                    KeyNode* nextNode = currentNode.next;
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
            }
        }

        if(buckets.length * 32 <= this.aliveKeys) {
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

    void mergeDeletedListToNewParent(scope KeyNode* oldParent, scope KeyNode* newParent) scope @trusted {
        assert(oldParent !is null);
        assert(!oldParent.isDeleted);
        assert(newParent !is null);
        assert(!newParent.isDeleted);

        KeyNode* endOfOldList = oldParent.previousReadyToBeDeleted;
        assert(endOfOldList !is null);
        assert(endOfOldList.isDeleted);
        assert(endOfOldList.previousReadyToBeDeleted is null);

        KeyNode* endOfNewList = newParent.previousReadyToBeDeleted;

        if(endOfNewList !is null) {
            assert(endOfNewList.isDeleted);
            assert(endOfNewList.previousReadyToBeDeleted is null);

            // we have a list on the new parent
            // so we have to get the start of the old list
            // which allows us to append it to the new list
            KeyNode* startOfOldList = endOfOldList;

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

    void mergeDeletedListToNewParent(scope ValueNode* oldParent, scope ValueNode* newParent) scope @trusted {
        assert(oldParent !is null);
        assert(!oldParent.isDeleted);
        assert(newParent !is null);
        assert(!newParent.isDeleted);

        ValueNode* endOfOldList = oldParent.previousReadyToBeDeleted;
        assert(endOfOldList !is null);
        assert(endOfOldList.isDeleted);
        assert(endOfOldList.previousReadyToBeDeleted is null);

        ValueNode* endOfNewList = newParent.previousReadyToBeDeleted;

        if(endOfNewList !is null) {
            assert(endOfNewList.isDeleted);
            assert(endOfNewList.previousReadyToBeDeleted is null);

            // we have a list on the new parent
            // so we have to get the start of the old list
            // which allows us to append it to the new list
            ValueNode* startOfOldList = endOfOldList;

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

    static struct Bucket {
        KeyNode head, tail;
    }

    static struct KeyNode {
        KeyNode* previous, previousReadyToBeDeleted, next;
        ulong hash;

        KeyType key;
        ValueNode head, tail;

        ptrdiff_t refCount;
        bool isDeleted;

    @trusted nothrow @nogc:

        void onIteratorIn() {
            refCount++;
        }

        void onIteratorOut() {
            refCount--;
            assert(refCount >= 0);
        }
    }

    static struct ValueNode {
        ValueNode* previous, previousReadyToBeDeleted, next;
        ValueType value;

        ptrdiff_t refCount;
        bool isDeleted;

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
