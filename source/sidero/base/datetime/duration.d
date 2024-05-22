module sidero.base.datetime.duration;
import sidero.base.text;
import sidero.base.traits;
import sidero.base.attributes;

export @safe nothrow @nogc:

///
struct Duration {
    private @PrettyPrintIgnore {
        enum NanoSecondsInDay = 24 * 60 * 60 * 1_000_000_000L;
        long days_;
        long nanoSeconds_;
    }

export @safe nothrow @nogc:

    ///
    static immutable string DefaultFormat = "%a", HumanDeltaFormat = "%D";

    ///
    this(long day, long nanoSecond) pure {
        Duration temp = day.days + nanoSecond.nanoSeconds;
        days_ = temp.days_;
        nanoSeconds_ = temp.nanoSeconds_;
    }

    ///
    long days() scope const pure {
        return this.days_;
    }

    ///
    long nanoSeconds() scope const pure {
        return this.nanoSeconds_ - (this.totalMicroSeconds * 1_000);
    }

    ///
    long microSeconds() scope const pure {
        return (this.nanoSeconds_ - (this.totalMilliSeconds * 1_000_000)) / 1_000;
    }

    ///
    long milliSeconds() scope const pure {
        return (this.nanoSeconds_ - (this.totalSeconds * 1_000_000_000)) / 1_000_000;
    }

    ///
    long seconds() scope const pure {
        return (this.nanoSeconds_ - (this.totalMinutes * 60_000_000_000)) / 1_000_000_000;
    }

    ///
    long minutes() scope const pure {
        return (this.nanoSeconds_ - (this.totalHours * 3_600_000_000_000)) / 60_000_000_000;
    }

    ///
    long hours() scope const pure {
        return this.nanoSeconds_ / 3_600_000_000_000;
    }

    ///
    long totalNanoSeconds() scope const pure {
        return this.nanoSeconds_;
    }

    ///
    long totalMicroSeconds() scope const pure {
        return this.nanoSeconds_ / 1_000;
    }

    ///
    long totalMilliSeconds() scope const pure {
        return this.nanoSeconds_ / 1_000_000;
    }

    ///
    long totalSeconds() scope const pure {
        return this.nanoSeconds_ / 1_000_000_000;
    }

    ///
    long totalMinutes() scope const pure {
        return this.nanoSeconds_ / 60_000_000_000;
    }

    ///
    long totalHours() scope const pure {
        return this.nanoSeconds_ / 3_600_000_000_000;
    }

    ///
    Duration opUnary(string op : "-")() scope const pure {
        Duration temp = this;
        temp.days_ *= -1;
        temp.nanoSeconds_ *= -1;

        return temp;
    }

    ///
    Duration opBinary(string op : "+")(scope const Duration other) scope const pure {
        Duration temp = this;

        temp.days_ += other.days_;
        temp.nanoSeconds_ += other.nanoSeconds_;

        while (temp.nanoSeconds_ <= -NanoSecondsInDay) {
            temp.nanoSeconds_ -= NanoSecondsInDay;
            temp.days_--;
        }

        while (temp.nanoSeconds_ >= NanoSecondsInDay) {
            temp.nanoSeconds_ -= NanoSecondsInDay;
            temp.days_++;
        }

        return temp;
    }

    ///
    Duration opBinary(string op : "-")(scope const Duration other) scope const pure {
        Duration temp = other;
        temp.days_ *= -1;
        temp.nanoSeconds_ *= -1;

        return this + temp;
    }

    ///
    void opOpAssign(string op : "+")(scope const Duration other) scope pure {
        this = this + other;
    }

    ///
    void opOpAssign(string op : "-")(scope const Duration other) scope {
        this = this - other;
    }

    ///
    bool opEquals(scope const Duration other) scope const pure {
        return this.days_ == other.days_ && this.nanoSeconds_ == other.nanoSeconds_;
    }

    ///
    int opCmp(scope const Duration other) scope const pure {
        if (this.days_ < other.days_)
            return -1;
        else if (this.days_ > other.days_)
            return 1;

        if (this.nanoSeconds_ < other.nanoSeconds_)
            return -1;
        else if (this.nanoSeconds_ > other.nanoSeconds_)
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

    /// Supports R(sign +/-), r(sign +), d(ays), h(ours), m(inutes), s(econds), i(milliseconds), u(microseconds), n(anoseconds), a(daptive), Human D(elta)
    StringBuilder_UTF8 format(FormatString)(scope FormatString specification, bool usePercentageEscape = true) scope const
            if (isSomeString!FormatString) {
        StringBuilder_UTF8 ret;
        this.format(ret, specification, usePercentageEscape);
        return ret;
    }

    /// Ditto
    StringBuilder_UTF8 format(FormatChar)(scope String_UTF!FormatChar specification, bool usePercentageEscape = true) scope const {
        StringBuilder_UTF8 ret;
        this.format(ret, specification, usePercentageEscape);
        return ret;
    }

    /// Ditto
    void format(Builder, FormatString)(scope ref Builder builder, scope FormatString specification, bool usePercentageEscape = true) scope const @trusted
            if (isBuilderString!Builder && isSomeString!FormatString) {
        this.format(builder, String_UTF!(Builder.Char)(specification), usePercentageEscape);
    }

    /// Ditto
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
    bool formatValue(Builder)(scope ref Builder builder, dchar specification) scope const if (isBuilderString!Builder) {
        import writer = sidero.base.text.format.write;

        switch (specification) {
        case 'R':
            if (this.days_ < 0 || this.nanoSeconds_ < 0)
                builder ~= "-";
            else
                builder ~= "+";
            break;
        case 'r':
            if (this.days_ < 0 || this.nanoSeconds_ < 0)
                builder ~= "-";
            break;

        case 'a':
            if (this.days_ != long.min && (this.days_ < 0 || this.nanoSeconds_ < 0))
                builder ~= "-";

            auto days = this.days, hours = this.hours, minutes = this.minutes, seconds = this.seconds,
                milliSecs = this.milliSeconds, microSecs = this.microSeconds, nanoSecs = this.nanoSeconds;

            if (days < 0)
                days *= -1;
            if (hours < 0)
                hours *= -1;
            if (minutes < 0)
                minutes *= -1;
            if (seconds < 0)
                seconds *= -1;
            if (milliSecs < 0)
                milliSecs *= -1;
            if (microSecs < 0)
                microSecs *= -1;
            if (nanoSecs < 0)
                nanoSecs *= -1;

            bool gotOne;

            if (days != 0) {
                gotOne = true;
                writer.formattedWrite(builder, "{:s} days", days);
            }

            if (hours != 0) {
                if (gotOne)
                    builder ~= " ";
                gotOne = true;
                writer.formattedWrite(builder, "{:s} hours", hours);
            }

            if (minutes != 0) {
                if (gotOne)
                    builder ~= " ";
                gotOne = true;
                writer.formattedWrite(builder, "{:s} minutes", minutes);
            }

            if (seconds != 0) {
                if (gotOne)
                    builder ~= " ";
                gotOne = true;
                writer.formattedWrite(builder, "{:s} seconds", seconds);
            }

            if (milliSecs != 0) {
                if (gotOne)
                    builder ~= " ";
                gotOne = true;
                writer.formattedWrite(builder, "{:s} milliseconds", milliSecs);
            }

            if (microSecs != 0) {
                if (gotOne)
                    builder ~= " ";
                gotOne = true;
                writer.formattedWrite(builder, "{:s} microseconds", microSecs);
            }

            if (nanoSecs != 0) {
                if (gotOne)
                    builder ~= " ";
                gotOne = true;
                writer.formattedWrite(builder, "{:s} nanoseconds", nanoSecs);
            }

            if (!gotOne) {
                builder ~= "0";
            }
            break;

        case 'd':
            writer.formattedWrite(builder, "{:s}", this.days_ < 0 ? -this.days_ : this.days_);
            break;

        case 'h':
            auto hours = this.hours;
            writer.formattedWrite(builder, "{:s}", hours < 0 ? -hours : hours);
            break;
        case 'm':
            auto minutes = this.minutes;
            writer.formattedWrite(builder, "{:s}", minutes < 0 ? -minutes : minutes);
            break;
        case 's':
            auto seconds = this.seconds;
            writer.formattedWrite(builder, "{:s}", seconds < 0 ? -seconds : seconds);
            break;
        case 'i':
            auto milliSecs = this.milliSeconds;
            writer.formattedWrite(builder, "{:s}", milliSecs < 0 ? -milliSecs : milliSecs);
            break;
        case 'u':
            auto microSecs = this.microSeconds;
            writer.formattedWrite(builder, "{:s}", microSecs < 0 ? -microSecs : microSecs);
            break;
        case 'n':
            auto nanoSecs = this.nanoSeconds;
            writer.formattedWrite(builder, "{:s}", nanoSecs < 0 ? -nanoSecs : nanoSecs);
            break;

        case 'D':
            const years = cast(long)(this.days_ / 365.25);

            if (years != 0) {
                if (this.days_ < 0)
                    writer.formattedWrite(builder, "{:s} years ago", -years);
                else
                    writer.formattedWrite(builder, "in {:s} years", years);
            } else if (this.days_ != 0) {
                if (this.days_ < 0)
                    writer.formattedWrite(builder, "{:s} days ago", -this.days_);
                else
                    writer.formattedWrite(builder, "in {:s} days", this.days_);
            } else {
                auto hours = this.hours;
                auto minutes = this.minutes;

                if (hours != 0) {
                    if (this.nanoSeconds_ < 0)
                        writer.formattedWrite(builder, "{:s} hours ago", -hours);
                    else
                        writer.formattedWrite(builder, "in {:s} hours", hours);
                } else if (minutes != 0) {
                    if (this.nanoSeconds_ < 0)
                        writer.formattedWrite(builder, "{:s} minutes ago", -minutes);
                    else
                        writer.formattedWrite(builder, "in {:s} minutes", minutes);
                } else if (this.nanoSeconds_ < 0) {
                    builder ~= "less than a minute ago";
                } else {
                    builder ~= "in less than a minute";
                }
            }
            break;

        default:
            return false;
        }

        return true;
    }

    ///
    unittest {
        assert(.days(2922).format(HumanDeltaFormat) == "in 8 years");
        assert(.days(-1461).format(HumanDeltaFormat) == "4 years ago");
        assert(.days(8L).format(HumanDeltaFormat) == "in 8 days");
        assert(.days(-5L).format(HumanDeltaFormat) == "5 days ago");
        assert(.hours(3).format(HumanDeltaFormat) == "in 3 hours");
        assert(.hours(-2).format(HumanDeltaFormat) == "2 hours ago");
        assert(.minutes(5).format(HumanDeltaFormat) == "in 5 minutes");
        assert(.minutes(-6).format(HumanDeltaFormat) == "6 minutes ago");
        assert(.seconds(32).format(HumanDeltaFormat) == "in less than a minute");
        assert(.seconds(-21).format(HumanDeltaFormat) == "less than a minute ago");
    }

    ///
    bool formattedWrite(scope ref StringBuilder_ASCII builder, scope FormatSpecifier format) @safe nothrow @nogc {
        return false;
    }

    ///
    bool formattedWrite(scope ref StringBuilder_UTF8 builder, scope FormatSpecifier format) @safe nothrow @nogc {
        if (format.fullFormatSpec.length == 0)
            return false;

        this.format(builder, format.fullFormatSpec);
        return true;
    }

    ///
    static bool parse(Input)(scope ref Input input, scope ref Duration output, scope String_UTF8 specification,
            bool usePercentageEscape = true) {
        if (specification.length == 0)
            return false;
        bool isEscaped, negate;

        if (usePercentageEscape) {
            foreach (c; specification.byUTF32()) {
                if (isEscaped) {
                    isEscaped = false;
                    if (output.parseValue(input, negate, c))
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
                } else if (output.parseValue(input, negate, c)) {
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

        if (negate)
            output = -output;
        input = input.save;
        return true;
    }

    private bool parseValue(Input)(scope ref Input input, scope ref bool negate, dchar specification) {
        import reader = sidero.base.text.format.read;

        long days, hours, minutes, seconds, milliSecs, microSecs, nanoSecs;
        Input input2;
        bool gotOne;

        switch (specification) {
        case 'R':
            if (input.startsWith("-"c))
                negate = true;
            else if (input.startsWith("+"c))
                negate = false;
            else
                return false;

            input.popFront;
            return true;
        case 'r':
            if (input.startsWith("-"c)) {
                negate = true;
                input.popFront;
            }
            return true;

        case 'a':
            if (input.startsWith("-"c)) {
                negate = true;
                input.popFront;
            }
            break;
        default:
            break;
        }

        switch (specification) {
        case 'a':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} days"), days)) {
                gotOne = true;
                input = input2;
            } else
                days = 0;

            input2 = input.save.stripLeft;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} hours"), hours)) {
                gotOne = true;
                input = input2;
            } else
                hours = 0;

            input2 = input.save.stripLeft;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} minutes"), minutes)) {
                gotOne = true;
                input = input2;
            } else
                minutes = 0;

            input2 = input.save.stripLeft;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} seconds"), seconds)) {
                gotOne = true;
                input = input2;
            } else
                seconds = 0;

            input2 = input.save.stripLeft;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} milliseconds"), milliSecs)) {
                gotOne = true;
                input = input2;
            } else
                milliSecs = 0;

            input2 = input.save.stripLeft;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} microseconds"), microSecs)) {
                gotOne = true;
                input = input2;
            } else
                microSecs = 0;

            input2 = input.save.stripLeft;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} nanoseconds"), nanoSecs)) {
                gotOne = true;
                input = input2;
            } else
                nanoSecs = 0;

            if (!gotOne && input.stripLeft.startsWith("0")) {
                input.popFront;
                gotOne = true;
            }

            if (gotOne)
                this += .days(days) + .hours(hours) + .minutes(minutes) + .seconds(seconds) + .milliSeconds(
                        milliSecs) + .microSeconds(microSecs) + .nanoSeconds(nanoSecs);
            return gotOne;

        case 'd':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), days)) {
                gotOne = true;
                input = input2;
            }

            if (days < 0) {
                days *= -1;
                negate = true;
            }

            if (gotOne)
                this += .days(days);
            return gotOne;

        case 'h':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), hours)) {
                gotOne = true;
                input = input2;
            }

            if (hours < 0) {
                hours *= -1;
                negate = true;
            }

            if (gotOne)
                this += .hours(hours);
            return gotOne;
        case 'm':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), minutes)) {
                gotOne = true;
                input = input2;
            }

            if (minutes < 0) {
                minutes *= -1;
                negate = true;
            }

            if (gotOne)
                this += .minutes(minutes);
            return gotOne;
        case 's':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), seconds)) {
                gotOne = true;
                input = input2;
            }

            if (seconds < 0) {
                seconds *= -1;
                negate = true;
            }

            if (gotOne)
                this += .seconds(seconds);
            return gotOne;
        case 'i':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), milliSecs)) {
                gotOne = true;
                input = input2;
            }

            if (milliSecs < 0) {
                milliSecs *= -1;
                negate = true;
            }

            if (gotOne)
                this += .milliSeconds(milliSecs);
            return gotOne;
        case 'u':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), microSecs)) {
                gotOne = true;
                input = input2;
            }

            if (microSecs < 0) {
                microSecs *= -1;
                negate = true;
            }

            if (gotOne)
                this += .microSeconds(microSecs);
            return gotOne;
        case 'n':
            input2 = input.save;
            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), nanoSecs)) {
                gotOne = true;
                input = input2;
            }

            if (nanoSecs < 0) {
                nanoSecs *= -1;
                negate = true;
            }

            if (gotOne)
                this += .nanoSeconds(nanoSecs);
            return gotOne;

        case 'D':
            long years;

            {
                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} years ago"), years)) {
                    gotOne = true;
                    input = input2;

                    days = cast(long)(years * 365.25);
                    negate = true;
                    goto DoneD;
                }

                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("in {:d} years"), years)) {
                    gotOne = true;
                    input = input2;

                    days = cast(long)(years * 365.25);
                    goto DoneD;
                }
            }

            {
                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} days ago"), days)) {
                    gotOne = true;
                    input = input2;

                    negate = true;
                    goto DoneD;
                }

                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("in {:d} days"), days)) {
                    gotOne = true;
                    input = input2;
                    goto DoneD;
                }
            }

            {
                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} hours ago"), hours)) {
                    gotOne = true;
                    input = input2;

                    negate = true;
                    goto DoneD;
                }

                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("in {:d} hours"), hours)) {
                    gotOne = true;
                    input = input2;
                    goto DoneD;
                }
            }

            {
                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d} minutes ago"), minutes)) {
                    gotOne = true;
                    input = input2;

                    negate = true;
                    goto DoneD;
                }

                input2 = input.save;
                if (cast(bool)reader.formattedRead(input2, String_UTF8("in {:d} minutes"), minutes)) {
                    gotOne = true;
                    input = input2;
                    goto DoneD;
                }
            }

            {
                if (input.startsWith("less than a minute ago")) {
                    gotOne = true;
                    input = input["less than a minute ago".length .. $];

                    seconds = 30;
                    negate = true;
                    goto DoneD;
                } else if (input.startsWith("in less than a minute")) {
                    gotOne = true;
                    input = input["in less than a minute".length .. $];

                    seconds = 30;
                    goto DoneD;
                }
            }

        DoneD:
            if (days < 0)
                days *= -1;
            if (hours < 0)
                hours *= -1;
            if (minutes < 0)
                minutes *= -1;
            if (seconds < 0)
                seconds *= -1;

            if (gotOne)
                this += .days(days) + .hours(hours) + .minutes(minutes) + .seconds(seconds);
            return gotOne;

        default:
            return false;
        }
    }

    ///
    static bool formattedRead(Input)(scope ref Input input, scope ref Duration output, scope FormatSpecifier format) {
        return parse(input, output, format.fullFormatSpec);
    }

    ///
    static Duration zero() pure {
        return Duration.init;
    }

    ///
    static Duration min() pure {
        Duration temp;
        temp.days_ = long.min;
        temp.nanoSeconds_ = (-NanoSecondsInDay) + 1;
        return temp;
    }

    ///
    static Duration max() pure {
        Duration temp;
        temp.days_ = long.max;
        temp.nanoSeconds_ = NanoSecondsInDay - 1;
        return temp;
    }
}

///
alias day = days;

///
Duration days(long amount) pure {
    Duration ret;
    ret.days_ = amount;
    return ret;
}

///
alias hour = hours;

///
Duration hours(long amount) pure {
    Duration temp;
    temp.nanoSeconds_ = amount * 3_600_000_000_000;
    return Duration.init + temp;
}

///
alias minute = minutes;

///
Duration minutes(long amount) pure {
    Duration temp;
    temp.nanoSeconds_ = amount * 60_000_000_000;
    return Duration.init + temp;
}

///
alias second = seconds;

///
Duration seconds(long amount) pure {
    Duration temp;
    temp.nanoSeconds_ = amount * 1_000_000_000;
    return Duration.init + temp;
}

///
alias milliSecond = milliSeconds;

///
Duration milliSeconds(long amount) pure {
    Duration temp;
    temp.nanoSeconds_ = amount * 1_000_000;
    return Duration.init + temp;
}

///
alias microSecond = microSeconds;

///
Duration microSeconds(long amount) pure {
    Duration temp;
    temp.nanoSeconds_ = amount * 1_000;
    return Duration.init + temp;
}

///
alias nanoSecond = nanoSeconds;

///
Duration nanoSeconds(long amount) pure {
    Duration temp;
    temp.nanoSeconds_ = amount;
    return Duration.init + temp;
}

unittest {
    import sidero.base.text.format.write;
    import sidero.base.text.format.read;
    import sidero.base.text : String_UTF8;

    Duration d1 = 2.days + 6.microSeconds;
    auto formatted = d1.format("%a");

    Duration d2;
    assert(formattedRead(formatted, String_UTF8("{:%a}"), d2));
    assert(d1 == d2);
}
