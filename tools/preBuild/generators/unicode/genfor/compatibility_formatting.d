module generators.unicode.genfor.compatibility_formatting;
import generators.unicode.data.UnicodeData;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import std.format : formattedWrite;

void genForCompatibilityFormatting() {
    implOutput ~= q{module sidero.base.internal.unicode.unicodedataCF;
// Generated do not modify

alias SD = SliceDiced;

struct SliceDiced {
    ushort offset, end;
}
};

    decompositionForTag;
    decompositionForTag_Compatibility;
    lengthOfDecompositionForTag;
    lengthOfDecompositionForTag_Compatibility;
}

private:

struct SliceDiced {
    ushort offset, end;
}

void decompositionForTag() {
    foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
        ValueRange[] ranges;
        dstring[] decompositions;

        foreach(entry; UnicodeData.entries) {
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
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getDecompositionMapping" ~ tag, ranges, decompositions);
    }
}

void decompositionForTag_Compatibility() {
    ValueRange[] ranges;
    dstring[] decompositions;

    foreach(entry; UnicodeData.entries) {
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
    generateReturn(apiOutput, implOutput, "sidero_utf_lut_getDecompositionMappingCompatibility", ranges, decompositions);
}

void lengthOfDecompositionForTag() {
    foreach(tag; __traits(allMembers, CompatibilityFormattingTag)) {
        ValueRange[] ranges;
        ubyte[] lengths;

        foreach (entry; UnicodeData.entries) {
            if (entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                if (ranges.length == 0) {
                    ranges ~= entry.range;
                    lengths ~= cast(ubyte)entry.decompositionMapping.length;
                } else if (ranges[$ - 1].end + 1 == entry.range.start && lengths[$ - 1] == entry.decompositionMapping.length) {
                    ranges[$ - 1].end = entry.range.end;
                } else {
                    ranges ~= entry.range;
                    lengths ~= cast(ubyte)entry.decompositionMapping.length;
                }
            }
        }

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup length of decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_lengthOfDecompositionMapping" ~ tag, ranges, lengths);
    }
}

void lengthOfDecompositionForTag_Compatibility() {
    ValueRange[] ranges;
    ubyte[] lengths;

    foreach(entry; UnicodeData.entries) {
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
    generateReturn(apiOutput, implOutput, "sidero_utf_lut_lengthOfDecompositionMappingCompatibility", ranges, lengths);
}
