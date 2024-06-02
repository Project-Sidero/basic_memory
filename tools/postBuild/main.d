module main;
import constants;
import std.stdio : writeln;
import std.file : remove, exists, mkdirRecurse, write, readText, copy;

void main() {
    writeln("Running post build tools");

    try {
        if(exists(OutputDirectory))
            remove(OutputDirectory);
    } catch(Exception e) {
    }

    mkdirRecurse(OutputUnicodeDirectory);
    mkdirRecurse(OutputInternalDirectory);
    mkdirRecurse(OutputDateTimeDirectory);

    {
        import unicode_text_representation.builder;
        writeln("Running unicode text representation builder generator");
        generateUnicodeBuilders;

        writeln("Running unicode text representation readonly generator");
        import unicode_text_representation.readonly;
        generateUnicodeReadOnly;

        copy(InputGeneratedUnicodeDirectory ~ "database.d", OutputUnicodeDirectory ~ "database.d");
    }

    {
        import internal.meta;
        writeln("Running internal meta opApply combos generator");
        generateInternalMeta;
    }

    {
        copy(InputGeneratedDateTimeDirectory ~ "cldr.d", OutputDateTimeDirectory ~ "cldr.di");
    }

    writeln("All tools have run successfully");
}
