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
    this(scope T value) scope {
        this = value;
    }

    ///
    bool isNull() scope {
        return !isSet;
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
    ref T get() scope {
        assert(this.isSet, "Value must be set to get, did you check if isNull first?");
        return this.value;
    }

    ///
    bool opEquals(scope const T other) scope const {
        if (!this.isSet)
            return false;
        return this.value == other;
    }

    ///
    int opCmp(scope const T other) scope const {
        if (!this.isSet)
            return -1;

        if (this.value == other)
            return 0;
        else if (this.value < other)
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
    void toString(S)(scope ref S sink) scope const {
        if (!this.isSet)
            sink ~= "not-set";
        else
            sink.formattedWrite!"%s"(this.value);
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
                sink ~= "not-set";
                return;
            }

            static if (__traits(compiles, { this.value.toStringPretty(sink); })) {
                this.value.toStringPretty(sink);
            } else static if (__traits(compiles, { this.value.toStringPretty(&sink.put); })) {
                this.value.toStringPretty(&sink.put);
            } else static if (__traits(compiles, { sink ~= this.value.toStringPretty(); })) {
                sink ~= this.value.toStringPretty();
            }
        }
    }
}
