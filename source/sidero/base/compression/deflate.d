/// https://tools.ietf.org/html/rfc1951
/// https://pyokagan.name/blog/2019-10-18-zlibinflate/
/// https://www.infinitepartitions.com/art001.html
module sidero.base.compression.deflate;
import sidero.base.compression.huffman;
import sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.containers.appender;
import sidero.base.allocators;
import sidero.base.errors;

export @safe nothrow @nogc:

enum DeflateCompressionRate {
    None,
    FixedHuffManTree,
    DynamicHuffManTree,
    HashWithFixedHuffManTree,
    DeepHashWithFixedHuffManTree,

    Fastest = None,
    Fast = DynamicHuffManTree,
    Slow = HashWithFixedHuffManTree,
    Slowest = DeepHashWithFixedHuffManTree,
}

///
Result!size_t decompressDeflate(scope Slice!ubyte source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return decompressDeflate(bitReader, output, allocator);
}

///
Result!size_t decompressDeflate(scope DynamicArray!ubyte source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return decompressDeflate(bitReader, output, allocator);
}

///
Result!size_t decompressDeflate(scope const(ubyte)[] source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    return decompressDeflate(bitReader, output, allocator);
}

///
Slice!ubyte compressDeflate(scope Slice!ubyte source, DeflateCompressionRate rate, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return compressDeflate(bitReader, rate, allocator);
}

///
Slice!ubyte compressDeflate(scope DynamicArray!ubyte source, DeflateCompressionRate rate, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    return compressDeflate(bitReader, rate, allocator);
}

///
Slice!ubyte compressDeflate(scope const(ubyte)[] source, DeflateCompressionRate rate, RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    return compressDeflate(bitReader, rate, allocator);
}

package(sidero.base.compression):

Result!size_t decompressDeflate(scope ref BitReader source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    if (source.lengthOfSource == 0)
        return typeof(return)(0);

    const originallyConsumed = source.consumed;
    initGlobalTrees;
    Appender!ubyte result = Appender!ubyte(allocator);

    TreeState treeState;
    BlockState blockState;

    ErrorInfo startNewBlock() @trusted {
        if (blockState.isLast)
            return ErrorInfo.init;
        else if (!source.haveMoreBits)
            return ErrorInfo(MalformedInputException("No final block"));

        {
            auto isLast = source.nextBits(1), btype = source.nextBits(2);

            if (!isLast)
                return isLast.getError();
            else if (!btype)
                return btype.getError();

            blockState = BlockState(cast(bool)isLast.get, cast(BTYPE)btype.get, false);
        }

        final switch (blockState.type) {
        case BTYPE.NoCompression:
            source.ignoreBits;
            auto len = source.nextShort, nlen = source.nextShort;

            if (!len)
                return len.getError();
            else if (!nlen)
                return nlen.getError();

            if (len.get != ((~nlen.get) & 0xFFFF))
                return ErrorInfo(MalformedInputException("Length and 2's complement do not match"));

            blockState.noCompression.amountToGo = len.get;
            break;

        case BTYPE.DynamicHuffmanCodes:
            ErrorInfo error = readDynamicHuffmanTrees(source, treeState);
            if (error.isSet)
                return error;

            treeState.literalSymbolTree = &treeState.dynamicLiteralSymbolTree;
            treeState.distanceTree = &treeState.dynamicDistanceTree;
            break;

        case BTYPE.FixedHuffmanCodes:
            treeState.literalSymbolTree = &fixedLiteralSymbolTree;
            treeState.distanceTree = &fixedDistanceTree;
            break;

        case BTYPE.Reserved:
            return ErrorInfo(MalformedInputException("Reserved block type"));
        }

        return ErrorInfo.init;
    }

    while (source.haveMoreBits && !(blockState.complete && blockState.isLast)) {
        if (blockState.complete) {
            auto error = startNewBlock;
            if (error.isSet)
                return typeof(return)(error);
        }

        final switch (blockState.type) {
        case BTYPE.NoCompression:
            size_t toProcess = blockState.noCompression.amountToGo;

            if (toProcess >= ushort.max / 2)
                toProcess = ushort.max / 2;

            auto got = source.consumeExact(toProcess);

            if (got.length != toProcess)
                return typeof(return)(MalformedInputException("Not enough input for no compression block"));
            result ~= got;

            blockState.noCompression.amountToGo = 0;
            blockState.complete = true;
            break;

        case BTYPE.DynamicHuffmanCodes:
        case BTYPE.FixedHuffmanCodes:
            while (source.haveMoreBits()) {
                size_t symbol;
                auto symbolBits = treeState.literalSymbolTree.lookupValue(&source.nextBit, &source.haveMoreBits, symbol);
                if (!symbolBits || !symbolBits.get)
                    return typeof(return)(MalformedInputException("Incomplete huffman tree"));

                if (symbol < 256) {
                    result ~= cast(ubyte)symbol;
                } else if (symbol == 256) {
                    blockState.complete = true;
                    break;
                } else if (symbol < 285) {
                    symbol -= 257;

                    auto lengthBits = source.nextBits(lengthExtraBits[symbol]);
                    if (!lengthBits)
                        return typeof(return)(MalformedInputException("Not enough backwards length lookup bits"));
                    const length = lengthBits.get + lengthBase[symbol];

                    size_t distanceSymbol;
                    auto completeTree = treeState.distanceTree.lookupValue(&source.nextBit, &source.haveMoreBits, distanceSymbol);
                    if (!completeTree || !completeTree.get)
                        return typeof(return)(MalformedInputException("Incomplete huffman tree"));

                    auto distanceBits = source.nextBits(distanceExtraBits[distanceSymbol]);
                    if (!distanceBits)
                        return typeof(return)(MalformedInputException("Not enough backwards distance lookup bits"));

                    const distance = distanceBits.get + distanceBase[distanceSymbol];
                    assert(distance > 0);

                    foreach (offset; 0 .. length) {
                        auto temp = result[-cast(ptrdiff_t)distance];
                        if (!temp)
                            return typeof(return)(temp.getError());

                        result ~= temp.get;
                    }
                } else
                    return typeof(return)(MalformedInputException("Incorrect huffman tree"));
            }
            break;

        case BTYPE.Reserved:
            return typeof(return)(MalformedInputException("Reserved block type"));
        }
    }

    if (source.consumed == originallyConsumed)
        return typeof(return)(0);
    else if (blockState.complete && blockState.isLast) {
        output = result.asReadOnly(allocator);
        return typeof(return)(source.consumed - originallyConsumed);
    } else {
        return typeof(return)(MalformedInputException("Incomplete block stream, no final block"));
    }
}

Slice!ubyte compressDeflate(scope ref BitReader source, DeflateCompressionRate compressionRate, RCAllocator allocator = RCAllocator.init) @trusted {
    import sidero.base.compression.internal.bitwriter;

    enum BlockSizeToWalk = 16 * 1024;

    initGlobalTrees;
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    void emitBlockHeader(bool isLast, BTYPE type) {
        ubyte b = cast(ubyte)type;

        result.writeBit(isLast);

        result.writeBit((b & 1) == 1);
        result.writeBit((b & 2) == 2);
    }

    void emitSymbol(ushort[2] symbol) {
        const shiftMSBLeftToMax = 16 - symbol[1];
        uint tempPath = symbol[0] << shiftMSBLeftToMax;

        foreach (i; 0 .. symbol[1]) {
            const bit = (tempPath & 0x8000) > 0;
            tempPath <<= 1;
            result.writeBit(bit);
        }
    }

    for (;;) {
        const startSourceLength = source.lengthOfSource;
        if (startSourceLength == 0)
            break;

        const lengthForBlock = cast(ushort)(startSourceLength > BlockSizeToWalk ? BlockSizeToWalk : startSourceLength);
        const isLast = lengthForBlock == startSourceLength;

        final switch (compressionRate) {
        case DeflateCompressionRate.None:
            // no compression is pretty easy to implement

            emitBlockHeader(isLast, BTYPE.NoCompression);
            result.flushBits;

            result.writeShorts(lengthForBlock, cast(ushort)~lengthForBlock);

            auto data = source.consumeExact(lengthForBlock);
            result.writeBytes(data);
            break;

        case DeflateCompressionRate.FixedHuffManTree:
            // the goal of this one is to use the fixed huffman trees
            // probably isn't worth it if lengthOfBlock <= 32

            if (lengthForBlock <= 32)
                goto case DeflateCompressionRate.None;

            emitBlockHeader(isLast, BTYPE.FixedHuffmanCodes);

            foreach (i; 0 .. lengthForBlock) {
                auto b = source.nextByte();
                assert(b);
                emitSymbol(fixedLiteralSymbolValuePaths[b.get]);
            }

            // EMIT 256 aka end
            emitSymbol(fixedLiteralSymbolValuePaths[256]);
            break;

        case DeflateCompressionRate.DynamicHuffManTree:
            // build huffman tree, write it out
            // probably isn't worth it if lengthOfBlock <= 64
            goto case DeflateCompressionRate.None;
        case DeflateCompressionRate.HashWithFixedHuffManTree:
            // build hash chain, but only look for first match
            // probably isn't worth it if lengthOfBlock <= 32
            // write out using fixed huffman tree
            goto case DeflateCompressionRate.None;
        case DeflateCompressionRate.DeepHashWithFixedHuffManTree:
            // build hash chain, look for longest match
            // create a dynamic huffman tree and write that out
            // probably isn't worth it if lengthOfBlock <= 64
            goto case DeflateCompressionRate.None;
        }
    }

    return result.asReadOnly(allocator);
}

private:
import sidero.base.compression.internal.bitreader;
import sidero.base.parallelism.mutualexclusion;

struct TreeState {
    HuffManTree!288* literalSymbolTree;
    HuffManTree!30* distanceTree;

    HuffManTree!288 dynamicLiteralSymbolTree;
    HuffManTree!30 dynamicDistanceTree;
}

struct BlockState {
    // 0
    bool isLast;
    // 1 .. 2
    BTYPE type;

    bool complete = true;
    size_t amountProcessed;

    NoCompression noCompression;

    static struct NoCompression {
        ushort amountToGo;
    }
}

enum BTYPE {
    NoCompression = 0,
    FixedHuffmanCodes = 1,
    DynamicHuffmanCodes = 2,
    Reserved = 3
}

static immutable lengthExtraBits = [
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0
];
static immutable lengthBase = [
    3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258
];
static immutable distanceExtraBits = [
    0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13
];
static immutable distanceBase = [
    1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145,
    8193, 12289, 16385, 24577
];

__gshared {
    TestTestSetLockInline initTreeLock;
    bool isGlobalTreesSetup;
    HuffManTree!288 fixedLiteralSymbolTree;
    HuffManTree!30 fixedDistanceTree;
    ushort[2][288] fixedLiteralSymbolValuePaths;
}

void initGlobalTrees() @trusted {
    if (isGlobalTreesSetup)
        return;

    initTreeLock.pureLock;

    {
        ubyte[288] literalLength;
        literalLength[0 .. 144] = 8;
        literalLength[144 .. 256] = 9;
        literalLength[256 .. 280] = 7;
        literalLength[280 .. 288] = 8;

        getDeflateHuffmanBits(literalLength[], &fixedLiteralSymbolTree.addLeafMSB);
        fixedLiteralSymbolValuePaths = fixedLiteralSymbolTree.pathForValues();
    }

    {
        ubyte[30] distance;
        distance[] = 5;

        getDeflateHuffmanBits(distance[], &fixedDistanceTree.addLeafMSB);
    }

    isGlobalTreesSetup = true;
    initTreeLock.unlock;
}

ErrorInfo getDeflateHuffmanBits(scope const(ubyte)[] lengths, scope void delegate(ushort, size_t, size_t) @safe nothrow @nogc gotValue) {
    size_t[16] bl_count;

    foreach (v; lengths[0 .. lengths.length]) {
        if (v > 15)
            return ErrorInfo(MalformedInputException("Invalid huffman length"));
        bl_count[v]++;
    }

    bl_count[0] = 0;

    uint code;
    uint[16] next_code = void;
    next_code[1] = 0;

    // skip first entry which will be zero.
    foreach (bits; 2 .. 16) {
        code += bl_count[bits - 1];
        code <<= 1;

        next_code[bits] = code;
    }

    foreach (offset, length; lengths) {
        if (length == 0)
            continue;

        gotValue(cast(ushort)(next_code[length]++), length, offset);
    }

    return ErrorInfo.init;
}

ErrorInfo readDynamicHuffmanTrees(scope ref BitReader bitReader, scope ref TreeState treeState) @trusted {
    static immutable codeLengthAlphabet = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];

    treeState.dynamicLiteralSymbolTree.clear;

    // literal/length alphabet 257 .. 286]
    // distance codes 1 .. 32]
    // code lengths 4 .. 19]
    int hlit, hdist, hclen;
    ubyte[19] bdtcl = void;

    {
        Result!ubyte error;

        error = bitReader.nextBits(5);
        if (!error)
            return error.getError();
        hlit = error.get + 257;

        error = bitReader.nextBits(5);
        if (!error)
            return error.getError();
        hdist = error.get + 1;

        error = bitReader.nextBits(4);
        if (!error)
            return error.getError();
        hclen = error.get + 4;
    }

    foreach (i; 0 .. hclen) {
        // 0 .. 7]
        Result!ubyte codeLength = bitReader.nextBits(3);
        if (!codeLength)
            return codeLength.getError();

        const offset = codeLengthAlphabet[i];
        bdtcl[offset] = codeLength.get;
    }

    {
        ErrorInfo error = getDeflateHuffmanBits(bdtcl[], &treeState.dynamicLiteralSymbolTree.addLeafMSB);
        if (error.isSet)
            return error;
    }

    ubyte[288] treeBuffer = void;
    size_t treeBufferOffset;

    while (treeBufferOffset < hdist + hlit) {
        size_t symbol;

        auto check = treeState.dynamicLiteralSymbolTree.lookupValue(&bitReader.nextBit, &bitReader.haveMoreBits, symbol);
        if (!check || !check.get)
            return ErrorInfo(MalformedInputException("Incorrect huffman tree"));

        switch (symbol) {
        case 0: .. case 15:
            treeBuffer[treeBufferOffset++] = cast(ubyte)symbol;
            break;
        case 16:
            if (treeBufferOffset == 0)
                return ErrorInfo(MalformedInputException("Not enough preceeding symbols"));

            const previousCodeLength = treeBuffer[treeBufferOffset - 1];
            auto multiplier = bitReader.nextBits(2);
            if (!multiplier)
                return multiplier.getError();

            treeBuffer[treeBufferOffset .. treeBufferOffset + multiplier.get + 3][] = previousCodeLength;
            treeBufferOffset += multiplier.get + 3;
            break;
        case 17:
            auto multiplier = bitReader.nextBits(3);
            if (!multiplier)
                return multiplier.getError();

            treeBuffer[treeBufferOffset .. treeBufferOffset + multiplier.get + 3][] = 0;
            treeBufferOffset += multiplier.get + 3;
            break;
        case 18:
            auto multiplier = bitReader.nextBits(7);
            if (!multiplier)
                return multiplier.getError();

            treeBuffer[treeBufferOffset .. treeBufferOffset + multiplier.get + 11][] = 0;
            treeBufferOffset += multiplier.get + 11;
            break;

        default:
            return ErrorInfo(MalformedInputException("Incorrect huffman tree"));
        }
    }

    treeState.dynamicLiteralSymbolTree.clear;
    treeState.dynamicDistanceTree.clear;

    getDeflateHuffmanBits(treeBuffer[0 .. hlit], &treeState.dynamicLiteralSymbolTree.addLeafMSB);
    getDeflateHuffmanBits(treeBuffer[hlit .. hlit + hdist], &treeState.dynamicDistanceTree.addLeafMSB);
    return typeof(return).init;
}

@trusted unittest {
    bool test(ubyte[] toDecompress, ubyte[] expected) {
        Slice!ubyte output;
        auto consumed = decompressDeflate(toDecompress, output);

        if (!consumed || consumed.get != toDecompress.length || output.length != expected.length)
            return false;

        size_t offset;

        foreach (ubyte v; output) {
            if (offset >= expected.length || expected[offset++] != v)
                return false;
        }

        return true;
    }

    assert(test([cast(ubyte)1, 7, 0, 248, 255, 72, 101, 108, 108, 111, 32, 68], cast(ubyte[])"Hello D"));

    // from: https://github.com/nayuki/Simple-DEFLATE-decompressor/blob/master/java/test/DecompressorTest.java
    assert(test(null, null));
    assert(!test([7], null)); // reserved
    assert(!test([1], null)); // partial block
    assert(test([1, 0, 0, 255, 255], null)); // empty uncompressed block
    assert(test([1, 3, 0, 252, 255, 5, 20, 35], [0x05, 0x14, 0x23])); // uncompressed block
    assert(test([0, 2, 0, 253, 255, 5, 20, 1, 1, 0, 254, 255, 35], [0x05, 0x14, 0x23])); // two uncompressed blocks
    assert(!test([1], null)); // empty uncompressed block with partial padding
    assert(!test([1, 0, 0], null)); // empty uncompressed block
    assert(!test([1, 4, 8, 159, 172], null)); // mismatchesd length and 2's complement for uncompressed block
    assert(!test([249, 6, 0, 249, 255, 85, 238], null)); // uncompressed block, not enough data
    assert(!test([0, 0, 0, 255, 255], null)); // uncompressed block, no final block
    assert(test([154, 176, 240, 63, 32, 2, 0, 253, 255, 171, 205], [0x90, 0xA1, 0xFF, 0xAB, 0xCD])); // huffman block end, uncompresed block
    assert(test([3, 0], null)); // fixed huffman end
    assert(test([99, 104, 232, 159, 112, 224, 63, 0], [0x0, 0x80, 0x8f, 0x90, 0xC0, 0xFF])); // fixed huffman end
    assert(test([99, 96, 100, 2, 34, 0], [0x0, 0x01, 0x02, 0x0, 0x01, 0x02])); // fixed huffman end
    assert(test([99, 4, 1, 0], [0x1, 0x1, 0x1, 0x1, 0x1])); // fixed huffman end
    assert(test([235, 235, 7, 67, 0], [0x8E, 0x8F, 0x8E, 0x8F, 0x8E, 0x8F, 0x8E])); // fixed huffman end
    assert(!test([27, 3], null)); // fixed huffman out of range
    assert(!test([27, 7], null)); // fixed huffman out of range
    assert(!test([99, 0, 62], null)); // fixed huffman
    assert(!test([99, 0, 126], null)); // fixed huffman
    assert(!test([3], null)); // fixed huffman partial
    assert(!test([99, 192, 6], null)); // fixed huffman partial
    assert(!test([99, 24, 5, 64, 1], null)); // fixed huffman partial
    assert(test([5, 225, 129, 0, 0, 0, 0, 0, 16, 248, 175, 70], null)); // dynamic huffman end
    assert(test([5, 192, 129, 8, 0, 0, 0, 0, 32, 127, 234, 47], null)); // dynamic huffman end
    assert(!test([5, 192, 3, 0, 0, 0, 0, 0, 144], null)); // dynamic huffman
    assert(!test([5, 192, 129, 0, 0, 0, 0, 0, 16, 254, 179, 1], null)); // dynamic huffman
    assert(!test([5, 0, 146, 0, 0, 0], null)); // dynamic huffman
    assert(!test([5, 0, 162, 1, 0, 0], null)); // dynamic huffman
    assert(!test([5, 0, 0, 0, 0, 0], null)); // dynamic huffman
    assert(!test([5, 0, 128, 0, 0, 0], null)); // dynamic huffman
    assert(!test([5, 0, 20, 0, 0, 0], null)); // dynamic huffman
    assert(!test([13, 192, 1, 9, 0, 0, 0, 128, 32, 250, 127, 218, 108, 0], null)); // dynamic huffman
    assert(!test([13, 192, 1, 9, 0, 0, 0, 128, 32, 250, 127, 218, 236, 0], null)); // dynamic huffman
    assert(!test([13, 192, 1, 9, 0, 0, 0, 128, 160, 254, 175, 54, 26, 0, 0], null)); // dynamic huffman
}

@trusted unittest {
    bool test(ubyte[] toCompress, DeflateCompressionRate rate) @trusted {
        Slice!ubyte compressed, decompressed;

        compressed = compressDeflate(toCompress, rate);
        if (compressed.length == 0)
            return false;

        auto consumed = decompressDeflate(compressed, decompressed);
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
}
