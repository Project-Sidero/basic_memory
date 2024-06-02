module generators.unicode.specialcasing;
import constants;

void specialCasing() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "SpecialCasing.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.specialcasing;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    static foreach(language; __traits(allMembers, Language)) {
        {
            SequentialRanges!(Casing, SequentialRangeSplitGroup, 2) sr;

            foreach(entry; state.range[__traits(getMember, Language, language)]) {
                foreach(c; entry.range.start .. entry.range.end + 1) {
                    Casing casing = entry.casing;
                    if(casing.lowercase.length == 1 && casing.lowercase[0] == c)
                        casing.lowercase = null;
                    if(casing.titlecase.length == 1 && casing.titlecase[0] == c)
                        casing.titlecase = null;
                    if(casing.uppercase.length == 1 && casing.uppercase[0] == c)
                        casing.uppercase = null;
                    sr.add(c, casing);
                }
            }

            foreach(entry; state.single[__traits(getMember, Language, language)]) {
                foreach(c; entry.range.start .. entry.range.end + 1) {
                    Casing casing = entry.casing;
                    if(casing.lowercase.length == 1 && casing.lowercase[0] == c)
                        casing.lowercase = null;
                    if(casing.titlecase.length == 1 && casing.titlecase[0] == c)
                        casing.titlecase = null;
                    if(casing.uppercase.length == 1 && casing.uppercase[0] == c)
                        casing.uppercase = null;
                    sr.add(c, casing);
                }
            }

            sr.splitForSame;
            sr.calculateTrueSpread;
            sr.joinWithDiff(null, 64);
            sr.calculateTrueSpread;
            sr.layerByRangeMax(0, ushort.max / 4);
            sr.layerByRangeMax(1, ushort.max / 2);

            LookupTableGenerator!(Casing, SequentialRangeSplitGroup, 2) lut;
            lut.sr = sr;
            lut.lutType = "void*";
            lut.name = "sidero_utf_lut_getSpecialCasing2" ~ language;
            lut.typeToReplacedName["Casing"] = "Ca";

            auto gotDcode = lut.build();

            api ~= "\n";
            api ~= "/// Get special casing for character.\n";
            api ~= "/// Returns: non-null for a given entry if changed from input character.\n";
            api ~= "export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasing" ~ language ~
                "(dchar input) @trusted nothrow @nogc pure {\n";
            api ~= "    auto got = sidero_utf_lut_getSpecialCasing2" ~ language ~ "(input);\n";
            api ~= "    if (got is null) return typeof(return).init;\n";
            api ~= "    return *cast(immutable(SpecialCasing*)) got;\n";
            api ~= "}\n";
            api ~= gotDcode[0];

            internal ~= gotDcode[1];
        }
    }

    {
        internal ~= q{
alias Ca = Casing;

struct Casing {
    dstring lower, title, upper;
    ubyte condition;
}
};

        api ~= q{
/// Get casing for character in regards to a language or simplified mapping.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasing(dchar input, Language language) @trusted nothrow @nogc pure {
    void* got;

    final switch(language) {
        case Language.Unknown:
            got = cast(void*)sidero_utf_lut_getSpecialCasing2None(input);
            break;
        case Language.Lithuanian:
            got = cast(void*)sidero_utf_lut_getSpecialCasing2Lithuanian(input);
            break;
        case Language.Turkish:
            got = cast(void*)sidero_utf_lut_getSpecialCasing2Turkish(input);
            break;
        case Language.Azeri:
            got = cast(void*)sidero_utf_lut_getSpecialCasing2Azeri(input);
            break;
    }

    if (got !is null)
        return *cast(immutable(SpecialCasing*))got;
    else
        return sidero_utf_lut_getSimplifiedCasing(input);
}

/// Get casing for character in regards to turkic or simplified mapping.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingTurkic(dchar input) @trusted nothrow @nogc pure {
    void* got = cast(void*)sidero_utf_lut_getSpecialCasing2Turkish(input);
    if (got is null)
        got = cast(void*)sidero_utf_lut_getSpecialCasing2Azeri(input);
    if (got is null)
        got = cast(void*)sidero_utf_lut_getSpecialCasing2None(input);

    if (got !is null)
        return *cast(immutable(SpecialCasing*))got;
    else
        return sidero_utf_lut_getSimplifiedCasing(input);
}
};
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "specialcasing.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter, startsWith, endsWith;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange!dchar valueRangeFromString(string charRangeStr) {
        ValueRange!dchar ret;

        ptrdiff_t offsetOfSeperator = charRangeStr.countUntil("..");
        if(offsetOfSeperator < 0) {
            ret.start = parse!uint(charRangeStr, 16);
            ret.end = ret.start;
        } else {
            string startStr = charRangeStr[0 .. offsetOfSeperator], endStr = charRangeStr[offsetOfSeperator + 2 .. $];
            ret.start = parse!uint(startStr, 16);
            ret.end = parse!uint(endStr, 16);
        }

        return ret;
    }

    dstring replacementsFromString(string replacementsStr) {
        dchar[] replacements;
        replacements.reserve(4);

        foreach(replacement; replacementsStr.splitter(' ')) {
            replacement = replacement.strip;
            if(replacement.length == 0)
                continue;

            replacements ~= parse!uint(replacement, 16);
        }

        return cast(dstring)replacements;
    }

    foreach(line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if(line.length < 5) // anything that low can't represent a functional line
            continue;

        offset = line.countUntil(';');
        if(offset < 0) // no char range
            continue;
        string charRangeStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        ValueRange!dchar valueRange = valueRangeFromString(charRangeStr);

        offset = line.countUntil(';');
        if(offset < 0) // no lowercase
            continue;
        string lowercaseStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        offset = line.countUntil(';');
        if(offset < 0) // no titlecase
            continue;
        string titlecaseStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        offset = line.countUntil(';');
        if(offset < 0) // no uppercase
            continue;
        string uppercaseStr = line[0 .. offset].strip;
        string conditionStr = line[offset + 1 .. $].strip;

        if(conditionStr.endsWith(';'))
            conditionStr = conditionStr[0 .. $ - 1].strip;

        Language language;
        Condition condition;

        if(conditionStr.startsWith("lt")) {
            language = Language.Lithuanian;
            conditionStr = conditionStr[2 .. $].strip;
        } else if(conditionStr.startsWith("tr")) {
            language = Language.Turkish;
            conditionStr = conditionStr[2 .. $].strip;
        } else if(conditionStr.startsWith("az")) {
            language = Language.Azeri;
            conditionStr = conditionStr[2 .. $].strip;
        }

        switch(conditionStr) {
        case "Final_Sigma":
            condition = Condition.Final_Sigma;
            break;
        case "Not_Final_Sigma":
            condition = Condition.Not_Final_Sigma;
            break;
        case "After_Soft_Dotted":
            condition = Condition.After_Soft_Dotted;
            break;
        case "More_Above":
            condition = Condition.More_Above;
            break;
        case "After_I":
            condition = Condition.After_I;
            break;
        case "Not_Before_Dot":
            condition = Condition.Not_Before_Dot;
            break;
        case "":
            break;
        default:
            assert(0, conditionStr);
        }

        if(valueRange.isSingle)
            state.single[language] ~= Entry(valueRange, Casing(replacementsFromString(lowercaseStr),
                    replacementsFromString(titlecaseStr), replacementsFromString(uppercaseStr), condition));
        else
            state.range[language] ~= Entry(valueRange, Casing(replacementsFromString(lowercaseStr),
                    replacementsFromString(titlecaseStr), replacementsFromString(uppercaseStr), condition));
    }
}

struct TotalState {
    Entry[][Language.max + 1] single;
    Entry[][Language.max + 1] range;
}

struct Entry {
    ValueRange!dchar range;
    Casing casing;
}

struct Casing {
    dstring lowercase, titlecase, uppercase;
    ubyte condition;
}

enum Language {
    None,
    Lithuanian,
    Turkish,
    Azeri,
}

enum Condition : ubyte {
    None,
    Final_Sigma,
    Not_Final_Sigma,
    After_Soft_Dotted,
    More_Above,
    After_I,
    Not_Before_Dot
}
