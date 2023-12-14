module sidero.base.bindings.openssl.libcrypto.bn;
import sidero.base.bindings.openssl.libcrypto.types;
import core.stdc.config : c_ulong, c_long;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] bnFUNCTIONS = [
    "BN_new", "BN_set_word", "BN_free"
];

// I'm not entirely sure about this, but I think it'll be correct
alias BN_ULONG = c_ulong;

///
alias f_BN_new = extern(C) BIGNUM* function();
///
alias f_BN_set_word = extern(C) int function(BIGNUM* a, BN_ULONG w);
///
alias f_BN_free = extern(C) void function(BIGNUM* a);

///
__gshared {
    ///
    @("optional")
    f_BN_new BN_new;
    ///
    @("optional")
    f_BN_set_word BN_set_word;
    ///
    @("optional")
    f_BN_free BN_free;
}
