module generators.unicode.genfor.composition;
import generators.unicode.data.CompositionExclusions;
import generators.unicode.data.UnicodeData;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import std.algorithm : sort;

void genForComposition() {
    implOutput ~= "module sidero.base.internal.unicode.unicodedataC;\n";
    implOutput ~= "// Generated do not modify\n\n";

    canonical;
    compatibility;
}

private:

struct Pair {
    ulong range;
    dchar character;
}

void canonical() {
    Pair[] pairs;
    ulong[] ranges;
    dchar[] characters;

    CompositionCanonical: foreach(character, entry; UnicodeData.decompositonMappings) {
        if(entry.decomposed.length != 2 || entry.tag != CompatibilityFormattingTag.None)
            continue;

        foreach(ex; CompositionExclusions) {
            if(ex.within(character))
                continue CompositionCanonical;
        }

        dchar L = entry.decomposed[0], C = entry.decomposed[1];

        ulong temp = C;
        temp <<= 32;
        temp |= L;

        pairs ~= Pair(temp, character);
    }

    sort!"a.range < b.range"(pairs);

    foreach(v; pairs) {
        ranges ~= v.range;
        characters ~= v.character;
    }

    apiOutput ~= "\n";
    apiOutput ~= "/// Get composition for character pair.\n";
    apiOutput ~= "/// Returns: dchar.init if not set.\n";
    apiOutput ~= "export dchar sidero_utf_lut_getCompositionCanonical(dchar L, dchar C) @trusted nothrow @nogc pure {\n";
    apiOutput ~= "    ulong temp = C;\n";
    apiOutput ~= "    temp <<= 32;\n";
    apiOutput ~= "    temp |= L;\n";
    apiOutput ~= "    return sidero_utf_lut_getCompositionCanonical2(temp);\n";
    apiOutput ~= "}\n";

    generateReturn(apiOutput, implOutput, "sidero_utf_lut_getCompositionCanonical2", ranges, characters);
}

void compatibility() {
    Pair[] pairs;
    ulong[] ranges;
    dchar[] characters;

    CompositionCompatibility: foreach(character, entry; UnicodeData.decompositonMappings) {
        if(entry.decomposed.length != 2)
            continue;

        foreach(ex; CompositionExclusions) {
            if(ex.within(character))
                continue CompositionCompatibility;
        }

        dchar L = entry.decomposed[0], C = entry.decomposed[1];

        ulong temp = C;
        temp <<= 32;
        temp |= L;

        foreach(ref pair; pairs) {
            if(pair.range == temp) {
                pair.character = character;
                continue CompositionCompatibility;
            }
        }

        pairs ~= Pair(temp, character);
    }

    sort!"a.range < b.range"(pairs);

    foreach(i, v; pairs) {
        ranges ~= v.range;
        characters ~= v.character;
    }

    apiOutput ~= "\n";
    apiOutput ~= "/// Get composition for character pair.\n";
    apiOutput ~= "/// Returns: dchar.init if not set.\n";
    apiOutput ~= "export dchar sidero_utf_lut_getCompositionCompatibility(dchar L, dchar C) @trusted nothrow @nogc pure {\n";
    apiOutput ~= "    ulong temp = C;\n";
    apiOutput ~= "    temp <<= 32;\n";
    apiOutput ~= "    temp |= L;\n";
    apiOutput ~= "    return sidero_utf_lut_getCompositionCompatibility2(temp);\n";
    apiOutput ~= "}\n";

    generateReturn(apiOutput, implOutput, "sidero_utf_lut_getCompositionCompatibility2", ranges, characters);
}
