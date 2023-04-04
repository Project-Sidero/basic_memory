/*
Mutal exclusion, read write lock used for thread consistency when reading and writing are different memory patterns.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.synchronization.rwmutex;
import sidero.base.attributes;

export:

///
struct ReaderWriterLockInline {
    private @PrettyPrintIgnore {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;
        import core.atomic : atomicOp;

        TestTestSetLockInline readerLock, globalLock;
        shared(ptrdiff_t) readers;
    }

export @safe nothrow @nogc:

pure:

    /// A limited lock method, that is pure.
    void pureWriteLock() {
        globalLock.pureLock;
    }

    /// A limited lock method, that is pure.
    void pureReadLock() @trusted {
        readerLock.pureLock;
        if (atomicOp!"+="(readers, 1) == 1)
            globalLock.pureLock;
        readerLock.unlock;
    }

    /// A limited unlock method, that is pure.
    void pureReadUnlock() @trusted {
        readerLock.pureLock;
        if (atomicOp!"-="(readers, 1) == 0)
            globalLock.unlock;
        readerLock.unlock;
    }

    ///
    void pureWriteUnlock() {
        globalLock.unlock;
    }

    /// A limited conversion method, that is pure.
    void pureConvertReadToWrite() @trusted {
        readerLock.pureLock;
        if (atomicOp!"-="(readers, 1) == 0)
            globalLock.unlock;
        readerLock.unlock;
        globalLock.pureLock;
    }

    ///
    bool tryWriteLock() {
        return globalLock.tryLock();
    }

    ///
    bool tryReadLock() {
        if (!readerLock.tryLock)
            return false;

        if (atomicOp!"+="(readers, 1) == 1) {
            if (!globalLock.tryLock) {
                atomicOp!"-="(readers, 1);
                readerLock.unlock;
            }
        }

        readerLock.unlock;
        return true;
    }
}
