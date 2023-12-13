module sidero.base.bindings.openssl.libcrypto.evp;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] evpFUNCTIONS = ["EVP_PKEY_new", "EVP_PKEY_free", "EVP_sha1"];

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

///
alias f_EVP_PKEY_new = extern(C) EVP_PKEY* function();
///
alias f_EVP_PKEY_free = extern(C) void function(EVP_PKEY* key);


///
alias f_EVP_sha1 = extern(C) const(EVP_MD)* function();

///
__gshared {
    ///
    f_EVP_PKEY_new EVP_PKEY_new;
    ///
    f_EVP_PKEY_free EVP_PKEY_free;
    ///
    f_EVP_sha1 EVP_sha1;
}
