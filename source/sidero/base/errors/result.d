module sidero.base.errors.result;
import sidero.base.errors.message;

///
auto result(Type)(Type argument) {
    import std.traits : Unqual;

    static if (is(UnQual!Type == ErrorMessage)) {
        return ErrorResult(argument);
    } else {
        return Result!Type(argument);
    }
}

///
alias ErrorResult = Result!void;

///
struct Result(Type) {
    ///
    enum HaveValue = !is(Type == void);

    static if (HaveValue) {
        private {
            Type value;
        }

        static if (__traits(hasMember, Type, "opAssign")) {
            ///
            auto opAssign(Args...)(Args args) {
                if (isNull)
                    assert(0);
                return value.opAssign(args);
            }
        }
    }

    ///
    ErrorInfo error;

scope nothrow @nogc @safe:

    static if (HaveValue) {
        ///
        this(scope Type value) {
            this.value = value;
        }

        /// Will verify that you checked
        ref Type get() return @trusted {
            if (!error.checked)
                assert(0, "You forgot to check if value had an error. assert(thing, thing.error.toString());");

            assert(opCast!bool(), error.toString().unsafeGetLiteral);
            return value;
        }

        ///
        alias get this;

        /// Will check and only error if there is an error.
        Type assumeOkay() @system {
            assert(opCast!bool(), error.toString().unsafeGetLiteral);
            return value;
        }
    }

    ///
    this(ErrorInfo errorInfo) {
        error = errorInfo;
        error.checked = false;
    }

    ///
    this(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        error = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    void opAssign(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        error = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    this(ref Result other) @trusted {
        static foreach (i; 0 .. this.tupleof.length)
            this.tupleof[i] = other.tupleof[i];

        this.error.checked = false;
    }

    ///
    bool opCast(T : bool)() {
        error.checked = true;
        return error.info.message is null;
    }

    ///
    bool isNull() @trusted {
        if (!error.checked)
            assert(0, "You forgot to check if value had an error. assert(thing, thing.error.toString());");

        assert(opCast!bool(), error.toString().unsafeGetLiteral);

        static if (__traits(hasMember, Type, "isNull")) {
            return value.isNull;
        } else
            return false;
    }

    ///
    bool opEquals(scope const ErrorMessage other) const {
        return error.info.id !is null && error.info.id == other.id;
    }

    static if (HaveValue) {
        ///
        bool opEquals(scope const Type other) const {
            if (error.info.message !is null)
                return false;

            return this.value == other;
        }

        ///
        bool opEquals(scope const Result!Type other) const {
            if (error.info.message !is null)
                return other.error.info.message !is null;
            return this.value == other;
        }
    }
}

///
unittest {
    ErrorResult got = ErrorResult();

    if (got) {
        // ok
    } else {
        assert(0, "Null, but no error");
    }

    assert(!got.isNull);
}

///
unittest {
    import sidero.base.errors.stock;

    ErrorResult got = ErrorResult(NullPointerException("Missing some state?"));

    if (got) {
        assert(0, "Null, have error");
    } else {
        // ok
    }
}

///
unittest {
    import sidero.base.errors.stock;

    auto success1 = ErrorResult(), success2 = ErrorResult();
    auto error = ErrorResult(NullPointerException("Missing some state?"));

    if (success1 && success2) {
        // ok

        if (success1 && success2 && error) {
            // not so ok
            assert(0, "Null, have error");
        }
    } else {
        assert(0, "Null, but no error");
    }
}
