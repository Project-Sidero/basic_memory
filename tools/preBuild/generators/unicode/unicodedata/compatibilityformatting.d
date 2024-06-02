module generators.unicode.unicodedata.compatibilityformatting;
import generators.unicode.unicodedata.common;
import constants;
import utilities.sequential_ranges;
import utilities.lut;
import std.file : write;
import std.array : appender;

void compatibilityFormatting() {
    import std.format : formattedWrite;

    auto internalCF = appender!string();
    internalCF ~= "module sidero.base.internal.unicode.unicodedataCF;\n\n";
    internalCF ~= "// Generated do not modify\n";

    size_t[dstring] decompositionDStringMap;
    dstring decompositionText;

    {
        foreach(entry; state.entries) {
            if(entry.decompositionMapping !in decompositionDStringMap) {
                decompositionDStringMap[entry.decompositionMapping] = decompositionText.length;
                decompositionText ~= entry.decompositionMapping;
            }
        }
    }

    {
        foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
            SequentialRanges!(SliceDiced, SequentialRangeSplitGroup, 2) sr;

            foreach(entry; state.entries) {
                if(entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                    foreach(dchar c; entry.range.start .. entry.range.end + 1) {
                        SliceDiced diced;
                        diced.offset = cast(ushort)decompositionDStringMap[entry.decompositionMapping];
                        diced.end = cast(ushort)(diced.offset + entry.decompositionMapping.length);
                        sr.add(c, diced);
                    }
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

            LookupTableGenerator!(SliceDiced, SequentialRangeSplitGroup, 2) lut;
            lut.sr = sr;
            lut.lutType = "void*";
            lut.name = "sidero_utf_lut_getDecompositionMapping2" ~ tag;
            lut.typeToReplacedName["SliceDiced"] = "SD";

            auto gotDcode = lut.build();
            internalCF ~= gotDcode[1];

            internalCF ~= "export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMapping" ~ tag ~
                "(dchar input) @trusted nothrow @nogc pure {\n";
            internalCF ~= "    SliceDiced* got = cast(SliceDiced*)sidero_utf_lut_getDecompositionMapping2" ~ tag ~ "(input);\n";
            internalCF ~= "    if (got is null || got.end == 0)\n";
            internalCF ~= "        return null;\n";
            internalCF ~= "    return LUT_DecompositionFMappingDString[got.offset .. got.end];\n";
            internalCF ~= "}\n";

            apiOutput ~= "\n";
            apiOutput ~= "/// Lookup decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
            apiOutput ~= "export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMapping" ~ tag ~
                "(dchar input) @trusted nothrow @nogc pure;\n";
        }
    }

    {
        SequentialRanges!(SliceDiced, SequentialRangeSplitGroup, 2) sr;

        foreach(entry; state.entries) {
            if(entry.compatibilityTag != CompatibilityFormattingTag.None) {
                foreach(dchar c; entry.range.start .. entry.range.end + 1) {
                    SliceDiced diced;
                    diced.offset = cast(ushort)decompositionDStringMap[entry.decompositionMapping];
                    diced.end = cast(ushort)(diced.offset + entry.decompositionMapping.length);
                    sr.add(c, diced);
                }
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

        LookupTableGenerator!(SliceDiced, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "void*";
        lut.name = "sidero_utf_lut_getDecompositionMappingCompatibility2";
        lut.typeToReplacedName["SliceDiced"] = "SD";

        auto gotDcode = lut.build();
        internalCF ~= gotDcode[1];

        internalCF ~= "export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCompatibility(dchar input) @trusted nothrow @nogc pure {\n";
        internalCF ~= "    SliceDiced* got = cast(SliceDiced*)sidero_utf_lut_getDecompositionMappingCompatibility2(input);\n";
        internalCF ~= "    if (got is null || got.end == 0)\n";
        internalCF ~= "        return null;\n";
        internalCF ~= "    return LUT_DecompositionFMappingDString[got.offset .. got.end];\n";
        internalCF ~= "}\n";

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup decomposition mapping for character if compatibility.\n";
        apiOutput ~= "export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCompatibility(dchar input) @trusted nothrow @nogc pure;\n";
    }

    {
        internalCF ~= "static immutable dstring LUT_DecompositionFMappingDString = cast(dstring)[";

        foreach(i, dchar c; decompositionText) {
            if(i > 0)
                internalCF ~= ", ";
            internalCF.formattedWrite!"0x%X"(c);
        }

        internalCF ~= "];\n\n";
    }

    version(none) {
        {
            foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
                SequentialRanges!(dstring, SequentialRangeSplitGroup, 2) sr;

                foreach(entry; state.entries) {
                    if(entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) &&
                            entry.decompositionMapping.length > 0) {
                        foreach(dchar c; entry.range.start .. entry.range.end + 1)
                            sr.add(c, entry.decompositionMapping);
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

                LookupTableGenerator!(dstring, SequentialRangeSplitGroup, 2) lut;
                lut.sr = sr;
                lut.lutType = "dstring";
                lut.name = "sidero_utf_lut_getDecompositionMapping" ~ tag;

                auto gotDcode = lut.build();

                apiOutput ~= "\n";
                apiOutput ~= "/// Lookup decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
                apiOutput ~= gotDcode[0];

                internalCF ~= gotDcode[1];
            }
        }

        {
            SequentialRanges!(dstring, SequentialRangeSplitGroup, 2) sr;

            foreach(entry; state.entries) {
                if(entry.compatibilityTag != CompatibilityFormattingTag.None) {
                    foreach(dchar c; entry.range.start .. entry.range.end + 1)
                        sr.add(c, entry.decompositionMapping);
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

            LookupTableGenerator!(dstring, SequentialRangeSplitGroup, 2) lut;
            lut.sr = sr;
            lut.lutType = "dstring";
            lut.name = "sidero_utf_lut_getDecompositionMappingCompatibility";

            auto gotDcode = lut.build();

            apiOutput ~= "\n";
            apiOutput ~= "/// Lookup decomposition mapping for character if compatibility.\n";
            apiOutput ~= gotDcode[0];

            internalCF ~= gotDcode[1];
        }
    }

    foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach(entry; state.entries) {
            if(entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                foreach(dchar c; entry.range.start .. entry.range.end + 1)
                    sr.add(c, cast(ubyte)entry.decompositionMapping.length);
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

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_lengthOfDecompositionMapping" ~ tag;

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup length of decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
        apiOutput ~= gotDcode[0];

        internalCF ~= gotDcode[1];
    }

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach(entry; state.entries) {
            if(entry.compatibilityTag != CompatibilityFormattingTag.None) {
                foreach(dchar c; entry.range.start .. entry.range.end + 1)
                    sr.add(c, cast(ubyte)entry.decompositionMapping.length);
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

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_lengthOfDecompositionMappingCompatibility";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup length of decomposition mapping for character if compatibility.\n";
        apiOutput ~= gotDcode[0];

        internalCF ~= gotDcode[1];
    }

    internalCF ~= q{
alias SD = SliceDiced;

struct SliceDiced {
    ushort offset, end;
}
};

    write(UnicodeLUTDirectory ~ "unicodedataCF.d", internalCF.data);
}

struct SliceDiced {
    ushort offset, end;
}
