module sidero.base.bindings.openssl.libcrypto.objects;
import sidero.base.bindings.openssl.libcrypto.types;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] objectsFUNCTIONS = ["OBJ_obj2nid"];

///
alias f_OBJ_obj2nid = int function(const ASN1_OBJECT* o);

///
__gshared {
    ///
    f_OBJ_obj2nid OBJ_obj2nid;
}
