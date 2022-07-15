module generators.unicode.wordbreakproperty;

void wordBreakProperty() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText("unicode-14/auxiliary/WordBreakProperty.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.wordbreakproperty;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.range)
            foreach (c; entry.range.start .. entry.range.end + 1)
                sr.add(c, cast(ubyte)entry.property);

        foreach (entry; state.single) {
            foreach (c; entry.range.start .. entry.range.end + 1)
                sr.add(c, cast(ubyte)entry.property);
        }

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.externType = "WordBreakProperty";
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_getWordBreakProperty";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup word break property for character.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    append("generated/sidero/base/text/unicode/database.d", api.data);
    write("generated/sidero/base/internal/unicode/wordbreakproperty.d", internal.data);
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

    void handleLine(ValueRange!dchar valueRange, string propertyStr) {
        Property property;

        switch (propertyStr) {
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

        foreach (index; valueRange.start .. valueRange.end + 1) {
            foreach (value; state.single) {
                if (index == value.range.start)
                    assert(0, propertyStr);
            }

            foreach (value; state.single) {
                if (index >= value.range.start && index <= value.range.end)
                    assert(0, propertyStr);
            }
        }

        if (valueRange.isSingle)
            state.single ~= Entry(valueRange, property);
        else
            state.range ~= Entry(valueRange, property);
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

        ValueRange!dchar valueRange = valueRangeFromString(charRangeStr);

        handleLine(valueRange, line);
    }
}

struct TotalState {
    Entry[] single;
    Entry[] range;
}

struct Entry {
    ValueRange!dchar range;
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
