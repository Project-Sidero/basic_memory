module generators.unicode.unicodedata;
import generators.unicode.unicodedata.common;
import generators.constants;
import utilities.sequential_ranges;
import utilities.lut;

void unicodeData() {
    import std.file : readText, write, append;
    import std.array : appender;

    apiOutput = appender!string();

    processEachLine(readText("unicode-14/UnicodeData.txt"));
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
        SequentialRanges!(size_t, SequentialRangeSplitGroup, 2) sr;

        foreach(character, entry; state.decompositonMappings)
            sr.add(character, entry.fullyDecomposed.length);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(size_t, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "size_t";
        lut.name = "sidero_utf_lut_lengthOfFullyDecomposed";
        lut.defaultReturn = "1";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Get length of fully decomposed for character.\n";
        apiOutput ~= gotDcode[0];

        internal ~= gotDcode[1];
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
        SequentialRanges!(long[], SequentialRangeSplitGroup, 2) sr;

        foreach(entry; state.entries) {
            foreach(c; entry.range.start .. entry.range.end + 1) {
                if(entry.numericValueNumerator != 0 || entry.numericValueDenominator != 0)
                    sr.add(cast(dchar)c, [entry.numericValueNumerator, entry.numericValueDenominator]);
            }
        }

        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar key) => [0L, 0], 5, 32);
        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar key) => [0L, 0], 5, 32);
        sr.calculateTrueSpread;
        sr.layerBySingleMulti(0);
        sr.layerJoinIfEndIsStart(0, 1);
        sr.layerByRangeMax(1, ushort.max / 8);

        LookupTableGenerator!(long[], SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "long[]";
        lut.name = "sidero_utf_lut_getNumeric";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup numeric numerator/denominator for character.\n";
        apiOutput ~= "/// Returns: null if not set.\n";
        apiOutput ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach(entry; state.entries) {
            foreach(c; entry.range.start .. entry.range.end + 1)
                sr.add(cast(dchar)c, cast(ubyte)entry.generalCategory);
        }

        sr.calculateTrueSpread;
        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.externType = "GeneralCategory";
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_getGeneralCategory";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup general category for character.\n";
        apiOutput ~= gotDcode[0];

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

        internal ~= gotDcode[1];
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
