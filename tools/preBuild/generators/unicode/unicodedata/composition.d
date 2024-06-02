module generators.unicode.unicodedata.composition;
import generators.unicode.unicodedata.common;
import constants;
import utilities.sequential_ranges;
import utilities.lut;
import std.file : write;
import std.array : appender;

void Composition() {
    import generators.unicode.compositionexclusions;

    auto internalC = appender!string();
    internalC ~= "module sidero.base.internal.unicode.unicodedataC;\n\n";
    internalC ~= "// Generated do not modify\n";

    {
        SequentialRanges!(dchar, SequentialRangeSplitGroup, 2, ulong) sr;

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
            sr.add(temp, character);
        }

        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 256);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(dchar, SequentialRangeSplitGroup, 2, ulong) lut;
        lut.sr = sr;
        lut.lutType = "dchar";
        lut.name = "sidero_utf_lut_getCompositionCanonical2";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Get composition for character pair.\n";
        apiOutput ~= "/// Returns: dchar.init if not set.\n";
        apiOutput ~= "export dchar sidero_utf_lut_getCompositionCanonical(dchar L, dchar C) @trusted nothrow @nogc pure {\n";
        apiOutput ~= "    ulong temp = C;\n";
        apiOutput ~= "    temp <<= 32;\n";
        apiOutput ~= "    temp |= L;\n";
        apiOutput ~= "    return sidero_utf_lut_getCompositionCanonical2(temp);\n";
        apiOutput ~= "}\n";
        apiOutput ~= gotDcode[0];

        internalC ~= gotDcode[1];
    }

    {
        SequentialRanges!(dchar, SequentialRangeSplitGroup, 2, ulong) sr;

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
            sr.add(temp, character);
        }

        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 256);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(dchar, SequentialRangeSplitGroup, 2, ulong) lut;
        lut.sr = sr;
        lut.lutType = "dchar";
        lut.name = "sidero_utf_lut_getCompositionCompatibility2";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Get composition for character pair.\n";
        apiOutput ~= "/// Returns: dchar.init if not set.\n";
        apiOutput ~= "export dchar sidero_utf_lut_getCompositionCompatibility(dchar L, dchar C) @trusted nothrow @nogc pure {\n";
        apiOutput ~= "    ulong temp = C;\n";
        apiOutput ~= "    temp <<= 32;\n";
        apiOutput ~= "    temp |= L;\n";
        apiOutput ~= "    return sidero_utf_lut_getCompositionCompatibility2(temp);\n";
        apiOutput ~= "}\n";
        apiOutput ~= gotDcode[0];

        internalC ~= gotDcode[1];
    }

    write(UnicodeLUTDirectory ~ "unicodedataC.d", internalC.data);
}
