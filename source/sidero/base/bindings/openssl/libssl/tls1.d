module sidero.base.bindings.openssl.libssl.tls1;
import sidero.base.bindings.openssl.libssl.ssl;
import sidero.base.bindings.openssl.libcrypto;
import core.stdc.config : c_ulong, c_long;

export extern (C) nothrow @nogc:
package(sidero.base.bindings.openssl.libssl) enum string[] tls1FUNCTIONS = [];

enum {
    ///
    TLSEXT_NAMETYPE_host_name = 0,
}

///
c_long SSL_set_tlsext_host_name(SSL* ssl, char* name) {
    return SSL_ctrl(ssl, SSL_CTRL_SET_TLSEXT_HOSTNAME, TLSEXT_NAMETYPE_host_name, cast(void*)name);
}
