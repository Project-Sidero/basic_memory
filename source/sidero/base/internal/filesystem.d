module sidero.base.internal.filesystem;
import sidero.base.containers.dynamicarray;
import sidero.base.text;
import sidero.base.allocators;

@safe nothrow @nogc:

DynamicArray!Type readFile(Type)(scope string filename, size_t ifNotSize = 0) @trusted {
    return readFile!Type(String_UTF8(filename), ifNotSize);
}

DynamicArray!Type readFile(Type)(scope String_UTF8 filename, size_t ifNotSize = 0) @trusted {
    import core.stdc.stdio;

    if (!filename.isPtrNullTerminated || filename.isEncodingChanged)
        filename = filename.dup;

    FILE* toRead = fopen(filename.unsafeGetLiteral.ptr, "rb");
    if (toRead is null)
        return typeof(return).init;

    typeof(return) ret;

    {
        auto got = fseek(toRead, 0, SEEK_END);
        auto toReserve = ftell(toRead);

        if (got == 0) {
            if (toReserve == ifNotSize) {
                fclose(toRead);
                return typeof(return ).init;
            }

            ret = typeof(return)(globalAllocator());
            ret.reserve(cast(size_t)toReserve);
        }

        rewind(toRead);
    }

    Type[1024] buffer;

    size_t read;
    while ((read = fread(buffer.ptr, 1, buffer.length, toRead)) > 0) {
        ret ~= buffer[0 .. read];
    }

    fclose(toRead);
    return ret;
}

ptrdiff_t getFileSize(scope string filename) @trusted {
    return getFileSize(String_UTF8(filename));
}

ptrdiff_t getFileSize(scope String_UTF8 filename) @trusted {
    import core.stdc.stdio;

    if (!filename.isPtrNullTerminated || filename.isEncodingChanged)
        filename = filename.dup;

    FILE* toRead = fopen(filename.unsafeGetLiteral.ptr, "rb");
    if (toRead is null)
        return -1;

    auto got = fseek(toRead, 0, SEEK_END);
    if (got != 0) {
        fclose(toRead);
        return -2;
    }

    auto ret = ftell(toRead);
    fclose(toRead);

    if (ret < 0)
        return -3;

    return cast(ptrdiff_t)ret;
}
