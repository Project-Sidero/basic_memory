module generators.unicode.data.SpecialCasing;
import utilities.setops;
import utilities.inverselist;

__gshared SpecialCasing_State SpecialCasing;

struct SpecialCasing_State {
    SpecialCasing_Entry[][Language.max + 1] entries;
}

struct SpecialCasing_Entry {
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

void processSpecialCasing(string inputText) {
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

        SpecialCasing.entries[language] ~= SpecialCasing_Entry(valueRange, Casing(replacementsFromString(lowercaseStr),
        replacementsFromString(titlecaseStr), replacementsFromString(uppercaseStr), condition));
    }

    foreach(language; __traits(allMembers, Language)) {
        sort!"a.range.start < b.range.start"(SpecialCasing.entries[__traits(getMember, Language, language)]);
    }
}
