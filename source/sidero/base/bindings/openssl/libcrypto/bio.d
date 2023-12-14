module sidero.base.bindings.openssl.libcrypto.bio;
import sidero.base.bindings.openssl.libcrypto.types;
import core.stdc.config : c_ulong, c_long;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] bioFUNCTIONS = [
    "BIO_new", "BIO_new_file", "BIO_s_mem", "BIO_free", "BIO_ctrl", "BIO_set_flags", "BIO_read_ex", "BIO_read",
    "BIO_puts", "BIO_write", "BIO_push"
];

///
c_ulong BIO_get_mem_data(BIO* bp, ref ubyte* data) {
    pragma(inline, true);
    return cast(c_ulong)BIO_ctrl(bp, BIO_CTRL_INFO, 0, cast(void*)&data);
}

///
c_ulong BIO_set_mem_buf(BIO* bp, BUF_MEM* data, int c) {
    pragma(inline, true);
    return cast(c_ulong)BIO_ctrl(bp, BIO_C_SET_BUF_MEM, c, cast(void*)&data);
}

///
c_ulong BIO_get_mem_ptr(BIO* bp, ref BUF_MEM* data) {
    pragma(inline, true);
    return cast(c_ulong)BIO_ctrl(bp, BIO_C_GET_BUF_MEM_PTR, 0, cast(void*)&data);
}

///
enum {
    ///
    BIO_NOCLOSE = 0,
    ///
    BIO_CLOSE = 1,

    ///
    BIO_CTRL_INFO = 3,
    ///
    BIO_C_SET_BUF_MEM = 114,
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
alias f_BIO_new = extern (C) BIO* function(const BIO_METHOD* type);
///
alias f_BIO_new_file = extern (C) BIO* function(const char* filename, const char* mode);
///
alias f_BIO_s_mem = extern (C) const(BIO_METHOD)* function();
///
alias f_BIO_free = extern (C) int function(BIO* a);
///
alias f_BIO_ctrl = extern (C) long function(BIO* bp, int cmd, c_long larg, void* parg);
///
alias f_BIO_set_flags = extern (C) void function(BIO* b, int flags);

///
alias f_BIO_read_ex = extern (C) int function(BIO* b, ubyte* data, size_t dlen, size_t* readbytes);
///
alias f_BIO_read = extern (C) int function(BIO* b, void* data, int dlen);
///
alias f_BIO_puts = extern (C) int function(BIO* b, const(char)* buf);
///
alias f_BIO_write = extern (C) int function(BIO* b, void* data, int dlen);

///
alias f_BIO_push = extern (C) BIO* function(BIO* b, BIO* next);

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
    ///
    f_BIO_set_flags BIO_set_flags;

    ///
    f_BIO_read_ex BIO_read_ex;
    ///
    f_BIO_read BIO_read;
    ///
    f_BIO_puts BIO_puts;
    ///
    f_BIO_write BIO_write;

    ///
    f_BIO_push BIO_push;
}
