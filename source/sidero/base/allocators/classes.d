/**
Class lifetime management.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2024 Richard Andrew Cattermole
 */
module sidero.base.allocators.classes;
import sidero.base.allocators.api;
import sidero.base.hash.fnv : fnv_64_1a;
import sidero.base.internal.logassert;

///
extern (C++) interface IRootRefRC() {
@safe nothrow @nogc:
    ///
    CRef!(IRootRefRC!()) self() return scope;

    protected {
        void opRC(bool addRef) scope;
        void opClassDownCast(ulong targetHash, out void* obj);
    }

    ///
    ulong toHash() scope const;
}

///
export extern (C++) class RootRefRCClass() : IRootRefRC!() {
    private {
        shared(ptrdiff_t) refCount = 1;
        RCAllocator allocator;
        IRootRefRC!() rootInterfaceInstance;
        immutable(void)* ci;
    }

export @safe nothrow @nogc:

    protected {
        void opRC(bool addRef) scope @trusted {
            import sidero.base.internal.atomic;

            if(addRef)
                atomicIncrementAndLoad(this.refCount, 1);
            else if(atomicDecrementAndLoad(this.refCount, 1) == 0) {
                RCAllocator allocator = this.allocator;
                this.__xdtor;

                immutable(ClassHierachy!())* ci2 = cast(immutable(ClassHierachy!())*)this.ci;
                allocator.deallocate(U!(RootRefRCClass!())(this).objPtr[0 .. ci2.instanceSize]);
            }
        }

        void opOnCreate(RealType)(RCAllocator allocator, RealType realValue) scope {
            this.allocator = allocator;
            this.ci = buildClassHierachy!RealType;
            this.rootInterfaceInstance = cast(IRootRefRC!())realValue;
        }

        void opClassDownCast(ulong targetHash, out void* obj) @trusted {
            ptrdiff_t delta;
            immutable(ClassHierachy!())* ci2 = cast(immutable(ClassHierachy!())*)this.ci;

            foreach(c; ci2.classes) {
                if(c.nameHash == targetHash) {
                    delta = c.deltaFromRootRef;
                    goto Success;
                }
            }

            foreach(i; ci2.interfaces) {
                if(i.nameHash == targetHash) {
                    delta = i.deltaFromRootRef;
                    goto Success;
                }
            }

            return;

        Success:
            U!(IRootRefRC!()) temp = U!(IRootRefRC!())(this.rootInterfaceInstance);
            temp.diff += delta;

            obj = temp.objPtr;
            return;
        }
    }

    ///
    CRef!(IRootRefRC!()) self() return scope {
        CRef!(IRootRefRC!()) ret;
        ret.instance = this;
        this.opRC(true);
        return ret;
    }

    ///
    ulong toHash() scope const @trusted {
        return U!(IRootRefRC!())(cast(immutable)this).diff;
    }
}

///
struct CRef(ObjectType : IRootRefRC!()) {
    private {
        ObjectType instance;
        bool checked;
    }

export @safe nothrow @nogc:

    this(return scope ref CRef other) scope {
        this.instance = other.instance;

        if(this.instance !is null)
            this.instance.opRC(true);
    }

    ~this() scope {
        if(this.instance !is null)
            this.instance.opRC(false);
    }

    void opAssign(return scope ref CRef other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    bool isNull() {
        this.checked = this.instance !is null;
        return this.instance is null;
    }

    /// Uses fnv_64_1a to hash the ``__traits(fullyQualifiedName)`` of type.
    NewType opCast(NewType : CRef!NewObjectType, NewObjectType)() scope @trusted {
        if(isNull)
            return typeof(return).init;

        static if(is(ObjectType : NewObjectType)) {
            NewType ret;

            ret.instance = cast(NewObjectType)this.instance;

            if(ret.instance !is null)
                ret.instance.opRC(true);

            return ret;
        } else static if(is(NewObjectType : IRootRefRC!())) {
            enum FQN = __traits(fullyQualifiedName, NewObjectType);
            enum hash = fnv_64_1a(cast(ubyte[])FQN);

            U!NewObjectType u;
            this.instance.opClassDownCast(hash, u.objPtr);

            if(u.obj is null)
                return typeof(return).init;

            NewType ret;
            ret.instance = u.obj;
            ret.instance.opRC(true);
            return ret;
        } else
            static assert(0, "New type is not a parent of current class");
    }

    /// Will verify that you checked
    ObjectType get(string moduleName = __MODULE__, int line = __LINE__) return @trusted {
        logAssert(this.checked,
                "You forgot to check if value is null for " ~ ObjectType.stringof ~ ". assert(thing, thing.error.toString());",
                moduleName, line);
        return this.instance;
    }

    ///
    alias get this;

    ///
    ref ObjectType assumeOkay() return @system {
        return instance;
    }

    static CRef make(ToAllocate : CRef!ToAllocateType, ToAllocateType, Args...)(Args args) {
        return CRef.make!ToAllocateType(args);
    }

    static CRef make(ToAllocateType, Args...)(Args args) @trusted {
        RCAllocator allocator = globalAllocator();
        CRef ret;

        auto temp = allocator.make!ToAllocateType(args);
        if(temp is null)
            return CRef.init;

        ret.instance = cast(ObjectType)temp;

        static if(__traits(hasMember, ToAllocateType, "opOnCreate")) {
            temp.opOnCreate!ToAllocateType(allocator, temp);
        }

        return ret;
    }
}

///
unittest {
    static extern (C++) interface I : IRootRefRC!() {
        void thing(int);
    }

    static extern (C++) class Child : RootRefRCClass!(), I {
        int counter;

    @safe nothrow @nogc:

        this() {
        }

        this(int i) {
            this.counter = i;
        }

        void thing(int j) {
            this.counter += j;
        }
    }

    CRef!I i = CRef!I.make!Child(2);
    assert(!i.isNull);

    CRef!Child child = cast(CRef!Child)i;
    assert(!child.isNull);

    child.thing(9);
    assert(child.counter == 11);

    CRef!I root = cast(CRef!I)child;
    assert(!root.isNull);
    assert(root.instance is i.instance);
}

private:

immutable(ClassHierachy!())* buildClassHierachy(ActualType)() @trusted {
    import std.traits : TransitiveBaseTypeTuple;

    alias TBTT = TransitiveBaseTypeTuple!ActualType;

    enum Base = () {
        ClassHierachy!() ret;
        ret.instanceSize = __traits(classInstanceSize, ActualType);
        ClassInHierachy!() cih;

        cih.name = __traits(fullyQualifiedName, ActualType);
        cih.nameHash = fnv_64_1a(cast(ubyte[])cih.name);
        ret.classes ~= cih;

        static foreach(T; TransitiveBaseTypeTuple!ActualType) {
            cih.name = __traits(fullyQualifiedName, T);
            cih.nameHash = fnv_64_1a(cast(ubyte[])cih.name);

            static if(is(T == IRootRefRC!())) {
            } else static if(is(T == class)) {
                ret.classes ~= cih;
            } else static if(is(T == interface)) {
                ret.interfaces ~= cih;
            }
        }

        return ret;
    }();

    ActualType actual = U!(ActualType)(0xFFFFFF).obj;
    __gshared ret = Base;
    __gshared bool done;

    if(!done) {
        size_t classOffset, interfaceOffset;
        ptrdiff_t t, r, delta;

        t = U!ActualType(actual).diff;
        r = U!(IRootRefRC!())(cast(IRootRefRC!())actual).diff;
        delta = t - r;
        ret.classes[classOffset++].deltaFromRootRef = delta;

        static foreach(T; TBTT) {
            t = U!T(cast(T)actual).diff;
            r = U!(IRootRefRC!())(cast(IRootRefRC!())actual).diff;
            delta = t - r;

            static if(is(T == IRootRefRC!())) {
            } else static if(is(T == class)) {
                ret.classes[classOffset++].deltaFromRootRef = delta;
            } else static if(is(T == interface)) {
                ret.interfaces[interfaceOffset++].deltaFromRootRef = delta;
            }
        }

        done = true;
    }

    return cast(immutable)&ret;
}

struct ClassHierachy() {
    size_t instanceSize;
    ClassInHierachy!()[] classes;
    ClassInHierachy!()[] interfaces;
}

struct ClassInHierachy() {
    string name;
    ulong nameHash;
    ptrdiff_t deltaFromRootRef;
}

union U(T) {
    immutable T t;
    T obj;
    void* objPtr;
    ptrdiff_t diff;

    this(int diff) {
        this.diff = diff;
    }

    this(void* objPtr) {
        this.objPtr = objPtr;
    }

    this(T obj) {
        this.obj = obj;
    }

    this(immutable T t) {
        this.t = t;
    }
}
