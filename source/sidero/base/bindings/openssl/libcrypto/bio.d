module sidero.base.bindings.openssl.libcrypto.bio;
import sidero.base.bindings.openssl.libcrypto.types;
import core.stdc.config : c_ulong, c_long;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] bioFUNCTIONS = [
    "BIO_new", "BIO_new_file", "BIO_s_mem", "BIO_free", "BIO_ctrl"
];

///
enum {
    ///
    BIO_CTRL_INFO = 3,
    ///
    BIO_C_GET_BUF_MEM_PTR = 115,

    ///
    BIO_FLAGS_MEM_RDONLY = 0x200,
}

///
struct bio_method_st;
///
alias BIO_METHOD = bio_method_st;

///
alias f_BIO_new = BIO* function(const BIO_METHOD* type);
///
alias f_BIO_new_file = BIO* function(const char* filename, const char* mode);
///
alias f_BIO_s_mem = const(BIO_METHOD)* function();
///
alias f_BIO_free = int function(BIO* a);
///
alias f_BIO_ctrl = long function(BIO* bp, int cmd, c_long larg, void* parg);

///
c_ulong BIO_get_mem_data(BIO* bp, ref ubyte* data) {
    pragma(inline, true);
    return cast(c_ulong)BIO_ctrl(bp, BIO_CTRL_INFO, 0, cast(void*)&data);
}

///
c_ulong BIO_get_mem_ptr(BIO* bp, ref BUF_MEM* data) {
    pragma(inline, true);
    return cast(c_ulong)BIO_ctrl(bp, BIO_C_GET_BUF_MEM_PTR, 0, cast(void*)&data);
}

///
__gshared {
    ///
    f_BIO_new BIO_new;
    ///
    f_BIO_new_file BIO_new_file;
    ///
    f_BIO_s_mem BIO_s_mem;
    ///
    f_BIO_free BIO_free;
    ///
    f_BIO_ctrl BIO_ctrl;
}
