/**
The main API for memory allocators.

Posix: On fork will set global allocator to malloc.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.api;
import sidero.base.attributes;
import sidero.base.typecons : Ternary;

///
private {
    import sidero.base.synchronization.mutualexclusion;

    __gshared TestTestSetLockInline globalAllocatorLock;
    __gshared RCAllocator globalAllocator_;
}

export:

/**
    Get the global allocator for the process

    Any memory returned can be assumed to be aligned to GoodAlignment or larger.
 */
RCAllocator globalAllocator() @trusted nothrow @nogc {
    globalAllocatorLock.pureLock;
    scope (exit)
        globalAllocatorLock.unlock;

    if (globalAllocator_.isNull) {
        version (all) {
            import sidero.base.allocators.predefined;

            globalAllocator_ = RCAllocator.instanceOf!GeneralPurposeAllocator();
        } else {
            import sidero.base.allocators.mapping.malloc;

            globalAllocator_ = RCAllocator.instanceOf!Mallocator();
        }

        version (Posix) {
            import sidero.base.allocators.mapping.malloc;
            import core.sys.posix.pthread : pthread_atfork;

            extern (C) static void onForkForGlobalAllocator() {
                globalAllocator_ = RCAllocator.instanceOf!Mallocator();
            }

            // we need to clear out the state due to locks not getting cleared *sigh*
            pthread_atfork(null, null, &onForkForGlobalAllocator);
        }
    }

    return globalAllocator_;
}

/**
    Set the global allocator for the process

    Warning: this allocator MUST return memory aligned to GoodAlignment or larger.
 */
void globalAllocator(RCAllocator allocator) @system nothrow @nogc {
    globalAllocatorLock.pureLock;
    scope (exit)
        globalAllocatorLock.unlock;

    globalAllocator_ = allocator;
}

/// Reference counted memory allocator interface.
struct RCAllocator {
    private @PrettyPrintIgnore {
        void delegate() @safe @nogc pure nothrow refAdd_;
        void delegate() @safe @nogc pure nothrow refSub_;

        void[]delegate(size_t, TypeInfo ti = null) @safe @nogc pure nothrow allocate_;
        bool delegate(scope void[]) @safe @nogc pure nothrow deallocate_;
        bool delegate(scope ref void[], size_t) @safe @nogc pure nothrow reallocate_;
        Ternary delegate(scope void[]) @safe @nogc pure nothrow owns_;
        bool delegate() @safe @nogc pure nothrow deallocateAll_;
        bool delegate() @safe @nogc pure nothrow empty_;
    }

export @safe @nogc pure nothrow:

    /// Acquire an RCAllocator from a built up memory allocator with support for getting the default instance from its static member.
    static RCAllocator instanceOf(T)(T* value = defaultInstanceForAllocator!T) @trusted {
        return instanceOf_!T(value);
    }

    private static RCAllocator instanceOf_(T)(T* value) @system pure {
        assert(value !is null, "Allocators must either have a global instance or be heap allocated, neither was passed in.");

        static if (__traits(hasMember, T, "NeedsLocking"))
            static assert(!T.NeedsLocking,
                    "An allocator must not require locking to be thread safe. Remove or explicitly lock it to a thread.");

        static assert(__traits(hasMember, T, "allocate"), "Allocators must be able to allocate memory");
        static assert(__traits(hasMember, T, "deallocate"), "Allocators must be able to deallocate memory");

        RCAllocator ret;

        ret.deallocate_ = &value.deallocate;
        ret.allocate_ = &value.allocate;

        static if (__traits(hasMember, T, "reallocate"))
            ret.reallocate_ = &value.reallocate;
        static if (__traits(hasMember, T, "owns"))
            ret.owns_ = &value.owns;
        static if (__traits(hasMember, T, "deallocateAll"))
            ret.deallocateAll_ = &value.deallocateAll;
        static if (__traits(hasMember, T, "empty"))
            ret.empty_ = &value.empty;

        static if (__traits(hasMember, T, "refAdd") && __traits(hasMember, T, "refSub")) {
            ret.refAdd_ = &value.refAdd;
            ret.refSub_ = &value.refSub;
        } else {
            static assert(!(__traits(hasMember, T, "refAdd") || __traits(hasMember, T, "refSub")),
                    "You must provide both refAdd and refSub methods for an allocator to be reference counted.");
        }

        return ret;
    }

scope:

    ///
     ~this() {
        if (refSub_ !is null)
            refSub_();
    }

    ///
    this(return scope ref RCAllocator other) @trusted {
        this.tupleof = other.tupleof;

        if (refAdd_ !is null)
            refAdd_();
    }

    ///
    //@disable this(this);

    ///
    void opAssign(scope RCAllocator other) @trusted {
        this.tupleof = other.tupleof;

        if (refAdd_ !is null)
            refAdd_();
    }

    ///
    bool isNull() const {
        return deallocate_ is null || allocate_ is null;
    }

    @disable this(typeof(allocate_) allocate, typeof(deallocate_) deallocate, typeof(reallocate_) reallocate,
            typeof(refAdd_) refAdd = null, typeof(refSub_) refSub = null) const;

    @disable this(ref const RCAllocator other) const;

    @disable void opAssign(scope ref RCAllocator other) const;
    @disable void opAssign(scope RCAllocator other) const;

    ///
    bool opCast(T : bool)() scope const {
        return !isNull;
    }

    @disable auto opCast(T)();

    ///
    bool deallocate(scope void[] data) {
        assert(!isNull);
        assert(data.ptr !is null);
        assert(data.length > 0);
        return deallocate_(data);
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        assert(!isNull);
        return allocate_(size, ti);
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if (reallocate_ is null)
            return false;
        return reallocate_(array, newSize);
    }

    ///
    Ternary owns(scope void[] array) {
        if (owns_ is null)
            return Ternary.Unknown;
        return owns_(array);
    }

    ///
    bool deallocateAll() {
        if (deallocateAll_ is null)
            return false;
        return deallocateAll_();
    }

    ///
    bool empty() {
        if (empty_ is null)
            return false;
        return empty_();
    }

    ///
    string toString() const {
        return isNull ? "null" : "non-null";
    }
}

///
unittest {
    struct Thing {
        int x;
    }

    RCAllocator allocator = globalAllocator();

    Thing* thing = allocator.make!Thing(4);
    assert(thing !is null);
    assert(thing.x == 4);

    struct Thing2 {
        int call(int a) {
            return a + 3;
        }
    }

    Thing2* thing2 = allocator.make!Thing2();
    assert(thing2 !is null);
    assert(thing2.call(1) == 4);
}

///
unittest {
    RCAllocator allocator = globalAllocator();

    int[] data = allocator.makeArray!int(5);
    assert(data.length == 5);
}

/// Allocate a set of arrays all at once using a buffer (will automatically deallocate all when called).
template makeBufferedArrays(Types...) if (Types.length > 0) {
    auto makeBufferedArrays(Allocator)(ref Allocator allocator, size_t[] sizes...) {
        assert(sizes.length == Types.length);

        static struct Result {
            MakeAllArray!Types _;
            alias _ this;
        }

        Result ret;
        allocator.deallocateAll;

        static foreach (i; 0 .. Types.length)
            ret[i] = allocator.makeArray!(Types[i])(sizes[i]);

        return ret;
    }
}

///
/+unittest {
    import sidero.base.allocators.predefined;

    GeneralPurposeAllocator allocator;
    auto got = allocator.makeBufferedArrays!(int, float)(2, 4);

    static assert(is(typeof(got[0]) == int[]));
    static assert(is(typeof(got[1]) == float[]));

    assert(got[0].length == 2);
    assert(got[1].length == 4);
}+/

template stateSize(T) {
    import std.traits : Fields, isNested;

    static if (is(T == class) || is(T == interface))
        enum stateSize = __traits(classInstanceSize, T);
    else static if (is(T == struct) || is(T == union))
        enum stateSize = Fields!T.length || isNested!T ? T.sizeof : 0;
    else static if (is(T == void))
        enum size_t stateSize = 0;
    else
        enum stateSize = T.sizeof;
}

/// A subset of the std.experimental.allocator one, as that one can use exceptions.
auto make(T, Allocator, Args...)(scope auto ref Allocator alloc, return scope auto ref Args args) @trusted {
    import core.lifetime : emplace;

    size_t sizeToAllocate = stateSize!T;
    if (sizeToAllocate == 0)
        sizeToAllocate = 1;

    version (D_BetterC) {
        void[] array = alloc.allocate(sizeToAllocate);
    } else {
        void[] array = alloc.allocate(sizeToAllocate, typeid(T));
    }

    static if (is(T == class)) {
        auto ret = cast(T)array.ptr;
    } else {
        auto ret = cast(T*)array.ptr;
    }

    if (array is null)
        return typeof(ret).init;
    assert(ret !is null);

    version (D_BetterC) {
        emplace!T(ret, args);
    } else {
        try {
            emplace!T(ret, args);
        } catch (Exception) {
            alloc.deallocate(array);
            ret = null;
        }
    }
    return ret;
}

/// Similar to std.experimental.allocator one
T[] makeArray(T, Allocator)(auto ref Allocator alloc, size_t length) @trusted {
    import sidero.base.allocators.utils : fillUninitializedWithInit;

    if (length == 0)
        return null;

    static if (T.sizeof <= 1) {
        const sizeToAllocate = length * T.sizeof;
    } else {
        import core.checkedint : mulu;

        bool overflow;
        const sizeToAllocate = mulu(length, T.sizeof, overflow);
        if (overflow)
            return null;
    }

    version (D_BetterC) {
        void[] array = alloc.allocate(sizeToAllocate);
    } else {
        void[] array = alloc.allocate(sizeToAllocate, typeid(T[]));
    }

    if (array is null)
        return null;
    else if (array.length < sizeToAllocate) {
        alloc.deallocate(array);
        return null;
    }

    T[] ret = (cast(T*)array.ptr)[0 .. length];
    fillUninitializedWithInit(ret);

    return ret;
}

/// Ditto
T[] makeArray(T, Allocator)(auto ref Allocator alloc, const(T)[] initValues) @trusted {
    import sidero.base.allocators.utils : fillUninitializedWithInit;

    T[] ret = alloc.makeArray!T(initValues.length);

    if (ret is null)
        return null;
    else if (ret.length != initValues.length) {
        alloc.deallocate((cast(void*)ret.ptr)[0 .. T.sizeof * ret.length]);
        return null;
    } else {
        fillUninitializedWithInit(ret);

        foreach (i, ref v; initValues) {
            ret[i] = *cast(T*)&v;
        }

        return ret;
    }
}

/// Mostly a copy of the one in std.experimental.allocator.
bool expandArray(T, Allocator)(auto ref Allocator alloc, scope ref T[] array, size_t delta) @trusted {
    import sidero.base.allocators.utils : fillUninitializedWithInit;

    if (delta == 0)
        return true;
    if (array is null)
        return false;

    size_t originalLength = array.length;
    void[] temp = (cast(void*)array.ptr)[0 .. T.sizeof * array.length];

    if (!alloc.reallocate(temp, temp.length + (T.sizeof * delta))) {
        return false;
    }

    array = (cast(T*)temp.ptr)[0 .. originalLength + delta];
    fillUninitializedWithInit(array[originalLength .. $]);
    return true;
}

/// A subset of the std.experimental.allocator one, as that one can use exceptions.
bool shrinkArray(T, Allocator)(auto ref Allocator alloc, scope ref T[] array, size_t delta) @trusted {
    if (delta > array.length)
        return false;

    version (D_BetterC) {
        foreach (ref item; array[$ - delta .. $]) {
            static if (__traits(hasMember, T, "__dtor"))
                item.__dtor;
            item = T.init;
        }
    } else {
        foreach (ref item; array[$ - delta .. $]) {
            try {
                item.destroy;
            } catch (Exception) {
            }
        }
    }

    if (delta == array.length) {
        alloc.deallocate(array);
        array = null;
        return true;
    }

    void[] temp = (cast(void*)array.ptr)[0 .. T.sizeof * array.length];
    bool result = alloc.reallocate(temp, temp.length - (delta * T.sizeof));
    array = cast(T[])temp;
    return result;
}

/// A subset of std.experimental.allocator one simplified to be faster to compile.
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type* p) {
    void[] toDeallocate = () @trusted { return (cast(void*)p)[0 .. Type.sizeof]; }();

    destroy(*p);
    alloc.deallocate(toDeallocate);

    p = null;
}

/// Ditto
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type p) if (is(Type == class) || is(Type == interface)) {
    if (p is null)
        return;

    static if (is(Type == interface)) {
        version (Windows) {
            import core.sys.windows.unknwn : IUnknown;

            static assert(!is(T : IUnknown), "COM interfaces can't be destroyed in " ~ __PRETTY_FUNCTION__);
        }
        auto ob = cast(Object)p;
    } else
        alias ob = p;

    void[] toDeallocate = () @trusted { return (cast(void*)ob)[0 .. typeid(ob).initializer.length]; }();

    destroy(p);
    alloc.deallocate(toDeallocate);
    p = null;
}

/// Ditto
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type[] array) {
    static if (!is(Type == void)) {
        foreach (ref e; array) {
            destroy(cast()e);
        }
    }

    void[] toDeallocate = () @trusted { return (cast(void*)array.ptr)[0 .. Type.sizeof * array.length]; }();

    alloc.deallocate(toDeallocate);
    array = null;
}

private:
import std.meta : AliasSeq;

T* defaultInstanceForAllocator(T)() {
    import std.traits : isPointer;

    static if (__traits(hasMember, T, "instance")) {
        static if (isPointer!(typeof(__traits(getMember, T, "instance"))))
            return T.instance;
        else
            return &T.instance;
    } else
        return null;
}

template MakeAllArray(Types...) {
    alias MakeAllArray = AliasSeq!();

    static foreach (Type; Types) {
        MakeAllArray = AliasSeq!(MakeAllArray, Type[]);
    }
}
