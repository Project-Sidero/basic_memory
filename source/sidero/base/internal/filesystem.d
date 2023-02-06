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
                return typeof(return).init;
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

bool directoryExists(String_UTF8 directory) @trusted {
    version (Posix) {
        import core.sys.posix.sys.stat : lstat, stat_t, S_ISDIR;

        if (!directory.isPtrNullTerminated)
            directory = directory.dup;

        stat_t buffer;
        return lstat(cast(char*)directory.ptr, &buffer) > 0 && S_ISDIR(buffer.st_mode);
    } else version (Windows) {
        import core.sys.windows.winbase : GetFileAttributesW;
        import core.sys.windows.winnt : INVALID_FILE_ATTRIBUTES, FILE_ATTRIBUTE_DIRECTORY;

        String_UTF16 directory16 = directory.byUTF16;
        if (!directory16.isPtrNullTerminated)
            directory16 = directory16.dup;

        auto got = GetFileAttributesW(cast(wchar*)directory16.ptr);
        return got != INVALID_FILE_ATTRIBUTES && got & FILE_ATTRIBUTE_DIRECTORY;
    } else
        static assert(0, "Unimplemented");
}

struct FileAppender {
    private {
        import core.stdc.stdio : FILE, fflush, fclose, fopen, fwrite;

        FILE* descriptor;
        String_UTF8 filename;
    }

@safe nothrow @nogc:

    this(return scope ref FileAppender other) scope {
        this.tupleof = other.tupleof;
        other.tupleof = FileAppender.init.tupleof;
    }

    this(String_UTF8 filename) scope @trusted {
        if (filename.isPtrNullTerminated)
            this.filename = filename;
        else
            this.filename = filename.dup;

        descriptor = fopen(cast(char*)this.filename.ptr, "w+");
    }

    @disable this(this);

    ~this() scope @trusted {
        if (descriptor !is null) {
            fflush(descriptor);
            fclose(descriptor);
        }
    }

    bool isNull() scope {
        return descriptor is null;
    }

    private void reopen() scope @trusted {
        fflush(descriptor);
        fclose(descriptor);
        descriptor = fopen(cast(char*)this.filename.ptr, "w+");
    }

    void append(scope StringBuilder_UTF8 input) scope {
        this.append(input.asReadOnly);
    }

    void append(scope StringBuilder_UTF16 input) scope {
        this.append(input.byUTF8.asReadOnly);
    }

    void append(scope StringBuilder_UTF32 input) scope {
        this.append(input.byUTF8.asReadOnly);
    }

    void append(scope String_UTF16 input) scope @trusted {
        this.append(input.byUTF8);
    }

    void append(scope String_UTF32 input) scope @trusted {
        this.append(input.byUTF8);
    }

    void append(scope String_UTF8 input) scope @trusted {
        if (isNull || input.length == 0)
            return;

        if (!input.isPtrNullTerminated)
            input = input.dup;

        size_t writtenSoFar, written, failedAttempt;

        while (!isNull && written < input.length && failedAttempt < 2) {
            written = fwrite(input.ptr + writtenSoFar, 1, input.length, descriptor);

            if (written == 0) {
                failedAttempt = 0;
                writtenSoFar += written;
            } else {
                failedAttempt++;
                reopen;
            }
        }
    }

    void append(scope StringBuilder_ASCII input) scope {
        this.append(input.asReadOnly);
    }

    void append(scope String_ASCII input) scope @trusted {
        if (isNull)
            return;

        if (!input.isPtrNullTerminated)
            input = input.dup;

        size_t writtenSoFar, written, failedAttempt;

        while (!isNull && written < input.length && failedAttempt < 2) {
            written = fwrite(input.ptr + writtenSoFar, 1, input.length, descriptor);

            if (written == 0) {
                failedAttempt = 0;
                writtenSoFar += written;
            } else {
                failedAttempt++;
                reopen;
            }
        }
    }
}
