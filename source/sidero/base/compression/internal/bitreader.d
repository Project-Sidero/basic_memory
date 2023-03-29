module sidero.base.compression.internal.bitreader;
import sidero.base.errors;

struct BitReader {
    const(ubyte)[] source, nextSource;
    size_t consumed;

    uint bufferByteBitsLeft;
    ubyte bufferByte;
    bool hadNextSourceBits;

@safe nothrow @nogc:
    private void checkIfEmpty() scope {
        if (source.length == 0) {
            source = nextSource;
            nextSource = null;
        }
    }

export:

    @disable this(this);

    size_t lengthOfSource() scope const {
        return source.length + nextSource.length;
    }

    size_t bitsRead() scope const {
        return (consumed * 8) - bufferByteBitsLeft;
    }

    bool hadNextSource() {
        return nextSource.length > 0 || this.hadNextSourceBits;
    }

    const(ubyte)[] consumeExact(size_t amount) scope @trusted {
        checkIfEmpty;
        if (source.length < amount)
            return null;

        auto ret = source[0 .. amount];
        source = source[amount .. $];

        consumed += amount;
        return ret;
    }

    void ignoreBits() scope {
        bufferByteBitsLeft = 0;
    }

    Result!bool nextBit() scope {
        auto got = nextBits(1);

        if (!got)
            return typeof(return)(got.getError());
        else
            return typeof(return)(got.get == 1);
    }

    bool haveMoreBits() scope const {
        return bufferByteBitsLeft > 0 || source.length > 0;
    }

    Result!ubyte nextBits(uint numberOfBits) scope {
        static ubyte[8] Mask = [0x1, 0x3, 0x7, 0xF, 0x1F, 0x3F, 0x7F, 0xFF];
        uint numberOfBitsToGo = numberOfBits;
        ubyte ret;

        while (numberOfBitsToGo > 0) {
            if (bufferByteBitsLeft == 0) {
                checkIfEmpty;
                if (source.length == 0)
                    return typeof(return)(MalformedInputException("Not enough input"));

                bufferByte = source[0];
                bufferByteBitsLeft = 8;

                source = source[1 .. $];
                consumed++;
                hadNextSourceBits = nextSource.length > 0;
            }

            const bitsToTake = bufferByteBitsLeft > numberOfBitsToGo ? numberOfBitsToGo : bufferByteBitsLeft;
            assert(bitsToTake > 0);

            ret |= (bufferByte & Mask[bitsToTake - 1]) << (numberOfBits - numberOfBitsToGo);
            bufferByte >>= bitsToTake;

            numberOfBitsToGo -= bitsToTake;
            bufferByteBitsLeft -= bitsToTake;
        }

        return typeof(return)(ret);
    }

    Result!uint nextIntBE() scope {
        import std.bitmanip : bigEndianToNative;

        checkIfEmpty;
        if (source.length < 4)
            return typeof(return)(MalformedInputException("Not enough input"));

        const ubyte[4] temp = source[0 .. 4];
        source = source[4 .. $];

        consumed += 4;
        return typeof(return)(bigEndianToNative!uint(temp));
    }

    Result!ushort nextShort() scope {
        import std.bitmanip : littleEndianToNative;

        checkIfEmpty;
        if (source.length < 2)
            return typeof(return)(MalformedInputException("Not enough input"));

        const ubyte[2] temp = source[0 .. 2];
        source = source[2 .. $];

        consumed += 2;
        return typeof(return)(littleEndianToNative!ushort(temp));
    }

    Result!ubyte nextByte() scope {
        checkIfEmpty;
        if (source.length == 0)
            return typeof(return)(MalformedInputException("Not enough input"));

        const temp = source[0];
        source = source[1 .. $];

        consumed++;
        return typeof(return)(temp);
    }
}
