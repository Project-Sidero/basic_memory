/**
Bit manipulation functions

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.bitmanip;
import std.traits : isIntegral;

export @safe nothrow @nogc pure:

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

export @safe nothrow @nogc pure:

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
    void opOpAssign(string op : "&")(BitFlags value) {
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
    void opOpAssign(string op : "|")(BitFlags value) {
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
    void opOpAssign(string op : "^")(BitFlags value) {
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
    BitFlags opBinary(string op : "&")(BitFlags value) {
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
    BitFlags opBinary(string op : "|")(BitFlags value) {
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
    BitFlags opBinary(string op : "^")(BitFlags value) {
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

    ///
    struct For(Enum) {
        static assert(__traits(allMembers, Enum).length <= typeof(this.bitFlags.flags).sizeof * 8);

        ///
        BitFlags bitFlags;

    @safe nothrow @nogc pure:

        ///
        this(Input)(Input input) {
            import std.traits : isNumeric;

            static if (is(Input == Enum)) {
                this.bitFlags.flags = flagForEnum(input);
            } else static if (isNumeric!Input) {
                this.bitFlags.flags = input;
            } else static if (is(Input == BitFlags)) {
                this.bitFlags = input;
            } else
                static assert(0);
        }

        ///
        void opOpAssign(string op : "&")(Enum value) {
            bitFlags &= value;
        }

        ///
        void opOpAssign(string op : "|")(Enum value) {
            bitFlags |= value;
        }

        ///
        void opOpAssign(string op : "^")(Enum value) {
            bitFlags ^= value;
        }

        ///
        void opOpAssign(string op : "&")(BitFlags value) {
            bitFlags &= value;
        }

        ///
        void opOpAssign(string op : "|")(BitFlags value) {
            bitFlags |= value;
        }

        ///
        void opOpAssign(string op : "^")(BitFlags value) {
            bitFlags ^= value;
        }

        ///
        For opBinary(string op : "&")(Enum value) {
            return For(bitFlags & value);
        }

        ///
        For opBinary(string op : "|")(Enum value) {
            return For(bitFlags | value);
        }

        ///
        For opBinary(string op : "^")(Enum value) {
            return For(bitFlags ^ value);
        }

        ///
        For opBinary(string op : "&")(BitFlags value) {
            return For(bitFlags & value);
        }

        ///
        For opBinary(string op : "|")(BitFlags value) {
            return For(bitFlags | value);
        }

        ///
        For opBinary(string op : "^")(BitFlags value) {
            return For(bitFlags ^ value);
        }

        ///
        bool opBinaryRight(string op : "in")(Enum value) {
            return value in bitFlags;
        }

        ///
        int opCmp(const BitFlags other) const {
            return bitFlags.opCmp(other);
        }

        ///
        int opCmp(const For other) const {
            return bitFlags.opCmp(other.bitFlags);
        }

        ///
        ulong toHash() const {
            return bitFlags.toHash();
        }
    }

    ///
    unittest {
        enum Something {
            Donkey,
            Horse,
            Anything,
        }

        alias SomethingFlags = BitFlags.For!Something;

        void accepter(SomethingFlags bitFlags) {
            assert(Something.Anything in bitFlags);
            assert(Something.Donkey !in bitFlags);
        }

        accepter(SomethingFlags(Something.Anything));
        accepter(SomethingFlags(Something.Anything) | Something.Horse);
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

///
short swapEndian(short input) {
    return swapEndianImpl(input);
}

///
ushort swapEndian(ushort input) {
    return swapEndianImpl(input);
}

///
int swapEndian(int input) {
    return swapEndianImpl(input);
}

///
uint swapEndian(uint input) {
    return swapEndianImpl(input);
}

///
long swapEndian(long input) {
    return swapEndianImpl(input);
}

///
ulong swapEndian(ulong input) {
    return swapEndianImpl(input);
}

///
short littleEndianToNative(T : short)(ubyte[2] input) {
    return littleEndianToNativeImpl!T(input);
}

///
ushort littleEndianToNative(T : ushort)(ubyte[2] input) {
    return littleEndianToNativeImpl!T(input);
}

///
int littleEndianToNative(T : int)(ubyte[4] input) {
    return littleEndianToNativeImpl!T(input);
}

///
uint littleEndianToNative(T : uint)(ubyte[4] input) {
    return littleEndianToNativeImpl!T(input);
}

///
long littleEndianToNative(T : long)(ubyte[8] input) {
    return littleEndianToNativeImpl!T(input);
}

///
ulong littleEndianToNative(T : ulong)(ubyte[8] input) {
    return littleEndianToNativeImpl!T(input);
}

///
short bigEndianToNative(T : short)(ubyte[2] input) {
    return bigEndianToNativeImpl!T(input);
}

///
ushort bigEndianToNative(T : ushort)(ubyte[2] input) {
    return bigEndianToNativeImpl!T(input);
}

///
int bigEndianToNative(T : int)(ubyte[4] input) {
    return bigEndianToNativeImpl!T(input);
}

///
uint bigEndianToNative(T : uint)(ubyte[4] input) {
    return bigEndianToNativeImpl!T(input);
}

///
long bigEndianToNative(T : long)(ubyte[8] input) {
    return bigEndianToNativeImpl!T(input);
}

///
ulong bigEndianToNative(T : ulong)(ubyte[8] input) {
    return bigEndianToNativeImpl!T(input);
}

///
ubyte[2] nativeToLittleEndian(ushort input) {
    return nativeToLittleEndianImpl(input);
}

///
ubyte[2] nativeToLittleEndian(short input) {
    return nativeToLittleEndianImpl(input);
}

///
ubyte[4] nativeToLittleEndian(uint input) {
    return nativeToLittleEndianImpl(input);
}

///
ubyte[4] nativeToLittleEndian(int input) {
    return nativeToLittleEndianImpl(input);
}

///
ubyte[8] nativeToLittleEndian(ulong input) {
    return nativeToLittleEndianImpl(input);
}

///
ubyte[8] nativeToLittleEndian(long input) {
    return nativeToLittleEndianImpl(input);
}

///
ubyte[2] nativeToBigEndian(ushort input) {
    return nativeToBigEndianImpl(input);
}

///
ubyte[2] nativeToBigEndian(short input) {
    return nativeToBigEndianImpl(input);
}

///
ubyte[4] nativeToBigEndian(uint input) {
    return nativeToBigEndianImpl(input);
}

///
ubyte[4] nativeToBigEndian(int input) {
    return nativeToBigEndianImpl(input);
}

///
ubyte[8] nativeToBigEndian(ulong input) {
    return nativeToBigEndianImpl(input);
}

///
ubyte[8] nativeToBigEndian(long input) {
    return nativeToBigEndianImpl(input);
}

private:

T swapEndianImpl(T)(T input) {
    T ret;

    static foreach (I; 0 .. T.sizeof) {
        static if (I > 0) {
            ret <<= 8;
        }

        ret |= (input & 0xFF);
        input >>= 8;
    }

    return ret;
}

T littleEndianToNativeImpl(T)(ubyte[T.sizeof] input) {
    T ret;

    static foreach (I; 1 .. T.sizeof + 1) {
        static if (I > 1) {
            ret <<= 8;
        }

        ret |= input[$ - I];
    }

    return ret;
}

T bigEndianToNativeImpl(T)(ubyte[T.sizeof] input) {
    T ret;

    static foreach (I; 0 .. T.sizeof) {
        static if (I > 0) {
            ret <<= 8;
        }

        ret |= input[I];
    }

    return ret;
}

ubyte[T.sizeof] nativeToLittleEndianImpl(T)(T input) {
    ubyte[T.sizeof] ret;

    static foreach (I; 0 .. T.sizeof) {
        static if (I > 0) {
            input >>= 8;
        }

        ret[I] = input & 0xFF;
    }

    return ret;
}

ubyte[T.sizeof] nativeToBigEndianImpl(T)(T input) {
    ubyte[T.sizeof] ret;

    static foreach (I; 1 .. T.sizeof + 1) {
        static if (I > 1) {
            input >>= 8;
        }

        ret[$ - I] = input & 0xFF;
    }

    return ret;
}
