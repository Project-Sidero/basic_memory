// unsupported Android < 2018e
module sidero.base.datetime.time.internal.iana;
import sidero.base.datetime.time.timezone;
import sidero.base.datetime.defs;
import sidero.base.datetime.calendars.gregorian;
import sidero.base.containers.map.concurrenthashmap;
import sidero.base.containers.dynamicarray;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.allocators;

package(sidero.base.datetime) @safe nothrow @nogc:

bool loadAutoIANA(scope String_UTF8 path = String_UTF8.init) @trusted {
    import sidero.base.internal.filesystem;

    if (path.length == 0)
        path = getDefaultTZDirectory();

    version (Android) {
        const wasAndroid = androidFileSize > 0 || tzDatabase.length == 0;
    } else {
        const wasAndroid = androidFileSize > 0 || getFileSize((path ~ "tzdata").asReadOnly) > 0;
    }

    tzDatabase.clear;
    posixTZToIANA.clear;
    androidFileSize = 0;

    if (wasAndroid)
        loadForAndroid(path);
    else
        loadStandard(path);

    return tzDatabase.length > 0;
}

void reloadTZ(bool forceReload = true) @trusted {
    version (Android) {
        const wasAndroid = androidFileSize > 0 || tzDatabase.length == 0;
    } else {
        const wasAndroid = androidFileSize > 0;
    }

    // if we have a database and not forced to reload,
    //  the load functions won't load if it can avoid it
    //  so just not clearing state is enough to do it lazily
    if (forceReload) {
        tzDatabase.clear;
        posixTZToIANA.clear;
        androidFileSize = 0;
    }

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

            TZFile ret;
            loadTZ(sliced, region, ret);
            tzDatabase[region] = ret;
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

        TZFile loaded;
        loadTZ(rawFileRead, region.get, loaded);
        value = loaded;
    }
}

Result!IanaTZBase findIANATimeZone(scope String_UTF8 zone) @trusted {
    reloadTZ(false);

    auto name = posixTZToIANA.get(zone, zone);
    if (!name)
        return typeof(return)(name.getError);

    auto ret = tzDatabase[name];
    if (!ret)
        return typeof(return)(ret.getError);

    IanaTZBase temp;
    temp.tzFile = ret;

    return typeof(return)(temp);
}

struct IanaTZBase {
    ResultReference!TZFile tzFile;
    long startUnixTime, endUnixTime;

    DynamicArray!(TZFile.Transition) transitionsForRange;

@safe nothrow @nogc:

    this(return scope ref IanaTZBase other) scope @trusted {
        this.tupleof = other.tupleof;
    }

    export ulong toHash() scope const {
        import sidero.base.hash.utils : hashOf;

        return hashOf(this);
    }

package(sidero.base.datetime):

    Result!TimeZone forYear(long year, return scope RCAllocator allocator = RCAllocator.init) scope @trusted {
        import sidero.base.datetime.calendars.gregorian;
        import sidero.base.datetime.time.timeofday;
        import sidero.base.datetime.defs;

        if (!tzFile || tzFile.isNull)
            return typeof(return)(NullPointerException("No IANA TZ information"));

        TimeZone ret;
        ret.initialize(allocator);
        ret.state.source = TimeZone.Source.IANA;
        ret.state.name = tzFile.region;

        long startUnixTime, endUnixTime;

        {
            // assuming UTC0, what is the unix time of the start and end of this year?
            DateTime!GregorianDate startGD = DateTime!GregorianDate(GregorianDate(year, 1, 1), TimeOfDay(0, 0, 0)),
                endGD = DateTime!GregorianDate(GregorianDate(year + 1, 1, 1), TimeOfDay(0, 0, 0));

            auto startUnix = startGD.toUnixTime, endUnix = endGD.toUnixTime;

            if (!startUnix)
                return typeof(return)(startUnix.getError);
            else if (!endUnix)
                return typeof(return)(endUnix.getError);

            startUnixTime = startUnix.get;
            endUnixTime = endUnix.get;
            ret.state.ianaTZBase.startUnixTime = startUnixTime;
            ret.state.ianaTZBase.endUnixTime = endUnixTime;
        }

        {
            ptrdiff_t index = -1;

            foreach (offset, transition; tzFile.transitions) {
                if (transition.appliesOn > startUnixTime)
                    break;
                index = offset;
            }

            if (index >= 0) {
                auto temp = tzFile.transitions[index .. $];
                assert(temp);
                size_t count;

                foreach (transition; temp) {
                    if (transition.appliesOn >= endUnixTime)
                        break;
                    count++;
                }

                transitionsForRange = tzFile.transitions[index .. index + count];
            }
        }

        return typeof(return)(ret);
    }

    String_UTF8 nameFor(long unixTime) scope @trusted {
        ptrdiff_t index = -1;

        foreach_reverse (offset, transition; this.transitionsForRange) {
            if (transition.appliesOn < unixTime)
                break;
            index = offset;
        }

        if (index >= 0) {
            auto temp = this.transitionsForRange[index];
            assert(temp);

            auto got = this.tzFile.postTransitionInfo[temp.postTransitionInfoOffset];
            assert(got);

            return got.designator;
        }

        return tzFile.region;
    }

    bool isInDST(long unixTime) scope @trusted {
        ptrdiff_t index = -1;

        foreach_reverse (offset, transition; this.transitionsForRange) {
            if (transition.appliesOn < unixTime)
                break;
            index = offset;
        }

        if (index >= 0) {
            auto temp = this.transitionsForRange[index];
            assert(temp);

            auto got = this.tzFile.postTransitionInfo[temp.postTransitionInfoOffset];
            assert(got);

            return got.isDstActive;
        }

        return false;
    }

    long secondsBias(long unixTime) scope @trusted {
        ptrdiff_t index = -1;

        foreach_reverse (offset, transition; this.transitionsForRange) {
            if (transition.appliesOn < unixTime)
                break;
            index = offset;
        }

        if (index >= 0) {
            auto temp = this.transitionsForRange[index];
            assert(temp);

            auto got = this.tzFile.postTransitionInfo[temp.postTransitionInfoOffset];
            assert(got);

            return got.secondsSinceUTC0;
        }

        return 0;
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

void loadTZ(scope DynamicArray!ubyte rawFileRead, return scope String_UTF8 region, ref TZFile tzFile) @trusted {
    import sidero.base.internal.filesystem;
    import sidero.base.allocators;
    import std.bitmanip : bigEndianToNative;

    {
        auto acquired = tzDatabase.get(region, TZFile.init);
        assert(acquired);
        tzFile = acquired.get;
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

    const originalFileSize = rawFileRead.length;
    const isGMT = region.contains("GMT");

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
            tzFile.transitions.reserve(tzh_timecnt);
            long lastApplied = long.min;
            foreach (i; 0 .. tzh_timecnt) {
                auto appliesOn = readValue!SizeOfTime;

                // if it is not contiguous, error (we could sort if we need to)
                assert(appliesOn > lastApplied, "Non-contiguous IANA TZ database entries for transitions");
                lastApplied = appliesOn;

                tzFile.transitions ~= TZFile.Transition(appliesOn);
            }

            foreach (i; 0 .. tzh_timecnt) {
                auto got = tzFile.transitions[i];
                assert(got);

                got.postTransitionInfoOffset = readValue!ubyte;
                tzFile.transitions[i] = got;
            }
        }

        {
            tzFile.postTransitionInfo.reserve(tzh_typecnt);
            foreach (i; 0 .. tzh_typecnt) {
                auto delta = readValue!int;

                if (isGMT)
                    delta *= -1;

                tzFile.postTransitionInfo ~= TZFile.PostTransitionInfo(delta, readValue!bool, readValue!ubyte);
            }
        }

        {
            String_UTF8 designators = readUTF8(tzh_charcnt);

            version (none) {
                DynamicArray!String_UTF8 allDesignatorsBuffer;

                while (designators.length > 0) {
                    ptrdiff_t indexOfZero = designators.indexOf("\0\0"c);
                    String_UTF8 designator;

                    if (indexOfZero < 0) {
                        designator = designators;
                        designators = String_UTF8.init;
                    } else {
                        designator = designators[0 .. indexOfZero + 1];
                        designators = designators[indexOfZero + 1 .. $];
                    }

                    allDesignatorsBuffer ~= designator;
                }

                foreach (offset, pti; tzFile.postTransitionInfo) {
                    if (allDesignatorsBuffer.length > pti.designatorOffset) {
                        auto got = allDesignatorsBuffer[pti.designatorOffset];
                        assert(got);
                        pti.designator = got;

                        if (got.length > 0)
                            tzFile.postTransitionInfo[offset] = pti;
                    }
                }
            }

            // this is the fastest approach :(
            version (all) {
                foreach (offset, pti; tzFile.postTransitionInfo) {
                    String_UTF8 designator = designators;
                    size_t wanted = pti.designatorOffset;
                    ptrdiff_t index;

                    while (wanted > 0 && designator.length > 0) {
                        index = designator.indexOf("\0");
                        if (index >= 0)
                            designator = designator[index + 1 .. $];
                        wanted--;
                    }

                    if (wanted == 0 && designator.length > 0) {
                        index = designator.indexOf("\0");
                        if (index >= 0)
                            designator = designator[0 .. index + 1];
                        pti.designator = designator;

                        if (designator.length > 0)
                            tzFile.postTransitionInfo[offset] = pti;
                    }
                }
            }

            version (none) {
                ubyte designatorIndex;

                while (designators.length > 0) {
                    ptrdiff_t indexOfZero = designators.indexOf("\0\0"c);
                    String_UTF8 designator;

                    if (indexOfZero < 0) {
                        designator = designators;
                        designators = String_UTF8.init;
                    } else {
                        designator = designators[0 .. indexOfZero + 1];
                        designators = designators[indexOfZero + 1 .. $];
                    }

                    foreach (offset, pti; tzFile.postTransitionInfo) {
                        if (pti.designatorOffset == designatorIndex) {
                            pti.designator = designator;
                            tzFile.postTransitionInfo[offset] = pti;
                        }
                    }

                    designatorIndex++;
                }
            }
        }

        {
            tzFile.leapSecond.reserve(tzh_leapcnt);

            foreach (i; 0 .. tzh_leapcnt) {
                long appliesOn = readValue!SizeOfTime;
                int count = readValue!int;
                tzFile.leapSecond ~= TZFile.LeapSecond(appliesOn, count);
            }
        }

        {
            foreach (i; 0 .. tzh_ttisstdcnt) {
                auto got = tzFile.transitions[i];
                assert(got);

                got.standardOrWallClockTime = readValue!bool;
                tzFile.transitions[i] = got;
            }
        }

        {
            foreach (i; 0 .. tzh_ttisstdcnt) {
                auto got = tzFile.transitions[i];
                assert(got);

                got.localTimeInUTCOrLocal = readValue!bool;
                tzFile.transitions[i] = got;
            }
        }
    }

    if (rawFileRead.length > 0) {
        tzFile.region = region;
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
}

struct TZFile {
    size_t fileSize;
    String_UTF8 region;

    ubyte version_;

    DynamicArray!Transition transitions;
    DynamicArray!PostTransitionInfo postTransitionInfo;
    DynamicArray!LeapSecond leapSecond;

    String_UTF8 tzString;

@safe nothrow @nogc:

    this(return scope ref TZFile other) scope {
        this.tupleof = other.tupleof;
    }

    export ulong toHash() scope const {
        import sidero.base.hash.utils : hashOf;

        return hashOf(this);
    }

    static struct Transition {
        // Seconds since Unix Epoch
        long appliesOn;
        ubyte postTransitionInfoOffset;

        bool standardOrWallClockTime;
        bool localTimeInUTCOrLocal;
    }

    static struct PostTransitionInfo {
        int secondsSinceUTC0;
        bool isDstActive;

        // ignore this, its just a temporary, prefer designator field instead
        ubyte designatorOffset;

        String_UTF8 designator;

    @safe nothrow @nogc:

        this(return scope ref PostTransitionInfo other) scope {
            this.tupleof = other.tupleof;
        }

        export ulong toHash() scope const {
            import sidero.base.hash.utils : hashOf;

            return hashOf(this);
        }
    }

    static struct LeapSecond {
        long appliesOn;
        int amount;
    }
}
