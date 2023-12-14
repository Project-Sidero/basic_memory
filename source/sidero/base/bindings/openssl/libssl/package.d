module sidero.base.bindings.openssl.libssl;
public import sidero.base.bindings.openssl.libssl.ssl;
public import sidero.base.bindings.openssl.libssl.tls1;
import sidero.base.bindings.symbolloader;
import sidero.base.path.file;
import sidero.base.errors;

export @safe nothrow @nogc:

///
__gshared SymbolLoader libSSLSymbolLoader;

///
ErrorResult loadLibSSL(scope FilePath filePath = FilePath.init) @trusted {
    ErrorResult ret;

    bool attempt(FilePath filePath) {
        if (!filePath.couldPointToEntry())
            return false;

        return libSSLSymbolLoader.load(filePath, () {
            import std.meta : staticIndexOf;

            static foreach (f; AllFunctions) {
                if (ret) {
                    enum required = mixin("staticIndexOf!(`optional`, __traits(getAttributes, " ~ f ~ ")) == -1");

                    void* symbol = libSSLSymbolLoader.acquire(f);
                    mixin(f ~ " = cast(f_" ~ f ~ ")symbol;");

                    if (symbol is null) {
                        ret = ErrorResult(NullPointerException("Missing libssl function " ~ f));
                    }
                }
            }
        });
    }

    bool handled = libSSLSymbolLoader.isLoaded();

    if (!handled)
        handled = attempt(filePath);

    if (!handled) {
        version (Windows) {
            auto filePathP = FilePath.from("libssl.dll");

            if (filePathP)
                handled = attempt(filePathP.get);
            else
                ret = ErrorResult(filePathP.getError());
        } else version (OSX) {
            auto filePathP = FilePath.from("libssl.dylib");

            if (filePathP)
                handled = attempt(filePathP.get);
            else
                ret = ErrorResult(filePathP.getError());
        } else version (Posix) {
            auto filePathP = FilePath.from("libssl.so");

            if (filePathP)
                handled = attempt(filePathP.get);
            else
                ret = ErrorResult(filePathP.getError());
        } else {
            ret = ErrorResult(PlatformNotImplementedException("Missing default for libssl shared library, cannot load"));
        }
    }

    if (!handled)
        ret = ErrorResult(UnknownPlatformBehaviorException("Missing libssl shared library, cannot load"));

    if (!ret)
        unloadLibSSL();

    return ret;
}

///
void unloadLibSSL() @trusted {
    libSSLSymbolLoader.unload(() {
        static foreach (f; AllFunctions) {
            mixin(f ~ " = null;");
        }
    });
}

private pragma(crt_destructor) extern (C) void deinitializeLibSSLAutomatically() {
    unloadLibSSL;
}

private:

static immutable AllFunctions = sslFUNCTIONS ~ tls1FUNCTIONS;
