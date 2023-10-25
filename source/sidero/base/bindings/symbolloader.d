module sidero.base.bindings.symbolloader;
import sidero.base.text;
import sidero.base.path.file;

///
struct SymbolLoader {
    private {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;
        import sidero.base.internal.logassert;
        import sidero.base.internal.atomic : atomicStore, atomicLoad;

        TestTestSetLockInline mutex;

        version(Windows) {
            import core.sys.windows.windows : HMODULE, FreeLibrary, LoadLibraryExW, GetProcAddress;

            shared HMODULE binary;

            enum LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = 0x00001000;
        } else version(Posix) {
            import core.sys.posix.dlfcn : dlopen, dlclose, dlsym, RTLD_NOW, RTLD_GLOBAL;

            shared void* binary;
        } else
            static assert(0, "Unimplemented");
    }

export @system nothrow @nogc:

    /// Moves the symbol loader
    this(ref return scope SymbolLoader other) scope {
        this.tupleof = other.tupleof;

        // don't trigger destructor
        other.tupleof = SymbolLoader.init.tupleof;
    }

    /// Guarantees it gets unloaded
    ~this() scope {
        if(!isLoaded)
            return;

        unload;
    }

    ///
    bool isLoaded() scope const {
        return atomicLoad(this.binary) !is null;
    }

    /// Special behavior for the executable
    bool loadMainProgram(scope void delegate() @system nothrow @nogc loadSymbolsDel = null) scope {
        if(isLoaded)
            return false;

        version(Windows) {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            atomicStore(this.binary, LoadLibraryExW(null, null, 0));

            if(isLoaded && loadSymbolsDel !is null)
                loadSymbolsDel();
            return isLoaded;
        } else version(Posix) {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            atomicStore(this.binary, dlopen(null, RTLD_GLOBAL | RTLD_NOW));

            if(isLoaded && loadSymbolsDel !is null)
                loadSymbolsDel();
            return isLoaded;
        } else
            static assert(0);
    }

    ///
    bool load(scope FilePath filePath, scope void delegate() @system nothrow @nogc loadSymbolsDel = null) scope {
        if(isLoaded || !filePath.couldPointToEntry)
            return false;

        version(Windows) {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            String_UTF16 filename = filePath.toStringUTF16();
            atomicStore(this.binary, LoadLibraryExW(filename.ptr, null, LOAD_LIBRARY_SEARCH_DEFAULT_DIRS));

            if(isLoaded && loadSymbolsDel !is null)
                loadSymbolsDel();

            return isLoaded;
        } else version(Posix) {
            mutex.pureLock;
            scope(exit)
                mutex.unlock;

            String_UTF8 filename = filePath.toString();
            atomicStore(this.binary, dlopen(filename.ptr, RTLD_GLOBAL | RTLD_NOW));

            if(isLoaded && loadSymbolsDel !is null)
                loadSymbolsDel();

            return isLoaded;
        } else
            static assert(0);
    }

    ///
    void unload(scope void delegate() @system nothrow @nogc unloadSymbolsDel = null) scope {
        if(!isLoaded)
            return;

        version(Windows) {
            mutex.pureLock;

            if(unloadSymbolsDel !is null)
                unloadSymbolsDel();

            logAssert(FreeLibrary(cast(HMODULE)atomicLoad(this.binary)) != 0, "Failed to unload library");
            atomicStore(this.binary, typeof(this.binary).init);

            mutex.unlock;
        } else version(Posix) {
            mutex.pureLock;

            if(unloadSymbolsDel !is null)
                unloadSymbolsDel();

            logAssert(dlclose(cast(void*)atomicLoad(this.binary)) == 0, "Failed to unload library");
            atomicStore(this.binary, typeof(this.binary).init);

            mutex.unlock;
        } else
            static assert(0);
    }

    /// Get pointer for a symbol or null
    void* acquire(String_ASCII symbolName) scope const {
        if(!isLoaded || symbolName.isNull)
            return null;

        version(Windows) {
            return GetProcAddress(cast(HMODULE)atomicLoad(this.binary), cast(char*)symbolName.ptr);
        } else version(Posix) {
            return dlsym(cast(void*)atomicLoad(this.binary), cast(char*)symbolName.ptr);
        } else
            static assert(0);
    }

    /// Get pointer for a symbol or null
    void* acquire(String_UTF8 symbolName) scope const {
        if(!isLoaded || symbolName.isNull)
            return null;

        if(symbolName.isEncodingChanged)
            symbolName = symbolName.dup;

        version(Windows) {
            return GetProcAddress(cast(HMODULE)this.binary, symbolName.ptr);
        } else version(Posix) {
            return dlsym(cast(void*)this.binary, cast(char*)symbolName.ptr);
        } else
            static assert(0);
    }

    /// Ditto
    void* acquire(String_UTF16 symbolName) scope const {
        return this.acquire(symbolName.byUTF8);
    }

    /// Ditto
    void* acquire(String_UTF32 symbolName) scope const {
        return this.acquire(symbolName.byUTF8);
    }

    /// Ditto
    void* acquire(String_UTF8.LiteralType symbolName) scope const {
        return this.acquire(String_UTF8(symbolName));
    }

    /// Ditto
    void* acquire(String_UTF16.LiteralType symbolName) scope const {
        return this.acquire(String_UTF8(symbolName));
    }

    /// Ditto
    void* acquire(String_UTF32.LiteralType symbolName) scope const {
        return this.acquire(String_UTF8(symbolName));
    }
}
