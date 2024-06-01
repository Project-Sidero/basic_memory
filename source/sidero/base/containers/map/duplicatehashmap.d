module sidero.base.containers.map.duplicatehashmap;
import sidero.base.internal.atomic;
import sidero.base.allocators;
import sidero.base.attributes;
import sidero.base.traits;

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
            if (isNull)
                return 0;

            int result;

            foreach (ref bucket; state.nodeList.buckets) {
                auto kn = bucket.head.next;

                while (kn !is null) {
                    result = del(kn.key);
                    if (result)
                        return result;
                    kn = kn.next;
                }
            }

            return result;
        }
    }

export:

    ///
    mixin OpApplyCombos!("KeyType", null, ["@safe", "nothrow", "@nogc"]);

@safe nothrow @nogc:

    ///
    this(RCAllocator allocator, RCAllocator valueAllocator = RCAllocator.init) scope @trusted {
        if (allocator.isNull)
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

        if (!isNull)
            state.rcExternal(true);
    }

    ///
    unittest {
        DuplicateHashMap original = DuplicateHashMap(globalAllocator());
        DuplicateHashMap copied = original;
    }

    @disable this(ref return scope const DuplicateHashMap other) scope const;

    ~this() scope {
        if (!isNull)
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
        if (isNull)
            return 0;
        return state.nodeList.allNodes;
    }

    ///
    DuplicateHashMap dup(RCAllocator allocator = RCAllocator.init, RCAllocator valueAllocator = RCAllocator.init) scope {
        if (isNull)
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
        if (!isNull)
            state.copyOnWrite = true;
    }

    ///
    void cleanupUnreferencedNodes() {
        if (!isNull)
            state.keepNoExternalReferences = false;
    }

    ///
    DuplicateHashMapByKey opIndex(return scope RealKeyType key) scope return @trusted {
        return DuplicateHashMapByKey(this, key);
    }

    static if (!is(KeyType == RealKeyType)) {
        DuplicateHashMapByKey opIndex(return scope KeyType key) scope return @trusted {
            return DuplicateHashMapByKey(this, key.asReadOnl());
        }
    }

    ///
    void opIndexOpAssign(string op : "~")(return scope ValueType value, return scope RealKeyType key) scope @trusted {
        setupState;
        willModify;

        static if (!is(KeyType == RealKeyType)) {
            state.insertExternal(key.asReadOnly(), value);
        } else {
            state.insertExternal(key, value);
        }
    }

    ///
    bool opBinaryRight(string op : "in")(scope RealKeyType key) scope @trusted {
        if (isNull)
            return false;

        static if (!is(KeyType == RealKeyType)) {
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
        if (isNull)
            return false;
        willModify;

        static if (!is(KeyType == RealKeyType)) {
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
    void clear() scope {
        if (!isNull)
            state.clearExternal;
    }

    @disable auto opCast(T)();

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils : hashOf;

        if (isNull)
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
        if (isNull)
            return other.isNull ? 0 : -1;
        else if (other.isNull)
            return 1;
        return (cast(DuplicateHashMapImpl!(RealKeyType, ValueType)*)state).compareExternal((cast(DuplicateHashMapImpl!(RealKeyType,
                ValueType)*)other.state));
    }

    ///
    static struct DuplicateHashMapByKey {
        private {
            DuplicateHashMap hashmap;
            RealKeyType key;

            int opApplyImpl(Del)(scope Del del) scope @trusted {
                if (hashmap.isNull)
                    return 0;

                const hash = hashmap.state.nodeList.getHash(key);
                auto keyNode = hashmap.state.nodeList.nodeFor(hash, key);

                if (keyNode is null)
                    return 0;

                int result;
                auto valueNode = keyNode.head;

                while (result == 0 && valueNode !is null) {
                    auto value = valueNode.value;
                    result = del(value);
                    valueNode = valueNode.next;
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
        mixin OpApplyCombos!("ValueType", null, ["@safe", "nothrow", "@nogc"]);

        ///
        unittest {
            DuplicateHashMap cll;
            cll[KeyType.init] ~= ValueType.init;
            cll[KeyType.init] ~= ValueType.init;

            int count;

            foreach (v; cll[KeyType.init]) {
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
            if (!isNull)
                return;

            RCAllocator allocator = globalAllocator();
            state = allocator.make!(DuplicateHashMapImpl!(RealKeyType, ValueType))(allocator, RCAllocator.init);
        }

        void willModify() scope {
            if (state.copyOnWrite) {
                this = this.dup;
            }
        }
    }
}

private:

struct DuplicateHashMapImpl(RealKeyType, ValueType) {
    DuplicativeHashMapNode!(RealKeyType, ValueType) nodeList;

    bool copyOnWrite, keepNoExternalReferences;

    alias Bucket = typeof(nodeList).Bucket;
    alias KeyType = typeof(nodeList).KeyType;
    alias KeyNode = typeof(nodeList).KeyNode;
    alias ValueNode = typeof(nodeList).ValueNode;

export @safe nothrow @nogc:

    this(return scope RCAllocator allocator, return scope RCAllocator valueAllocator) scope @trusted {
        nodeList = typeof(nodeList)(allocator, valueAllocator);
        keepNoExternalReferences = true;
    }

    void rcExternal(bool addRef) scope @trusted {
        if (addRef) {
            atomicIncrementAndLoad(nodeList.refCount, 1);
        } else if (atomicDecrementAndLoad(nodeList.refCount, 1) == 0) {
            this.clearExternal;

            nodeList.cleanup;

            RCAllocator allocator = nodeList.allocator;
            allocator.dispose(&this);
        }
    }

    void insertExternal(scope KeyType key, scope ValueType value) scope {
        nodeList.insertInternal(key, value);
    }

    bool removeExternal(scope KeyType key) scope {
        const hash = nodeList.getHash(key);
        KeyNode* node = nodeList.nodeFor(hash, key);

        if (node !is null) {
            nodeList.removeNode(node);
            return true;
        } else
            return false;
    }

    void clearExternal() scope @trusted {
        foreach (ref bucket; nodeList.buckets) {
            KeyNode** currentPtr = &bucket.head.next;

            while (*currentPtr !is &bucket.tail) {
                KeyNode* current = *currentPtr;
                nodeList.removeNode(current);
            }
        }
    }

    bool containsExternal(scope KeyType key) scope {
        const hash = nodeList.getHash(key);
        KeyNode* ret = nodeList.nodeFor(hash, key);
        return ret !is null;
    }

    int compareExternal(scope DuplicateHashMapImpl* other) scope @trusted {
        import sidero.base.containers.utils : genericCompare;

        assert(other !is null);

        if (&this is other)
            return 0;

        int result = genericCompare(nodeList.allNodes, other.nodeList.allNodes);
        if (result != 0)
            return result;

        ptrdiff_t ourBucketId, otherBucketId;
        Bucket* ourBucket, otherBucket;
        KeyNode* ourKeyNode, otherKeyNode;
        ValueNode* ourValueNode, otherValueNode;

        int advanceBuckets() {
            ourBucketId++;
            otherBucketId++;

            if (ourBucketId < nodeList.buckets.length) {
                ourBucket = &nodeList.buckets[ourBucketId];
            } else
                return otherBucketId < other.nodeList.buckets.length ? -1 : 0;

            if (otherBucketId < other.nodeList.buckets.length) {
                otherBucket = &other.nodeList.buckets[otherBucketId];
            } else
                return 1;

            ourKeyNode = ourBucket.head.next;
            otherKeyNode = otherBucket.head.next;

            if (ourKeyNode.next is null && otherKeyNode.next !is null)
                return -1;
            else if (ourKeyNode.next !is null && otherKeyNode.next is null)
                return 1;

            ourValueNode = ourKeyNode.head;
            otherValueNode = otherKeyNode.head;
            return 0;
        }

        int advanceKeys() {
            ourKeyNode = ourKeyNode.next;
            otherKeyNode = otherKeyNode.next;

            if (ourKeyNode.next is null && otherKeyNode.next !is null)
                return -1;
            else if (ourKeyNode.next !is null && otherKeyNode.next is null)
                return 1;

            ourValueNode = ourKeyNode.head;
            otherValueNode = otherKeyNode.head;
            return 0;
        }

        int advanceValues() {
            ourValueNode = ourValueNode.next;
            otherValueNode = otherValueNode.next;

            if (ourValueNode.next is null && otherValueNode.next !is null)
                return -1;
            else if (ourValueNode.next !is null && otherValueNode.next is null)
                return 1;

            return 0;
        }

        while ((result = advanceBuckets()) == 0 && ourBucket !is null) {
            assert(otherBucket !is null);

            do {
                assert(ourKeyNode !is null);
                assert(otherKeyNode !is null);

                result = genericCompare(ourKeyNode.key, otherKeyNode.key);
                if (result != 0)
                    return result;

                do {
                    assert(ourValueNode !is null);
                    assert(otherValueNode !is null);

                    result = genericCompare(ourValueNode.value, otherValueNode.value);
                    if (result != 0)
                        return result;
                }
                while ((result = advanceValues()) == 0 && ourValueNode !is null);

            }
            while ((result = advanceKeys()) == 0 && ourKeyNode !is null);
        }

        return result;
    }

    ulong hashExternal() scope @trusted {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();

        foreach (ref bucket; nodeList.buckets) {
            KeyNode* currentKeyNode = bucket.head.next;
            ret = hashOf(currentKeyNode.key, ret);

            while (currentKeyNode !is &bucket.tail) {
                ValueNode* currentValueNode = currentKeyNode.head;

                while (currentValueNode !is null) {
                    ret = hashOf(currentValueNode.value, ret);

                    currentValueNode = currentValueNode.next;
                }
            }
        }

        return ret;
    }

    DuplicateHashMapImpl* dupExternal(scope RCAllocator allocator, scope RCAllocator valueAllocator) scope @trusted {
        if (allocator.isNull)
            allocator = globalAllocator();

        DuplicateHashMapImpl* ret = allocator.make!DuplicateHashMapImpl(allocator, valueAllocator);

        foreach (ref bucket; nodeList.buckets) {
            KeyNode* currentKeyNode = bucket.head.next;

            while (currentKeyNode !is &bucket.tail) {
                ValueNode* currentValueNode = currentKeyNode.head;

                while (currentValueNode !is null) {
                    ret.insertExternal(currentKeyNode.key, currentValueNode.value);

                    currentValueNode = currentValueNode.next;
                }

                currentKeyNode = currentKeyNode.next;
            }
        }

        return ret;
    }
}

struct DuplicativeHashMapNode(RealKeyType, ValueType) {
    static if (__traits(hasMember, RealKeyType, "asReadOnly")) {
        alias KeyType = typeof(RealKeyType.init.asReadOnly());
        enum KeyIsReadOnly = !is(RealKeyType == KeyType);
    } else {
        alias KeyType = RealKeyType;
        enum KeyIsReadOnly = false;
    }

    RCAllocator allocator, valueAllocator;
    shared(ptrdiff_t) refCount;

    Bucket[] buckets;
    size_t allNodes;

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

    void cleanup() scope {
        if (buckets.ptr !is smallBucketOptimization.ptr)
            allocator.dispose(buckets);
    }

    size_t getBucketId(ulong hash, scope Bucket[] buckets = null) scope {
        if (buckets.length == 0)
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

    static if (KeyIsReadOnly) {
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

        while (currentNode.next.next !is null && currentNode.next.hash <= hash && currentNode.next.key <= key) {
            currentNode = currentNode.next;
        }

        return (currentNode.previous !is null && currentNode.hash == hash && currentNode.key == key) ? currentNode : null;
    }

    KeyNode* priorNodeFor(ulong hash, scope KeyType key) scope @trusted {
        assert(buckets.length > 0);

        Bucket* bucket = &buckets[getBucketId(hash)];
        KeyNode* currentNode = &bucket.head;

        while (currentNode.next.next !is null && (currentNode.next.hash < hash || currentNode.next.key < key)) {
            currentNode = currentNode.next;
        }

        return currentNode;
    }

    void insertInternal(return scope KeyType key, return scope ValueType value) scope @trusted {
        const hash = getHash(key);
        KeyNode* prior = priorNodeFor(hash, key);

        KeyNode* current;

        if (prior.next.hash != hash || prior.next.key != key) {
            current = allocator.make!KeyNode();
            current.hash = hash;

            current.previous = prior;
            current.next = prior.next;
            prior.next = current;

            current.key = key;
        } else
            current = prior.next;

        auto newNode = allocator.make!ValueNode(current.head);
        newNode.value = value;

        current.head = newNode;
        this.allNodes++;
    }

    void removeNode(scope KeyNode* keyNode) scope @trusted {
        assert(keyNode !is null);
        assert(keyNode.previous !is null);
        assert(keyNode.next !is null);

        if (keyNode.previous !is null)
            keyNode.previous.next = keyNode.next;

        keyNode.next.previous = keyNode.previous;

        ValueNode* currentValueNode = keyNode.head;

        while (currentValueNode !is null) {
            ValueNode* next = currentValueNode.next;

            static if (isAnyPointer!ValueType) {
                if (!valueAllocator.isNull)
                    valueAllocator.dispose(currentValueNode.value);
            }

            this.allNodes--;
            allocator.dispose(currentValueNode);

            currentValueNode = next;
        }

        allocator.dispose(keyNode);
    }

    void moveIntoBiggerBuckets() scope @trusted {
        size_t nextCountOfBuckets() {
            switch (buckets.length) {
            case 0:
                return 16;
            case 16:
                return 0xFF;
            case 0xFF:
                return 0xFFF;
            case 0xFFF:
                return 0xFFFF;
            default:
                if (buckets.length > 0xFFFF && buckets.length < 0xFFFFFF)
                    return buckets.length * 2;
                else
                    return buckets.length;
            }
        }

        void copyOldIntoNew(scope Bucket[] old, scope Bucket[] into) {
            Bucket* lastIntoBucket;
            KeyNode* priorNode;

            foreach (ref oldBucket; old) {
                KeyNode* currentNode = oldBucket.head.next;

                while (currentNode.next !is null) {
                    KeyNode* nextNode = currentNode.next;
                    Bucket* intoBucket = &into[getBucketId(currentNode.hash, into)];

                    if (intoBucket is lastIntoBucket) {
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

        if (buckets.length * 32 <= allNodes) {
            size_t nextCount = nextCountOfBuckets();

            if (nextCount == buckets.length)
                return;

            Bucket[] oldBuckets = buckets;
            Bucket[] newBuckets = buckets.length == 0 ? this.smallBucketOptimization[] : allocator.makeArray!Bucket(nextCount);

            {
                buckets = newBuckets;

                foreach (ref b; newBuckets) {
                    b.head.next = &b.tail;
                    b.tail.previous = &b.head;
                }
            }

            if (oldBuckets.length > 0) {
                copyOldIntoNew(oldBuckets, newBuckets);

                if (oldBuckets.ptr !is smallBucketOptimization.ptr) {
                    allocator.dispose(oldBuckets);
                }
            }
        }
    }

    static struct Bucket {
        KeyNode head, tail;
    }

    static struct KeyNode {
        KeyNode* previous, next;
        ulong hash;

        KeyType key;
        ValueNode* head;
    }

    static struct ValueNode {
        ValueNode* next;
        ValueType value;
    }
}
