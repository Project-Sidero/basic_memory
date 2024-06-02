module sidero.base.internal.puresystemlock;
import sidero.base.datetime.duration;
import sidero.base.attributes;

// Recursive mutex
struct PureSystemLock {
    private @PrettyPrintIgnore {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

        TestTestSetLockInline protectMutex;
        bool initialized;

        version(Windows) {
            import core.sys.windows.winbase : CreateMutex, INFINITE, WAIT_OBJECT_0, WAIT_ABANDONED, WAIT_FAILED;
            import core.sys.windows.winerror : WAIT_TIMEOUT;

            HANDLE mutex;

            void setupImpl() scope @trusted nothrow @nogc {
                protectMutex.pureLock;

                if(!initialized) {
                    mutex = CreateMutex(null, false, null);
                    assert(mutex !is null);
                    initialized = true;
                }

                protectMutex.unlock;
            }
        } else version(Posix) {
            import core.sys.posix.pthread : pthread_mutex_t, pthread_mutex_init, pthread_mutexattr_t,
                pthread_mutexattr_settype, PTHREAD_MUTEX_RECURSIVE, pthread_mutexattr_init, pthread_mutexattr_destroy;
            import core.stdc.errno : EOWNERDEAD, EAGAIN, ENOTRECOVERABLE, EBUSY;

            pthread_mutex_t mutex;

            void setupImpl() scope @trusted {
                protectMutex.pureLock;

                if(!initialized) {
                    pthread_mutexattr_t attr;
                    auto result = pthread_mutexattr_init(&attr);
                    assert(result == 0);

                    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
                    pthread_mutexattr_setrobust(&attr, PTHREAD_MUTEX_ROBUST);

                    pthread_mutex_init(&mutex, &attr);
                    pthread_mutexattr_destroy(&attr);
                    initialized = true;
                }

                protectMutex.unlock;
            }
        } else
            static assert(0, "Unimplemented platform");

        void setup() scope @trusted nothrow @nogc pure {
            (cast(void delegate()@safe nothrow @nogc pure)&this.setupImpl)();
        }
    }

export @safe nothrow @nogc pure:
    this(return scope PureSystemLock other) scope @trusted {
        this.tupleof = other.tupleof;
        other.tupleof = PureSystemLock.init.tupleof;
    }

    ///
    ~this() scope @trusted {
        if(initialized) {
            version(Windows) {
                CloseHandle(mutex);
            } else version(Posix) {
                pthread_mutex_destroy(&mutex);
            } else
                static assert(0, "Unimplemented platform");
        }
    }

    ///
    void opAssign(return scope PureSystemLock other) scope {
        this.__ctor(other);
    }

    ///
    bool lock(Duration timeout = Duration.max) scope @trusted {
        if(timeout <= Duration.init)
            return false;

        setup;

        version(Windows) {
            if(timeout < Duration.max) {
                auto result = WaitForSingleObject(mutex, timeout < Duration.max ? cast(uint)timeout.totalMilliSeconds() : INFINITE);

                switch(result) {
                case WAIT_OBJECT_0:
                case WAIT_ABANDONED:
                    return true;

                case WAIT_FAILED:
                default:
                    return false;
                }
            } else {
                return waitForLock(mutex);
            }
        } else version(Posix) {
            import core.sys.posix.time : CLOCK_REALTIME;
            import core.stdc.errno : EINVAL, ETIMEDOUT, EAGAIN;

            if(timeout < Duration.max) {
                int result;

                long secs = timeout.totalSeconds();
                long nsecs = (timeout - secs.seconds()).totalNanoSeconds();

                timespec ts;
                if(clock_gettime(CLOCK_REALTIME, &ts) != 0)
                    return false;

                ts.tv_sec += secs;
                ts.tv_nsec += nsecs;

                result = pthread_mutex_timedlock(&mutex, &ts);

                switch(result) {
                case 0:
                    return true;

                case EOWNERDEAD:
                    pthread_mutex_consistent(&mutex);
                    return false;

                case EINVAL:
                case ETIMEDOUT:
                case EAGAIN:
                case ENOTRECOVERABLE:
                default:
                    return false;
                }
            } else {
                return waitForLock(&mutex);
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    bool tryLock() scope @trusted {
        setup;

        version(Windows) {
            auto result = WaitForSingleObject(mutex, 0);

            switch(result) {
            case WAIT_OBJECT_0:
            case WAIT_ABANDONED:
                return true;

            case WAIT_TIMEOUT:
                return false;

            case WAIT_FAILED:
            default:
                return false;
            }
        } else version(Posix) {
            auto result = pthread_mutex_trylock(&mutex);

            switch(result) {
            case 0:
                return true;

            case EOWNERDEAD:
                pthread_mutex_consistent(&mutex);
                return true;

            case EBUSY:
                return false;

            case EAGAIN:
            case ENOTRECOVERABLE:
            default:
                return false;
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    void unlock() scope @trusted {
        setup;

        version(Windows) {
            ReleaseMutex(mutex);
        } else version(Posix) {
            pthread_mutex_unlock(&mutex);
        } else
            static assert(0, "Unimplemented platform");
    }
}

private:

version(Windows) {
    import core.sys.windows.basetsd : HANDLE;
    import core.sys.windows.windef : DWORD, BOOL;

    extern (Windows) nothrow @nogc pure {
        BOOL CloseHandle(HANDLE);
        DWORD WaitForSingleObject(HANDLE, DWORD);
        BOOL ReleaseMutex(HANDLE);
    }
} else version(Posix) {
    import core.sys.posix.pthread : pthread_mutex_t, pthread_mutexattr_t;
    import core.sys.posix.time : clockid_t, timespec;

    enum {
        PTHREAD_MUTEX_ROBUST = 1,
    }

    extern (C) nothrow @nogc pure {
        int pthread_mutexattr_setrobust(pthread_mutexattr_t* attr, int robustness);
        int pthread_mutex_consistent(pthread_mutex_t* mutex);
        int pthread_mutex_destroy(pthread_mutex_t*);
        int pthread_mutex_timedlock(pthread_mutex_t*, const scope timespec*);
        int pthread_mutex_trylock(pthread_mutex_t*);
        int pthread_mutex_unlock(pthread_mutex_t*);
        int pthread_mutex_lock(pthread_mutex_t*);
        int clock_gettime(clockid_t, timespec*);
    }
}

bool waitForLock(scope void* handle) @trusted nothrow @nogc pure {
    version(Windows) {
        import core.sys.windows.winbase : INFINITE, WAIT_OBJECT_0, WAIT_ABANDONED, WAIT_FAILED;

        auto result = WaitForSingleObject(handle, INFINITE);

        switch(result) {
        case WAIT_OBJECT_0:
        case WAIT_ABANDONED:
            return true;

        case WAIT_FAILED:
        default:
            return false;
        }
    } else version(Posix) {
        import core.stdc.errno : EINVAL, ETIMEDOUT, EAGAIN, EOWNERDEAD, ENOTRECOVERABLE, EBUSY;

        int result = pthread_mutex_lock(cast(pthread_mutex_t*)handle);

        switch(result) {
        case 0:
            return true;

        case EOWNERDEAD:
            pthread_mutex_consistent(cast(pthread_mutex_t*)handle);
            return true;

        case EINVAL:
        case ETIMEDOUT:
        case EAGAIN:
        case ENOTRECOVERABLE:
        default:
            return false;
        }
    }
}
