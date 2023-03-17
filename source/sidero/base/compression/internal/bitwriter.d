module sidero.base.compression.internal.bitwriter;
import sidero.base.containers.appender;
import sidero.base.allocators;
import sidero.base.errors;

struct BitWriter {
    Appender!ubyte output;

    uint bufferByteBits;
    ubyte bufferByte;

@safe nothrow @nogc:

export:

    void flushBits() scope {
        if (bufferByteBits > 0) {
            bufferByte >>= 8 - bufferByteBits;
            output ~= bufferByte;

            bufferByteBits = 0;
            bufferByte = 0;
        }
    }

    void writeBit(bool bit) scope {
        bufferByte >>= 1;
        bufferByte |= bit << 7;

        if (bufferByteBits++ == 7)
            flushBits;
    }

    void writeBytes(scope const(ubyte)[] input...) scope {
        flushBits;
        output ~= input;
    }

    void writeShorts(scope const(ushort)[] input...) scope {
        import std.bitmanip : nativeToLittleEndian;

        flushBits;

        foreach (v; input) {
            auto got = nativeToLittleEndian(v);
            output ~= got[];
        }
    }

    auto asReadOnly(RCAllocator allocator = RCAllocator.init) scope {
        flushBits;
        return output.asReadOnly(allocator);
    }
}
