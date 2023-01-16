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

///
enum {
    ///
    NoTimeZoneDatabaseException = ErrorMessage("NTZDE", "Timezone database is missing, cannot lookup timezone"),
    ///
    NoTimeZoneException = ErrorMessage("NTZE", "Timezone requested does not exist, cannot look it up"),
}

export @safe nothrow @nogc:

///
struct TimeZone {
    package(sidero.base.datetime) {
        // FIXME: heap allocate all of this state!
        import sidero.base.datetime.time.internal.iana;
        import sidero.base.datetime.time.internal.posix;
        import sidero.base.datetime.time.internal.windows;

        String_UTF8 ianaName_;
        bool haveDaylightSavings_;

        Source source;
        short fixedBias;
        WindowsTimeZoneBase windowsBase;
        IanaTZBase ianaTZBase;

        enum Source {
            NotSet,
            Fixed,
            Windows,
            IANA,
            PosixRule
        }
    }

    ///
    static string DefaultFormat = "e";

export @safe nothrow @nogc:

    ///
    bool isNull() scope const {
        return this.source == Source.NotSet;
    }

    ///
    void opAssign(scope return TimeZone other) scope @trusted {
        this.tupleof = other.tupleof;
    }

    ///
    this(scope return ref TimeZone other) scope return {
        this.tupleof = other.tupleof;
    }

    ///
    String_UTF8 ianaName() scope const return @trusted {
        return (cast(TimeZone)this).ianaName_;
    }

    ///
    bool haveDaylightSavings() scope const {
        return haveDaylightSavings_;
    }

    ///
    bool isInDaylightSavings(scope DateTime!GregorianDate date) scope const @trusted {
        mutex.pureLock;
        scope (exit)
            mutex.unlock;

        final switch (source) {
        case Source.NotSet:
            return false;
        case Source.Fixed:
            return false;
        case Source.Windows:
            return (cast(TimeZone)this).windowsBase.isInDaylightSavings(date);
        case Source.IANA:
            assert(0); // TODO
        case Source.PosixRule:
            assert(0); // TODO
        }
    }

    /// Get the name/abbreviation for a date/time
    String_UTF8 nameFor(scope DateTime!GregorianDate date) scope const @trusted {
        final switch (source) {
        case Source.NotSet:
            return String_UTF8("not-set");
        case Source.Fixed:
            return (cast(TimeZone)this).ianaName_;
        case Source.Windows:
            return this.isInDaylightSavings(date) ? (cast(TimeZone)this).windowsBase.dstName
                : (cast(TimeZone)this).windowsBase.stdName;
        case Source.IANA:
            assert(0); // TODO
        case Source.PosixRule:
            assert(0); // TODO
        }
    }

    ///
    long currentSecondsBias(scope DateTime!GregorianDate date) scope const @trusted {
        final switch (source) {
        case Source.NotSet:
        case Source.Fixed:
            return this.fixedBias;
        case Source.Windows:
            return this.isInDaylightSavings(date) ? (cast(TimeZone)this)
                .windowsBase.daylightSavingsOffset.seconds : (cast(TimeZone)this).windowsBase.standardOffset.seconds;
        case Source.IANA:
            assert(0); // TODO
        case Source.PosixRule:
            assert(0); // TODO
        }
    }

    /// Get a version of this time zone for a given year, if available otherwise return this.
    TimeZone forYear(long year) scope @trusted {
        mutex.pureLock;
        scope (exit)
            mutex.unlock;

        final switch (source) {
        case Source.NotSet:
            return this;
        case Source.Fixed:
            return this;
        case Source.Windows:
            auto got = this.windowsBase.forYear(year);
            if (got)
                return got;
            else
                return this;
        case Source.IANA:
            assert(0); // TODO
        case Source.PosixRule:
            assert(0); // TODO
        }
    }

    ///
    bool opEquals(const TimeZone other) scope const @trusted {
        if (this.source != other.source)
            return false;

        final switch (source) {
        case Source.NotSet:
        case Source.Fixed:
            if (this.fixedBias != other.fixedBias)
                return false;
            break;
        case Source.Windows:
            if (this.windowsBase.standardOffset != other.windowsBase.standardOffset ||
                    this.haveDaylightSavings_ != other.haveDaylightSavings_)
                return false;
            else if (this.haveDaylightSavings_ && this.windowsBase.daylightSavingsOffset != other.windowsBase.daylightSavingsOffset)
                return false;
            else
                break;
        case Source.IANA:
            assert(0); // TODO
        case Source.PosixRule:
            assert(0); // TODO
        }

        return (cast(TimeZone)this).ianaName_.opEquals((cast(TimeZone)other).ianaName_);
    }

    ///
    int opCmp(const TimeZone other) scope const @trusted {
        if (this.source < other.source)
            return -1;
        else if (this.source > other.source)
            return 1;

        final switch (source) {
        case Source.NotSet:
        case Source.Fixed:
            if (this.fixedBias < other.fixedBias)
                return -1;
            else if (this.fixedBias > other.fixedBias)
                return 1;
            break;
        case Source.Windows:
            if (this.haveDaylightSavings_ && !other.haveDaylightSavings_)
                return 1;
            else if (!this.haveDaylightSavings_ && other.haveDaylightSavings_)
                return -1;

            if (this.windowsBase.standardOffset < other.windowsBase.standardOffset)
                return -1;
            else if (this.windowsBase.standardOffset > other.windowsBase.standardOffset)
                return 1;

            if (this.haveDaylightSavings_) {
                if (this.windowsBase.daylightSavingsOffset < other.windowsBase.daylightSavingsOffset)
                    return -1;
                else if (this.windowsBase.daylightSavingsOffset > other.windowsBase.daylightSavingsOffset)
                    return 1;
            }

            break;
        case Source.IANA:
            assert(0); // TODO
        case Source.PosixRule:
            assert(0); // TODO
        }

        return (cast(TimeZone)this).ianaName_.opCmp((cast(TimeZone)other).ianaName_);
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
    StringBuilder_UTF8 format(FormatString)(scope FormatString specification) scope const if (isSomeString!FormatString) {
        StringBuilder_UTF8 ret;
        this.format(ret, specification);
        return ret;
    }

    ///
    StringBuilder_UTF8 format(FormatChar)(scope String_UTF!FormatChar specification) scope const {
        StringBuilder_UTF8 ret;
        this.format(ret, specification);
        return ret;
    }

    ///
    void format(Builder, FormatString)(scope ref Builder builder, scope FormatString specification) scope const @trusted
            if (isBuilderString!Builder && isSomeString!FormatString) {
        this.format(builder, String_UTF!(Builder.Char)(specification));
    }

    /**
     See: https://www.php.net/manual/en/datetime.format.php

     Note: Only e aka IANA identifier is implemented here. T aka abbreviations are not included, so cannot be provided here.
     */
    void format(Builder, Format)(scope ref Builder builder, scope Format specification) scope const @trusted
            if (isBuilderString!Builder && isReadOnlyString!Format) {
        import sidero.base.allocators;

        if (builder.isNull)
            builder = typeof(builder)(globalAllocator());

        bool isEscaped;

        foreach (c; specification.byUTF32()) {
            if (isEscaped) {
                typeof(c)[1] str = [c];
                builder ~= str;
                isEscaped = false;
            } else if (c == '\\') {
                isEscaped = true;
            } else if (this.formatValue(builder, c)) {
            } else {
                typeof(c)[1] str = [c];
                builder ~= str;
            }
        }
    }

    /// Ditto
    bool formatValue(Builder)(scope ref Builder builder, dchar specification) scope const @trusted
            if (isBuilderString!Builder) {
        switch (specification) {
        case 'e':
            builder ~= this.ianaName();
            break;

        default:
            return false;
        }

        return true;
    }

    version (none) {
        ///
        static Result!TimeZone local() @trusted {
            mutex.pureLock;
            auto ret = localTimeZone;

            mutex.unlock;
            return ret;
        }

        /// Supports Windows and IANA names
        static Result!TimeZone from(scope String_UTF8 wantedName, long year) @trusted {
            mutex.pureLock;

            auto ret = getTimeZone(wantedName, year);
            ret.isSet_ = true;

            mutex.unlock;
            return ret;
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
    }

    /// Seconds bias (UTC-1:30 would be -5400).
    static TimeZone from(long seconds) @trusted {
        TimeZone ret;
        ret.fixedBias = cast(short)seconds;

        {
            StringBuilder_UTF8 builder;
            builder ~= "UTC";
            builder ~= seconds < 0 ? "-"c : "+"c;

            TimeOfDay tod = TimeOfDay(0, 0, 0);
            tod.advanceSeconds(seconds < 0 ? -seconds : seconds);

            builder.formattedWrite("%s", tod.hour);

            if (tod.minute > 0) {
                builder.formattedWrite(":%s", tod.minute);
            }

            ret.ianaName_ = builder.asReadOnly;
            ret.source = Source.Fixed;
        }

        return ret;
    }
}

private:
import sidero.base.parallelism.mutualexclusion : TestTestSetLockInline;

__gshared {
    TestTestSetLockInline mutex;
    bool useWindows, useIANA, usePosix;
}
