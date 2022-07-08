module generators.unicode.unicodedata;
import generators.unicode.compositionexclusions;

void unicodeData() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText("unicode-14/UnicodeData.txt"), state);
    fullyDecompose(state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.unicodedata;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    foreach (tag; __traits(allMembers, CompatibilityFormattingTag)) {
        SequentialRanges!(dstring, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            if (entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                foreach (dchar c; entry.range.start .. entry.range.end + 1)
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

        api ~= "\n";
        api ~= "/// Lookup decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    foreach (tag; __traits(allMembers, CompatibilityFormattingTag)) {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            if (entry.compatibilityTag == __traits(getMember, CompatibilityFormattingTag, tag) && entry.decompositionMapping.length > 0) {
                foreach (dchar c; entry.range.start .. entry.range.end + 1)
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

        api ~= "\n";
        api ~= "/// Lookup length of decomposition mapping for character if in compatibility formatting tag " ~ tag ~ ".\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(dstring, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            if (entry.compatibilityTag != CompatibilityFormattingTag.None) {
                foreach (dchar c; entry.range.start .. entry.range.end + 1)
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

        api ~= "\n";
        api ~= "/// Lookup decomposition mapping for character if compatibility.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            if (entry.compatibilityTag != CompatibilityFormattingTag.None) {
                foreach (dchar c; entry.range.start .. entry.range.end + 1)
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

        api ~= "\n";
        api ~= "/// Lookup length of decomposition mapping for character if compatibility.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
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

        api ~= "\n";
        api ~= "/// Get decomposition map for character.\n";
        api ~= "/// Returns: null if unchanged.\n";
        api ~= "export immutable(DecompositionMapping) sidero_utf_lut_getDecompositionMap(dchar input) @trusted nothrow @nogc pure {\n";
        api ~= "    auto got = sidero_utf_lut_getDecompositionMap2(input);\n";
        api ~= "    if (got is null) return typeof(return).init;\n";
        api ~= "    return *cast(immutable(DecompositionMapping*)) got;\n";
        api ~= "}\n";
        api ~= gotDcode[0];

        version (none) {
            api ~= "shared static this() {\n";
            api ~= "    assert(sidero_utf_lut_getDecompositionMap(0xF96B).decomposed == \"\\u53C3\"d);\n";
            api ~= "}\n";
        }

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(size_t, SequentialRangeSplitGroup, 2) sr;

        foreach (character, entry; state.decompositonMappings)
            sr.add(character, entry.fullyDecomposed.length);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose();
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerJoinIfEndIsStart(0, 16);
        sr.layerByRangeMax(1, ushort.max / 2);
        sr.layerJoinIfEndIsStart(1, 64);

        LookupTableGenerator!(size_t, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "size_t";
        lut.name = "sidero_utf_lut_lengthOfFullyDecomposed";
        lut.defaultReturn = "1";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Get length of fully decomposed for character.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(dchar, SequentialRangeSplitGroup, 2, ulong) sr;

        CompositionCanonical: foreach (character, entry; state.decompositonMappings) {
            if (entry.decomposed.length != 2 || entry.tag != CompatibilityFormattingTag.None)
                continue;

            foreach (ex; compositionExclusionRanges) {
                if (ex.within(character))
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

        api ~= "\n";
        api ~= "/// Get composition for character pair.\n";
        api ~= "/// Returns: dchar.init if not set.\n";
        api ~= "export dchar sidero_utf_lut_getCompositionCanonical(dchar L, dchar C) @trusted nothrow @nogc pure {\n";
        api ~= "    ulong temp = C;\n";
        api ~= "    temp <<= 32;\n";
        api ~= "    temp |= L;\n";
        api ~= "    return sidero_utf_lut_getCompositionCanonical2(temp);\n";
        api ~= "}\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(dchar, SequentialRangeSplitGroup, 2, ulong) sr;

        CompositionCompatibility: foreach (character, entry; state.decompositonMappings) {
            if (entry.decomposed.length != 2)
                continue;

            foreach (ex; compositionExclusionRanges) {
                if (ex.within(character))
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

        api ~= "\n";
        api ~= "/// Get composition for character pair.\n";
        api ~= "/// Returns: dchar.init if not set.\n";
        api ~= "export dchar sidero_utf_lut_getCompositionCompatibility(dchar L, dchar C) @trusted nothrow @nogc pure {\n";
        api ~= "    ulong temp = C;\n";
        api ~= "    temp <<= 32;\n";
        api ~= "    temp |= L;\n";
        api ~= "    return sidero_utf_lut_getCompositionCompatibility2(temp);\n";
        api ~= "}\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        api ~= "\n";
        api ~= "/// Lookup decomposition mapping for character if canonical.\n";
        api ~= "alias sidero_utf_lut_getDecompositionMappingCanonical = sidero_utf_lut_getDecompositionMappingNone;\n";

        api ~= "\n";
        api ~= "/// Lookup decomposition mapping length for character if canonical.\n";
        api ~= "alias sidero_utf_lut_lengthOfDecompositionMappingCanonical = sidero_utf_lut_lengthOfDecompositionMappingNone;\n";
    }

    {
        api ~= "\n";
        api ~= "/// Lookup decomposition mapping for character given the compatibility formatting tag.\n";
        api ~= "export dstring sidero_utf_lut_getDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {\n";
        api ~= "    final switch(tag) {\n";
        foreach (tag; __traits(allMembers, CompatibilityFormattingTag)) {
            api ~= "        case CompatibilityFormattingTag." ~ tag ~ ":\n";
            api ~= "            return sidero_utf_lut_getDecompositionMapping" ~ tag ~ "(input);\n";
        }
        api ~= "    }\n";
        api ~= "}\n";
    }

    {
        api ~= "\n";
        api ~= "/// Lookup length of decomposition mapping for character given the compatibility formatting tag.\n";
        api ~= "export ubyte sidero_utf_lut_lengthOfDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {\n";
        api ~= "    final switch(tag) {\n";
        foreach (tag; __traits(allMembers, CompatibilityFormattingTag)) {
            api ~= "        case CompatibilityFormattingTag." ~ tag ~ ":\n";
            api ~= "            return sidero_utf_lut_lengthOfDecompositionMapping" ~ tag ~ "(input);\n";
        }
        api ~= "    }\n";
        api ~= "}\n";
    }

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            foreach (c; entry.range.start .. entry.range.end + 1)
                sr.add(cast(dchar)c, cast(ubyte)entry.canonicalCombiningClass);
        }

        sr.calculateTrueSpread;
        sr.joinWhenClose(null, 5, 32);
        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose(null, 5, 32);
        sr.calculateTrueSpread;
        sr.layerBySingleMulti(0);
        sr.layerJoinIfEndIsStart(0, 1);
        sr.layerByRangeMax(1, ushort.max / 8);

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_getCCC";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup CCC for character.\n";
        api ~= "/// Returns: 0 if not set.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
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

        api ~= "\n";
        api ~= "/// Get simplified casing for character.\n";
        api ~= "/// Returns: non-null for a given entry if changed from input character.\n";
        api ~= "export immutable(SpecialCasing) sidero_utf_lut_getSimplifiedCasing(dchar input) @trusted nothrow @nogc pure {\n";
        api ~= "    auto got = sidero_utf_lut_getSimplifiedCasing2(input);\n";
        api ~= "    if (got is null) return typeof(return).init;\n";
        api ~= "    return *cast(immutable(SpecialCasing*)) got;\n";
        api ~= "}\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
        internal ~= q{
alias Ca = Casing;

struct Casing {
    dstring lower, title, upper;
    ubyte condition;
}
};
    }

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.entries) {
            foreach (c; entry.range.start .. entry.range.end + 1)
                sr.add(cast(dchar)c, cast(ubyte)entry.generalCategory);
        }

        sr.calculateTrueSpread;
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
        lut.externType = "GeneralCategory";
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_getGeneralCategory";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup general category for character.\n";
        api ~= gotDcode[0];

        api ~= q{
/// Is character graphical?
export bool isUnicodeGraphical(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.L:
        case GeneralCategory.M:
        case GeneralCategory.N:
        case GeneralCategory.P:
        case GeneralCategory.S:
        case GeneralCategory.Zs:
            return true;

        default:
            return false;
    }
}

/// Is character a control?
export bool isUnicodeControl(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Cc:
            return true;

        default:
            return false;
    }
}

/// Is character a alpha?
export bool isUnicodeAlpha(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lu:
        case GeneralCategory.Ll:
        case GeneralCategory.Lt:
        case GeneralCategory.Lm:
        case GeneralCategory.Lo:
            return true;

        default:
            return false;
    }
}

/// Is character a number?
export bool isUnicodeNumber(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Nd:
        case GeneralCategory.Nl:
        case GeneralCategory.No:
            return true;

        default:
            return false;
    }
}

/// Is character a alpha or number?
export bool isUnicodeAlphaOrNumber(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lu:
        case GeneralCategory.Ll:
        case GeneralCategory.Lt:
        case GeneralCategory.Lm:
        case GeneralCategory.Lo:
        case GeneralCategory.Nd:
        case GeneralCategory.Nl:
        case GeneralCategory.No:
            return true;

        default:
            return false;
    }
}

/// Is character uppercase?
export bool isUnicodeUpper(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lu:
            return true;

        default:
            return false;
    }
}

/// Is character lowercase?
export bool isUnicodeLower(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Ll:
            return true;

        default:
            return false;
    }
}

/// Is character titlecase?
export bool isUnicodeTitle(dchar input) @safe nothrow @nogc pure {
    GeneralCategory got = sidero_utf_lut_getGeneralCategory(input);

    switch(got) {
        case GeneralCategory.Lt:
            return true;

        default:
            return false;
    }
}
};

        internal ~= gotDcode[1];
    }

    {
        internal ~= q{
enum CFT {
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
};

    }

    append("generated/sidero/base/text/unicode/database.d", api.data);
    write("generated/sidero/base/internal/unicode/unicodedata.d", internal.data);
}

/*
compatibility mappings have a formatting tag
canonical does not have a formatting tag

If a decomposition mapping (codepoints) are empty or its the original codepoint, than it is equivalent to the original codepoint and ignored

canonical mappings maybe have decomposition mappings
*/

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter, startsWith, endsWith;
    import std.string : strip, lineSplitter;
    import std.conv : parse;
    import std.array : split;

    bool expectedRangeEnd, nextRangeEnd;

    foreach (line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        string[] fields = line.split(";");

        foreach (ref field; fields) {
            field = field.strip;
        }

        /+
How first field ranges are specified (the First, Last bit):
3400;<CJK Ideograph Extension A, First>;Lo;0;L;;;;;N;;;;;
4DBF;<CJK Ideograph Extension A, Last>;Lo;0;L;;;;;N;;;;;
+/

        if (fields.length == 0)
            continue;
        else if (fields.length != 15) {
            continue;
        }

        uint character = parse!uint(fields[0], 16);
        string name;

        nextRangeEnd = false;

        if (fields[1].endsWith(">")) {
            bool extractName;

            if (fields[1].endsWith("First>")) {
                nextRangeEnd = true;
                extractName = true;
            } else if (fields[1].endsWith("Last>")) {
                if (!expectedRangeEnd) {
                    continue;
                }

                extractName = true;
            } else if (fields[1] == "<control>") {
                if (expectedRangeEnd) {
                    expectedRangeEnd = false;
                    continue;
                }
            } else {
                continue;
            }

            if (extractName) {
                offset = fields[1].countUntil(',');
                if (offset > 0)
                    name = fields[1][1 .. offset];
            }
        } else if (expectedRangeEnd) {
            continue;
        } else {
            name = fields[1];
        }

        int canonicalCombiningClass = parse!int(fields[3]);

        if (expectedRangeEnd) {
            // use last entry

            state.entries[$ - 1].range.end = character;
            expectedRangeEnd = false;
        } else {
            // create a new entry
            Entry entry;

            entry.range.start = character;
            entry.range.end = character;
            entry.name = name;

            static foreach (GC; __traits(allMembers, GeneralCategory)) {
                if (fields[2] == GC)
                    entry.generalCategory = __traits(getMember, GeneralCategory, GC);
            }

            if (fields[2].length > 0 && entry.generalCategory == GeneralCategory.None)
                assert(0, "Unrecognized general category " ~ fields[2]);

            entry.canonicalCombiningClass = canonicalCombiningClass;
            entry.bidiClass = fields[4];

            if (fields[5].length > 0) {
                // fields[5];
                string map = fields[5], tag = "<>";

                if (map.startsWith('<')) {
                    offset = map.countUntil('>');
                    assert(offset > 0);

                    tag = map[0 .. offset + 1].strip;
                    map = map[offset + 1 .. $].strip;
                }

                switch (tag[1 .. $ - 1]) {
                case "font":
                    entry.compatibilityTag = CompatibilityFormattingTag.Font;
                    break;
                case "noBreak":
                    entry.compatibilityTag = CompatibilityFormattingTag.NoBreak;
                    break;
                case "initial":
                    entry.compatibilityTag = CompatibilityFormattingTag.Initial;
                    break;
                case "medial":
                    entry.compatibilityTag = CompatibilityFormattingTag.Medial;
                    break;
                case "final":
                    entry.compatibilityTag = CompatibilityFormattingTag.Final;
                    break;
                case "isolated":
                    entry.compatibilityTag = CompatibilityFormattingTag.Isolated;
                    break;
                case "circle":
                    entry.compatibilityTag = CompatibilityFormattingTag.Circle;
                    break;
                case "super":
                    entry.compatibilityTag = CompatibilityFormattingTag.Super;
                    break;
                case "sub":
                    entry.compatibilityTag = CompatibilityFormattingTag.Sub;
                    break;
                case "vertical":
                    entry.compatibilityTag = CompatibilityFormattingTag.Vertical;
                    break;
                case "wide":
                    entry.compatibilityTag = CompatibilityFormattingTag.Wide;
                    break;
                case "narrow":
                    entry.compatibilityTag = CompatibilityFormattingTag.Narrow;
                    break;
                case "small":
                    entry.compatibilityTag = CompatibilityFormattingTag.Small;
                    break;
                case "square":
                    entry.compatibilityTag = CompatibilityFormattingTag.Square;
                    break;
                case "fraction":
                    entry.compatibilityTag = CompatibilityFormattingTag.Fraction;
                    break;
                case "compat":
                    entry.compatibilityTag = CompatibilityFormattingTag.Compat;
                    break;
                default:
                    assert(tag.length < 3);
                    entry.compatibilityTag = CompatibilityFormattingTag.None;
                    break;
                }

                foreach (v; map.splitter(" ")) {
                    v = v.strip;
                    entry.decompositionMapping ~= parse!uint(v, 16);
                    assert(v.length == 0);
                }
            }

            if (fields[6].length > 0) {
                entry.isDecimal = true;
                entry.numericValueNumerator = parse!int(fields[6]);
                entry.numericValueDenominator = 1;
            } else if (fields[7].length > 0) {
                entry.isDigit = true;
                entry.numericValueNumerator = parse!int(fields[7]);
                entry.numericValueDenominator = 1;
            } else if (fields[8].length > 0) {
                entry.isNumeric = true;
                string[] field8 = fields[8].split("/");

                if (field8.length == 2) {
                    entry.numericValueNumerator = parse!int(field8[0]);
                    entry.numericValueDenominator = parse!int(field8[1]);
                } else if (field8.length == 1) {
                    entry.numericValueNumerator = parse!long(field8[0]);
                    entry.numericValueDenominator = 1;
                } else
                    assert(0);
            }

            if (fields[9] == "Y")
                entry.bidiMirrored = true;

            if (fields[12].length > 0)
                entry.simpleUppercaseMapping = parse!int(fields[12], 16);
            if (fields[13].length > 0)
                entry.simpleLowercaseMapping = parse!int(fields[13], 16);
            if (fields[14].length > 0)
                entry.simpleTitlecaseMapping = parse!int(fields[14], 16);
            else
                entry.simpleTitlecaseMapping = entry.simpleUppercaseMapping;

            state.entries ~= entry;
            expectedRangeEnd = nextRangeEnd;
        }
    }
}

void fullyDecompose(ref TotalState state) {
    foreach (entry; state.entries) {
        if (entry.decompositionMapping.length > 0) {
            foreach (v; entry.range.start .. entry.range.end + 1) {
                if (entry.compatibilityTag == CompatibilityFormattingTag.None)
                    state.decompositionMaps[v] = entry.decompositionMapping;
                else
                    state.decompositionMapsCompatibility[v] = entry.decompositionMapping;
            }
        }
    }

    foreach (entry; state.entries) {
        DecompositionMapping value;
        value.tag = entry.compatibilityTag;
        value.decomposed = entry.decompositionMapping;

        const canonical = entry.compatibilityTag == CompatibilityFormattingTag.None;

        {
            dstring last = value.decomposed;

            for (;;) {
                dstring temp;
                temp.reserve = last.length;

                foreach (dchar c; last) {
                    if (canonical) {
                        if (c in state.decompositionMaps) {
                            temp ~= state.decompositionMaps[c];
                            continue;
                        }
                    } else {
                        if (c in state.decompositionMapsCompatibility) {
                            temp ~= state.decompositionMapsCompatibility[c];
                            continue;
                        } else if (c in state.decompositionMaps) {
                            temp ~= state.decompositionMaps[c];
                            continue;
                        }
                    }

                    temp ~= c;
                }

                if (temp == last)
                    break;

                value.fullyDecomposed = temp;
                last = temp;
            }
        }

        if (value.fullyDecomposed.length == 0)
            value.fullyDecomposed = value.decomposed;

        if (canonical) {
            dstring last = value.decomposed;

            for (;;) {
                dstring temp;
                temp.reserve = last.length;

                foreach (dchar c; last) {
                    if (c in state.decompositionMapsCompatibility) {
                        temp ~= state.decompositionMapsCompatibility[c];
                        continue;
                    } else if (c in state.decompositionMaps) {
                        temp ~= state.decompositionMaps[c];
                        continue;
                    } else
                        temp ~= c;
                }

                if (temp == last)
                    break;

                value.fullyDecomposedCompatibility = temp;
                last = temp;
            }

            if (value.fullyDecomposedCompatibility.length == 0)
                value.fullyDecomposedCompatibility = value.decomposed;
        } else {
            value.fullyDecomposedCompatibility = value.fullyDecomposed;
        }

        if (value.decomposed.length > 0) {
            foreach (dchar c; entry.range.start .. entry.range.end + 1)
                state.decompositonMappings[c] = value;
        }
    }
}

struct Entry {
@safe:

    ValueRange!dchar range;
    string name;
    GeneralCategory generalCategory;

    // DerivedCombiningClass.txt
    int canonicalCombiningClass;

    // DerivedBidiClass.txt
    string bidiClass;

    CompatibilityFormattingTag compatibilityTag;
    dstring decompositionMapping;

    bool isDecimal, isDigit, isNumeric;
    long numericValueNumerator, numericValueDenominator;

    bool bidiMirrored;

    // ignore
    // ignore

    dchar simpleUppercaseMapping;
    dchar simpleLowercaseMapping;
    dchar simpleTitlecaseMapping;

    bool haveSimpleUppercaseMapping() {
        return simpleUppercaseMapping != dchar.init;
    }

    bool haveSimpleLowercaseMapping() {
        return simpleLowercaseMapping != dchar.init;
    }

    bool haveSimpleTitlecaseMapping() {
        return simpleTitlecaseMapping != dchar.init;
    }
}

struct TotalState {
    Entry[] entries;

    dstring[dchar] decompositionMaps, decompositionMapsCompatibility;
    DecompositionMapping[dchar] decompositonMappings;
}

enum GeneralCategory {
    None, ///
    Lu, ///
    Ll, ///
    Lt, ///
    LC, ///
    Lm, ///
    Lo, ///
    L, ///
    Mn, ///
    Mc, ///
    Me, ///
    M, ///
    Nd, ///
    Nl, ///
    No, ///
    N, ///
    Pc, ///
    Pd, ///
    Ps, ///
    Pe, ///
    Pi, ///
    Pf, ///
    Po, ///
    P, ///
    Sm, ///
    Sc, ///
    Sk, ///
    So, ///
    S, ///
    Zs, ///
    Zl, ///
    Zp, ///
    Z, ///
    Cc, ///
    Cf, ///
    Cs, ///
    Co, ///
    Cn, ///
    C, ///
}

enum BidiClass {
    None, ///
    L, ///
    R, ///
    AL, ///
    EN, ///
    ES, ///
    ET, ///
    AN, ///
    CS, ///
    NSM, ///
    BN, ///
    B, ///
    S, ///
    WS, ///
    ON, ///
    LRE, ///
    LRO, ///
    RLE, ///
    RLO, ///
    PDF, ///
    LRI, ///
    RLI, ///
    FSI, ///
    PDI, ///
}

enum CompatibilityFormattingTag {
    None, ///
    Font, ///
    NoBreak, ///
    Initial, ///
    Medial, ///
    Final, ///
    Isolated, ///
    Circle, ///
    Super, ///
    Sub, ///
    Vertical, ///
    Wide, ///
    Narrow, ///
    Small, ///
    Square, ///
    Fraction, ///
    Compat, ///
}

struct DecompositionMapping {
    CompatibilityFormattingTag tag;
    dstring decomposed;
    dstring fullyDecomposed, fullyDecomposedCompatibility;
}

struct SimplifiedCasing {
    dstring lowercase, titlecase, uppercase;
}
