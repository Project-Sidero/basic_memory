/*
Mutal exclusion, read write lock used for thread consistency when reading and writing are different memory patterns.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.synchronization.rwmutex;
import sidero.base.attributes;
import sidero.base.internal.atomic;

export:

///
struct ReaderWriterLockInline {
    private @PrettyPrintIgnore {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

        TestTestSetLockInline readersLock, globalLock;
        shared(ptrdiff_t) readers;
    }

export @safe nothrow @nogc:

    ///
    void writeLock() scope {
        globalLock.lock;
    }

    ///
    void readLock() scope {
        readersLock.lock;
        if (atomicIncrementAndLoad(readers, 1) == 1)
            globalLock.lock;
        readersLock.unlock;
    }

    ///
    void readUnlock() scope {
        if (atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
    }

    ///
    void convertReadToWrite() scope @trusted {
        readersLock.lock;
        if (atomicDecrementAndLoad(readers, 1) > 0)
            globalLock.lock;
        readersLock.unlock;
    }

pure:

    /// A limited lock method, that is pure.
    void pureWriteLock() scope {
        globalLock.pureLock;
    }

    /// A limited lock method, that is pure.
    void pureReadLock() scope @trusted {
        readersLock.pureLock;
        if (atomicIncrementAndLoad(readers, 1) == 1)
            globalLock.pureLock;
        readersLock.unlock;
    }

    /// A limited unlock method, that is pure.
    void pureWriteUnlock() scope {
        globalLock.unlock;
    }

    /// A limited unlock method, that is pure.
    void pureReadUnlock() scope @trusted {
        if (atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
    }

    /// A limited conversion method, that is pure.
    void pureConvertReadToWrite() scope @trusted {
        readersLock.pureLock;
        if (atomicDecrementAndLoad(readers, 1) > 0)
            globalLock.pureLock;
        readersLock.unlock;
    }
}
