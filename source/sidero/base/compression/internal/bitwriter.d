module sidero.base.compression.internal.bitwriter;
import sidero.base.containers.appender;
import sidero.base.allocators;
import sidero.base.errors;

struct BitWriter {
    import sidero.base.bitmanip : nativeToLittleEndian, nativeToBigEndian;
    Appender!ubyte output;

    uint bufferByteBits;
    ubyte bufferByte;

@safe nothrow @nogc:

export:

    size_t bitsWritten() scope const {
        return bufferByteBits + (output.length * 8);
    }

    void flushBits() scope {
        if (bufferByteBits > 0) {
            output ~= bufferByte;

            bufferByteBits = 0;
            bufferByte = 0;
        }
    }

    void writeBit(bool bit) scope {
        bufferByte |= bit << bufferByteBits;

        if (bufferByteBits++ == 7)
            flushBits;
    }

    void writeBytes(scope const(ubyte)[] input...) scope {
        flushBits;
        output ~= input;
    }

    void writeShorts(scope const(ushort)[] input...) scope {
        flushBits;

        foreach (v; input) {
            auto got = nativeToLittleEndian(v);
            output ~= got[];
        }
    }

    void writeIntBE(uint value) {
        auto bytes = nativeToBigEndian(value);
        this.writeBytes(bytes[]);
    }

    void writeAppender(scope ref Appender!ubyte other, size_t offset = 0, size_t length = size_t.max) {
        flushBits;
        this.output.append(other, offset, length);
    }

    auto asReadOnly(RCAllocator allocator = RCAllocator.init) scope {
        flushBits;
        return output.asReadOnly(allocator);
    }
}
