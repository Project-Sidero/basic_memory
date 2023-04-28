module generators.unicode.unicodedata.casing;
import generators.unicode.unicodedata.common;
import generators.constants;
import utilities.sequential_ranges;
import utilities.lut;
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

        foreach (character, entry; state.entries) {
            if (entry.haveSimpleLowercaseMapping && (""d ~ entry.simpleLowercaseMapping) !in casingDStringMap) {
                casingDStringMap[""d ~ entry.simpleLowercaseMapping] = casingText.length;
                casingText ~= entry.simpleLowercaseMapping;
            }

            if (entry.haveSimpleTitlecaseMapping && (""d ~ entry.simpleTitlecaseMapping) !in casingDStringMap) {
                casingDStringMap[""d ~ entry.simpleTitlecaseMapping] = casingText.length;
                casingText ~= entry.simpleTitlecaseMapping;
            }

            if (entry.haveSimpleUppercaseMapping && (""d ~ entry.simpleUppercaseMapping) !in casingDStringMap) {
                casingDStringMap[""d ~ entry.simpleUppercaseMapping] = casingText.length;
                casingText ~= entry.simpleUppercaseMapping;
            }
        }
    }

    {
        SequentialRanges!(CasingDiced, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            if (entry.haveSimpleLowercaseMapping || entry.haveSimpleTitlecaseMapping || entry.haveSimpleUppercaseMapping) {
                CasingDiced diced;

                if (entry.haveSimpleLowercaseMapping) {
                    diced.lowerOffset = cast(ushort)casingDStringMap[""d ~ entry.simpleLowercaseMapping];
                    diced.lowerEnd = cast(ushort)(diced.lowerOffset + (""d ~ entry.simpleLowercaseMapping).length);
                }

                if (entry.haveSimpleTitlecaseMapping) {
                    diced.titleOffset = cast(ushort)casingDStringMap[""d ~ entry.simpleTitlecaseMapping];
                    diced.titleEnd = cast(ushort)(diced.titleOffset + (""d ~ entry.simpleTitlecaseMapping).length);
                }

                if (entry.haveSimpleUppercaseMapping) {
                    diced.upperOffset = cast(ushort)casingDStringMap[""d ~ entry.simpleUppercaseMapping];
                    diced.upperEnd = cast(ushort)(diced.upperOffset + (""d ~ entry.simpleUppercaseMapping).length);
                }

                foreach (c; entry.range.start .. entry.range.end + 1)
                    sr.add(cast(dchar)c, diced);
            }
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

        LookupTableGenerator!(CasingDiced, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "void*";
        lut.name = "sidero_utf_lut_getSimplifiedCasing3";
        lut.typeToReplacedName["CasingDiced"] = "Ca";

        auto gotDcode = lut.build();
        internalCa ~= gotDcode[1];
    }

    {
        internalCa ~= "export extern(C) void sidero_utf_lut_getSimplifiedCasing2(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
        internalCa ~= "    Casing* output = cast(Casing*)outputPtr;\n";
        internalCa ~= "    auto sliced = cast(CasingDiced*)sidero_utf_lut_getSimplifiedCasing3(input);\n";
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
        internalCa ~= "static immutable dstring LUT_CasingDString = cast(dstring)[";

        foreach(i, dchar c; casingText) {
            if (i > 0)
                internalCa ~= ", ";
            internalCa.formattedWrite!"0x%X"(c);
        }

        internalCa ~= "];\n\n";
    }

    {
        internalCa ~= q{
alias Ca = CasingDiced;

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

    version(none) {
        SequentialRanges!(SimplifiedCasing, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            SimplifiedCasing casing;

            if (entry.haveSimpleLowercaseMapping)
                casing.lowercase = ""d ~ entry.simpleLowercaseMapping;
            if (entry.haveSimpleTitlecaseMapping)
                casing.titlecase = ""d ~ entry.simpleTitlecaseMapping;
            if (entry.haveSimpleUppercaseMapping)
                casing.uppercase = ""d ~ entry.simpleUppercaseMapping;

            if (entry.haveSimpleLowercaseMapping || entry.haveSimpleTitlecaseMapping || entry.haveSimpleUppercaseMapping) {
                foreach (c; entry.range.start .. entry.range.end + 1)
                    sr.add(cast(dchar)c, casing);
            }
        }

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(SimplifiedCasing, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "void*";
        lut.name = "sidero_utf_lut_getSimplifiedCasing2";
        lut.typeToReplacedName["SimplifiedCasing"] = "Ca";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Get simplified casing for character.\n";
        apiOutput ~= "/// Returns: non-null for a given entry if changed from input character.\n";
        apiOutput ~= "export immutable(SpecialCasing) sidero_utf_lut_getSimplifiedCasing(dchar input) @trusted nothrow @nogc pure {\n";
        apiOutput ~= "    auto got = sidero_utf_lut_getSimplifiedCasing2(input);\n";
        apiOutput ~= "    if (got is null) return typeof(return).init;\n";
        apiOutput ~= "    return *cast(immutable(SpecialCasing*)) got;\n";
        apiOutput ~= "}\n";
        apiOutput ~= gotDcode[0];

        internalCa ~= gotDcode[1];
        internalCa ~= q{
alias Ca = Casing;

struct Casing {
    dstring lower, title, upper;
    ubyte condition;
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
