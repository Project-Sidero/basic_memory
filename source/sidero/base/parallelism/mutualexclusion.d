/*
Mutal exclusion, locks for thread consistency.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.parallelism.mutualexclusion;

version(D_BetterC) {
} else {
    import core.thread : Thread;
}

///
struct TestTestSetLockInline {
    private shared(bool) state;

    @disable this(this);

@safe @nogc nothrow:

    version(D_BetterC) {
    } else {
        ///
        void lock() @trusted {
            import core.atomic : cas, pause, atomicLoad;

            for (;;) {
                if (atomicLoad(state)) {
                    pause();

                    while (atomicLoad(state)) {
                        Thread.yield;
                    }
                }

                if (cas(&state, false, true))
                    return ;
            }
        }
    }

pure:

    /// A much more limited lock method, that is pure.
    void pureLock() {
        import core.atomic : cas, pause, atomicLoad;

        for (;;) {
            if (atomicLoad(state))
                pause();

            if (cas(&state, false, true))
                return;
        }
    }

    ///
    bool tryLock() {
        import core.atomic : cas;

        return cas(&state, false, true);
    }

    ///
    void unlock() {
        import core.atomic : atomicStore;

        atomicStore(state, false);
    }
}
