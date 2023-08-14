/**
Allows splitting of allocations between two sizes of allocations.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.alternatives.segregator;
import sidero.base.typecons : Ternary;

private {
    import sidero.base.allocators.api;

    alias SegRC = Segregator!(RCAllocator, RCAllocator, 1024);
}

export:

/**
    Splits memory allocations based upon size. Uses small <= threshold < large.
 */
struct Segregator(SmallAllocator, LargeAllocator, size_t threshold) {
export:
    ///
    SmallAllocator smallAllocator;
    ///
    LargeAllocator largeAllocator;

    ///
    enum NeedsLocking = () {
        bool ret;

        static if(__traits(hasMember, SmallAllocator, "NeedsLocking"))
            if(SmallAllocator.NeedsLocking)
                ret = true;
        static if(__traits(hasMember, LargeAllocator, "NeedsLocking"))
            if(LargeAllocator.NeedsLocking)
                ret = true;

        return ret;
    }();

scope @safe @nogc pure nothrow:

    this(return scope ref Segregator other) @trusted {
        this.tupleof = other.tupleof;
        other = Segregator.init;
    }

    ///
    bool isNull() const {
        return smallAllocator.isNull || largeAllocator.isNull;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        if(isNull)
            return null;
        else {
            if(size <= threshold)
                return smallAllocator.allocate(size, ti);
            else
                return largeAllocator.allocate(size, ti);
        }
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if(isNull)
            return false;
        else if(smallAllocator.owns(array) == Ternary.Yes)
            return smallAllocator.reallocate(array, newSize);
        else
            return largeAllocator.reallocate(array, newSize);
    }

    ///
    bool deallocate(scope void[] array) {
        if(isNull)
            return false;
        else if(smallAllocator.owns(array) == Ternary.Yes)
            return smallAllocator.deallocate(array);
        else
            return largeAllocator.deallocate(array);
    }

    static if(__traits(hasMember, SmallAllocator, "owns") && __traits(hasMember, LargeAllocator, "owns")) {
        ///
        Ternary owns(scope void[] array) {
            if(isNull)
                return Ternary.No;
            else if(largeAllocator.owns(array) != Ternary.Yes)
                return smallAllocator.owns(array);
            else
                return largeAllocator.owns(array);
        }
    }

    static if(__traits(hasMember, SmallAllocator, "deallocateAll") && __traits(hasMember, LargeAllocator, "deallocateAll")) {
        ///
        bool deallocateAll() {
            if(isNull)
                return false;
            else {
                smallAllocator.deallocateAll();
                largeAllocator.deallocateAll();
                return true;
            }
        }
    }

    static if(__traits(hasMember, SmallAllocator, "empty") && __traits(hasMember, LargeAllocator, "empty")) {
        ///
        bool empty() {
            return isNull || smallAllocator.empty() && largeAllocator.empty();
        }
    }
}
