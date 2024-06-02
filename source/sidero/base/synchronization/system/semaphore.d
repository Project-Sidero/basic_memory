module sidero.base.synchronization.system.semaphore;
import sidero.base.datetime.duration;
import sidero.base.errors;
import sidero.base.attributes;

/// A system backed semaphore, must be initialized.
struct SystemSemaphore {
    private @PrettyPrintIgnore {
        import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

        bool initialized;

        version(Windows) {
            import core.sys.windows.winerror : WAIT_TIMEOUT;
            import core.sys.windows.basetsd : HANDLE;
            import core.sys.windows.winbase : ReleaseSemaphore, WaitForSingleObject, CreateSemaphoreA, CloseHandle,
                WAIT_OBJECT_0, WAIT_ABANDONED, WAIT_FAILED, INFINITE;

            HANDLE semaphore;
        } else version(Posix) {
            import core.sys.posix.semaphore : sem_init, sem_destroy, sem_wait, sem_post, sem_t, sem_trywait, sem_timedwait;

            sem_t semaphore;
        } else
            static assert(0, "Unimplemented platform");
    }

    @disable this(this);

export @safe nothrow @nogc:

    /// Maximum value does not apply to POSIX.
    this(uint initialValue, uint maximumValue = uint.max) scope @trusted {
        version(Windows) {
            semaphore = CreateSemaphoreA(null, initialValue, maximumValue, null);
            if(semaphore is null)
                return;
        } else version(Posix) {
            int got = sem_init(&semaphore, 0, initialValue);
            if(got != 0)
                return;
        } else
            static assert(0, "Unimplemented platform");

        initialized = true;
    }

    ///
    ~this() scope @trusted {
        if(initialized) {
            version(Windows) {
                CloseHandle(semaphore);
            } else version(Posix) {
                sem_destroy(&semaphore);
            } else
                static assert(0, "Unimplemented platform");
        }
    }

    ///
    bool isNull() scope const {
        return initialized;
    }

    ///
    ErrorResult lock(Duration timeout = Duration.max) scope @trusted {
        if(!initialized)
            return ErrorResult(NullPointerException);
        else if(timeout <= Duration.init)
            return ErrorResult(MalformedInputException("Timeout duration must be above zero"));

        version(Windows) {
            if(timeout < Duration.max) {
                auto result = WaitForSingleObject(semaphore, cast(uint)timeout.totalMilliSeconds());

                switch(result) {
                case WAIT_OBJECT_0:
                case WAIT_ABANDONED:
                    return ErrorResult.init;

                case WAIT_FAILED:
                default:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock semaphore"));
                }
            } else {
                return waitForLock(semaphore);
            }
        } else version(Posix) {
            import core.sys.posix.time : timespec, clock_gettime, CLOCK_REALTIME;
            import core.stdc.errno : EINVAL, ETIMEDOUT, EAGAIN, EINTR;

            if(timeout < Duration.max) {
                int result;

                long secs = timeout.totalSeconds();
                long nsecs = (timeout - secs.seconds()).totalNanoSeconds();

                timespec ts;
                if(clock_gettime(CLOCK_REALTIME, &ts) != 0)
                    return ErrorResult(UnknownPlatformBehaviorException("Could not get time to compute timeout for thread join"));

                ts.tv_sec += secs;
                ts.tv_nsec += nsecs;

                result = sem_timedwait(&semaphore, &ts);

                switch(result) {
                case 0:
                    return ErrorResult.init;

                case EINVAL:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock the mutex due to timeout"));

                case ETIMEDOUT:
                    return ErrorResult(MalformedInputException("Timeout duration out of range"));

                case EAGAIN:
                case EINTR:
                default:
                    return ErrorResult(UnknownPlatformBehaviorException("Could not lock semaphore"));
                }
            } else {
                return waitForLock(&semaphore);
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    Result!bool tryLock() scope @trusted {
        if(!initialized)
            return typeof(return)(NullPointerException);

        version(Windows) {
            auto result = WaitForSingleObject(semaphore, 0);

            switch(result) {
            case WAIT_OBJECT_0:
            case WAIT_ABANDONED:
                return typeof(return)(true);

            case WAIT_TIMEOUT:
                return typeof(return)(false);

            case WAIT_FAILED:
            default:
                return typeof(return)(UnknownPlatformBehaviorException("Could not lock semaphore"));
            }
        } else version(Posix) {
            import core.stdc.errno : EINVAL, EAGAIN, EINTR;

            auto result = sem_trywait(&semaphore);

            switch(result) {
            case 0:
                return typeof(return)(true);

            case EAGAIN:
                return typeof(return)(false);

            case EINTR:
            case EINVAL:
            default:
                return typeof(return)(UnknownPlatformBehaviorException("Could not lock semaphore"));
            }
        } else
            static assert(0, "Unimplemented platform");
    }

    ///
    ErrorResult unlock() scope @trusted {
        if(!initialized)
            return ErrorResult(NullPointerException);

        version(Windows) {
            if(ReleaseSemaphore(semaphore, 1, null) == 0)
                return typeof(return)(UnknownPlatformBehaviorException("Could not unlock semaphore"));
        } else version(Posix) {
            if(sem_post(&semaphore) != 0)
                return typeof(return)(UnknownPlatformBehaviorException("Could not unlock semaphore"));
        } else
            static assert(0, "Unimplemented platform");

        return ErrorResult.init;
    }
}

private:

ErrorResult waitForLock(scope void* handle) @trusted nothrow @nogc {
    version(Windows) {
        import core.sys.windows.winbase : WaitForSingleObject, INFINITE, WAIT_OBJECT_0, WAIT_ABANDONED, WAIT_FAILED;

        auto result = WaitForSingleObject(handle, INFINITE);

        switch(result) {
        case WAIT_OBJECT_0:
        case WAIT_ABANDONED:
            return ErrorResult.init;

        case WAIT_FAILED:
        default:
            return ErrorResult(UnknownPlatformBehaviorException("Could not lock semaphore"));
        }
    } else version(Posix) {
        import core.sys.posix.semaphore : sem_wait, sem_t;
        import core.stdc.errno : EOWNERDEAD, ENOTRECOVERABLE, EBUSY, EINVAL, ETIMEDOUT, EAGAIN;

        int result = sem_wait(cast(sem_t*)handle);

        switch(result) {
        case 0:
            return ErrorResult.init;

        case EOWNERDEAD:
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
