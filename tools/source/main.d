module main;
import std.stdio;

void main() {
    writeln("Running tools");

    import unicode_builders : runUnicodeBuilders;
    writeln("Running generation of Unicode string builders");
    runUnicodeBuilders;

    import internal_meta : generateInternalMeta;
    writeln("Running generation of op apply combos");
    generateInternalMeta;

    writeln("All tools have run successfully");
}

private:

