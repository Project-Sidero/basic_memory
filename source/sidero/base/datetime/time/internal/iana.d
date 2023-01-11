// unsupported Android < 2018e
module sidero.base.datetime.time.iana;
import sidero.base.containers.map.concurrenthashmap;
import sidero.base.containers.dynamicarray;
import sidero.base.text;
import sidero.base.errors;

package(sidero.base.datetime) @safe nothrow @nogc:

void reloadTZ() @trusted {
    version (Android) {
        const wasAndroid = androidFileSize > 0 || tzDatabase.length == 0;
    } else {
        const wasAndroid = androidFileSize > 0;
    }

    tzDatabase.clear;
    posixTZToIANA.clear;
    androidFileSize = 0;

    String_UTF8 path = loadedPath;

    if (wasAndroid)
        loadForAndroid(path);
    else
        loadStandard(path);
}

void loadForAndroid(scope String_UTF8 path = String_UTF8.init) @trusted {
    import sidero.base.internal.filesystem;
    import sidero.base.allocators;
    import std.bitmanip : bigEndianToNative;

    if (path.length == 0)
        path = getDefaultTZDirectory();

    // The Android file format for tzdata is documented in ZoneCompactor.java
    // available here: https://android.googlesource.com/platform/system/timezone/+/master/input_tools/android/zone_compactor/main/java/ZoneCompactor.java

    String_UTF8 filename = (path ~ "tzdata").asReadOnly;
    auto rawFileRead = readFile!ubyte(filename, androidFileSize);

    if (rawFileRead.length == 0)
        return;

    loadedPath = path.dup;
    androidFileSize = rawFileRead.length;

    // everything is 4 bytes

    {
        if (rawFileRead.length < 6)
            return;

        //tzdata
        auto temp = rawFileRead[0 .. 6];
        assert(temp);
        if (temp.get != cast(const(ubyte)[])"tzdata")
            return;

        temp = rawFileRead[6 .. $];
        assert(temp);
        rawFileRead = temp;

        // char[] (zero terminated), version
        ptrdiff_t index = rawFileRead.indexOf('\0');
        if (index < 0)
            return;

        temp = rawFileRead[index + 1 .. $];
        assert(temp);
        rawFileRead = temp;
    }

    void skipBytes(size_t amount) {
        auto temp = rawFileRead[amount .. $];
        assert(temp);
        rawFileRead = temp;
    }

    auto readValue(Type)() {
        assert(rawFileRead.length >= Type.sizeof);

        auto reading = rawFileRead[0 .. Type.sizeof];
        assert(reading);
        skipBytes(Type.sizeof);

        ubyte[Type.sizeof] buffer;

        size_t i;
        foreach (v; reading) {
            assert(v);
            buffer[i++] = v;
        }

        static if (Type.sizeof > 1) {
            return bigEndianToNative!Type(buffer);
        } else {
            return cast(Type)buffer[0];
        }
    }

    auto readArray(Type)() {
        Type ret;

        foreach (i, ref v; ret) {
            v = readValue!(typeof(v));
        }

        return ret;
    }

    String_UTF8 readUTF8(size_t count) {
        RCAllocator allocator = globalAllocator();

        char[] ret = allocator.makeArray!char(count);
        assert(ret.length == count);

        foreach (ref v; ret) {
            v = readValue!char;
        }

        return String_UTF8(ret, allocator);
    }

    const offsetToIndexes = readValue!uint, offsetToData = readValue!uint, offsetToEndOfTZif = readValue!uint;

    {
        enum MaxNameLength = 40;
        enum RegionIndexEntry = MaxNameLength + 4 + 4 + 4;

        const numberOfRegions = (offsetToData - offsetToIndexes) / RegionIndexEntry;

        foreach (i; 0 .. numberOfRegions) {
            auto region = readUTF8(40);
            region.stripRight;
            region = region.dup;

            const offsetOfZone = readValue!uint, lengthOfZone = readValue!uint;
            skipBytes(4);

            const adjustment = androidFileSize - rawFileRead.length, offsetTo = offsetToData + offsetOfZone - adjustment;
            auto sliced = rawFileRead[offsetTo .. offsetTo + lengthOfZone];
            assert(sliced);

            tzDatabase[region] = loadTZ(sliced, region);
        }
    }

    // rawFileRead[offsetToEndOfTZif .. $] should be zone.tab/zone1970.tab
    // we don't need them, as the information we need is at the start.
}

void loadStandard(scope String_UTF8 path = String_UTF8.init) @trusted {
    import sidero.base.internal.filesystem;

    if (path.length == 0)
        path = getDefaultTZDirectory();
    loadedPath = path.dup;

    void readRegions(scope ref size_t length, scope string zoneFile) {
        String_UTF8 filename = (path ~ zoneFile).asReadOnly;
        auto rawFileRead = readFile!char(filename, length);

        if (rawFileRead.length > 0)
            length = rawFileRead.length;

        while (rawFileRead.length > 0) {
            ptrdiff_t index = rawFileRead.indexOf('\n');
            Result!(DynamicArray!char) line;

            if (index < 0) {
                line = rawFileRead;
                assert(line);

                auto temp = rawFileRead[$ .. $];
                assert(temp);
                rawFileRead = temp;
            } else {
                line = rawFileRead[0 .. index + 1];
                assert(line);

                auto temp = rawFileRead[index + 1 .. $];
                assert(temp);
                rawFileRead = temp;
            }

            if (line.length == 0)
                continue;

            {
                // skip two tabs

                index = line.indexOf('\t');
                if (index < 0)
                    continue;

                line = line[index + 1 .. $];
                assert(line);

                index = line.indexOf('\t');
                if (index < 0)
                    continue;

                line = line[index + 1 .. $];
                assert(line);
            }

            {
                // we want this field

                index = line.indexOf('\t');
                if (index >= 0)
                    line = line[0 .. index];
                assert(line);

                if (line.length == 0)
                    continue;
            }

            String_UTF8 region = String_UTF8(line.unsafeGetLiteral).stripRight.dup;
            tzDatabase[region] = TZFile.init;
        }
    }

    readRegions(zoneTabLength, "zone.tab");
    readRegions(zone1970TabLength, "zone1970.tab");

    foreach (region, value; tzDatabase) {
        assert(region);
        assert(value);

        String_UTF8 filename = (path ~ region.get).asReadOnly;
        auto rawFileRead = readFile!ubyte(filename, value.fileSize);
        value = loadTZ(rawFileRead, region.get);
    }
}

ResultReference!TZFile lookupTZ(scope String_UTF8 zone) @trusted {
    reloadTZ;

    auto name = posixTZToIANA.get(zone, zone);
    auto ret = tzDatabase[name];

    return ret;
}

struct TZFile {
    size_t fileSize;
    ubyte version_;

    DynamicArray!DaylightTransition transitionIntoDaylight;
    DynamicArray!Ttinfo ttinfo;
    String_UTF8 designators;
    DynamicArray!LeapSecond leapSecond;
    DynamicArray!bool dstTransitionInStandardOrWallClock;
    DynamicArray!bool dstTransitionLocalTimeAreUTCOrLocal;
    String_UTF8 tzString;

@safe nothrow @nogc:

    this(scope return ref TZFile other) scope {
        this.tupleof = other.tupleof;
    }

    static struct DaylightTransition {
        // Seconds since Unix Epoch
        long appliesOn;
        ubyte indexInto_ttinfo;
    }

    static struct Ttinfo {
        int tt_utoff;
        bool tt_isdst;
        // See_Also: designators
        ubyte tt_desigidx;
    }

    static struct LeapSecond {
        long appliesOn;
        int amount;
    }
}

private:

__gshared {
    size_t androidFileSize, zoneTabLength, zone1970TabLength;
    String_UTF8 loadedPath, defaultTZDirectory;
    ConcurrentHashMap!(String_UTF8, TZFile) tzDatabase;
    ConcurrentHashMap!(String_UTF8, String_UTF8) posixTZToIANA;
}

String_UTF8 getDefaultTZDirectory() @trusted {
    import sidero.base.system : EnvironmentVariables;

    // default directories are copied straight from Phobos
    version (Android) {
        enum DefaultTZDirectory = "/system/usr/share/zoneinfo/";
    } else version (Solaris) {
        enum DefaultTZDirectory = "/usr/share/lib/zoneinfo/";
    } else version (Posix) {
        enum DefaultTZDirectory = "/usr/share/zoneinfo/";
    } else {
        enum DefaultTZDirectory = "";
    }

    // env var $TZDIR

    if (defaultTZDirectory.isNull) {
        String_UTF8 tzdir = EnvironmentVariables[String_UTF8("TZDIR\0")];

        if (tzdir.length > 0) {
            defaultTZDirectory = tzdir;
        } else {
            defaultTZDirectory = DefaultTZDirectory;
        }
    }

    return defaultTZDirectory;
}

TZFile loadTZ(scope DynamicArray!ubyte rawFileRead, scope return String_UTF8 region) @trusted {
    import sidero.base.internal.filesystem;
    import sidero.base.allocators;
    import std.bitmanip : bigEndianToNative;

    auto tzFile = tzDatabase.get(region, TZFile.init);
    assert(tzFile);

    void skipBytes(size_t amount) {
        auto temp = rawFileRead[amount .. $];
        assert(temp);
        rawFileRead = temp;
    }

    auto readValue(Type)() {
        assert(rawFileRead.length >= Type.sizeof);

        auto reading = rawFileRead[0 .. Type.sizeof];
        assert(reading);
        skipBytes(Type.sizeof);

        ubyte[Type.sizeof] buffer;

        size_t i;
        foreach (v; reading) {
            assert(v);
            buffer[i++] = v;
        }

        static if (Type.sizeof > 1) {
            return bigEndianToNative!Type(buffer);
        } else {
            return cast(Type)buffer[0];
        }
    }

    auto readArray(Type)() {
        Type ret;

        foreach (i, ref v; ret) {
            v = readValue!(typeof(v));
        }

        return ret;
    }

    String_UTF8 readUTF8(size_t count) {
        RCAllocator allocator = globalAllocator();

        char[] ret = allocator.makeArray!char(count);
        assert(ret.length == count);

        foreach (ref v; ret) {
            v = readValue!char;
        }

        return String_UTF8(ret, allocator);
    }

    const originalFileSize = rawFileRead.length;

    void handle(SizeOfTime)() {
        //"TZif"
        char[4] magicHeader = readArray!(char[4]);

        if (magicHeader != "TZif")
            return;

        tzFile = TZFile.init;
        tzFile.fileSize = originalFileSize;

        {
            // 0, '2', '3', '4'
            tzFile.version_ = readValue!ubyte;

            if (tzFile.version_ == 0) {
            } else {
                tzFile.version_ -= '0';
                if (tzFile.version_ < 2 || tzFile.version_ > 4)
                    return;
            }
        }

        // reserved for future use
        skipBytes(15);

        uint tzh_ttisutcnt = readValue!uint, tzh_ttisstdcnt = readValue!uint, tzh_leapcnt = readValue!uint,
            tzh_timecnt = readValue!uint, tzh_typecnt = readValue!uint, tzh_charcnt = readValue!uint;

        {
            tzFile.transitionIntoDaylight.reserve(tzh_timecnt);
            foreach (i; 0 .. tzh_timecnt) {
                tzFile.transitionIntoDaylight ~= TZFile.DaylightTransition(readValue!SizeOfTime);
            }

            foreach (i; 0 .. tzh_timecnt) {
                auto got = tzFile.transitionIntoDaylight[i];
                assert(got);

                got.indexInto_ttinfo = readValue!ubyte;
                tzFile.transitionIntoDaylight[i] = got;
            }
        }

        {
            tzFile.ttinfo.reserve(tzh_typecnt);
            foreach (i; 0 .. tzh_typecnt) {
                tzFile.ttinfo ~= TZFile.Ttinfo(readValue!int, readValue!bool, readValue!ubyte);
            }
        }

        tzFile.designators = readUTF8(tzh_charcnt);

        {
            tzFile.leapSecond.reserve(tzh_leapcnt);

            foreach (i; 0 .. tzh_leapcnt) {
                long appliesOn = readValue!SizeOfTime;
                int count = readValue!int;
                tzFile.leapSecond ~= TZFile.LeapSecond(appliesOn, count);
            }
        }

        {
            tzFile.dstTransitionInStandardOrWallClock.reserve(tzh_ttisstdcnt);

            foreach (i; 0 .. tzh_ttisstdcnt)
                tzFile.dstTransitionInStandardOrWallClock ~= readValue!bool;
        }

        {
            tzFile.dstTransitionLocalTimeAreUTCOrLocal.reserve(tzh_ttisutcnt);

            foreach (i; 0 .. tzh_ttisutcnt)
                tzFile.dstTransitionLocalTimeAreUTCOrLocal ~= readValue!bool;
        }
    }

    if (rawFileRead.length > 0) {
        handle!int;

        if (tzFile.version_ > 0) {
            handle!long;

            if (rawFileRead.length > 2) {
                if (readValue!ubyte != '\n')
                    goto End;

                StringBuilder_UTF8 tzStringBuilder;

                while (rawFileRead.length > 0) {
                    char[1] c = [readValue!char];
                    if (c[0] == '\n')
                        break;
                    tzStringBuilder ~= c[];
                }

                tzFile.tzString = tzStringBuilder.asReadOnly;

                if (tzFile.tzString.length > 0)
                    posixTZToIANA[tzFile.tzString] = region;
            }
        }
    }

End:
    return tzFile;
}
