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

    genForExternal();

    import generators.unicode.genfor.casing;

    handle!genForCasing("unicodedataCa.d");

    import generators.unicode.genfor.ccc;

    handle!genForCCC("unicodedataCCC.d");

    import generators.unicode.genfor.casing_special;

    handle!genForSpecialCasing("specialcasing.d");

    import generators.unicode.genfor.properties;

    handle!genForProperties("proplist.d");

    import generators.unicode.genfor.compatibility_formatting;

    handle!genForCompatibilityFormatting("unicodedataCF.d");

    import generators.unicode.genfor.decomposition;

    handle!genForDecomposition("unicodedataDM.d");

    import generators.unicode.genfor.composition;

    handle!genForComposition("unicodedataC.d");

    import generators.unicode.genfor.composition_exclusions;

    handle!genForCompositionExclusions("compositionexclusions.d");

    import generators.unicode.genfor.uax31;

    handle!genForUAX31Tables("uax31.d");

    import generators.unicode.genfor.other;

    handle!genForOther("other.d");
}

private:

void handle(alias Func)(string filename) {
    implOutput = appender!string();

    scope(exit)
        write(UnicodeLUTDirectory ~ filename, implOutput.data);

    Func();
}
