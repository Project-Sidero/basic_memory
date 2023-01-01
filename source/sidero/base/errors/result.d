module sidero.base.errors.result;
import sidero.base.errors.message;
import sidero.base.math.utils : isClose;

export:

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
export:
    ///
    enum HaveValue = !is(Type == void);

    static if (HaveValue) {
        private {
            Type value;
        }

        static if (__traits(hasMember, Type, "opAssign")) {
            ///
            auto opAssign(Args...)(scope return Args args) {
                if (isNull)
                    assert(0);
                return value.opAssign(args);
            }
        }

        static if (__traits(hasMember, Type, "toHash")) {
            ///
            auto toHash() const {
                if (error.info.id !is null)
                    return 0;
                return value.toHash();
            }
        }
    }

    ///
    ErrorInfo error;

scope nothrow @nogc @safe:

    static if (HaveValue) {
        ///
        this(scope return Type value) @trusted {
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
    this(ErrorInfo errorInfo, string moduleName = __MODULE__, int line = __LINE__) {
        error = errorInfo;
        error.moduleName = moduleName;
        error.line = line;
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
    void opAssign(scope return Result other) {
        this.__ctor(other);
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
    bool opCast(T : bool)() @trusted const {
        assert(!__ctfe, "Don't check for error on const in CTFE");

        (cast(ErrorInfo*)&error).checked = true;
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
        bool opEquals(scope const Type other) const @trusted {
            if (error.info.message !is null)
                return false;

            static if (is(Type == float) || is(Type == double))
                return this.value.isClose(other);
            else
                return (*cast(Type*)&this.value) == (*cast(Type*)&other);
        }

        ///
        bool opEquals(scope Result!Type other) const @trusted {
            if (error.info.message !is null)
                return other.error.info.message !is null;

            static if (is(Type == float) || is(Type == double))
                return this.value.isClose(other.value);
            else
                return (*cast(Type*)&this.value) == (*cast(Type*)&other.value);
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

///
struct ResultReference(Type) {
export:
    alias RCHandle = void delegate(bool addRef, scope void* _user) @safe nothrow @nogc;

    private {
        Type* _value;
        void* _user;

        RCHandle _rcHandle;
    }

    ///
    ErrorInfo error;

scope nothrow @nogc @safe:

    ///
    this(scope return Type* value, scope return void* user, scope return RCHandle rcHandle) @trusted {
        assert(value !is null);
        assert(rcHandle !is null);

        this._value = value;
        this._user = user;
        this._rcHandle = rcHandle;
    }

    ///
    this(ErrorInfo errorInfo, string moduleName = __MODULE__, int line = __LINE__) {
        error = errorInfo;
        error.moduleName = moduleName;
        error.line = line;
        error.checked = false;
    }

    ///
    this(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        error = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    this(ref ResultReference other) @trusted {
        static foreach (i; 0 .. this.tupleof.length)
            this.tupleof[i] = other.tupleof[i];

        this.error.checked = false;

        if (this._rcHandle !is null)
            this._rcHandle(true, this._user);
    }

    ~this() @trusted {
        if (this._rcHandle !is null)
            this._rcHandle(false, this._user);
    }

    ///
    void opAssign(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        error = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    void opAssign(scope return ResultReference other) {
        this.__ctor(other);
    }

    ///
    void opAssign(Type value) {
        if (isNull || _value is null)
            return;
        *_value = value;
    }

    static if (__traits(hasMember, Type, "opAssign")) {
        ///
        auto opAssign(Args...)(Args args) {
            if (isNull)
                assert(0);
            return _value.opAssign(args);
        }
    }

    static if (__traits(hasMember, Type, "toHash")) {
        ///
        auto toHash() const {
            if (error.info.message !is null)
                return 0;
            return _value.toHash();
        }
    }

    ///
    @disable void opAssign(ref ResultReference other) const;
    ///
    @disable void opAssign(ResultReference other) const;
    ///
    @disable void opAssign(Type value) const;

    /// Will check and only error if there is an error.
    ref Type assumeOkay() @system {
        assert(opCast!bool(), error.toString().unsafeGetLiteral);
        assert(this._value !is null);
        return *_value;
    }

    ///
    bool opCast(T : bool)() {
        error.checked = true;
        return error.info.message is null;
    }

    ///
    bool opCast(T : bool)() @trusted const {
        assert(!__ctfe, "Don't check for error on const in CTFE");

        (cast(ErrorInfo*)&error).checked = true;
        return error.info.message is null;
    }
    ///
    bool isNull() @trusted const {
        if (!error.checked)
            assert(0, "You forgot to check if value had an error. assert(thing, thing.error.toString());");

        assert(error.info.message is null && _value !is null, error.toString().unsafeGetLiteral);

        static if (__traits(hasMember, Type, "isNull")) {
            return _value.isNull;
        } else
            return false;
    }

    /// Will verify that you checked
    ref Type get() return @trusted {
        if (!error.checked)
            assert(0, "You forgot to check if value had an error. assert(thing, thing.error.toString());");

        assert(opCast!bool(), error.toString().unsafeGetLiteral);
        assert(_value !is null);
        return *_value;
    }

    ///
    alias get this;

    ///
    bool opEquals(scope const ErrorMessage other) const {
        return error.info.id !is null && error.info.id == other.id;
    }

    ///
    bool opEquals(scope const Type other) const @trusted {
        if (error.info.message !is null || _value is null)
            return false;

        static if (is(Type == float) || is(Type == double))
            return (*this._value).isClose(other);
        else
            return (*cast(Type*)this._value) == (*cast(Type*)&other);
    }

    ///
    bool opEquals(scope const Result!Type other) const @trusted {
        if (error.isSet || other.error.isSet || error.info.message !is null || _value is null || other.error.info.message !is null)
            return error.isSet && other.error.isSet;
        static if (is(Type == float) || is(Type == double))
            return (*this._value).isClose(other.value);
        else
            return (*cast(Type*)this._value) == (*cast(Type*)&other.value);
    }

    ///
    bool opEquals(scope const ResultReference!Type other) const @trusted {
        if (error.isSet || other.error.isSet || error.info.message !is null || _value is null ||
                other.error.info.message !is null || other._value is null)
            return error.isSet && other.error.isSet;
        static if (is(Type == float) || is(Type == double))
            return (*this._value).isClose(*other._value);
        else
            return (*cast(Type*)this._value) == (*cast(Type*)&other._value);
    }
}
