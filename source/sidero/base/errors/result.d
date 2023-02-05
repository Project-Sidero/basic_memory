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
            auto opAssign(Args...)(return scope Args args) {
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
        this(return scope Type value) @trusted {
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
    void opAssign(return scope Result other) {
        this.__ctor(other);
    }

    ///
    this(return scope ref Result other) scope @trusted {
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
    this(return scope Type* value, return scope void* user, return scope RCHandle rcHandle) @trusted {
        assert(value !is null);
        assert(rcHandle !is null);

        this._value = value;
        this._user = user;
        this._rcHandle = rcHandle;
    }

    ///
    this(return scope RCResultValue!Type wrapped) @trusted {
        assert(!wrapped.isNull);

        this._value = wrapped.get;
        this._user = wrapped.getUser();
        this._rcHandle = &wrapped.rc;
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
    this(return scope ref ResultReference other) @trusted {
        this.tupleof = other.tupleof;
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
    void opAssign(return scope ResultReference other) {
        this.tupleof = other.tupleof;
        this.error.checked = false;

        if (this._rcHandle !is null)
            this._rcHandle(true, this._user);
    }

    ///
    void opAssign(Type value) {
        if (!this || isNull || _value is null)
            return;
        *_value = value;
    }

    static if (__traits(hasMember, Type, "opAssign")) {
        ///
        auto opAssign(Args...)(Args args) {
            if (!this || isNull || _value is null)
                assert(0);
            return _value.opAssign(args);
        }
    }

    static if (__traits(hasMember, Type, "toHash")) {
        ///
        auto toHash() const {
            if (!this)
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

        assert(error.info.message is null, error.toString().unsafeGetLiteral);

        if (_value is null)
            return true;

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
    bool opEquals(scope Result!Type other) const @trusted {
        if (error.isSet || other.error.isSet || error.info.message !is null || _value is null || other.error.info.message !is null)
            return error.isSet && other.error.isSet;
        static if (is(Type == float) || is(Type == double))
            return (*this._value).isClose(other.value);
        else
            return (*cast(Type*)this._value) == other.value;
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
    bool opEquals(scope ResultReference!Type other) const @trusted {
        if (error.isSet || other.error.isSet || error.info.message !is null || _value is null ||
        other.error.info.message !is null || other._value is null)
            return error.isSet && other.error.isSet;
        static if (is(Type == float) || is(Type == double))
            return (*this._value).isClose(*other._value);
        else
            return (*cast(Type*)this._value) == *other._value;
    }

    ///
    bool opEquals(scope const ResultReference!Type other) const @trusted {
        if (error.isSet || other.error.isSet || error.info.message !is null || _value is null ||
                other.error.info.message !is null || other._value is null)
            return error.isSet && other.error.isSet;
        static if (is(Type == float) || is(Type == double))
            return (*this._value).isClose(*other._value);
        else
            return (*cast(Type*)this._value) == (*cast(Type*)other._value);
    }
}

/// Compatible with ResultReference, should not be copied around, only passed directly to ResultReference!
struct RCResultValue(Type) {
    private {
        import sidero.base.allocators;
        State* state;

        static struct State {
            shared(ptrdiff_t) refCount;
            Type value;
            RCAllocator allocator;
        }
    }

export @safe nothrow @nogc:

    ///
    this(Type value, return scope RCAllocator allocator = RCAllocator.init) scope @trusted {
        if (allocator.isNull)
            allocator = globalAllocator();

        state = allocator.make!State;
        assert(this.state !is null);

        state.allocator = allocator;
        state.refCount = 1;
        state.value = value;
    }

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    void rc(bool addRef, scope void* user) scope @trusted {
        import core.atomic : atomicOp, atomicLoad;

        State* state = cast(State*)user;
        assert(state !is null);

        if (addRef)
            atomicOp!"+="(state.refCount, cast(ptrdiff_t)1);
        else if (atomicOp!"-="(state.refCount, cast(ptrdiff_t)1) == 0) {
            RCAllocator alloc = state.allocator;
            alloc.dispose(state);
        }
    }

    /// Unsafe
    void* getUser() scope return @system {
        return state;
    }

    /// Unsafe
    Type* get() scope return @system {
        assert(state !is null);
        return &state.value;
    }
}
