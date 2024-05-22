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

        TestTestSetLockInline globalLock;
        shared(ptrdiff_t) readers;
    }

export @safe nothrow @nogc:

    ///
    void writeLock() scope {
        globalLock.lock;
    }

    ///
    void readLock() scope {
        if (atomicIncrementAndLoad(readers, 1) == 1)
            globalLock.lock;
    }

    ///
    void readUnlock() scope {
        if (atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
    }

    ///
    void convertReadToWrite() scope @trusted {
        if (atomicDecrementAndLoad(readers, 1) > 0)
            globalLock.lock;
    }

pure:

    /// A limited lock method, that is pure.
    void pureWriteLock() scope {
        globalLock.pureLock;
    }

    /// A limited lock method, that is pure.
    void pureReadLock() scope @trusted {
        if (atomicIncrementAndLoad(readers, 1) == 1)
            globalLock.pureLock;
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
        if (atomicDecrementAndLoad(readers, 1) > 0)
            globalLock.pureLock;
    }
}
