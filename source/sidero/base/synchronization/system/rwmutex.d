/*
Mutal exclusion, read write lock used for thread consistency when reading and writing are different memory patterns.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2024 Richard Andrew Cattermole
*/
module sidero.base.synchronization.system.rwmutex;
import sidero.base.attributes;
import sidero.base.internal.atomic;
import sidero.base.internal.logassert;

export:

///
struct SystemReaderWriterLock {
    private @PrettyPrintIgnore {
        import sidero.base.internal.puresystemlock;

        PureSystemLock readersLock, globalLock;
        shared(ptrdiff_t) readers;
    }

export @safe nothrow @nogc:

    ///
    void writeLock() scope {
        logAssert(globalLock.lock, "Failed to lock");
    }

    ///
    void readLock() scope {
        logAssert(readersLock.lock, "Failed to lock");
        if (atomicIncrementAndLoad(readers, 1) == 1)
            logAssert(globalLock.lock, "Failed to lock");
        readersLock.unlock;
    }

    ///
    void readUnlock() scope {
        if (atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
    }

    ///
    void convertReadToWrite() scope @trusted {
        logAssert(readersLock.lock, "Failed to lock");
        if (atomicDecrementAndLoad(readers, 1) > 0)
            logAssert(globalLock.lock, "Failed to lock");
        readersLock.unlock;
    }

pure:

    /// A limited lock method, that is pure.
    void pureWriteLock() scope {
        logAssert(globalLock.lock, "Failed to lock");
    }

    /// A limited lock method, that is pure.
    void pureReadLock() scope @trusted {
        logAssert(readersLock.lock, "Failed to lock");
        if (atomicIncrementAndLoad(readers, 1) == 1)
            logAssert(globalLock.lock, "Failed to lock");
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
        logAssert(readersLock.lock, "Failed to lock");
        if (atomicDecrementAndLoad(readers, 1) > 0)
            logAssert(globalLock.lock, "Failed to lock");
        readersLock.unlock;
    }
}
