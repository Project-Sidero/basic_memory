module sidero.base.bindings.openssl.libcrypto.obj_mac;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] objmacFUNCTIONS = [];

///
enum {
    ///
    NID_commonName = 13,
    ///
    NID_subject_alt_name = 85,
}
