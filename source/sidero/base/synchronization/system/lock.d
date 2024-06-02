module sidero.base.synchronization.system.lock;
import sidero.base.datetime.duration;
import sidero.base.errors;
import sidero.base.attributes;

/// Recursive mutex
struct SystemLock {
    private @PrettyPrintIgnore {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

        TestTestSetLockInline protectMutex;
        bool initialized;

        version(Windows) {
            import core.sys.windows.basetsd : HANDLE;
            import core.sys.windows.winerror : WAIT_TIMEOUT;
            import core.sys.windows.winbase : CreateMutex, CloseHandle, WaitForSingleObject, INFINITE, WAIT_OBJECT_0,
                WAIT_ABANDONED, WAIT_FAILED, ReleaseMutex;

            HANDLE mutex;

            void setup() scope @trusted nothrow @nogc {
                protectMutex.pureLock;

                if(!initialized) {
                    mutex = CreateMutex(null, false, null);
                    assert(mutex !is null);
                    initialized = true;
                }

                protectMutex.unlock;
            }
        } else version(Posix) {
            import core.sys.posix.pthread : pthread_mutex_t, pthread_mutex_init, pthread_mutex_destroy,
                pthread_mutex_lock, pthread_mutex_unlock, pthread_mutex_trylock,
                pthread_mutexattr_t, pthread_mutexattr_settype, PTHREAD_MUTEX_RECURSIVE, pthread_mutexattr_init,
                pthread_mutexattr_destroy;
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

            void setup() scope @trusted nothrow @nogc {
                (cast(void delegate()@safe nothrow @nogc)&this.setupImpl)();
            }
        } else
            static assert(0, "Unimplemented platform");
    }

export @safe nothrow @nogc:
    this(return scope SystemLock other) scope @trusted {
        this.tupleof = other.tupleof;
        other.tupleof = SystemLock.init.tupleof;
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
    void opAssign(return scope SystemLock other) scope {
        this.__ctor(other);
    }

    ///
    ErrorResult lock(Duration timeout = Duration.max) scope @trusted {
        if(timeout <= Duration.init)
            return ErrorResult(MalformedInputException("Timeout duration must be above zero"));

        setup;

        version(Windows) {
            if(timeout < Duration.max) {
                auto result = WaitForSingleObject(mutex, timeout < Duration.max ? cast(uint)timeout.totalMilliSeconds() : INFINITE);

                switch(result) {
                case WAIT_OBJECT_0:
                case WAIT_ABANDONED:
                    return ErrorResult.init;

                case WAIT_FAILED:
                default:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock mutex"));
                }
            } else {
                return waitForLock(mutex);
            }
        } else version(Posix) {
            import core.sys.posix.pthread : pthread_mutex_timedlock;
            import core.sys.posix.time : clock_gettime, CLOCK_REALTIME, timespec;
            import core.stdc.errno : EINVAL, ETIMEDOUT, EAGAIN;

            if(timeout < Duration.max) {
                int result;

                long secs = timeout.totalSeconds();
                long nsecs = (timeout - secs.seconds()).totalNanoSeconds();

                timespec ts;
                if(clock_gettime(CLOCK_REALTIME, &ts) != 0)
                    return ErrorResult(UnknownPlatformBehaviorException("Could not get time to compute timeout for thread join"));

                ts.tv_sec += secs;
                ts.tv_nsec += nsecs;

                result = pthread_mutex_timedlock(&mutex, &ts);

                switch(result) {
                case 0:
                    return ErrorResult.init;

                case EOWNERDEAD:
                    pthread_mutex_consistent(&mutex);
                    return ErrorResult.init;

                case EINVAL:
                    return ErrorResult(MalformedInputException("Timeout duration out of range"));

                case ETIMEDOUT:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock the mutex due to timeout"));

                case EAGAIN:
                case ENOTRECOVERABLE:
                default:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock mutex"));
                }
            } else {
                return waitForLock(&mutex);
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    Result!bool tryLock() scope @trusted {
        setup;

        version(Windows) {
            auto result = WaitForSingleObject(mutex, 0);

            switch(result) {
            case WAIT_OBJECT_0:
            case WAIT_ABANDONED:
                return typeof(return)(true);

            case WAIT_TIMEOUT:
                return typeof(return)(false);

            case WAIT_FAILED:
            default:
                return typeof(return)(UnknownPlatformBehaviorException("Could not lock mutex"));
            }
        } else version(Posix) {
            auto result = pthread_mutex_trylock(&mutex);

            switch(result) {
            case 0:
                return typeof(return)(true);

            case EOWNERDEAD:
                pthread_mutex_consistent(&mutex);
                return typeof(return)(true);

            case EBUSY:
                return typeof(return)(false);

            case EAGAIN:
            case ENOTRECOVERABLE:
            default:
                return typeof(return)(UnknownPlatformBehaviorException("Could not lock mutex"));
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

version(Posix) {
    import core.sys.posix.pthread : pthread_mutex_t, pthread_mutexattr_t;

    enum {
        PTHREAD_MUTEX_ROBUST = 1,
    }

    extern (C) nothrow @nogc {
        int pthread_mutexattr_setrobust(pthread_mutexattr_t* attr, int robustness);
        int pthread_mutex_consistent(pthread_mutex_t* mutex);
    }
}

ErrorResult waitForLock(scope void* handle) @trusted nothrow @nogc {
    version(Windows) {
        import core.sys.windows.windows : WaitForSingleObject, INFINITE, WAIT_OBJECT_0, WAIT_ABANDONED, WAIT_FAILED;

        auto result = WaitForSingleObject(handle, INFINITE);

        switch(result) {
        case WAIT_OBJECT_0:
        case WAIT_ABANDONED:
            return ErrorResult.init;

        case WAIT_FAILED:
        default:
            return ErrorResult(UnknownPlatformBehaviorException("Could not lock mutex"));
        }
    } else version(Posix) {
        import core.sys.posix.pthread : pthread_mutex_lock;
        import core.stdc.errno : EINVAL, ETIMEDOUT, EAGAIN, EOWNERDEAD, ENOTRECOVERABLE, EBUSY;

        int result = pthread_mutex_lock(cast(pthread_mutex_t*)handle);

        switch(result) {
        case 0:
            return ErrorResult.init;

        case EOWNERDEAD:
            pthread_mutex_consistent(cast(pthread_mutex_t*)handle);
            return ErrorResult.init;

        case EINVAL:
            return ErrorResult(MalformedInputException("Timeout duration out of range"));

        case ETIMEDOUT:
            return ErrorResult(UnknownPlatformBehaviorException("Could not lock the mutex due to timeout"));

        case EAGAIN:
        case ENOTRECOVERABLE:
        default:
            return ErrorResult(UnknownPlatformBehaviorException("Could not lock mutex"));
        }
    }
}
