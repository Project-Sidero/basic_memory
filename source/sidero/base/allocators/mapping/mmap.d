/**
Provides Posix specific memory mapping via the mmap/munmap functions.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.mapping.mmap;
import core.sys.posix.sys.mman;

version (Posix) {
    ///
    struct MMap {
        ///
        enum NeedsLocking = false;

        ///
        enum isNull = false;

        ///
        __gshared MMap instance;

    @nogc scope pure nothrow @trusted:

        ///
        bool empty() {
            return false;
        }

        ///
        void[] allocate(size_t length, TypeInfo ti = null) {
            if (length == 0)
                return null;

            void* ret = assumeAllAttributes(&mmap)(null, length, PROT_READ | PROT_WRITE, MAP_PRIVATE, 0, 0);

            if (ret is MAP_FAILED)
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
            if (array.length > 0) {
                assumeAllAttributes(&munmap)(array.ptr, array.length);
                return true;
            } else
                return false;
        }
    }

private:
nothrow @nogc pure:

    auto assumeAllAttributes(T)(T arg) @trusted {
        import std.traits : SetFunctionAttributes, FunctionAttribute;

        return cast(SetFunctionAttributes!(T, "C",
                FunctionAttribute.pure_ | FunctionAttribute.nothrow_ | FunctionAttribute.safe | FunctionAttribute.nogc))arg;
    }
}
