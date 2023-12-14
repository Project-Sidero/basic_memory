module sidero.base.bindings.openssl.libcrypto.rsa;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] rsaFUNCTIONS = [
    "EVP_RSA_gen", "RSA_generate_key_ex", "RSA_new", "RSA_free"
];

///
enum {
    ///
    RSA_F4 = 0x10001
}

///
alias f_EVP_RSA_gen = extern (C) EVP_PKEY* function(uint bits);
///
alias f_RSA_generate_key_ex = extern (C) int function(RSA* rsa, int bits, BIGNUM* e, BN_GENCB* cb);
///
alias f_RSA_new = extern (C) RSA* function();
///
alias f_RSA_free = extern (C) void function(RSA* rsa);

///
__gshared {
    ///
    @("optional")
    f_EVP_RSA_gen EVP_RSA_gen;
    ///
    @("optional")
    f_RSA_generate_key_ex RSA_generate_key_ex;
    ///
    @("optional")
    f_RSA_new RSA_new;
    ///
    @("optional")
    f_RSA_free RSA_free;
}
