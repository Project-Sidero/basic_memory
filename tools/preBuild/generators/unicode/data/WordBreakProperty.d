module generators.unicode.data.WordBreakProperty;
import utilities.setops;

__gshared WordBreakProperty_State WordBreakProperty;

struct WordBreakProperty_State {
    WordBreakProperty_Entry[] ranges;
}

struct WordBreakProperty_Entry {
    ValueRange range;
    Property property;
}

enum Property : ubyte {
    None, ///
    Double_Quote, ///
    Single_Quote, ///
    Hebrew_Letter, ///
    CR, ///
    LF, ///
    Newline, ///
    Extend, ///
    Regional_Indicator, ///
    Format, ///
    Katakana, ///
    ALetter, ///
    MidLetter, ///
    MidNum, ///
    MidNumLet, ///
    Numeric, ///
    ExtendNumLet, ///
    ZWJ, ///
    WSegSpace, ///
}

void processWordBreakProperty(string inputText) {
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

        switch(propertyStr) {
            case "Double_Quote":
                property = Property.Double_Quote;
                break;
            case "Single_Quote":
                property = Property.Single_Quote;
                break;
            case "Hebrew_Letter":
                property = Property.Hebrew_Letter;
                break;
            case "CR":
                property = Property.CR;
                break;
            case "LF":
                property = Property.LF;
                break;
            case "Newline":
                property = Property.Newline;
                break;
            case "Extend":
                property = Property.Extend;
                break;
            case "Regional_Indicator":
                property = Property.Regional_Indicator;
                break;
            case "Format":
                property = Property.Format;
                break;
            case "Katakana":
                property = Property.Katakana;
                break;
            case "ALetter":
                property = Property.ALetter;
                break;
            case "MidLetter":
                property = Property.MidLetter;
                break;
            case "MidNum":
                property = Property.MidNum;
                break;
            case "MidNumLet":
                property = Property.MidNumLet;
                break;
            case "Numeric":
                property = Property.Numeric;
                break;
            case "ExtendNumLet":
                property = Property.ExtendNumLet;
                break;
            case "ZWJ":
                property = Property.ZWJ;
                break;
            case "WSegSpace":
                property = Property.WSegSpace;
                break;

                default:
                assert(0, propertyStr);
        }

        WordBreakProperty.ranges ~= WordBreakProperty_Entry(valueRange, property);
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
