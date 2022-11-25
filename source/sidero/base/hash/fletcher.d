/**
Fletcher hashes

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.hash.fletcher;

export @safe nothrow @nogc pure:

/**
Performs an Fletcher hash (16-bit).

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
ushort fletcher16BitChecksum(const(ubyte)[] data, ushort start = 0) {
    uint sum1 = start & 0xFF, sum2 = (start >> 8) & 0xFF;

    foreach (v; data) {
        sum1 += v;
        sum1 %= ubyte.max;

        sum2 += sum1;
        sum2 %= ubyte.max;
    }

    return cast(ushort)((sum2 << 8) + sum1);
}

/**
Performs an Fletcher hash (32-bit).

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fletcher32BitChecksum(const(ubyte)[] data, uint start = 0) {
    uint sum1 = start & 0xFFFF, sum2 = (start >> 16) & 0xFFFF;

    foreach (v; data) {
        sum1 += v;
        sum1 %= ushort.max;

        sum2 += sum1;
        sum2 %= ushort.max;
    }

    return cast(ushort)((sum2 << 16) + sum1);
}

/**
Performs an Fletcher hash (64-bit).

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
ulong fletcher64BitChecksum(const(ubyte)[] data, ulong start = 0) {
    ulong sum1 = start & 0xFFFFFFFF, sum2 = (start >> 32) & 0xFFFFFFFF;

    foreach (v; data) {
        sum1 += v;
        sum1 %= uint.max;

        sum2 += sum1;
        sum2 %= uint.max;
    }

    return cast(ushort)((sum2 << 32) + sum1);
}
