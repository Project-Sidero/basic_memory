module sidero.base.containers.set.single;
import sidero.base.allocators;
import sidero.base.containers.readonlyslice;

private {
    alias Set_int = Set!int;
    alias Set_int_int = Set!(int, int);
}

///
struct Set(KeyType, ValueType = void) {
    static assert(__traits(isArithmetic, KeyType) || __traits(compiles, KeyType.init < KeyType.init &&
            KeyType.init == KeyType.init), "Only comparable types may be used for a set key");

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(Del del) scope @trusted {
            if(state is null || state.head is null)
                return 0;

            Iterator iterator = Iterator(state);

            while(iterator.current !is null) {
                iterator.before;
                KeyType key = iterator.key;

                static if(!is(ValueType == void) && __traits(compiles, del(key, iterator.value))) {
                    int ret = del(key, iterator.value);
                } else {
                    int ret = del(key);
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
        mixin OpApplyCombos!(ValueType, KeyType, "opApply", true, true, true, false, false);
    }

@safe nothrow @nogc:

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
    bool isNull() scope {
        return state is null;
    }

    static if(is(ValueType == void)) {
        ///
        void opOpAssign(string op : "~")(KeyType key) scope {
            this.insert(key);
        }

        ///
        void insert(KeyType key, bool update = false) scope {
            checkInit;

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
    } else {
        ///
        void opIndexAssign(ValueType value, KeyType key) scope {
            this.insert(key, value);
        }

        ///
        void insert(KeyType key, ValueType value, bool update = true) scope {
            checkInit;

            Link containing;
            Link* parent = state.findParentOfKey(&state.head, key, containing);
            Link c;

            if(*parent !is null) {
                c = *parent;

                if(c.key == key) {
                    // all done!
                    if(update)
                        c.value = value;
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
            state.count++;

            state.repatchChildCounts(state.head, state.head.key > key ? state.head.left : state.head.right,
                    state.head.key > key ? state.head.right : state.head.left, *parent);
            state.rotateForChildren(parent);
            state.rotateForChildren(&state.head);
        }
    }

    ///
    Set dup() scope {
        Set ret;
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
    Set difference(Set other) scope {
        Set ret;
        ret.checkInit;

        static if(is(ValueType == void)) {
            foreach(KeyType k; this) {
                if(k !in other)
                    ret ~= k;
            }
        } else {
            foreach(KeyType k, ValueType v; this) {
                if(k !in other)
                    ret[k] = v;
            }
        }

        return ret;
    }

    ///
    Set intersect(Set other) scope {
        Set ret;
        ret.checkInit;

        static if(is(ValueType == void)) {
            foreach(KeyType k; this) {
                if(k in other)
                    ret ~= k;
            }
        } else {
            foreach(KeyType k, ValueType v; this) {
                if(k in other)
                    ret[k] = v;
            }
        }

        return ret;
    }

    ///
    Set union_(Set other) scope {
        Set ret = this.dup;

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
        ret.length = this.count;
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

        Link* parent = state.findParentOfKey(&state.head, key);
        Link c;

        c = *parent;
        if(c is null || c.key != key)
            return;

        state.mutated = true;
        state.patchRemove(parent);
    }

    ///
    size_t count() scope {
        if(isNull || state.head is null)
            return 0;
        else
            return state.head.countChildren + 1;
    }

    ///
    bool opBinaryRight(string op : "in")(KeyType key) scope {
        return this.contains(key);
    }

    ///
    bool contains(KeyType key) scope {
        if(isNull)
            return false;

        Link* parent = state.findParentOfKey(&state.head, key);
        return *parent !is null && (*parent).key == key;
    }

    static if(is(ValueType == void)) {
    } else {
        ///
        bool contains(KeyType key, out ValueType value) scope {
            if(isNull)
                return false;

            Link* parent = state.findParentOfKey(&state.head, key);
            if(*parent !is null && (*parent).key == key) {
                value = (*parent).value;
                return true;
            } else
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
    alias Ti = Set!int;

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

        foreach(int i; ti) {
            seen ~= i;
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

        foreach(int i; ti) {
            seen ~= i;
        }

        assert(seen == [3, 2]);
    }

    ti.insert(4);
    assert(ti.count == 3);
    assert(0 !in ti);
    assert(1 !in ti);
    assert(2 in ti);
    assert(3 in ti);
    assert(4 in ti);
    assert(5 !in ti);

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

        Ti not = set1.difference(set2);
        assert(not.keys == [2, 3]);
    }
}
