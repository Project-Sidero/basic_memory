/**
The main API for memory allocators.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.memory.allocators.api;
import std.typecons : Ternary;
public import std.experimental.allocator : make, makeArray, expandArray, shrinkArray, dispose;

///
private {
    import sidero.base.parallelism.mutualexclusion;

    __gshared TestTestSetLockInline globalAllocatorLock;
    __gshared RCAllocator globalAllocator_;
}

/**
    Get the global allocator for the process

    Any memory returned can be assumed to be aligned to GoodAlignment or larger.
 */
RCAllocator globalAllocator() @trusted nothrow @nogc {
    globalAllocatorLock.lock;
    scope (exit)
        globalAllocatorLock.unlock;

    if (globalAllocator_.isNull) {
        version (all) {
            import sidero.base.memory.allocators.predefined;

            globalAllocator_ = RCAllocator.instanceOf!GeneralPurposeAllocator();
        } else {
            import sidero.base.memory.allocators.mapping.malloc;

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
    globalAllocatorLock.lock;
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

@safe @nogc pure nothrow:

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

    ///
    ~this() @safe @nogc pure nothrow {
        if (refSub_ !is null)
            refSub_();
    }

scope:

    ///
    this(ref RCAllocator other) {
        this.tupleof = other.tupleof;

        if (refAdd_ !is null)
            refAdd_();
    }

    ///
    @disable this(this);

    ///
    void opAssign(scope ref RCAllocator other) @trusted {
        this.__xdtor;
        opAssign_(&other);
    }

    ///
    void opAssign(scope RCAllocator other) @trusted {
        this.__xdtor;
        opAssign_(&other);
    }

    private void opAssign_(scope RCAllocator* other) @system {
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
    import sidero.base.memory.allocators.predefined;
    GeneralPurposeAllocator allocator;
    auto got = allocator.makeBufferedArrays!(int, float)(2, 4);

    static assert(is(typeof(got[0]) == int[]));
    static assert(is(typeof(got[1]) == float[]));

    assert(got[0].length == 2);
    assert(got[1].length == 4);
}

private:
import std.meta : staticMap, AliasSeq;

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

alias MakeAllArray(Types...) = staticMap!(MakeArray, Types);
alias MakeArray(T) = T[];
