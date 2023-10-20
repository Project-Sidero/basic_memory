module sidero.base.bindings.openssl.libcrypto.buffer;
import sidero.base.bindings.openssl.libcrypto.types;

export extern (C) nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] bufferFUNCTIONS = ["BUF_MEM_new"];

///
alias f_BUF_MEM_new = BUF_MEM* function();

__gshared {
    ///
    f_BUF_MEM_new BUF_MEM_new;
}
