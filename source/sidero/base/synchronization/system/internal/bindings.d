module sidero.base.synchronization.system.internal.bindings;

version(Posix) {
    import core.sys.posix.pthread : pthread_mutex_t, pthread_mutexattr_t;

    enum {
        PTHREAD_MUTEX_ROBUST = 1,
    }

    extern (C) nothrow @nogc {
        int pthread_mutexattr_setrobust(pthread_mutexattr_t* attr, int robustness);
        int pthread_mutex_consistent(pthread_mutex_t* mutex);
    }
} else version(Windows) {
    import core.sys.windows.winbase : CRITICAL_SECTION;
    import core.sys.windows.windef : DWORD;

    struct CONDITION_VARIABLE {
        void* _;
    }

    extern (Windows) nothrow @nogc {
        void InitializeConditionVariable(ref CONDITION_VARIABLE);
        bool SleepConditionVariableCS(ref CONDITION_VARIABLE, ref CRITICAL_SECTION, DWORD dwMilliseconds);
        void WakeAllConditionVariable(ref CONDITION_VARIABLE);
    }
}
