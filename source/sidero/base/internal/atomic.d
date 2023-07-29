module sidero.base.internal.atomic;
import std.meta : AliasSeq;
import coreatomic = core.atomic;

export @safe nothrow @nogc pure:

version(DigitalMars) {
    void atomicFence() {
        coreatomic.atomicFence();
    }
} else {
    alias atomicFence = coreatomic.atomicFence;
}

static foreach(T; AliasSeq!(bool, ubyte, byte, ushort, short, uint, int, ulong, long, size_t[2], ptrdiff_t[2])) {
    const(T) atomicLoad(ref return scope const T val) {
        pragma(inline, true);
        return coreatomic.atomicLoad(val);
    }

    const(T) atomicLoad(ref return scope const shared T val) {
        pragma(inline, true);
        return coreatomic.atomicLoad(val);
    }

    void atomicStore(ref shared T val, T newval) {
        pragma(inline, true);
        coreatomic.atomicStore(val, newval);
    }

    bool cas(ref shared T here, shared T ifThis, shared T writeThis) @trusted {
        pragma(inline, true);
        return coreatomic.cas!(coreatomic.MemoryOrder.seq, coreatomic.MemoryOrder.seq)(&here, ifThis, writeThis);
    }

    static if(!(is(T == bool) || is(T == size_t[2]) || is(T == ptrdiff_t[2]))) {
        T atomicIncrementAndLoad(ref shared T here, T newval) {
            pragma(inline, true);
            return coreatomic.atomicOp!"+="(here, newval);
        }

        T atomicDecrementAndLoad(ref shared T here, T newval) {
            pragma(inline, true);
            return coreatomic.atomicOp!"-="(here, newval);
        }
    }
}
