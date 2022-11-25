/*
Spin counter, locks for thread consistency.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.parallelism.spincounter;
export:

///
struct SpinCounter {
    private shared(int) current;

    @disable this(this);

export @safe nothrow @nogc pure:

    ///
    SpinCounterValue get() {
        import core.atomic : atomicLoad;

        return SpinCounterValue(atomicLoad(current));
    }

    ///
    SpinCounterValue getAndIncrement() {
        import core.atomic : atomicOp;

        return SpinCounterValue(atomicOp!"+="(current, 1));
    }

    void increment() {
        import core.atomic : atomicOp;

        atomicOp!"+="(current, 1);
    }
}

///
unittest {
    SpinCounter counter;

    assert(counter.get() == SpinCounterValue());
    assert(counter.getAndIncrement() == SpinCounterValue(1));
    assert(counter.getAndIncrement() > SpinCounterValue());
}

///
struct SpinCounterValue {
    private int value;

export @safe nothrow @nogc:

    ///
    int opCmp(const SpinCounterValue other) const {
        if (this.value >= 0 && other.value < 0)
            return -1;
        else if (this.value < 0 && other.value >= 0)
            return 1;
        else if (this.value == other.value)
            return 0;
        else if (this.value >= 0 && other.value >= 0)
            return this.value > other.value;
        else
            return -cast(int)(this.value < other.value);
    }

    version (none) {
        ///
        void toString(scope ref StringBuilder_ASCII writer) const {
            import sidero.base.text;

            String_ASCII("%s").formattedWrite(writer, value);
        }

        ///
        StringBuilder_ASCII toString() const @trusted {
            StringBuilder_ASCII ret = StringBuilder_ASCII();
            this.toString(ret);
            return ret;
        }
    }
}
