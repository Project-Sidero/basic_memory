module sidero.base.bindings.openssl.libssl.ssl;
import sidero.base.bindings.openssl.libcrypto;
import core.stdc.config : c_ulong, c_long;

export nothrow @nogc:
package(sidero.base.bindings.openssl.libssl) enum string[] sslFUNCTIONS = [
    "SSL_get_error", "SSL_CTX_new", "SSL_CTX_free", "SSL_CTX_set_options", "TLS_method", "SSL_new", "SSL_free",
    "SSL_set_bio", "SSL_set0_rbio", "SSL_set0_wbio", "SSL_set_connect_state", "SSL_set_accept_state",
    "SSL_use_cert_and_key", "SSL_set_verify", "SSL_write_ex", "SSL_read_ex", "SSL_do_handshake", "SSL_ctrl"
];

enum {
    ///
    SSL_ERROR_NONE = 0,
    ///
    SSL_ERROR_SSL = 1,
    ///
    SSL_ERROR_WANT_READ = 2,
    ///
    SSL_ERROR_WANT_WRITE = 3,
    ///
    SSL_ERROR_WANT_X509_LOOKUP = 4,
    ///
    SSL_ERROR_SYSCALL = 5,
    ///
    SSL_ERROR_ZERO_RETURN = 6,
    ///
    SSL_ERROR_WANT_CONNECT = 7,
    ///
    SSL_ERROR_WANT_ACCEPT = 8,
    ///
    SSL_ERROR_WANT_ASYNC = 9,
    ///
    SSL_ERROR_WANT_ASYNC_JOB = 10,
    ///
    SSL_ERROR_WANT_CLIENT_HELLO_CB = 11,
    ///
    SSL_ERROR_WANT_RETRY_VERIFY = 12,

    ///
    SSL_CTRL_SET_TLSEXT_HOSTNAME = 55,

    ///
    SSL_VERIFY_NONE = 0x00,
    ///
    SSL_VERIFY_PEER = 0x01,
    ///
    SSL_VERIFY_FAIL_IF_NO_PEER_CERT = 0x02,
    ///
    SSL_VERIFY_CLIENT_ONCE = 0x04,
    ///
    SSL_VERIFY_POST_HANDSHAKE = 0x08,
}

///
struct ssl_method_st;
///
alias SSL_METHOD = ssl_method_st;

///
struct ssl_session_st;
///
alias SSL_SESSION = ssl_session_st;

///
alias SSL_verify_cb = extern (C) int function(int preverify_ok, X509_STORE_CTX* x509_ctx);

enum {
    ///
    SSL_OP_TLSEXT_PADDING = 1 << 4,
    ///
    SSL_OP_SAFARI_ECDHE_ECDSA_BUG = 1 << 6,
    ///
    SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS = 1 << 11,
    ///
    SSL_OP_NO_SSLv3 = 1 << 25,
    ///
    SSL_OP_CRYPTOPRO_TLSEXT_BUG = 1 << 31,

    ///
    SSL_OP_ALL = SSL_OP_CRYPTOPRO_TLSEXT_BUG |
        SSL_OP_DONT_INSERT_EMPTY_FRAGMENTS | SSL_OP_TLSEXT_PADDING | SSL_OP_SAFARI_ECDHE_ECDSA_BUG,
}

///
alias f_SSL_get_error = extern (C) int function(const SSL* ssl, int ret);

///
alias f_SSL_CTX_new = extern (C) SSL_CTX* function(const SSL_METHOD* meth);
///
alias f_SSL_CTX_free = extern (C) void function(SSL_CTX*);
///
alias f_SSL_CTX_set_options = extern (C) ulong function(SSL_CTX* ctx, ulong op);

///
alias f_TLS_method = extern (C) const(SSL_METHOD)* function();

///
alias f_SSL_new = extern (C) SSL* function(SSL_CTX* ctx);
///
alias f_SSL_free = extern (C) void function(SSL* ssl);

///
alias f_SSL_set_bio = extern (C) void function(SSL* s, BIO* rbio, BIO* wbio);
///
alias f_SSL_set0_rbio = extern (C) void function(SSL* s, BIO* rbio);
///
alias f_SSL_set0_wbio = extern (C) void function(SSL* s, BIO* wbio);

///
alias f_SSL_set_connect_state = extern (C) void function(SSL* s);
///
alias f_SSL_set_accept_state = extern (C) void function(SSL* s);
///
alias f_SSL_use_cert_and_key = extern (C) int function(SSL* ssl, X509* x509, EVP_PKEY* privatekey, STACK_OF!X509* chain, int override_);
//
alias f_SSL_set_verify = extern (C) void function(SSL* s, int mode, SSL_verify_cb callback);

///
alias f_SSL_write_ex = extern (C) int function(SSL* s, const void* buf, size_t num, size_t* written);
///
alias f_SSL_read_ex = extern (C) int function(SSL* ssl, void* buf, size_t num, size_t* readbytes);

///
alias f_SSL_do_handshake = extern (C) int function(SSL* s);

///
alias f_SSL_ctrl = extern (C) c_long function(SSL* ssl, int cmd, c_long larg, void* parg);

__gshared {
    ///
    f_SSL_get_error SSL_get_error;

    ///
    f_SSL_CTX_new SSL_CTX_new;
    ///
    f_SSL_CTX_free SSL_CTX_free;
    ///
    f_SSL_CTX_set_options SSL_CTX_set_options;

    ///
    f_TLS_method TLS_method;

    ///
    f_SSL_new SSL_new;
    ///
    f_SSL_free SSL_free;

    ///
    f_SSL_set_bio SSL_set_bio;
    ///
    f_SSL_set0_rbio SSL_set0_rbio;

    ///
    f_SSL_set_connect_state SSL_set_connect_state;
    ///
    f_SSL_set_accept_state SSL_set_accept_state;
    ///
    f_SSL_use_cert_and_key SSL_use_cert_and_key;
    ///
    f_SSL_set_verify SSL_set_verify;

    ///
    f_SSL_write_ex SSL_write_ex;
    ///
    f_SSL_read_ex SSL_read_ex;
    ///
    f_SSL_set0_wbio SSL_set0_wbio;

    ///
    f_SSL_do_handshake SSL_do_handshake;

    ///
    f_SSL_ctrl SSL_ctrl;
}
