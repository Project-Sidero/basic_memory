module generators.main;
import generators.constants;

void main() {
    import std.array : appender;
    import std.file : remove, exists, mkdirRecurse, write;

    try {
        if(exists("generated"))
            remove("generated");
    } catch(Exception e) {
    }

    mkdirRecurse(UnicodeLUTDirectory);
    mkdirRecurse(CLDRDirectory);

    {
        import generators.unicode.external;
        import generators.unicode.casefolding;
        import generators.unicode.compositionexclusions;
        import generators.unicode.hangulsyllabletype;
        import generators.unicode.derivednormalizationprops;
        import generators.unicode.unicodedata;
        import generators.unicode.proplist;
        import generators.unicode.wordbreakproperty;
        import generators.unicode.specialcasing;
        import generators.unicode.linebreak;
        import generators.unicode.emoji_data;
        import generators.unicode.scripts;

        createAPIfile;

        caseFolding;
        // must be before unicodeData
        compositionExclusions;
        hangulSyllableType;
        derivedNormalizationProps;
        // must be after compositionExclusions
        unicodeData;
        propList;
        wordBreakProperty;
        specialCasing;
        lineBreak;
        emojiData;
        handleScripts;
    }

    {
        import generators.cldr.external;
        import generators.cldr.windowszones;

        createAPIfile;

        windowsZones;
    }
}
