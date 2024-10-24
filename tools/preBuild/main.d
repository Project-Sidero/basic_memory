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
        import generators.unicode.graphemebreakproperty;
        import generators.unicode.derivedcoreproperties;
        import generators.unicode.uax31;

        writeln("Running generation of Unicode database");
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

        graphemeBreakProperty;
        parseDerivedCoreProperties;

        // must be after parseDerivedCoreProperties
        uax31Tables;
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
