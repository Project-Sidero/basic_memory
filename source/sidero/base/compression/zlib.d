module sidero.base.compression.zlib;
import sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.containers.appender;
import sidero.base.errors;
import sidero.base.allocators;

export @safe nothrow @nogc:

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

private:
import sidero.base.compression.internal.bitreader;
import sidero.base.hash.adler32;

Result!size_t decompressZlib(scope ref BitReader source, scope out Slice!ubyte output,
        scope ZlibPresetDictionaryDelegate presetDictionaryDel, RCAllocator allocator = RCAllocator.init) @trusted {
    import sidero.base.compression.deflate;

    const originallyConsumed = source.consumed;
    ZlibHeader header;

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

            auto presetDictionary = presetDictionaryDel(header.DICTID);
            if (presetDictionary is null)
                return ErrorInfo(MalformedInputException("Unknown preset dictionary"));

            source.nextSource = source.source;
            source.source = presetDictionary;
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
        Slice!ubyte decompressed;
        auto didDecompress = decompressDeflate(source, decompressed, allocator);
        if (!didDecompress)
            return typeof(return)(didDecompress.getError());

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
