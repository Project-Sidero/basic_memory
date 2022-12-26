module sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.defs;
import sidero.base.datetime.calendars.defs;
import sidero.base.text;
import sidero.base.traits;

/// Time of day has a lot more concensus on how to represent it. So we'll go with that.
struct TimeOfDay {
    private {
        ubyte hour_, minute_, second_;
        uint msec_;
    }

export @safe nothrow @nogc:

    ///
    static string DefaultFormat = "H:i:s.u", ISOFormat = "His", ISOExtFormat = "H:i:s";

    ///
    this(ubyte hour, ubyte minute, ubyte second = 0, long msec = 0) scope {
        this.advanceMicroSeconds(msec);
        this.advanceSeconds(second);
        this.advanceMinutes(minute);
        this.advanceHours(hour);
    }

    ///
    uint microSecond() scope const {
        return this.msec_;
    }

    ///
    ubyte second() scope const {
        return this.second_;
    }

    ///
    ubyte minute() scope const {
        return this.minute_;
    }

    ///
    ubyte hour() scope const {
        return this.hour_;
    }

    ///
    bool isAM() scope const {
        return this.hour_ < 12;
    }

    ///
    bool isPM() scope const {
        return this.hour_ >= 12;
    }

    ///
    long totalMicroSeconds() scope const {
        long working = this.hour_;

        working *= 60;
        working += this.minute_;

        working *= 60;
        working += this.second_;

        working *= 1_000_000;
        working += this.msec_;

        return working;
    }

    ///
    uint totalSeconds() scope const {
        uint working = this.hour_;

        working *= 60;
        working += this.minute_;

        working *= 60;
        working += this.second_;

        return working;
    }

    ///
    uint totalMinutes() scope const {
        uint working = this.hour_;

        working *= 60;
        working += this.minute_;

        return working;
    }

    ///
    DayInterval advanceMicroSeconds(const MicroSecondInterval interval, bool allowOverflow = true) scope {
        return advanceMicroSeconds(interval.amount);
    }

    ///
    DayInterval advanceMicroSeconds(long amount, bool allowOverflow = true) scope {
        amount += this.msec_;
        long rollDays, rollHours, rollMinutes, rollSeconds;

        if (allowOverflow) {
            enum DayToMicro = 86_400_000_000;
            enum HourToMicro = 3_600_000_000;
            enum MinuteToMicro = 60_000_000;
            enum SecondToMicro = 100_00_00;

            rollDays = amount / DayToMicro;
            amount -= rollDays * DayToMicro;

            rollHours = amount / HourToMicro;
            amount -= rollHours * HourToMicro;

            rollMinutes = amount / MinuteToMicro;
            amount -= rollMinutes * MinuteToMicro;

            rollSeconds = amount / SecondToMicro;
            amount -= rollSeconds * SecondToMicro;
        } else {
            amount %= 1_000_000;
        }

        if (amount < 0)
            amount += 1_000_000;

        this.msec_ = cast(uint)amount;

        if (allowOverflow) {
            DayInterval ret = DayInterval(rollDays);

            ret.amount += this.advanceHours(rollHours).amount;
            ret.amount += this.advanceMinutes(rollMinutes).amount;
            ret.amount += this.advanceSeconds(rollSeconds).amount;

            return ret;
        } else
            return DayInterval(0);
    }

    ///
    unittest {
        assert(TimeOfDay(0, 0, 0, -58_752_000_010).totalMicroSeconds() == 31_308_999_990);
        assert(TimeOfDay(0, 0, 0, 58_752_000_010).totalMicroSeconds() == 58_752_000_010);
    }

    ///
    DayInterval advanceSeconds(long amount, bool allowOverflow = true) scope {
        amount += this.second_;
        long rollMinutes;

        if (allowOverflow) {
            rollMinutes = amount / 60;
            amount -= rollMinutes * 60;
        } else {
            amount %= 60;
        }

        if (amount < 0)
            amount += 60;

        this.second_ = cast(ubyte)amount;

        if (allowOverflow)
            return this.advanceMinutes(rollMinutes, allowOverflow);
        else
            return DayInterval(0);
    }

    ///
    DayInterval advanceMinutes(long amount, bool allowOverflow = true) scope {
        amount += this.minute_;
        long rollHours;

        if (allowOverflow) {
            rollHours = amount / 60;
            amount -= rollHours * 60;
        } else {
            amount %= 60;
        }

        if (amount < 0)
            amount += 60;

        this.minute_ = cast(ubyte)amount;

        if (allowOverflow)
            return this.advanceHours(rollHours, allowOverflow);
        else
            return DayInterval(0);
    }

    ///
    DayInterval advanceHours(long amount, bool allowOverflow = true) scope {
        amount += this.hour_;
        long rollDays;

        if (allowOverflow) {
            rollDays = amount / 24;
            amount -= rollDays * 24;
        } else {
            amount %= 24;
        }

        if (amount < 0)
            amount += 24;

        this.hour_ = cast(ubyte)amount;
        return DayInterval(rollDays);
    }

    ///
    MicroSecondInterval opBinary(string op : "-")(const TimeOfDay other) scope const {
        long a = this.totalMicroSeconds(), b = other.totalMicroSeconds();
        return MicroSecondInterval(a - b);
    }

    ///
    bool opEquals(const TimeOfDay other) scope const {
        return this.second_ == other.second_ && this.minute_ == other.minute_ && this.hour_ == other.hour_;
    }

    ///
    int opCmp(const TimeOfDay other) scope const {
        if (this.hour_ < other.hour_)
            return -1;
        else if (this.hour_ > other.hour_)
            return 1;

        if (this.minute_ < other.minute_)
            return -1;
        else if (this.minute_ > other.minute_)
            return 1;

        if (this.second_ < other.second_)
            return -1;
        else if (this.second_ > other.second_)
            return 1;

        return 0;
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

     Note: B aka Swatch Internet time requires a timezone, so cannot be computed here.
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
                continue;
            }

            switch (c) {
            case 'a':
                builder ~= this.isAM() ? "am" : "pm";
                break;

            case 'A':
                builder ~= this.isAM() ? "AM" : "PM";
                break;

                //case 'B':

            case 'g':
                auto actual = this.hour_ % 12;
                builder.formattedWrite("%s", actual);
                break;

            case 'G':
                builder.formattedWrite("%s", this.hour_);
                break;

            case 'h':
                auto actual = this.hour_ % 12;
                if (actual < 10)
                    builder ~= "0"c;
                builder.formattedWrite("%s", actual);
                break;

            case 'H':
                if (this.hour_ < 10)
                    builder ~= "0"c;
                builder.formattedWrite("%s", this.hour_);
                break;

            case 'i':
                if (this.minute_ < 10)
                    builder ~= "0"c;
                builder.formattedWrite("%s", this.minute_);
                break;

            case 's':
                if (this.second_ < 10)
                    builder ~= "0"c;
                builder.formattedWrite("%s", this.second_);
                break;

            case 'u':
                if (this.msec_ < 10)
                    builder ~= "00000"c;
                else if (this.msec_ < 100)
                    builder ~= "0000";
                else if (this.msec_ < 1000)
                    builder ~= "000";
                else if (this.msec_ < 10_000)
                    builder ~= "00";
                else if (this.msec_ < 100_000)
                    builder ~= "0";
                builder.formattedWrite("%s", this.msec_);
                break;

            case 'v':
                const working = this.msec_ / 1000;

                if (working < 10)
                    builder ~= "00"c;
                else if (working < 100)
                    builder ~= "0";

                builder.formattedWrite("%s", working);
                break;

            case '\\':
                isEscaped = true;
                break;

            default:
                typeof(c)[1] str = [c];
                builder ~= str;
                break;
            }
        }
    }

    /// midnight
    static TimeOfDay min() {
        return TimeOfDay(0, 0, 0, 0);
    }

    /// 1 second before midnight
    static TimeOfDay max() {
        return TimeOfDay(23, 59, 59, 999_999);
    }
}
