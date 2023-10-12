module sidero.base.bindings.openssl.libcrypto.asn1;
import sidero.base.bindings.openssl.libcrypto.types;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] asn1FUNCTIONS = ["ASN1_STRING_to_UTF8"];

///
alias f_ASN1_STRING_to_UTF8 = int function(ref char*, const ASN1_STRING*);

///
__gshared {
    f_ASN1_STRING_to_UTF8 ASN1_STRING_to_UTF8;
}
