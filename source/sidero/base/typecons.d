///
module sidero.base.typecons;
import sidero.base.text;

export:

/// Similar to std.typecons : Nullable except -betterC compatible
struct Optional(T) {
    private {
        T value;
        bool isSet;
    }

export @safe nothrow @nogc:

    ///
    this(return scope ref Optional other) scope @trusted {
        this.tupleof = other.tupleof;
    }

    ///
    this(scope T value) scope {
        this = value;
    }

    ///
    bool isNull() scope {
        return !isSet;
    }

    bool opCast(T : bool)() scope const {
        return this.isSet;
    }

    ///
    void nullify() scope {
        this.value = T.init;
        this.isSet = false;
    }

    ///
    unittest {
        Optional op = T.init;
        assert(!op.isNull);
        op.nullify;
        assert(op.isNull);
    }

    ///
    void opAssign(scope T value) scope {
        this.value = value;
        this.isSet = true;
    }

    ///
    unittest {
        Optional op = T.init;
        assert(!op.isNull);
    }

    ///
    ref T get() scope return {
        assert(this.isSet, "Value must be set to get, did you check if isNull first?");
        return this.value;
    }

    ///
    bool opEquals(scope T other) scope const @trusted {
        if (!this.isSet)
            return false;
        return (cast(Optional*)&this).value == other;
    }

    ///
    int opCmp(scope T other) scope const @trusted {
        if (!this.isSet)
            return -1;

        if ((cast(Optional*)&this).value == other)
            return 0;
        else if ((cast(Optional*)&this).value < other)
            return -1;
        else
            return 1;
    }

    ///
    String_UTF8 toString() scope const {
        StringBuilder_UTF8 ret;
        this.toString(ret);
        return ret.asReadOnly();
    }

    ///
    void toString(S)(scope ref S sink) scope const @trusted {
        if (!this.isSet)
            sink ~= "not-set"c;
        else
            sink.formattedWrite("{:s}", (cast(Optional*)&this).value);
    }

    static if (__traits(hasMember, T, "toStringPretty")) {
        ///
        String_UTF8 toStringPretty() scope const {
            StringBuilder_UTF8 ret;
            this.toStringPretty(ret);
            return ret.asReadOnly();
        }

        ///
        void toStringPretty(S)(scope ref S sink) scope const {
            if (!this.isSet) {
                sink ~= "not-set"c;
                return;
            }

            static if (__traits(compiles, { (cast(Optional*)&this).value.toStringPretty(sink); })) {
                (cast(Optional*)&this).value.toStringPretty(sink);
            } else static if (__traits(compiles, { (cast(Optional*)&this).value.toStringPretty(&sink.put); })) {
                (cast(Optional*)&this).value.toStringPretty(&sink.put);
            } else static if (__traits(compiles, { sink ~= (cast(Optional*)&this).value.toStringPretty(); })) {
                sink ~= (cast(Optional*)&this).value.toStringPretty();
            }
        }
    }
}
