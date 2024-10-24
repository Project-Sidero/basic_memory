module generators.unicode.unicodedata;
import generators.unicode.unicodedata.common;
import constants;
import utilities.setops;
import utilities.inverselist;

void unicodeData() {
    import std.file : readText, write, append;
    import std.array : appender;

    apiOutput = appender!string();

    processEachLine(readText(UnicodeDatabaseDirectory ~ "UnicodeData.txt"));
    fullyDecompose;

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.unicodedata;\n\n";
    internal ~= "// Generated do not modify\n";

    import generators.unicode.unicodedata.compatibilityformatting;

    compatibilityFormatting;

    import generators.unicode.unicodedata.decomposition;

    decompositionMap;

    import generators.unicode.unicodedata.ccc;

    CCC;

    import generators.unicode.unicodedata.composition;

    Composition;

    import generators.unicode.unicodedata.casing;

    Casing;

    {
        dchar[] characters;
        uint[] lengths;

        foreach(character, entry; state.decompositonMappings) {
            characters ~= character;
            lengths ~= cast(uint)entry.fullyDecomposed.length;
        }

        apiOutput ~= "\n";
        apiOutput ~= "/// Get length of fully decomposed for character.\n";
        generateReturn(apiOutput, internal, "sidero_utf_lut_lengthOfFullyDecomposed", characters, lengths);
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup decomposition mapping for character if canonical.\n";
        apiOutput ~= "alias sidero_utf_lut_getDecompositionMappingCanonical = sidero_utf_lut_getDecompositionMappingNone;\n";

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup decomposition mapping length for character if canonical.\n";
        apiOutput ~= "alias sidero_utf_lut_lengthOfDecompositionMappingCanonical = sidero_utf_lut_lengthOfDecompositionMappingNone;\n";
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup decomposition mapping for character given the compatibility formatting tag.\n";
        apiOutput ~= "export dstring sidero_utf_lut_getDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {\n";
        apiOutput ~= "    final switch(tag) {\n";
        foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
            apiOutput ~= "        case CompatibilityFormattingTag." ~ tag ~ ":\n";
            apiOutput ~= "            return sidero_utf_lut_getDecompositionMapping" ~ tag ~ "(input);\n";
        }
        apiOutput ~= "    }\n";
        apiOutput ~= "}\n";
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup length of decomposition mapping for character given the compatibility formatting tag.\n";
        apiOutput ~= "export ubyte sidero_utf_lut_lengthOfDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {\n";
        apiOutput ~= "    final switch(tag) {\n";
        foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
            apiOutput ~= "        case CompatibilityFormattingTag." ~ tag ~ ":\n";
            apiOutput ~= "            return sidero_utf_lut_lengthOfDecompositionMapping" ~ tag ~ "(input);\n";
        }
        apiOutput ~= "    }\n";
        apiOutput ~= "}\n";
    }

    {
        dchar[] ranges;
        long[2][] numdemos;

        foreach(entry; state.entries) {
            foreach(c; entry.range.start .. entry.range.end + 1) {
                if(entry.numericValueNumerator != 0 || entry.numericValueDenominator != 0) {
                    ranges ~= c;
                    numdemos ~= [entry.numericValueNumerator, entry.numericValueDenominator];
                }
            }
        }

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup numeric numerator/denominator for character.\n";
        apiOutput ~= "/// Returns: null if not set.\n";
        generateReturn(apiOutput, internal, "sidero_utf_lut_getNumeric", ranges, numdemos);
    }

    {
        ValueRange[] ranges;
        ubyte[] gcs;

        foreach(entry; state.entries) {
            ranges ~= entry.range;
            gcs ~= cast(ubyte)entry.generalCategory;
        }

        apiOutput ~= q{
/// Is character graphical?
export bool isUnicodeGraphical(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.L:
        case GeneralCategory.M:
        case GeneralCategory.N:
        case GeneralCategory.P:
        case GeneralCategory.S:
        case GeneralCategory.Zs:
            return true;

        default:
            return false;
    }
}

/// Is character a control?
export bool isUnicodeControl(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Cc:
            return true;

        default:
            return false;
    }
}

/// Is character a alpha?
export bool isUnicodeAlpha(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lu:
        case GeneralCategory.Ll:
        case GeneralCategory.Lt:
        case GeneralCategory.Lm:
        case GeneralCategory.Lo:
            return true;

        default:
            return false;
    }
}

/// Is character a number?
export bool isUnicodeNumber(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Nd:
        case GeneralCategory.Nl:
        case GeneralCategory.No:
            return true;

        default:
            return false;
    }
}

/// Is character a alpha or number?
export bool isUnicodeAlphaOrNumber(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lu:
        case GeneralCategory.Ll:
        case GeneralCategory.Lt:
        case GeneralCategory.Lm:
        case GeneralCategory.Lo:
        case GeneralCategory.Nd:
        case GeneralCategory.Nl:
        case GeneralCategory.No:
            return true;

        default:
            return false;
    }
}

/// Is character uppercase?
export bool isUnicodeUpper(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lu:
            return true;

        default:
            return false;
    }
}

/// Is character lowercase?
export bool isUnicodeLower(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Ll:
            return true;

        default:
            return false;
    }
}

/// Is character titlecase?
export bool isUnicodeTitle(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lt:
            return true;

        default:
            return false;
    }
}
};

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup general category for character.\n";
        generateReturn(apiOutput, internal, "sidero_utf_lut_getGeneralCategory", ranges, gcs, "GeneralCategory");
    }

    append(UnicodeAPIFile, apiOutput.data);
    write(UnicodeLUTDirectory ~ "unicodedata.d", internal.data);
}

/*
compatibility mappings have a formatting tag
canonical does not have a formatting tag

If a decomposition mapping (codepoints) are empty or its the original codepoint, than it is equivalent to the original codepoint and ignored

canonical mappings maybe have decomposition mappings
*/
