module sidero.base.datetime.calendars.gregorian;
import sidero.base.datetime.calendars.defs;
import sidero.base.text;
import sidero.base.traits;

///
struct GregorianDate {
    private {
        long year_;
        ubyte month_, day_;
    }

    ///
    static string DefaultFormat = "j/n/Y", ISOFormat = "Ymd", ISOExtFormat = "Y-m-d", SimpleFormat = "Y-M-d";

export @safe nothrow @nogc:

    ///
    this(const DaysSinceY2k from) scope {
        this.year_ = 2000;
        this.month_ = 1;
        this.day_ = 1;

        this.advanceDays(from.amount);
    }

    ///
    this(long year, Month month, ubyte day) scope {
        this.year_ = year;
        this.month_ = cast(ubyte)month;
        this.day_ = day;
    }

    ///
    this(long year, ubyte month, ubyte day) scope {
        this.day_ = 1;
        this.month_ = 1;
        this.year_ = year;

        this.advanceMonths(month - 1);
        this.advanceDays(day - 1);
    }

    ///
    long year() scope const {
        return this.year_;
    }

    ///
    Month month() scope const {
        return cast(Month)this.month_;
    }

    ///
    ubyte day() scope const {
        return this.day_;
    }

    ///
    long century() scope const {
        return this.year_ / 100;
    }

    ///
    bool isAD() scope const {
        return this.year_ < 0;
    }

    ///
    bool isCE() scope const {
        return this.year_ >= 0;
    }

    ///
    WeekDay dayInWeek() scope const {
        import std.math : floor;

        // https://en.wikipedia.org/wiki/Determination_of_the_day_of_the_week#Disparate_variation
        long c = this.century();
        long m = this.month_ < 3 ? (this.month_ + 10) : (this.month_ - 2);
        long Y = this.month_ < 3 ? (this.year_ - 1) : this.year_;
        long y = Y - (100 * c);

        long W = cast(long)((this.day_ + floor((2.6 * m) - 0.2) - (2 * c) + y + floor(y / 4f) + floor(c / 4f)) % 7);

        if (W == 0)
            W = 6;
        else
            W--;

        return cast(WeekDay)W;
    }

    ///
    unittest {
        assert(GregorianDate(2022, 12, 24).dayInWeek == WeekDay.Saturday);
        assert(GregorianDate(2022, 12, 25).dayInWeek == WeekDay.Sunday);
        assert(GregorianDate(2012, 2, 15).dayInWeek == WeekDay.Wednesday);
    }

    /// [1 ..
    long dayInYear() scope const {
        long soFar;

        foreach (m; cast(ubyte)1 .. this.month_) {
            soFar += GregorianDate(cast()this.year_, cast(ubyte)m, cast(ubyte)1).daysInMonth;
        }

        return soFar + this.day_;
    }

    ///
    bool isLeapYear() scope const {
        return (this.year % 4 == 0) && (this.year_ % 100 != 0 || this.year_ % 400 == 0);
    }

    ///
    unittest {
        assert(!GregorianDate(1700, 1, 1).isLeapYear);
        assert(!GregorianDate(1800, 1, 1).isLeapYear);
        assert(!GregorianDate(1900, 1, 1).isLeapYear);
        assert(GregorianDate(2000, 1, 1).isLeapYear);
    }

    ///
    ubyte daysInMonth() scope const {
        static immutable ubyte[12] Count = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        return (isLeapYear() && this.month_ == 2) ? 29 : Count[this.month_ - 1];
    }

    ///
    long daysInYear() scope const {
        return isLeapYear() ? 366 : 365;
    }

    ///
    ubyte firstMondayOfYear() scope const {
        GregorianDate temp = GregorianDate(this.year_, 1, 1);
        ubyte dow = cast(ubyte)temp.dayInWeek();

        if (dow == 0)
            return 1;

        return cast(ubyte)(8 - dow);
    }

    ///
    unittest {
        assert(GregorianDate(2018, 1, 1).firstMondayOfYear() == 1);
        assert(GregorianDate(2019, 1, 1).firstMondayOfYear() == 7);
        assert(GregorianDate(2020, 1, 1).firstMondayOfYear() == 6);
        assert(GregorianDate(2021, 1, 1).firstMondayOfYear() == 4);
        assert(GregorianDate(2022, 1, 1).firstMondayOfYear() == 3);
    }

    ///
    GregorianDate endOfMonth() scope const {
        return GregorianDate(this.year_, this.month_, daysInMonth());
    }

    ///
    void advanceDays(DayInterval interval) scope {
        this.advanceDays(interval.amount);
    }

    ///
    void advanceDays(long amount) scope {
        while (amount < 0) {
            long canDo = this.day_ - 1;

            if (canDo == 0) {
                this.month_--;
                amount++;

                if (this.month_ == 0) {
                    this.year_--;
                    this.month_ = 12;
                }

                this.day_ = this.daysInMonth();
            } else {
                if (canDo > -amount)
                    canDo = -amount;
                this.day_ -= canDo;
                amount += canDo;
            }
        }

        while (amount > 0) {
            long canDo = this.daysInMonth() - this.day_;

            if (canDo == 0) {
                this.day_ = 1;
                this.month_++;
                amount--;

                if (this.month_ == 13) {
                    this.year_++;
                    this.month_ = 1;
                }
            } else {
                if (canDo > amount)
                    canDo = amount;
                this.day_ += canDo;
                amount -= canDo;
            }
        }
    }

    ///
    unittest {
        GregorianDate date = GregorianDate(2022, 11, 5);

        date.advanceDays(59);
        assert(date == GregorianDate(2023, 1, 3));

        date.advanceDays(-59);
        assert(date == GregorianDate(2022, 11, 5));
    }

    ///
    void advanceMonths(long amount, bool allowOverflow = true) scope {
        auto newMonth = (this.month_ + amount) % 12;
        if (newMonth <= 0)
            newMonth += 12;

        this.month_ = cast(ubyte)newMonth;
        auto max = this.daysInMonth();
        auto overflow = this.day_ - max;

        if (overflow > 0) {
            if (allowOverflow) {
                this.month_++;
                this.day_ = cast(ubyte)overflow;
            } else
                this.day_ = max;
        }
    }

    ///
    void advanceYears(long amount, bool allowOverflow = true) scope {
        this.year_ += amount;

        if (this.month_ == 2 && this.day_ == 29 && !this.isLeapYear()) {
            if (allowOverflow) {
                this.month_++;
                this.day_ = 1;
            } else
                this.day_ = 28;
        }
    }

    ///
    unittest {
        GregorianDate date = GregorianDate(2000, 2, 29);
        date.advanceYears(-1);
        assert(date == GregorianDate(1999, 3, 1));
    }

    ///
    DayInterval opBinary(string op : "-")(const GregorianDate other) scope {
        DaysSinceY2k us = this.toDaysSinceY2k(), against = other.toDaysSinceY2k();
        return DayInterval(us.amount - against.amount);
    }

    ///
    DaysSinceY2k toDaysSinceY2k() scope const {
        DaysSinceY2k ret;
        GregorianDate temp = this;
        GregorianDate target = GregorianDate(2000, 1, 1);

        while (temp < target) {
            long canDo = temp.daysInYear() - (temp.dayInYear() - 1);
            temp.advanceDays(canDo);
            ret.amount -= canDo;
        }

        while (temp > target) {
            long canDo = temp.dayInYear();
            temp.advanceDays(-canDo);
            ret.amount += canDo;
        }

        return ret;
    }

    ///
    unittest {
        assert(GregorianDate(2000, 1, 1).toDaysSinceY2k() == DaysSinceY2k(0));
        assert(GregorianDate(2022, 12, 24).toDaysSinceY2k() == DaysSinceY2k(8394));
        assert(GregorianDate(1975, 1, 1).toDaysSinceY2k() == DaysSinceY2k(-9131));
    }

    ///
    bool opEquals(const GregorianDate other) scope const {
        return this.day_ == other.day_ && this.month_ == other.month_ && this.year_ == other.year_;
    }

    ///
    int opCmp(const GregorianDate other) scope const {
        if (this.year_ < other.year_)
            return -1;
        else if (this.year_ > other.year_)
            return 1;

        if (this.month_ < other.month_)
            return -1;
        else if (this.month_ > other.month_)
            return 1;

        if (this.day_ < other.day_)
            return -1;
        else if (this.day_ > other.day_)
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

    /// See: https://www.php.net/manual/en/datetime.format.php
    void format(Builder, Format)(scope ref Builder builder, scope Format specification) scope const 
            if (isBuilderString!Builder && isReadOnlyString!Format) {
        import sidero.base.allocators;

        static immutable ThreeLettersDay = ["Mon", "Tue", "Wed", "Thr", "Fri", "Sat", "Sun"];
        static immutable DayText = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
        static immutable OrdinalSuffix = [
            `st`, `nd`, `rd`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `th`,
            `th`, `th`, `st`, `nd`, `rd`, `th`, `th`, `th`, `th`, `th`, `th`, `th`, `st`, `nd`
        ];
        static immutable FullMonth = [
            `January`, `February`, `March`, `April`, `May`, `June`, `July`, `August`, `September`, `October`, `November`,
            `December`
        ];
        static immutable ThreeLettersMonth = [
            `Jan`, `Feb`, `Mar`, `Apr`, `May`, `Jun`, `Jul`, `Aug`, `Sep`, `Oct`, `Nov`, `Dec`
        ];

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
            case 'd':
                if (this.day_ < 10)
                    builder ~= "0"c;
                builder.formattedWrite("%s", this.day_);
                break;

            case 'D':
                builder ~= ThreeLettersDay[this.dayInWeek()];
                break;

            case 'j':
                builder.formattedWrite("%s", this.day_);
                break;

            case 'l':
                builder ~= DayText[this.dayInWeek()];
                break;

            case 'N':
                builder.formattedWrite("%s", this.dayInWeek() + 1);
                break;

            case 'S':
                builder ~= OrdinalSuffix[this.day_];
                break;

            case 'w':
                auto adjusted = cast(ubyte)this.dayInWeek();
                if (adjusted == 7)
                    adjusted = 0;
                else
                    adjusted++;

                builder.formattedWrite("%s", adjusted);
                break;

            case 'z':
                builder.formattedWrite("%s", this.dayInYear() - 1);
                break;

            case 'W':
                builder.formattedWrite("%s", (this.dayInYear() - this.firstMondayOfYear()) / 7);
                break;

            case 'F':
                builder ~= FullMonth[this.month_];
                break;

            case 'm':
                if (this.month_ < 10)
                    builder ~= "0"c;
                builder.formattedWrite("%s", this.month_);
                break;

            case 'M':
                builder ~= ThreeLettersMonth[this.month_];
                break;

            case 'n':
                builder.formattedWrite("%s", this.month_);
                break;

            case 't':
                builder.formattedWrite("%s", this.daysInMonth());
                break;

            case 'L':
                builder.formattedWrite("%d", this.isLeapYear());
                break;

            case 'o':
                if (this.day_ < this.firstMondayOfYear()) {
                    builder.formattedWrite("%s", this.year_ - 1);
                } else {
                    long temp = this.year_;

                    if (temp < 0) {
                        temp *= -1;
                        builder ~= "-";
                    }

                    if (temp < 10)
                        builder ~= "000";
                    else if (temp < 100)
                        builder ~= "00";
                    else if (temp < 1000)
                        builder ~= "0";

                    builder.formattedWrite("%s", temp);
                }
                break;

            case 'X':
                long temp = this.year_;

                if (temp < 0) {
                    temp *= -1;
                    builder ~= "-";
                } else {
                    builder ~= "+";
                }

                if (temp < 10)
                    builder ~= "000";
                else if (temp < 100)
                    builder ~= "00";
                else if (temp < 1000)
                    builder ~= "0";

                builder.formattedWrite("%s", temp);
                break;

            case 'x':
                long temp = this.year_;

                if (temp < 0) {
                    temp *= -1;
                    builder ~= "-";
                } else if (temp >= 10000) {
                    builder ~= "+";
                }

                if (temp < 10)
                    builder ~= "000";
                else if (temp < 100)
                    builder ~= "00";
                else if (temp < 1000)
                    builder ~= "0";

                builder.formattedWrite("%s", temp);
                break;

            case 'Y':
                long temp = this.year_;

                if (temp < 0) {
                    temp *= -1;
                    builder ~= "-";
                }

                if (temp < 10)
                    builder ~= "000";
                else if (temp < 100)
                    builder ~= "00";
                else if (temp < 1000)
                    builder ~= "0";

                builder.formattedWrite("%s", temp);
                break;

            case 'y':
                long temp = this.year_;
                temp -= (temp / 100) * 100;

                if (temp < 10)
                    builder ~= "0";
                builder.formattedWrite("%s", temp);
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

    ///
    enum WeekDay {
        ///
        Monday,
        ///
        Tuesday,
        ///
        Wednesday,
        ///
        Thursday,
        ///
        Friday,
        ///
        Saturday,
        ///
        Sunday
    }

    ///
    enum Month : ubyte {
        ///
        January,
        ///
        February,
        ///
        March,
        ///
        April,
        ///
        May,
        ///
        June,
        ///
        July,
        ///
        August,
        ///
        September,
        ///
        October,
        ///
        November,
        ///
        December
    }
}
