module sidero.base.datetime.defs;
import sidero.base.datetime.duration;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.timezone;
import sidero.base.datetime.calendars.defs;
import sidero.base.datetime.calendars.gregorian;
import sidero.base.text;
import sidero.base.traits;
import sidero.base.errors;
import sidero.base.attributes;

///
enum {
    ///
    MissingUnixEpochException = ErrorMessage("MUEE", "Date type doesn't implement Unix epoch, is it representable?"),
}

///
struct DateTime(DateType) {
    package(sidero.base.datetime) @PrettyPrintIgnore {
        TimeOfDay time_;
        TimeZone timezone_;
        DateType date_;
    }

    ///
    static string DefaultFormat = DateType.DefaultFormat ~ " " ~ TimeOfDay.DefaultFormat,
        ATOMFormat = "%Y-%m-%dT%H:%i:%s%P", COOKIEFormat = "%l, %d-%M-%Y %H:%i:%s %T",
        ISO8601Format = "%Y-%m-%dT%H:%i:%s%O",
        ISO8601_EXPANDEDFormat = "%X-%m-%dT%H:%i:%s%P", RFC822Format = "%D, %d %M %y %H:%i:%s %O",
        RFC850Format = "%l, %d-%M-%y %H:%i:%s %T", RFC1036Format = "%D, %d %M %y %H:%i:%s %O",
        RFC1123Format = "%D, %d %M %Y %H:%i:%s %O",
        RFC7231Format = "%D, %d %M %Y %H:%i:%s GMT",
        RFC2822Format = "%D, %d %M %Y %H:%i:%s %O", RFC3339Format = "%Y-%m-%dT%H:%i:%s%P", RFC3339ExtendedFormat = "%Y-%m-%dT%H:%i:%s.%v%P",
        RSSFormat = "%D, %d %M %Y %H:%i:%s %O", W3CFormat = "%Y-%m-%dT%H:%i:%s%P", LogFileName = "%Y-%m-%d-%H";

export @safe nothrow @nogc:

    ///
    this(return scope ref DateTime other) scope {
        this.tupleof = other.tupleof;
    }

    ///
    this(return scope DateType date) scope {
        this.date_ = date;
    }

    ///
    this(return scope TimeOfDay time) scope {
        this.time_ = time;
    }

    ///
    this(return scope DateType date, return scope TimeOfDay time) scope {
        this.date_ = date;
        this.time_ = time;
    }

    ///
    this(return scope DateType date, return scope TimeOfDay time, return scope TimeZone timezone) scope {
        this.date_ = date;
        this.time_ = time;
        this.timezone_ = timezone;
    }

    /// Does not adjust date/time into timezone!
    this(return scope DateTime datetime, return scope TimeZone timezone) scope {
        this.date_ = datetime.date_;
        this.time_ = datetime.time_;
        this.timezone_ = timezone;
    }

    ///
    void opAssign(return scope DateTime other) scope @trusted {
        this.__ctor(other);
    }

    //

    ///
    TimeOfDay time() scope const {
        return this.time_;
    }

    ///
    TimeZone timezone() scope const @trusted {
        return (*cast(DateTime*)&this).timezone_;
    }

    ///
    DateType date() scope const {
        return this.date_;
    }

    ///
    mixin DateType.DateWrapper!();

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
    void advance(const Duration interval) scope {
        this.advanceMicroSeconds(interval.totalMicroSeconds);
    }

    ///
    void advanceMicroSeconds(long amount) scope {
        timezoneCheck(() {
            auto dateInterval = this.time_.advanceMicroSeconds(amount, true);
            this.date_.advanceDays(dateInterval.days);
        });
    }

    ///
    void advanceSeconds(long amount) scope {
        timezoneCheck(() {
            auto dateInterval = this.time_.advanceSeconds(amount, true);
            this.date_.advanceDays(dateInterval.days);
        });
    }

    ///
    void advanceMinutes(long amount) scope {
        timezoneCheck(() {
            auto dateInterval = this.time_.advanceMinutes(amount, true);
            this.date_.advanceDays(dateInterval.days);
        });
    }

    ///
    void advanceHours(long amount) scope {
        timezoneCheck(() {
            auto dateInterval = this.time_.advanceHours(amount, true);
            this.date_.advanceDays(dateInterval.days);
        });
    }

    /// If current time zone not set, it'll just add it without adjustment.
    DateTime asTimeZone(return scope TimeZone timezone) scope return @trusted {
        long delta;

        if (!this.timezone_.isNull) {
            auto gDateTime = this.asGregorian();
            auto oldBias = this.timezone_.currentSecondsBias(gDateTime);
            auto newBias = timezone.currentSecondsBias(gDateTime);
            delta = newBias - oldBias;
        }

        DateTime ret = this;
        ret.timezone_ = timezone;

        if (delta != 0)
            ret.advanceSeconds(delta);

        return ret;
    }

    ///
    DateTime!(GregorianDate) asGregorian() scope const return @trusted {
        return typeof(return)(GregorianDate(this.date_.toDaysSinceY2k), cast(TimeOfDay)this.time_, this.timezone);
    }

    ///
    Result!long toUnixTime() scope const @trusted {
        static if (!__traits(hasMember, DateType, "UnixEpoch")) {
            return typeof(return)(MissingUnixEpochException);
        } else {
            auto gDateTime = this.asGregorian();
            auto oldBias = this.timezone_.currentSecondsBias(gDateTime);

            Duration interval = this.date_ - DateType.UnixEpoch;

            long working = interval.days * 86_400;
            working -= oldBias;

            if (interval.days >= 0)
                working += this.time_.totalSeconds;
            else
                working -= this.time_.totalSeconds;

            return typeof(return)(cast(long)working);
        }
    }

    ///
    static DateTime fromUnixTime(long amount, return scope TimeZone timeZone = TimeZone.init) @trusted {
        DateTime ret = DateTime(DateType.UnixEpoch);
        ret = ret.asTimeZone(timeZone);

        ret.advanceSeconds(amount);
        return ret;
    }

    /// Get a date/time pair
    long[2] pair() scope const {
        return [this.date.toDaysSinceY2k().amount, this.time.totalNanoSeconds()];
    }

    //

    ///
    Result!Duration opBinary(string op : "-")(scope DateTime other) scope const {
        auto ourUnixTime = this.toUnixTime, otherUnixTime = other.toUnixTime;

        if (!ourUnixTime)
            return typeof(return)(ourUnixTime.getError);
        else if (!otherUnixTime)
            return typeof(return)(otherUnixTime.getError);

        long ourNanoSeconds = this.time.nanoSecond, otherNanoSeconds = other.time.nanoSecond;
        ourNanoSeconds -= (ourNanoSeconds / 1_000_000_000) * 1_000_000_000;
        otherNanoSeconds -= (otherNanoSeconds / 1_000_000_000) * 1_000_000_000;

        if (ourUnixTime < 0)
            ourNanoSeconds *= -1;
        if (otherUnixTime < 0)
            otherNanoSeconds *= -1;

        ourNanoSeconds += ourUnixTime * 1_000_000_000;
        otherNanoSeconds += otherUnixTime * 1_000_000_000;
        return typeof(return)((ourNanoSeconds - otherNanoSeconds).nanoSeconds);
    }

    ///
    bool opEquals(scope const DateTime other) scope const {
        return this.time_ == other.time_ && this.date_ == other.date_;
    }

    ///
    int opCmp(scope const DateTime other) scope const {
        const ret = this.date_.opCmp(other.date_);

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

     Note: Implements I, O, P, p, T, Z, c, r, U. Defers everything else to respective type
     */
    void format(Builder, Format)(scope ref Builder builder, scope Format specification, bool usePercentageEscape = true) scope const
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
        import writer = sidero.base.text.format.write;

        switch (specification) {
        case 'B':
            DateTime temp;

            if (this.timezone_.isNull)
                temp = DateTime(cast(DateTime)this, TimeZone.from(0));
            else
                temp = cast(DateTime)this;

            // UTC+1
            TimeZone newTimeZone = TimeZone.from(60);
            temp = temp.asTimeZone(newTimeZone);

            auto working = cast(uint)(((3600 * temp.hour) + (60 * temp.minute)) / 86.4);

            if (working < 10)
                builder ~= "0"c;
            else if (working < 100)
                builder ~= "00"c;

            writer.formattedWrite(builder, "{:s}", working);
            return true;

        case 'e':
            // we are overriding the timezone behavior, because we have the date/time,
            //  which also means we have access to the unix time which we can use for IANA TZ.
            builder ~= this.timezone_.nameFor(this.asGregorian());
            return true;

        case 'I':
            if (this.timezone_.isNull || !this.timezone_.haveDaylightSavings) {
                builder ~= "0"c;
            } else {
                auto gDateTime = this.asGregorian();
                bool inDaylight = this.timezone_.isInDaylightSavings(gDateTime);

                builder ~= inDaylight ? "1"c : "0"c;
            }
            return true;

        case 'O':
            if (this.timezone_.isNull) {
                builder ~= "+0000";
            } else {
                auto gDateTime = this.asGregorian();
                auto bias = this.timezone_.currentSecondsBias(gDateTime);

                TimeOfDay tod = TimeOfDay(0, 0, 0);
                tod.advanceSeconds(bias < 0 ? -bias : bias);

                if (bias < 0)
                    builder ~= "-";
                else
                    builder ~= "+";

                auto hour = tod.hour;
                if (hour < 10)
                    builder ~= "0";
                writer.formattedWrite(builder, "{:s}", hour);

                auto minutes = tod.minute;
                if (minutes < 10)
                    builder ~= "0";
                writer.formattedWrite(builder, "{:s}", minutes);
            }
            return true;

        case 'P':
            if (this.timezone_.isNull) {
                builder ~= "+0000";
            } else {
                auto gDateTime = this.asGregorian();
                auto bias = this.timezone_.currentSecondsBias(gDateTime);

                TimeOfDay tod = TimeOfDay(0, 0, 0);
                tod.advanceSeconds(bias < 0 ? -bias : bias);

                if (bias < 0)
                    builder ~= "-";
                else
                    builder ~= "+";

                auto hour = tod.hour;
                if (hour < 10)
                    builder ~= "0";
                writer.formattedWrite(builder, "{:s}", hour);

                auto minutes = tod.minute;
                if (minutes < 10)
                    builder ~= "0";
                writer.formattedWrite(builder, "{:s}", minutes);
            }
            return true;

        case 'p':
            if (this.timezone_.isNull) {
                builder ~= "+0000";
            } else {
                auto gDateTime = this.asGregorian();
                auto bias = this.timezone_.currentSecondsBias(gDateTime);

                if (bias == 0) {
                    builder ~= "Z";
                } else {
                    TimeOfDay tod = TimeOfDay(0, 0, 0);
                    tod.advanceSeconds(bias < 0 ? -bias : bias);

                    if (bias < 0)
                        builder ~= "-";
                    else
                        builder ~= "+";

                    auto hour = tod.hour;
                    if (hour < 10)
                        builder ~= "0";
                    writer.formattedWrite(builder, "{:s}", hour);

                    auto minutes = tod.minute;
                    if (minutes < 10)
                        builder ~= "0";
                    writer.formattedWrite(builder, "{:s}", minutes);
                }
            }
            return true;

        case 'T':
            if (this.timezone_.isNull) {
                builder ~= "Z";
            } else {
                auto gDateTime = this.asGregorian();
                auto bias = this.timezone_.currentSecondsBias(gDateTime);

                if (bias == 0) {
                    builder ~= "Z";
                } else {
                    TimeOfDay tod = TimeOfDay(0, 0, 0);
                    tod.advanceSeconds(bias < 0 ? -bias : bias);

                    if (bias < 0)
                        builder ~= "-";
                    else
                        builder ~= "+";

                    auto hour = tod.hour;
                    if (hour < 10)
                        builder ~= "0";
                    writer.formattedWrite(builder, "{:s}", hour);

                    auto minutes = tod.minute;
                    if (minutes > 0) {
                        if (minutes < 10)
                            builder ~= "0";
                        writer.formattedWrite(builder, "{:s}", minutes);
                    }
                }
            }
            return true;

        case 'Z':
            if (this.timezone_.isNull) {
                builder ~= "0";
            } else {
                auto gDateTime = this.asGregorian();
                auto bias = this.timezone_.currentSecondsBias(gDateTime);
                writer.formattedWrite(builder, "{:s}", bias);
            }
            return true;

        case 'c':
            this.format(builder, ISO8601Format);
            return true;

        case 'r':
            this.format(builder, RFC2822Format);
            return true;

        case 'U':
            auto unixTime = this.toUnixTime;

            if (unixTime) {
                writer.formattedWrite(builder, "{:s}", unixTime);
            }
            return true;

        default:
            return this.time_.formatValue(builder, specification) || this.timezone_.formatValue(builder,
                    specification) || this.date_.formatValue(builder, specification);
        }
    }

    ///
    bool formattedWrite(scope ref StringBuilder_ASCII builder, scope FormatSpecifier format, bool usePercentageEscape = true) @safe nothrow @nogc {
        return false;
    }

    ///
    bool formattedWrite(scope ref StringBuilder_UTF8 builder, scope FormatSpecifier format, bool usePercentageEscape = true) @safe nothrow @nogc {
        if (format.fullFormatSpec.length == 0)
            return false;

        this.format(builder, format.fullFormatSpec, usePercentageEscape);
        return true;
    }

    private alias PI = parse!StringBuilder_UTF8; // just to make sure it all compiles

    ///
    static bool parse(Input)(scope ref Input input, scope ref DateTime output, scope String_UTF8 specification,
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
    bool parseValue(Input)(scope ref Input input, dchar specification) {
        import reader = sidero.base.text.format.read;

        Input input2;

        switch (specification) {
        case 'p':
        case 'P':
        case 'T':
            if (input.startsWith("Z")) {
                input = input[1 .. $];
                this.timezone_ = TimeZone.from(0);
                return true;
            } else if (input.length >= 4) {
                long hours, seconds;

                input2 = input[0 .. 2];
                if (!cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), hours) || !input2.empty || hours >= 24)
                    return false;

                input2 = input[2 .. 4];
                if (!cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), seconds) || !input2.empty || seconds >= 60)
                    return false;

                const bias = (hours * 60) + seconds;
                this.timezone_ = TimeZone.from(bias);
                return true;
            } else
                return false;

        case 'Z':
            input2 = input.save;
            long bias;

            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), bias)) {
                input = input2;
                this.timezone_ = TimeZone.from(bias);
                return true;
            }
            return false;

        case 'c':
            return DateTime.parse(input, this, String_UTF8(ISO8601Format), true);

        case 'r':
            return DateTime.parse(input, this, String_UTF8(RFC2822Format), true);

        case 'U':
            input2 = input.save;
            long unixTime;

            if (cast(bool)reader.formattedRead(input2, String_UTF8("{:d}"), unixTime)) {
                input = input2;
                this = DateTime.fromUnixTime(unixTime);
                return true;
            }
            return false;

        default:
            return this.time_.parseValue(input, specification) || this.timezone_.parseValue(input, specification) ||
                this.date_.parseValue(input, specification);
        }
    }

    ///
    static bool formattedRead(Input)(scope ref Input input, scope ref Duration output, scope FormatSpecifier format) {
        return parse(input, output, format.fullFormatSpec);
    }

private @hidden:
    void timezoneCheck(Delegate)(scope Delegate callback) scope @trusted {
        auto temp = this.asGregorian();
        const oldYear = temp.year;
        const oldBias = this.timezone_.currentSecondsBias(temp);

        callback();

        temp = this.asGregorian();

        if (temp.year != oldYear)
            this.timezone_ = this.timezone_.forYear(temp.year);
        const newBias = this.timezone_.currentSecondsBias(temp);

        if (oldBias != newBias) {
            auto dateInterval = this.time_.advanceSeconds(newBias - oldBias, true);
            this.date_.advanceDays(dateInterval.days);
        }
    }
}
