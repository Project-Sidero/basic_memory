module sidero.base.bindings.openssl.libcrypto.buffer;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] bufferFUNCTIONS = ["BUF_MEM_new"];

///
alias f_BUF_MEM_new = extern (C) BUF_MEM* function();

__gshared {
    ///
    f_BUF_MEM_new BUF_MEM_new;
}
