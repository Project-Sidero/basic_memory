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

        TestTestSetLockInline readerLock, globalLock;
        shared(ptrdiff_t) readers;
    }

export @safe nothrow @nogc:

    ///
    void writeLock() scope {
        globalLock.lock;
    }

    ///
    void readLock() scope {
        readerLock.lock;
        if(atomicIncrementAndLoad(readers, 1) == 1)
            globalLock.lock;
        readerLock.unlock;
    }

    ///
    void readUnlock() scope {
        readerLock.lock;
        if(atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
        readerLock.unlock;
    }

    ///
    void pureConvertReadToWrite() scope @trusted {
        readerLock.lock;
        if(atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
        readerLock.unlock;
        globalLock.lock;
    }

pure:

    /// A limited lock method, that is pure.
    void pureWriteLock() scope {
        globalLock.pureLock;
    }

    /// A limited lock method, that is pure.
    void pureReadLock() scope @trusted {
        readerLock.pureLock;
        if(atomicIncrementAndLoad(readers, 1) == 1)
            globalLock.pureLock;
        readerLock.unlock;
    }

    /// A limited unlock method, that is pure.
    void pureWriteUnlock() scope {
        globalLock.unlock;
    }

    /// A limited unlock method, that is pure.
    void pureReadUnlock() scope @trusted {
        readerLock.pureLock;
        if(atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
        readerLock.unlock;
    }

    /// A limited conversion method, that is pure.
    void pureConvertReadToWrite() scope @trusted {
        readerLock.pureLock;
        if(atomicDecrementAndLoad(readers, 1) == 0)
            globalLock.unlock;
        readerLock.unlock;
        globalLock.pureLock;
    }

    ///
    bool tryWriteLock() scope {
        return globalLock.tryLock();
    }

    ///
    bool tryReadLock() scope {
        if(!readerLock.tryLock)
            return false;

        if(atomicIncrementAndLoad(readers, 1) == 1) {
            if(!globalLock.tryLock) {
                atomicDecrementAndLoad(readers, 1);
                readerLock.unlock;
            }
        }

        readerLock.unlock;
        return true;
    }
}
