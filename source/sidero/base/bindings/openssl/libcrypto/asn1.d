module sidero.base.bindings.openssl.libcrypto.asn1;
import sidero.base.bindings.openssl.libcrypto.types;
import core.stdc.config : c_long;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] asn1FUNCTIONS = [
    "ASN1_STRING_to_UTF8", "ASN1_INTEGER_set", "ASN1_STRING_set", "ASN1_STRING_type_new", "ASN1_STRING_free"
];

///
enum {
    ///
    MBSTRING_FLAG = 0x1000,
    ///
    MBSTRING_UTF8 = MBSTRING_FLAG,

    ///
    V_ASN1_OCTET_STRING = 4,
}

///
alias f_ASN1_STRING_to_UTF8 = extern (C) int function(ref char*, const ASN1_STRING*);
///
alias f_ASN1_INTEGER_set = extern (C) int function(const(ASN1_INTEGER)* a, c_long v);
///
alias f_ASN1_STRING_set = extern (C) int function(ASN1_STRING* str, const(void)* data, int len);

///
alias f_ASN1_STRING_type_new = extern (C) ASN1_STRING* function(int type);
///
alias f_ASN1_STRING_free = extern (C) void function(ASN1_STRING* a);

///
__gshared {
    ///
    f_ASN1_STRING_to_UTF8 ASN1_STRING_to_UTF8;
    ///
    f_ASN1_INTEGER_set ASN1_INTEGER_set;
    ///
    f_ASN1_STRING_set ASN1_STRING_set;
    ///
    f_ASN1_STRING_type_new ASN1_STRING_type_new;
    ///
    f_ASN1_STRING_free ASN1_STRING_free;
}
