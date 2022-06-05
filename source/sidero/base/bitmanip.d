/**
Bit manipulation functions

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.bitmanip;
import std.traits : isIntegral;

/// Get a bit mask for a given number of bits.
Return bitMaskForNumberOfBits(Return = size_t, Arg)(Arg numberOfBits) if (isIntegral!Arg) {
    if (numberOfBits >= Return.sizeof * 8)
        return Return.max;

    Return ret = 1;
    ret <<= numberOfBits;
    return ret - 1;
}

/// Reverse a specified number of LSB bits
Return reverseBitsLSB(Return = size_t, Arg)(Return input, Arg numberOfBitsToReverse) if (isIntegral!Arg) {
    if (numberOfBitsToReverse >= Return.sizeof * 8)
        numberOfBitsToReverse = Return.sizeof * 8;

    Return result;

    foreach (i; 0 .. numberOfBitsToReverse) {
        result <<= 1;
        result |= input & 1;
        input >>= 1;
    }

    input <<= numberOfBitsToReverse;
    return result | input;
}

///
unittest {
    assert(reverseBitsLSB!uint(0x3e23,3) == 0x3e26);
    assert(reverseBitsLSB!ulong(0x8000000000000002, 64) == 0x4000000000000001);
}
