/**
Some utility code needed for memory allocators to operate.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.utils;

export @safe nothrow @nogc:

/// Initialize uninitialized memory to its init state
void fillUninitializedWithInit(T)(scope T[] array...) @trusted {
    enum InitToZero = __traits(isZeroInit, T);
    enum InitToInit = __traits(isScalar, T);

    static if (InitToZero || InitToInit) {
        static if (is(T : void) || InitToZero) {
            alias CastTo = ubyte;
        } else {
            alias CastTo = T;
        }

        foreach (ref v; cast(CastTo[])array)
            v = CastTo.init;
    } else {
        immutable initState = cast(immutable(ubyte[]))__traits(initSymbol, T);
        assert(initState.length == T.sizeof);

        while (array.length > 0) {
            foreach (i, ref v; (cast(ubyte[])array)[0 .. initState.length]) {
                v = initState[i];
            }

            array = array[1 .. $];
        }
    }
}
