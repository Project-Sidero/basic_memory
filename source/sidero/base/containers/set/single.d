module sidero.base.containers.set.single;
import sidero.base.allocators;
import sidero.base.containers.readonlyslice;

private {
    alias Set_int = Set!int;
}

///
struct Set(KeyType) {
    static assert(__traits(isArithmetic, KeyType) || __traits(compiles, KeyType.init < KeyType.init &&
            KeyType.init == KeyType.init), "Only comparable types may be used for a set key");

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(Del del) scope @trusted {
            cannotBeSlice;

            if(state is null || state.head is null)
                return 0;

            state.mutex.lock;
            Iterator iterator = Iterator(state);

            while(iterator.current !is null) {
                iterator.before;
                state.mutex.unlock;

                KeyType key = iterator.key;
                const ret = del(key);

                if(ret)
                    return ret;

                state.mutex.lock;
                iterator.after;
            }

            state.mutex.unlock;
            return 0;
        }
    }

export:

    mixin OpApplyCombos!(KeyType, void, "opApply", true, true, true, false, false);

@safe nothrow:

    /// Will construct into a set at CTFE, must be sorted.
    static Set constructCTFE(immutable(KeyType)[] allKeys) {
        import sidero.base.hash.utils : hashOf;

        if(allKeys.length == 0)
            return Set.init;

        Set ret;

        if(__ctfe) {
            ret.state = new State;
            ret.state.copyOnWrite = true;

            ret.state.count = allKeys.length;
            ret.state.nodeCount = allKeys.length;

            ret.state.sliceOfKeys = allKeys;
            ret.state.sliceOfKeysHash = hashOf();

            foreach(k; allKeys) {
                ret.state.sliceOfKeysHash = hashOf(k, ret.state.sliceOfKeysHash);
            }

            return ret;
        }

        assert(0);
    }

@nogc:

    ///
    this(return scope ref Set other) scope {
        this.tupleof = other.tupleof;
        if(state !is null)
            state.rc(true);
    }

    ///
    ~this() scope {
        if(state !is null)
            state.rc(false);
    }

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    void opOpAssign(string op : "~")(KeyType key) scope {
        this.insert(key);
    }

    ///
    void insert(KeyType key, bool update = false) scope {
        checkInit;

        state.mutex.lock;
        scope(exit)
            state.mutex.unlock;

        Link containing;
        Link* parent = state.findParentOfKey(&state.head, key, containing);
        Link c;

        if(*parent !is null) {
            c = *parent;

            if(c.key == key) {
                // all done!
                return;
            } else if(c.key > key) {
                // c.left
                parent = &c.left;
            } else if(c.key < key) {
                // c.right
                parent = &c.right;
            }
        }

        state.mutated = true;

        *parent = state.nodeAllocator.make!Node(containing, null, null, 0, key);
        state.count++;

        state.repatchChildCounts(state.head, state.head.key > key ? state.head.left : state.head.right,
                state.head.key > key ? state.head.right : state.head.left, *parent);
        state.rotateForChildren(parent);
        state.rotateForChildren(&state.head);
    }

    ///
    Set dup() scope {
        if(isNull)
            return Set.init;

        state.mutex.lock;
        scope(exit)
            state.mutex.unlock;

        Set ret;
        ret.checkInit;

        Link createFromNode(Link newParent, Link old) {
            Link retL = ret.state.nodeAllocator.make!Node(newParent, null, null, 0, old.key);

            retL.countChildren = old.countChildren;

            if(old.left !is null)
                retL.left = createFromNode(retL, old.left);
            if(old.right !is null)
                retL.right = createFromNode(retL, old.right);

            return retL;
        }

        Link createFromSlice(Link newParent, immutable(KeyType[]) toGoKey) {
            if(toGoKey.length == 0)
                return null;

            const mid = toGoKey.length / 2;

            Link retL = ret.state.nodeAllocator.make!Node(newParent, null, null, 0, toGoKey[mid]);

            retL.left = createFromSlice(retL, toGoKey[0 .. mid]);
            retL.right = createFromSlice(retL, toGoKey[mid + 1 .. $]);

            if(newParent !is null)
                newParent.countChildren += retL.countChildren + 1;

            return retL;
        }

        if(state.sliceOfKeys is null) {
            ret.state.head = createFromNode(null, state.head);
            ret.state.count = state.count;
            ret.state.nodeCount = state.nodeCount;
        } else {
            ret.state.head = createFromSlice(null, state.sliceOfKeys);
            ret.state.count = state.sliceOfKeys.length;
            ret.state.nodeCount = state.sliceOfKeys.length;
        }

        return ret;
    }

    ///
    void copyOnWrite() scope {
        import sidero.base.internal.atomic;

        if(isNull)
            return;

        atomicStore(state.copyOnWrite, true);
    }

    ///
    Set difference(Set other) scope {
        Set ret;
        ret.checkInit;

        foreach(KeyType k; this) {
            if(k !in other)
                ret ~= k;
        }

        return ret;
    }

    ///
    Set symmetricDifference(Set other) {
        // [ab~~acd] == [bcd]

        Set ret;
        ret.checkInit;

        foreach(KeyType k; this) {
            if(k !in other)
                ret ~= k;
        }

        foreach(KeyType k; other) {
            if(k !in ret && k !in this)
                ret ~= k;
        }

        return ret;
    }

    ///
    Set intersect(Set other) scope {
        Set ret;
        ret.checkInit;

        foreach(KeyType k; this) {
            if(k in other)
                ret ~= k;
        }

        return ret;
    }

    ///
    Set union_(Set other) scope {
        Set ret = this.dup;

        foreach(KeyType k; other) {
            ret ~= k;
        }

        return ret;
    }

    ///
    Slice!KeyType keys() scope @trusted {
        import sidero.base.containers.dynamicarray;
        import std.algorithm : sort;

        if(this.length == 0)
            return typeof(return).init;

        DynamicArray!KeyType ret;
        ret.length = this.length;
        KeyType[] literal = ret.unsafeGetLiteral;

        size_t i;

        foreach(KeyType key; this) {
            literal[i++] = key;
        }

        sort(literal);
        return ret.asReadOnly;
    }

    ///
    void remove(KeyType key) scope {
        if(isNull)
            return;

        cannotBeSlice;

        state.mutex.lock;
        scope(exit)
            state.mutex.unlock;

        Link* parent = state.findParentOfKey(&state.head, key);
        Link c;

        c = *parent;
        if(c is null || c.key != key)
            return;

        state.mutated = true;
        state.patchRemove(parent);
    }

    ///
    size_t length() scope const @trusted {
        if(isNull || state.head is null)
            return 0;

        State* self = cast(State*)state;

        self.mutex.lock;
        scope(exit)
            self.mutex.unlock;

        return self.head.countChildren + 1;
    }

    ///
    bool opBinaryRight(string op : "in")(KeyType key) scope {
        return this.contains(key);
    }

    ///
    bool contains(KeyType key) scope {
        if(isNull)
            return false;

        state.mutex.lock;
        scope(exit)
            state.mutex.unlock;

        if(state.sliceOfKeys.length == 0) {
            Link* parent = state.findParentOfKey(&state.head, key);
            return *parent !is null && (*parent).key == key;
        } else {
            ptrdiff_t low, high = state.sliceOfKeys.length / 2;

            while(low < high) {
                const mid = low + (high - low) / 2;
                const ckey = state.sliceOfKeys[mid];

                if(key == ckey)
                    return true;
                else if(key > ckey)
                    low = mid + 1;
                else if(key < ckey)
                    high = mid;
            }

            return false;
        }
    }

    ///
    KeyType front() scope {
        cannotBeSlice;
        needIterator;
        assert(iterator.current !is null);
        return iterator.key;
    }

    ///
    bool empty() scope {
        cannotBeSlice;
        needIterator;
        return !iterator.isSetup() || iterator.current is null;
    }

    ///
    void popFront() scope {
        cannotBeSlice;
        needIterator;

        state.mutex.lock;
        iterator.after;
        iterator.before;
        state.mutex.unlock;
    }

    ///
    bool opEquals(scope Set other) scope const {
        return this.opCmp(other) == 0;
    }

    ///
    int opCmp(scope Set other) scope const {
        const c1 = this.length, c2 = other.length;

        if(c1 < c2)
            return -1;
        else if(c2 > c1)
            return 1;
        else if(c1 == 0)
            return 0;

        ulong a = this.toHash(), b = this.toHash();
        return a < b ? -1 : (a > b ? 1 : 0);
    }

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils : hashOf;

        if(isNull)
            return toHash();

        State* self = cast(State*)state;

        if(self.sliceOfKeys.length > 0)
            return self.sliceOfKeysHash;

        self.mutex.lock;
        scope(exit)
            self.mutex.unlock;

        return self.calculateHash();
    }

private:
    import sidero.base.containers.set.internal.state;

    alias RealKeyType = KeyType;
    mixin SetInternals!(KeyType);
}

unittest {
    alias Ti = Set!int;

    Ti ti;
    assert(ti.length == 0);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 !in ti);
    assert(3 !in ti);
    assert(4 !in ti);
    assert(5 !in ti);

    ti.insert(2);
    assert(ti.length == 1);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 in ti);
    assert(3 !in ti);
    assert(4 !in ti);
    assert(5 !in ti);

    {
        int[] seen;

        foreach(int i; ti) {
            seen ~= i;
        }

        assert(seen == [2]);
    }

    ti.insert(3);
    assert(ti.length == 2);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 in ti);
    assert(3 in ti);
    assert(4 !in ti);
    assert(5 !in ti);

    {
        int[] seen;

        foreach(int i; ti) {
            seen ~= i;
        }

        assert(seen == [3, 2]);
    }

    ti.insert(4);
    assert(ti.length == 3);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 in ti);
    assert(3 in ti);
    assert(4 in ti);
    assert(5 !in ti);

    ti.remove(3);
    assert(ti.length == 2);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 in ti);
    assert(3 !in ti);
    assert(4 in ti);
    assert(5 !in ti);

    ti ~= 7;
    ti ~= 8;
    ti ~= 9;
    ti ~= 10;
    ti ~= -2;
    ti ~= 12;

    {
        int[] seen;

        foreach(int v; ti) {
            seen ~= v;
        }

        assert(seen == [-2, 2, 7, 4, 9, 12, 10, 8]);
    }

    {
        int[] seen;

        for(auto __r = ti; !__r.empty; __r.popFront()) {
            seen ~= __r.front;
        }

        assert(seen == [-2, 2, 7, 4, 9, 12, 10, 8]);
    }

    assert(ti.keys == [-2, 2, 4, 7, 8, 9, 10, 12]);

    {
        Ti set1, set2;

        set1 ~= 1;
        set1 ~= 2;
        set1 ~= 3;

        set2 ~= -1;
        set2 ~= 0;
        set2 ~= 1;

        Ti join = set1.union_(set2);
        assert(join.keys == [-1, 0, 1, 2, 3]);

        Ti inter = set1.intersect(set2);
        assert(inter.keys == [1]);

        Ti diff = set1.difference(set2);
        assert(diff.keys == [2, 3]);

        Ti symmDiff = set1.symmetricDifference(set2);
        assert(symmDiff.keys == [-1, 0, 2, 3]);
    }
}
