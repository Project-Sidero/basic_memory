module sidero.base.bindings.openssl.libcrypto.asn1;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] asn1FUNCTIONS = ["ASN1_STRING_to_UTF8"];

///
alias f_ASN1_STRING_to_UTF8 = extern (C) int function(ref char*, const ASN1_STRING*);

///
__gshared {
    f_ASN1_STRING_to_UTF8 ASN1_STRING_to_UTF8;
}
