/**
Performs a Fowler Noll Vo hash algorithms

Supports 0, 1 and 1a in the bit depths of 32, 64, 128 and 256.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.hash.fnv;

version(SideroBase_OnlyUnderTheHood) {
} else {
    import sidero.base.math.bigint;
}

private {
    enum {
        FNV_Prime_32 = (2 ^^ 24) + (2 ^^ 8) + 0x93,
        FNV_Offset_Basis_32 = 0x811c9dc5,

        FNV_Prime_64 = (2 ^^ 40) + (2 ^^ 8) + 0xb3,
        FNV_Offset_Basis_64 = 0xcbf29ce484222325,
    }

    version(SideroBase_OnlyUnderTheHood) {
    } else {
        enum {
            FNV_Prime_128 = BigInteger_128.parse(
                "309485009821345068724781371"c),
            FNV_Offset_Basis_128 = BigInteger_128.parse("144066263297769815596495629667062367629"c),

            FNV_Prime_256 = BigInteger_256.parse("374144419156711147060143317175368453031918731002211"c),
            FNV_Offset_Basis_256 = BigInteger_256.parse(
                    "100029257958052580907070968620625704837092796014241193945225284501741471925557"c),
        }
    }
}

export @safe nothrow @nogc:

/**
Performs a Fowler Noll Vo 0 hash

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fnv_32_0(const(ubyte)[] data, uint start = 0) pure {
    uint hash = start;

    foreach(b; data) {
        hash *= FNV_Prime_32;
        hash ^= b;
    }

    return hash;
}

/// Ditto
ulong fnv_64_0(const(ubyte)[] data, ulong start = 0) pure {
    ulong hash = start;

    foreach(b; data) {
        hash *= FNV_Prime_64;
        hash ^= b;
    }

    return hash;
}

version(SideroBase_OnlyUnderTheHood) {
} else {
    /// Ditto
    BigInteger_128 fnv_128_0(const(ubyte)[] data, BigInteger_128 start = BigInteger_128(0)) {
        BigInteger_128 hash = start;

        foreach(b; data) {
            hash *= FNV_Prime_128;
            hash ^= BigInteger_128(b);
        }

        return hash;
    }

    /// Ditto
    BigInteger_256 fnv_256_0(const(ubyte)[] data, BigInteger_256 start = BigInteger_256(0)) {
        BigInteger_256 hash = start;

        foreach(b; data) {
            hash *= FNV_Prime_256;
            hash ^= BigInteger_256(b);
        }

        return hash;
    }
}

/**
Performs a Fowler Noll Vo 1 hash

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fnv_32_1(const(ubyte)[] data, uint start = FNV_Offset_Basis_32) pure {
    uint hash = start;

    foreach(b; data) {
        hash *= FNV_Prime_32;
        hash ^= b;
    }

    return hash;
}

/// Ditto
ulong fnv_64_1(const(ubyte)[] data, ulong start = FNV_Offset_Basis_64) pure {
    ulong hash = start;

    foreach(b; data) {
        hash *= FNV_Prime_64;
        hash ^= b;
    }

    return hash;
}

version(SideroBase_OnlyUnderTheHood) {
} else {
    /// Ditto
    BigInteger_128 fnv_128_1(const(ubyte)[] data, BigInteger_128 start = FNV_Offset_Basis_128) {
        BigInteger_128 hash = start;

        foreach(b; data) {
            hash *= FNV_Prime_128;
            hash ^= BigInteger_128(b);
        }

        return hash;
    }

    /// Ditto
    BigInteger_256 fnv_256_1(const(ubyte)[] data, BigInteger_256 start = FNV_Offset_Basis_256) {
        BigInteger_256 hash = start;

        foreach(b; data) {
            hash *= FNV_Prime_256;
            hash ^= BigInteger_256(b);
        }

        return hash;
    }
}

/**
Performs a Fowler Noll Vo 1a hash

Params:
    data = The data to hash
    start = Start hash (for incremental hashing)

Returns:
    The hash
 */
uint fnv_32_1a(const(ubyte)[] data, uint start = FNV_Offset_Basis_32) pure {
    uint hash = start;

    foreach(b; data) {
        hash ^= b;
        hash *= FNV_Prime_32;
    }

    return hash;
}

/// Ditto
ulong fnv_64_1a(const(ubyte)[] data, ulong start = FNV_Offset_Basis_64) pure {
    ulong hash = start;

    foreach(b; data) {
        hash ^= b;
        hash *= FNV_Prime_64;
    }

    return hash;
}

version(SideroBase_OnlyUnderTheHood) {
} else {
    /// Ditto
    BigInteger_128 fnv_128_1a(const(ubyte)[] data, BigInteger_128 start = FNV_Offset_Basis_128) {
        BigInteger_128 hash = start;

        foreach(b; data) {
            hash ^= BigInteger_128(b);
            hash *= FNV_Prime_128;
        }

        return hash;
    }

    /// Ditto
    BigInteger_256 fnv_256_1a(const(ubyte)[] data, BigInteger_256 start = FNV_Offset_Basis_256) {
        BigInteger_256 hash = start;

        foreach(b; data) {
            hash ^= BigInteger_256(b);
            hash *= FNV_Prime_256;
        }

        return hash;
    }
}
