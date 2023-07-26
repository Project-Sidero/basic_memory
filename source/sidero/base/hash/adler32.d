/**
Adler32 hashing

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.hash.adler32;

export @safe nothrow @nogc:

/**
Performs an Adler32 hash (32-bit).

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint adler32Checksum(const(ubyte)[] data, uint start = 1) {
    enum Base = 65521;
    uint sum1 = start & 0xffff;
    uint sum2 = (start >> 16) & 0xffff;

    foreach(v; data) {
        sum1 += v;
        sum1 %= Base;

        sum2 += sum1;
    }

    return (sum2 << 16) + sum1;
}
