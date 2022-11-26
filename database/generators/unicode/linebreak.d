module generators.unicode.linebreak;
import generators.constants;

void lineBreak() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText("unicode-14/LineBreak.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.linebreak;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach (range, value; state.values) {
            foreach (c; range.start .. range.end + 1)
                sr.add(c, cast(ubyte)value);
        }

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "ubyte";
        lut.externType = "LineBreakClass";
        lut.name = "sidero_utf_lut_getLineBreakClass";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Get the Line break class\n";
        api ~= gotDcode[0];
        api ~= "\n";

        internal ~= gotDcode[1];
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "linebreak.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange!dchar valueRangeFromString(string charRangeStr) {
        ValueRange!dchar ret;

        ptrdiff_t offsetOfSeperator = charRangeStr.countUntil("..");
        if (offsetOfSeperator < 0) {
            ret.start = parse!uint(charRangeStr, 16);
            ret.end = ret.start;
        } else {
            string startStr = charRangeStr[0 .. offsetOfSeperator], endStr = charRangeStr[offsetOfSeperator + 2 .. $];
            ret.start = parse!uint(startStr, 16);
            ret.end = parse!uint(endStr, 16);
        }

        return ret;
    }

    void handleLine(ValueRange!dchar range, string line) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

    SLB:
        switch (line) {
            static foreach (m; __traits(allMembers, LineBreak)) {
        case m:
                state.values[range] = __traits(getMember, LineBreak, m);
                break SLB;
            }

        default:
            assert(0, line);
        }
    }

    foreach (line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if (line.length < 5) // anything that low can't represent a functional line
            continue;

        offset = line.countUntil(';');
        if (offset < 0) // no char range
            continue;
        string charRangeStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        ValueRange!dchar range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}

struct TotalState {
    LineBreak[ValueRange!dchar] values;
}

enum LineBreak {
    XX, ///
    BK, ///
    CR, ///
    LF, ///
    CM, ///
    NL, ///
    SG, ///
    WJ, ///
    ZW, ///
    GL, ///
    SP, ///
    ZWJ, ///
    B2, ///
    BA, ///
    BB, ///
    HY, ///
    CB, ///
    CL, ///
    CP, ///
    EX, ///
    IN, ///
    NS, ///
    OP, ///
    QU, ///
    IS, ///
    NU, ///
    PO, ///
    PR, ///
    SY, ///
    AI, ///
    AL, ///
    CJ, ///
    EB, ///
    EM, ///
    H2, ///
    H3, ///
    HL, ///
    ID, ///
    JL, ///
    JV, ///
    JT, ///
    RI, ///
    SA, ///
}
