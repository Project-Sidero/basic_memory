module generators.unicode.genfor.hangul_syllable_type;
import generators.unicode.data.HangulSyllableType;
import generators.unicode.defs;
import utilities.intervallist;
import std.format : formattedWrite;

void genForHangulSyllableType() {
    implOutput ~= q{module sidero.base.internal.unicode.hangulsyllabletype;
// Generated do not modify

enum HangulSyllableType {
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

};

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Is character a hangul syllable?\n";
        generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isHangulSyllable", HangulSyllableType.all, false);
        apiOutput ~= "\n";
    }

    genForHangulType;
}

private:

void genForHangulType() {
    static string[] NameOfValue = ["LeadingConsonant", "Vowel", "TrailingConsonant", "LV_Syllable", "LVT_Syllable"];

    apiOutput ~= "/// Gets the ranges of values in a given Hangul syllable type.\n";
    apiOutput ~= "deprecated export immutable(ValueRange[]) sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc pure {\n";
    apiOutput ~= "    return cast(immutable(ValueRange[]))sidero_utf_lut_hangulSyllables2(type);\n";
    apiOutput ~= "}\n";
    apiOutput ~= "private extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure;\n";

    implOutput ~= "export extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure {\n";
    implOutput ~= "    final switch(type) {\n";

    static foreach(i; 0 .. 5) {
        {
            implOutput ~= "        case HangulSyllableType." ~ NameOfValue[i] ~ ":\n";
            implOutput ~= "            static immutable Array = [";

            foreach(entry; HangulSyllableType.tupleof[i]) {
                if(entry.isSingle)
                    implOutput.formattedWrite!"ValueRange(0x%X), "(entry.start);
                else
                    implOutput.formattedWrite!"ValueRange(0x%X, 0x%X), "(entry.start, entry.end);
            }

            implOutput ~= "];\n";
            implOutput ~= "            return Array;\n";
        }
    }

    implOutput ~= "    }\n";
    implOutput ~= "}\n";
}
