module generators.unicode.genfor.scripts;
import generators.unicode.data.Scripts;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import utilities.intervallist;

void genForScripts() {
    implOutput ~= "module sidero.base.internal.unicode.scripts;\n";
    implOutput ~= "import sidero.base.containers.set.interval;\n";
    implOutput ~= "// Generated do not modify\n\n";

    scriptFor;
    isUnknown;
    isKnown;
}

private:

void seqEntries(out ValueRange[] ranges, out ubyte[] scripts, Pair[] entries) {
    import std.algorithm : sort;

    sort!"a.range.start < b.range.start"(entries);

    ranges.reserve(entries.length);
    scripts.reserve(entries.length);

    foreach(v; entries) {
        assert(v.range.start <= v.range.end);
        ranges ~= v.range;
        scripts ~= v.script;
    }
}

void scriptFor() {
    apiOutput ~= "\n";
    apiOutput ~= "/// Get the Script for a character\n";

    ValueRange[] ranges;
    ubyte[] scripts;
    seqEntries(ranges, scripts, Scripts.pairs);
    generateReturn(apiOutput, implOutput, "sidero_utf_lut_getScript", ranges, scripts, "Script");
}

void isUnknown() {
    apiOutput ~= "/// Is the character a member of the script Unknown\n";
    generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isScriptUnknown", Scripts.all.ranges, true, true);
}

void isKnown() {
    static foreach(Sm; __traits(allMembers, Script)) {
        {
            enum script = __traits(getMember, Script, Sm);

            static if(script != Script.Unknown) {
                apiOutput ~= "/// Is the character a member of the script " ~ Sm ~ "\n";
                generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isScript" ~ Sm, Scripts.scriptRanges[script], true);
            }
        }
    }
}
