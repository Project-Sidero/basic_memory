/**
Tree based memory allocation and storage strategies.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.buffers.freetree;
import sidero.base.allocators.mapping : GoodAlignment;
public import sidero.base.allocators.buffers.defs : FitsStrategy;
public import sidero.base.allocators.predefined : HouseKeepingAllocator;
import std.typecons : Ternary;

private {
    import sidero.base.allocators.api;

    // guarantee tha each strategy has been initialized
    alias FreeTreeFirstFit = FreeTree!(RCAllocator, FitsStrategy.FirstFit);
    alias FreeTreeNextFit = FreeTree!(RCAllocator, FitsStrategy.NextFit);
    alias FreeTreeBestFit = FreeTree!(RCAllocator, FitsStrategy.BestFit);
    alias FreeTreeWorstFit = FreeTree!(RCAllocator, FitsStrategy.WorstFit);

    alias AT = AllocatedTree!(RCAllocator, RCAllocator);
}

/**
    An implementation of cartesian tree for storing free memory with optional alignment and minimum stored size.

    Based upon Fast Fits by C. J. Stephenson. http://sigops.org/s/conferences/sosp/2015/archive/1983-Bretton_Woods/06-stephenson-SOSP.pdf

    Will automatically deallocate memory back to the pool allocator when matching original allocation.

    See_Also: FreeList
*/
struct FreeTree(PoolAllocator, FitsStrategy Strategy, size_t DefaultAlignment = GoodAlignment, size_t DefaultMinimumStoredSize = 0) {
    /// Source for all memory
    PoolAllocator poolAllocator;
    /// Ensure all return pointers from stored source are aligned to a multiply of this
    size_t alignedTo = DefaultAlignment;
    // Ensure all memory stored are at least this size
    size_t minimumStoredSize = DefaultMinimumStoredSize;

    ///
    enum NeedsLocking = true;

    invariant {
        assert(alignedTo > 0);
        assert(anchor is null || !poolAllocator.isNull);

        version (none) {
            void handle(Node* parent) {
                assert(parent.length >= Node.sizeof);

                if (parent.left !is null)
                    handle(parent.left);
                if (parent.right !is null)
                    handle(parent.right);
            }

            if (anchor !is null)
                handle(cast(Node*)anchor);
        }
    }

    private {
        Node* anchor;

        static if (Strategy == FitsStrategy.NextFit) {
            Node** previousAnchor;
        }

        AllocatedTree!() allocations, fullAllocations;
    }

@safe @nogc scope pure nothrow:

     ~this() {
        deallocateAll();
    }

    ///
    bool isNull() const {
        return poolAllocator.isNull;
    }

@trusted:

    ///
    this(scope return ref FreeTree other) {
        this.tupleof = other.tupleof;

        other.anchor = null;
        static if (Strategy == FitsStrategy.NextFit)
            other.previousAnchor = null;

        other = FreeTree.init;
    }

    static if (Strategy == FitsStrategy.FirstFit) {
        ///
        void[] allocate(size_t size, TypeInfo ti = null) {
            Node** parent = &anchor;

            if (*parent is null) {
                size_t toAllocateSize = size;
                if (size < Node.sizeof)
                    toAllocateSize = Node.sizeof;

                auto ret = poolAllocator.allocate(toAllocateSize, ti);
                if (ret is null)
                    return null;

                if (ret.length < toAllocateSize) {
                    poolAllocator.deallocate(ret);
                    return null;
                }

                allocations.store(ret);
                fullAllocations.store(ret);
                return ret[0 .. size];
            }

            Node** currentParent = parent;
            Node** left = &(*currentParent).left;

            while (fitsAlignment(left, size, alignedTo)) {
                parent = currentParent;
                currentParent = left;
                left = &(*currentParent).left;
            }

            return allocateImpl(size, parent);
        }
    } else static if (Strategy == FitsStrategy.NextFit) {
        ///
        void[] allocate(size_t size, TypeInfo ti = null) {
            void[] perform(scope Node** parent) {
                Node** currentParent = parent, left = &(*currentParent).left;

                while (fitsAlignment(left, size, alignedTo)) {
                    parent = currentParent;
                    currentParent = left;
                    left = &(*currentParent).left;
                }

                previousAnchor = parent;
                return allocateImpl(size, parent);
            }

            if (fitsAlignment(previousAnchor, size, alignedTo))
                return perform(previousAnchor);
            else if (fitsAlignment(&anchor, size, alignedTo))
                return perform(&anchor);

            {
                size_t toAllocateSize = size;
                if (size < Node.sizeof)
                    toAllocateSize = Node.sizeof;

                auto ret = poolAllocator.allocate(toAllocateSize, ti);
                if (ret is null)
                    return null;

                if (ret.length < toAllocateSize) {
                    poolAllocator.deallocate(ret);
                    return null;
                }

                allocations.store(ret);
                fullAllocations.store(ret);
                return ret[0 .. size];
            }
        }
    } else static if (Strategy == FitsStrategy.BestFit) {
        ///
        void[] allocate(size_t size, TypeInfo ti = null) {
            Node** parent = &anchor, currentParent = parent;

            if (*currentParent !is null) {
                Node** left = &(*currentParent).left, right = &(*currentParent).right;
                bool leftFit = fitsAlignment(left, size, alignedTo), rightFit = fitsAlignment(right, size, alignedTo);

                while (leftFit || rightFit) {
                    parent = currentParent;

                    if (leftFit)
                        currentParent = left;
                    else
                        currentParent = right;

                    left = &(*currentParent).left;
                    right = &(*currentParent).right;
                    leftFit = fitsAlignment(left, size, alignedTo);
                    rightFit = fitsAlignment(right, size, alignedTo);
                }

                if (fitsAlignment(parent, size, alignedTo))
                    return allocateImpl(size, parent);
            }

            {
                size_t toAllocateSize = size;
                if (size < Node.sizeof)
                    toAllocateSize = Node.sizeof;

                auto ret = poolAllocator.allocate(toAllocateSize, ti);
                if (ret is null)
                    return null;

                if (ret.length < toAllocateSize) {
                    poolAllocator.deallocate(ret);
                    return null;
                }

                allocations.store(ret);
                fullAllocations.store(ret);
                return ret[0 .. size];
            }
        }
    } else static if (Strategy == FitsStrategy.WorstFit) {
        ///
        void[] allocate(size_t size, TypeInfo ti = null) {
            if (anchor !is null && fitsAlignment(&anchor, size, alignedTo))
                return allocateImpl(size, &anchor);

            {
                size_t toAllocateSize = size;
                if (size < Node.sizeof)
                    toAllocateSize = Node.sizeof;

                auto ret = poolAllocator.allocate(toAllocateSize, ti);
                if (ret is null)
                    return null;

                if (ret.length < toAllocateSize) {
                    poolAllocator.deallocate(ret);
                    return null;
                }

                allocations.store(ret);
                fullAllocations.store(ret);
                return ret[0 .. size];
            }
        }
    } else
        static assert(0, "Unimplemented fit strategy");

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if (void[] actual = allocations.getTrueRegionOfMemory(array)) {
            size_t pointerDifference = array.ptr - actual.ptr;
            size_t amountLeft = actual.length - pointerDifference;

            if (amountLeft >= newSize) {
                array = array.ptr[0 .. newSize];
                return true;
            }
        }

        return false;
    }

    ///
    bool deallocate(void[] array) {
        void[] trueArray = allocations.getTrueRegionOfMemory(array);

        if (trueArray !is null) {
            assert(trueArray.length >= Node.sizeof);
            allocations.remove(trueArray);

            Node** parent = &anchor;
            Node* current;

            while ((current = *parent) !is null) {
                void* currentPtr = cast(void*)current;

                if (currentPtr + current.length is trueArray.ptr) {
                    trueArray = currentPtr[0 .. current.length + trueArray.length];
                    delete_(parent);
                } else if (trueArray.ptr + trueArray.length is currentPtr) {
                    trueArray = trueArray.ptr[0 .. trueArray.length + current.length];
                    delete_(parent);
                } else if (trueArray.ptr < currentPtr)
                    parent = &current.left;
                else
                    parent = &current.right;
            }

            assert(trueArray.length > 0);
            void[] trueArrayOrigin = fullAllocations.getTrueRegionOfMemory(trueArray);

            if (trueArrayOrigin.ptr is trueArray.ptr && trueArrayOrigin.length == trueArray.length) {
                fullAllocations.remove(trueArray);
                poolAllocator.deallocate(trueArray);
            } else {
                Node* nodeToInsert = cast(Node*)trueArray.ptr;
                nodeToInsert.length = trueArray.length;
                nodeToInsert.left = null;
                nodeToInsert.right = null;

                insert(nodeToInsert, &anchor);
            }

            return true;
        }

        return false;
    }

    ///
    Ternary owns(scope void[] array) {
        return fullAllocations.owns(array) ? Ternary.yes : Ternary.no;
    }

    ///
    bool deallocateAll() {
        allocations.deallocateAll(null);
        fullAllocations.deallocateAll(&poolAllocator.deallocate);

        anchor = null;

        static if (Strategy == FitsStrategy.NextFit) {
            previousAnchor = null;
        }

        static if (__traits(hasMember, PoolAllocator, "deallocateAll")) {
            poolAllocator.deallocateAll();
        }

        return true;
    }

    static if (__traits(hasMember, PoolAllocator, "empty")) {
        ///
        bool empty() {
            return poolAllocator.empty();
        }
    }

private:
    void insert(Node* toInsert, Node** parent) {
        assert(toInsert !is null);
        assert(toInsert.length >= Node.sizeof);
        assert(toInsert.left is null || toInsert.left.length >= Node.sizeof);
        assert(toInsert.right is null || toInsert.right.length >= Node.sizeof);

        if (*parent !is null) {
            assert((*parent).length > Node.sizeof);
            assert((*parent).left is null || (*parent).left.length >= Node.sizeof);
            assert((*parent).right is null || (*parent).right.length >= Node.sizeof);
        }

        Node* currentChild = *parent;

        // find parent to inject into
        {
            while (weightOf(currentChild) >= toInsert.length) {
                if (toInsert < currentChild)
                    parent = &currentChild.left;
                else
                    parent = &currentChild.right;
                currentChild = *parent;
            }

            *parent = toInsert;
        }

        // recombine orphaned nodes back into the tree
        {
            Node** left_hook = &toInsert.left;
            Node** right_hook = &toInsert.right;

            while (currentChild !is null) {
                if (currentChild < toInsert) {
                    *left_hook = currentChild;
                    left_hook = &currentChild.right;
                    currentChild = currentChild.right;
                } else {
                    *right_hook = currentChild;
                    right_hook = &currentChild.left;
                    currentChild = currentChild.left;
                }
            }

            *left_hook = null;
            *right_hook = null;
        }
    }

    void delete_(Node** parent) {
        assert(*parent !is null);
        assert((*parent).length >= Node.sizeof);
        assert((*parent).left is null || (*parent).left.length >= Node.sizeof);
        assert((*parent).right is null || (*parent).right.length >= Node.sizeof);

        Node* left = (*parent).left, right = (*parent).right;
        size_t weightOfLeft = weightOf(left), weightOfRight = weightOf(right);

        while (left !is right) {
            if (weightOfLeft >= weightOfRight) {
                *parent = left;
                parent = &left.right;

                left = left.right;
                weightOfLeft = weightOf(left);
            } else {
                *parent = right;
                parent = &right.left;

                right = right.left;
                weightOfRight = weightOf(right);
            }
        }

        *parent = null;
    }

    void promote(Node* childToPromote, Node** parent) {
        assert(childToPromote !is null);
        assert(childToPromote.length >= Node.sizeof);
        assert(childToPromote.left is null || childToPromote.left.length >= Node.sizeof);
        assert(childToPromote.right is null || childToPromote.right.length >= Node.sizeof);

        Node* currentChild = *parent;

        // finds appropriete parent to inject childToPromote into
        {
            size_t childToPromoteWeight = weightOf(childToPromote);

            while (weightOf(currentChild) >= childToPromoteWeight) {
                if (childToPromote < currentChild)
                    parent = &currentChild.left;
                else
                    parent = &currentChild.right;
                currentChild = *parent;
            }

            *parent = childToPromote;
        }

        // recombine orphaned nodes back into the tree
        {
            Node* left_branch = childToPromote.left;
            Node* right_branch = childToPromote.right;
            Node** left_hook = &childToPromote.left;
            Node** right_hook = &childToPromote.right;

            while (currentChild !is childToPromote) {
                if (currentChild < childToPromote) {
                    *left_hook = currentChild;
                    left_hook = &currentChild.right;
                    currentChild = currentChild.right;
                } else {
                    *right_hook = currentChild;
                    right_hook = &currentChild.left;
                    currentChild = currentChild.left;
                }
            }

            *left_hook = left_branch;
            *right_hook = right_branch;
        }
    }

    void demote(Node** parent) {
        Node* toDemote = *parent;
        assert(toDemote !is null);
        assert(toDemote.length >= Node.sizeof);
        assert(toDemote.left is null || toDemote.left.length >= Node.sizeof);
        assert(toDemote.right is null || toDemote.right.length >= Node.sizeof);

        Node* left = toDemote.left;
        Node* right = toDemote.right;

        size_t weightOfToDemote = weightOf(toDemote), weightOfLeft = weightOf(left), weightOfRight = weightOf(right);

        while (weightOfLeft > weightOfToDemote || weightOfRight > weightOfToDemote) {
            if (weightOfLeft >= weightOfRight) {
                *parent = left;
                parent = &left.right;

                left = *parent;
                weightOfLeft = weightOf(left);
            } else {
                *parent = right;
                parent = &right.left;

                right = *parent;
                weightOfRight = weightOf(right);
            }
        }

        *parent = toDemote;
        toDemote.left = left;
        toDemote.right = right;
    }

    static struct Node {
        Node* left, right;
        size_t length;

    @safe @nogc scope pure nothrow:

        void[] recreate() @trusted {
            assert(length > 0);
            return (cast(void*)&this)[0 .. length];
        }
    }

    size_t weightOf(Node* node) {
        assert(node is null || node.length > 0);
        return node is null ? 0 : node.length;
    }

    bool fitsAlignment(Node** node, size_t needed, size_t alignedTo) {
        if (node is null || *node is null)
            return false;

        assert((*node).length >= Node.sizeof);
        assert((*node).left is null || (*node).left.length >= Node.sizeof);
        assert((*node).right is null || (*node).right.length >= Node.sizeof);

        if (alignedTo == 0)
            return (*node).length >= needed;

        size_t padding = alignedTo - ((cast(size_t)*node) % alignedTo);
        if (padding == alignedTo)
            padding = 0;

        return needed + padding <= (*node).length;
    }

    void[] allocateImpl(size_t size, Node** parent) {
        Node* current = *parent;
        assert(current !is null);
        assert(current.length >= Node.sizeof);
        assert(current.left is null || current.left.length >= Node.sizeof);
        assert(current.right is null || current.right.length >= Node.sizeof);

        size_t toAddAlignment = alignedTo - ((cast(size_t)current) % alignedTo);

        if (toAddAlignment == alignedTo)
            toAddAlignment = 0;

        assert(current.length >= size + toAddAlignment);

        size_t actualAllocationSize = size;
        if (actualAllocationSize < Node.sizeof)
            actualAllocationSize = Node.sizeof;

        if (current.length <= actualAllocationSize + toAddAlignment + Node.sizeof + minimumStoredSize) {
            allocations.store(current.recreate());
            delete_(parent);
        } else {
            assert(current.length >= actualAllocationSize + toAddAlignment + Node.sizeof);
            allocations.store(current.recreate()[0 .. actualAllocationSize + toAddAlignment]);

            Node* temp = cast(Node*)((cast(size_t)current) + actualAllocationSize + toAddAlignment);
            temp.left = current.left;
            temp.right = current.right;
            temp.length = current.length - (actualAllocationSize + toAddAlignment);

            *parent = temp;
            demote(parent);
        }

        return current.recreate()[toAddAlignment .. toAddAlignment + size];
    }
}

///
unittest {
    import sidero.base.allocators.mapping.malloc;
    import sidero.base.allocators.buffers.region;

    void perform(FT)() {
        FT ft;
        assert(!ft.empty);
        assert(!ft.isNull);

        ft = FT();
        assert(!ft.empty);
        assert(!ft.isNull);

        void[] got1 = ft.allocate(1024);
        assert(got1 !is null);
        assert(got1.length == 1024);
        assert(ft.owns(null) == Ternary.no);
        assert(ft.owns(got1) == Ternary.yes);
        assert(ft.owns(got1[10 .. 20]) == Ternary.yes);

        void[] got2 = ft.allocate(512);
        assert(got2 !is null);
        assert(got2.length == 512);
        assert(ft.owns(null) == Ternary.no);
        assert(ft.owns(got2) == Ternary.yes);
        assert(ft.owns(got2[10 .. 20]) == Ternary.yes);

        void[] got3 = ft.allocate(1024);
        assert(got3 !is null);
        assert(got3.length == 1024);
        assert(ft.owns(null) == Ternary.no);
        assert(ft.owns(got3) == Ternary.yes);
        assert(ft.owns(got3[10 .. 20]) == Ternary.yes);

        bool success = ft.reallocate(got1, 2048);
        assert(!success);
        assert(got1.length == 1024);

        assert(ft.owns(got1) == Ternary.yes);
        success = ft.deallocate(got1);
        assert(success);
        success = ft.deallocate(got2);
        assert(success);
        success = ft.deallocate(got3);
        assert(success);

        got1 = ft.allocate(512);
        assert(got1 !is null);
        assert(got1.length == 512);
        assert(ft.owns(null) == Ternary.no);
        assert(ft.owns(got1) == Ternary.yes);
        assert(ft.owns(got1[10 .. 20]) == Ternary.yes);
    }

    perform!(FreeTree!(Region!Mallocator, FitsStrategy.FirstFit));
    perform!(FreeTree!(Region!Mallocator, FitsStrategy.NextFit));
    perform!(FreeTree!(Region!Mallocator, FitsStrategy.BestFit));
    perform!(FreeTree!(Region!Mallocator, FitsStrategy.WorstFit));
}

/**
    A tree of all allocated memory, optionally supports a pool allocator that can be used to automatically deallocate all stored memory.

    Warning: You must remove all memory (i.e. by deallocateAll) prior to destruction or you will get an error.
*/
struct AllocatedTree(InternalAllocator = HouseKeepingAllocator!(), PoolAllocator = void) {
    ///
    InternalAllocator internalAllocator;

    static if (!is(PoolAllocator == void)) {
        ///
        PoolAllocator poolAllocator;
    }

    ///
    enum NeedsLocking = true;

    invariant {
        assert(anchor is null || !internalAllocator.isNull);
    }

    private {
        Node* anchor;

        static struct Node {
            Node* left, right;
            void[] array;

            bool matches(scope void* other) scope @trusted nothrow @nogc {
                return array.ptr <= other && (array.ptr + array.length) > other;
            }
        }
    }

scope @safe @nogc pure nothrow:

    ///
     ~this() {
        static if (!is(PoolAllocator == void)) {
            if (!poolAllocator.isNull)
                deallocateAll();
        }

        assert(anchor is null, "You didn't deallocate all memory before destruction of allocated list.");
    }

    ///
    bool isNull() const {
        return internalAllocator.isNull;
    }

@trusted:

    ///
    this(scope return ref AllocatedTree other) {
        this.tupleof = other.tupleof;
        other.anchor = null;
        other = AllocatedTree.init;
    }

    static if (!is(PoolAllocator == void)) {
        ///
        void deallocateAll() {
            deallocateAll(!poolAllocator.isNull ? &poolAllocator.deallocate : null);
        }
    }

    ///
    void deallocateAll(scope bool delegate(scope void[] array) @trusted nothrow @nogc pure deallocator) {
        void handle(Node* current) {
            if (current.left !is null)
                handle(current.left);
            if (current.right !is null)
                handle(current.right);

            if (deallocator !is null)
                deallocator(current.array);
            internalAllocator.deallocate((cast(void*)current)[0 .. Node.sizeof]);
        }

        if (anchor !is null) {
            handle(anchor);
            anchor = null;
        }
    }

    ///
    void store(scope void[] array) {
        if (array is null)
            return;

        Node** parent = &anchor;

        while (*parent !is null) {
            void* weightOfParentEnd = (*parent).array.ptr + (*parent).array.length;
            Node* left = (*parent).left, right = (*parent).right;

            if (right !is null && weightOfParentEnd <= array.ptr)
                parent = &(*parent).right;
            else if (left !is null && array.ptr + array.length <= weightOf(*parent))
                parent = &(*parent).left;
            else
                break;
        }

        Node* current = *parent;

        if (current !is null && current.matches(array.ptr)) {
            void* actualStartPtr = current.array.ptr < array.ptr ? current.array.ptr : array.ptr,
                actualEndPtr = (current.array.ptr + current.array.length) > (array.ptr + array.length) ? (
                        current.array.ptr + current.array.length) : (array.ptr + array.length);
            size_t actualLength = actualEndPtr - actualStartPtr;

            if (current.array.ptr !is actualStartPtr) {
                delete_(parent);

                current.array = actualStartPtr[0 .. actualLength];
                insert(current, &anchor);
            } else if (current.array.length != actualLength) {
                current.array = actualStartPtr[0 .. actualLength];
            }
        } else {
            current = cast(Node*)internalAllocator.allocate(Node.sizeof);
            current.left = null;
            current.right = null;
            current.array = array;

            insert(current, parent);
        }
    }

    /// Caller is responsible for deallocation of memory
    void remove(scope void[] array) {
        if (array is null)
            return;

        Node** parent = &anchor;

        while (*parent !is null) {
            void* weightOfParentEnd = (*parent).array.ptr + (*parent).array.length;
            Node* left = (*parent).left, right = (*parent).right;

            if (right !is null && weightOfParentEnd <= array.ptr)
                parent = &(*parent).right;
            else if (left !is null && array.ptr + array.length <= weightOf(*parent))
                parent = &(*parent).left;
            else
                break;
        }

        Node* current = *parent;

        if (current !is null && current.matches(array.ptr)) {
            delete_(parent);
            internalAllocator.deallocate(current[0 .. Node.sizeof]);
        }
    }

    ///
    bool owns(scope void[] array) {
        if (array is null)
            return false;

        Node** parent = &anchor;

        while (*parent !is null) {
            void* weightOfParentEnd = (*parent).array.ptr + (*parent).array.length;
            Node* left = (*parent).left, right = (*parent).right;

            if (right !is null && weightOfParentEnd <= array.ptr)
                parent = &(*parent).right;
            else if (left !is null && array.ptr + array.length <= weightOf(*parent))
                parent = &(*parent).left;
            else
                break;
        }

        return *parent !is null && (*parent).matches(array.ptr);
    }

    ///
    bool empty() {
        return anchor is null;
    }

    /// If memory is stored by us, will return the true region of memory associated with it.
    void[] getTrueRegionOfMemory(scope void[] array) {
        if (array is null)
            return null;

        Node** parent = &anchor;
        void* weightOfArrayEnd = array.ptr + array.length;

        while (*parent !is null) {
            void* weightOfParentEnd = (*parent).array.ptr + (*parent).array.length;
            Node* left = (*parent).left, right = (*parent).right;

            if (right !is null && weightOfParentEnd <= array.ptr)
                parent = &(*parent).right;
            else if (left !is null && weightOfArrayEnd <= weightOf(*parent))
                parent = &(*parent).left;
            else
                break;
        }

        Node* current = *parent;

        if (current !is null && current.matches(array.ptr))
            return current.array;
        else
            return null;
    }

private:
    void insert(Node* toInsert, Node** parent) {
        assert(toInsert !is null);
        void* weightOfToInsert = toInsert.array.ptr;
        Node* currentChild = *parent;

        // locate parent to insert into
        {
            void* weightOfToInsertEnd = weightOfToInsert + toInsert.array.length;

            while (weightOf(currentChild) >= weightOfToInsertEnd) {
                void* weightOfParentEnd = (*parent).array.ptr + (*parent).array.length;

                if (weightOfToInsert < (*parent).array.ptr)
                    parent = &currentChild.left;
                else if (weightOfToInsert > weightOfParentEnd)
                    parent = &currentChild.right;
                else
                    break;

                currentChild = *parent;
            }

            *parent = toInsert;
        }

        // handle the orphans to reinsert
        {
            Node** left_hook = &toInsert.left;
            Node** right_hook = &toInsert.right;

            while (currentChild !is null) {
                if (weightOf(currentChild) < weightOfToInsert) {
                    *left_hook = currentChild;
                    left_hook = &currentChild.right;
                    currentChild = currentChild.right;
                } else {
                    *right_hook = currentChild;
                    right_hook = &currentChild.left;
                    currentChild = currentChild.left;
                }
            }

            *left_hook = null;
            *right_hook = null;
        }
    }

    void delete_(Node** parent) {
        Node* left = (*parent).left, right = (*parent).right;

        while (left !is right) {
            if (weightOf(left) >= weightOf(right)) {
                *parent = left;
                parent = &left.right;
                left = left.right;
            } else {
                *parent = right;
                parent = &right.left;
                right = right.left;
            }
        }

        *parent = null;
    }

    void* weightOf(Node* node) {
        return node is null ? null : node.array.ptr;
    }
}

///
unittest {
    alias AT = AllocatedTree!();

    AT at;
    assert(!at.isNull);
    assert(at.empty);

    at = AT();
    assert(!at.isNull);
    assert(at.empty);

    void[] someArray = new void[1024];
    at.store(someArray);
    assert(!at.empty);
    assert(!at.owns(null));
    assert(at.owns(someArray));
    assert(at.owns(someArray[10 .. 20]));
    assert(at.getTrueRegionOfMemory(someArray[10 .. 20]) is someArray);

    void[] someArray2 = new void[512];
    at.store(someArray2);
    assert(!at.empty);
    assert(!at.owns(null));
    assert(at.owns(someArray2));
    assert(at.owns(someArray2[10 .. 20]));
    assert(at.getTrueRegionOfMemory(someArray2[10 .. 20]) is someArray2);

    void[] someArray3 = new void[1024];
    at.store(someArray3);
    assert(!at.empty);
    assert(!at.owns(null));
    assert(at.owns(someArray3));
    assert(at.owns(someArray3[10 .. 20]));
    assert(at.getTrueRegionOfMemory(someArray3[10 .. 20]) is someArray3);

    at.remove(someArray);
    assert(!at.owns(someArray));
    assert(at.owns(someArray2));
    assert(at.owns(someArray3));
    at.remove(someArray2);
    assert(!at.owns(someArray));
    assert(!at.owns(someArray2));
    assert(at.owns(someArray3));
    at.remove(someArray3);
    assert(!at.owns(someArray));
    assert(!at.owns(someArray2));
    assert(!at.owns(someArray3));
    assert(at.empty);

    at.store(someArray);
    assert(!at.empty);

    int got;
    at.deallocateAll((array) { got += array == someArray ? 1 : 0; return true; });
    assert(got == 1);
}
