module sidero.base.errors.result;
import sidero.base.errors.message;
import sidero.base.attributes;
import sidero.base.internal.logassert;
import sidero.base.containers.utils : genericCompare;
import sidero.base.math.utils;
import std.traits : isPointer;

export:

///
auto result(Type)(Type argument) {
    import std.traits : Unqual;

    static if(is(UnQual!Type == ErrorMessage)) {
        return ErrorResult(argument);
    } else {
        return Result!Type(argument);
    }
}

///
alias ErrorResult = Result!void;

///
@mustuse struct Result(Type) {
export:
    ///
    enum HaveValue = !is(Type == void);

    static if(HaveValue) {
        private {
            Type value;
        }

        void opAssign(return scope Type arg) scope @trusted nothrow @nogc {
            this.destroy;
            cast(void)this.__ctor(arg);
        }

        static if(__traits(hasMember, Type, "opAssign")) {
            ///
            auto opAssign(Args...)(return scope Args args) {
                if(isNull)
                    assert(0);
                this.error__ = ErrorInfo.init;
                return value.opAssign(args);
            }
        }
    }

    package(sidero.base) ErrorInfo error__;

scope nothrow @nogc @safe:

    static if(HaveValue) {
        ///
        this(return scope Type value) @trusted {
            this.value = value;
        }

        /// Will verify that you checked
        ref Type get(string moduleName = __MODULE__, int line = __LINE__) return @trusted {
            logAssert(error__.checked,
                    "You forgot to check if value had an error for " ~ Type.stringof ~ ". assert(thing, thing.error.toString());",
                    this.error__, moduleName, line);
            logAssert(!error__.isSet(), null, this.error__, moduleName, line);
            return value;
        }

        ///
        alias get this;

        /// Will check and only error if there is an error.
        ref Type assumeOkay() return @system {
            assert(!error__.isSet(), error__.toString().unsafeGetLiteral);
            return value;
        }
    }

    ///
    this(ErrorInfo errorInfo, string moduleName = __MODULE__, int line = __LINE__) {
        error__ = errorInfo;
        error__.moduleName = moduleName;
        error__.line = line;
        error__.checked = false;
    }

    ///
    this(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        error__ = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    void opAssign(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        this.destroy;
        error__ = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    void opAssign(return scope Result other) @trusted {
        if(__ctfe) {
            this.tupleof = Result.init.tupleof;
        } else {
            this.destroy;
        }

        cast(void)this.__ctor(other);
    }

    /// Will check and only error if there is an error.
    Type assumeOkay(string moduleName = __MODULE__, int line = __LINE__) return @system {
        logAssert(!error__.isSet(), null, this.error__, moduleName, line);
        static if(HaveValue) {
            return value;
        }
    }

    ///
    this(return scope ref Result other) @trusted {
        this.tupleof = other.tupleof;

        this.error__.checked = false;
    }

    ~this() {
    }

    ///
    ErrorInfo getError() const {
        return cast(ErrorInfo)this.error__;
    }

    ///
    bool opCast(T : bool)() {
        error__.checked = true;
        return error__.info.message is null;
    }

    ///
    bool opCast(T : bool)() @trusted const {
        assert(!__ctfe, "Don't check for error on const in CTFE");

        (cast(ErrorInfo*)&error__).checked = true;
        return error__.info.message is null;
    }

    ///
    bool isNull(string moduleName = __MODULE__, int line = __LINE__) @trusted const {
        logAssert(error__.checked,
                "You forgot to check if value had an error for " ~ Type.stringof ~ ". assert(thing, thing.error.toString());",
                this.error__, moduleName, line);
        logAssert(!error__.isSet(), null, this.error__, moduleName, line);

        static if(__traits(hasMember, Type, "isNull")) {
            return value.isNull;
        } else static if(isPointer!Type) {
            return value is null;
        } else
            return false;
    }

    ///
    auto toHash() const {
        import sidero.base.hash.utils;

        if(error__.info.id !is null)
            return hashOf(error__.info);
        static if(__traits(hasMember, Type, "toHash") && !__traits(isDisabled, Type.toHash)) {
            return value.toHash();
        } else
            return hashOf();
    }

    ///
    bool opEquals(scope const ErrorMessage other) const {
        return error__.info.id !is null && error__.info.id == other.id;
    }

    static if(HaveValue) {
        ///
        bool opEquals(scope const Type other) const @trusted {
            if(error__.info.message !is null)
                return false;
            else
                return genericCompare(*cast(Type*)&this.value, *cast(Type*)&other) == 0;
        }

        ///
        bool opEquals(scope Result!Type other) const @trusted {
            if(error__.info.message !is null)
                return other.error__.info.message !is null;
            else
                return genericCompare(*cast(Type*)&this.value, *cast(Type*)&other.value) == 0;
        }
    }
}

///
unittest {
    ErrorResult got = ErrorResult();

    if(got) {
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

    if(got) {
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

    if(success1 && success2) {
        // ok

        if(success1 && success2 && error) {
            // not so ok
            assert(0, "Null, have error");
        }
    } else {
        assert(0, "Null, but no error");
    }
}

///
@mustuse struct ResultReference(Type) {
export:
    alias RCHandle = void delegate(bool addRef, scope void* _user) @safe nothrow @nogc;

    private {
        Type* _value;
        void* _user;

        RCHandle _rcHandle;
    }

    package(sidero.base) ErrorInfo error__;

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
        error__ = errorInfo;
        error__.moduleName = moduleName;
        error__.line = line;
        error__.checked = false;
    }

    ///
    this(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        error__ = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    this(return scope ref ResultReference other) @trusted {
        this.tupleof = other.tupleof;
        this.error__.checked = false;

        if(this._rcHandle !is null)
            this._rcHandle(true, this._user);
    }

    ~this() @trusted {
        if(this._rcHandle !is null)
            this._rcHandle(false, this._user);
    }

    ///
    void opAssign(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        this.destroy;
        error__ = ErrorInfo(errorMessage, moduleName, line);
    }

    ///
    void opAssign(return scope ResultReference other) {
        this.destroy;
        cast(void)this.__ctor(other);
    }

    ///
    void opAssign(return scope ResultReferenceAlternative!Type other) {
        this.destroy;
        this.tupleof = other.tupleof;
        cast(void)this.__ctor(this);
    }

    ///
    void opAssign(Type value) {
        if(!this || isNull || _value is null)
            return;
        *_value = value;
    }

    static if(__traits(hasMember, Type, "opAssign")) {
        ///
        auto opAssign(Args...)(Args args) {
            if(!this || isNull || _value is null)
                assert(0);
            return _value.opAssign(args);
        }
    }

    /// Use this to get around forward reference bugs
    ResultReferenceAlternative!Type asAlternative() return scope {
        ResultReferenceAlternative!Type ret;
        ret.tupleof = this.tupleof;
        ret.__ctor(ret);

        return ret;
    }

    ///
    auto toHash() const {
        import sidero.base.hash.utils;

        if(error__.info.id !is null)
            return hashOf(error__.info);
        static if(__traits(hasMember, Type, "toHash") && !__traits(isDisabled, Type.toHash)) {
            return _value.toHash();
        } else
            return hashOf();
    }

    ///
    @disable void opAssign(ref ResultReference other) const;
    ///
    @disable void opAssign(ResultReference other) const;
    ///
    @disable void opAssign(Type value) const;

    /// Will check and only error if there is an error.
    ref Type assumeOkay(string moduleName = __MODULE__, int line = __LINE__) return @system {
        logAssert(!error__.isSet(), null, this.error__, moduleName, line);
        assert(this._value !is null);
        return *_value;
    }

    ///
    ErrorInfo getError() const {
        return cast(ErrorInfo)this.error__;
    }

    ///
    bool opCast(T : bool)() {
        error__.checked = true;
        return error__.info.message is null;
    }

    ///
    bool opCast(T : bool)() @trusted const {
        assert(!__ctfe, "Don't check for error on const in CTFE");

        (cast(ErrorInfo*)&error__).checked = true;
        return error__.info.message is null;
    }

    ///
    bool isNull(string moduleName = __MODULE__, int line = __LINE__) @trusted const {
        logAssert(error__.checked,
                "You forgot to check if value had an error for " ~ Type.stringof ~ ". assert(thing, thing.error.toString());",
                this.error__, moduleName, line);
        logAssert(!error__.isSet(), null, this.error__, moduleName, line);

        if(_value is null)
            return true;

        static if(__traits(hasMember, Type, "isNull")) {
            return _value.isNull;
        } else static if(isPointer!Type) {
            return *_value is null;
        } else
            return false;
    }

    /// Will verify that you checked
    ref Type get(string moduleName = __MODULE__, int line = __LINE__) return @trusted {
        logAssert(error__.checked,
                "You forgot to check if value had an error for " ~ Type.stringof ~ ". assert(thing, thing.error.toString());",
                this.error__, moduleName, line);
        logAssert(!error__.isSet(), null, this.error__, moduleName, line);
        logAssert(_value !is null, "Reference to value has null reference, cannot return value", moduleName, line);
        return *_value;
    }

    ///
    alias get this;

    ///
    bool opEquals(scope const ErrorMessage other) const {
        return error__.info.id !is null && error__.info.id == other.id;
    }

    ///
    bool opEquals(scope const Type other) const @trusted {
        if(error__.info.message !is null || _value is null)
            return false;

        static if(is(Type == float) || is(Type == double))
            return (*this._value).isClose(other);
        else {
            static if(__traits(hasMember, Type, "isNull")) {
                if(_value.isNull == other.isNull)
                    return true;
            }

            return genericCompare(*cast(Type*)this._value, *cast(Type*)&other) == 0;
        }
    }

    ///
    bool opEquals()(scope Result!Type other) const @trusted {
        if(error__.isSet || other.error__.isSet || error__.info.message !is null || _value is null || other.error__.info.message !is null)
            return error__.isSet && other.error__.isSet;
        else {
            static if(__traits(hasMember, Type, "isNull")) {
                if(_value.isNull == other.isNull)
                    return true;
            }

            return genericCompare(*cast(Type*)this._value, *cast(Type*)&other.value) == 0;
        }
    }

    ///
    bool opEquals()(scope const Result!Type other) const @trusted {
        if(error__.isSet || other.error__.isSet || error__.info.message !is null || _value is null || other.error__.info.message !is null)
            return error__.isSet && other.error__.isSet;
        else if(this.isNull && other.isNull)
            return true;
        else
            return genericCompare(*cast(Type*)this._value, *cast(Type*)&other.value) == 0;
    }

    ///
    bool opEquals(scope ResultReference!Type other) const @trusted {
        if(error__.isSet || other.error__.isSet || error__.info.message !is null || _value is null ||
                other.error__.info.message !is null || other._value is null)
            return error__.isSet && other.error__.isSet;
        else if(this.isNull && other.isNull)
            return true;
        else
            return genericCompare(*cast(Type*)this._value, *cast(Type*)other._value) == 0;
    }

    ///
    bool opEquals(scope const ResultReference!Type other) const @trusted {
        if(error__.isSet || other.error__.isSet || error__.info.message !is null || _value is null ||
                other.error__.info.message !is null || other._value is null)
            return error__.isSet && other.error__.isSet;
        else if(this.isNull && other.isNull)
            return true;
        else
            return genericCompare(*cast(Type*)this._value, *cast(Type*)other._value) == 0;
    }
}

struct ResultReferenceAlternative(Type) {
export:
    alias RCHandle = void delegate(bool addRef, scope void* _user) @safe nothrow @nogc;

    private {
        Type* _value;
        void* _user;

        RCHandle _rcHandle;
    }

    package(sidero.base) ErrorInfo error__;

scope nothrow @nogc @safe:

    ///
    this(return scope ref ResultReferenceAlternative other) @trusted {
        this.tupleof = other.tupleof;
        this.error__.checked = false;

        if(this._rcHandle !is null)
            this._rcHandle(true, this._user);
    }

    ~this() @trusted {
        if(this._rcHandle !is null)
            this._rcHandle(false, this._user);
    }

    ///
    bool opCast(T : bool)() {
        error__.checked = true;
        return error__.info.message is null;
    }

    ///
    bool opCast(T : bool)() @trusted const {
        assert(!__ctfe, "Don't check for error on const in CTFE");

        (cast(ErrorInfo*)&error__).checked = true;
        return error__.info.message is null;
    }

    /// Will verify that you checked
    ref Type get(string moduleName = __MODULE__, int line = __LINE__) return @trusted {
        logAssert(error__.checked,
                "You forgot to check if value had an error for " ~ Type.stringof ~ ". assert(thing, thing.error.toString());",
                this.error__, moduleName, line);
        logAssert(!error__.isSet(), null, this.error__, moduleName, line);
        logAssert(_value !is null, "Reference to value has null reference, cannot return value", moduleName, line);
        return *_value;
    }

    ///
    alias get this;
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
        if(allocator.isNull)
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
        import sidero.base.internal.atomic;

        State* state = cast(State*)user;
        assert(state !is null);

        if(addRef)
            atomicIncrementAndLoad(state.refCount, cast(ptrdiff_t)1);
        else if(atomicDecrementAndLoad(state.refCount, cast(ptrdiff_t)1) == 0) {
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
