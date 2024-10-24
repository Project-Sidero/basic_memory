module generators.unicode.unicodedata.casing;
import generators.unicode.unicodedata.common;
import constants;
import utilities.sequential_ranges;
import utilities.inverselist;
import std.file : write;
import std.array : appender;

void Casing() {
    import std.format : formattedWrite;

    auto internalCa = appender!string();
    internalCa ~= "module sidero.base.internal.unicode.unicodedataCa;\n\n";
    internalCa ~= "// Generated do not modify\n";

    size_t[dstring] casingDStringMap;
    dstring casingText;

    {

        foreach(character, entry; state.entries) {
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

    {
        ValueRange!dchar[] ranges;
        CasingDiced[] casingsDiced;

        foreach(entry; state.entries) {
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

        generateTupleReturn(internalCa, "sidero_utf_lut_getSimplifiedCasing3", ranges, casingsDiced);
    }

    {
        internalCa ~= "export extern(C) void sidero_utf_lut_getSimplifiedCasing2(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
        internalCa ~= "    Casing* output = cast(Casing*)outputPtr;\n";
        internalCa ~= "    auto sliced = sidero_utf_lut_getSimplifiedCasing3(input);\n";
        internalCa ~= "    if (sliced is null)\n";
        internalCa ~= "        return;\n";
        internalCa ~= "    output.lower = LUT_CasingDString[sliced.lowerOffset .. sliced.lowerEnd];\n";
        internalCa ~= "    output.title = LUT_CasingDString[sliced.titleOffset .. sliced.titleEnd];\n";
        internalCa ~= "    output.upper = LUT_CasingDString[sliced.upperOffset .. sliced.upperEnd];\n";
        internalCa ~= "    if (output.lower.length == 0)\n";
        internalCa ~= "        output.lower = null;\n";
        internalCa ~= "    if (output.title.length == 0)\n";
        internalCa ~= "        output.title = null;\n";
        internalCa ~= "    if (output.upper.length == 0)\n";
        internalCa ~= "        output.upper = null;\n";
        internalCa ~= "}\n";

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

    {
        internalCa ~= "static immutable LUT_CasingDString = cast(dstring)x\"";

        foreach(i, dchar c; casingText) {
            internalCa.formattedWrite!"%08X"(c);
        }

        internalCa ~= "\";\n";
    }

    {
        internalCa ~= q{
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
    }

    write(UnicodeLUTDirectory ~ "unicodedataCa.d", internalCa.data);
}

struct CasingDiced {
    ushort lowerOffset, lowerEnd;
    ushort titleOffset, titleEnd;
    ushort upperOffset, upperEnd;
}
