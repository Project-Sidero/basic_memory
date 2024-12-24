module generators.unicode.data.GraphemeBreakProperty;
import utilities.setops;

__gshared GraphemeBreakProperty_State GraphemeBreakProperty;

struct GraphemeBreakProperty_State {
    ValueRange[][Property.max + 1] ranges;
}

enum Property {
    Prepend,
    CR,
    LF,
    Control,
    Extend,
    Regional_Indicator,
    SpacingMark,
    L,
    V,
    T,
    LV,
    LVT,
    ZWJ,
}

void processGraphemeBreakProperty(string inputText) {
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

    void handleLine(ValueRange valueRange, string propertyStr) {
        Property property;

    Switch:
        switch(propertyStr) {
            static foreach(P; __traits(allMembers, Property)) {
        case P:
                property = __traits(getMember, Property, P);
                break Switch;
            }
        default:
            assert(0, propertyStr);
        }

        if(GraphemeBreakProperty.ranges[property].length == 0)
            GraphemeBreakProperty.ranges[property] ~= valueRange;
        else {
            if(valueRange.start == GraphemeBreakProperty.ranges[property][$ - 1].end + 1)
                GraphemeBreakProperty.ranges[property][$ - 1].end = valueRange.end;
            else
                GraphemeBreakProperty.ranges[property] ~= valueRange;
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

        ValueRange valueRange = valueRangeFromString(charRangeStr);

        handleLine(valueRange, line);
    }
}
