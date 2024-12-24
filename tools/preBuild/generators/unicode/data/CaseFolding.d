module generators.unicode.data.CaseFolding;
import utilities.setops;

__gshared CasingFolding_State CaseFolding;

struct CasingFolding_State {
    CaseFolding_Entry[] common, full, simple, turkic;
}

struct CaseFolding_Entry {
    dchar codepoint;
    dstring replacedBy;
}

void processCaseFolding(string inputText) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    void handleLine(dchar codepoint, string line) {
        CaseFolding_Entry entry;
        entry.codepoint = codepoint;

        ptrdiff_t offset;

        offset = line.countUntil(';');
        if (offset < 0) // no status
        return;

        string status = line[0 .. offset].strip;
        line = line[offset + 1 .. $];

        offset = line.countUntil(';');
        if (offset > 0)
        line = line[0 .. offset];
        offset = line.countUntil('#');
        if (offset > 0)
        line = line[0 .. offset];

        line = line.strip;

        while (line.length > 0) {
            entry.replacedBy ~= cast(dchar)parse!uint(line, 16);
            line = line.strip;
        }

        switch (status) {
            case "C":
                CaseFolding.common ~= entry;
                break;
            case "F":
                CaseFolding.full ~= entry;
                break;
            case "S":
                CaseFolding.simple ~= entry;
                break;
            case "T":
                CaseFolding.turkic ~= entry;
                break;
                default:
                assert(0, status);
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

        dchar codepoint = parse!uint(charRangeStr, 16);
        handleLine(codepoint, line);
    }
}

