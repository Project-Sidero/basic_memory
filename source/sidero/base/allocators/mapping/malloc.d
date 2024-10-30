/**
Provides memory mapping via the libc malloc/realloc/free functions.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.mapping.malloc;
import sidero.base.allocators.api : RCAllocatorInstance;

export:

/**
Libc malloc + realloc + free based memory allocator, should be treated as a mapping allocator but can be used as an allocator.

Does not use `TypeInfo` argument on allocation.

Warning: Deallocating using this without keeping track of roots will fail.

Warning: does not destroy on deallocation.
*/
struct Mallocator {
export:

    ///
    enum NeedsLocking = false;

    ///
    enum isNull = false;

    ///
    __gshared RCAllocatorInstance!Mallocator instance;

@nogc scope pure nothrow @trusted:

    ///
    bool empty() {
        return false;
    }

    ///
    void[] allocate(size_t length, TypeInfo ti = null) {
        // implementation defined behavior == bad
        if(length == 0)
            return null;

        void* ret = pureMalloc(length);

        if(ret is null)
            return null;
        else
            return ret[0 .. length];
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        // implementation defined behavior == bad
        if(newSize == 0)
            return false;

        void* ret = pureRealloc(array.ptr, newSize);

        if(ret !is null) {
            array = ret[0 .. newSize];
            return true;
        } else {
            return false;
        }
    }

    ///
    bool deallocate(scope void[] data) @trusted {
        if(data.ptr !is null) {
            pureFree(data.ptr);
            return true;
        } else
            return false;
    }
}

private:

// copied from druntime
extern (C) pure @system @nogc nothrow {
    pragma(mangle, "malloc") void* pureMalloc(size_t);
    pragma(mangle, "calloc") void* pureCalloc(size_t nmemb, size_t size);
    pragma(mangle, "realloc") void* pureRealloc(void* ptr, size_t size);
    pragma(mangle, "free") void pureFree(void* ptr);
}
