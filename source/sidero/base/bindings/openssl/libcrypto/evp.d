module sidero.base.bindings.openssl.libcrypto.evp;
import sidero.base.bindings.openssl.libcrypto.types;

export extern(C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] evpFUNCTIONS = [];

///
enum {
    ///
    EVP_MAX_IV_LENGTH = 16,
}

///
struct evp_cipher_info_st {
    ///
    const EVP_CIPHER* cipher;
    ///
    ubyte[EVP_MAX_IV_LENGTH] iv;
}

///
alias EVP_CIPHER_INFO = evp_cipher_info_st;
