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
import sidero.base.path.file;

package(sidero.base.datetime) @safe nothrow @nogc:

bool loadAutoIANA(scope FilePath path = FilePath.init, String_UTF8 limitToRegion = String_UTF8.init) @trusted {
    import sidero.base.internal.filesystem;

    if (path.isNull)
        path = getDefaultTZDirectory();

    loadedPath = path;
    reloadTZ(true, limitToRegion);

    return tzDatabase.length > 0;
}

void reloadTZ(bool forceReload = true, String_UTF8 limitToRegion = String_UTF8.init) @trusted {
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

    FilePath path = loadedPath;

    if (wasAndroid)
        loadForAndroid(path, limitToRegion);
    else
        loadStandard(path, limitToRegion);
}

void loadForAndroid(scope FilePath path = FilePath.init, String_UTF8 limitToRegion) @trusted {
    import sidero.base.internal.filesystem;
    import sidero.base.allocators;
    import sidero.base.bitmanip : bigEndianToNative;

    if (path.isNull)
        path = getDefaultTZDirectory();

    // The Android file format for tzdata is documented in ZoneCompactor.java
    // available here: https://android.googlesource.com/platform/system/timezone/+/master/input_tools/android/zone_compactor/main/java/ZoneCompactor.java

    auto rawFileRead = readFile!ubyte(path.dup ~ "tzdata", androidFileSize);

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

void loadStandard(scope FilePath path = FilePath.init, String_UTF8 limitToRegion) @trusted {
    import sidero.base.internal.filesystem;

    if (path.isNull)
        path = getDefaultTZDirectory();
    loadedPath = path.dup;

    void readRegions(scope ref size_t length, scope string zoneFile) {
        auto rawFileRead = readFile!char(path.dup ~ zoneFile, length);

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

    void processPerRegion(String_UTF8 region, size_t regionFileSize) {
        auto src = loadedPath ~ region;
        auto rawFileRead = readFile!ubyte(src, regionFileSize);

        if (!rawFileRead.isNull) {
            TZFile loaded;
            loadTZ(rawFileRead, region, loaded);
            tzDatabase[region] = loaded;
        }
    }

    if (!limitToRegion.isNull) {
        size_t existingFileSize;

        auto existingValue = tzDatabase[limitToRegion];
        if (existingValue && !existingValue.isNull)
            existingFileSize = existingValue.fileSize;

        processPerRegion(limitToRegion, existingFileSize);
    } else {
        foreach (region, value; tzDatabase) {
            assert(region);
            assert(value);

            processPerRegion(region.get, value.fileSize);
        }
    }
}

Result!IanaTZBase findIANATimeZone(scope String_UTF8 zone) @trusted {
    auto name = posixTZToIANA.get(zone, zone);
    assert(name);

    reloadTZ(false, name);

    auto ret = tzDatabase[name];
    if (!ret) {
        version (Posix) {
            // If we are only Posix, it is possible that we just haven't loaded the right region yet
            //  so we'll force a load of only the region Posix TZ mapping and try that one again

            // TODO: only load the regions Posix TZ mapping
            reloadTZ(false);

            name = posixTZToIANA.get(zone, zone);
            assert(name);

            ret = tzDatabase[name];
        }

        if (!ret)
            return typeof(return)(ret.getError);
    }

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

    void opAssign(return scope IanaTZBase other) scope {
        this.destroy;
        this.__ctor(other);
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
        ret.state.ianaTZBase.tzFile = this.tzFile;

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

                auto tempTransitions = tzFile.transitions[index .. index + count];
                assert(tempTransitions);
                transitionsForRange = tempTransitions;
            }
        }

        return typeof(return)(ret);
    }

    String_UTF8 nameFor(long unixTime) return scope @trusted {
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

    Result!long secondsBias(long unixTime, bool hasOffsetApplied = false) scope @trusted {
        long ret;

        if (!tzFile || tzFile.isNull)
            return typeof(return)(NullPointerException("No IANA TZ information"));

        foreach_reverse (transitionLeapSecond; this.tzFile.transitionLeapSeconds) {
            unixTime -= transitionLeapSecond.leapSeconds;
            long bias, tempUnixTime = unixTime;

            if (transitionLeapSecond.secondsSinceUTC0 >= 0) {
                bias = transitionLeapSecond.secondsSinceUTC0;

                if (hasOffsetApplied)
                    tempUnixTime -= bias;
            }

            if (transitionLeapSecond.appliesOn <= tempUnixTime) {
                ret = bias;
                break;
            }
        }

        return typeof(return)(ret);
    }
}

void uninitializeIANATZ() @trusted {
    loadedPath = FilePath.init;
    defaultTZDirectory = FilePath.init;
    tzDatabase = typeof(tzDatabase).init;
    posixTZToIANA = typeof(posixTZToIANA).init;
}

private:

__gshared {
    size_t androidFileSize, zoneTabLength, zone1970TabLength;
    FilePath loadedPath, defaultTZDirectory;
    ConcurrentHashMap!(String_UTF8, TZFile) tzDatabase;
    ConcurrentHashMap!(String_UTF8, String_UTF8) posixTZToIANA;
}

FilePath getDefaultTZDirectory() @trusted {
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
            auto got = FilePath.from(tzdir);
            if (got)
                defaultTZDirectory = got.get;
        } else {
            auto got = FilePath.from(DefaultTZDirectory);
            if (got)
                defaultTZDirectory = got.get;
        }
    }

    return defaultTZDirectory;
}

void loadTZ(scope DynamicArray!ubyte rawFileRead, return scope String_UTF8 region, ref TZFile tzFile) @trusted {
    import sidero.base.internal.filesystem;
    import sidero.base.allocators;
    import sidero.base.bitmanip : bigEndianToNative;

    {
        auto acquired = tzDatabase.get(region, TZFile.init);
        assert(acquired);
        tzFile = acquired.get;
    }

    size_t readSoFar;

    void skipBytes(size_t amount) {
        auto temp = rawFileRead[amount .. $];
        assert(temp);
        rawFileRead = temp;
        readSoFar += amount;
    }

    auto readValue(Type)() {
        assert(rawFileRead.length >= Type.sizeof);

        auto reading = rawFileRead[0 .. Type.sizeof];
        assert(reading);
        skipBytes(Type.sizeof);

        ubyte[Type.sizeof] buffer;

        size_t i;
        foreach (v; reading) {
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

    void handle(bool first) {
        //"TZif"
        char[4] magicHeader = readArray!(char[4]);

        if (magicHeader != "TZif")
            return;

        tzFile = TZFile.init;
        tzFile.fileSize = originalFileSize;
        tzFile.region = region;

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
            // transition times
            tzFile.transitions.reserve(tzh_timecnt);
            long lastApplied = long.min;
            foreach (i; 0 .. tzh_timecnt) {
                long appliesOn = (tzFile.version_ <= 1 || first) ? readValue!int : readValue!long;

                // if it is not contiguous, error (we could sort if we need to)
                assert(appliesOn > lastApplied, "Non-contiguous IANA TZ database entries for transitions");
                lastApplied = appliesOn;

                tzFile.transitions ~= TZFile.Transition(appliesOn);
            }

            foreach (i; 0 .. tzh_timecnt) {
                auto got = tzFile.transitions[i];
                assert(got);

                got.postTransitionInfoOffset = readValue!ubyte;
                cast(void)(tzFile.transitions[i] = got);
            }
        }

        {
            // local time type records

            tzFile.postTransitionInfo.reserve(tzh_typecnt);
            foreach (i; 0 .. tzh_typecnt) {
                auto delta = readValue!int;

                if (isGMT)
                    delta *= -1;

                tzFile.postTransitionInfo ~= TZFile.PostTransitionInfo(delta, readValue!bool, readValue!ubyte);
            }
        }

        {
            // time zone designations

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
                            cast(void)(tzFile.postTransitionInfo[offset] = pti);
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
            // leap-second records

            tzFile.leapSecond.reserve(tzh_leapcnt);

            foreach (i; 0 .. tzh_leapcnt) {
                long appliesOn = (tzFile.version_ <= 1 || first) ? readValue!int : readValue!long;
                int count = readValue!int;
                tzFile.leapSecond ~= TZFile.LeapSecond(appliesOn, count);
            }
        }

        {
            // standard/wall indicators

            foreach (i; 0 .. tzh_ttisstdcnt) {
                auto got = tzFile.transitions[i];
                bool b = readValue!bool;

                if (!got) {
                    // missing transition, we're not interested in it
                } else {
                    got.standardOrWallClockTime = b;
                    cast(void)(tzFile.transitions[i] = got);
                }
            }
        }

        {
            foreach (i; 0 .. tzh_ttisstdcnt) {
                auto got = tzFile.transitions[i];
                bool b = readValue!bool;

                if (!got) {
                    // missing transition, we're not interested in it
                } else {
                    got.localTimeInUTCOrLocal = b;
                    cast(void)(tzFile.transitions[i] = got);
                }
            }
        }
    }

    if (rawFileRead.length > 0) {
        tzFile.region = region;

        handle(true);

        if (tzFile.version_ > 1) {
            handle(false);

            if (rawFileRead.length > 2) {
                if (readValue!ubyte != '\n')
                    goto MergeTransitionLeap;

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

    MergeTransitionLeap: {
            // Perform a two-way merge of transitions + leap seconds for calculation of seconds bias

            const lengthOfLeapSeconds = tzFile.leapSecond.length, lengthOfTransitions = tzFile.transitions.length;
            const maxElements = lengthOfLeapSeconds + lengthOfTransitions;
            tzFile.transitionLeapSeconds = typeof(tzFile.transitionLeapSeconds).init;
            tzFile.transitionLeapSeconds.reserve(maxElements);

            const leapSeconds = tzFile.leapSecond.unsafeGetLiteral;
            const transitions = tzFile.transitions.unsafeGetLiteral;
            auto postTransitions = tzFile.postTransitionInfo.unsafeGetLiteral;

            size_t leapSecondIndex, transitionIndex;

            foreach (_; 0 .. maxElements) {
                if (leapSecondIndex == lengthOfLeapSeconds) {
                    // transition
                    auto transition = transitions[transitionIndex++];
                    auto postTransition = postTransitions[transition.postTransitionInfoOffset];

                    tzFile.transitionLeapSeconds ~= TZFile.TransitionLeapSecond(transition.appliesOn, postTransition.secondsSinceUTC0, 0);
                } else if (transitionIndex == lengthOfTransitions) {
                    // leap second
                    auto leapSecond = leapSeconds[leapSecondIndex++];
                    tzFile.transitionLeapSeconds ~= TZFile.TransitionLeapSecond(leapSecond.appliesOn, -1, leapSecond.amount);
                } else {
                    auto transition = transitions[transitionIndex];
                    auto postTransition = postTransitions[transition.postTransitionInfoOffset];
                    auto leapSecond = leapSeconds[leapSecondIndex];

                    if (transition.appliesOn < leapSecond.appliesOn) {
                        transitionIndex++;
                        tzFile.transitionLeapSeconds ~= TZFile.TransitionLeapSecond(transition.appliesOn,
                                postTransition.secondsSinceUTC0, 0);
                    } else if (transition.appliesOn > leapSecond.appliesOn) {
                        leapSecondIndex++;
                        tzFile.transitionLeapSeconds ~= TZFile.TransitionLeapSecond(leapSecond.appliesOn, -1, leapSecond.amount);
                    } else {
                        transitionIndex++;
                        leapSecondIndex++;
                        tzFile.transitionLeapSeconds ~= TZFile.TransitionLeapSecond(transition.appliesOn,
                                postTransition.secondsSinceUTC0, leapSecond.amount);
                    }
                }
            }
        }
    }
}

struct TZFile {
    size_t fileSize;
    String_UTF8 region;

    ubyte version_;

    DynamicArray!Transition transitions;
    DynamicArray!PostTransitionInfo postTransitionInfo;
    DynamicArray!LeapSecond leapSecond;
    DynamicArray!TransitionLeapSecond transitionLeapSeconds;

    String_UTF8 tzString;

export @safe nothrow @nogc:

    this(return scope ref TZFile other) scope {
        this.tupleof = other.tupleof;
    }

    void opAssign(return scope TZFile other) scope {
        this.destroy;
        this.__ctor(other);
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

        void opAssign(return scope PostTransitionInfo other) scope {
            this.destroy;
            this.__ctor(other);
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

    static struct TransitionLeapSecond {
        long appliesOn;
        int secondsSinceUTC0;
        int leapSeconds;
    }
}
