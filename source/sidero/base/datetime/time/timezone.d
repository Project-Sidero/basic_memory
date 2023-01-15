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

        Bias standardOffset_, daylightSavingsOffset_;
        String_UTF8 standardName_, daylightSavingsName_, ianaName_;
        bool haveDaylightSavings_;

        Source source;
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
    String_UTF8 standardName() scope const return @trusted {
        return (cast(TimeZone)this).standardName_;
    }

    ///
    String_UTF8 daylightSavingsName() scope const return @trusted {
        return (cast(TimeZone)this).daylightSavingsName_;
    }

    ///
    String_UTF8 ianaName() scope const return @trusted {
        return (cast(TimeZone)this).ianaName();
    }

    ///
    bool haveDaylightSavings() scope const {
        return haveDaylightSavings_;
    }

    ///
    bool isInDaylightSavings(scope DateTime!GregorianDate date) scope const @trusted {
        if (!this.haveDaylightSavings || this.daylightSavingsOffset_.appliesOn < date)
            return false;
        else if (this.standardOffset_.appliesOn > this.daylightSavingsOffset_.appliesOn)
            return this.standardOffset_.appliesOn > date;
        else {
            auto next = (cast(TimeZone)this).forYear(standardOffset_.appliesOn.year + 1);
            return date < next.standardOffset_.appliesOn;
        }
    }

    ///
    long currentSecondsBias(scope DateTime!GregorianDate date) scope const {
        return isInDaylightSavings(date) ? this.daylightSavingsOffset_.seconds : this.standardOffset_.seconds;
    }

    /// Get a version of this time zone for a given year, if available otherwise return this.
    TimeZone forYear(long year) scope @trusted {
        // TODO
        /+TimeZone attempt = TimeZone.from(this.ianaName_, year);

        if (!attempt.isNull)
            return attempt;
        return this;+/
        assert(0);
    }

    ///
    bool opEquals(const TimeZone other) scope const @trusted {
        if (standardOffset_ != other.standardOffset_ || (haveDaylightSavings_ && daylightSavingsOffset_ != other.daylightSavingsOffset_))
            return false;

        return (cast(TimeZone)this).ianaName_.opEquals((cast(TimeZone)other).ianaName_);
    }

    ///
    int opCmp(const TimeZone other) scope const @trusted {
        if (standardOffset_ < other.standardOffset_)
            return -1;
        else if (standardOffset_ > other.standardOffset_)
            return 1;

        if (haveDaylightSavings_) {
            if (daylightSavingsOffset_ < other.daylightSavingsOffset_)
                return -1;
            else if (daylightSavingsOffset_ > other.daylightSavingsOffset_)
                return 1;
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
        ret.standardOffset_.seconds = cast(short)seconds;

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

    ///
    static struct Bias {
        ///
        long seconds;
        /// If there is no daylight savings time, this shouldn't be populated!
        GregorianDate appliesOnDate;
        /// Ditto
        TimeOfDay appliesOnTime;

    export @safe nothrow @nogc:

        ///
        bool opEquals(const Bias other) scope const {
            return this.tupleof == other.tupleof;
        }

        ///
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

/// Unfortunately this can't be in Bias due to forward referencing issues.
DateTime!GregorianDate appliesOn(scope const TimeZone.Bias bias) {
    return typeof(return)(bias.appliesOnDate, bias.appliesOnTime);
}

private:
import sidero.base.parallelism.mutualexclusion : TestTestSetLockInline;

__gshared {
    TestTestSetLockInline mutex;
    bool useWindows, useIANA, usePosix;
}
