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
    assert(reverseBitsLSB!uint(0x3e23, 3) == 0x3e26);
    assert(reverseBitsLSB!ulong(0x8000000000000002, 64) == 0x4000000000000001);
}

/// Treat any enum as if it was setup for bit flags
struct BitFlags {
    ///
    ulong flags;

@safe nothrow @nogc pure:

    ///
    this(Input)(Input input) {
        import std.traits : isNumeric;

        static if (is(Input == enum)) {
            static assert(__traits(allMembers, Input).length <= typeof(this.flags).sizeof * 8);
            this.flags = flagForEnum(input);
        } else static if (isNumeric!Input) {
            this.flags = input;
        } else
            static assert(0);
    }

    ///
    void opOpAssign(string op : "&", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        flags &= flagForEnum(value);
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(3);
        flags &= Enum.B;
        assert(flags.flags == 2);
    }


    ///
    void opOpAssign(string op : "|", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        flags |= flagForEnum(value);
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        flags |= Enum.B;
        assert(flags.flags == 3);
    }

    ///
    void opOpAssign(string op : "^", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        flags |= flagForEnum(value);
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        flags ^= Enum.B;
        assert(flags.flags == 3);
    }

    ///
    void opOpAssign(string op : "&")(BitFlags value)
             {
        flags &= value.flags;
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(3);
        flags &= BitFlags(Enum.B);
        assert(flags.flags == 2);
    }

    ///
    void opOpAssign(string op : "|")(BitFlags value)
            {
        flags |= value.flags;
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        flags |= BitFlags(Enum.B);
        assert(flags.flags == 3);
    }

    ///
    void opOpAssign(string op : "^")(BitFlags value)
           {
        flags |= value.flags;
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        flags ^= BitFlags(Enum.B);
        assert(flags.flags == 3);
    }

    ///
    BitFlags opBinary(string op : "&", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        return BitFlags(flags & flagForEnum(value));
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(3);
        assert((flags & Enum.B).flags == 2);
    }

    ///
    BitFlags opBinary(string op : "|", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        return BitFlags(flags | flagForEnum(value));
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        assert((flags | Enum.B).flags == 3);
    }

    ///
    BitFlags opBinary(string op : "^", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        return BitFlags(flags ^ flagForEnum(value));
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        assert((flags ^ Enum.B).flags == 3);
    }

    ///
    BitFlags opBinary(string op : "&")(BitFlags value)
            {
        return BitFlags(flags & value.flags);
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(3);
        assert((flags & BitFlags(Enum.B)).flags == 2);
    }

    ///
    BitFlags opBinary(string op : "|")(BitFlags value)
            {
        return BitFlags(flags | value.flags);
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        assert((flags | BitFlags(Enum.B)).flags == 3);
    }

    ///
    BitFlags opBinary(string op : "^")(BitFlags value)
             {
        return BitFlags(flags ^ value.flags);
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        assert((flags ^ BitFlags(Enum.B)).flags == 3);
    }

    ///
    bool opBinaryRight(string op : "in", Enum)(Enum value)
            if (is(Enum == enum) && __traits(allMembers, Enum).length <= typeof(this.flags).sizeof * 8) {
        return (flags & flagForEnum(value)) != 0;
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        BitFlags flags = BitFlags(1);
        assert(Enum.A in flags);
    }

    ///
    int opCmp(const BitFlags other) const {
        if (this.flags < other.flags)
            return -1;
        else if (this.flags > other.flags)
            return 1;
        else
            return 0;
    }

    ///
    unittest {
        enum Enum {
            A,
            B,
        }

        assert(BitFlags(Enum.A) < BitFlags(Enum.B));
        assert(BitFlags(Enum.A) == BitFlags(Enum.A));
        assert(BitFlags(Enum.B) > BitFlags(Enum.A));
    }

    ///
    ulong toHash() const {
        return flags;
    }

private:
    static uint flagForEnum(Enum)(Enum value) if (is(Enum == enum)) {
        final switch (value) {
            static foreach (i, m; __traits(allMembers, Enum)) {
        case __traits(getMember, Enum, m):
                return 1 << i;
            }
        }
    }
}
