module generators.unicode.proplist;
import generators.constants;

void propList() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText("unicode-14/PropList.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.proplist;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    foreach (i, property; __traits(allMembers, Property)) {
        {
            SequentialRanges!(bool, SequentialRangeSplitGroup, 2) sr;

            foreach (entry; state.single[__traits(getMember, Property, property)]) {
                foreach(dchar c; entry.start .. entry.end + 1)
                    sr.add(c, true);
            }
            foreach (entry; state.range[__traits(getMember, Property, property)]) {
                foreach(dchar c; entry.start .. entry.end + 1)
                    sr.add(c, true);
            }

            sr.splitForSame;
            sr.calculateTrueSpread;
            sr.joinWithDiff(null, 256);
            sr.calculateTrueSpread;
            sr.layerByRangeMax(0, ushort.max / 4);
            sr.layerByRangeMax(1, ushort.max / 2);

            LookupTableGenerator!(bool, SequentialRangeSplitGroup, 2) lut;
            lut.sr = sr;
            lut.lutType = "bool";
            lut.name = "sidero_utf_lut_isMemberOf" ~ property;

            auto gotDcode = lut.build();

            api ~= "\n";
            api ~= "/// Is character member of property.\n";
            api ~= gotDcode[0];

            internal ~= gotDcode[1];
        }
    }

    api ~= q{
/// Is character whitespace?
alias isUnicodeWhiteSpace = sidero_utf_lut_isMemberOfWhite_Space;
};

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "proplist.d", internal.data);
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
        case "White_Space":
            property = Property.White_Space;
            break;
        case "Bidi_Control":
            property = Property.Bidi_Control;
            break;
        case "Join_Control":
            property = Property.Join_Control;
            break;
        case "Dash":
            property = Property.Dash;
            break;
        case "Hyphen":
            property = Property.Hyphen;
            break;
        case "Quotation_Mark":
            property = Property.Quotation_Mark;
            break;
        case "Terminal_Punctuation":
            property = Property.Terminal_Punctuation;
            break;
        case "Other_Math":
            property = Property.Other_Math;
            break;
        case "Hex_Digit":
            property = Property.Hex_Digit;
            break;
        case "ASCII_Hex_Digit":
            property = Property.ASCII_Hex_Digit;
            break;
        case "Other_Alphabetic":
            property = Property.Other_Alphabetic;
            break;
        case "Ideographic":
            property = Property.Ideographic;
            break;
        case "Diacritic":
            property = Property.Diacritic;
            break;
        case "Extender":
            property = Property.Extender;
            break;
        case "Other_Lowercase":
            property = Property.Other_Lowercase;
            break;
        case "Other_Uppercase":
            property = Property.Other_Uppercase;
            break;
        case "Noncharacter_Code_Point":
            property = Property.Noncharacter_Code_Point;
            break;
        case "Other_Grapheme_Extend":
            property = Property.Other_Grapheme_Extend;
            break;
        case "IDS_Binary_Operator":
            property = Property.IDS_Binary_Operator;
            break;
        case "IDS_Trinary_Operator":
            property = Property.IDS_Trinary_Operator;
            break;
        case "Radical":
            property = Property.Radical;
            break;
        case "Unified_Ideograph":
            property = Property.Unified_Ideograph;
            break;
        case "Other_Default_Ignorable_Code_Point":
            property = Property.Other_Default_Ignorable_Code_Point;
            break;
        case "Deprecated":
            property = Property.Deprecated;
            break;
        case "Soft_Dotted":
            property = Property.Soft_Dotted;
            break;
        case "Logical_Order_Exception":
            property = Property.Logical_Order_Exception;
            break;
        case "Other_ID_Start":
            property = Property.Other_ID_Start;
            break;
        case "Other_ID_Continue":
            property = Property.Other_ID_Continue;
            break;
        case "Sentence_Terminal":
            property = Property.Sentence_Terminal;
            break;
        case "Variation_Selector":
            property = Property.Variation_Selector;
            break;
        case "Pattern_White_Space":
            property = Property.Pattern_White_Space;
            break;
        case "Pattern_Syntax":
            property = Property.Pattern_Syntax;
            break;
        case "Prepended_Concatenation_Mark":
            property = Property.Prepended_Concatenation_Mark;
            break;
        case "Regional_Indicator":
            property = Property.Regional_Indicator;
            break;
        default:
            assert(0, propertyStr);
        }

        if (valueRange.isSingle)
            state.single[property] ~= valueRange;
        else
            state.range[property] ~= valueRange;
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
    ValueRange!dchar[][Property.max + 1] single;
    ValueRange!dchar[][Property.max + 1] range;
}

enum Property {
    White_Space,
    Bidi_Control,
    Join_Control,
    Dash,
    Hyphen,
    Quotation_Mark,
    Terminal_Punctuation,
    Other_Math,
    Hex_Digit,
    ASCII_Hex_Digit,
    Other_Alphabetic,
    Ideographic,
    Diacritic,
    Extender,
    Other_Lowercase,
    Other_Uppercase,
    Noncharacter_Code_Point,
    Other_Grapheme_Extend,
    IDS_Binary_Operator,
    IDS_Trinary_Operator,
    Radical,
    Unified_Ideograph,
    Other_Default_Ignorable_Code_Point,
    Deprecated,
    Soft_Dotted,
    Logical_Order_Exception,
    Other_ID_Start,
    Other_ID_Continue,
    Sentence_Terminal,
    Variation_Selector,
    Pattern_White_Space,
    Pattern_Syntax,
    Prepended_Concatenation_Mark,
    Regional_Indicator
}
