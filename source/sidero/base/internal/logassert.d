module sidero.base.internal.logassert;
import sidero.base.errors.message;

export @safe nothrow @nogc:

void logAssert(bool condition, scope string message, string moduleName = __MODULE__, int line = __LINE__) @trusted {
    ErrorInfo errorInfo;
    logAssert(condition, message, errorInfo, moduleName, line);
}

void logAssert(bool condition, scope string message, scope ref const ErrorInfo errorInfo, string moduleName = __MODULE__, int line = __LINE__) @trusted {
    import core.stdc.stdio : fprintf;
    import core.stdc.stdlib : exit;

    if(condition)
        return;

    if(message is null && !errorInfo.isSet()) {
        // what? no error message, ok
        fprintf(stderr, "Assert: condition failed `%s`:%d\n".ptr, moduleName.ptr, line);
    } else if(message is null) {
        fprintf(stderr, "Assert: condition failed `%s`:%d from `%s`:%d with error: $%s=%s\n".ptr, moduleName.ptr, line,
                errorInfo.moduleName.ptr, errorInfo.line, errorInfo.info.id.ptr, errorInfo.info.message.ptr);
    } else if(!errorInfo.isSet()) {
        fprintf(stderr, "Assert: condition failed `%s`:%d with: %s\n".ptr, moduleName.ptr, line, message.ptr);
    } else {
        fprintf(stderr, "Assert: condition failed `%s`:%d from `%s`:%d with error: $%s=%s with: %s\n".ptr,
                moduleName.ptr, line, errorInfo.moduleName.ptr, errorInfo.line, errorInfo.info.id.ptr,
                errorInfo.info.message.ptr, message.ptr);
    }

    exit(1);
    assert(0);
}

import core.stdc.stdio : FILE;

version(CRuntime_Microsoft) {
    // from druntime bug fix

    extern (C) FILE* __acrt_iob_func(int hnd) nothrow @nogc;
    FILE* stdin()() @trusted nothrow @nogc {
        return __acrt_iob_func(0);
    }

    FILE* stdout()() @trusted nothrow @nogc {
        return __acrt_iob_func(1);
    }

    FILE* stderr()() @trusted nothrow @nogc {
        return __acrt_iob_func(2);
    }
} else {
    public import core.stdc.stdio : stdin, stdout, stderr;
}
