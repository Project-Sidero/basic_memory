module sidero.base.synchronization.system.point;
import sidero.base.datetime.duration;
import sidero.base.errors;
import sidero.base.attributes;

/**
    A point in time that will be synchronized between threads
    Examples:
    ------------------------------
    SynchronizationPoint sp;

    // thread 1
    sp.lock.assumeOkay;
    sp.waitForCondition.assumeOkay;
    // stuff here
    sp.unlock;

    // thread 2
    sp.triggerCondition;
    ------------------------------
*/
struct SynchronizationPoint {
    private @PrettyPrintIgnore {
        import sidero.base.synchronization.system.internal.bindings;
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

        TestTestSetLockInline protectMutex;
        bool initialized;

        version(Windows) {
            import core.sys.windows.winbase : CRITICAL_SECTION, InitializeCriticalSection, DeleteCriticalSection,
                EnterCriticalSection, TryEnterCriticalSection, LeaveCriticalSection, INFINITE, GetLastError;
            import core.sys.windows.windef : DWORD, ERROR_TIMEOUT;

            CRITICAL_SECTION criticalSection;
            CONDITION_VARIABLE conditionVariable;

            void setup() scope @trusted nothrow @nogc {
                protectMutex.pureLock;

                if(!initialized) {
                    InitializeCriticalSection(&criticalSection);
                    InitializeConditionVariable(conditionVariable);
                    initialized = true;
                }

                protectMutex.unlock;
            }
        } else version(Posix) {
            import core.sys.posix.pthread : pthread_mutex_t, pthread_mutex_init, pthread_mutex_destroy,
                pthread_mutex_lock, pthread_mutex_unlock, pthread_mutex_trylock,
                pthread_mutexattr_t, pthread_mutexattr_settype, PTHREAD_MUTEX_RECURSIVE, pthread_mutexattr_init,
                pthread_mutexattr_destroy, pthread_cond_init, pthread_cond_t, pthread_cond_destroy, pthread_cond_timedwait, pthread_cond_wait;
            import core.stdc.errno : EOWNERDEAD, EAGAIN, ENOTRECOVERABLE, EBUSY;

            pthread_mutex_t mutex;
            pthread_cond_t condition;

            void setupImpl() scope @trusted {
                protectMutex.pureLock;

                if(!initialized) {
                    {
                        pthread_mutexattr_t attr;
                        auto result = pthread_mutexattr_init(&attr);
                        assert(result == 0);

                        pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
                        pthread_mutexattr_setrobust(&attr, PTHREAD_MUTEX_ROBUST);

                        pthread_mutex_init(&mutex, &attr);
                        pthread_mutexattr_destroy(&attr);
                    }

                    {
                        auto result = pthread_cond_init(&condition, null);
                        assert(result == 0);
                    }

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
    this(return scope SynchronizationPoint other) scope @trusted {
        this.tupleof = other.tupleof;
        other.tupleof = SynchronizationPoint.init.tupleof;
    }

    ///
    ~this() scope @trusted {
        if(initialized) {
            version(Windows) {
                DeleteCriticalSection(&criticalSection);
            } else version(Posix) {
                pthread_cond_destroy(&condition);
                pthread_mutex_destroy(&mutex);
            } else
                static assert(0, "Unimplemented platform");
        }
    }

    ///
    bool isNull() scope {
        protectMutex.pureLock;
        const ret = this.initialized;

        protectMutex.unlock;
        return ret;
    }

    ///
    void opAssign(return scope SynchronizationPoint other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    ErrorResult lock() scope @trusted {
        setup;

        version(Windows) {
            EnterCriticalSection(&criticalSection);
            return typeof(return).init;
        } else version(Posix) {
            import core.stdc.errno : EINVAL, EAGAIN;

            int result = pthread_mutex_lock(&mutex);

            switch(result) {
            case 0:
                return ErrorResult.init;

            case EOWNERDEAD:
                pthread_mutex_consistent(&mutex);
                return ErrorResult.init;

            case EINVAL:
                return ErrorResult(MalformedInputException("Timeout duration out of range"));

            case EAGAIN, ENOTRECOVERABLE:
                goto default;

            default:
                return ErrorResult(UnknownPlatformBehaviorException("Could not lock mutex"));
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    Result!bool tryLock() scope @trusted {
        setup;

        version(Windows) {
            if(TryEnterCriticalSection(&criticalSection) != 0)
                return typeof(return)(true);
            else
                return typeof(return)(UnknownPlatformBehaviorException("Could not lock mutex"));
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

            case EAGAIN, ENOTRECOVERABLE:
                goto default;

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
            LeaveCriticalSection(&criticalSection);
        } else version(Posix) {
            pthread_mutex_unlock(&mutex);
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    ErrorResult waitForCondition(Duration timeout = Duration.max) scope @trusted {
        version(Windows) {
            if(SleepConditionVariableCS(conditionVariable, criticalSection, timeout < Duration.max ?
                    cast(uint)timeout.totalMilliSeconds() : INFINITE) != 0)
                return typeof(return).init;

            switch(GetLastError()) {
            case ERROR_TIMEOUT:
                return ErrorResult(MalformedInputException("Timeout duration out of range"));

            default:
                return ErrorResult(UnknownPlatformBehaviorException("Condition did not occur"));
            }
        } else version(Posix) {
            import core.sys.posix.time : clock_gettime, CLOCK_REALTIME, timespec;
            import core.stdc.errno : EINVAL, ETIMEDOUT, EAGAIN;

            int result;

            if(timeout < Duration.max) {
                long secs = timeout.totalSeconds();
                long nsecs = (timeout - secs.seconds()).totalNanoSeconds();

                timespec ts;
                if(clock_gettime(CLOCK_REALTIME, &ts) != 0)
                    return ErrorResult(UnknownPlatformBehaviorException("Could not get time to compute timeout for thread join"));

                ts.tv_sec += secs;
                ts.tv_nsec += nsecs;

                result = pthread_cond_timedwait(&condition, &mutex, &ts);
            } else {
                result = pthread_cond_wait(&condition, &mutex);
            }

            switch(result) {
                case 0:
                    return ErrorResult.init;

                case EINVAL:
                    return ErrorResult(MalformedInputException("Timeout duration out of range"));

                case ETIMEDOUT:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock the mutex due to timeout"));

                default:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock mutex"));
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    /// Awake the threads waiting on this
    void triggerCondition() scope @trusted {
        setup;

        version(Windows) {
            WakeAllConditionVariable(conditionVariable);
        } else version(Posix) {
            int result = pthread_cond_broadcast(&condition);
            assert(result == 0);
        } else
            static assert(0, "Unimplemented platform");
    }
}
