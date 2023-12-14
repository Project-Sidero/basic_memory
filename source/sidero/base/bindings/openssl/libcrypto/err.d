module sidero.base.bindings.openssl.libcrypto.err;
import sidero.base.bindings.openssl.libcrypto.types;

export nothrow @nogc:

package(sidero.base.bindings.openssl.libcrypto) enum string[] errFUNCTIONS = ["ERR_print_errors_cb"];

///
void ERR_print_errors() @trusted {
    import sidero.base.text;
    import sidero.base.console;

    StringBuilder_UTF8 builder;

    ERR_print_errors_cb((str, len, u) {
        StringBuilder_UTF8* builder = cast(StringBuilder_UTF8*)u;

        *builder ~= str[0 .. len];
        *builder ~= "\r\n";
        return 1;
    }, &builder);

    write(builder);
}

///
alias ERR_print_errors_cb_ptr = extern (C) int function(const(char)* str, size_t len, void* u);

///
alias f_ERR_print_errors_cb = extern (C) void function(ERR_print_errors_cb_ptr, void* u);

__gshared {
    ///
    f_ERR_print_errors_cb ERR_print_errors_cb;
}
