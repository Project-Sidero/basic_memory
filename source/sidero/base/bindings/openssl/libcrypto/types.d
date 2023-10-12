module sidero.base.bindings.openssl.libcrypto.types;

export extern(C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] typesFUNCTIONS = [];

///
struct bio_st;
///
alias BIO = bio_st;

///
struct evp_pkey_st;
///
alias EVP_PKEY = evp_pkey_st;

///
struct x509_st;
///
alias X509 = x509_st;

///
struct asn1_string_st;
///
alias ASN1_OCTET_STRING = asn1_string_st;
///
alias ASN1_TIME = asn1_string_st;
///
alias ASN1_STRING = asn1_string_st;

///
struct X509_crl_st;
///
alias X509_CRL = X509_crl_st;

///
struct evp_cipher_st;
///
alias EVP_CIPHER = evp_cipher_st;

///
struct X509_name_st;
///
alias X509_NAME = X509_name_st;

///
struct asn1_object_st;
///
alias ASN1_OBJECT = asn1_object_st;

///
alias pem_password_cb = extern (C) int function(ubyte* buf, int size, int rwflag, void* userdata);

