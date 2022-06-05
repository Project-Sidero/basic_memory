/*
Mutal exclusion, read write lock used for thread consistency when reading and writing are different memory patterns.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.parallelism.rwmutex;
import core.atomic : cas, atomicLoad, pause;

///
struct ReaderWriterLockInline {
    private {
        version(D_BetterC) {
        } else {
            import core.thread : Thread;
        }

        enum TopBit = (cast(size_t)1) << ((size_t.sizeof * 8) - 1);
        shared(size_t) state;
    }

@safe nothrow @nogc:

    version(D_BetterC) {
    } else {
        ///
        void writeLock() @trusted {
            scope (exit) {
                assert(atomicLoad(state) == TopBit + 1);
            }

            if (cas(&state, cast(size_t)0, TopBit + 1))
                return ;

            size_t temp = atomicLoad(state);
            if (temp >= TopBit) {
                if (cas(&state, TopBit, TopBit + 1))
                    return ;
            } else
                cas(&state, temp, temp | TopBit);

            pause();

            for (;;) {
                if (cas(&state, cast(size_t)0, TopBit + 1))
                    return ;

                temp = atomicLoad(state);
                if (temp >= TopBit) {
                    if (cas(&state, TopBit, TopBit + 1))
                        return ;
                } else
                    cas(&state, temp, temp | TopBit);

                Thread.yield;
            }
        }

        ///
        void readLock() @trusted {
            size_t temp = atomicLoad(state);

            if (temp < TopBit && cas(&state, temp, temp + 1))
                return ;

            pause();

            for (;;) {
                temp = atomicLoad(state);

                if (temp < TopBit && cas(&state, temp, temp + 1))
                    return ;

                Thread.yield;
            }

            assert(0);
        }

        ///
        void readUnlock() @trusted {
            size_t temp = atomicLoad(state);
            if (temp < TopBit) {
                if (cas(&state, temp, temp - 1))
                    return ;
            } else
                assert(0);

            pause();

            for (;;) {
                temp = atomicLoad(state);
                if (temp < TopBit) {
                    if (cas(&state, temp, temp - 1))
                        return ;
                } else
                    assert(0);

                Thread.yield;
            }
        }

        ///
        void convertReadToWrite() @trusted {
            if (cas(&state, cast(size_t)1, TopBit + 1))
                return ;

            size_t temp = atomicLoad(state);
            if (temp >= TopBit) {
                if (temp == TopBit + 1)
                    return ;
            } else
                cas(&state, temp, temp | TopBit);

            pause();

            for (;;) {
                if (cas(&state, cast(size_t)1, TopBit + 1))
                    return ;

                temp = atomicLoad(state);
                if (temp >= TopBit) {
                    if (temp == TopBit + 1)
                        return ;
                } else
                    cas(&state, temp, temp | TopBit);

                Thread.yield;
            }
        }
    }

pure:

    /// A limited lock method, that is pure.
    void pureWriteLock() {
        scope (exit) {
            assert(atomicLoad(state) == TopBit + 1);
        }

        if (cas(&state, cast(size_t)0, TopBit + 1))
            return;

        size_t temp = atomicLoad(state);
        if (temp >= TopBit) {
            if (cas(&state, TopBit, TopBit + 1))
                return;
        } else
            cas(&state, temp, temp | TopBit);

        pause();

        for (;;) {
            if (cas(&state, cast(size_t)0, TopBit + 1))
                return;

            temp = atomicLoad(state);
            if (temp >= TopBit) {
                if (cas(&state, TopBit, TopBit + 1))
                    return;
            } else
                cas(&state, temp, temp | TopBit);

            pause();
        }
    }

    /// A limited lock method, that is pure.
    void pureReadLock() @trusted {
        size_t temp = atomicLoad(state);

        if (temp < TopBit && cas(&state, temp, temp + 1))
            return;

        pause();

        for (;;) {
            temp = atomicLoad(state);

            if (temp < TopBit && cas(&state, temp, temp + 1))
                return;

            pause();
        }

        assert(0);
    }

    /// A limited unlock method, that is pure.
    void pureReadUnlock() @trusted {
        size_t temp = atomicLoad(state);
        if (temp < TopBit) {
            if (cas(&state, temp, temp - 1))
                return;
        } else
            assert(0);

        pause();

        for (;;) {
            temp = atomicLoad(state);
            if (temp < TopBit) {
                if (cas(&state, temp, temp - 1))
                    return;
            } else
                assert(0);

            pause();
        }
    }

    /// A limited conversion method, that is pure.
    void pureConvertReadToWrite() @trusted {
        if (cas(&state, cast(size_t)1, TopBit + 1))
            return;

        size_t temp = atomicLoad(state);
        if (temp >= TopBit) {
            if (temp == TopBit + 1)
                return;
        } else
            cas(&state, temp, temp | TopBit);

        pause();

        for (;;) {
            if (cas(&state, cast(size_t)1, TopBit + 1))
                return;

            temp = atomicLoad(state);
            if (temp >= TopBit) {
                if (temp == TopBit + 1)
                    return;
            } else
                cas(&state, temp, temp | TopBit);

            pause();
        }
    }

    ///
    bool tryWriteLock() {
        return cas(&state, cast(size_t)0, TopBit + 1);
    }

    ///
    void writeUnlock() {
        if (!cas(&state, TopBit + 1, cast(size_t)0))
            assert(0);
    }

    ///
    bool tryReadLock() {
        size_t temp = atomicLoad(state);
        return temp < TopBit && cas(&state, temp, temp + 1);
    }
}
