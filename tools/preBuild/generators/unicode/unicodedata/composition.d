module generators.unicode.unicodedata.composition;
import generators.unicode.unicodedata.common;
import constants;
import std.file : write;
import std.array : appender;

void Composition() {
    import generators.unicode.compositionexclusions;
    import std.algorithm : sort;

    auto internalC = appender!string();
    internalC ~= "module sidero.base.internal.unicode.unicodedataC;\n\n";
    internalC ~= "// Generated do not modify\n";

    {
        Pair[] pairs;
        ulong[] ranges;
        dchar[] characters;

        CompositionCanonical: foreach(character, entry; state.decompositonMappings) {
            if(entry.decomposed.length != 2 || entry.tag != CompatibilityFormattingTag.None)
                continue;

            foreach(ex; compositionExclusionRanges) {
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

        generateReturn(apiOutput, internalC, "sidero_utf_lut_getCompositionCanonical2", ranges, characters);
    }

    {
        Pair[] pairs;
        ulong[] ranges;
        dchar[] characters;

        CompositionCompatibility: foreach(character, entry; state.decompositonMappings) {
            if(entry.decomposed.length != 2)
                continue;

            foreach(ex; compositionExclusionRanges) {
                if(ex.within(character))
                    continue CompositionCompatibility;
            }

            dchar L = entry.decomposed[0], C = entry.decomposed[1];

            ulong temp = C;
            temp <<= 32;
            temp |= L;

            foreach(ref pair; pairs) {
                if (pair.range == temp) {
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

        generateReturn(apiOutput, internalC, "sidero_utf_lut_getCompositionCompatibility2", ranges, characters);

    }

    write(UnicodeLUTDirectory ~ "unicodedataC.d", internalC.data);
}

private:
import utilities.setops;
import utilities.inverselist;

struct Pair {
    ulong range;
    dchar character;
}
