module generators.unicode.unicodedata.decomposition;
import generators.unicode.unicodedata.common;
import constants;
import utilities.setops;
import utilities.inverselist;
import std.file : write;
import std.array : appender;

void decompositionMap() {
    import std.algorithm : sort;
    import std.format : formattedWrite;

    auto internalDM = appender!string();
    internalDM ~= "module sidero.base.internal.unicode.unicodedataDM;\n";
    internalDM ~= "// Generated do not modify\n\n";

    size_t[dstring] decompositionDStringMap;
    dstring decompositionText;

    {

        foreach(character, entry; state.decompositonMappings) {
            if(entry.decomposed !in decompositionDStringMap) {
                decompositionDStringMap[entry.decomposed] = decompositionText.length;
                decompositionText ~= entry.decomposed;
            }

            if(entry.fullyDecomposed !in decompositionDStringMap) {
                decompositionDStringMap[entry.fullyDecomposed] = decompositionText.length;
                decompositionText ~= entry.fullyDecomposed;
            }

            if(entry.fullyDecomposedCompatibility !in decompositionDStringMap) {
                decompositionDStringMap[entry.fullyDecomposedCompatibility] = decompositionText.length;
                decompositionText ~= entry.fullyDecomposedCompatibility;
            }
        }
    }

    {
        Pair[] pairs;
        dchar[] characters;
        DMdiced[] dmDiceds;

        foreach(character, entry; state.decompositonMappings) {
            DMdiced diced;
            diced.tag = cast(ushort)entry.tag;
            diced.decomposedOffset = cast(ushort)decompositionDStringMap[entry.decomposed];
            diced.decomposedEnd = cast(ushort)(diced.decomposedOffset + entry.decomposed.length);
            diced.fullyDecomposedOffset = cast(ushort)decompositionDStringMap[entry.fullyDecomposed];
            diced.fullyDecomposedEnd = cast(ushort)(diced.fullyDecomposedOffset + entry.fullyDecomposed.length);
            diced.fullyDecomposedCompatibilityOffset = cast(ushort)decompositionDStringMap[entry.fullyDecomposedCompatibility];
            diced.fullyDecomposedCompatibilityEnd = cast(ushort)(
                    diced.fullyDecomposedCompatibilityOffset + entry.fullyDecomposedCompatibility.length);

            pairs ~= Pair(character, diced);
        }

        sort!"a.range < b.range"(pairs);
        characters.reserve(pairs.length);
        dmDiceds.reserve(pairs.length);

        foreach(pair; pairs) {
            characters ~= pair.range;
            dmDiceds ~= pair.diced;
        }

        generateReturn(internalDM, "sidero_utf_lut_getDecompositionMap3", characters, dmDiceds);
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
        internalDM ~= "static immutable LUT_DecompositionDString = cast(dstring)x\"";

        foreach(i, dchar c; decompositionText) {
            internalDM.formattedWrite!"%08X"(c);
        }

        internalDM ~= "\";\n\n";
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

struct DMdiced {
    ushort tag;
    ushort decomposedOffset, decomposedEnd;
    ushort fullyDecomposedOffset, fullyDecomposedEnd;
    ushort fullyDecomposedCompatibilityOffset, fullyDecomposedCompatibilityEnd;
}
};

    write(UnicodeLUTDirectory ~ "unicodedataDM.d", internalDM.data);
}

struct Pair {
    dchar range;
    DMdiced diced;
}

struct DMdiced {
    ushort tag;
    ushort decomposedOffset, decomposedEnd;
    ushort fullyDecomposedOffset, fullyDecomposedEnd;
    ushort fullyDecomposedCompatibilityOffset, fullyDecomposedCompatibilityEnd;
}
