module sidero.base.bindings.openssl.libcrypto.x509;
import sidero.base.bindings.openssl.libcrypto.types;
import sidero.base.bindings.openssl.libcrypto.evp;
import sidero.base.bindings.openssl.libcrypto.safestack;
import sidero.base.bindings.openssl.libcrypto.stack;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] x509FUNCTIONS = [
    "X509_get_issuer_name", "X509_get_subject_name", "X509_get0_notBefore", "X509_get0_notAfter", "X509_get0_pubkey",
    "X509_NAME_entry_count", "X509_NAME_get_entry", "X509_NAME_ENTRY_get_data", "X509_free", "X509_PKEY_free",
    "X509_INFO_free", "X509_NAME_ENTRY_get_object"
];

///
struct X509_algor_st;
///
alias X509_ALGOR = X509_algor_st;

///
struct private_key_st {
    ///
    int version_;
    ///
    X509_ALGOR* enc_algor;
    ///
    ASN1_OCTET_STRING* enc_pkey;
    ///
    EVP_PKEY* dec_pkey;
    ///
    int key_length;
    ///
    char* key_data;
    ///
    int key_free;
    ///
    EVP_CIPHER_INFO cipher;
}

///
alias X509_PKEY = private_key_st;

///
struct X509_info_st {
    ///
    X509* x509;
    ///
    X509_CRL* crl;
    ///
    X509_PKEY* x_pkey;
    ///
    EVP_CIPHER_INFO enc_cipher;
    ///
    int enc_len;
    ///
    ubyte* enc_data;
}

///
alias X509_INFO = X509_info_st;

///
struct X509_name_entry_st;
///
alias X509_NAME_ENTRY = X509_name_entry_st;

///
alias f_X509_get_issuer_name = X509_NAME* function(const X509* a);
///
alias f_X509_get_subject_name = X509_NAME* function(const X509* a);
///
alias f_X509_get0_notBefore = const(ASN1_TIME)* function(const X509* x);
///
alias f_X509_get0_notAfter = const(ASN1_TIME)* function(const X509* x);
///
alias f_X509_get0_pubkey = EVP_PKEY* function(const X509* x);

///
alias f_X509_NAME_entry_count = int function(const X509_NAME* name);
///
alias f_X509_NAME_get_entry = X509_NAME_ENTRY* function(const X509_NAME* name, int loc);
///
alias f_X509_NAME_ENTRY_get_data = ASN1_STRING* function(const X509_NAME_ENTRY* ne);
///
alias f_X509_NAME_ENTRY_get_object = ASN1_OBJECT* function(const X509_NAME_ENTRY* ne);

///
alias f_X509_free = void function(X509* a);
///
alias f_X509_PKEY_free = void function(X509_PKEY* a);
///
alias f_X509_INFO_free = void function(X509_INFO* a);

///
alias sk_X509_compfunc = int function(const X509* *a, const X509 * *b);

///
int sk_X509_INFO_num(const STACK_OF!X509_INFO* sk) {
    pragma(inline, true);
    return OPENSSL_sk_num(cast(const OPENSSL_STACK*)sk);
}

///
X509_INFO* sk_X509_INFO_value(const STACK_OF!X509_INFO* sk, int idx) {
    pragma(inline, true);
    return cast(X509_INFO*)OPENSSL_sk_value(cast(const OPENSSL_STACK*)sk, idx);
}

///
void sk_X509_INFO_pop_free(STACK_OF!X509_INFO* sk, f_OPENSSL_sk_pop_free_freefunc freefunc) {
    pragma(inline, true);
    OPENSSL_sk_pop_free(cast(stack_st*)sk, freefunc);
}

///
int sk_X509_num(const STACK_OF!X509* sk) {
    pragma(inline, true);
    return OPENSSL_sk_num(cast(const OPENSSL_STACK*)sk);
}

///
STACK_OF!X509* sk_X509_new_reserve(sk_X509_compfunc compare, int n) {
    pragma(inline, true);
    return cast(STACK_OF!X509*)OPENSSL_sk_new_reserve(cast(OPENSSL_sk_compfunc)compare, n);
}

///
void sk_X509_pop_free(STACK_OF!X509* sk, f_OPENSSL_sk_pop_free_freefunc freefunc) {
    pragma(inline, true);
    OPENSSL_sk_pop_free(cast(stack_st*)sk, freefunc);
}

///
void sk_X509_push(STACK_OF!X509* sk, X509* value) {
    pragma(inline, true);
    OPENSSL_sk_push(cast(stack_st*)sk, value);
}

///
__gshared {
    ///
    f_X509_get_issuer_name X509_get_issuer_name;
    ///
    f_X509_get_subject_name X509_get_subject_name;
    ///
    f_X509_get0_notBefore X509_get0_notBefore;
    ///
    f_X509_get0_notAfter X509_get0_notAfter;
    ///
    f_X509_get0_pubkey X509_get0_pubkey;
    ///
    f_X509_NAME_entry_count X509_NAME_entry_count;
    ///
    f_X509_NAME_get_entry X509_NAME_get_entry;
    ///
    f_X509_NAME_ENTRY_get_data X509_NAME_ENTRY_get_data;
    ///
    f_X509_free X509_free;
    ///
    f_X509_PKEY_free X509_PKEY_free;
    ///
    f_X509_INFO_free X509_INFO_free;
    ///
    f_X509_NAME_ENTRY_get_object X509_NAME_ENTRY_get_object;
}
