module generators.unicode.genfor.decomposition;
import generators.unicode.data.UnicodeData;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import std.format : formattedWrite;
import std.algorithm : sort;

/*
compatibility mappings have a formatting tag
canonical does not have a formatting tag

If a decomposition mapping (codepoints) are empty or its the original codepoint, than it is equivalent to the original codepoint and ignored

canonical mappings maybe have decomposition mappings
*/

void genForDecomposition() {
    implOutput ~= q{module sidero.base.internal.unicode.unicodedataDM;
// Generated do not modify

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

    intern;
    mappings;
    table;
    wrapper;
    forTag;
    lengthOfForTag;
    lengthOfFullyDecomposed;
}

private:
size_t[dstring] decompositionDStringMap;
dstring decompositionText;

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

struct CharacterLength {
    dchar character;
    ushort length;
}

void intern() {
    foreach(character, entry; UnicodeData.decompositonMappings) {
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

void mappings() {
    Pair[] pairs;
    dchar[] characters;
    DMdiced[] dmDiceds;

    foreach(character, entry; UnicodeData.decompositonMappings) {
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

    generateReturn(implOutput, "sidero_utf_lut_getDecompositionMap3", characters, dmDiceds);
}

void wrapper() {
    implOutput ~= "export extern(C) void sidero_utf_lut_getDecompositionMap2(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
    implOutput ~= "    DM* output = cast(DM*)outputPtr;\n";
    implOutput ~= "    auto sliced = cast(DMdiced*)sidero_utf_lut_getDecompositionMap3(input);\n";
    implOutput ~= "    if (sliced is null)\n";
    implOutput ~= "        return;\n";
    implOutput ~= "    output.tag = cast(CFT)sliced.tag;\n";
    implOutput ~= "    output.decomposed = LUT_DecompositionDString[sliced.decomposedOffset .. sliced.decomposedEnd];\n";
    implOutput ~= "    output.fullyDecomposed = LUT_DecompositionDString[sliced.fullyDecomposedOffset .. sliced.fullyDecomposedEnd];\n";
    implOutput ~= "    output.fullyDecomposedCompatibility = LUT_DecompositionDString[sliced.fullyDecomposedCompatibilityOffset .. sliced.fullyDecomposedCompatibilityEnd];\n";
    implOutput ~= "    if (output.decomposed.length == 0)\n";
    implOutput ~= "        output.decomposed = null;\n";
    implOutput ~= "    if (output.fullyDecomposed.length == 0)\n";
    implOutput ~= "        output.fullyDecomposed = null;\n";
    implOutput ~= "    if (output.fullyDecomposedCompatibility.length == 0)\n";
    implOutput ~= "        output.fullyDecomposedCompatibility = null;\n";
    implOutput ~= "}\n";

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

void table() {
    implOutput ~= "static immutable LUT_DecompositionDString = cast(dstring)x\"";

    foreach(i, dchar c; decompositionText) {
        implOutput.formattedWrite!"%08X"(c);
    }

    implOutput ~= "\";\n\n";
}

void forTag() {
    apiOutput ~= "\n";
    apiOutput ~= "/// Lookup decomposition mapping for character given the compatibility formatting tag.\n";
    apiOutput ~= "export dstring sidero_utf_lut_getDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {\n";
    apiOutput ~= "    final switch(tag) {\n";
    foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
        apiOutput ~= "        case CompatibilityFormattingTag." ~ tag ~ ":\n";
        apiOutput ~= "            return sidero_utf_lut_getDecompositionMapping" ~ tag ~ "(input);\n";
    }
    apiOutput ~= "    }\n";
    apiOutput ~= "}\n";
}

void lengthOfForTag() {
    apiOutput ~= "\n";
    apiOutput ~= "/// Lookup length of decomposition mapping for character given the compatibility formatting tag.\n";
    apiOutput ~= "export ubyte sidero_utf_lut_lengthOfDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {\n";
    apiOutput ~= "    final switch(tag) {\n";
    foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
        apiOutput ~= "        case CompatibilityFormattingTag." ~ tag ~ ":\n";
        apiOutput ~= "            return sidero_utf_lut_lengthOfDecompositionMapping" ~ tag ~ "(input);\n";
    }
    apiOutput ~= "    }\n";
    apiOutput ~= "}\n";
}

void lengthOfFullyDecomposed() {
    CharacterLength[] pairs;
    dchar[] characters;
    ushort[] lengths;

    foreach(character, entry; UnicodeData.decompositonMappings) {
        pairs ~= CharacterLength(character, cast(ushort)entry.fullyDecomposed.length);
    }

    sort!"a.character < b.character"(pairs);

    foreach(pair; pairs) {
        characters ~= pair.character;
        lengths ~= pair.length;
    }

    apiOutput ~= "\n";
    apiOutput ~= "/// Get length of fully decomposed for character.\n";
    generateReturn(apiOutput, implOutput, "sidero_utf_lut_lengthOfFullyDecomposed", characters, lengths);
}
