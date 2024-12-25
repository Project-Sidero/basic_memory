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

        writeln("Running generation of Unicode database");
        loadUnicodeData;
        genForUnicode;
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
