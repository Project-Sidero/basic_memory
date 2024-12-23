module main;
import constants;
import std.stdio : writeln;
import std.array : appender;
import std.file : remove, exists, mkdirRecurse, write;

void main() {
    writeln("Running pre build tools");

    try {
        if(exists("generated"))
            remove("generated");
    } catch(Exception e) {
    }

    mkdirRecurse(UnicodeLUTDirectory);
    mkdirRecurse(CLDRDirectory);

    {
        import generators.unicode_text_representations : generateUnicodeTextRepresentations;
        writeln("Running generation of Unicode text representations");
        generateUnicodeTextRepresentations;

        import generators.internal_meta_opapplycombos : generateInternalMetaOpApplyCombos;
        writeln("Running generation of op apply combos");
        generateInternalMetaOpApplyCombos;
    }

    {
        import generators.unicode.data;
        import generators.unicode.genfor;

        import generators.unicode.casefolding;
        import generators.unicode.hangulsyllabletype;
        import generators.unicode.derivednormalizationprops;
        import generators.unicode.wordbreakproperty;
        import generators.unicode.linebreak;
        import generators.unicode.emoji_data;
        import generators.unicode.scripts;
        import generators.unicode.graphemebreakproperty;
        import generators.unicode.derivedcoreproperties;

        writeln("Running generation of Unicode database");
        loadUnicodeData;
        genForUnicode;

        caseFolding;
        // must be before unicodeData
        hangulSyllableType;
        derivedNormalizationProps;
        // must be after compositionExclusions
        wordBreakProperty;
        lineBreak;
        emojiData;
        handleScripts;

        graphemeBreakProperty;
        parseDerivedCoreProperties;
    }

    {
        import generators.cldr.external;
        import generators.cldr.windowszones;

        writeln("Running generation of CLDR windows zones");
        createAPIfile;

        windowsZones;
    }

    {
        import generators.all_generated;
        generateAllGeneratedFiles();
    }

    writeln("All tools have run successfully");
}
