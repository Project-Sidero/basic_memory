module generators.unicode.compositionexclusions;
import constants;

__gshared ValueRange!dchar[] compositionExclusionRanges;

void compositionExclusions() {
    import std.file : readText, write, append;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "CompositionExclusions.txt"));

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.compositionexclusions;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();
    import std.stdio;

    {
        SequentialRanges!(bool, SequentialRangeSplitGroup, 0) sr;

        foreach (entry; compositionExclusionRanges) {
            foreach (c; entry.start .. entry.end + 1)
                sr.add(cast(dchar)c, true);
        }

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose(null, 5, 32);
        sr.calculateTrueSpread;

        LookupTableGenerator!(bool, SequentialRangeSplitGroup, 0) lut;
        lut.sr = sr;
        lut.lutType = "bool";
        lut.name = "sidero_utf_lut_isCompositionExcluded";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Is excluded from composition.\n";
        api ~= "/// Returns: false if not set.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "compositionexclusions.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;

void processEachLine(string inputText) {
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

    foreach (line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if (line.length < 4 || line.countUntil(".") >= 0) // anything that low can't represent a functional line
            continue;

        ValueRange!dchar valueRange = valueRangeFromString(line);
        compositionExclusionRanges ~= valueRange;
    }
}
