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
    alias Link = Node*;

    State* state;
    Iterator iterator;

    void checkInit() scope {
        if(state is null) {
            RCAllocator allocator = globalAllocator();
            state = allocator.make!State(1, allocator);
        }
    }

    void needIterator() scope {
        if(state is null || state.head is null || iterator.isSetup)
            return;

        iterator = Iterator(state);
        iterator.before;
    }

    static struct Iterator {
        State* state;
        Link current;
        KeyType key;

        static if(!is(ValueType == void)) {
            ValueType value;
        }

    @safe nothrow @nogc:

        this(State* state) scope {
            this.state = state;

            if(state.head.left !is null)
                current = state.getMinKey(state.head);
            else if(state.head.right !is null)
                current = state.getMinKey(state.head.right);
            else
                current = state.head;
        }

        this(return scope ref Iterator other) scope {
            this.tupleof = other.tupleof;
        }

        ~this() scope {
        }

        void opAssign(return scope Iterator other) scope {
            this.__ctor(other);
        }

        bool isSetup() scope {
            return this.state !is null;
        }

        void before() scope {
            if(current is null)
                return;
            key = current.key;

            static if(!is(ValueType == void)) {
                value = current.value;
            }

            state.mutated = false;
        }

        void after() scope {
            if(state.mutated)
                current = state.findLeftOfKey(state.head, key);

            if(current !is null && current.key <= key)
                locateNext();
        }

        void locateNext() scope {
            //   p
            //  / \
            // l   r

            if(current.parent !is null) {
                if(current.parent.left is current && current.parent.right !is null) {
                    // we are left, our instinct is always to go to our sibling's on the right left most child
                    current = current.parent.right;

                    // now find the left most node
                    while(current.left !is null) {
                        current = current.left;
                    }
                } else {
                    current = current.parent;
                }
            } else
                current = null;
        }
    }

    static struct Node {
        Link parent;
        Link left, right;

        size_t countChildren;
        KeyType key;

        static if(is(ValueType == void)) {
        } else {
            ValueType value;
        }

    @safe nothrow @nogc:

        void patchThisChildCount() scope {
            this.countChildren = this.left !is null ? this.left.countChildren : 0;
            this.countChildren += this.right !is null ? this.right.countChildren : 0;
            this.countChildren += this.left !is null;
            this.countChildren += this.right !is null;
        }

        void cleanup() scope {
            this.key.destroy;

            static if(is(ValueType == void)) {
            } else {
                this.value.destroy;
            }

            if(left !is null)
                left.cleanup;
            if(right !is null)
                right.cleanup;
        }
    }

    static struct State {
        import sidero.base.allocators.predefined : FreeableFixedSizeAllocator;

        ptrdiff_t refCount;
        RCAllocator allocator;
        FreeableFixedSizeAllocator nodeAllocator;

        Link head;
        bool mutated;

    @safe nothrow @nogc:

        void rc(bool addRef) scope @trusted {
            if(addRef)
                this.refCount++;
            else if(this.refCount == 1) {
                if(head !is null)
                    head.cleanup;
                nodeAllocator.deallocateAll;
                head = null;

                RCAllocator allocator = this.allocator;
                allocator.dispose(&this);
            } else
                this.refCount--;
        }

        Link getMinKey(Link root) scope {
            Link current = root;
            assert(current !is null);

            while(current.left !is null) {
                current = current.left;
            }

            return current;
        }

        void debugMe() scope @trusted {
            import core.stdc.stdio : printf, stdout, fflush;

            void handle(Link link) {
                if(link is null)
                    return;

                static if(__traits(isArithmetic, KeyType)) {
                    printf("    N%zd[label=\"%zd : %zd\"];\n", cast(size_t)link, link.countChildren, cast(size_t)link.key);
                } else {
                    printf("    N%zd[label=\"%zd\"];\n", cast(size_t)link, link.countChildren);
                }

                printf("    N%zd -> N%zd[style=dotted];\n", cast(size_t)link, cast(size_t)link.parent);
                printf("    N%zd", cast(size_t)link);

                if(link.left !is null || link.right !is null) {
                    printf(" -> ");

                    if(link.left !is null)
                        printf("N%zd", cast(size_t)link.left);
                    if(link.left !is null && link.right !is null)
                        printf(", ");
                    if(link.right !is null)
                        printf("N%zd", cast(size_t)link.right);

                    printf(";\n");
                    handle(link.left);
                    handle(link.right);
                } else
                    printf(";\n");
            }

            printf("digraph G {\n");
            handle(head);
            printf("}\n");

            fflush(stdout);
        }

        Link* findParentOfKey(Link* current, KeyType key) scope {
            while(*current !is null) {
                Link c = *current;

                if(c.key > key)
                    current = &c.left;
                else if(c.key < key)
                    current = &c.right;
                else
                    break;
            }

            return current;
        }

        Link* findParentOfKey(Link* current, KeyType key, out Link containing) scope {
            while(*current !is null) {
                Link c = *current;
                containing = c;

                if(c.key > key)
                    current = &c.left;
                else if(c.key < key)
                    current = &c.right;
                else
                    break;
            }

            return current;
        }

        Link findLeftOfKey(Link current, KeyType key) scope {
            while(current !is null && current.left !is null) {
                if(current.key > key)
                    current = current.left;
                else
                    break;
            }

            return current;
        }

        void rotateForChildren(scope Link* parent) scope @trusted {
            if(*parent is null)
                return;

            Link c = *parent;
            Link l = c.left, r = c.right;

            size_t leftCount = c.left !is null ? c.left.countChildren : 0;
            size_t rightCount = c.right !is null ? c.right.countChildren : 0;

            bool doneOneLeft, doneOneRight;

            while(leftCount > rightCount) {
                *parent = rotateRight(*parent);

                c = *parent;
                l = c.left, r = c.right;
                leftCount = c.left !is null ? c.left.countChildren : 0;
                rightCount = c.right !is null ? c.right.countChildren : 0;

                doneOneRight = true;
            }

            while(leftCount < rightCount) {
                *parent = rotateLeft(*parent);

                c = *parent;
                l = c.left, r = c.right;
                leftCount = c.left !is null ? c.left.countChildren : 0;
                rightCount = c.right !is null ? c.right.countChildren : 0;

                doneOneLeft = true;
            }

            if(doneOneLeft)
                rotateForChildren(&c.left);
            if(doneOneRight)
                rotateForChildren(&c.right);
        }

        Link rotateLeft(Link parent) scope {
            //   P
            //  / \
            // l   r
            //    / \
            //   rl

            Link ret = parent.right, rl = ret.left;
            parent.right = rl;
            ret.left = parent;

            //     r
            //    / \
            //   P
            //  / \
            // l   rl

            if(rl !is null)
                rl.parent = parent;
            ret.parent = parent.parent;
            parent.parent = ret;

            parent.patchThisChildCount;
            ret.patchThisChildCount;
            return ret;
        }

        Link rotateRight(Link parent) scope {
            //    P
            //   / \
            //  l   r
            // / \
            //    lr

            Link ret = parent.left, lr = ret.right;
            parent.left = lr;
            ret.right = parent;

            //  l
            // / \
            //    P
            //   / \
            //  lr  r

            if(lr !is null)
                lr.parent = parent;
            ret.parent = parent.parent;
            parent.parent = ret;

            parent.patchThisChildCount;
            ret.patchThisChildCount;
            return ret;
        }

        void patchRemove(scope Link* pointerToNode) scope @trusted {
            Link c = *pointerToNode;

            if(c.left is null) {
                *pointerToNode = c.right;
                c.right.parent = c.parent;
            } else if(c.right is null) {
                *pointerToNode = c.left;
                c.left.parent = c.parent;
            } else {
                //   c
                //  / \
                // l   r

                *pointerToNode = c.left;
                c.left.parent = c.parent;
                //   l
                //     r

                Link l = c.left, r = c.right, containing;

                Link* nextParent = findParentOfKey(pointerToNode, r.key, containing);
                r.parent = containing;

                if(*nextParent is null) {
                    *nextParent = r;
                } else if(r.key > (*nextParent).key) {
                    (*nextParent).right = r;
                } else if(r.key < (*nextParent).key) {
                    (*nextParent).left = r;
                }

                //   l
                //    \
                //     \
                //      r

                // everything between &c.right and r needs countChildren updated
                repatchChildCounts(l, l.right, head.left, *pointerToNode);
            }

            if(c.key < head.key) {
                repatchChildCounts(head, head.left, head.right, *pointerToNode);
            } else if(c.key > head.key) {
                repatchChildCounts(head, head.right, head.left, *pointerToNode);
            }

            rotateForChildren(pointerToNode);
            rotateForChildren(&head);

            this.nodeAllocator.dispose(c);
        }

        void repatchChildCounts(Link parent, Link childTaken, Link childNotTaken, Link stopAt) scope {
            size_t patch(Link link) {
                if(link is null)
                    return 0;

                if(link !is stopAt)
                    link.countChildren = patch(link.left) + patch(link.right);

                link.countChildren += link.left !is null;
                link.countChildren += link.right !is null;

                return link.countChildren;
            }

            parent.countChildren = patch(childTaken);
            parent.countChildren += childNotTaken !is null ? childNotTaken.countChildren : 0;
            parent.countChildren += parent.left !is null;
            parent.countChildren += parent.right !is null;
        }
    }
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
