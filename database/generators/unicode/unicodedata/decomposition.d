module generators.unicode.unicodedata.decomposition;
import generators.unicode.unicodedata.common;
import generators.constants;
import utilities.sequential_ranges;
import utilities.lut;
import std.file : write;
import std.array : appender;

void decompositionMap() {
    import std.format : formattedWrite;
    auto internalDM = appender!string();
    internalDM ~= "module sidero.base.internal.unicode.unicodedataDM;\n\n";
    internalDM ~= "// Generated do not modify\n";

    size_t[dstring] decompositionDStringMap;
    dstring decompositionText;

    {

        foreach (character, entry; state.decompositonMappings) {
            if (entry.decomposed !in decompositionDStringMap) {
                decompositionDStringMap[entry.decomposed] = decompositionText.length;
                decompositionText ~= entry.decomposed;
            }

            if (entry.fullyDecomposed !in decompositionDStringMap) {
                decompositionDStringMap[entry.fullyDecomposed] = decompositionText.length;
                decompositionText ~= entry.fullyDecomposed;
            }

            if (entry.fullyDecomposedCompatibility !in decompositionDStringMap) {
                decompositionDStringMap[entry.fullyDecomposedCompatibility] = decompositionText.length;
                decompositionText ~= entry.fullyDecomposedCompatibility;
            }
        }
    }

    {
        SequentialRanges!(DMdiced, SequentialRangeSplitGroup, 2) sr;

        foreach (character, entry; state.decompositonMappings) {
            DMdiced diced;
            diced.tag = cast(ushort)entry.tag;
            diced.decomposedOffset = cast(ushort)decompositionDStringMap[entry.decomposed];
            diced.decomposedEnd = cast(ushort)(diced.decomposedOffset + entry.decomposed.length);
            diced.fullyDecomposedOffset = cast(ushort)decompositionDStringMap[entry.fullyDecomposed];
            diced.fullyDecomposedEnd = cast(ushort)(diced.fullyDecomposedOffset + entry.fullyDecomposed.length);
            diced.fullyDecomposedCompatibilityOffset = cast(ushort)decompositionDStringMap[entry.fullyDecomposedCompatibility];
            diced.fullyDecomposedCompatibilityEnd = cast(ushort)(diced.fullyDecomposedCompatibilityOffset + entry.fullyDecomposedCompatibility.length);

            sr.add(character, diced);
        }

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(DMdiced, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "void*";
        lut.name = "sidero_utf_lut_getDecompositionMap3";
        lut.typeToReplacedName["DMdiced"] = "DM2";

        auto gotDcode = lut.build();
        internalDM ~= gotDcode[1];
    }

    {
        internalDM ~= "export extern(C) void sidero_utf_lut_getDecompositionMap2(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
        internalDM ~= "    DM* output = cast(DM*)outputPtr;\n";
        internalDM ~= "    auto sliced = cast(DMdiced*)sidero_utf_lut_getDecompositionMap3(input);\n";
        internalDM ~= "    if (sliced is null)\n";
        internalDM ~= "        return;\n";
        internalDM ~= "    output.tag = cast(CFT)sliced.tag;\n";
        internalDM ~= "    output.decomposed = LUT_DecompositionDString[sliced.decomposedOffset .. sliced.decomposedEnd];\n";
        internalDM ~= "    output.fullyDecomposed = LUT_DecompositionDString[sliced.fullyDecomposedOffset .. sliced.fullyDecomposedEnd];\n";
        internalDM ~= "    output.fullyDecomposedCompatibility = LUT_DecompositionDString[sliced.fullyDecomposedCompatibilityOffset .. sliced.fullyDecomposedCompatibilityEnd];\n";
        internalDM ~= "    if (output.decomposed.length == 0)\n";
        internalDM ~= "        output.decomposed = null;\n";
        internalDM ~= "    if (output.fullyDecomposed.length == 0)\n";
        internalDM ~= "        output.fullyDecomposed = null;\n";
        internalDM ~= "    if (output.fullyDecomposedCompatibility.length == 0)\n";
        internalDM ~= "        output.fullyDecomposedCompatibility = null;\n";
        internalDM ~= "}\n";

        apiOutput ~= "\n";
        apiOutput ~= "/// Get decomposition map for character.\n";
        apiOutput ~= "/// Returns: None for tag if unchanged.\n";
        apiOutput ~= "export immutable(DecompositionMapping) sidero_utf_lut_getDecompositionMap(dchar input) @trusted nothrow @nogc pure {\n";
        apiOutput ~= "    DecompositionMapping ret;\n";
        apiOutput ~= "    sidero_utf_lut_getDecompositionMap2(input, &ret);\n";
        apiOutput ~= "    return cast(immutable)ret;\n";
        apiOutput ~= "}\n";

        apiOutput ~= "export extern(C) void sidero_utf_lut_getDecompositionMap2(dchar input, void*) @trusted nothrow @nogc pure;\n";
    }

    {
        internalDM ~= "static immutable dstring LUT_DecompositionDString = cast(dstring)[";

        foreach(i, dchar c; decompositionText) {
            if (i > 0)
                internalDM ~= ", ";
            internalDM.formattedWrite!"0x%X"(c);
        }

        internalDM ~= "];\n\n";
    }

    version (none) {
        SequentialRanges!(DecompositionMapping, SequentialRangeSplitGroup, 2) sr;

        foreach (character, entry; state.decompositonMappings)
            sr.add(character, entry);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(DecompositionMapping, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "void*";
        lut.name = "sidero_utf_lut_getDecompositionMap2";
        lut.typeToReplacedName["DecompositionMapping"] = "DM";
        lut.typeToReplacedName["CompatibilityFormattingTag"] = "CFT";

        auto gotDcode = lut.build();

        size_t foundIt;
        foreach (entry, layerIndex; sr) {
            if (entry.range.within(0xF96B)) {
                version (none) {
                    import std.stdio;

                    writefln!"%X < input < %X"(entry.range.start, entry.range.end);

                    foreach (c; entry.metadataEntries[0xF96B - entry.range.start].decomposed)
                        writef!"%X"(c);
                    writeln;
                    debug stdout.flush;
                }

                foundIt++;
                assert(entry.metadataEntries[0xF96B - entry.range.start].decomposed == "\u53C3"d);
            }
        }
        assert(foundIt == 1);

        apiOutput ~= "\n";
        apiOutput ~= "/// Get decomposition map for character.\n";
        apiOutput ~= "/// Returns: null if unchanged.\n";
        apiOutput ~= "export immutable(DecompositionMapping) sidero_utf_lut_getDecompositionMap(dchar input) @trusted nothrow @nogc pure {\n";
        apiOutput ~= "    auto got = sidero_utf_lut_getDecompositionMap2(input);\n";
        apiOutput ~= "    if (got is null) return typeof(return).init;\n";
        apiOutput ~= "    return *cast(immutable(DecompositionMapping*)) got;\n";
        apiOutput ~= "}\n";
        apiOutput ~= gotDcode[0];

        version (none) {
            apiOutput ~= "shared static this() {\n";
            apiOutput ~= "    assert(sidero_utf_lut_getDecompositionMap(0xF96B).decomposed == \"\\u53C3\"d);\n";
            apiOutput ~= "}\n";
        }

        internalDM ~= gotDcode[1];
    }

    internalDM ~= q{
enum CFT : uint {
    None,
    Font,
    NoBreak,
    Initial,
    Medial,
    Final,
    Isolated,
    Circle,
    Super,
    Sub,
    Vertical,
    Wide,
    Narrow,
    Small,
    Square,
    Fraction,
    Compat,
}

struct DM {
    CFT tag;
    dstring decomposed;
    dstring fullyDecomposed, fullyDecomposedCompatibility;
}

alias DM2 = DMdiced;
struct DMdiced {
    ushort tag;
    ushort decomposedOffset, decomposedEnd;
    ushort fullyDecomposedOffset, fullyDecomposedEnd;
    ushort fullyDecomposedCompatibilityOffset, fullyDecomposedCompatibilityEnd;
}
};

    write(UnicodeLUTDirectory ~ "unicodedataDM.d", internalDM.data);
}

struct DMdiced {
    ushort tag;
    ushort decomposedOffset, decomposedEnd;
    ushort fullyDecomposedOffset, fullyDecomposedEnd;
    ushort fullyDecomposedCompatibilityOffset, fullyDecomposedCompatibilityEnd;
}
