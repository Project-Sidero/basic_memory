module generators.unicode.data.UnicodeData;
import utilities.setops;

__gshared UnicodeData_State UnicodeData;

struct UnicodeData_State {
    UnicodeData_Entry[] entries;

    dstring[dchar] decompositionMaps, decompositionMapsCompatibility;
    DecompositionMapping[dchar] decompositonMappings;
}

struct UnicodeData_Entry {
@safe:

    ValueRange range;
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

void processUnicodeData(string inputText) {
    import std.algorithm : countUntil, splitter, startsWith, endsWith;
    import std.string : strip, lineSplitter;
    import std.conv : parse;
    import std.array : split;

    bool expectedRangeEnd, nextRangeEnd;

    foreach(line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        string[] fields = line.split(";");

        foreach(ref field; fields) {
            field = field.strip;
        }

        /+
How first field ranges are specified (the First, Last bit):
3400;<CJK Ideograph Extension A, First>;Lo;0;L;;;;;N;;;;;
4DBF;<CJK Ideograph Extension A, Last>;Lo;0;L;;;;;N;;;;;
+/

        if(fields.length == 0)
            continue;
        else if(fields.length != 15) {
            continue;
        }

        uint character = parse!uint(fields[0], 16);
        string name;

        if(fields[1].endsWith(">")) {
            bool extractName;

            if(fields[1].endsWith("First>")) {
                nextRangeEnd = true;
                extractName = true;
            } else if(fields[1].endsWith("Last>")) {
                assert(nextRangeEnd);
                nextRangeEnd = false;
                expectedRangeEnd = true;

                extractName = true;
            } else if(fields[1] == "<control>") {
                if(expectedRangeEnd) {
                    nextRangeEnd = false;
                    expectedRangeEnd = false;
                    continue;
                }
            } else {
                continue;
            }

            if(extractName) {
                offset = fields[1].countUntil(',');
                if(offset > 0)
                    name = fields[1][1 .. offset];
            }
        } else if(expectedRangeEnd) {
            continue;
        } else {
            name = fields[1];
        }

        int canonicalCombiningClass = parse!int(fields[3]);

        if(expectedRangeEnd) {
            // use last entry

            UnicodeData.entries[$ - 1].range.end = character;
            expectedRangeEnd = false;
        } else {
            // create a new entry
            UnicodeData_Entry entry;

            entry.range.start = character;
            entry.range.end = character;
            entry.name = name;

            static foreach(GC; __traits(allMembers, GeneralCategory)) {
                if(fields[2] == GC)
                    entry.generalCategory = __traits(getMember, GeneralCategory, GC);
            }

            if(fields[2].length > 0 && entry.generalCategory == GeneralCategory.None)
                assert(0, "Unrecognized general category " ~ fields[2]);

            entry.canonicalCombiningClass = canonicalCombiningClass;
            entry.bidiClass = fields[4];

            if(fields[5].length > 0) {
                // fields[5];
                string map = fields[5], tag = "<>";

                if(map.startsWith('<')) {
                    offset = map.countUntil('>');
                    assert(offset > 0);

                    tag = map[0 .. offset + 1].strip;
                    map = map[offset + 1 .. $].strip;
                }

                switch(tag[1 .. $ - 1]) {
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

                foreach(v; map.splitter(" ")) {
                    v = v.strip;
                    entry.decompositionMapping ~= parse!uint(v, 16);
                    assert(v.length == 0);
                }
            }

            if(fields[6].length > 0) {
                entry.isDecimal = true;
                entry.numericValueNumerator = parse!int(fields[6]);
                entry.numericValueDenominator = 1;
            } else if(fields[7].length > 0) {
                entry.isDigit = true;
                entry.numericValueNumerator = parse!int(fields[7]);
                entry.numericValueDenominator = 1;
            } else if(fields[8].length > 0) {
                entry.isNumeric = true;
                string[] field8 = fields[8].split("/");

                if(field8.length == 2) {
                    entry.numericValueNumerator = parse!int(field8[0]);
                    entry.numericValueDenominator = parse!int(field8[1]);
                } else if(field8.length == 1) {
                    entry.numericValueNumerator = parse!long(field8[0]);
                    entry.numericValueDenominator = 1;
                } else
                    assert(0);
            }

            if(fields[9] == "Y")
                entry.bidiMirrored = true;

            if(fields[12].length > 0)
                entry.simpleUppercaseMapping = parse!int(fields[12], 16);
            if(fields[13].length > 0)
                entry.simpleLowercaseMapping = parse!int(fields[13], 16);
            if(fields[14].length > 0)
                entry.simpleTitlecaseMapping = parse!int(fields[14], 16);
            else
                entry.simpleTitlecaseMapping = entry.simpleUppercaseMapping;

            UnicodeData.entries ~= entry;
            expectedRangeEnd = nextRangeEnd;
        }
    }

    fullyDecompose;
}

private:

void fullyDecompose() {
    foreach(entry; UnicodeData.entries) {
        if(entry.decompositionMapping.length > 0) {
            foreach(v; entry.range.start .. entry.range.end + 1) {
                if(entry.compatibilityTag == CompatibilityFormattingTag.None)
                    UnicodeData.decompositionMaps[v] = entry.decompositionMapping;
                else
                    UnicodeData.decompositionMapsCompatibility[v] = entry.decompositionMapping;
            }
        }
    }

    foreach(entry; UnicodeData.entries) {
        DecompositionMapping value;
        value.tag = entry.compatibilityTag;
        value.decomposed = entry.decompositionMapping;

        const canonical = entry.compatibilityTag == CompatibilityFormattingTag.None;

        {
            dstring last = value.decomposed;

            for(;;) {
                dstring temp;
                temp.reserve = last.length;

                foreach(dchar c; last) {
                    if(canonical) {
                        if(c in UnicodeData.decompositionMaps) {
                            temp ~= UnicodeData.decompositionMaps[c];
                            continue;
                        }
                    } else {
                        if(c in UnicodeData.decompositionMapsCompatibility) {
                            temp ~= UnicodeData.decompositionMapsCompatibility[c];
                            continue;
                        } else if(c in UnicodeData.decompositionMaps) {
                            temp ~= UnicodeData.decompositionMaps[c];
                            continue;
                        }
                    }

                    temp ~= c;
                }

                if(temp == last)
                    break;

                value.fullyDecomposed = temp;
                last = temp;
            }
        }

        if(value.fullyDecomposed.length == 0)
            value.fullyDecomposed = value.decomposed;

        if(canonical) {
            dstring last = value.decomposed;

            for(;;) {
                dstring temp;
                temp.reserve = last.length;

                foreach(dchar c; last) {
                    if(c in UnicodeData.decompositionMapsCompatibility) {
                        temp ~= UnicodeData.decompositionMapsCompatibility[c];
                        continue;
                    } else if(c in UnicodeData.decompositionMaps) {
                        temp ~= UnicodeData.decompositionMaps[c];
                        continue;
                    } else
                        temp ~= c;
                }

                if(temp == last)
                    break;

                value.fullyDecomposedCompatibility = temp;
                last = temp;
            }

            if(value.fullyDecomposedCompatibility.length == 0)
                value.fullyDecomposedCompatibility = value.decomposed;
        } else {
            value.fullyDecomposedCompatibility = value.fullyDecomposed;
        }

        if(value.decomposed.length > 0) {
            foreach(dchar c; entry.range.start .. entry.range.end + 1)
                UnicodeData.decompositonMappings[c] = value;
        }
    }
}
