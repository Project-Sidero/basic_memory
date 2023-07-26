/**
Windows specific memory mappers.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.mapping.virtualalloc;
export:

version(Windows) {
    /**
        Note: this is designed for 4k increments! It will do 4k increments regardless of what you want.
        It cannot reallocate, use HeapAllocMapper instead.
     */
    struct VirtualAllocMapper {
    export:
        ///
        enum NeedsLocking = false;

        ///
        enum isNull = false;

        ///
        __gshared VirtualAllocMapper instance;

    @nogc scope pure nothrow @trusted:

        ///
        bool empty() {
            return false;
        }

        ///
        void[] allocate(size_t length, TypeInfo ti = null) {
            enum FourKb = 4 * 1024 * 1024;

            size_t leftOver;
            if((leftOver = length % FourKb) != 0)
                length += FourKb - leftOver;

            void* ret = VirtualAlloc(null, length, MEM_COMMIT, PAGE_READWRITE);

            if(ret !is null)
                return ret[0 .. length];
            else
                return null;
        }

        ///
        bool reallocate(scope ref void[] array, size_t newSize) {
            return false;
        }

        ///
        bool deallocate(scope void[] array) {
            return VirtualFree(array.ptr, 0, MEM_RELEASE) != 0;
        }
    }

    /**
        Windows HeapAlloc family of mappers.
     */
    struct HeapAllocMapper {
    export:
        ///
        enum NeedsLocking = false;

        ///
        __gshared HeapAllocMapper instance;

        private {
            HANDLE heap;
        }

    @nogc scope pure nothrow @trusted:

        ///
        bool empty() {
            return false;
        }

        ///
        this(return scope ref HeapAllocMapper other) {
            import std.algorithm.mutation : move;

            move(other, this);
        }

        ///
        ~this() {
            deallocateAll();
        }

        ///
        bool isNull() const {
            return heap == HANDLE.init;
        }

        ///
        void[] allocate(size_t length, TypeInfo ti = null) {
            if(heap == HANDLE.init)
                heap = HeapCreate(0, 0, 0);

            if(heap != HANDLE.init) {
                void* ret = HeapAlloc(heap, 0, length);

                if(ret !is null)
                    return ret[0 .. length];
            }

            return null;
        }

        ///
        bool reallocate(scope ref void[] array, size_t newSize) {
            if(heap == HANDLE.init)
                return false;

            void* ret = HeapReAlloc(heap, 0, array.ptr, newSize);

            if(ret !is null) {
                array = ret[0 .. newSize];
                return true;
            } else
                return false;
        }

        ///
        bool deallocate(scope void[] data) {
            if(heap == HANDLE.init)
                return false;

            return HeapFree(heap, 0, data.ptr) != 0;
        }

        ///
        bool deallocateAll() {
            if(heap != HANDLE.init) {
                HeapDestroy(heap);
                heap = HANDLE.init;
                return true;
            } else
                return false;
        }
    }

private:
    import core.sys.windows.winnt : MEM_COMMIT, MEM_RELEASE, MEM_RESERVE, PAGE_READWRITE, PVOID, LPVOID;
    import core.sys.windows.basetsd : SIZE_T;
    import core.sys.windows.windef : DWORD, BOOL, HANDLE;

    @nogc pure nothrow @system extern (Windows) {
        PVOID VirtualAlloc(scope PVOID, SIZE_T, DWORD, DWORD);
        BOOL VirtualFree(scope PVOID, SIZE_T, DWORD);

        HANDLE HeapCreate(DWORD, SIZE_T, SIZE_T);
        BOOL HeapDestroy(scope HANDLE);
        LPVOID HeapAlloc(scope HANDLE, DWORD, SIZE_T);
        LPVOID HeapReAlloc(scope HANDLE, DWORD, LPVOID, SIZE_T);
        BOOL HeapFree(scope HANDLE, DWORD, scope LPVOID);
    }
}
