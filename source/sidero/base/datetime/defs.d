module sidero.base.datetime.defs;
import sidero.base.datetime.time.defs;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.timezone;
import sidero.base.datetime.calendars.defs;
import sidero.base.text;
import sidero.base.traits;
import sidero.base.errors;

private {
    import sidero.base.datetime.calendars.gregorian;

    alias GDateTime = DateTime!GregorianDate;
}

///
enum {
    ///
    BeforeUnixEpochException = ErrorMessage("CUEE", "Time is before Unix epoch"),
    ///
    MissingUnixEpochException = ErrorMessage("MUEE", "Date type doesn't implement Unix epoch, is it representable?"),
}

///
struct DateTime(DateType) {
    private {
        TimeOfDay time_;
        TimeZone timezone_;
    }

    ///
    static string DefaultFormat = DateType.DefaultFormat ~ " " ~ TimeOfDay.DefaultFormat, ATOMFormat = "Y-m-d\\TH:i:sP",
        COOKIEFormat = "l, d-M-Y H:i:s T",
        ISO8601Format = "Y-m-d\\TH:i:sO",
        ISO8601_EXPANDEDFormat = "X-m-d\\TH:i:sP", RFC822Format = "D, d M y H:i:s O", RFC850Format = "l, d-M-y H:i:s T",
        RFC1036Format = "D, d M y H:i:s O", RFC1123Format = "D, d M Y H:i:s O",
        RFC7231Format = "D, d M Y H:i:s \\G\\M\\T", RFC2822Format = "D, d M Y H:i:s O",
        RFC3339Format = "Y-m-d\\TH:i:sP", RFC3339ExtendedFormat = "Y-m-d\\TH:i:s.vP", RSSFormat = "D, d M Y H:i:s O",
        W3CFormat = "Y-m-d\\TH:i:sP";

    ///
    DateType.DateWrapper date;
    ///
    alias date this;

export @safe nothrow @nogc:

    ///
    this(scope ref DateTime other) scope {
        this.tupleof = other.tupleof;
    }

    ///
    this(scope DateType date) scope {
        this.date = typeof(this.date)(date);
    }

    ///
    this(scope TimeOfDay time) scope {
        this.time_ = time;
    }

    ///
    this(scope DateType date, scope TimeOfDay time, scope TimeZone timezone = TimeZone.init) scope {
        this.date = typeof(this.date)(date);
        this.time_ = time;
        this.timezone_ = timezone;
    }

    /// Does not adjust date/time into timezone!
    this(scope DateTime datetime, scope TimeZone timezone) scope {
        this.date = datetime.date;
        this.time_ = datetime.time_;
        this.timezone_ = timezone;
    }

    //

    ///
    TimeOfDay time() scope const {
        return this.time_;
    }

    ///
    TimeZone time() scope @trusted {
        return this.timezone_;
    }

    ///
    uint microSecond() scope const {
        return this.time_.microSecond();
    }

    ///
    ubyte second() scope const {
        return this.time_.second();
    }

    ///
    ubyte minute() scope const {
        return this.time_.minute();
    }

    ///
    ubyte hour() scope const {
        return this.time_.hour();
    }

    ///
    bool isAM() scope const {
        return this.time_.isAM();
    }

    ///
    bool isPM() scope const {
        return this.time_.isPM();
    }

    ///
    long totalMicroSeconds() scope const {
        return this.time_.totalMicroSeconds();
    }

    ///
    uint totalSeconds() scope const {
        return this.time_.totalSeconds();
    }

    ///
    uint totalMinutes() scope const {
        return this.time_.totalMinutes();
    }

    ///
    void advanceMicroSeconds(const MicroSecondInterval interval) scope {
        this.advanceMicroSeconds(interval.amount);
    }

    ///
    void advanceMicroSeconds(long amount) scope {
        auto dateInterval = this.time_.advanceMicroSeconds(amount, true);
        this.date.advanceDays(dateInterval.amount);
    }

    ///
    void advanceSeconds(long amount) scope {
        auto dateInterval = this.time_.advanceSeconds(amount, true);
        this.date.advanceDays(dateInterval.amount);
    }

    ///
    void advanceMinutes(long amount) scope {
        auto dateInterval = this.time_.advanceMinutes(amount, true);
        this.date.advanceDays(dateInterval.amount);
    }

    ///
    void advanceHours(long amount) scope {
        auto dateInterval = this.time_.advanceHours(amount, true);
        this.date.advanceDays(dateInterval.amount);
    }

    /// If current time zone not set, it'll just add it without adjustment.
    DateTime asTimeZone(scope TimeZone timezone) scope const {
        // FIXME
        assert(0);
    }

    ///
    Result!ulong toUnixTime() scope const {
        static if (!__traits(hasMember, DateType, "UnixEpoch")) {
            return typeof(return)(MissingUnixEpochException);
        } else {
            DayInterval days = this.date - DateType.UnixEpoch;

            // FIXME: REMOVE timezone!
            long working = days.amount * 86_400;
            working += this.time_.totalSeconds;

            if (days.amount < 0 || working < 0)
                return typeof(return)(BeforeUnixEpochException);

            return typeof(return)(cast(ulong)working);
        }
    }

    ///
    static DateTime fromUnixTime(ulong amount, TimeZone asTimeZone = TimeZone.init) {
        DateTime ret = DateTime(DateType.UnixEpoch);
        ret.advanceSeconds(amount);

        // FIXME: timezone!

        return ret;
    }

    //

    ///
    bool opEquals(scope const DateTime other) scope const {
        return this.time_ == other.time_ && this.date == other.date;
    }

    ///
    int opCmp(scope const DateTime other) scope const {
        const ret = this.date.opCmp(other.date);

        if (ret != 0)
            return ret;
        else
            return this.time_.opCmp(other.time_);
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

     Note: Implements I, O, P, p, T, Z, c, r, U. Defers everything else to respective type
     */
    void format(Builder, Format)(scope ref Builder builder, scope Format specification) scope const 
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
            } else if (this.time_.formatValue(builder, c)) {
            } else if (c == 'B') {
                // TODO: swatch time
                // calculated from UTC+1
                // ((3600 * h) + (60 * m)) / 86.4
            } else if (this.timezone_.formatValue(builder, c)) {
            } else if (c == 'I') {
                // TODO: is in daylight savings time
            } else if (c == 'O') {
                // TODO: +0200
            } else if (c == 'P') {
                // TODO: +02:00
            } else if (c == 'p') {
                // TODO: P but return Z for 0
            } else if (c == 'T') {
                // TODO: timezone offset like P
                // like O except can elide minutes if zero
            } else if (c == 'Z') {
                // TODO: timezone bias in seconds
                // 5 digit without + only -
            } else if (c == 'c') {
                // TODO: ISO8601 date
            } else if (c == 'r') {
                // TODO: ISO2822 date
            } else if (c == 'U') {
                // TODO: unix time
            } else if (this.date.formatValue(builder, c)) {
            } else {
                typeof(c)[1] str = [c];
                builder ~= str;
            }
        }
    }
}
