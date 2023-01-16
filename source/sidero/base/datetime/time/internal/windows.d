module sidero.base.datetime.time.internal.windows;
import sidero.base.datetime.defs;
import sidero.base.datetime.calendars.gregorian;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.timezone;
import sidero.base.errors;
import sidero.base.attributes;
import sidero.base.text;

package(sidero.base.datetime) @safe nothrow @nogc:

void reloadWindowsTimeZones(bool forceReload = true) @trusted {
    version (Windows) {
        import sidero.base.datetime.cldr;
        import core.sys.windows.winreg;
        import core.stdc.wchar_ : wcslen;

        if (!forceReload) {
            DWORD version_, version_size = DWORD.sizeof;
            LONG got = RegGetValueA(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Time Zones",
                    "TzVersion", RRF_RT_REG_DWORD, null, &version_, &version_size);

            if (got == ERROR_SUCCESS) {
                // ok all good
                if (windowsTZVersion == version_)
                    return;
                windowsTZVersion = version_;
            } else {
                // didn't get the key we wanted, but thats ok
                // we only need to reload if forced to or if our map is empty
                if (windowsTimeZones.length > 0)
                    return;
            }
        }

        {
            windowsTimeZones.clear;

            DWORD dwResult, offset;
            WindowsTimeZoneBase temp;

            do {
                dwResult = EnumDynamicTimeZoneInformation(offset++, &temp.dtzi);

                if (dwResult == ERROR_SUCCESS) {
                    wchar[] name16Standard = temp.dtzi.StandardName[0 .. wcslen(temp.dtzi.StandardName.ptr)],
                        name16Daylight = temp.dtzi.DaylightName[0 .. wcslen(temp.dtzi.DaylightName.ptr)];

                    windowsTimeZones[String_UTF8(name16Standard).dup] = temp;
                    windowsTimeZones[String_UTF8(name16Daylight).dup] = temp;
                }
            }
            while (dwResult != ERROR_NO_MORE_ITEMS);
        }
    }
}

WindowsTimeZoneBase localTimeZone() @trusted {
    version (Windows) {
        WindowsTimeZoneBase ret;
        DWORD got = GetDynamicTimeZoneInformation(&ret.dtzi);
        return ret;
    } else
        return typeof(return).init;
}

Result!WindowsTimeZoneBase findWindowsTimeZone(scope String_UTF8 wantedName) @trusted {
    import sidero.base.datetime.cldr;

    version (Windows) {
        reloadWindowsTimeZones(false);

        if (wantedName.isEncodingChanged)
            wantedName = wantedName.dup;
        wantedName.stripZeroTerminator;

        String_UTF8 ianaAsWindows = String_UTF8(ianaToWindows(cast(string)wantedName.unsafeGetLiteral()));
        auto got = ianaAsWindows.length > 0 ? windowsTimeZones[ianaAsWindows] : windowsTimeZones[wantedName];

        if (got)
            return typeof(return)(got.get);
    }

    return typeof(return)(MalformedInputException("Could not find timezone given name"));
}

struct WindowsTimeZoneBase {
    version (Windows) {
        DYNAMIC_TIME_ZONE_INFORMATION dtzi;
    } else {
        int _;
    }

    String_UTF8 stdName, dstName;
    Bias standardOffset, daylightSavingsOffset;

@safe nothrow @nogc:

    this(scope return ref WindowsTimeZoneBase other) scope {
        this.tupleof = other.tupleof;
    }

package(sidero.base.datetime):

    bool haveDaylightSavings() scope {
        return daylightSavingsOffset.seconds != 0;
    }

    Result!TimeZone forYear(long year) scope @trusted {
        import sidero.base.datetime.cldr;
        import core.stdc.wchar_ : wcslen;

        version (Windows) {
            if (year < 0 || year > ushort.max)
                return typeof(return)(MalformedInputException("Windows timezone for year function only supports 0 .. 65536 range in year"));

            TIME_ZONE_INFORMATION tzi;
            BOOL got = GetTimeZoneInformationForYear(cast(ushort)year, &dtzi, &tzi);

            if (got) {
                TimeZone ret;
                ret.windowsBase.dtzi = this.dtzi;
                ret.haveDaylightSavings_ = tzi.StandardDate.wMonth != 0;

                {
                    // we have to store named seaparately due to possibilities of it changing per year
                    String_UTF8 standardName = String_UTF8(tzi.StandardName[0 .. wcslen(tzi.StandardName.ptr)]).dup;
                    ret.windowsBase.stdName = standardName;

                    if (ret.haveDaylightSavings_)
                        ret.windowsBase.dstName = String_UTF8(tzi.DaylightName[0 .. wcslen(tzi.DaylightName.ptr)]).dup;

                    standardName.stripZeroTerminator;
                    ret.ianaName_ = String_UTF8(windowsToIANA(cast(string)standardName.unsafeGetLiteral));
                    if (ret.ianaName_.length == 0) {
                        // stuff it, just pick the standard name
                        ret.ianaName_ = ret.windowsBase.stdName;
                    }
                }

                ret.windowsBase.standardOffset.seconds = tzi.StandardBias * 60;
                ret.windowsBase.standardOffset.appliesOnDate = GregorianDate(year, cast(ubyte)tzi.StandardDate.wMonth,
                        cast(ubyte)tzi.StandardDate.wDay);
                ret.windowsBase.standardOffset.appliesOnTime = TimeOfDay(cast(ubyte)tzi.StandardDate.wHour,
                        cast(ubyte)tzi.StandardDate.wMinute, cast(ubyte)tzi.StandardDate.wSecond,
                        cast(uint)(tzi.StandardDate.wMilliseconds * 1000));

                if (ret.haveDaylightSavings_) {
                    ret.windowsBase.daylightSavingsOffset.seconds = tzi.DaylightBias * 60;
                    ret.windowsBase.daylightSavingsOffset.appliesOnDate = GregorianDate(year, cast(ubyte)tzi.DaylightDate.wMonth,
                            cast(ubyte)tzi.DaylightDate.wDay);
                    ret.windowsBase.daylightSavingsOffset.appliesOnTime = TimeOfDay(cast(ubyte)tzi.DaylightDate.wHour,
                            cast(ubyte)tzi.DaylightDate.wMinute, cast(ubyte)tzi.DaylightDate.wSecond,
                            cast(uint)(tzi.DaylightDate.wMilliseconds * 1000));
                }

                ret.source = TimeZone.Source.Windows;
                return typeof(return)(ret);
            } else
                return typeof(return)(NonMatchingStateToArgumentException("Could not get timezone for year"));
        } else
            return typeof(return)(PlatformNotImplementedException("Only Windows is supported for Windows timezone for year function"));
    }

    static struct Bias {
        long seconds;
        GregorianDate appliesOnDate;
        TimeOfDay appliesOnTime;

        @safe nothrow @nogc:

        bool opEquals(const Bias other) scope const {
            return this.tupleof == other.tupleof;
        }

        int opCmp(const Bias other) scope const @trusted {
            if (this.seconds < other.seconds)
                return -1;
            else if (this.seconds > other.seconds)
                return 1;

            if (this.appliesOnDate < other.appliesOnDate)
                return -1;
            else if (this.appliesOnDate > other.appliesOnDate)
                return 1;

            if (this.appliesOnTime < other.appliesOnTime)
                return -1;
            else if (this.appliesOnTime > other.appliesOnTime)
                return 1;

            return 0;
        }
    }
}

bool isInDaylightSavings(scope ref WindowsTimeZoneBase self, scope DateTime!GregorianDate date) {
    if (!self.haveDaylightSavings || self.daylightSavingsOffset.appliesOn < date)
        return false;
    else if (self.standardOffset.appliesOn > self.daylightSavingsOffset.appliesOn)
        return self.standardOffset.appliesOn > date;
    else {
        auto next = self.forYear(self.standardOffset.appliesOn.year + 1);
        return date < next.windowsBase.standardOffset.appliesOn;
    }
}

private @hidden:
import sidero.base.containers.map.concurrenthashmap;

__gshared {
    DWORD windowsTZVersion;
    ConcurrentHashMap!(String_UTF8, WindowsTimeZoneBase) windowsTimeZones;
}

version (Windows) {
    import core.sys.windows.windows : DWORD, LONG, WCHAR, SYSTEMTIME, BOOLEAN, BOOL, USHORT, ERROR_NO_MORE_ITEMS,
        ERROR_SUCCESS, TIME_ZONE_INFORMATION, GetTimeZoneInformation, GetSystemTime;

    struct DYNAMIC_TIME_ZONE_INFORMATION {
        LONG Bias;
        WCHAR[32] StandardName;
        SYSTEMTIME StandardDate;
        LONG StandardBias;
        WCHAR[32] DaylightName;
        SYSTEMTIME DaylightDate;
        LONG DaylightBias;
        WCHAR[128] TimeZoneKeyName;
        BOOLEAN DynamicDaylightTimeDisabled;
    }

    extern (Windows) DWORD EnumDynamicTimeZoneInformation(const DWORD, DYNAMIC_TIME_ZONE_INFORMATION*) nothrow @nogc;
    extern (Windows) DWORD GetDynamicTimeZoneInformation(DYNAMIC_TIME_ZONE_INFORMATION*) nothrow @nogc;
    extern (Windows) BOOL GetTimeZoneInformationForYear(USHORT, DYNAMIC_TIME_ZONE_INFORMATION*, TIME_ZONE_INFORMATION*) nothrow @nogc;
}

// Unfortunately this can't be in Bias due to forward referencing issues.
DateTime!GregorianDate appliesOn(scope const ref WindowsTimeZoneBase.Bias bias) {
    return typeof(return)(bias.appliesOnDate, bias.appliesOnTime);
}
