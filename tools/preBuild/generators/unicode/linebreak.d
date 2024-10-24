module generators.unicode.linebreak;
import constants;

void lineBreak() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "LineBreak.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.linebreak;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    {
        api ~= "\n";
        api ~= "/// Get the Line break class\n";

        ValueRange[] ranges;
        ubyte[] values;
        seqEntries(ranges, values, state.pairs);

        generateReturn(api, internal, "sidero_utf_lut_getLineBreakClass", ranges, values, "LineBreakClass");
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "linebreak.d", internal.data);
}

private:
import std.array : appender;
import utilities.setops;
import utilities.inverselist;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange valueRangeFromString(string charRangeStr) {
        ValueRange ret;

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

    void handleLine(ValueRange range, string line) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

    SLB:
        switch (line) {
            static foreach (m; __traits(allMembers, LineBreak)) {
        case m:
                state.pairs ~= Pair(range, __traits(getMember, LineBreak, m));
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

        ValueRange range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}

struct TotalState {
    Pair[] pairs;
}

struct Pair {
    ValueRange range;
    LineBreak lineBreak;
}

enum LineBreak : ubyte {
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
    AK, ///
    VI, ///
    AS, ///
    VF, ///
    AP, ///
}

void seqEntries(out ValueRange[] ranges, out ubyte[] lineBreaks, Pair[] entries) {
    import std.algorithm : sort;

    sort!"a.range.start < b.range.start"(entries);

    ranges.reserve(entries.length);
    lineBreaks.reserve(entries.length);

    foreach(v; entries) {
        assert(v.range.start <= v.range.end);
        ranges ~= v.range;
        lineBreaks ~= v.lineBreak;
    }
}
