module sidero.base.internal.atomic;
import coreatomic = core.atomic;

export @safe nothrow @nogc pure:

void atomicFence() {
    pragma(inline, true);
    coreatomic.atomicFence();
}

T atomicLoad(T)(ref return scope shared const T val) {
    pragma(inline, true);
    return coreatomic.atomicLoad(val);
}

void atomicStore(T, V)(ref shared T val, V newval) {
    pragma(inline, true);
    coreatomic.atomicStore(val, newval);
}

bool cas(T, V1, V2)(ref T here, V1 ifThis, V2 writeThis) @trusted {
    pragma(inline, true);
    return coreatomic.cas(&here, ifThis, writeThis);
}

T atomicIncrementAndLoad(T, V)(ref T here, V newval) {
    pragma(inline, true);
    return coreatomic.atomicOp!"+="(here, newval);
}

T atomicDecrementAndLoad(T, V)(ref T here, V newval) {
    pragma(inline, true);
    return coreatomic.atomicOp!"-="(here, newval);
}
