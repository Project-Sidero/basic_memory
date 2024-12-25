module generators.unicode.genfor.hangul_syllable_type;
import generators.unicode.data.HangulSyllableType;
import generators.unicode.defs;
import utilities.intervallist;
import std.format : formattedWrite;

void genForHangulSyllableType() {
    implOutput ~= q{module sidero.base.internal.unicode.hangulsyllabletype;
import sidero.base.containers.set.interval;
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
        generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isHangulSyllable", HangulSyllableType.all, false, false);
        apiOutput ~= "\n";
    }

    genForHangulType2;
}

private:

void genForHangulType2() {
    static string[] NameOfValue = ["LeadingConsonant", "Vowel", "TrailingConsonant", "LV_Syllable", "LVT_Syllable"];

    {
        apiOutput ~= "/// Gets the ranges of values in a given Hangul syllable type.\n";
        apiOutput ~= "export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc {\n";

        apiOutput ~= "    final switch(type) {\n";
        foreach(nov; NameOfValue) {
            apiOutput ~= "        case HangulSyllableType." ~ nov ~ ":\n";
            apiOutput ~= "            return sidero_utf_lut_hangulSyllables_" ~ nov ~ "_Set();\n";
        }

        apiOutput ~= "    }\n";
        apiOutput ~= "}\n";
    }

    static foreach(i; 0 .. 5) {
        apiOutput ~= "/// Gets the ranges of values in a Hangul syllable " ~ NameOfValue[i] ~ ".\n";
        generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_hangulSyllables_" ~ NameOfValue[i],
                HangulSyllableType.tupleof[i], true, false);
    }
}
