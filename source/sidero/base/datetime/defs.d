module sidero.base.datetime.defs;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.defs;
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

// TODO: TIME ZONES

///
struct DateTime(DateType) {
    private {
        TimeOfDay time_;
    }

    static string DefaultFormat = DateType.DefaultFormat ~ " " ~ TimeOfDay.DefaultFormat;

    ///
    DateType.DateWrapper date;
    ///
    alias date this;

export @safe nothrow @nogc:

    ///
    this(DateType date) scope {
        this.date = typeof(this.date)(date);
    }

    ///
    this(TimeOfDay time) scope {
        this.time_ = time;
    }

    ///
    this(DateType date, TimeOfDay time) scope {
        this.date = typeof(this.date)(date);
        this.time_ = time;
    }

    //

    ///
    TimeOfDay time() scope const {
        return this.time_;
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
    static DateTime fromUnixTime(ulong amount) {
        DateTime ret = DateTime(DateType.UnixEpoch);
        ret.advanceSeconds(amount);
        return ret;
    }

    //

    ///
    bool opEquals(const DateTime other) scope const {
        return this.time_ == other.time_ && this.date == other.date;
    }

    ///
    int opCmp(const DateTime other) scope const {
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
                // TODO: } else if (c == 'B') {
                // TODO: } else if (this.timezone_.formatValue(builder, c)) {
                // TODO: } else if (c == 'c') {
                // TODO: } else if (c == 'r') {
                // TODO: } else if (c == 'U') {
            } else if (this.date.formatValue(builder, c)) {
            } else {
                typeof(c)[1] str = [c];
                builder ~= str;
            }
        }
    }
}
