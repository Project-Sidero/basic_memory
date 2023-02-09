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

    version (Windows) {
        FILETIME fileTime;
        GetSystemTimePreciseAsFileTime(&fileTime);

        SYSTEMTIME systemTime;
        auto got = FileTimeToSystemTime(&fileTime, &systemTime);

        if (got) {
            // welp that was easy...
            ret = typeof(return)(GregorianDate(systemTime.wYear, cast(ubyte)systemTime.wMonth,
                    cast(ubyte)systemTime.wDay), TimeOfDay(cast(ubyte)systemTime.wHour, cast(ubyte)systemTime.wMinute,
                    cast(ubyte)systemTime.wSecond, systemTime.wMilliseconds * 1000), fixedUTC0);
            // this is UTC+0
            needTimeZoneAdjustment = true;
        }
    } else version (Posix) {
        import core.sys.posix.time;

        timespec ts;

        if (clock_gettime(CLOCK_REALTIME, &ts) == 0) {
            ret.advanceNanoSeconds(ts.tv_nsec);
            ret = ret.asTimeZone(fixedUTC0);
            // this is UTC+0
            needTimeZoneAdjustment = true;
        }
    }

    if (!needTimeZoneAdjustment) {
        // if all we can do is get seconds from the libc, then I guess thats all we can do.

        time_t t = time(null);
        tm* utcT = gmtime(&t);

        if (utcT !is null) {
            // this is UTC+0
            ret = typeof(return )(GregorianDate(utcT.tm_year + 1900, cast(ubyte)utcT.tm_mon, cast(ubyte)utcT.tm_mday),
            TimeOfDay(cast(ubyte)utcT.tm_hour, cast(ubyte)utcT.tm_min, cast(ubyte)utcT.tm_sec), fixedUTC0);
            needTimeZoneAdjustment = true;
        }
    }

    if (needTimeZoneAdjustment) {
        auto timeZone = TimeZone.local;

        if (timeZone) {
            assert(!timeZone.state.allocator.isNull);
            ret = ret.asTimeZone(timeZone.get);
        }
    }

    return ret;
}

version (Windows) {
    import core.sys.windows.winbase : FILETIME, SYSTEMTIME, FileTimeToSystemTime;

    extern (Windows) void GetSystemTimePreciseAsFileTime(FILETIME*) @safe nothrow @nogc;
}
