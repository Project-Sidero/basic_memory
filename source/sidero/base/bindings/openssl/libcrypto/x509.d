module sidero.base.bindings.openssl.libcrypto.x509;
import sidero.base.bindings.openssl.libcrypto.types;
import sidero.base.bindings.openssl.libcrypto.evp;
import sidero.base.bindings.openssl.libcrypto.safestack;
import sidero.base.bindings.openssl.libcrypto.stack;
import core.stdc.config : c_long;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] x509FUNCTIONS = [
    "X509_get_issuer_name", "X509_get_subject_name", "X509_get0_notBefore", "X509_get0_notAfter",
    "X509_getm_notBefore", "X509_getm_notAfter", "X509_get0_pubkey", "X509_set_pubkey",
    "X509_NAME_entry_count", "X509_NAME_get_entry", "X509_NAME_ENTRY_get_data",
    "X509_new_ex", "X509_free", "X509_PKEY_free", "X509_INFO_free", "X509_NAME_ENTRY_get_object", "X509_sign",
    "X509_gmtime_adj", "X509_set_version", "X509_get0_serialNumber", "X509_get_serialNumber", "X509_NAME_add_entry_by_txt",
    "X509_set_issuer_name", "X509_EXTENSION_create_by_NID", "X509_EXTENSION_free", "X509_add_ext",
];

///
enum {
    ///
    X509_VERSION_3 = 2,
}

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
struct X509_algor_st;
///
alias X509_ALGOR = X509_algor_st;

///
struct X509_extension_st;
///
alias X509_EXTENSION = X509_extension_st;

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
alias f_X509_get_issuer_name = extern (C) X509_NAME* function(const X509* a);
///
alias f_X509_get_subject_name = extern (C) X509_NAME* function(const X509* a);
///
alias f_X509_get0_notBefore = extern (C) const(ASN1_TIME)* function(const X509* x);
///
alias f_X509_get0_notAfter = extern (C) const(ASN1_TIME)* function(const X509* x);
///
alias f_X509_getm_notBefore = extern (C) ASN1_TIME* function(const X509* x);
///
alias f_X509_getm_notAfter = extern (C) ASN1_TIME* function(const X509* x);
///
alias f_X509_get0_pubkey = extern (C) EVP_PKEY* function(const X509* x);
///
alias f_X509_set_pubkey = extern (C) int function(X509* x, EVP_PKEY* pkey);

///
alias f_X509_NAME_entry_count = extern (C) int function(const X509_NAME* name);
///
alias f_X509_NAME_get_entry = extern (C) X509_NAME_ENTRY* function(const X509_NAME* name, int loc);
///
alias f_X509_NAME_ENTRY_get_data = extern (C) ASN1_STRING* function(const X509_NAME_ENTRY* ne);
///
alias f_X509_NAME_ENTRY_get_object = extern (C) ASN1_OBJECT* function(const X509_NAME_ENTRY* ne);

///
alias f_X509_new_ex = extern (C) X509* function(OSSL_LIB_CTX* libctx, const char* propq);
///
alias f_X509_free = extern (C) void function(X509* a);
///
alias f_X509_PKEY_free = extern (C) void function(X509_PKEY* a);
///
alias f_X509_INFO_free = extern (C) void function(X509_INFO* a);

///
alias f_X509_sign = extern (C) int function(X509* x, EVP_PKEY* pkey, const EVP_MD* md);

///
alias f_X509_gmtime_adj = extern (C) ASN1_TIME* function(ASN1_TIME* s, c_long adj);
///
alias f_X509_set_version = extern (C) int function(X509* x, c_long version_);
///
alias f_X509_get0_serialNumber = extern (C) const(ASN1_INTEGER)* function(const(X509)* x);
///
alias f_X509_get_serialNumber = extern (C) ASN1_INTEGER* function(X509* x);
///
alias f_X509_NAME_add_entry_by_txt = extern (C) int function(X509_NAME* name, const(char)* field, int type,
        const(ubyte)* bytes, int len, int loc, int set);
///
alias f_X509_set_issuer_name = extern (C) int function(X509* x, const(X509_NAME)* name);

///
alias f_X509_EXTENSION_create_by_NID = extern (C) X509_EXTENSION* function(X509_EXTENSION** ex, int nid, int crit, ASN1_OCTET_STRING* data);
///
alias f_X509_EXTENSION_free = extern (C) void function(X509_EXTENSION* a);
///
alias f_X509_add_ext = extern (C) int function(X509* x, X509_EXTENSION* ex, int loc);

///
alias sk_X509_compfunc = extern (C) int function(const X509** a, const X509** b);

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
    f_X509_getm_notBefore X509_getm_notBefore;
    ///
    f_X509_getm_notAfter X509_getm_notAfter;
    ///
    f_X509_get0_pubkey X509_get0_pubkey;
    ///
    f_X509_set_pubkey X509_set_pubkey;
    ///
    f_X509_NAME_entry_count X509_NAME_entry_count;
    ///
    f_X509_NAME_get_entry X509_NAME_get_entry;
    ///
    f_X509_NAME_ENTRY_get_data X509_NAME_ENTRY_get_data;
    ///
    f_X509_new_ex X509_new_ex;
    ///
    f_X509_free X509_free;
    ///
    f_X509_PKEY_free X509_PKEY_free;
    ///
    f_X509_INFO_free X509_INFO_free;
    ///
    f_X509_NAME_ENTRY_get_object X509_NAME_ENTRY_get_object;
    ///
    f_X509_sign X509_sign;
    ///
    f_X509_gmtime_adj X509_gmtime_adj;
    ///
    f_X509_set_version X509_set_version;
    ///
    f_X509_get0_serialNumber X509_get0_serialNumber;
    ///
    f_X509_get_serialNumber X509_get_serialNumber;
    ///
    f_X509_NAME_add_entry_by_txt X509_NAME_add_entry_by_txt;
    ///
    f_X509_set_issuer_name X509_set_issuer_name;
    ///
    f_X509_EXTENSION_create_by_NID X509_EXTENSION_create_by_NID;
    ///
    f_X509_EXTENSION_free X509_EXTENSION_free;
    ///
    f_X509_add_ext X509_add_ext;
}
