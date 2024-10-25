module generators.unicode.specialcasing;
import constants;

void specialCasing() {
    import std.algorithm;
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "SpecialCasing.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.specialcasing;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    ValueRange[][Language] ranges;
    DicedCasing[][Language] diceds;
    size_t[dstring] casingsDStringMap;
    dstring casingsText;

    {
        static foreach(language; __traits(allMembers, Language)) {
            {
                foreach(entry; state.entries[__traits(getMember, Language, language)]) {
                    DicedCasing diced;
                    diced.condition = entry.casing.condition;

                    if(entry.casing.lowercase !in casingsDStringMap) {
                        casingsDStringMap[entry.casing.lowercase] = casingsText.length;
                        casingsText ~= entry.casing.lowercase;
                    }

                    if(entry.casing.titlecase !in casingsDStringMap) {
                        casingsDStringMap[entry.casing.titlecase] = casingsText.length;
                        casingsText ~= entry.casing.titlecase;
                    }

                    if(entry.casing.uppercase !in casingsDStringMap) {
                        casingsDStringMap[entry.casing.uppercase] = casingsText.length;
                        casingsText ~= entry.casing.uppercase;
                    }

                    diced.lowerCaseOffset = cast(ushort)casingsDStringMap[entry.casing.lowercase];
                    diced.lowerCaseEnd = cast(ushort)(diced.lowerCaseOffset + entry.casing.lowercase.length);
                    diced.titleCaseOffset = cast(ushort)casingsDStringMap[entry.casing.titlecase];
                    diced.titleCaseEnd = cast(ushort)(diced.titleCaseOffset + entry.casing.titlecase.length);
                    diced.upperCaseOffset = cast(ushort)casingsDStringMap[entry.casing.uppercase];
                    diced.upperCaseEnd = cast(ushort)(diced.upperCaseOffset + entry.casing.uppercase.length);

                    diceds[__traits(getMember, Language, language)] ~= diced;
                    ranges[__traits(getMember, Language, language)] ~= entry.range;
                }

                api ~= "\n";
                api ~= "/// Get special casing for character.\n";
                api ~= "/// Returns: non-null for a given entry if changed from input character.\n";
                api ~= "export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasing" ~ language ~
                    "(dchar input) @trusted nothrow @nogc pure {\n";
                api ~= "    SpecialCasing ret;\n";
                api ~= "    sidero_utf_lut_getSpecialCasing2" ~ language ~ "(input, &ret);\n";
                api ~= "    return cast(immutable)ret;\n";
                api ~= "}\n";

                internal ~= "export extern(C) bool sidero_utf_lut_getSpecialCasing2" ~ language ~ "(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
                internal ~= "    Casing* output = cast(Casing*)outputPtr;\n";
                internal ~= "    auto sliced = cast(DicedCasing*)sidero_utf_lut_getSpecialCasing3" ~ language ~ "(input);\n";
                internal ~= "    if (sliced is null)\n";
                internal ~= "        return false;\n";
                internal ~= "    output.condition = sliced.condition;\n";
                internal ~= "    output.lowercase = LUT_SpecialCasingDString[sliced.lowerCaseOffset .. sliced.lowerCaseEnd];\n";
                internal ~= "    output.titlecase = LUT_SpecialCasingDString[sliced.titleCaseOffset .. sliced.titleCaseEnd];\n";
                internal ~= "    output.uppercase = LUT_SpecialCasingDString[sliced.upperCaseOffset .. sliced.upperCaseEnd];\n";
                internal ~= "    if (output.lowercase.length == 0)\n";
                internal ~= "        output.lowercase = null;\n";
                internal ~= "    if (output.titlecase.length == 0)\n";
                internal ~= "        output.titlecase = null;\n";
                internal ~= "    if (output.uppercase.length == 0)\n";
                internal ~= "        output.uppercase = null;\n";
                internal ~= "    return true;";
                internal ~= "}\n";

                api ~= "export extern(C) bool sidero_utf_lut_getSpecialCasing2" ~ language ~ "(dchar input, SpecialCasing*) @trusted nothrow @nogc pure;\n";

                generateReturn(internal, "sidero_utf_lut_getSpecialCasing3" ~ language, ranges[__traits(getMember,
                        Language, language)], diceds[__traits(getMember, Language, language)]);
            }
        }
    }

    {
        internal ~= "static immutable LUT_SpecialCasingDString = cast(dstring)x\"";

        foreach(i, dchar c; casingsText) {
            internal.formattedWrite!"%08X"(c);
        }

        internal ~= "\";\n\n";
    }

    {
        internal ~= q{
struct DicedCasing {
    ushort lowerCaseOffset, lowerCaseEnd;
    ushort titleCaseOffset, titleCaseEnd;
    ushort upperCaseOffset, upperCaseEnd;
    ubyte condition;
}

struct Casing {
    dstring lowercase, titlecase, uppercase;
    ubyte condition;
}
};

        api ~= q{
/// Get casing for character in regards to a language or simplified mapping.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasing(dchar input, Language language) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    bool got;

    final switch(language) {
        case Language.Unknown:
            got = sidero_utf_lut_getSpecialCasing2None(input, &ret);
            break;
        case Language.Lithuanian:
            got = sidero_utf_lut_getSpecialCasing2Lithuanian(input, &ret);
            break;
        case Language.Turkish:
            got = sidero_utf_lut_getSpecialCasing2Turkish(input, &ret);
            break;
        case Language.Azeri:
            got = sidero_utf_lut_getSpecialCasing2Azeri(input, &ret);
            break;
    }

    if (got)
        return cast(immutable)ret;
    else
        return sidero_utf_lut_getSimplifiedCasing(input);
}

/// Get casing for character in regards to turkic or simplified mapping.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingTurkic(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    bool got = sidero_utf_lut_getSpecialCasing2Turkish(input, &ret);
    if (!got)
        got = sidero_utf_lut_getSpecialCasing2Azeri(input, &ret);
    if (!got)
        got = sidero_utf_lut_getSpecialCasing2None(input, &ret);

    if (got)
        return cast(immutable)ret;
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
import utilities.setops;
import utilities.inverselist;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter, startsWith, endsWith, sort;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange valueRangeFromString(string charRangeStr) {
        ValueRange ret;

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

        ValueRange valueRange = valueRangeFromString(charRangeStr);

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

        state.entries[language] ~= Entry(valueRange, Casing(replacementsFromString(lowercaseStr),
                replacementsFromString(titlecaseStr), replacementsFromString(uppercaseStr), condition));
    }

    foreach(language; __traits(allMembers, Language)) {
        sort!"a.range.start < b.range.start"(state.entries[__traits(getMember, Language, language)]);
    }
}

struct TotalState {
    Entry[][Language.max + 1] entries;
}

struct Entry {
    ValueRange range;
    Casing casing;
}

struct Casing {
    dstring lowercase, titlecase, uppercase;
    ubyte condition;
}

struct DicedCasing {
    ushort lowerCaseOffset, lowerCaseEnd;
    ushort titleCaseOffset, titleCaseEnd;
    ushort upperCaseOffset, upperCaseEnd;
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
