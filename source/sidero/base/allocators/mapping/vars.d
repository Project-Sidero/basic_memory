/**
    Note: has code from druntime.

    License: Boost
 */
module sidero.base.allocators.mapping.vars;
import std.algorithm.comparison : max;
@trusted nothrow @nogc:

///
enum GoodAlignment = max(real.alignof, double.alignof);
// in practice this will provide a good value regardless of target

///
@property size_t PAGESIZE() pure {
    return (cast(typeof(&PAGESIZE))&PAGESIZE_get)();
}

private {
    // Bug: https://issues.dlang.org/show_bug.cgi?id=22031
    size_t PAGESIZE_get() @safe {
        if (PAGESIZE_ == 0)
            initializeMappingVariables();
        return PAGESIZE_;
    }

    size_t PAGESIZE_;
}

pragma(crt_constructor) extern (C) void initializeMappingVariables() {
    // COPIED FROM druntime core.thread.types
    version (Windows) {
        import core.sys.windows.winbase;

        SYSTEM_INFO info;
        GetSystemInfo(&info);

        PAGESIZE_ = info.dwPageSize;
        assert(PAGESIZE < int.max);
    } else version (PAGESIZE_) {
        import core.sys.posix.unistd;

        PAGESIZE_ = cast(size_t)sysconf(_SC_PAGESIZE);
    } else {
        pragma(msg, "Unknown platform, defaulting PAGESIZE in " ~ __MODULE__ ~ " to 64kb");
        PAGESIZE_ = 64 * 1024;
    }
}
