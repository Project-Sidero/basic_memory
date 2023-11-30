module sidero.base.bindings.openssl.libcrypto.objects;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] objectsFUNCTIONS = ["OBJ_obj2nid"];

///
alias f_OBJ_obj2nid = extern (C) int function(const ASN1_OBJECT* o);

///
__gshared {
    ///
    f_OBJ_obj2nid OBJ_obj2nid;
}
