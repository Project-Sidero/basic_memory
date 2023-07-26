module sidero.base.compression.deflate.decompression;
import sidero.base.compression.deflate.defs;
import sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.allocators;
import sidero.base.errors;

export @safe nothrow @nogc:

///
Result!size_t decompressDeflate(scope Slice!ubyte source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    Appender!ubyte result = Appender!ubyte(allocator);

    auto ret = decompressDeflate(bitReader, result, allocator);
    if(ret)
        output = result.asReadOnly(allocator);
    return ret;
}

///
Result!size_t decompressDeflate(scope DynamicArray!ubyte source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    Appender!ubyte result = Appender!ubyte(allocator);

    auto ret = decompressDeflate(bitReader, result, allocator);
    if(ret)
        output = result.asReadOnly(allocator);
    return ret;
}

///
Result!size_t decompressDeflate(scope const(ubyte)[] source, scope out Slice!ubyte output, RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    Appender!ubyte result = Appender!ubyte(allocator);

    auto ret = decompressDeflate(bitReader, result, allocator);
    if(ret)
        output = result.asReadOnly(allocator);
    return ret;
}

package(sidero.base.compression):
import sidero.base.compression.huffman;
import sidero.base.containers.appender;
import sidero.base.compression.internal.bitreader;
import sidero.base.compression.internal.bitwriter;

Result!size_t decompressDeflate(scope ref BitReader source, scope ref Appender!ubyte result, RCAllocator allocator = RCAllocator.init) @trusted {
    if(source.lengthOfSource == 0)
        return typeof(return)(0);

    const originallyConsumed = source.consumed;
    initGlobalTrees;

    TreeState treeState;
    BlockState blockState;

    ErrorInfo startNewBlock() @trusted {
        if(blockState.isLast)
            return ErrorInfo.init;
        else if(!source.haveMoreBits)
            return ErrorInfo(MalformedInputException("No final block"));

        {
            auto isLast = source.nextBits(1), btype = source.nextBits(2);

            if(!isLast)
                return isLast.getError();
            else if(!btype)
                return btype.getError();

            blockState = BlockState(cast(bool)isLast.get, cast(BTYPE)btype.get, false);
        }

        final switch(blockState.type) {
        case BTYPE.NoCompression:
            source.ignoreBits;
            auto len = source.nextShort, nlen = source.nextShort;

            if(!len)
                return len.getError();
            else if(!nlen)
                return nlen.getError();

            if(len.get != ((~nlen.get) & 0xFFFF))
                return ErrorInfo(MalformedInputException("Length and 2's complement do not match"));

            blockState.noCompression.amountToGo = len.get;
            break;

        case BTYPE.DynamicHuffmanCodes:
            ErrorInfo error = readDynamicHuffmanTrees(source, treeState);
            if(error.isSet)
                return error;

            treeState.symbolTree = &treeState.dynamicSymbolTree;
            treeState.distanceTree = &treeState.dynamicDistanceTree;
            break;

        case BTYPE.FixedHuffmanCodes:
            treeState.symbolTree = &fixedLiteralSymbolTree;
            treeState.distanceTree = &fixedDistanceTree;
            break;

        case BTYPE.Reserved:
            return ErrorInfo(MalformedInputException("Reserved block type"));
        }

        return ErrorInfo.init;
    }

    void emitByte(ubyte value) {
        result ~= value;
    }

    void emitBytes(scope const(ubyte)[] values) {
        result ~= values;
    }

    while(source.haveMoreBits && !(blockState.complete && blockState.isLast)) {
        if(blockState.complete) {
            auto error = startNewBlock;
            if(error.isSet)
                return typeof(return)(error);
        }

        final switch(blockState.type) {
        case BTYPE.NoCompression:
            size_t toProcess = blockState.noCompression.amountToGo;

            if(toProcess >= ushort.max / 2)
                toProcess = ushort.max / 2;

            auto got = source.consumeExact(toProcess);

            if(got.length != toProcess)
                return typeof(return)(MalformedInputException("Not enough input for no compression block"));
            emitBytes(got);

            blockState.noCompression.amountToGo = 0;
            blockState.complete = true;
            break;

        case BTYPE.DynamicHuffmanCodes:
        case BTYPE.FixedHuffmanCodes:
            while(source.haveMoreBits()) {
                size_t symbol;
                auto symbolBits = treeState.symbolTree.lookupValue(&source.nextBit, &source.haveMoreBits, symbol);
                if(!symbolBits || !symbolBits.get)
                    return typeof(return)(MalformedInputException("Incomplete huffman tree"));

                if(symbol < 256) {
                    emitByte(cast(ubyte)symbol);
                } else if(symbol == 256) {
                    blockState.complete = true;
                    break;
                } else if(symbol < 286) {
                    symbol -= 257;

                    auto lengthBits = source.nextBits(lengthExtraBits[symbol]);
                    if(!lengthBits)
                        return typeof(return)(MalformedInputException("Not enough backwards length lookup bits"));
                    const length = lengthBits.get + lengthBase[symbol];

                    size_t distanceSymbol;
                    auto completeTree = treeState.distanceTree.lookupValue(&source.nextBit, &source.haveMoreBits, distanceSymbol);
                    if(!completeTree || !completeTree.get)
                        return typeof(return)(MalformedInputException("Incomplete huffman tree"));

                    auto distanceBits = source.nextBits(distanceExtraBits[distanceSymbol]);
                    if(!distanceBits)
                        return typeof(return)(MalformedInputException("Not enough backwards distance lookup bits"));

                    const distance = distanceBits.get + distanceBase[distanceSymbol];
                    assert(distance > 0);

                    foreach(offset; 0 .. length) {
                        if(result.length < distance)
                            return typeof(return)(MalformedInputException("Not enough decompressed data given distance lookup value"));

                        auto temp = result[-cast(ptrdiff_t)distance];
                        if(!temp)
                            return typeof(return)(temp.getError());

                        emitByte(temp.get);
                    }
                } else
                    return typeof(return)(MalformedInputException("Incorrect huffman tree"));
            }
            break;

        case BTYPE.Reserved:
            return typeof(return)(MalformedInputException("Reserved block type"));
        }
    }

    if(source.consumed == originallyConsumed)
        return typeof(return)(0);
    else if(!blockState.isLast)
        return typeof(return)(MalformedInputException("Incomplete block stream, no final block"));
    else if(blockState.complete)
        return typeof(return)(source.consumed - originallyConsumed);
    else
        return typeof(return)(MalformedInputException("Incomplete block stream"));
}

ErrorInfo readDynamicHuffmanTrees(scope ref BitReader bitReader, scope ref TreeState treeState) @trusted {
    treeState.dynamicSymbolTree.clear;

    // literal/length alphabet 257 .. 286]
    // distance codes 1 .. 32]
    // code lengths 4 .. 19]
    int hlit, hdist, hclen;
    ubyte[19] bdtcl = void;
    HuffManTree!19 codeLengthTree;

    {
        Result!ubyte error;

        error = bitReader.nextBits(5);
        if(!error)
            return error.getError();
        hlit = error.get + 257;

        error = bitReader.nextBits(5);
        if(!error)
            return error.getError();
        hdist = error.get + 1;

        error = bitReader.nextBits(4);
        if(!error)
            return error.getError();
        hclen = error.get + 4;
    }

    {
        foreach(i; 0 .. hclen) {
            // 0 .. 7]
            Result!ubyte codeLength = bitReader.nextBits(3);
            if(!codeLength)
                return codeLength.getError();

            const offset = codeLengthAlphabet[i];
            bdtcl[offset] = codeLength.get;
        }

        foreach(i; hclen .. 19) {
            const offset = codeLengthAlphabet[i];
            bdtcl[offset] = 0;
        }

        ErrorInfo error = getDeflateHuffmanBits(bdtcl[], &codeLengthTree.addLeafMSB);
        if(error.isSet)
            return error;
    }

    ubyte[320] treeBuffer = void;
    size_t treeBufferOffset;

    while(treeBufferOffset < hlit + hdist) {
        size_t symbol;

        auto check = codeLengthTree.lookupValue(&bitReader.nextBit, &bitReader.haveMoreBits, symbol);
        if(!check || !check.get)
            return ErrorInfo(MalformedInputException("Incorrect huffman tree"));

        switch(symbol) {
        case 0: .. case 15:
            treeBuffer[treeBufferOffset++] = cast(ubyte)symbol;
            break;
        case 16:
            if(treeBufferOffset == 0)
                return ErrorInfo(MalformedInputException("Not enough preceeding symbols"));

            const previousCodeLength = treeBuffer[treeBufferOffset - 1];
            auto multiplier = bitReader.nextBits(2);
            if(!multiplier)
                return multiplier.getError();

            treeBuffer[treeBufferOffset .. treeBufferOffset + multiplier.get + 3][] = previousCodeLength;
            treeBufferOffset += multiplier.get + 3;
            break;
        case 17:
            auto multiplier = bitReader.nextBits(3);
            if(!multiplier)
                return multiplier.getError();

            treeBuffer[treeBufferOffset .. treeBufferOffset + multiplier.get + 3][] = 0;
            treeBufferOffset += multiplier.get + 3;
            break;
        case 18:
            auto multiplier = bitReader.nextBits(7);
            if(!multiplier)
                return multiplier.getError();

            treeBuffer[treeBufferOffset .. treeBufferOffset + multiplier.get + 11][] = 0;
            treeBufferOffset += multiplier.get + 11;
            break;

        default:
            return ErrorInfo(MalformedInputException("Incorrect huffman tree, OOB"));
        }
    }

    treeState.dynamicSymbolTree.clear;
    treeState.dynamicDistanceTree.clear;

    getDeflateHuffmanBits(treeBuffer[0 .. hlit], &treeState.dynamicSymbolTree.addLeafMSB);
    getDeflateHuffmanBits(treeBuffer[hlit .. hlit + hdist], &treeState.dynamicDistanceTree.addLeafMSB);
    return typeof(return).init;
}

@trusted unittest {
    bool test(ubyte[] toDecompress, ubyte[] expected) {
        Slice!ubyte output;
        auto consumed = decompressDeflate(toDecompress, output);
        if(!consumed || consumed.get != toDecompress.length || output.length != expected.length)
            return false;

        size_t offset;

        foreach(ubyte v; output) {
            if(offset >= expected.length || expected[offset++] != v)
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
