/**
Provides Posix specific memory mapping via the mmap/munmap functions.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022-2024 Richard Andrew Cattermole
 */
module sidero.base.allocators.mapping.mmap;
import core.sys.posix.sys.mman;

export:

version(Posix) {
    /**
    A posix `mmap` based allocator.

    Does not use `TypeInfo` argument on allocation.

    Warning: do not use this as an allocator directly, it can only function as a memory mapper.

    Warning: does not destroy on deallocation.
    */
    struct MMap {
    export:
        ///
        enum NeedsLocking = false;

        ///
        enum isNull = false;

        ///
        __gshared RCAllocatorInstance!MMap instance;

    @nogc scope pure nothrow @trusted:

        ///
        bool empty() {
            return false;
        }

        ///
        void[] allocate(size_t length, TypeInfo ti = null) {
            if(length == 0)
                return null;

            void* ret = (cast(MMAP)&mmap)(null, length, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANON, -1, 0);

            if(ret is MAP_FAILED)
                return null;
            else
                return ret[0 .. length];
        }

        ///
        bool reallocate(scope ref void[] array, size_t newSize) {
            return false;
        }

        ///
        bool deallocate(scope void[] array) {
            if(array.length > 0) {
                (cast(MUNMAP)&munmap)(array.ptr, array.length);
                return true;
            } else
                return false;
        }
    }

private:
    alias MMAP = void* function(void*, size_t, int, int, int, off_t) pure nothrow @safe @nogc;
    alias MUNMAP = void* function(void*, size_t) pure nothrow @safe @nogc;
}
