module generators.unicode.hangulsyllabletype;

void hangulSyllableType() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText("unicode-14/HangulSyllableType.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.hangulsyllabletype;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    {
        SequentialRanges!(bool, SequentialRangeSplitGroup, 0) sr;

        foreach (entry; state.L) {
            foreach (codepoint; entry.start .. entry.end + 1)
                sr.add(codepoint, true);
        }
        foreach (entry; state.V) {
            foreach (codepoint; entry.start .. entry.end + 1)
                sr.add(codepoint, true);
        }
        foreach (entry; state.T) {
            foreach (codepoint; entry.start .. entry.end + 1)
                sr.add(codepoint, true);
        }
        foreach (entry; state.LV) {
            foreach (codepoint; entry.start .. entry.end + 1)
                sr.add(codepoint, true);
        }
        foreach (entry; state.LVT) {
            foreach (codepoint; entry.start .. entry.end + 1)
                sr.add(codepoint, true);
        }

        sr.calculateTrueSpread;
        sr.joinWhenClose(null, 5, 1);
        sr.calculateTrueSpread;

        LookupTableGenerator!(bool, SequentialRangeSplitGroup, 0) lut;
        lut.sr = sr;
        lut.lutType = "bool";
        lut.name = "sidero_utf_lut_isHangulSyllable";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Is character a hangul syllable?\n";
        api ~= gotDcode[0];
        api ~= "\n";

        internal ~= gotDcode[1];
    }

    {
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

        static string[] NameOfValue = ["LeadingConsonant", "Vowel", "TrailingConsonant", "LV_Syllable", "LVT_Syllable"];

        api ~= "/// Gets the ranges of values in a given Hangul syllable type.\n";
        api ~= "export immutable(ValueRange[]) sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc pure {\n";
        api ~= "    return cast(immutable(ValueRange[]))sidero_utf_lut_hangulSyllables2(type);\n";
        api ~= "}\n";
        api ~= "private extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure;\n";

        internal ~= "export extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure {\n";
        internal ~= "    final switch(type) {\n";

        static foreach (i; 0 .. state.tupleof.length) {
            {
                SequentialRanges!(bool, SequentialRangeSplitGroup, 0) sr;

                foreach (entry; state.tupleof[i]) {
                    foreach (codepoint; entry.start .. entry.end + 1)
                        sr.add(codepoint, true);
                }

                sr.calculateTrueSpread;
                sr.joinWhenClose(null, 5, 1);

                internal ~= "        case HangulSyllableType." ~ NameOfValue[i] ~ ":\n";
                internal ~= "            static immutable Array = [";

                foreach (entry, layerIndexes; sr) {
                    if (entry.range.isSingle)
                        internal.formattedWrite!"ValueRange(0x%X), "(entry.range.start);
                    else
                        internal.formattedWrite!"ValueRange(0x%X, 0x%X), "(entry.range.start, entry.range.end);
                }

                internal ~= "];\n";
                internal ~= "            return Array;\n";
            }
        }

        internal ~= "    }\n";
        internal ~= "}\n";
    }

    append("generated/sidero/base/text/unicode/database.d", api.data);
    write("generated/sidero/base/internal/unicode/hangulsyllabletype.d", internal.data);
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

    void handleLine(ValueRange!dchar range, string line) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        switch (line) {
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

        ValueRange!dchar range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}

struct TotalState {
    ValueRange!dchar[] L, V, T, LV, LVT;
}
