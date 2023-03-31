module sidero.base.compression.deflate.compression;
import sidero.base.compression.deflate.defs;
import sidero.base.containers.readonlyslice;
import sidero.base.containers.dynamicarray;
import sidero.base.allocators;
import sidero.base.errors;

export @safe nothrow @nogc:

///
Slice!ubyte compressDeflate(scope Slice!ubyte source, DeflateCompressionRate rate = DeflateCompressionRate.Default,
        RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    size_t amountInFirstBatch;
    compressDeflate(bitReader, result, rate, 0, amountInFirstBatch, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressDeflate(scope DynamicArray!ubyte source, DeflateCompressionRate rate = DeflateCompressionRate.Default,
        RCAllocator allocator = RCAllocator.init) @trusted {
    BitReader bitReader = BitReader(source.unsafeGetLiteral());
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    size_t amountInFirstBatch;
    compressDeflate(bitReader, result, rate, 0, amountInFirstBatch, allocator);
    return result.asReadOnly(allocator);
}

///
Slice!ubyte compressDeflate(scope const(ubyte)[] source, DeflateCompressionRate rate = DeflateCompressionRate.Default,
        RCAllocator allocator = RCAllocator.init) {
    BitReader bitReader = BitReader(source);
    BitWriter result = BitWriter(Appender!ubyte(allocator));

    size_t amountInFirstBatch;
    compressDeflate(bitReader, result, rate, 0, amountInFirstBatch, allocator);
    return result.asReadOnly(allocator);
}

package(sidero.base.compression):
import sidero.base.compression.huffman;
import sidero.base.containers.appender;
import sidero.base.compression.internal.bitreader;
import sidero.base.compression.internal.bitwriter;
import sidero.base.compression.internal.hashchain;

void compressDeflate(scope ref BitReader source, scope ref BitWriter result, DeflateCompressionRate compressionRate,
        size_t amountNeededInFirstBatch, out size_t amountInFirstBatch, RCAllocator allocator = RCAllocator.init) @trusted {
    import sidero.base.compression.internal.hashchain;
    import std.algorithm : min;

    DeflateCompressionImpl impl = DeflateCompressionImpl(source, result, compressionRate, amountNeededInFirstBatch,
            amountInFirstBatch, allocator);
    impl.perform();
}

struct DeflateCompressionImpl {
    BitReader* source;
    BitWriter* result;
    DeflateCompressionRate compressionRate;
    size_t amountNeededInFirstBatch, amountInFirstBatch;
    RCAllocator allocator;

    enum BlockSizeToWalk = 16 * 1024;

@safe nothrow @nogc:

    this(scope ref BitReader source, scope ref BitWriter result, DeflateCompressionRate compressionRate,
            size_t amountNeededInFirstBatch, out size_t amountInFirstBatch, RCAllocator allocator = RCAllocator.init) @trusted {
        this.source = &source;
        this.result = &result;
        this.compressionRate = compressionRate;
        this.amountNeededInFirstBatch = amountNeededInFirstBatch;
        this.amountInFirstBatch = amountInFirstBatch;
        this.allocator = allocator;

        initGlobalTrees;
    }

    void perform() {
        import std.algorithm : min;

        const initialConsumed = source.consumed;
        bool isFirst = true;

        for (;;) {
            const startSourceLength = source.lengthOfSource;
            if (startSourceLength == 0)
                break;

            const lengthForBlock = cast(ushort)(amountNeededInFirstBatch > 0 ? (amountNeededInFirstBatch > startSourceLength ?
        startSourceLength : amountNeededInFirstBatch) : (startSourceLength > BlockSizeToWalk ? BlockSizeToWalk : startSourceLength));
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
                auto toCompress = source.consumeExact(lengthForBlock);
                assert(toCompress.length == lengthForBlock);

                foreach (i; 0 .. lengthForBlock) {
                    emitFixedSymbol(toCompress[i]);
                }

                // EMIT 256 aka end
                emitFixedSymbol(256);
                break;

            case DeflateCompressionRate.DynamicHuffManTree:
                // build huffman tree, write it out
                // probably isn't worth it if lengthOfBlock <= 64
                // so we'll swap over to fixed huffman tree

                if (lengthForBlock <= 64)
                    goto case DeflateCompressionRate.FixedHuffManTree;

                emitBlockHeader(isLast, BTYPE.DynamicHuffmanCodes);
                auto toCompress = source.consumeExact(lengthForBlock);
                assert(toCompress.length == lengthForBlock);

                HuffManTree!288 symbolTree;
                ushort[2][288] symbolValuePaths = void;

                {
                    auto symbolDepths = symbolTree.buildFromData(toCompress, 256);

                    // The huffman tree won't be setup in the right order for DEFLATE,
                    //  so we need to recreate it but with our guarantees.
                    symbolTree.clear;
                    ErrorInfo error = getDeflateHuffmanBits(symbolDepths, &symbolTree.addLeafMSB);
                    assert(!error.isSet);

                    emitHuffManTree(symbolDepths, null);
                    symbolValuePaths = symbolTree.pathForValues();
                }

                foreach (i; 0 .. lengthForBlock) {
                    emitSymbolMSB(symbolValuePaths[toCompress[i]]);
                }

                // EMIT 256 aka end
                emitSymbolMSB(symbolValuePaths[256]);
                break;

            case DeflateCompressionRate.HashWithFixedHuffManTree:
                // build hash chain, but only look for first match
                // probably isn't worth it if lengthOfBlock <= 32
                // write out using fixed huffman tree
                // probably isn't worth it if lengthOfBlock <= 64
                if (lengthForBlock <= 64)
                    goto case DeflateCompressionRate.FixedHuffManTree;

                emitBlockHeader(isLast, BTYPE.FixedHuffmanCodes);
                auto toCompress = source.consumeExact(lengthForBlock);
                assert(toCompress.length == lengthForBlock);

                hashChainImplementation(isFirst, startSourceLength - initialConsumed, toCompress, false, 0, 4, 4 * 1024);
                break;
            case DeflateCompressionRate.HashWithDynamicHuffManTree:
                // build hash chain, look for longest match
                // create a dynamic huffman tree and write that out
                // probably isn't worth it if lengthOfBlock <= 64
                if (lengthForBlock <= 64)
                    goto case DeflateCompressionRate.FixedHuffManTree;

                emitBlockHeader(isLast, BTYPE.DynamicHuffmanCodes);
                auto toCompress = source.consumeExact(lengthForBlock);
                assert(toCompress.length == lengthForBlock);

                hashChainImplementation(isFirst, startSourceLength - initialConsumed, toCompress, true, 0, 6, 4 * 1024);
                break;
            case DeflateCompressionRate.DeepHashWithDynamicHuffManTree:
                // build hash chain, look for longest match, do it sqrt(found match) times
                // if better match is found look for match whose length is below the delta offset of the better one
                // use literal symbols in between the two
                // create a dynamic huffman tree and write that out
                // probably isn't worth it if lengthOfBlock <= 64
                if (lengthForBlock <= 64)
                    goto case DeflateCompressionRate.FixedHuffManTree;

                emitBlockHeader(isLast, BTYPE.DynamicHuffmanCodes);
                auto toCompress = source.consumeExact(lengthForBlock);
                assert(toCompress.length == lengthForBlock);

                hashChainImplementation(isFirst, startSourceLength - initialConsumed, toCompress, true, 8, 8, 4 * 1024);
                break;
            }

            if (amountNeededInFirstBatch > 0) {
                amountNeededInFirstBatch -= lengthForBlock;
                amountInFirstBatch += result.output.length;
            }

            isFirst = false;
        }
    }

    //

    HashChain hashChain;

    Appender!ushort dynamicHuffManSymbols, dynamicHuffManDistances, onlyDynamicHuffManDistances;
    Appender!(ushort[2]) symbolExtras, distanceExtras;

    //

    void emitBlockHeader(bool isLast, BTYPE type) {
        ubyte b = cast(ubyte)type;

        result.writeBit(isLast);
        result.writeBit((b & 1) == 1);
        result.writeBit((b & 2) == 2);
    }

    void emitSymbol(ushort[2] symbol) {
        assert(symbol[1] > 0);

        uint tempPath = symbol[0];
        foreach (i; 0 .. symbol[1]) {
            const bit = (tempPath & 1) == 1;
            tempPath >>= 1;
            result.writeBit(bit);
        }
    }

    void emitSymbolMSB(ushort[2] symbol) {
        const shiftMSBLeftToMax = 16 - symbol[1];
        uint tempPath = symbol[0] << shiftMSBLeftToMax;
        assert(symbol[1] > 0);

        foreach (i; 0 .. symbol[1]) {
            const bit = (tempPath & 0x8000) > 0;
            tempPath <<= 1;
            result.writeBit(bit);
        }
    }

    void emitHuffManTree(ushort[288] symbolDepths, scope ushort[] distanceDepths) {
        ushort hlit = 29, hdist, hclen;

        {
            // HLIT - 257 as 5 bits, number of non-zero in depths
            // its ok for HLIT to be zero here.

            foreach_reverse (depth; symbolDepths[$ - 31 .. $ - 2]) {
                if (depth != 0)
                    break;
                hlit--;
            }

            emitSymbol([hlit, 5]);
        }

        {
            // HDIST - 1 as 5 bits
            if (distanceDepths.length > 0)
                hdist = cast(ushort)(distanceDepths.length - 1);
            emitSymbol([cast(ushort)hdist, 5]);
        }

        ushort[2][19] symbolsForDepths;

        {
            ushort[1] tempZero = [0];
            HuffManTree!19 tree;

            auto depthsOfAnySymbol = tree.buildFromData(symbolDepths[], distanceDepths.length > 0 ? distanceDepths : tempZero[]);

            // The huffman tree won't be setup in the right order for DEFLATE,
            //  so we need to recreate it but with our guarantees.
            tree.clear;
            ErrorInfo error = getDeflateHuffmanBits(depthsOfAnySymbol, &tree.addLeafMSB);
            assert(!error.isSet);
            symbolsForDepths = tree.pathForValues();

            //HCLEN - 4 as 4 bits
            hclen = 19 - 4; // stuff it, we are not compressing this
            emitSymbol([hclen, 4]);

            foreach (alphabet; codeLengthAlphabet) {
                emitSymbol([depthsOfAnySymbol[alphabet], 3]);
            }
        }

        {
            // symbol + distance
            foreach (depth; symbolDepths[0 .. hlit + 257]) {
                emitSymbolMSB(symbolsForDepths[depth]);
            }

            if (distanceDepths.length == 0) {
                // emit as length 1, for value 0
                emitSymbolMSB(symbolsForDepths[0]);
            } else {
                foreach (depth; distanceDepths) {
                    emitSymbolMSB(symbolsForDepths[depth]);
                }
            }
        }
    }

    void emitFixedSymbol(ushort value) @trusted {
        emitSymbolMSB(fixedLiteralSymbolValuePaths[value]);
    }

    void hashChainImplementation(bool isFirst, size_t offsetOfBlock, scope const(ubyte)[] toCompress,
            bool useDynamicHuffMan, int lookForBetter, size_t maxLayers, size_t maxInLayer) @trusted {
        import std.math : sqrt;

        if (isFirst) {
            hashChain = HashChain(cast(size_t)sqrt(cast(float)toCompress.length), maxLayers, 3, maxInLayer, 258, allocator);
        }

        {
            hashChain.addLayer;
            dynamicHuffManSymbols = Appender!ushort(allocator);
            dynamicHuffManDistances = Appender!ushort(allocator);
            onlyDynamicHuffManDistances = Appender!ushort(allocator);
            symbolExtras = Appender!(ushort[2])(allocator);
            distanceExtras = Appender!(ushort[2])(allocator);
        }

        size_t offset = offsetOfBlock;

        ushort[2][3] calculateDistanceSymbol(size_t matchOffset, size_t matchLength) {
            ushort[2][3] ret;

            {
                size_t offsetForLength;
                while (lengthBase[offsetForLength++] < matchLength) {
                    assert(offsetForLength <= lengthBase.length);
                }
                offsetForLength--;
                const lengthExtra = cast(ushort)(matchLength - lengthBase[offsetForLength]);

                assert(lengthExtra < 1 << lengthExtraBits[offsetForLength]);
                const symbol = cast(ushort)(257 + offsetForLength);

                ret[0][0] = symbol;
                ret[1] = [lengthExtra, cast(ushort)lengthExtraBits[offsetForLength]];
            }

            {
                size_t offsetForDistance = 0;
                while (distanceBase[offsetForDistance++] < matchOffset) {
                    assert(offsetForDistance <= distanceBase.length);
                }
                offsetForDistance--;
                const distanceExtra = cast(ushort)(matchOffset - distanceBase[offsetForDistance]);
                assert(distanceExtra <= (1 << distanceExtraBits[offsetForDistance]) - 1);
                const distance = cast(ushort)offsetForDistance;

                ret[0][1] = distance;
                ret[2] = [distanceExtra, cast(ushort)distanceExtraBits[offsetForDistance]];
            }

            return ret;
        }

        void emitDynamicDistance(size_t offset, size_t matchLength) {
            auto got = calculateDistanceSymbol(offset, matchLength);

            dynamicHuffManSymbols ~= got[0][0];
            symbolExtras ~= got[1];

            dynamicHuffManDistances ~= got[0][1];
            distanceExtras ~= got[2];

            onlyDynamicHuffManDistances ~= got[0][1];
        }

        void emitFixedDistance(size_t offset, size_t matchLength) {
            auto got = calculateDistanceSymbol(offset, matchLength);

            emitFixedSymbol(got[0][0]);
            emitSymbol(got[1]);

            emitSymbolMSB(fixedLiteralDistanceValuePaths[got[0][1]]);
            emitSymbol(got[2]);
        }

        void emitDynamicSymbol(ushort value) {
            dynamicHuffManSymbols ~= value;
            dynamicHuffManDistances ~= cast(ushort)0;
            symbolExtras ~= [cast(ushort)0, cast(ushort)0];
            distanceExtras ~= [cast(ushort)0, cast(ushort)0];
        }

        while (toCompress.length > 0) {
            size_t initialMatchOffset, initialMatchLength;

            if (!hashChain.findLongestMatch(toCompress, initialMatchOffset, initialMatchLength)) {
                // if we didn't find a match, we need to emit first byte, add to chain and continue

                if (useDynamicHuffMan) {
                    emitDynamicSymbol(toCompress[0]);
                } else {
                    emitFixedSymbol(toCompress[0]);
                }

                hashChain.addMatch(offset, toCompress);
                toCompress = toCompress[1 .. $];
                offset++;
            } else if (useDynamicHuffMan) {
                // needs to be stored in an Appender prior to creating the huffman tree

                if (lookForBetter != 0) {
                    const howFarToLookForward = cast(size_t)(sqrt(sqrt(cast(float)toCompress.length)) * lookForBetter);
                    // look for a second match, if found redo first but slice shrink toCompress that was passed in

                    size_t proposedMatchOffset, proposedMatchLength;

                    foreach (i; 1 .. howFarToLookForward + 1) {
                        const toCompress2 = toCompress[i .. $];
                        size_t tempMatchOffset, tempMatchLength;

                        if (hashChain.findLongestMatch(toCompress2, tempMatchOffset, tempMatchLength) &&
                                proposedMatchLength < tempMatchLength) {
                            proposedMatchOffset = tempMatchOffset;
                            proposedMatchLength = tempMatchLength;
                        }
                    }

                    if (proposedMatchLength > initialMatchLength) {
                        while (offset < proposedMatchOffset) {
                            scope const(ubyte)[] matchable = toCompress[0 .. proposedMatchOffset - offset];
                            size_t tempMatchOffset, tempMatchLength;

                            if (hashChain.findLongestMatch(matchable, tempMatchOffset, tempMatchLength)) {
                                emitDynamicDistance(tempMatchOffset, tempMatchLength);
                                hashChain.addMatch(offset, toCompress);

                                toCompress = toCompress[tempMatchLength .. $];
                                offset += tempMatchLength;
                            } else {
                                emitDynamicSymbol(toCompress[0]);
                                hashChain.addMatch(offset, toCompress);

                                toCompress = toCompress[1 .. $];
                                offset++;
                            }
                        }

                        emitDynamicDistance(proposedMatchOffset, proposedMatchLength);
                        hashChain.addMatch(offset, toCompress);

                        toCompress = toCompress[proposedMatchLength .. $];
                        offset += proposedMatchLength;
                    } else {
                        emitDynamicDistance(initialMatchOffset, initialMatchLength);
                        hashChain.addMatch(offset, toCompress);

                        toCompress = toCompress[initialMatchLength .. $];
                        offset += initialMatchLength;
                    }
                } else {
                    emitDynamicDistance(initialMatchOffset, initialMatchLength);
                    hashChain.addMatch(offset, toCompress);

                    toCompress = toCompress[initialMatchLength .. $];
                    offset += initialMatchLength;
                }
            } else {
                emitFixedDistance(initialMatchOffset, initialMatchLength);
                hashChain.addMatch(offset, toCompress);

                toCompress = toCompress[initialMatchLength .. $];
                offset += initialMatchLength;
            }
        }

        if (useDynamicHuffMan) {
            HuffManTree!288 symbolTree;
            HuffManTree!30 distanceTree;
            ushort[2][288] symbolValuePaths = void;
            ushort[2][30] distanceValuePaths = void;

            {
                auto data = dynamicHuffManSymbols.asReadOnly(allocator);
                auto symbolDepths = symbolTree.buildFromData(data.unsafeGetLiteral(), 256);
                data = onlyDynamicHuffManDistances.asReadOnly(allocator);
                auto distanceDepths = distanceTree.buildFromData(data.unsafeGetLiteral());

                // The huffman tree won't be setup in the right order for DEFLATE,
                //  so we need to recreate it but with our guarantees.
                symbolTree.clear;
                distanceTree.clear;
                ErrorInfo error = getDeflateHuffmanBits(symbolDepths, &symbolTree.addLeafMSB);
                assert(!error.isSet);
                error = getDeflateHuffmanBits(distanceDepths, &distanceTree.addLeafMSB);
                assert(!error.isSet);

                emitHuffManTree(symbolDepths, distanceDepths);
                symbolValuePaths = symbolTree.pathForValues();
                distanceValuePaths = distanceTree.pathForValues();
            }

            foreach (i; 0 .. dynamicHuffManSymbols.length) {
                ushort symbol = dynamicHuffManSymbols[i].assumeOkay;

                emitSymbolMSB(symbolValuePaths[symbol]);
                if (symbolExtras[i].assumeOkay[1] > 0)
                    emitSymbol(symbolExtras[i].assumeOkay);

                if (symbol > 256) {
                    ushort distance = dynamicHuffManDistances[i].assumeOkay;

                    emitSymbolMSB(distanceValuePaths[distance]);
                    if (distanceExtras[i].assumeOkay[1] > 0)
                        emitSymbol(distanceExtras[i].assumeOkay);
                }
            }

            // EMIT 256 aka end
            emitSymbolMSB(symbolValuePaths[256]);
        } else {
            // EMIT 256 aka end
            emitFixedSymbol(256);
        }
    }
}

@trusted unittest {
    import sidero.base.compression.deflate.decompression;

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
    assert(test(BigText, DeflateCompressionRate.DynamicHuffManTree));
    assert(test(BigText, DeflateCompressionRate.HashWithFixedHuffManTree));
    assert(test(BigText, DeflateCompressionRate.HashWithDynamicHuffManTree));
    assert(test(BigText, DeflateCompressionRate.DeepHashWithDynamicHuffManTree));
}
