module generators.unicode.genfor;
import generators.unicode.defs;
import constants;
import std.array : appender;
import std.file : write;

void genForUnicode() {
    implOutput = appender!string();
    scope(exit)
        write(UnicodeAPIFile, apiOutput.data);

    import generators.unicode.genfor.external;
    import generators.unicode.genfor.casing;
    import generators.unicode.genfor.ccc;
    import generators.unicode.genfor.casing_special;
    import generators.unicode.genfor.casing_folding;
    import generators.unicode.genfor.properties;
    import generators.unicode.genfor.properties_normalization;
    import generators.unicode.genfor.properties_graphemebreak;
    import generators.unicode.genfor.properties_wordbreak;
    import generators.unicode.genfor.compatibility_formatting;
    import generators.unicode.genfor.decomposition;
    import generators.unicode.genfor.composition;
    import generators.unicode.genfor.composition_exclusions;
    import generators.unicode.genfor.uax31;
    import generators.unicode.genfor.other;
    import generators.unicode.genfor.emoji_data;

    genForExternal();
    handle!genForCasing("unicodedataCa.d");
    handle!genForCCC("unicodedataCCC.d");
    handle!genForSpecialCasing("specialcasing.d");
    handle!genForCaseFolding("casefolding.d");
    handle!genForProperties("proplist.d");
    handle!genForNormalizationProps("derivednormalizationprops.d");
    handle!genForGraphemeBreakProperty("graphemebreakproperty.d");
    handle!genForWordBreakProperty("wordbreakproperty.d");
    handle!genForCompatibilityFormatting("unicodedataCF.d");
    handle!genForDecomposition("unicodedataDM.d");
    handle!genForComposition("unicodedataC.d");
    handle!genForCompositionExclusions("compositionexclusions.d");
    handle!genForUAX31Tables("uax31.d");
    handle!genForOther("other.d");
    handle!genForEmojiData("emoji_data.d");
}

private:

void handle(alias Func)(string filename) {
    implOutput = appender!string();

    scope(exit)
        write(UnicodeLUTDirectory ~ filename, implOutput.data);

    Func();
}
