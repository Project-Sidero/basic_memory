module sidero.base.bindings.openssl.libcrypto.evp;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] evpFUNCTIONS = [
    "EVP_PKEY_new", "EVP_PKEY_free", "EVP_PKEY_up_ref", "EVP_sha1", "EVP_PKEY_assign_RSA", "EVP_PKEY_Q_keygen"
];

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
alias f_EVP_PKEY_new = extern (C) EVP_PKEY* function();
///
alias f_EVP_PKEY_free = extern (C) void function(EVP_PKEY* key);
///
alias f_EVP_PKEY_up_ref = extern (C) int function(EVP_PKEY* key);

///
alias f_EVP_PKEY_assign_RSA = extern (C) int function(EVP_PKEY* pkey, RSA* key);

///
alias f_EVP_sha1 = extern (C) const(EVP_MD)* function();

///
alias f_EVP_PKEY_Q_keygen = extern(C) EVP_PKEY* function(OSSL_LIB_CTX* libctx, const(char)* propq, const(char)* type, ...);

///
__gshared {
    ///
    f_EVP_PKEY_new EVP_PKEY_new;
    ///
    f_EVP_PKEY_free EVP_PKEY_free;
    ///
    f_EVP_PKEY_up_ref EVP_PKEY_up_ref;
    ///
    f_EVP_sha1 EVP_sha1;

    ///
    @("optional")
    f_EVP_PKEY_assign_RSA EVP_PKEY_assign_RSA;

    ///
    @("optional")
    f_EVP_PKEY_Q_keygen EVP_PKEY_Q_keygen;
}
