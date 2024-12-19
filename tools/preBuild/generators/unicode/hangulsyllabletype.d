module generators.unicode.hangulsyllabletype;
import constants;

void hangulSyllableType() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "HangulSyllableType.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.hangulsyllabletype;\n";
    internal ~= "// Generated do not modify\n\n";

    internal ~= "enum HangulSyllableType {
    LeadingConsonant, // L
    Vowel, // V
    TrailingConsonant, // T
    LV_Syllable, // LV
    LVT_Syllable // LVT
}

struct ValueRange {
    dchar start, end;
    @safe nothrow @nogc pure const:

    this(dchar index) {
        this.start = index;
        this.end = index;
    }

    this(dchar start, dchar end) {
        assert(end >= start);

        this.start = start;
        this.end = end;
    }
}

";

    auto api = appender!string();

    api ~= "\n";
    api ~= "/// Is character a hangul syllable?\n";
    generateIsCheck(api, internal, "sidero_utf_lut_isHangulSyllable", state.all, false);
    api ~= "\n";

    {
        static string[] NameOfValue = ["LeadingConsonant", "Vowel", "TrailingConsonant", "LV_Syllable", "LVT_Syllable"];

        api ~= "/// Gets the ranges of values in a given Hangul syllable type.\n";
        api ~= "export immutable(ValueRange[]) sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc pure {\n";
        api ~= "    return cast(immutable(ValueRange[]))sidero_utf_lut_hangulSyllables2(type);\n";
        api ~= "}\n";
        api ~= "private extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure;\n";

        internal ~= "export extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure {\n";
        internal ~= "    final switch(type) {\n";

        static foreach(i; 0 .. 5) {
            {
                internal ~= "        case HangulSyllableType." ~ NameOfValue[i] ~ ":\n";
                internal ~= "            static immutable Array = [";

                foreach(entry; state.tupleof[i]) {
                    if(entry.isSingle)
                        internal.formattedWrite!"ValueRange(0x%X), "(entry.start);
                    else
                        internal.formattedWrite!"ValueRange(0x%X, 0x%X), "(entry.start, entry.end);
                }

                internal ~= "];\n";
                internal ~= "            return Array;\n";
            }
        }

        internal ~= "    }\n";
        internal ~= "}\n";
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "hangulsyllabletype.d", internal.data);
}

private:
import std.array : appender;
import utilities.setops;
import utilities.inverselist;
import utilities.intervallist;

void processEachLine(string inputText, ref TotalState state) {
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
            state.L ~= range;
            break;
        case "V":
            state.V ~= range;
            break;
        case "T":
            state.T ~= range;
            break;
        case "LV":
            state.LV ~= range;
            break;
        case "LVT":
            state.LVT ~= range;
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
        state.all = state.L;
        state.all ~= state.V;
        state.all ~= state.T;
        state.all ~= state.LV;
        state.all ~= state.LVT;

        sort!("a.start < b.start")(state.all);
        ValueRange[] temp;

        foreach(valueRange; state.all) {
            if(temp.length == 0)
                temp ~= valueRange;
            else {
                if(valueRange.start == temp[$ - 1].end + 1)
                    temp[$ - 1].end = valueRange.end;
                else
                    temp ~= valueRange;
            }
        }

        state.all = temp;
    }
}

struct TotalState {
    ValueRange[] L, V, T, LV, LVT, all;
}
