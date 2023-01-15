module sidero.base.datetime.time.internal.windows;
import sidero.base.datetime.time.timezone;
import sidero.base.errors;
import sidero.base.attributes;
import sidero.base.text;

package(sidero.base.datetime) @safe nothrow @nogc:

void reloadWindowsTimeZones(bool forceReload = true) @trusted {
    version (Windows) {
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

package(sidero.base.datetime) @safe nothrow @nogc:

    Result!TimeZone forYear(long year) @trusted {
        import sidero.base.datetime.calendars.gregorian;
        import sidero.base.datetime.time.timeofday;

        version (Windows) {
            if (year < 0 || year > ushort.max)
                return typeof(return)(MalformedInputException("Windows timezone for year function only supports 0 .. 65536 range in year"));

            TIME_ZONE_INFORMATION tzi;
            BOOL got = GetTimeZoneInformationForYear(cast(ushort)year, &dtzi, &tzi);

            if (got) {
                TimeZone ret;

                ret.standardOffset_.seconds = tzi.StandardBias * 60;
                ret.standardOffset_.appliesOnDate = GregorianDate(year, cast(ubyte)tzi.StandardDate.wMonth,
                        cast(ubyte)tzi.StandardDate.wDay);
                ret.standardOffset_.appliesOnTime = TimeOfDay(cast(ubyte)tzi.StandardDate.wHour,
                        cast(ubyte)tzi.StandardDate.wMinute, cast(ubyte)tzi.StandardDate.wSecond,
                        cast(uint)(tzi.StandardDate.wMilliseconds * 1000));
                ret.haveDaylightSavings_ = tzi.StandardDate.wMonth != 0;

                if (ret.haveDaylightSavings_) {
                    ret.daylightSavingsOffset_.seconds = tzi.DaylightBias * 60;
                    ret.daylightSavingsOffset_.appliesOnDate = GregorianDate(year, cast(ubyte)tzi.DaylightDate.wMonth,
                            cast(ubyte)tzi.DaylightDate.wDay);
                    ret.daylightSavingsOffset_.appliesOnTime = TimeOfDay(cast(ubyte)tzi.DaylightDate.wHour,
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
