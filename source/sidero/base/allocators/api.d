/**
The main API for memory allocators.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.allocators.api;
import std.typecons : Ternary;

///
private {
    import sidero.base.parallelism.mutualexclusion;

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
    private {
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
    this(scope return ref RCAllocator other) @trusted {
        this.tupleof = other.tupleof;

        if (refAdd_ !is null)
            refAdd_();
    }

    ///
    @disable this(this);

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
            return Ternary.unknown;
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
unittest {
    import sidero.base.allocators.predefined;

    GeneralPurposeAllocator allocator;
    auto got = allocator.makeBufferedArrays!(int, float)(2, 4);

    static assert(is(typeof(got[0]) == int[]));
    static assert(is(typeof(got[1]) == float[]));

    assert(got[0].length == 2);
    assert(got[1].length == 4);
}

/// A subset of the std.experimental.allocator one, as that one can use exceptions.
auto make(T, Allocator, Args...)(scope auto ref Allocator alloc, scope return auto ref Args args) @trusted {
    import core.lifetime : emplace;
    size_t sizeToAllocate = T.sizeof;

    static if (is(T == class)) {
        sizeToAllocate = __traits(classInstanceSize, T);
    }

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

    static if (is(T == class)) {
        emplace(&ret);
    } else {
        emplace(ret);
    }

    static if (__traits(compiles, { ret.__ctor(args); })) {
        version (D_BetterC) {
            ret.__ctor(args);
        } else {
            try {
                ret.__ctor(args);
            } catch (Exception) {
                alloc.deallocate(array);
            }
        }
    } else {
        static if (is(T == class)) {
            static foreach (i; 0 .. Args.length) {
                ret.tupleof[i] = args[i];
            }
        } else {
            static foreach (i; 0 .. Args.length) {
                (*ret).tupleof[i] = args[i];
            }
        }
    }

    return ret;
}

/// Similar to std.experimental.allocator one
T[] makeArray(T, Allocator)(auto ref Allocator alloc, size_t length) @trusted {
    if (length == 0)
        return null;

    enum MaximumInArray = size_t.max / T.sizeof;

    if (length > MaximumInArray)
        return null;

    size_t sizeToAllocate = T.sizeof;

    static if (is(T == class)) {
        sizeToAllocate = __traits(classInstanceSize, T);
    }

    sizeToAllocate *= length;

    version (D_BetterC) {
        void[] array = alloc.allocate(sizeToAllocate);
    } else {
        void[] array = alloc.allocate(sizeToAllocate, typeid(T[]));
    }

    if (array is null)
        return null;

    T[] ret = cast(T[])array;

    static if (is(T == struct) || is(T == class) || is(T == union)) {
        foreach (i; 0 .. length) {
            import core.lifetime : emplace;
            emplace(&ret[i]);
        }
    } else static if (!is(T == void)) {
        foreach (ref v; ret)
            v = T.init;
    }

    return ret;
}

/// Ditto
T[] makeArray(T, Allocator)(auto ref Allocator alloc, const(T)[] initValues) @trusted {
    T[] ret = alloc.makeArray!T(initValues.length);

    if (ret is null)
        return null;
    else if (ret.length != initValues.length) {
        alloc.deallocate(cast(void[])ret);
        return null;
    } else {
        foreach (i, ref v; initValues)
            ret[i] = *cast(T*)&v;
        return ret;
    }
}

/// Mostly a copy of the one in std.experimental.allocator.
bool expandArray(T, Allocator)(scope auto ref Allocator alloc, scope ref T[] array, size_t delta) @trusted {
    if (delta == 0)
        return true;
    if (array is null)
        return false;

    size_t originalLength = array.length;
    void[] temp = cast(void[])array;

    if (!alloc.reallocate(temp, temp.length + (T.sizeof * delta))) {
        return false;
    }

    foreach(ref v; array[originalLength .. $])
        v = T.init;

    array = cast(T[])temp;
    return true;
}

/// A subset of the std.experimental.allocator one, as that one can use exceptions.
bool shrinkArray(T, Allocator)(scope auto ref Allocator alloc, scope ref T[] array, size_t delta) @trusted {
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

    auto temp = cast(void[])array;
    bool result = alloc.reallocate(temp, temp.length - (delta * T.sizeof));
    array = cast(T[])temp;
    return result;
}

/// A subset of std.experimental.allocator one simplified to be faster to compile.
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type* p) {
    destroy(*p);
    alloc.deallocate((cast(void*)p)[0 .. Type.sizeof]);
    p = null;
}

/// Ditto
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type p) if (is(Type == class) || is(Type == interface)) {
    if (!p)
        return;
    static if (is(Type == interface)) {
        version (Windows) {
            import core.sys.windows.unknwn : IUnknown;

            static assert(!is(T : IUnknown), "COM interfaces can't be destroyed in " ~ __PRETTY_FUNCTION__);
        }
        auto ob = cast(Object)p;
    } else
        alias ob = p;
    auto support = (cast(void*)ob)[0 .. typeid(ob).initializer.length];
    destroy(p);
    alloc.deallocate(support);
    p = null;
}

/// Ditto
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type[] array) {
    static if (!is(typeof(array[0]) == void)) {
        foreach (ref e; array) {
            destroy(cast()e);
        }
    }

    alloc.deallocate(cast(void[])array);
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
