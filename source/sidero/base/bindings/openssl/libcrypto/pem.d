module sidero.base.bindings.openssl.libcrypto.pem;
import sidero.base.bindings.openssl.libcrypto.types;
import sidero.base.bindings.openssl.libcrypto.safestack;
import sidero.base.bindings.openssl.libcrypto.x509;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] pemFUNCTIONS = [
    "PEM_X509_INFO_read_bio", "PEM_write_bio_PUBKEY", "PEM_write_bio_PrivateKey_traditional"
];

///
alias f_PEM_X509_INFO_read_bio = STACK_OF!X509_INFO* function(BIO* bp, STACK_OF!X509_INFO* sk, pem_password_cb cb, void* u);
///
alias f_PEM_write_bio_PUBKEY = int function(BIO* bp, EVP_PKEY* x);
///
alias f_PEM_write_bio_PrivateKey_traditional = int function(BIO* bp, const EVP_PKEY* x, const EVP_CIPHER* enc,
        const ubyte* kstr, int klen, pem_password_cb* cb, void* u);

///
__gshared {
    ///
    f_PEM_X509_INFO_read_bio PEM_X509_INFO_read_bio;
    ///
    f_PEM_write_bio_PUBKEY PEM_write_bio_PUBKEY;
    ///
    f_PEM_write_bio_PrivateKey_traditional PEM_write_bio_PrivateKey_traditional;
}
