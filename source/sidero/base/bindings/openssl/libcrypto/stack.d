module sidero.base.bindings.openssl.libcrypto.stack;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] stackFUNCTIONS = [
    "OPENSSL_sk_new_reserve", "OPENSSL_sk_num", "OPENSSL_sk_push", "OPENSSL_sk_value", "OPENSSL_sk_pop_free", "OPENSSL_sk_free"
];

///
struct stack_st;
///
alias OPENSSL_STACK = stack_st;

///
alias OPENSSL_sk_compfunc = int function(const void*, const void*);

///
alias f_OPENSSL_sk_new_reserve = OPENSSL_STACK* function(OPENSSL_sk_compfunc c, int n);

///
alias f_OPENSSL_sk_push = int function(OPENSSL_STACK *st, const void *data);

///
alias f_OPENSSL_sk_num = int function(const OPENSSL_STACK*);
///
alias f_OPENSSL_sk_value = void* function(const OPENSSL_STACK*, int);

///
alias f_OPENSSL_sk_pop_free_freefunc = void function(void*);
///
alias f_OPENSSL_sk_pop_free = void function(OPENSSL_STACK* st, f_OPENSSL_sk_pop_free_freefunc);

///
alias f_OPENSSL_sk_free = void function(OPENSSL_STACK*);

///
__gshared {
    ///
    f_OPENSSL_sk_new_reserve OPENSSL_sk_new_reserve;
    ///
    f_OPENSSL_sk_push OPENSSL_sk_push;
    ///
    f_OPENSSL_sk_num OPENSSL_sk_num;
    ///
    f_OPENSSL_sk_value OPENSSL_sk_value;
    ///
    f_OPENSSL_sk_pop_free OPENSSL_sk_pop_free;
    ///
    f_OPENSSL_sk_free OPENSSL_sk_free;
}
