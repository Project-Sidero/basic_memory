module sidero.base.datetime.time.timeofday;
import sidero.base.datetime.calendars.defs;
import sidero.base.datetime.duration;
import sidero.base.text;
import sidero.base.traits;
import sidero.base.attributes;

/// Time of day has a lot more concensus on how to represent it. So we'll go with that.
struct TimeOfDay {
    private @PrettyPrintIgnore {
        ubyte hour_, minute_, second_;
        uint nanoSeconds_;
    }

export @safe nothrow @nogc:

    ///
    static immutable string DefaultFormat = "%H:%i:%s.%V", ISOFormat = "%H%i%s", ISOExtFormat = "%H:%i:%s";

    ///
    this(long nanoSeconds) scope {
        this.advanceMicroSeconds(nanoSeconds / 1_000);
    }

    ///
    this(ubyte hour, ubyte minute, ubyte second, long msec = 0) scope {
        this.advanceMicroSeconds(msec);
        this.advanceSeconds(second);
        this.advanceMinutes(minute);
        this.advanceHours(hour);
    }

    ///
    uint nanoSecond() scope const {
        return this.nanoSeconds_;
    }

    ///
    uint microSecond() scope const {
        return this.nanoSeconds_ / 1_000;
    }

    ///
    uint milliSecond() scope const {
        return this.nanoSeconds_ / 1_000_000;
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
    long totalNanoSeconds() scope const {
        long working = this.hour_;

        working *= 60;
        working += this.minute_;

        working *= 60;
        working += this.second_;

        working *= 1_000_000_000;
        working += this.nanoSeconds_;

        return working;
    }

    ///
    long totalMicroSeconds() scope const {
        long working = this.hour_;

        working *= 60;
        working += this.minute_;

        working *= 60;
        working += this.second_;

        working *= 1_000_000;
        working += this.nanoSeconds_ / 1_000;

        return working;
    }

    ///
    long totalMilliSeconds() scope const {
        long working = this.hour_;

        working *= 60;
        working += this.minute_;

        working *= 60;
        working += this.second_;

        working *= 1_000;
        working += this.nanoSeconds_ / 1_000_000;

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
    Duration advance(const Duration interval, bool allowOverflow = true) scope {
        return advanceNanoSeconds(interval.totalNanoSeconds) + interval.days.days;
    }

    ///
    Duration advanceNanoSeconds(long amount, bool allowOverflow = true) scope {
        amount += this.nanoSeconds_;
        long rollDays, rollHours, rollMinutes, rollSeconds;

        if(allowOverflow) {
            enum DayToNano = 86_400_000_000_000;
            enum HourToNano = 3_600_000_000_000;
            enum MinuteToNano = 60_000_000_000;
            enum SecondToNano = 1_000_000_000;

            rollDays = amount / DayToNano;
            amount -= rollDays * DayToNano;

            rollHours = amount / HourToNano;
            amount -= rollHours * HourToNano;

            rollMinutes = amount / MinuteToNano;
            amount -= rollMinutes * MinuteToNano;

            rollSeconds = amount / SecondToNano;
            amount -= rollSeconds * SecondToNano;
        } else {
            amount %= 1_000_000_000;
        }

        if(amount < 0)
            amount += 1_000_000_000;

        this.nanoSeconds_ += amount;

        if(allowOverflow) {
            return rollDays.days + this.advanceHours(rollHours) + this.advanceMinutes(rollMinutes) + this.advanceSeconds(rollSeconds);
        } else
            return Duration.zero;
    }

    ///
    Duration advanceMicroSeconds(long amount, bool allowOverflow = true) scope {
        return this.advanceNanoSeconds(amount * 1_000, allowOverflow);
    }

    ///
    unittest {
        assert(TimeOfDay(0, 0, 0, -58_752_000_010).totalMicroSeconds() == 31_308_999_990);
        assert(TimeOfDay(0, 0, 0, 58_752_000_010).totalMicroSeconds() == 58_752_000_010);
    }

    ///
    Duration advanceSeconds(long amount, bool allowOverflow = true) scope {
        amount += this.second_;
        long rollMinutes;

        if(allowOverflow) {
            rollMinutes = amount / 60;
            amount -= rollMinutes * 60;
        } else {
            amount %= 60;
        }

        if(amount < 0)
            amount += 60;

        this.second_ = cast(ubyte)amount;

        if(allowOverflow)
            return this.advanceMinutes(rollMinutes, allowOverflow);
        else
            return Duration.zero;
    }

    ///
    Duration advanceMinutes(long amount, bool allowOverflow = true) scope {
        amount += this.minute_;
        long rollHours;

        if(allowOverflow) {
            rollHours = amount / 60;
            amount -= rollHours * 60;
        } else {
            amount %= 60;
        }

        if(amount < 0)
            amount += 60;

        this.minute_ = cast(ubyte)amount;

        if(allowOverflow)
            return this.advanceHours(rollHours, allowOverflow);
        else
            return Duration.zero;
    }

    ///
    Duration advanceHours(long amount, bool allowOverflow = true) scope {
        amount += this.hour_;
        long rollDays;

        if(allowOverflow) {
            rollDays = amount / 24;
            amount -= rollDays * 24;
        } else {
            amount %= 24;
        }

        if(amount < 0)
            amount += 24;

        this.hour_ = cast(ubyte)amount;
        return rollDays.days;
    }

    ///
    Duration opBinary(string op : "-")(const TimeOfDay other) scope const {
        long a = this.totalMicroSeconds(), b = other.totalMicroSeconds();
        return (a - b).microSeconds;
    }

    ///
    bool opEquals(const TimeOfDay other) scope const {
        return this.second_ == other.second_ && this.minute_ == other.minute_ && this.hour_ == other.hour_;
    }

    ///
    int opCmp(const TimeOfDay other) scope const {
        if(this.hour_ < other.hour_)
            return -1;
        else if(this.hour_ > other.hour_)
            return 1;

        if(this.minute_ < other.minute_)
            return -1;
        else if(this.minute_ > other.minute_)
            return 1;

        if(this.second_ < other.second_)
            return -1;
        else if(this.second_ > other.second_)
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
    StringBuilder_UTF8 format(FormatString)(scope FormatString specification, bool usePercentageEscape = true) scope const
            if (isSomeString!FormatString || isReadOnlyString!FormatString) {
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

     Note: B aka Swatch Internet time requires a timezone, so cannot be computed here.

     Supports V for nano seconds, unlike PHP's DateTime class.
     */
    void format(Builder, Format)(scope ref Builder builder, scope Format specification, bool usePercentageEscape = true) scope const @trusted
            if (isBuilderString!Builder && isReadOnlyString!Format) {
        import sidero.base.allocators;

        if(builder.isNull)
            builder = typeof(builder)(globalAllocator());

        bool isEscaped;

        if(usePercentageEscape) {
            foreach(c; specification.byUTF32()) {
                if(isEscaped) {
                    isEscaped = false;
                    if(this.formatValue(builder, c))
                        continue;
                } else if(c == '%') {
                    isEscaped = true;
                    continue;
                }

                builder ~= [c];
            }
        } else {
            foreach(c; specification.byUTF32()) {
                if(isEscaped) {
                    isEscaped = false;
                } else if(c == '\\') {
                    isEscaped = true;
                    continue;
                } else if(this.formatValue(builder, c)) {
                    continue;
                }

                builder ~= [c];
            }
        }
    }

    /// Ditto
    bool formatValue(Builder)(scope ref Builder builder, dchar specification) scope const if (isBuilderString!Builder) {
        import writer = sidero.base.text.format.write;

        switch(specification) {
        case 'a':
            builder ~= this.isAM() ? "am" : "pm";
            break;

        case 'A':
            builder ~= this.isAM() ? "AM" : "PM";
            break;

            //case 'B':

        case 'g':
            auto actual = this.hour_ % 12;
            writer.formattedWrite(builder, "{:s}", actual);
            break;

        case 'G':
            writer.formattedWrite(builder, "{:s}", this.hour_);
            break;

        case 'h':
            auto actual = this.hour_ % 12;
            if(actual < 10)
                builder ~= "0"c;
            writer.formattedWrite(builder, "{:s}", actual);
            break;

        case 'H':
            if(this.hour_ < 10)
                builder ~= "0"c;
            writer.formattedWrite(builder, "{:s}", this.hour_);
            break;

        case 'i':
            if(this.minute_ < 10)
                builder ~= "0"c;
            writer.formattedWrite(builder, "{:s}", this.minute_);
            break;

        case 's':
            if(this.second_ < 10)
                builder ~= "0"c;
            writer.formattedWrite(builder, "{:s}", this.second_);
            break;

        case 'u':
            // micro seconds
            auto msec = this.nanoSeconds_ / 1_000;

            if(msec < 10)
                builder ~= "00000"c;
            else if(msec < 100)
                builder ~= "0000";
            else if(msec < 1000)
                builder ~= "000";
            else if(msec < 10_000)
                builder ~= "00";
            else if(msec < 100_000)
                builder ~= "0";
            writer.formattedWrite(builder, "{:s}", msec);
            break;

        case 'v':
            // milli seconds
            const working = this.nanoSeconds_ / 1_000_000;

            if(working < 10)
                builder ~= "00"c;
            else if(working < 100)
                builder ~= "0";

            writer.formattedWrite(builder, "{:s}", working);
            break;

        case 'V':
            writer.formattedWrite(builder, "{:s}", this.nanoSeconds_);
            break;

        default:
            return false;
        }

        return true;
    }

    ///
    bool formattedWrite(scope ref StringBuilder_ASCII builder, scope FormatSpecifier format) @safe nothrow @nogc {
        return false;
    }

    ///
    bool formattedWrite(scope ref StringBuilder_UTF8 builder, scope FormatSpecifier format) @safe nothrow @nogc {
        if(format.fullFormatSpec.length == 0)
            return false;

        this.format(builder, format.fullFormatSpec);
        return true;
    }

    ///
    static bool parse(Input)(scope ref Input input, scope ref Duration output, scope String_UTF8 specification,
            bool usePercentageEscape = true) {
        if(specification.length == 0)
            return false;
        bool isEscaped;

        if(usePercentageEscape) {
            foreach(c; specification.byUTF32()) {
                if(isEscaped) {
                    isEscaped = false;
                    if(output.parseValue(input, c))
                        continue;
                } else if(c == '%') {
                    isEscaped = true;
                    continue;
                }

                static if(isASCII!Input) {
                    if(c >= 128 || !input.startsWith([c]))
                        return false;
                } else {
                    if(!input.startsWith([c]))
                        return false;
                }

                input.popFront;
            }
        } else {
            foreach(c; specification.byUTF32()) {
                if(isEscaped) {
                    isEscaped = false;
                } else if(c == '\\') {
                    isEscaped = true;
                    continue;
                } else if(output.parseValue(input, c)) {
                    continue;
                }

                static if(isASCII!Input) {
                    if(c >= 128 || !input.startsWith([c]))
                        return false;
                } else {
                    if(!input.startsWith([c]))
                        return false;
                }

                input.popFront;
            }
        }

        input = input.save;
        return true;
    }

    ///
    bool parseValue(Input)(scope ref Input input, dchar specification) {
        import reader = sidero.base.text.format.read;

        Input input2;
        long hour, minute, second, nanoSecs;

        switch(specification) {
        case 'a':
            if(input.startsWith("am")) {
                if(this.hour_ >= 12)
                    this.hour_ -= 12;
                input = input[2 .. $];
                return true;
            } else if(input.startsWith("pm")) {
                if(this.hour_ < 12)
                    this.hour_ += 12;
                input = input[2 .. $];
                return true;
            } else
                return false;
        case 'A':
            if(input.startsWith("AM")) {
                if(this.hour_ >= 12)
                    this.hour_ -= 12;
                input = input[2 .. $];
                return true;
            } else if(input.startsWith("PM")) {
                if(this.hour_ < 12)
                    this.hour_ += 12;
                input = input[2 .. $];
                return true;
            } else
                return false;

        case 'g':
        case 'h':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), hour) && hour < 12 && hour >= 0) {
                input = input2;
                this.hour_ = cast(ubyte)hour;
                return true;
            } else
                return false;
        case 'G':
        case 'H':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), hour) && hour < 24 && hour >= 0) {
                input = input2;
                this.hour_ = cast(ubyte)hour;
                return true;
            } else
                return false;

        case 'm':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), minute) && minute < 60 && minute >= 0) {
                input = input2;
                this.minute_ = cast(ubyte)minute;
                return true;
            } else
                return false;

        case 's':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), second) && second < 60 && second >= 0) {
                input = input2;
                this.second_ = cast(ubyte)second;
                return true;
            } else
                return false;

        case 'u':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), nanoSecs) && nanoSecs < 1_000_000 && nanoSecs >= 0) {
                input = input2;
                this.advanceNanoSeconds(cast(uint)(nanoSecs * 1_000));
                return true;
            } else
                return false;

        case 'v':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), nanoSecs) && nanoSecs < 1_000 && nanoSecs >= 0) {
                input = input2;
                this.advanceNanoSeconds(nanoSecs * 1_000_000);
                return true;
            } else
                return false;

        case 'V':
            input2 = input.save;
            if(cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), nanoSecs) && nanoSecs < 100 && nanoSecs >= 0) {
                input = input2;
                this.nanoSeconds_ = cast(uint)nanoSecs;
                return true;
            } else
                return false;

        default:
            return false;
        }
    }

    ///
    static bool formattedRead(Input)(scope ref Input input, scope ref TimeOfDay output, scope FormatSpecifier format) {
        return parse(input, output, format.fullFormatSpec);
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
