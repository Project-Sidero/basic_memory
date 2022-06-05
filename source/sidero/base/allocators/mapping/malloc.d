/**
Provides memory mapping via the libc malloc/realloc/free functions.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.memory.allocators.mapping.malloc;

/**
    LibC malloc/free/realloc based memory mapping allocator.

    Warning: Deallocating using this without keeping track of roots will fail.
 */
struct Mallocator {
    import core.memory : pureMalloc, pureFree, pureRealloc;

    ///
    enum NeedsLocking = false;

    ///
    enum isNull = false;

    ///
    __gshared Mallocator instance;

@nogc scope pure nothrow @trusted:

    ///
    bool empty() {
        return false;
    }

    ///
    void[] allocate(size_t length, TypeInfo ti = null) {
        // implementation defined behavior == bad
        assert(length != 0);

        void* ret = pureMalloc(length);

        if (ret is null)
            return null;
        else
            return ret[0 .. length];
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        // implementation defined behavior == bad
        assert(newSize != 0);

        void* ret = pureRealloc(array.ptr, newSize);

        if (ret !is null) {
            array = ret[0 .. newSize];
            return true;
        } else {
            return false;
        }
    }

    ///
    bool deallocate(scope void[] data) {
        if (data.length > 0) {
            pureFree(&data[0]);
            return true;
        } else
            return false;
    }
}
