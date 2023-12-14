module sidero.base.bindings.openssl.libcrypto;
public import sidero.base.bindings.openssl.libcrypto.asn1;
public import sidero.base.bindings.openssl.libcrypto.bio;
public import sidero.base.bindings.openssl.libcrypto.bn;
public import sidero.base.bindings.openssl.libcrypto.buffer;
public import sidero.base.bindings.openssl.libcrypto.crypto;
public import sidero.base.bindings.openssl.libcrypto.evp;
public import sidero.base.bindings.openssl.libcrypto.err;
public import sidero.base.bindings.openssl.libcrypto.pem;
public import sidero.base.bindings.openssl.libcrypto.safestack;
public import sidero.base.bindings.openssl.libcrypto.stack;
public import sidero.base.bindings.openssl.libcrypto.types;
public import sidero.base.bindings.openssl.libcrypto.x509;
public import sidero.base.bindings.openssl.libcrypto.obj_mac;
public import sidero.base.bindings.openssl.libcrypto.objects;
public import sidero.base.bindings.openssl.libcrypto.rsa;
import sidero.base.bindings.symbolloader;
import sidero.base.path.file;
import sidero.base.errors;

export @safe nothrow @nogc:

///
__gshared SymbolLoader libCryptoSymbolLoader;

///
ErrorResult loadLibCrypto(scope FilePath filePath = FilePath.init) @trusted {
    ErrorResult ret;

    bool attempt(FilePath filePath) {
        if (!filePath.couldPointToEntry())
            return false;

        return libCryptoSymbolLoader.load(filePath, () {
            import std.meta : staticIndexOf;

            static foreach (f; AllFunctions) {
                if (ret) {
                    enum required = mixin("staticIndexOf!(`optional`, __traits(getAttributes, " ~ f ~ ")) == -1");

                    void* symbol = libCryptoSymbolLoader.acquire(f);
                    mixin(f ~ " = cast(f_" ~ f ~ ")symbol;");

                    if (required && symbol is null) {
                        ret = ErrorResult(NullPointerException("Missing libcrypto function " ~ f));
                    }
                }
            }
        });
    }

    bool handled = libCryptoSymbolLoader.isLoaded();

    if (!handled)
        handled = attempt(filePath);

    if (!handled) {
        version (Windows) {
            auto filePathP = FilePath.from("libcrypto.dll");

            if (filePathP)
                handled = attempt(filePathP.get);
            else
                ret = ErrorResult(filePathP.getError());
        } else version (OSX) {
            auto filePathP = FilePath.from("libcrypto.dylib");

            if (filePathP)
                handled = attempt(filePathP.get);
            else
                ret = ErrorResult(filePathP.getError());
        } else version (Posix) {
            auto filePathP = FilePath.from("libcrypto.so");

            if (filePathP)
                handled = attempt(filePathP.get);
            else
                ret = ErrorResult(filePathP.getError());
        } else {
            ret = ErrorResult(PlatformNotImplementedException("Missing default for libcrypto shared library, cannot load"));
        }
    }

    if (!handled)
        ret = ErrorResult(UnknownPlatformBehaviorException("Missing libcrypto shared library, cannot load"));

    if (!ret)
        unloadLibCrypto();

    return ret;
}

///
void unloadLibCrypto() @trusted {
    libCryptoSymbolLoader.unload(() {
        static foreach (f; AllFunctions) {
            mixin(f ~ " = null;");
        }
    });
}

private pragma(crt_destructor) extern (C) void deinitializeLibCryptoAutomatically() {
    unloadLibCrypto;
}

private:

static immutable AllFunctions = asn1FUNCTIONS ~ bioFUNCTIONS ~ bnFUNCTIONS ~ bufferFUNCTIONS ~ cryptoFUNCTIONS ~ evpFUNCTIONS ~ errFUNCTIONS ~
    pemFUNCTIONS ~ safestackFUNCTIONS ~ stackFUNCTIONS ~ typesFUNCTIONS ~ x509FUNCTIONS ~ objmacFUNCTIONS ~ objectsFUNCTIONS ~ rsaFUNCTIONS;
