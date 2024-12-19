module generators.unicode.compositionexclusions;
import constants;

__gshared ValueRange[] compositionExclusionRanges;

void compositionExclusions() {
    import std.file : readText, write, append;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "CompositionExclusions.txt"));

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.compositionexclusions;\n";
    internal ~= "// Generated do not modify\n\n";

    auto api = appender!string();

    {
        api ~= "\n";
        api ~= "/// Is excluded from composition.\n";
        api ~= "/// Returns: false if not set.\n";

        generateIsCheck(api, internal, "sidero_utf_lut_isCompositionExcluded", compositionExclusionRanges, false);
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "compositionexclusions.d", internal.data);
}

private:
import std.array : appender;
import utilities.setops;
import utilities.inverselist;
import utilities.intervallist;

void processEachLine(string inputText) {
    import std.algorithm : countUntil, splitter, sort;
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

    foreach(line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if(line.length < 4 || line.countUntil(".") >= 0) // anything that low can't represent a functional line
            continue;

        ValueRange valueRange = valueRangeFromString(line);
        compositionExclusionRanges ~= valueRange;
    }

    {
        sort!("a.start < b.start")(compositionExclusionRanges);
        ValueRange[] temp;

        foreach(valueRange; compositionExclusionRanges) {
            if(temp.length == 0)
                temp ~= valueRange;
            else {
                if(valueRange.start == temp[$ - 1].end + 1)
                    temp[$ - 1].end = valueRange.end;
                else
                    temp ~= valueRange;
            }
        }

        compositionExclusionRanges = temp;
    }
}
