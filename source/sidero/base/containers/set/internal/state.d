module sidero.base.containers.set.internal.state;

mixin template SetInternals(KeyType, ValueType) {
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
                    while(current.left !is null || current.right !is null) {
                        if(current.left !is null)
                        current = current.left;
                        else
                        current = current.right;
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
        size_t count, nodeCount;
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

        Link* findParentOfKey(Link* current, KeyType key, out Link containing, out Link* containingParent) {
            while(*current !is null) {
                Link c = *current;
                containingParent = current;
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

            if(c.left is null && c.right is null) {
                *pointerToNode = null;
            } else if(c.left is null) {
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

            if(head is null) {
            } else if(c.key < head.key) {
                repatchChildCounts(head, head.left, head.right, *pointerToNode);
            } else if(c.key > head.key) {
                repatchChildCounts(head, head.right, head.left, *pointerToNode);
            }

            rotateForChildren(pointerToNode);
            rotateForChildren(&head);

            this.count--;
            this.nodeCount--;
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
