/**
Performs a Fowler Noll Vo hash algorithms

Supports 0, 1 and 1a in the bit depths of 32, 64, 128 and 256.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.hash.fnv;
import sidero.base.math.fixednum;

private enum {
    FNV_Prime_32 = (2 ^^ 24) + (2 ^^ 8) + 0x93,
    FNV_Offset_Basis_32 = 0x811c9dc5,

    FNV_Prime_64 = (2 ^^ 40) + (2 ^^ 8) + 0xb3,
    FNV_Offset_Basis_64 = 0xcbf29ce484222325,

    FNV_Prime_128 = (FixedUNum!16(2) ^^ FixedUNum!16(88)) + (FixedUNum!16(2) ^^ FixedUNum!16(8)) + FixedUNum!16(0x3b),
    FNV_Offset_Basis_128 = FixedUNum!16(0x6c62272e07bb0142, 0x62b821756295c58d),

    FNV_Prime_256 = (FixedUNum!32(2) ^^ FixedUNum!32(168)) + (FixedUNum!32(2) ^^ FixedUNum!32(8)) + FixedUNum!32(0x63),
    FNV_Offset_Basis_256 = FixedUNum!32(FixedUNum!16(0xdd268dbcaac55036, 0x2d98c384c4e576cc),
            FixedUNum!16(0xc8b1536847b6bbb3, 0x1023b4c8caee0535)),
}

@safe nothrow @nogc pure:

/**
Performs a Fowler Noll Vo 0 hash

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fnv_32_0(const(ubyte)[] data, uint start = 0) {
    uint hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_32;
        hash ^= b;
    }

    return hash;
}

/// Ditto
ulong fnv_64_0(const(ubyte)[] data, ulong start = 0) {
    ulong hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_64;
        hash ^= b;
    }

    return hash;
}

/// Ditto
FixedUNum!16 fnv_128_0(const(ubyte)[] data, FixedUNum!16 start = FixedUNum!16(0)) {
    FixedUNum!16 hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_128;
        hash ^= FixedUNum!16(b);
    }

    return hash;
}

/// Ditto
FixedUNum!32 fnv_256_0(const(ubyte)[] data, FixedUNum!32 start = FixedUNum!32(0)) {
    FixedUNum!32 hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_256;
        hash ^= FixedUNum!32(b);
    }

    return hash;
}

/**
Performs a Fowler Noll Vo 1 hash

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fnv_32_1(const(ubyte)[] data, uint start = FNV_Offset_Basis_32) {
    uint hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_32;
        hash ^= b;
    }

    return hash;
}

/// Ditto
ulong fnv_64_1(const(ubyte)[] data, ulong start = FNV_Offset_Basis_64) {
    ulong hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_64;
        hash ^= b;
    }

    return hash;
}

/// Ditto
FixedUNum!16 fnv_128_1(const(ubyte)[] data, FixedUNum!16 start = FNV_Offset_Basis_128) {
    FixedUNum!16 hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_128;
        hash ^= FixedUNum!16(b);
    }

    return hash;
}

/// Ditto
FixedUNum!32 fnv_256_1(const(ubyte)[] data, FixedUNum!32 start = FNV_Offset_Basis_256) {
    FixedUNum!32 hash = start;

    foreach (b; data) {
        hash *= FNV_Prime_256;
        hash ^= FixedUNum!32(b);
    }

    return hash;
}

/**
Performs a Fowler Noll Vo 1a hash

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fnv_32_1a(const(ubyte)[] data, uint start = FNV_Offset_Basis_32) {
    uint hash = start;

    foreach (b; data) {
        hash ^= b;
        hash *= FNV_Prime_32;
    }

    return hash;
}

/// Ditto
ulong fnv_64_1a(const(ubyte)[] data, ulong start = FNV_Offset_Basis_64) {
    ulong hash = start;

    foreach (b; data) {
        hash ^= b;
        hash *= FNV_Prime_64;
    }

    return hash;
}

/// Ditto
FixedUNum!16 fnv_128_1a(const(ubyte)[] data, FixedUNum!16 start = FNV_Offset_Basis_128) {
    FixedUNum!16 hash = start;

    foreach (b; data) {
        hash ^= FixedUNum!16(b);
        hash *= FNV_Prime_128;
    }

    return hash;
}

/// Ditto
FixedUNum!32 fnv_256_1a(const(ubyte)[] data, FixedUNum!32 start = FNV_Offset_Basis_256) {
    FixedUNum!32 hash = start;

    foreach (b; data) {
        hash ^= FixedUNum!32(b);
        hash *= FNV_Prime_256;
    }

    return hash;
}
