module sidero.base.math.interval;

private {
    alias Interval_int = Interval!int;
    alias Interval_dchar = Interval!dchar;
}

///
struct Interval(Type) {
    static assert(__traits(isArithmetic, Type) || __traits(compiles, Type.init < Type.init && Type.init == Type.init),
            "Only comparable types may be used for a interval");

    ///
    Type start, end;

export:

    private {
        import sidero.base.internal.meta : OpApplyCombos;

        int opApplyImpl(Del)(scope Del del) scope const {
            int result;

            foreach(Type index; start .. end + 1) {
                result = del(index);
                if(result)
                    return result;
            }

            return result;
        }
    }

    mixin OpApplyCombos!(Type, void, "opApply", true, true, true, false, false);

@safe nothrow @nogc:

    ///
    this(Type index) scope {
        this.start = index;
        this.end = index;
    }

    ///
    this(Type start, Type end) scope {
        assert(end >= start);

        this.start = start;
        this.end = end;
    }

    ///
    bool isSingle() scope const {
        return start == end;
    }

    ///
    bool within(Type other) scope const {
        return start <= other && end >= other;
    }

    ///
    bool within(Interval other) scope const {
        return this.end >= other.start && other.end >= this.start;
    }

    ///
    uint count() scope const {
        return end + 1 - start;
    }

    ///
    ulong toHash() scope const {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf(this.start);
        return hashOf(this.end, ret);
    }

    ///
    bool opEquals(const Interval other) scope const {
        return this.opCmp(other) == 0;
    }

    ///
    int opCmp(const Interval other) scope const {
        return this.start < other.start ? -1 : (this.start > other.start ? 1 : 0);
    }
}
