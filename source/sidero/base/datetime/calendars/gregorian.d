module sidero.base.datetime.calendars.gregorian;
import sidero.base.datetime.calendars.defs;

///
struct GregorianDate {
    private {
        long year_;
        ubyte month_, day_;
    }

export @safe nothrow @nogc:

    ///
    this(ubyte day, Month month, long year) {
        this.year_ = year;
        this.month_ = cast(ubyte)month;
        this.day_ = day;
    }

    ///
    this(ubyte day, ubyte month, long year) {
        this.day_ = 1;
        this.month_ = 1;
        this.year_ = year;

        this.advanceMonths(month - 1);
        this.advanceDays(day - 1);
    }

    ///
    long year() {
        return this.year_;
    }

    ///
    Month month() {
        return cast(Month)this.month_;
    }

    ///
    ubyte day() {
        return this.day_;
    }

    ///
    long century() {
        return this.year_ / 100;
    }

    ///
    WeekDay dayInWeek() {
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
        assert(GregorianDate(24, 12, 2022).dayInWeek == WeekDay.Saturday);
        assert(GregorianDate(25, 12, 2022).dayInWeek == WeekDay.Sunday);
        assert(GregorianDate(15, 2, 2012).dayInWeek == WeekDay.Wednesday);
    }

    ///
    long dayInYear() {
        long soFar;

        foreach (m; cast(ubyte)1 .. this.month_) {
            soFar += GregorianDate(cast(ubyte)1, m, this.year_).daysInMonth;
        }

        return soFar + this.day_;
    }

    ///
    bool isLeapYear() {
        return (this.year % 4 == 0) && (this.year_ % 100 != 0 || this.year_ % 400 == 0);
    }

    ///
    unittest {
        assert(!GregorianDate(1, 1, 1700).isLeapYear);
        assert(!GregorianDate(1, 1, 1800).isLeapYear);
        assert(!GregorianDate(1, 1, 1900).isLeapYear);
        assert(GregorianDate(1, 1, 2000).isLeapYear);
    }

    ///
    ubyte daysInMonth() {
        static immutable ubyte[12] Count = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
        return (isLeapYear() && this.month_ == 2) ? 29 : Count[this.month_ - 1];
    }

    ///
    long daysInYear() {
        return isLeapYear() ? 366 : 365;
    }

    ///
    GregorianDate endOfMonth() {
        return GregorianDate(daysInMonth(), this.month_, this.year_);
    }

    ///
    void advanceDays(DaysInterval interval) {
        this.advanceDays(interval.amount);
    }

    ///
    void advanceDays(long amount) {
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
        GregorianDate date = GregorianDate(5, 11, 2022);

        date.advanceDays(59);
        assert(date == GregorianDate(3, 1, 2023));

        date.advanceDays(-59);
        assert(date == GregorianDate(5, 11, 2022));
    }

    ///
    void advanceMonths(long amount, bool allowOverflow = true) {
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
    void advanceYears(long amount, bool allowOverflow = true) {
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
        GregorianDate date = GregorianDate(29, 2, 2000);
        date.advanceYears(-1);
        assert(date == GregorianDate(1, 3, 1999));
    }

    ///
    DaysInterval opBinary(string op : "-")(GregorianDate other) {
        DaysSinceY2k us = this.toDaysSinceY2k(), against = other.toDaysSinceY2k();
        return DaysInterval(us.amount - against.amount);
    }

    ///
    DaysSinceY2k toDaysSinceY2k() {
        DaysSinceY2k ret;
        GregorianDate temp = this;
        GregorianDate target = GregorianDate(1, 1, 2000);

        while(temp < target) {
            long canDo = temp.daysInYear() - (temp.dayInYear() - 1);
            temp.advanceDays(canDo);
            ret.amount -= canDo;
        }

        while(temp > target) {
            long canDo = temp.dayInYear();
            temp.advanceDays(-canDo);
            ret.amount += canDo;
        }

        return ret;
    }

    ///
    unittest {
        assert(GregorianDate(1, 1, 2000).toDaysSinceY2k() == DaysSinceY2k(0));
        assert(GregorianDate(24, 12, 2022).toDaysSinceY2k() == DaysSinceY2k(8394));
        assert(GregorianDate(1, 1, 1975).toDaysSinceY2k() == DaysSinceY2k(-9131));
    }

    ///
    bool opEquals(const GregorianDate other) const {
        return this.day_ == other.day_ && this.month_ == other.month_ && this.year_ == other.year_;
    }

    ///
    int opCmp(const GregorianDate other) const {
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
    static GregorianDate fromDaysSinceY2k(DaysSinceY2k from) {
        GregorianDate ret;
        ret.year_ = 2000;
        ret.month_ = 1;
        ret.day_ = 1;

        ret.advanceDays(from.amount);
        return ret;
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
