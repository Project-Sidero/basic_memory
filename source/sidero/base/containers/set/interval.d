module sidero.base.containers.set.interval;
import sidero.base.math.interval;
import sidero.base.allocators;
import sidero.base.containers.readonlyslice;

private {
    alias Set_int = IntervalSet!int;
    alias Set_int_int = IntervalSet!(int, int);
}

///
struct IntervalSet(RealKeyType, ValueType = void) {
    static assert(__traits(isArithmetic, KeyType) || __traits(compiles, KeyType.init < KeyType.init &&
            KeyType.init == KeyType.init), "Only comparable types may be used for a set key");

    alias KeyType = Interval!RealKeyType;

    private {
        import sidero.base.internal.meta;

        int opApplyImpl(Del)(Del del) scope @trusted {
            if(state is null || state.head is null)
                return 0;

            Iterator iterator = Iterator(state);

            while(iterator.current !is null) {
                iterator.before;
                KeyType key = iterator.key;

                static if (is(ValueType == void)) {
                    int ret = del(key);
                } else {
                    static if(!is(ValueType == void) && __traits(compiles, del(key, iterator.value))) {
                        int ret = del(key, iterator.value);
                    } else {
                        int ret = del(key);
                    }
                }

                if(ret)
                    return ret;

                iterator.after;
            }

            return 0;
        }
    }

export:

    static if(is(ValueType == void)) {
        mixin OpApplyCombos!(KeyType, void, "opApply", true, true, true, false, false);
    } else {
        mixin OpApplyCombosKeyNotValue!(ValueType, KeyType, "opApply", true, true, true, false, false);
    }

@safe nothrow @nogc:

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
    bool isNull() scope {
        return state is null;
    }

    static if(is(ValueType == void)) {
        ///
        void opOpAssign(string op : "~")(RealKeyType key) {
            this.insert(KeyType(key));
        }

        ///
        void opOpAssign(string op : "~")(KeyType key) {
            this.insert(key);
        }

        ///
        void insert(RealKeyType startEnd, bool update = false) {
            this.insert(KeyType(startEnd), update);
        }

        ///
        void insert(RealKeyType start, RealKeyType end, bool update = false) {
            this.insert(KeyType(start, end), update);
        }

        ///
        void insert(KeyType key, bool update = false) scope {
            checkInit;

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
    } else {
        ///
        void opIndexAssign(ValueType value, RealKeyType key) {
            this.insert(KeyType(key), value);
        }

        ///
        void opIndexAssign(ValueType value, KeyType key) {
            this.insert(key, value);
        }

        ///
        void insert(RealKeyType startEnd, ValueType value, bool update = false) {
            this.insert(KeyType(startEnd), value, update);
        }

        ///
        void insert(RealKeyType start, RealKeyType end, ValueType value, bool update = false) {
            this.insert(KeyType(start, end), value, update);
        }

        ///
        void insert(KeyType key, ValueType value, bool update = true) scope {
            checkInit;

            Link containing;
            Link* parent = state.findParentOfKey(&state.head, key, containing);
            Link c;

            if(containing !is null) {
                bool adjustStart = key.end == containing.key.start || key.end + 1 == containing.key.start,
                    adjustEnd = key.start == containing.key.end || key.start == containing.key.end + 1;

                if(containing.value != value) {
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
                    }
                }

                if(key.start >= containing.key.start && key.end <= containing.key.end) {
                    // already in set
                    return;
                }
            }

            if(*parent !is null) {
                c = *parent;

                if(c.key == key) {
                    // all done!
                    if(update)
                        c.value = value;
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

            *parent = state.nodeAllocator.make!Node(containing, null, null, 0, key, value);
            state.count += (key.end + 1) - key.start;
            state.nodeCount++;

            state.repatchChildCounts(state.head, state.head.key > key ? state.head.left : state.head.right,
                    state.head.key > key ? state.head.right : state.head.left, *parent);
            state.rotateForChildren(parent);
            state.rotateForChildren(&state.head);
        }
    }

    ///
    IntervalSet dup() scope {
        IntervalSet ret;
        ret.checkInit;

        static if(is(ValueType == void)) {
            foreach(KeyType k; this) {
                ret ~= k;
            }
        } else {
            foreach(KeyType k, ValueType v; this) {
                ret[k] = v;
            }
        }
        return ret;
    }

    ///
    IntervalSet difference(IntervalSet other) {
        IntervalSet ret;
        ret.checkInit;

        static if(is(ValueType == void)) {
            foreach(KeyType k; this) {
                foreach(val; k) {
                    if(val !in other)
                        ret ~= val;
                }
            }
        } else {
            foreach(KeyType k, ValueType v; this) {
                foreach(val; k) {
                    if(val !in other)
                        ret[val] = v;
                }
            }
        }

        return ret;
    }

    ///
    IntervalSet intersect(IntervalSet other) {
        IntervalSet ret;
        ret.checkInit;

        static if(is(ValueType == void)) {
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
        } else {
            foreach(KeyType k, ValueType v; this) {
                if(other.contains(k, true)) {
                    ret[k] = v;
                } else if(other.contains(k, false)) {
                    foreach(val; k) {
                        if(other.contains(val, false))
                            ret[KeyType(val)] = v;
                    }
                }
            }
        }

        return ret;
    }

    ///
    IntervalSet union_(IntervalSet other) {
        IntervalSet ret = this.dup;

        static if(is(ValueType == void)) {
            foreach(KeyType k; other) {
                ret ~= k;
            }
        } else {
            foreach(KeyType k, ValueType v; other) {
                ret.insert(k, v, false);
            }
        }

        return ret;
    }

    ///
    Slice!KeyType keys() scope @trusted {
        import sidero.base.containers.dynamicarray;
        import std.algorithm : sort;

        if(this.count == 0)
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
    void remove(RealKeyType key) {
        this.remove(KeyType(key));
    }

    ///
    void remove(KeyType key) {
        if(isNull)
            return;

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

        static if(is(ValueType == void)) {
            state.patchRemove(parent);

            if(key2.start < key.start)
                this.insert(KeyType(key2.start, key.start - 1));

            if(key.end < key2.end)
                this.insert(KeyType(key.end + 1, key2.end));
        } else {
            ValueType value = c.value;
            state.patchRemove(parent);

            if(key2.start < key.start)
                this.insert(KeyType(key2.start, key.start - 1), value);

            if(key.end < key2.end)
                this.insert(KeyType(key.end + 1, key2.end), value);
        }
    }

    ///
    size_t count() {
        if(isNull || state.head is null)
            return 0;
        else
            return state.count;
    }

    ///
    bool opBinaryRight(string op : "in")(RealKeyType key) {
        return this.contains(KeyType(key));
    }

    ///
    bool opBinaryRight(string op : "in")(KeyType key) {
        return this.contains(key);
    }

    ///
    bool contains(RealKeyType key, bool requireAll = false) {
        return this.contains(KeyType(key), requireAll);
    }

    ///
    bool contains(KeyType key, bool requireAll = false) {
        if(isNull)
            return false;

        Link containing;
        Link* parent = state.findParentOfKey(&state.head, key, containing);

        if(*parent !is null) {
            return requireAll ? (key.start >= (*parent).key.start && key.end <= (*parent).key.end) : (*parent).key.within(key);
        } else if(containing !is null) {
            return requireAll ? (key.start >= containing.key.start && key.end <= containing.key.end) : containing.key.within(key);
        } else
            return false;
    }

    static if(is(ValueType == void)) {
    } else {
        ///
        bool contains(KeyType key, out ValueType value, bool requireAll = false) {
            if(isNull)
                return false;

            Link containing;
            Link* parent = state.findParentOfKey(&state.head, key, containing);

            if(*parent !is null) {
                if(requireAll ? (key.start >= (*parent).key.start && key.end <= (*parent).key.end) : (*parent).key.within(key)) {
                    value = (*parent).value;
                    return true;
                }
            } else if(containing !is null) {
                if(requireAll ? (key.start >= containing.key.start && key.end <= containing.key.end) : containing.key.within(key)) {
                    value = containing.value;
                    return true;
                }
            }

            return false;
        }
    }

    ///
    KeyType front() scope {
        needIterator();
        assert(iterator.current !is null);
        return iterator.key;
    }

    ///
    bool empty() scope {
        needIterator();
        return !iterator.isSetup() || iterator.current is null;
    }

    ///
    void popFront() scope {
        needIterator();
        iterator.after;
        iterator.before;
    }

private:
    import sidero.base.containers.set.internal.state;

    mixin SetInternals!(KeyType, ValueType);
}

unittest {
    alias Ii = Interval!int;
    alias Ti = IntervalSet!int;

    Ti ti;
    assert(ti.count == 0);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 !in ti);
    assert(3 !in ti);
    assert(4 !in ti);
    assert(5 !in ti);

    ti.insert(2);
    assert(ti.count == 1);
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

    assert(ti.count == 2);
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
    assert(ti.count == 3);
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
    assert(ti.count == 2);
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

        Ti not = set1.difference(set2);
        assert(not.keys == [Ii(2, 3)]);
    }
}
