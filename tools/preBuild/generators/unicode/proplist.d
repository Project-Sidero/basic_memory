module generators.unicode.proplist;
import constants;

void propList() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "PropList.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.proplist;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    foreach(i, property; __traits(allMembers, Property)) {
        {
            internal ~= "\n";

            api ~= "\n";
            api ~= "/// Is character member of property.\n";

            generateIsCheck(api, internal, "sidero_utf_lut_isMemberOf" ~ property, state.ranges[i]);
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
import utilities.setops;
import utilities.inverselist;

void processEachLine(string inputText, ref TotalState state) {
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

        if(state.ranges[property].length == 0)
            state.ranges[property] ~= valueRange;
        else {
            if(valueRange.start == state.ranges[property][$ - 1].end + 1)
                state.ranges[property][$ - 1].end = valueRange.end;
            else
                state.ranges[property] ~= valueRange;
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

struct TotalState {
    ValueRange[][Property.max + 1] ranges;
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
    IDS_Unary_Operator,
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
    Regional_Indicator,
    ID_Compat_Math_Start,
    ID_Compat_Math_Continue,
    Modifier_Combining_Mark
}
