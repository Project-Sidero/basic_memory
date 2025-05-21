/**

Does not support leap seconds!

*/
module sidero.base.datetime.time.timezone;
import sidero.base.datetime.calendars.gregorian;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.defs;
import sidero.base.errors;
import sidero.base.text;
import sidero.base.traits;
import sidero.base.allocators;
import sidero.base.attributes;
import sidero.base.path.file;

///
enum {
    ///
    NoTimeZoneDatabaseException = ErrorMessage("NTZDE", "Timezone database is missing, cannot lookup timezone"),
    ///
    NoTimeZoneException = ErrorMessage("NTZE",
            "Timezone requested does not exist, cannot look it up"),
    ///
    NoLocalYearException = ErrorMessage("NLYE",
            "Cannot lookup current year"),
}

export @safe nothrow @nogc:

///
struct TimeZone {
    package(sidero.base.datetime) @PrettyPrintIgnore {
        State* state;

        static struct State {
            shared(ptrdiff_t) refCount;
            RCAllocator allocator;

            String_UTF8 name;
            bool haveDaylightSavings;

            TimeZone.Source source;

            short fixedBias;
            WindowsTimeZoneBase windowsBase;
            IanaTZBase ianaTZBase;
            PosixTZBase posixTZBase;
        }

        enum Source {
            Fixed,
            Windows,
            IANA,
            PosixRule
        }

        void initialize(return scope RCAllocator allocator) scope @trusted nothrow @nogc {
            assert(this.state is null);

            if (allocator.isNull)
                allocator = globalAllocator();

            this.state = allocator.make!State(1, allocator);
            assert(!state.allocator.isNull);
        }
    }

export @safe nothrow @nogc:

    ///
    static immutable string DefaultFormat = "%e";

    ///
    this(return scope ref TimeZone other) scope @trusted {
        import sidero.base.internal.atomic;

        this.tupleof = other.tupleof;

        if (this.state !is null) {
            atomicIncrementAndLoad(this.state.refCount, 1);
            assert(!state.allocator.isNull);
        }
    }

    ///
    ~this() scope @trusted {
        import sidero.base.internal.atomic;

        if (this.state !is null) {
            assert(!state.allocator.isNull);

            if (atomicDecrementAndLoad(state.refCount, 1) == 0) {
                RCAllocator allocator = state.allocator;
                allocator.dispose(state);
            }
        }
    }

    ///
    bool isNull() scope const {
        return this.state is null;
    }

    ///
    void opAssign(return scope TimeZone other) scope @trusted {
        this.destroy;
        this.__ctor(other);
    }

    /// Either a Olson (IANA TZ) or platform specific name.
    String_UTF8 name() scope const return @trusted {
        if (isNull)
            return typeof(return).init;
        else
            return (cast(State*)state).name;
    }

    /// Get the name/abbreviation for a date/time, date aware
    String_UTF8 nameFor(scope DateTime!GregorianDate date) scope const @trusted {
        if (isNull)
            return String_UTF8("null");

        final switch (state.source) {
        case Source.Fixed:
            return (cast(State*)state).name;
        case Source.Windows:
            return this.isInDaylightSavings(date) ? (cast(State*)state).windowsBase.dstName : (cast(State*)state).windowsBase.stdName;
        case Source.IANA:
            auto unixTime = date.toUnixTime();
            assert(unixTime);

            return (cast(State*)state).ianaTZBase.nameFor(unixTime.get);
        case Source.PosixRule:
            return this.isInDaylightSavings(date) ? (cast(State*)state).posixTZBase.dstName : (cast(State*)state).posixTZBase.stdName;
        }
    }

    ///
    bool haveDaylightSavings() scope const {
        return isNull ? false : state.haveDaylightSavings;
    }

    ///
    bool isInDaylightSavings(scope DateTime!GregorianDate date) scope const @trusted {
        if (isNull)
            return false;

        final switch (state.source) {
        case Source.Fixed:
            return false;
        case Source.Windows:
            return (cast(State*)state).windowsBase.isInDaylightSavings(date);
        case Source.IANA:
            auto unixTime = date.toUnixTime();
            assert(unixTime);

            return (cast(State*)state).ianaTZBase.isInDST(unixTime.get);
        case Source.PosixRule:
            if (state.posixTZBase.dstName.isNull)
                return false;
            else
                return state.posixTZBase.isInDaylightSavings(date);
        }
    }

    ///
    long currentSecondsBias(scope DateTime!GregorianDate date) scope const @trusted {
        if (isNull)
            return 0;

        final switch (state.source) {
        case Source.Fixed:
            return state.fixedBias;
        case Source.Windows:
            return this.isInDaylightSavings(date) ? (cast(State*)state)
                .windowsBase.daylightSavingsOffset.seconds : (cast(State*)state).windowsBase.standardOffset.seconds;
        case Source.IANA:
            auto unixTime = date.toUnixTime(false);
            assert(unixTime);

            auto got = (cast(State*)state).ianaTZBase.secondsBias(unixTime, true);
            assert(got, got.getError().toString().unsafeGetLiteral);
            return got.get;
        case Source.PosixRule:
            return this.isInDaylightSavings(date) ? (cast(State*)state).posixTZBase.dstOffset : (cast(State*)state).posixTZBase.stdOffset;
        }
    }

    /// Get a version of this time zone for a given year, if available otherwise return this.
    TimeZone forYear(long year) return scope @trusted {
        mutex.pureLock;
        scope (exit)
            mutex.unlock;

        if (isNull)
            return this;

        final switch (state.source) {
        case Source.Fixed:
            return this;
        case Source.Windows:
            auto got = state.windowsBase.forYear(year);
            if (got)
                return got;
            else
                return this;
        case Source.IANA:
            auto got = (cast(State*)state).ianaTZBase.forYear(year);
            if (got)
                return got.get;
            else
                return this;
        case Source.PosixRule:
            return this;
        }
    }

    ///
    long totalLeapSeconds(long unixTime, bool hasLeap) scope const @trusted {
        if (isNull)
            return 0;

        long delta;

        final switch (state.source) {
        case Source.Fixed:
        case Source.Windows:
        case Source.PosixRule:
            return 0;

        case Source.IANA:
            foreach (leap; (cast(State*)state).ianaTZBase.tzFile.get.leapSecond) {
                if (hasLeap)
                    unixTime -= leap.amount;

                if (leap.appliesOn > unixTime)
                    break;

                delta += leap.amount;
            }
        }

        return delta;
    }

    ///
    long leapSecondsBetween(long startWithLeap, long endWithoutLeap) scope const @trusted {
        if (isNull)
            return 0;

        long delta;

        final switch (state.source) {
        case Source.Fixed:
        case Source.Windows:
        case Source.PosixRule:
            return 0;

        case Source.IANA:
            foreach (leap; (cast(State*)state).ianaTZBase.tzFile.get.leapSecond) {
                if (leap.appliesOn < startWithLeap) {
                    continue;
                } else if (endWithoutLeap >= leap.appliesOn)
                    break;

                delta += leap.amount;
                endWithoutLeap += delta;
            }
        }

        return delta;
    }

    ///
    bool opEquals(const TimeZone other) scope const @trusted {
        if (isNull)
            return other.isNull;
        else if (other.isNull)
            return false;

        if (state.source != other.state.source)
            return false;

        final switch (state.source) {
        case Source.Fixed:
            if (state.fixedBias != other.state.fixedBias)
                return false;
            break;
        case Source.Windows:
            if (state.windowsBase.standardOffset != other.state.windowsBase.standardOffset ||
                    state.haveDaylightSavings != other.state.haveDaylightSavings)
                return false;
            else if (state.haveDaylightSavings && state.windowsBase.daylightSavingsOffset != other.state.windowsBase.daylightSavingsOffset)
                return false;
            else
                break;
        case Source.IANA:
            if (state.ianaTZBase.startUnixTime != other.state.ianaTZBase.startUnixTime ||
                    state.ianaTZBase.endUnixTime != other.state.ianaTZBase.endUnixTime)
                return false;
            else if ((cast(State*)state).ianaTZBase.tzFile.region != (cast(State*)other.state).ianaTZBase.tzFile.region)
                return false;
            else
                break;
        case Source.PosixRule:
            return state.posixTZBase.stdOffset == other.state.posixTZBase.stdOffset &&
                state.posixTZBase.dstOffset == other.state.posixTZBase.dstOffset &&
                state.posixTZBase.transitionToStd == other.state.posixTZBase.transitionToStd &&
                state.posixTZBase.transitionToDST == other.state.posixTZBase.transitionToDST && (cast(State*)state)
                    .posixTZBase.stdName == (cast(State*)other.state).posixTZBase.stdName && (cast(State*)state)
                    .posixTZBase.dstName == (cast(State*)other.state).posixTZBase.dstName;
        }

        return (cast(State*)state).name.opEquals((cast(State*)other.state).name);
    }

    ///
    int opCmp(const TimeZone other) scope const @trusted {
        if (isNull)
            return other.isNull ? 0 : -1;
        else if (other.isNull)
            return 1;

        if (state.source < other.state.source)
            return -1;
        else if (state.source > other.state.source)
            return 1;

        final switch (state.source) {
        case Source.Fixed:
            if (state.fixedBias < other.state.fixedBias)
                return -1;
            else if (state.fixedBias > other.state.fixedBias)
                return 1;
            break;
        case Source.Windows:
            if (state.haveDaylightSavings && !other.state.haveDaylightSavings)
                return 1;
            else if (!state.haveDaylightSavings && other.state.haveDaylightSavings)
                return -1;

            if (state.windowsBase.standardOffset < other.state.windowsBase.standardOffset)
                return -1;
            else if (state.windowsBase.standardOffset > other.state.windowsBase.standardOffset)
                return 1;

            if (state.haveDaylightSavings) {
                if (state.windowsBase.daylightSavingsOffset < other.state.windowsBase.daylightSavingsOffset)
                    return -1;
                else if (state.windowsBase.daylightSavingsOffset > other.state.windowsBase.daylightSavingsOffset)
                    return 1;
            }

            break;
        case Source.IANA:
            if (state.ianaTZBase.startUnixTime < other.state.ianaTZBase.startUnixTime ||
                    state.ianaTZBase.endUnixTime < other.state.ianaTZBase.endUnixTime)
                return -1;
            else if (state.ianaTZBase.startUnixTime > other.state.ianaTZBase.startUnixTime ||
                    state.ianaTZBase.endUnixTime > other.state.ianaTZBase.endUnixTime)
                return 1;
            int temp = (cast(State*)state).ianaTZBase.tzFile.region.opCmp((cast(State*)other.state).ianaTZBase.tzFile.region);
            if (temp != 0)
                return temp;
            else
                break;
        case Source.PosixRule:
            if (state.posixTZBase.stdOffset < other.state.posixTZBase.stdOffset ||
                    state.posixTZBase.dstOffset < other.state.posixTZBase.dstOffset ||
                    state.posixTZBase.transitionToStd < other.state.posixTZBase.transitionToStd ||
                    state.posixTZBase.transitionToDST < other.state.posixTZBase.transitionToDST || (cast(State*)state)
                        .posixTZBase.stdName < (cast(State*)other.state).posixTZBase.stdName || (cast(State*)state)
                        .posixTZBase.dstName < (cast(State*)other.state).posixTZBase.dstName)
                return -1;
            else if (state.posixTZBase.stdOffset > other.state.posixTZBase.stdOffset ||
                    state.posixTZBase.dstOffset > other.state.posixTZBase.dstOffset ||
                    state.posixTZBase.transitionToStd > other.state.posixTZBase.transitionToStd ||
                    state.posixTZBase.transitionToDST > other.state.posixTZBase.transitionToDST || (cast(State*)state)
                        .posixTZBase.stdName > (cast(State*)other.state).posixTZBase.stdName || (cast(State*)state)
                        .posixTZBase.dstName > (cast(State*)other.state).posixTZBase.dstName)
                return 1;
            else
                break;
        }

        return (cast(State*)state).name.opCmp((cast(State*)other.state).name);
    }

    ///
    String_UTF8 toString() scope const @trusted {
        StringBuilder_UTF8 ret;
        toString(ret);
        return ret.asReadOnly;
    }

    ///
    void toString(Builder)(scope ref Builder sink) scope const if (isBuilderString!Builder) {
        this.format(sink, DefaultFormat);
    }

    ///
    StringBuilder_UTF8 format(FormatString)(scope FormatString specification, bool usePercentageEscape = true) scope const
            if (isSomeString!FormatString) {
        StringBuilder_UTF8 ret;
        this.format(ret, specification, usePercentageEscape);
        return ret;
    }

    ///
    StringBuilder_UTF8 format(FormatChar)(scope String_UTF!FormatChar specification, bool usePercentageEscape = true) scope const {
        StringBuilder_UTF8 ret;
        this.format(ret, specification, usePercentageEscape);
        return ret;
    }

    ///
    void format(Builder, FormatString)(scope ref Builder builder, scope FormatString specification, bool usePercentageEscape = true) scope const @trusted
            if (isBuilderString!Builder && isSomeString!FormatString) {
        this.format(builder, String_UTF!(Builder.Char)(specification), usePercentageEscape);
    }

    /**
     See: https://www.php.net/manual/en/datetime.format.php

     Note: Only e aka Olson aka IANA TZ identifier is implemented here. T aka abbreviations are not included, so cannot be provided here.
     */
    void format(Builder, Format)(scope ref Builder builder, scope Format specification, bool usePercentageEscape = true) scope const @trusted
            if (isBuilderString!Builder && isReadOnlyString!Format) {
        import sidero.base.allocators;

        if (builder.isNull)
            builder = typeof(builder)(globalAllocator());

        bool isEscaped;

        if (usePercentageEscape) {
            foreach (c; specification.byUTF32()) {
                if (isEscaped) {
                    isEscaped = false;
                    if (this.formatValue(builder, c))
                        continue;
                } else if (c == '%') {
                    isEscaped = true;
                    continue;
                }

                builder ~= [c];
            }
        } else {
            foreach (c; specification.byUTF32()) {
                if (isEscaped) {
                    isEscaped = false;
                } else if (c == '\\') {
                    isEscaped = true;
                    continue;
                } else if (this.formatValue(builder, c)) {
                    continue;
                }

                builder ~= [c];
            }
        }
    }

    /// Ditto
    bool formatValue(Builder)(scope ref Builder builder, dchar specification) scope const @trusted
            if (isBuilderString!Builder) {
        switch (specification) {
        case 'e':
            builder ~= this.name();
            break;

        default:
            return false;
        }

        return true;
    }

    ///
    bool formattedWrite(scope ref StringBuilder_ASCII builder, scope FormatSpecifier format, bool usePercentageEscape = true) @safe nothrow @nogc {
        return false;
    }

    ///
    bool formattedWrite(scope ref StringBuilder_UTF8 builder, scope FormatSpecifier format, bool usePercentageEscape = true) @safe nothrow @nogc {
        if (format.fullFormatSpec.length == 0)
            return false;

        this.format(builder, format.fullFormatSpec);
        return true;
    }

    ///
    static bool parse(Input)(scope ref Input input, scope ref TimeZone output, scope String_UTF8 specification,
            bool usePercentageEscape = true) {
        if (specification.length == 0)
            return false;
        bool isEscaped;

        if (usePercentageEscape) {
            foreach (c; specification.byUTF32()) {
                if (isEscaped) {
                    isEscaped = false;
                    if (output.parseValue(input, c))
                        continue;
                } else if (c == '%') {
                    isEscaped = true;
                    continue;
                }

                static if (isASCII!Input) {
                    if (c >= 128 || !input.startsWith([c]))
                        return false;
                } else {
                    if (!input.startsWith([c]))
                        return false;
                }

                input.popFront;
            }
        } else {
            foreach (c; specification.byUTF32()) {
                if (isEscaped) {
                    isEscaped = false;
                } else if (c == '\\') {
                    isEscaped = true;
                    continue;
                } else if (output.parseValue(input, c)) {
                    continue;
                }

                static if (isASCII!Input) {
                    if (c >= 128 || !input.startsWith([c]))
                        return false;
                } else {
                    if (!input.startsWith([c]))
                        return false;
                }

                input.popFront;
            }
        }

        input = input.save;
        return true;
    }

    ///
    bool parseValue(Input)(scope ref Input input, dchar specification) @trusted {
        switch (specification) {
        case 'e':
            // Windows maxes out at 3 spaces, so we'll check up to 4
            // IANA has no spaces

            size_t lastLength;
            bool gotIt;

            foreach (_; 0 .. 4) {
                ptrdiff_t index = input[lastLength .. $].indexOf(" "c);

                Input sliced;
                if (index < 0)
                    sliced = input.save;
                else
                    sliced = input[0 .. index];

                lastLength = sliced.length + 1;
                sliced = sliced.stripLeft;

                if (sliced.length > 0) {
                    static if (isBuilderString!Input) {
                        auto got = TimeZone.from(sliced.asReadOnly());
                    } else {
                        auto got = TimeZone.from(sliced);
                    }

                    if (got) {
                        this = got.get;
                        gotIt = true;
                    }
                }

                if (lastLength >= input.length)
                    break;
            }

            return gotIt;
        default:
            return false;
        }
    }

    ///
    static bool formattedRead(Input)(scope ref Input input, scope ref TimeZone output, scope FormatSpecifier format) {
        return parse(input, output, format.fullFormatSpec);
    }

    ///
    static Result!TimeZone local() @trusted {
        import sidero.base.datetime.cldr;
        import sidero.base.system : EnvironmentVariables;
        import sidero.base.datetime.time.clock;

        mutex.pureLock;

        {
            auto tzVar = EnvironmentVariables[String_UTF8("TZ\0")];

            if (tzVar.length > 0) {
                auto got = parsePosixTZ(tzVar);

                if (got) {
                    if (got.loadFromFile) {
                        // well... this is at least in theory easy
                        // we don't actually support loading from a specific file
                        //  since internally we need the Olson name, and guess what a TZif doesn't include?
                        //  yup, a Olson name.
                    } else {
                        TimeZone ret;
                        ret.initialize(RCAllocator.init);
                        ret.state.source = Source.PosixRule;
                        ret.state.posixTZBase = got.get;

                        mutex.unlock;
                        return ret;
                    }
                } else {
                    // try to load via IANA tz or Windows
                    mutex.unlock;

                    auto got2 = TimeZone.from(tzVar, currentYear());
                    if (got2) {
                        return got2;
                    } else
                        mutex.pureLock;
                }
            }
        }

        version (Windows) {
            auto got = localWindowsTimeZone();

            // if we are prefering IANA TZ database over Windows internal one,
            //  attempt to use it first.
            if (useIANA) {
                auto stdName = got.stdName;
                stdName.stripZeroTerminator;

                auto ianaName = windowsToIANA(cast(string)stdName.unsafeGetLiteral);

                if (ianaName.length > 0) {
                    auto got2 = findIANATimeZone(String_UTF8(ianaName));

                    if (got2) {
                        auto got3 = got2.forYear(currentYear());
                        mutex.unlock;
                        return got3;
                    }
                }
            }

            auto got2 = got.forYear(currentYear());
            mutex.unlock;
            return got2;
        } else version (Posix) {
            auto posixLocalTimeZone = getPosixLocalTimeZone();
            auto got = findIANATimeZone(posixLocalTimeZone);

            if (!got) {
                mutex.unlock;
                return typeof(return)(got.getError);
            }

            auto got2 = got.forYear(currentYear());
            mutex.unlock;
            return got2;
        } else
            static assert(0, "Getting local timezone unimplemented for platform");

        assert(0);
    }

    /// Supports Windows and IANA names
    static Result!TimeZone from(scope String_UTF8.LiteralType wantedName) {
        import sidero.base.datetime.time.clock;

        scope String_UTF8 tempWanted;
        tempWanted.__ctor(wantedName);
        return from(tempWanted, currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF16.LiteralType wantedName) {
        import sidero.base.datetime.time.clock;

        scope String_UTF16 tempWanted;
        tempWanted.__ctor(wantedName);
        return from(tempWanted, currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF32.LiteralType wantedName) {
        import sidero.base.datetime.time.clock;

        scope String_UTF32 tempWanted;
        tempWanted.__ctor(wantedName);
        return from(tempWanted, currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_ASCII wantedName) @trusted {
        import sidero.base.datetime.time.clock;

        return from(String_UTF8(cast(string)wantedName.unsafeGetLiteral), currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF8 wantedName) {
        import sidero.base.datetime.time.clock;

        return from(wantedName, currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF16 wantedName) {
        import sidero.base.datetime.time.clock;

        return from(wantedName, currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF32 wantedName) {
        import sidero.base.datetime.time.clock;

        return from(wantedName, currentYear());
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF8.LiteralType wantedName, long year) {
        scope String_UTF8 tempWanted;
        tempWanted.__ctor(wantedName);
        return from(tempWanted, year);
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF16.LiteralType wantedName, long year) {
        scope String_UTF16 tempWanted;
        tempWanted.__ctor(wantedName);
        return from(tempWanted, year);
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF32.LiteralType wantedName, long year) {
        scope String_UTF32 tempWanted;
        tempWanted.__ctor(wantedName);
        return from(tempWanted, year);
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF8 wantedName, long year) @trusted {
        import sidero.base.datetime.cldr;

        mutex.pureLock;

        scope (exit)
            mutex.unlock;

        {
            String_UTF8 ianaName = wantedName;

            version (Windows) {
                // if we are prefering IANA TZ database over Windows internal one,
                //  attempt to use it first.
                if (useIANA) {
                    String_UTF8 stdName = wantedName;
                    if (!stdName.isPtrNullTerminated || stdName.isEncodingChanged)
                        stdName = stdName.dup;

                    stdName.stripZeroTerminator;
                    auto ianaName2 = windowsToIANA(cast(string)stdName.unsafeGetLiteral);

                    if (ianaName2.length > 0)
                        ianaName = String_UTF8(ianaName);
                }
            }

            auto got = findIANATimeZone(ianaName);
            if (got)
                return got.forYear(year);
            else version (Posix) {
                return typeof(return)(got.getError);
            }
        }

        version (Windows) {
            auto got = findWindowsTimeZone(wantedName);
            if (!got)
                return typeof(return)(got.getError);
            return got.forYear(year);
        } else version (Posix) {
        } else
            static assert(0, "Getting local timezone unimplemented for platform");
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF16 wantedName, long year) @trusted {
        return TimeZone.from(wantedName.byUTF8, year);
    }

    /// Ditto
    static Result!TimeZone from(scope String_UTF32 wantedName, long year) @trusted {
        return TimeZone.from(wantedName.byUTF8, year);
    }

    /// Ditto
    static Result!TimeZone from(String)(scope String wantedName, long year) @trusted if (isSomeString!String) {
        return TimeZone.from(String_UTF8(wantedName), year);
    }

    /// Seconds bias (UTC-1:30 would be -5400).
    static TimeZone from(long seconds, return scope RCAllocator allocator = RCAllocator.init) @trusted {
        TimeZone ret;
        ret.initialize(allocator);
        ret.state.fixedBias = cast(short)seconds;

        {
            StringBuilder_UTF8 builder;
            builder ~= "UTC";
            builder ~= seconds < 0 ? "-"c : "+"c;

            TimeOfDay tod = TimeOfDay(0, 0, 0);
            tod.advanceSeconds(seconds < 0 ? -seconds : seconds);

            builder.formattedWrite("{:s}", tod.hour);

            if (tod.minute > 0) {
                builder.formattedWrite("{:s}", tod.minute);
            }

            //ret.state.name = builder.asReadOnly;
            ret.state.source = Source.Fixed;
        }

        return ret;
    }

    /// Load the IANA database for a given path, will detect Android zone file
    static void loadIANADatabase(scope FilePath path = FilePath.init) @trusted {
        mutex.pureLock;
        useIANA = loadAutoIANA(path);
        mutex.unlock;
    }
}

pragma(crt_destructor) extern (C) void uninitializeTimeZoneDatabase() {
    import sidero.base.datetime.time.internal.iana : uninitializeIANATZ;

    version (Windows) {
        import sidero.base.datetime.time.internal.windows : unitializeWindowsTZ;

        unitializeWindowsTZ;
    }

    uninitializeIANATZ;
}

private:
import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;
import sidero.base.datetime.time.internal.iana;
import sidero.base.datetime.time.internal.posix;
import sidero.base.datetime.time.internal.windows;

__gshared {
    TestTestSetLockInline mutex;
    // on Windows this will force new loads to use the IANA TZ database for entries instead.
    bool useIANA;
}
