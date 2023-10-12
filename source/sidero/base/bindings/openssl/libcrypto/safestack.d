module sidero.base.bindings.openssl.libcrypto.safestack;

export extern(C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] safestackFUNCTIONS = [];

///
struct STACK_OF(Type);
