module generators.unicode.data.CompositionExclusions;
import utilities.setops;

__gshared ValueRange[] CompositionExclusions;

void processCompositionExclusions(string inputText) {
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
        CompositionExclusions ~= valueRange;
    }

    {
        sort!("a.start < b.start")(CompositionExclusions);
        ValueRange[] temp;

        foreach(valueRange; CompositionExclusions) {
            if(temp.length == 0)
                temp ~= valueRange;
            else {
                if(valueRange.start == temp[$ - 1].end + 1)
                    temp[$ - 1].end = valueRange.end;
                else
                    temp ~= valueRange;
            }
        }

        CompositionExclusions = temp;
    }
}
