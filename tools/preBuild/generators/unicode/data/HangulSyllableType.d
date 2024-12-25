module generators.unicode.data.HangulSyllableType;
import utilities.setops;

__gshared HangulSyllableType_State HangulSyllableType;

struct HangulSyllableType_State {
    ValueRange[] L, V, T, LV, LVT, all;
}

void processHangulSyllableType(string inputText) {
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

    void handleLine(ValueRange range, string line) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        switch(line) {
        case "L":
            HangulSyllableType.L ~= range;
            break;
        case "V":
            HangulSyllableType.V ~= range;
            break;
        case "T":
            HangulSyllableType.T ~= range;
            break;
        case "LV":
            HangulSyllableType.LV ~= range;
            break;
        case "LVT":
            HangulSyllableType.LVT ~= range;
            break;

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

    {
        HangulSyllableType.all = HangulSyllableType.L;
        HangulSyllableType.all ~= HangulSyllableType.V;
        HangulSyllableType.all ~= HangulSyllableType.T;
        HangulSyllableType.all ~= HangulSyllableType.LV;
        HangulSyllableType.all ~= HangulSyllableType.LVT;

        sort!("a.start < b.start")(HangulSyllableType.all);
        ValueRange[] temp;

        foreach(valueRange; HangulSyllableType.all) {
            if(temp.length == 0)
                temp ~= valueRange;
            else {
                if(valueRange.start == temp[$ - 1].end + 1)
                    temp[$ - 1].end = valueRange.end;
                else
                    temp ~= valueRange;
            }
        }

        HangulSyllableType.all = temp;
    }
}
