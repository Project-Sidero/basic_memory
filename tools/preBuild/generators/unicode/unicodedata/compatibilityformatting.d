module generators.unicode.unicodedata.compatibilityformatting;
import generators.unicode.unicodedata.common;
import constants;
import std.file : write;
import std.array : appender;

void compatibilityFormatting() {
    import std.format : formattedWrite;

    auto internalCF = appender!string();
    internalCF ~= "module sidero.base.internal.unicode.unicodedataCF;\n";
    internalCF ~= "// Generated do not modify\n\n";

    {
        foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
            ValueRange[] ranges;
            dstring[] decompositions;

            foreach(entry; state.entries) {
                if(entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                    if(ranges.length == 0) {
                        ranges ~= entry.range;
                        decompositions ~= entry.decompositionMapping;
                    } else if(ranges[$ - 1].end + 1 == entry.range.start && decompositions[$ - 1] == entry.decompositionMapping) {
                        ranges[$ - 1].end = entry.range.end;
                    } else {
                        ranges ~= entry.range;
                        decompositions ~= entry.decompositionMapping;
                    }
                }
            }

            apiOutput ~= "\n";
            apiOutput ~= "/// Lookup decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
            generateReturn(apiOutput, internalCF, "sidero_utf_lut_getDecompositionMapping" ~ tag, ranges, decompositions);
        }
    }

    {
        ValueRange[] ranges;
        dstring[] decompositions;

        foreach(entry; state.entries) {
            if(entry.compatibilityTag != CompatibilityFormattingTag.None && entry.decompositionMapping.length > 0) {
                if(ranges.length == 0) {
                    ranges ~= entry.range;
                    decompositions ~= entry.decompositionMapping;
                } else if(ranges[$ - 1].end + 1 == entry.range.start && decompositions[$ - 1] == entry.decompositionMapping) {
                    ranges[$ - 1].end = entry.range.end;
                } else {
                    ranges ~= entry.range;
                    decompositions ~= entry.decompositionMapping;
                }
            }
        }

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup decomposition mapping for character if compatibility.\n";
        generateReturn(apiOutput, internalCF, "sidero_utf_lut_getDecompositionMappingCompatibility", ranges, decompositions);
    }

    foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
        ValueRange[] ranges;
        ubyte[] lengths;

        foreach(entry; state.entries) {
            if(entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                if(ranges.length == 0) {
                    ranges ~= entry.range;
                    lengths ~= cast(ubyte)entry.decompositionMapping.length;
                } else if(ranges[$ - 1].end + 1 == entry.range.start && lengths[$ - 1] == entry.decompositionMapping.length) {
                    ranges[$ - 1].end = entry.range.end;
                } else {
                    ranges ~= entry.range;
                    lengths ~= cast(ubyte)entry.decompositionMapping.length;
                }
            }
        }

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup length of decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
        generateReturn(apiOutput, internalCF, "sidero_utf_lut_lengthOfDecompositionMapping" ~ tag, ranges, lengths);
    }

    {
        ValueRange[] ranges;
        ubyte[] lengths;

        foreach(entry; state.entries) {
            if(entry.compatibilityTag != CompatibilityFormattingTag.None && entry.decompositionMapping.length > 0) {
                if(ranges.length == 0) {
                    ranges ~= entry.range;
                    lengths ~= cast(ubyte)entry.decompositionMapping.length;
                } else if(ranges[$ - 1].end + 1 == entry.range.start && lengths[$ - 1] == entry.decompositionMapping.length) {
                    ranges[$ - 1].end = entry.range.end;
                } else {
                    ranges ~= entry.range;
                    lengths ~= cast(ubyte)entry.decompositionMapping.length;
                }
            }
        }

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup length of decomposition mapping for character if compatibility.\n";
        generateReturn(apiOutput, internalCF, "sidero_utf_lut_lengthOfDecompositionMappingCompatibility", ranges, lengths);
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

private:
import utilities.setops;
import utilities.inverselist;
