module generators.unicode.data.LineBreak;
import utilities.setops;

__gshared LineBreak_State LineBreak;

struct LineBreak_State {
    Pair[] pairs;
}

struct Pair {
    ValueRange range;
    LineBreakKind lineBreak;
}

enum LineBreakKind : ubyte {
    XX,
    BK,
    CR,
    LF,
    CM,
    NL,
    SG,
    WJ,
    ZW,
    GL,
    SP,
    ZWJ,
    B2,
    BA,
    BB,
    HY,
    CB,
    CL,
    CP,
    EX,
    IN,
    NS,
    OP,
    QU,
    IS,
    NU,
    PO,
    PR,
    SY,
    AI,
    AL,
    CJ,
    EB,
    EM,
    H2,
    H3,
    HL,
    ID,
    JL,
    JV,
    JT,
    RI,
    SA,
    AK,
    VI,
    AS,
    VF,
    AP,
}

void processLineBreak(string inputText) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange valueRangeFromString(string charRangeStr) {
        ValueRange ret;

        ptrdiff_t offsetOfSeperator = charRangeStr.countUntil("..");
        if(offsetOfSeperator < 0) {
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
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

    SLB:
        switch(line) {
            static foreach(m; __traits(allMembers, LineBreakKind)) {
        case m:
                LineBreak.pairs ~= Pair(range, __traits(getMember, LineBreakKind, m));
                break SLB;
            }

        default:
            assert(0, line);
        }
    }

    foreach(line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if(line.length < 5) // anything that low can't represent a functional line
            continue;

        offset = line.countUntil(';');
        if(offset < 0) // no char range
            continue;
        string charRangeStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        ValueRange range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}
