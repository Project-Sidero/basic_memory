module sidero.base.containers.set.interval;
import sidero.base.math.interval;
import sidero.base.allocators;
import sidero.base.containers.readonlyslice;

private {
    alias Set_int = IntervalSet!int;
}

///
struct IntervalSet(RealKeyType) {
    static assert(__traits(isArithmetic, KeyType) || __traits(compiles, KeyType.init < KeyType.init &&
            KeyType.init == KeyType.init), "Only comparable types may be used for a set key");

    alias KeyType = Interval!RealKeyType;

    private {
        import sidero.base.internal.meta;

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

    /// Start + end pairs will construct into a set at CTFE, must be sorted and coalesced.
    static IntervalSet constructCTFE(immutable(RealKeyType)[] allKeys) {
        import sidero.base.hash.utils : hashOf;

        if(allKeys.length == 0)
            return IntervalSet.init;

        assert(allKeys.length % 2 == 0);
        const count = allKeys.length / 2;

        IntervalSet ret;

        if(__ctfe) {
            ret.state = new State;
            ret.state.copyOnWrite = true;

            ret.state.count = count;
            ret.state.nodeCount = count;

            ret.state.sliceOfKeys = allKeys;
            ret.state.sliceOfKeysHash = hashOf();

            for(size_t i; i < allKeys.length; i += 2) {
                KeyType k = KeyType(allKeys[i], allKeys[i + 1]);
                ret.state.sliceOfKeysHash = hashOf(k, ret.state.sliceOfKeysHash);
            }

            return ret;
        }

        assert(0);
    }

@nogc:

    ///
    this(return scope ref IntervalSet other) scope {
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
    void opOpAssign(string op : "~")(RealKeyType key) scope {
        this.insert(KeyType(key));
    }

    ///
    void opOpAssign(string op : "~")(KeyType key) scope {
        this.insert(key);
    }

    ///
    void insert(RealKeyType startEnd, bool update = false) scope {
        this.insert(KeyType(startEnd), update);
    }

    ///
    void insert(RealKeyType start, RealKeyType end, bool update = false) scope {
        this.insert(KeyType(start, end), update);
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

        if(containing !is null) {
            bool adjustStart = key.end == containing.key.start || key.end + 1 == containing.key.start,
                adjustEnd = key.start == containing.key.end || key.start == containing.key.end + 1;

            if(adjustEnd) {
                // adjust end, as it can combine
                state.count += (key.end + 1) - key.start;
                containing.key.end = key.end;
                return;
            } else if(adjustStart) {
                // adjust start, as it can combine
                state.count += containing.key.start - key.start;
                containing.key.start = key.start;
                return;
            } else if(key.start >= containing.key.start && key.end <= containing.key.end) {
                // already in set
                return;
            }
        }

        if(*parent !is null) {
            c = *parent;

            if(c.key == key) {
                // all done!
                return;
            } else if(key.start >= c.key.start && key.end <= c.key.end) {
                // already in set
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
        state.count += (key.end + 1) - key.start;
        state.nodeCount++;

        state.repatchChildCounts(state.head, state.head.key > key ? state.head.left : state.head.right,
                state.head.key > key ? state.head.right : state.head.left, *parent);
        state.rotateForChildren(parent);
        state.rotateForChildren(&state.head);
    }

    ///
    IntervalSet dup() scope {
        if(isNull)
            return IntervalSet.init;

        state.mutex.lock;
        scope(exit)
            state.mutex.unlock;

        IntervalSet ret;
        ret.checkInit;

        Link createFromNode(Link newParent, Link old) {
            Link retL;

            retL = ret.state.nodeAllocator.make!Node(newParent, null, null, 0, old.key);
            retL.countChildren = old.countChildren;

            if(old.left !is null)
                retL.left = createFromNode(retL, old.left);
            if(old.right !is null)
                retL.right = createFromNode(retL, old.right);

            return retL;
        }

        Link createFromSlice(Link newParent, immutable(RealKeyType)[] toGoKey) @trusted {
            if(toGoKey.length < 2)
                return null;

            const mid = toGoKey.length / 2;

            Link retL = ret.state.nodeAllocator.make!Node(newParent, null, null, 0,
                    KeyType(cast(RealKeyType)toGoKey[mid], cast(RealKeyType)toGoKey[mid + 1]));

            retL.left = createFromSlice(retL, toGoKey[0 .. mid]);
            retL.right = createFromSlice(retL, toGoKey[mid + 2 .. $]);

            if(newParent !is null)
                newParent.countChildren += retL.countChildren + 1;

            ret.state.count += toGoKey[mid + 1] - toGoKey[mid];
            return retL;
        }

        if(state.sliceOfKeys is null) {
            ret.state.head = createFromNode(null, state.head);
            ret.state.count = state.count;
            ret.state.nodeCount = state.nodeCount;
        } else {
            ret.state.head = createFromSlice(null, state.sliceOfKeys);
            ret.state.count = state.sliceOfKeys.length / 2;
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
    IntervalSet difference(IntervalSet other) scope {
        IntervalSet ret;
        ret.checkInit;

        foreach(KeyType k; this) {
            foreach(val; k) {
                if(val !in other)
                    ret ~= val;
            }
        }

        return ret;
    }

    ///
    IntervalSet symmetricDifference(IntervalSet other) {
        // [ab~~acd] == [bcd]

        IntervalSet ret;
        ret.checkInit;

        foreach(KeyType k; this) {
            foreach(val; k) {
                if(val !in other)
                    ret ~= val;
            }
        }

        foreach(KeyType k; other) {
            foreach(val; k) {
                if(val !in ret && val !in this)
                    ret ~= val;
            }
        }

        return ret;
    }

    ///
    IntervalSet intersect(IntervalSet other) scope {
        IntervalSet ret;
        ret.checkInit;

        foreach(KeyType k; this) {
            if(other.contains(k, true)) {
                ret ~= k;
            } else if(other.contains(k, false)) {
                foreach(val; k) {
                    if(other.contains(val, false))
                        ret ~= val;
                }
            }
        }

        return ret;
    }

    ///
    IntervalSet union_(IntervalSet other) scope {
        IntervalSet ret = this.dup;

        foreach(KeyType k; other) {
            ret ~= k;
        }

        return ret;
    }

    ///
    IntervalSet invert(RealKeyType min = RealKeyType.min, RealKeyType max = RealKeyType.max) {
        IntervalSet ret;
        ret.checkInit;

        this.state.mutex.lock;
        scope(exit)
            this.state.mutex.unlock;

        bool seenOne;
        RealKeyType lastSeen = min;

        void handle(KeyType key) {
            if (seenOne) {
                ret ~= KeyType(lastSeen + 1, key.start - 1);
                lastSeen = key.end;
            } else {
                seenOne = true;

                if (key.start < min) {
                } else {
                    ret ~= KeyType(min, key.start - 1);
                }

                lastSeen = key.end;
            }
        }

        void walk(Link parent) {
            if (parent.left !is null)
                walk(parent.left);
            handle(parent.key);
            if (parent.right !is null)
                walk(parent.right);
        }

        walk(state.head);

        if (lastSeen < max)
            ret ~= KeyType(lastSeen + 1, max);

        return ret;
    }

    ///
    Slice!KeyType keys() scope @trusted {
        import sidero.base.containers.dynamicarray;
        import std.algorithm : sort;

        if(this.length == 0)
            return typeof(return).init;

        DynamicArray!KeyType ret;
        ret.length = state.nodeCount;
        KeyType[] literal = ret.unsafeGetLiteral;

        size_t i;

        foreach(KeyType key; this) {
            literal[i++] = key;
        }

        sort(literal);
        return ret.asReadOnly;
    }

    ///
    void remove(RealKeyType key) scope {
        this.remove(KeyType(key));
    }

    ///
    void remove(KeyType key) scope @trusted {
        if(isNull)
            return;

        cannotBeSlice;
        state.mutex.lock;

        Link containing;
        Link* containingParent, parent = state.findParentOfKey(&state.head, key, containing, containingParent);
        Link c;

        c = *parent;

        if(c !is null && c.key.within(key)) {
        } else if(containing !is null && containing.key.within(key)) {
            c = containing;
            parent = containingParent;
        } else
            assert(0);

        KeyType key2 = c.key;

        state.mutated = true;

        state.count -= key2.end - key2.start;

        state.patchRemove(parent);
        state.mutex.unlock;

        if(key2.start < key.start)
            this.insert(KeyType(key2.start, key.start - 1));

        if(key.end < key2.end)
            this.insert(KeyType(key.end + 1, key2.end));
    }

    ///
    size_t length() scope const @trusted {
        if(isNull || state.head is null)
            return 0;

        State* self = cast(State*)state;

        self.mutex.lock;
        scope(exit)
            self.mutex.unlock;

        return self.count;
    }

    ///
    bool opBinaryRight(string op : "in")(RealKeyType key) scope {
        return this.contains(KeyType(key));
    }

    ///
    bool opBinaryRight(string op : "in")(KeyType key) scope {
        return this.contains(key);
    }

    ///
    bool contains(RealKeyType key, bool requireAll = false) scope {
        return this.contains(KeyType(key), requireAll);
    }

    ///
    bool contains(KeyType key, bool requireAll = false) scope {
        if(isNull)
            return false;

        state.mutex.lock;
        scope(exit)
            state.mutex.unlock;

        if(state.sliceOfKeys.length == 0) {
            Link containing;
            Link* parent = state.findParentOfKey(&state.head, key, containing);

            if(*parent !is null) {
                return requireAll ? (key.start >= (*parent).key.start && key.end <= (*parent).key.end) : (*parent).key.within(key);
            } else if(containing !is null) {
                return requireAll ? (key.start >= containing.key.start && key.end <= containing.key.end) : containing.key.within(key);
            }
        } else {
            ptrdiff_t low, high = state.sliceOfKeys.length / 2;

            while(low < high) {
                const mid = low + (high - low) / 2;
                const start = state.sliceOfKeys[mid << 1], end = state.sliceOfKeys[(mid << 1) | 1];

                if(key.start >= start && key.start <= end)
                    return requireAll ? (key.end <= end) : true;
                else if(key.start > end)
                    low = mid + 1;
                else if(key.start < start)
                    high = mid;
            }
        }

        return false;
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
    bool opEquals(scope IntervalSet other) scope const {
        return this.opCmp(other) == 0;
    }

    ///
    int opCmp(scope IntervalSet other) scope const {
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

    mixin SetInternals!(KeyType);
}

unittest {
    alias Ii = Interval!int;
    alias Ti = IntervalSet!int;

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

        foreach(Ii i; ti) {
            foreach(val; i) {
                seen ~= val;
            }
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
        size_t nodes;

        foreach(Ii i; ti) {
            nodes++;

            foreach(val; i) {
                seen ~= val;
            }
        }

        assert(nodes == 1);
        assert(seen == [2, 3]);
    }

    ti.insert(4);
    assert(ti.length == 3);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 in ti);
    assert(3 in ti);
    assert(4 in ti);
    assert(5 !in ti);

    {
        int[] seen;
        size_t nodes;

        foreach(Ii i; ti) {
            nodes++;

            foreach(val; i) {
                seen ~= val;
            }
        }

        assert(nodes == 1);
        assert(seen == [2, 3, 4]);
    }

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

        foreach(Ii i; ti) {
            foreach(val; i) {
                seen ~= val;
            }
        }

        assert(seen == [-2, 2, 12, 7, 8, 9, 10, 4]);
    }

    {
        int[] seen;

        for(auto __r = ti; !__r.empty; __r.popFront()) {
            foreach(val; __r.front) {
                seen ~= val;
            }
        }

        assert(seen == [-2, 2, 12, 7, 8, 9, 10, 4]);
    }

    assert(ti.keys == [Ii(-2), Ii(2), Ii(4), Ii(7, 10), Ii(12)]);

    {
        Ti set1, set2;

        set1 ~= 1;
        set1 ~= 2;
        set1 ~= 3;

        set2 ~= -1;
        set2 ~= 0;
        set2 ~= 1;

        Ti join = set1.union_(set2);
        assert(join.keys == [Ii(-1, 3)]);

        Ti inter = set1.intersect(set2);
        assert(inter.keys == [Ii(1)]);

        Ti diff = set1.difference(set2);
        assert(diff.keys == [Ii(2, 3)]);

        Ti symmDiff = set1.symmetricDifference(set2);
        assert(symmDiff.keys == [Ii(-1, 0), Ii(2, 3)]);
    }

    {
        Ti set;

        set ~= 1;
        set ~= 2;
        set ~= 3;

        set ~= 6;
        set ~= 7;

        Ti inverted = set.invert(0, 10);
        assert(inverted.keys == [Ii(0), Ii(4, 5), Ii(8, 10)]);
    }
}
