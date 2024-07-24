/*
Mutal exclusion, locks for thread consistency.

https://en.wikipedia.org/wiki/Eisenberg_%26_McGuire_algorithm
https://en.wikipedia.org/wiki/Szyma%C5%84ski%27s_algorithm

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.synchronization.mutualexclusion;
import sidero.base.attributes;
import sidero.base.internal.atomic;
import sidero.base.internal.thread : threadYield;

export:

///
struct TestSetLockInline {
    private @PrettyPrintIgnore shared(bool) state;

    export @safe nothrow @nogc:

    /// Non-pure will yield the thread lock
    void lock() scope {
        while(!cas(state, false, true)) {
            threadYield;
        }
    }

    pure:

    /// A much more limited lock method, that is pure.
    void pureLock() scope {
        if(cas(state, false, true))
            return;
        else
            atomicFence();

        while(!cas(state, false, true)) {
            atomicFence();
        }
    }

    ///
    bool tryLock() scope {
        return cas(state, false, true);
    }

    ///
    void unlock() scope {
        atomicStore(state, false);
    }
}

///
struct TestTestSetLockInline {
    private @PrettyPrintIgnore shared(bool) state;

export @safe @nogc nothrow:

    /// Non-pure will yield the thread lock
    void lock() scope {
        for(;;) {
            while(atomicLoad(state)) {
                threadYield;
            }

            if(cas(state, false, true))
                return;
        }
    }

pure:

    /// A much more limited lock method, that is pure.
    void pureLock() scope {
        for(;;) {
            if(atomicLoad(state))
                atomicFence();

            if(cas(state, false, true))
                return;
        }
    }

    ///
    bool tryLock() scope {
        return cas(state, false, true);
    }

    ///
    void unlock() scope {
        atomicStore(state, false);
    }
}
