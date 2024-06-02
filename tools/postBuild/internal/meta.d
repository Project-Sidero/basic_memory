module internal.meta;
import constants;

void generateInternalMeta() {
    import std.file : write, readText;
    import std.regex;
    import std.stdio;

    string text = readText(InputGeneratedInternalDirectory ~ "meta.d");

    {
        auto r = regex("^([^\"\n]*opApply.*) =(?=>)([^;]*);$", "m");
        text = replaceAll!(capture => capture[1] ~ ";")(text, r);
    }

    write(OutputInternalDirectory ~ "meta.di", text);
}
