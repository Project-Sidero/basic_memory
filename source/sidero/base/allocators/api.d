/**
The main API for memory allocators.

Posix: On fork will set global allocator to malloc.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2022-2024 Richard Andrew Cattermole
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
    scope(exit)
        globalAllocatorLock.unlock;

    if(globalAllocator_.isNull) {
        version(all) {
            import sidero.base.allocators.predefined;

            globalAllocator_ = RCAllocator.instanceOf!GeneralPurposeAllocator();
        } else {
            import sidero.base.allocators.mapping.malloc;

            globalAllocator_ = RCAllocator.instanceOf!Mallocator();
        }

        version(Posix) {
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
    scope(exit)
        globalAllocatorLock.unlock;

    globalAllocator_ = allocator;
}

/**
Gives a memory allocator suitable to allocate a given type.

If that memory allocator can contain GC memory, it will be a compatible to GC allocator.

If GC compatibility is not needed, it will use malloc instead of the general purpose allocator.

Warning: not all allocators returned by this offer ownership tests. Therefore you must be careful to match deallocation to allocation allocator.
*/
RCAllocator allocatorGivenType(T)(bool canContainGCMemory = true) {
    import sidero.base.traits : hasIndirections;

    enum HasIndirections = hasIndirections!T;

    static if(HasIndirections) {
        if(canContainGCMemory) {
            import sidero.base.allocators.predefined;

            return RCAllocator.instanceOf!GeneralPurposeAllocator();
        } else {
            import sidero.base.allocators.mapping.malloc;

            return RCAllocator.instanceOf!Mallocator();
        }
    } else {
        import sidero.base.allocators.mapping.malloc;

        return RCAllocator.instanceOf!Mallocator();
    }
}

///
unittest {
    struct A {
        int x;
    }

    struct B {
        int* ptr;
    }

    RCAllocator aAllocator = allocatorGivenType!A;
    RCAllocator bAllocatorGC = allocatorGivenType!B(true);
    RCAllocator bAllocatorNonGC = allocatorGivenType!B(false);

    A* a = aAllocator.make!A;
    B* bGC = bAllocatorGC.make!B;
    B* bNonGC = bAllocatorNonGC.make!B;

    assert(a !is null);
    assert(bGC !is null);
    assert(bNonGC !is null);

    aAllocator.dispose(a);
    bAllocatorGC.dispose(bGC);
    bAllocatorNonGC.dispose(bNonGC);
}

/// Reference counted memory allocator interface.
struct RCAllocator {
    private @PrettyPrintIgnore {
        RCAllocatorVtbl* state;
    }

export @safe @nogc pure nothrow:

    /// Acquire an RCAllocator from a built up memory allocator with support for getting the default instance from its static member.
    static RCAllocator instanceOf(T)(RCAllocatorInstance!T* value = defaultInstanceForAllocator!T) @trusted {
        return instanceOf_!(RCAllocatorInstance!T)(value);
    }

    private static RCAllocator instanceOf_(T)(T* value) @system pure {
        if(value is null)
            return RCAllocator.init;

        alias Parent = typeof(T.init.parent);

        static if(__traits(hasMember, Parent, "NeedsLocking"))
            static assert(!Parent.NeedsLocking,
                    "An allocator must not require locking to be thread safe. Remove or explicitly lock it to a thread.");

        static assert(__traits(hasMember, T, "allocate"), "Allocators must be able to allocate memory");
        static assert(__traits(hasMember, T, "deallocate"), "Allocators must be able to deallocate memory");

        value.vtbl.deallocate_ = &value.parent.deallocate;
        value.vtbl.allocate_ = &value.parent.allocate;

        static if(__traits(hasMember, Parent, "reallocate"))
            value.vtbl.reallocate_ = &value.parent.reallocate;
        static if(__traits(hasMember, Parent, "owns"))
            value.vtbl.owns_ = &value.parent.owns;
        static if(__traits(hasMember, Parent, "deallocateAll"))
            value.vtbl.deallocateAll_ = &value.parent.deallocateAll;
        static if(__traits(hasMember, Parent, "empty"))
            value.vtbl.empty_ = &value.parent.empty;

        static if(__traits(hasMember, Parent, "refAdd") && __traits(hasMember, Parent, "refSub")) {
            value.vtbl.refAdd_ = &value.parent.refAdd;
            value.vtbl.refSub_ = &value.parent.refSub;
        } else {
            static assert(!(__traits(hasMember, Parent, "refAdd") || __traits(hasMember, Parent, "refSub")),
                    "You must provide both refAdd and refSub methods for an allocator to be reference counted.");

        }

        RCAllocator ret;
        ret.state = &value.vtbl;
        return ret;
    }

scope:

     ~this() {
        if(state !is null && state.refSub_ !is null)
            state.refSub_();
    }

    this(return scope ref RCAllocator other) @trusted {
        this.tupleof = other.tupleof;

        if(state !is null && state.refAdd_ !is null)
            state.refAdd_();
    }

    ///
    void opAssign(scope RCAllocator other) @trusted {
        this.destroy;
        this.__ctor(other);
    }

    ///
    bool isNull() const {
        return state is null || state.allocate_ is null || state.deallocate_ is null;
    }

    @disable this(ref const RCAllocator other) const;

    @disable void opAssign(scope ref RCAllocator other) const;
    @disable void opAssign(scope RCAllocator other) const;

    ///
    bool opCast(T : bool)() scope const {
        return !isNull;
    }

    ///
    void[] allocate(size_t size, TypeInfo ti = null) {
        assert(!isNull);
        return state.allocate_(size, ti);
    }

    ///
    bool reallocate(scope ref void[] array, size_t newSize) {
        if(isNull || state.reallocate_ is null)
            return false;
        return state.reallocate_(array, newSize);
    }

    ///
    bool deallocate(scope void[] data) {
        assert(!isNull);
        assert(data.ptr !is null);
        assert(data.length > 0);
        return state.deallocate_(data);
    }

    ///
    Ternary owns(scope void[] array) {
        if(isNull || state.owns_ is null)
            return Ternary.Unknown;
        return state.owns_(array);
    }

    ///
    bool deallocateAll() {
        if(isNull || state.deallocateAll_ is null)
            return false;
        return state.deallocateAll_();
    }

    ///
    bool empty() {
        if(isNull || state.empty_ is null)
            return false;
        return state.empty_();
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

/// Wrap any allocator instance with this, provides virtual table storage.
struct RCAllocatorInstance(Parent) {
    ///
    Parent parent;

    alias parent this;

private @PrettyPrintIgnore:

    RCAllocatorVtbl vtbl;
}

private struct RCAllocatorVtbl {
    void delegate() @safe @nogc pure nothrow refAdd_;
    void delegate() @safe @nogc pure nothrow refSub_;

    void[]delegate(size_t, TypeInfo ti = null) @safe @nogc pure nothrow allocate_;
    bool delegate(scope void[]) @safe @nogc pure nothrow deallocate_;
    bool delegate(scope ref void[], size_t) @safe @nogc pure nothrow reallocate_;
    Ternary delegate(scope void[]) @safe @nogc pure nothrow owns_;
    bool delegate() @safe @nogc pure nothrow deallocateAll_;
    bool delegate() @safe @nogc pure nothrow empty_;
}

private template stateSize(T) {
    import std.traits : Fields, isNested;

    static if(is(T == class) || is(T == interface))
        enum stateSize = __traits(classInstanceSize, T);
    else static if(is(T == struct) || is(T == union))
        enum stateSize = Fields!T.length || isNested!T ? T.sizeof : 0;
    else static if(is(T == void))
        enum size_t stateSize = 0;
    else
        enum stateSize = T.sizeof;
}

/**
Allocate the memory to store an item of type `T` and emplace it based upon the arguments in `Args`.

Constructor of the type to allocate `T` determines attributes of this function.
If constructor does not throw, neither does this.

May be used in BetterC code.

See_Also: makeBufferedArrays, makeArray
*/
auto make(T, Allocator, Args...)(scope auto ref Allocator alloc, return scope auto ref Args args) @trusted {
    import core.lifetime : emplace;

    size_t sizeToAllocate = stateSize!T;
    if(sizeToAllocate == 0)
        sizeToAllocate = 1;

    version(D_BetterC) {
        void[] array = alloc.allocate(sizeToAllocate);
    } else {
        void[] array = alloc.allocate(sizeToAllocate, typeid(T));
    }

    static if(is(T == class)) {
        if(array is null)
            return (T).init;

        auto ret = cast(T)array.ptr;
    } else {
        if(array is null)
            return (T*).init;

        auto ret = cast(T*)array.ptr;
    }

    assert(ret !is null);

    version(D_BetterC) {
        emplace!T(ret, args);
    } else {
        try {
            emplace!T(ret, args);
        } catch(Exception) {
            alloc.deallocate(array);
            ret = null;
        }
    }

    return ret;
}

/**
Allocate a set of arrays from an allocator that is acting in the form of a buffer for a specific task.

Like `make` its attributes are inherited from any constructor called.

Warning: Each time this is called, deallocation of past allocations will take place, without destructors being run.

May be used in BetterC code.

See_Also: make, makeArray
*/
template makeBufferedArrays(Types...) if (Types.length > 0) {
    auto makeBufferedArrays(Allocator)(ref Allocator allocator, size_t[] sizes...) {
        assert(sizes.length == Types.length);

        static struct Result {
            MakeAllArray!Types _;
            alias _ this;
        }

        Result ret;
        allocator.deallocateAll;

        static foreach(i; 0 .. Types.length)
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

/**
Allocates an array.

Like `make` its attributes are inherited from any constructor called.

May be used in BetterC code.

See_Also: make, makeBufferedArrays
*/
T[] makeArray(T, Allocator)(auto ref Allocator alloc, size_t length) @trusted {
    import sidero.base.allocators.utils : fillUninitializedWithInit;

    if(length == 0)
        return null;

    static if(T.sizeof <= 1) {
        const sizeToAllocate = length * T.sizeof;
    } else {
        import core.checkedint : mulu;

        bool overflow;
        const sizeToAllocate = mulu(length, T.sizeof, overflow);
        if(overflow)
            return null;
    }

    version(D_BetterC) {
        void[] array = alloc.allocate(sizeToAllocate);
    } else {
        void[] array = alloc.allocate(sizeToAllocate, typeid(T[]));
    }

    if(array is null)
        return null;
    else if(array.length < sizeToAllocate) {
        alloc.deallocate(array);
        return null;
    }

    T[] ret = (cast(T*)array.ptr)[0 .. length];
    fillUninitializedWithInit(ret);

    return ret;
}

/**
Allocates an array using existing memory as basis.

Like `make` its attributes are inherited from any constructor called.

Warning: the returned slice, may be larger than the length of `initvalues`.

May be used in BetterC code.

See_Also: make, makeBufferedArrays
*/
T[] makeArray(T, Allocator)(auto ref Allocator alloc, const(T)[] initValues) @trusted {
    import sidero.base.allocators.utils : fillUninitializedWithInit;

    T[] ret = alloc.makeArray!T(initValues.length);

    if(ret is null)
        return null;
    else if(ret.length < initValues.length) {
        alloc.deallocate((cast(void*)ret.ptr)[0 .. T.sizeof * ret.length]);
        return null;
    } else {
        fillUninitializedWithInit(ret);

        foreach(i, ref v; initValues) {
            ret[i] = *cast(T*)&v;
        }

        return ret;
    }
}

/**
Grows an array in size, by the amount in `delta`.

May be used in BetterC code.

See_Also: shrinkArray
*/
bool expandArray(T, Allocator)(auto ref Allocator alloc, scope ref T[] array, size_t delta) @trusted {
    import sidero.base.allocators.utils : fillUninitializedWithInit;

    if(delta == 0)
        return true;
    else if(array is null)
        return false;

    size_t originalLength = array.length;
    void[] temp = (cast(void*)array.ptr)[0 .. T.sizeof * array.length];

    if(!alloc.reallocate(temp, temp.length + (T.sizeof * delta))) {
        return false;
    }

    array = (cast(T*)temp.ptr)[0 .. originalLength + delta];
    fillUninitializedWithInit(array[originalLength .. $]);
    return true;
}

///
unittest {
    import sidero.base.allocators.predefined;

    GeneralPurposeAllocator allocator;

    // 1 byte is too small to allocate for,
    //  there should be at least 4-8 bytes available to expand into.

    ubyte[] slice = allocator.makeArray!ubyte(1);
    assert(slice.length == 1);
    assert(allocator.expandArray(slice, 1));
    assert(slice.length == 2);

    allocator.dispose(slice);
}

/**
Shrinks an array in size, by the amount in `delta`.

May be used in BetterC code.

See_Also: expandArray
*/
bool shrinkArray(T, Allocator)(auto ref Allocator alloc, scope ref T[] array, size_t delta) @trusted {
    if(delta > array.length)
        return false;

    foreach(ref item; array[$ - delta .. $]) {
        item.destroy;
    }

    if(delta == array.length) {
        alloc.deallocate(array);
        array = null;
        return true;
    }

    void[] temp = (cast(void*)array.ptr)[0 .. T.sizeof * array.length];
    bool result = alloc.reallocate(temp, temp.length - (delta * T.sizeof));
    array = cast(T[])temp;
    return result;
}

///
unittest {
    import sidero.base.allocators.predefined;

    GeneralPurposeAllocator allocator;

    int[] slice = allocator.makeArray!int(2);
    assert(slice.length == 2);
    assert(allocator.shrinkArray(slice, 1));
    assert(slice.length == 1);

    allocator.dispose(slice);
}

/**
Calls destroy on `memory` and then deallocates it.

May be used in BetterC code.
*/
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type* memory) {
    void[] toDeallocate = () @trusted { return (cast(void*)memory)[0 .. Type.sizeof]; }();

    destroy(*memory);
    alloc.deallocate(toDeallocate);
}

/// Ditto
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type memory)
        if (is(Type == class) || is(Type == interface)) {
    if(memory is null)
        return;

    static if(is(Type == interface)) {
        version(Windows) {
            import core.sys.windows.unknwn : IUnknown;

            static assert(!is(T : IUnknown), "COM interfaces can't be destroyed in " ~ __PRETTY_FUNCTION__);
        }
        auto ob = cast(Object)memory;
    } else
        alias ob = memory;

    void[] toDeallocate = () @trusted { return (cast(void*)ob)[0 .. __traits(classInstanceSize, Type)]; }();

    version(D_BetterC) {
        static if(__traits(hasMember, Type, "__xdtor")) {
            (cast(void delegate()nothrow @nogc)&memory.__xdtor)();
        } else static if(__traits(hasMember, Type, "__dtor")) {
            (cast(void delegate()nothrow @nogc)&memory.__dtor)();
        }
        memory = null;
    } else {
        memory.destroy;
    }

    alloc.deallocate(toDeallocate);
}

/// Ditto
void dispose(Type, Allocator)(auto ref Allocator alloc, scope auto ref Type[] memory) {
    static if(!is(Type == void)) {
        foreach(ref e; memory) {
            destroy(cast()e);
        }
    }

    void[] toDeallocate = () @trusted { return (cast(void*)memory.ptr)[0 .. Type.sizeof * memory.length]; }();

    alloc.deallocate(toDeallocate);
}

private:
import std.meta : AliasSeq;

RCAllocatorInstance!T* defaultInstanceForAllocator(T)() {
    import std.traits : isPointer;

    static if(__traits(hasMember, T, "instance")) {
        static if(isPointer!(typeof(__traits(getMember, T, "instance"))))
            return T.instance;
        else
            return &T.instance;
    } else
        return null;
}

template MakeAllArray(Types...) {
    alias MakeAllArray = AliasSeq!();

    static foreach(Type; Types) {
        MakeAllArray = AliasSeq!(MakeAllArray, Type[]);
    }
}
