module sidero.base.datetime.defs;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.defs;
import sidero.base.datetime.calendars.defs;
import sidero.base.text;
import sidero.base.traits;

private {
    import sidero.base.datetime.calendars.gregorian;

    alias GDateTime = DateTime!GregorianDate;
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
        // TODO: Format!!!!
    }
}
