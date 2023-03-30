///
module sidero.base.compression.zlib;
import sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.containers.appender;
import sidero.base.errors;
import sidero.base.allocators;

export @safe nothrow @nogc:

/// Gets a ZLIB dictionary for an identifier, will be uncompressed.
alias ZlibPresetDictionaryDelegate = const(ubyte)[]delegate(ubyte[4]) @safe nothrow @nogc;

///
Result!size_t decompressZlib(scope Slice!ubyte source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return decompressZlib(bitReader, output, null, allocator);
}

///
Result!size_t decompressZlib(scope DynamicArray!ubyte source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return decompressZlib(bitReader, output, null, allocator);
}

///
Result!size_t decompressZlib(scope const(ubyte)[] source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    return decompressZlib(bitReader, output, null, allocator);
}

///
Result!size_t decompressZlib(scope Slice!ubyte source, scope out Slice!ubyte output,
        scope ZlibPresetDictionaryDelegate presetDictionaryDel, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return decompressZlib(bitReader, output, presetDictionaryDel, allocator);
}

///
Result!size_t decompressZlib(scope DynamicArray!ubyte source, scope out Slice!ubyte output,
        scope ZlibPresetDictionaryDelegate presetDictionaryDel, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return decompressZlib(bitReader, output, presetDictionaryDel, allocator);
}

///
Result!size_t decompressZlib(scope const(ubyte)[] source, scope out Slice!ubyte output,
        scope ZlibPresetDictionaryDelegate presetDictionaryDel, RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    return decompressZlib(bitReader, output, presetDictionaryDel, allocator);
}

///
Slice!ubyte compressZlib(scope Slice!ubyte source, ubyte[4] dictionaryId, scope ZlibPresetDictionaryDelegate presetDictionaryDel,
        DeflateCompressionRate rate = DeflateCompressionRate.Default, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    compressZlib(bitReader, result, rate, dictionaryId, presetDictionaryDel, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressZlib(scope DynamicArray!ubyte source, ubyte[4] dictionaryId, scope ZlibPresetDictionaryDelegate presetDictionaryDel,
        DeflateCompressionRate rate = DeflateCompressionRate.Default, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    compressZlib(bitReader, result, rate, dictionaryId, presetDictionaryDel, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressZlib(scope const(ubyte)[] source, ubyte[4] dictionaryId, scope ZlibPresetDictionaryDelegate presetDictionaryDel,
        DeflateCompressionRate rate = DeflateCompressionRate.Default, RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    compressZlib(bitReader, result, rate, dictionaryId, presetDictionaryDel, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressZlib(scope Slice!ubyte source, DeflateCompressionRate rate = DeflateCompressionRate.Default,
        RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    compressZlib(bitReader, result, rate, [0, 0, 0, 0], null, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressZlib(scope DynamicArray!ubyte source, DeflateCompressionRate rate = DeflateCompressionRate.Default,
        RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    compressZlib(bitReader, result, rate, [0, 0, 0, 0], null, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressZlib(scope const(ubyte)[] source, DeflateCompressionRate rate = DeflateCompressionRate.Default,
        RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    compressZlib(bitReader, result, rate, [0, 0, 0, 0], null, allocator);
    return result.asReadOnly(allocator);
}

package(sidero.base.compression):
import sidero.base.compression.internal.bitreader;
import sidero.base.compression.internal.bitwriter;
import sidero.base.hash.adler32;
import sidero.base.compression.deflate;

Result!size_t decompressZlib(scope ref BitReader source, scope out Slice!ubyte output,
        scope ZlibPresetDictionaryDelegate presetDictionaryDel, RCAllocator allocator = RCAllocator.init) @trusted {
    const originallyConsumed = source.consumed;
    ZlibHeader header;

    const(ubyte)[] presetDictionary;

    ErrorInfo readHeader() @trusted {
        {
            auto CMFb = source.nextByte, FLGb = source.nextByte;
            if (!CMFb)
                return CMFb.getError();
            else if (!FLGb)
                return FLGb.getError();

            header.CMF = CMFb.get;
            header.FLG = FLGb.get;
        }

        if (!header.isValidFCHECK)
            return ErrorInfo(MalformedInputException("Invalid FCHECK"));
        else if (header.haveFDICT) {
            {
                auto temp = source.consumeExact(4);

                if (temp.length == 4)
                    return ErrorInfo(MalformedInputException("Preset dictionary is required, no dictionary id"));

                header.DICTID = temp[0 .. 4];
            }

            if (presetDictionaryDel is null)
                return ErrorInfo(MalformedInputException("Preset dictionary is required, no callback"));

            presetDictionary = presetDictionaryDel(header.DICTID);
            if (presetDictionary is null)
                return ErrorInfo(MalformedInputException("Unknown preset dictionary"));
        }

        header.runningAdler32 = adler32Checksum(null);

        if (header.compressionMethod == ZlibHeader.CompressionMethod.Error)
            return ErrorInfo(MalformedInputException("Unknown compression method"));

        return ErrorInfo.init;
    }

    {
        auto error = readHeader();
        if (error.isSet)
            return typeof(return)(error);
    }

    {
        Appender!ubyte result = Appender!ubyte(allocator);
        if (presetDictionary.length > 0)
            result ~= presetDictionary;

        auto didDecompress = decompressDeflate(source, result, allocator);
        if (!didDecompress)
            return typeof(return)(didDecompress.getError());

        Slice!ubyte decompressed = result.asReadOnly(presetDictionary.length, size_t.max, allocator);

        if (didDecompress.get > 0) {
            header.runningAdler32 = adler32Checksum(decompressed.unsafeGetLiteral(), header.runningAdler32);
            auto expectedHash = source.nextIntBE;

            if (!expectedHash || header.runningAdler32 != expectedHash.get) {
                return typeof(return)(MalformedInputException("Invalid hash"));
            }
        }

        output = decompressed;
        return typeof(return)(source.consumed - originallyConsumed);
    }
}

void compressZlib(scope ref BitReader source, scope ref BitWriter output, DeflateCompressionRate compressionRate,
        ubyte[4] dictionary, scope ZlibPresetDictionaryDelegate presetDictionaryDel, RCAllocator allocator = RCAllocator.init) @trusted {

    const(ubyte)[] presetDictionary;
    if (presetDictionaryDel !is null)
        presetDictionary = presetDictionaryDel(dictionary);

    {
        // DEFLATE, windows size 32kb
        const CMF = cast(ubyte)((7 << 4) | 8);

        // FLG
        ubyte FLG = (presetDictionary.length > 0 ? 0x20 : 0);
        if (compressionRate <= DeflateCompressionRate.Fastest) {
        } else if (compressionRate <= DeflateCompressionRate.Fast)
            FLG |= 0x40;
        else if (compressionRate <= DeflateCompressionRate.Default)
            FLG |= 0x80;
        else
            FLG |= 0xC0;

        // 5 bits for FCHECK
        const FCHECK = ((256 * CMF) + FLG) % 31;
        if (FCHECK > 0)
            FLG |= cast(ubyte)(31 - FCHECK);

        output.writeBytes(CMF, FLG);
    }

    if (presetDictionary.length > 0) {
        output.writeBytes(dictionary[]);
    }

    {
        const hash = adler32Checksum(source.nextSource, adler32Checksum(source.source));

        BitWriter deflateResult;
        size_t amountInFirstBatch;
        compressDeflate(source, deflateResult, compressionRate, presetDictionary.length, amountInFirstBatch, allocator);

        deflateResult.flushBits;
        output.writeAppender(deflateResult.output, amountInFirstBatch, size_t.max);
        output.writeIntBE(hash);
    }
}

struct ZlibHeader {
    ubyte CMF, FLG;

    // if FLG.FDICT set
    ubyte[4] DICTID;
    uint runningAdler32;

@safe nothrow @nogc:

    CompressionMethod compressionMethod() scope const {
        if ((CMF & 0xF) == 8)
            return CompressionMethod.Deflate;
        else
            return CompressionMethod.Error;
    }

    ubyte compressionInfo() scope const {
        return (CMF & 0x0F) >> 4;
    }

    bool isValidFCHECK() scope const {
        return ((256 * CMF) + FLG) % 31 == 0;
    }

    bool haveFDICT() scope const {
        return (FLG & 0x20) == 0x20;
    }

    CompressionLevel compressionLevel() scope const {
        return cast(CompressionLevel)(FLG >> 6);
    }

    @disable bool opEquals(scope const ref ZlibHeader) scope const;
    @disable int opCmp(scope const ref ZlibHeader) scope const;

    enum CompressionMethod {
        Error,
        Deflate = 8,
    }

    enum CompressionLevel {
        Fastest,
        Fast,
        Default,
        Slow,
    }
}

@trusted unittest {
    bool test(ubyte[] toDecompress, ubyte[] expected) {
        Slice!ubyte output;
        auto consumed = decompressZlib(toDecompress, output);

        if (!consumed || consumed.get != toDecompress.length || output.length != expected.length)
            return false;

        size_t offset;

        foreach (ubyte v; output) {
            if (offset >= expected.length || expected[offset++] != v)
                return false;
        }

        return true;
    }

    assert(test([120, 1, 1, 7, 0, 248, 255, 72, 101, 108, 108, 111, 32, 68, 9, 250, 2, 89], cast(ubyte[])"Hello D"));
    assert(!test([120, 1, 1, 7, 0, 248, 255, 72, 101, 108, 108, 111, 32, 68, 9, 250, 3, 89], cast(ubyte[])"Hello D"));
}

@trusted unittest {
    bool test(ubyte[] toCompress, DeflateCompressionRate rate) @trusted {
        Slice!ubyte compressed, decompressed;

        compressed = compressZlib(toCompress, rate);
        if (compressed.length == 0)
            return false;

        auto consumed = decompressZlib(compressed, decompressed);
        if (!consumed || consumed.get != compressed.length || decompressed.length != toCompress.length)
            return false;

        size_t offset;

        foreach (ubyte v; decompressed) {
            if (offset >= toCompress.length || toCompress[offset++] != v)
                return false;
        }

        return true;
    }

    static BigText = cast(ubyte[])"Lorem Ipsum is simply dummy text of the printing and typesetting industry.";

    assert(test(BigText, DeflateCompressionRate.None));
    assert(test(BigText, DeflateCompressionRate.FixedHuffManTree));
    assert(test(BigText, DeflateCompressionRate.DynamicHuffManTree));
    assert(test(BigText, DeflateCompressionRate.HashWithFixedHuffManTree));
    assert(test(BigText, DeflateCompressionRate.HashWithDynamicHuffManTree));
    assert(test(BigText, DeflateCompressionRate.DeepHashWithDynamicHuffManTree));
}
