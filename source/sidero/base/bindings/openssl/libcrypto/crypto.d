module sidero.base.bindings.openssl.libcrypto.crypto;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] cryptoFUNCTIONS = ["CRYPTO_free"];

///
void OPENSSL_free(void* addr, string mod = __MODULE__, int line = __LINE__) {
    CRYPTO_free(addr, mod.ptr, line);
}

///
alias f_CRYPTO_free = void function(void* ptr, const char* file, int line);

///
__gshared {
    ///
    f_CRYPTO_free CRYPTO_free;
}
