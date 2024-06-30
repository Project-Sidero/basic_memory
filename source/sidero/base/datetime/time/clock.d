module sidero.base.datetime.time.clock;
import sidero.base.datetime.defs;
import sidero.base.datetime.calendars.gregorian;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.timezone;

export @safe nothrow @nogc:

/// Will try to get the most accurate date/time of a given platform possible.
DateTime!GregorianDate accurateDateTime() @trusted {
    import core.stdc.time;
    import core.stdc.config;

    bool needTimeZoneAdjustment;
    typeof(return) ret;
    TimeZone fixedUTC0 = TimeZone.from(0);

    version(Windows) {
        FILETIME fileTime;
        GetSystemTimePreciseAsFileTime(&fileTime);

        SYSTEMTIME systemTime;
        auto got = FileTimeToSystemTime(&fileTime, &systemTime);

        if(got) {
            // welp that was easy...
            ret = typeof(return)(GregorianDate(systemTime.wYear, cast(ubyte)systemTime.wMonth,
                    cast(ubyte)systemTime.wDay), TimeOfDay(cast(ubyte)systemTime.wHour, cast(ubyte)systemTime.wMinute,
                    cast(ubyte)systemTime.wSecond, systemTime.wMilliseconds * 1000), fixedUTC0);
            // this is UTC+0
            needTimeZoneAdjustment = true;
        }
    } else version(Posix) {
        timespec ts;
        const err = clock_gettime(CLOCK_REALTIME, &ts);

        if(err == 0) {
            ret = typeof(ret).fromUnixTime(ts.tv_sec, fixedUTC0);
            ret.advanceNanoSeconds(ts.tv_nsec);

            // this is UTC+0
            needTimeZoneAdjustment = true;
        }
    }

    if(!needTimeZoneAdjustment) {
        // if all we can do is get seconds from the libc, then I guess thats all we can do.

        time_t t = time(null);
        tm* utcT = gmtime(&t);

        if(utcT !is null) {
            // this is UTC+0
            ret = typeof(return)(GregorianDate(utcT.tm_year + 1900, cast(ubyte)utcT.tm_mon, cast(ubyte)utcT.tm_mday),
                    TimeOfDay(cast(ubyte)utcT.tm_hour, cast(ubyte)utcT.tm_min, cast(ubyte)utcT.tm_sec), fixedUTC0);
            needTimeZoneAdjustment = true;
        }
    }

    if(needTimeZoneAdjustment) {
        auto timeZone = TimeZone.local;

        if(timeZone) {
            assert(!timeZone.state.allocator.isNull);
            ret = ret.asTimeZone(timeZone.get);
        }
    }

    return ret;
}

/// Acquires a point in time, since an unknown epoch measured in nano seconds.
long accuratePointInTime() {
    version(Windows) {
        ULONGLONG ret;

        // Acquire as hnsec
        QueryInterruptTime(&ret);

        return ret * 100;
    } else version(Posix) {
        timespec ts;
        const err = clock_gettime(CLOCK_MONOTONIC, &ts);

        if(err == 0) {
            return (ts.tv_sec * 1000000000) + ts.tv_nsec;
        }
    }

    return 0;
}

/// Acquires the amount of user time this process has used in micro seconds.
long amountOfProcessUserTime() {
    version(Windows) {
        FILETIME userTime; // hnsecs over two uint's
        FILETIME dummy1, dummy2, dummy3;

        if(GetProcessTimes(GetCurrentProcess(), &dummy1, &dummy2, &dummy3, &userTime) != 0) {
            long ret = (cast(long)userTime.dwHighDateTime << 32) | userTime.dwLowDateTime;
            // 1000ns to 1 ms
            // time acquired is 100ns
            return ret / 10;
        }
    } else version(Posix) {
        import core.sys.posix.sys.resource;

        rusage ru;
        if (getrusage(RUSAGE_SELF, &ru) == 0)
        {
            long ret = (cast(long)ru.ru_utime.tv_sec * 1000000) + tv.usec;
            // micro seconds
            return ret;
        }
    }

    return 0;
}

/// Get the current year
long currentYear() @trusted {
    import core.stdc.time;

    time_t t = time(null);
    tm* utcT = gmtime(&t);
    assert(utcT !is null);

    return utcT.tm_year + 1900;
}

version(Windows) {
    import core.sys.windows.winbase : FILETIME, SYSTEMTIME, FileTimeToSystemTime;
    import core.sys.windows.winnt : ULONGLONG, HANDLE;

    extern (Windows) @safe nothrow @nogc {
        void GetSystemTimePreciseAsFileTime(FILETIME*);
        void QueryInterruptTime(scope ULONGLONG* lpInterruptTime);
        HANDLE GetCurrentProcess();
        bool GetProcessTimes(scope HANDLE, scope FILETIME*, scope FILETIME*, scope FILETIME*, scope FILETIME*);
    }
} else version(Posix) {
    import core.sys.posix.time;
}
