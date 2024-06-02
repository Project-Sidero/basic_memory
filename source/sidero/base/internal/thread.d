module sidero.base.internal.thread;

export @safe nothrow @nogc:

void threadYield() @trusted {
    version (Windows) {
        import core.sys.windows.winbase : SwitchToThread;

        SwitchToThread();
    } else version (Posix) {
        import core.sys.posix.sched : sched_yield;

        sched_yield();
    }
}
