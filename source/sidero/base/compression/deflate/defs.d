module sidero.base.compression.deflate.defs;
export @safe nothrow @nogc:

///
enum DeflateCompressionRate {
    ///
    None,
    ///
    FixedHuffManTree,
    ///
    DynamicHuffManTree,
    ///
    HashWithFixedHuffManTree,
    ///
    HashWithDynamicHuffManTree,
    ///
    DeepHashWithDynamicHuffManTree,

    ///
    Fastest = None,
    ///
    Fast = DynamicHuffManTree,
    ///
    Slow = HashWithDynamicHuffManTree,
    ///
    Slowest = DeepHashWithDynamicHuffManTree,

    ///
    Default = HashWithFixedHuffManTree
}

package(sidero.base.compression):
import sidero.base.compression.huffman;
import sidero.base.synchronization.mutualexclusion;
import sidero.base.errors;

struct TreeState {
    HuffManTree!288* symbolTree;
    HuffManTree!30* distanceTree;

    HuffManTree!288 dynamicSymbolTree;
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

static immutable codeLengthAlphabet = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];

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
    ushort[2][30] fixedLiteralDistanceValuePaths;
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
        fixedLiteralDistanceValuePaths = fixedDistanceTree.pathForValues();
    }

    isGlobalTreesSetup = true;
    initTreeLock.unlock;
}

ErrorInfo getDeflateHuffmanBits(DepthType)(scope const(DepthType)[] lengths, scope void delegate(ushort, size_t,
    size_t) @safe nothrow @nogc gotValue) {
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

unittest {
    int counter;

    ushort[8] expectedCodes = [2, 3, 4, 5, 6, 0, 14, 15];

    void handle(ushort code, size_t length, size_t offset) {
        assert(expectedCodes[offset] == code);
    }

    auto error = getDeflateHuffmanBits([3, 3, 3, 3, 3, 2, 4, 4], &handle);
}
