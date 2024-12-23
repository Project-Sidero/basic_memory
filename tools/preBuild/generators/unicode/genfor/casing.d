module generators.unicode.genfor.casing;
import generators.unicode.data.UnicodeData;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import std.format : formattedWrite;

void genForCasing() {
    implOutput ~= q{module sidero.base.internal.unicode.unicodedataCa;
// Generated do not modify

struct Casing {
    dstring lower, title, upper;
    ubyte condition;
}

struct CasingDiced {
    ushort lowerOffset, lowerEnd;
    ushort titleOffset, titleEnd;
    ushort upperOffset, upperEnd;
}
};

    intern;

    simplified;
    table;
    wrapper;
    isCased;
}

private:

size_t[dstring] casingDStringMap;
dstring casingText;

struct CasingDiced {
    ushort lowerOffset, lowerEnd;
    ushort titleOffset, titleEnd;
    ushort upperOffset, upperEnd;
}

void intern() {
    foreach(character, entry; UnicodeData.entries) {
        if(entry.haveSimpleLowercaseMapping && (""d ~ entry.simpleLowercaseMapping) !in casingDStringMap) {
            casingDStringMap[""d ~ entry.simpleLowercaseMapping] = casingText.length;
            casingText ~= entry.simpleLowercaseMapping;
        }

        if(entry.haveSimpleTitlecaseMapping && (""d ~ entry.simpleTitlecaseMapping) !in casingDStringMap) {
            casingDStringMap[""d ~ entry.simpleTitlecaseMapping] = casingText.length;
            casingText ~= entry.simpleTitlecaseMapping;
        }

        if(entry.haveSimpleUppercaseMapping && (""d ~ entry.simpleUppercaseMapping) !in casingDStringMap) {
            casingDStringMap[""d ~ entry.simpleUppercaseMapping] = casingText.length;
            casingText ~= entry.simpleUppercaseMapping;
        }
    }
}

void simplified() {
    ValueRange[] ranges;
    CasingDiced[] casingsDiced;

    foreach(entry; UnicodeData.entries) {
        if(entry.haveSimpleLowercaseMapping || entry.haveSimpleTitlecaseMapping || entry.haveSimpleUppercaseMapping) {
            CasingDiced diced;

            if(entry.haveSimpleLowercaseMapping) {
                diced.lowerOffset = cast(ushort)casingDStringMap[""d ~ entry.simpleLowercaseMapping];
                diced.lowerEnd = cast(ushort)(diced.lowerOffset + (""d ~ entry.simpleLowercaseMapping).length);
            }

            if(entry.haveSimpleTitlecaseMapping) {
                diced.titleOffset = cast(ushort)casingDStringMap[""d ~ entry.simpleTitlecaseMapping];
                diced.titleEnd = cast(ushort)(diced.titleOffset + (""d ~ entry.simpleTitlecaseMapping).length);
            }

            if(entry.haveSimpleUppercaseMapping) {
                diced.upperOffset = cast(ushort)casingDStringMap[""d ~ entry.simpleUppercaseMapping];
                diced.upperEnd = cast(ushort)(diced.upperOffset + (""d ~ entry.simpleUppercaseMapping).length);
            }

            ranges ~= entry.range;
            casingsDiced ~= diced;
        }
    }

    generateReturn(implOutput, "sidero_utf_lut_getSimplifiedCasing3", ranges, casingsDiced);
}

void table() {
    implOutput ~= "static immutable LUT_CasingDString = cast(dstring)x\"";

    foreach(i, dchar c; casingText) {
        implOutput.formattedWrite!"%08X"(c);
    }

    implOutput ~= "\";\n";
}

void wrapper() {
    implOutput ~= "export extern(C) void sidero_utf_lut_getSimplifiedCasing2(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
    implOutput ~= "    Casing* output = cast(Casing*)outputPtr;\n";
    implOutput ~= "    auto sliced = sidero_utf_lut_getSimplifiedCasing3(input);\n";
    implOutput ~= "    if (sliced is null)\n";
    implOutput ~= "        return;\n";
    implOutput ~= "    output.lower = LUT_CasingDString[sliced.lowerOffset .. sliced.lowerEnd];\n";
    implOutput ~= "    output.title = LUT_CasingDString[sliced.titleOffset .. sliced.titleEnd];\n";
    implOutput ~= "    output.upper = LUT_CasingDString[sliced.upperOffset .. sliced.upperEnd];\n";
    implOutput ~= "    if (output.lower.length == 0)\n";
    implOutput ~= "        output.lower = null;\n";
    implOutput ~= "    if (output.title.length == 0)\n";
    implOutput ~= "        output.title = null;\n";
    implOutput ~= "    if (output.upper.length == 0)\n";
    implOutput ~= "        output.upper = null;\n";
    implOutput ~= "}\n";

    apiOutput ~= "\n";
    apiOutput ~= "/// Get simplified casing for character.\n";
    apiOutput ~= "/// Returns: non-null for a given entry if changed from input character.\n";
    apiOutput ~= "export immutable(SpecialCasing) sidero_utf_lut_getSimplifiedCasing(dchar input) @trusted nothrow @nogc pure {\n";
    apiOutput ~= "    SpecialCasing ret;\n";
    apiOutput ~= "    sidero_utf_lut_getSimplifiedCasing2(input, &ret);\n";
    apiOutput ~= "    return cast(immutable)ret;\n";
    apiOutput ~= "}\n";

    apiOutput ~= "export extern(C) void sidero_utf_lut_getSimplifiedCasing2(dchar input, void*) @trusted nothrow @nogc pure;\n";
}

void isCased() {
    ValueRanges ranges;

    foreach(entry; UnicodeData.entries) {
        switch(entry.generalCategory) {
            case GeneralCategory.Lt:
            case GeneralCategory.Ll:
            case GeneralCategory.Lu:
                break;

                default:
                continue;
        }

        ranges.ranges ~= entry.range;
    }

    // TODO
}
