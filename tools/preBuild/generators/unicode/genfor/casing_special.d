module generators.unicode.genfor.casing_special;
import generators.unicode.data.SpecialCasing;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import std.format : formattedWrite;
import std.algorithm;

void genForSpecialCasing() {
    implOutput ~= q{module sidero.base.internal.unicode.specialcasing;
// Generated do not modify

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

    apiOutput ~= q{
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

    intern;
    wrapper;
    table;

}

private:
ValueRange[][Language] ranges;
DicedCasing[][Language] diceds;
size_t[dstring] casingsDStringMap;
dstring casingsText;

void intern() {
    static foreach(language; __traits(allMembers, Language)) {
        {
            foreach(entry; SpecialCasing.entries[__traits(getMember, Language, language)]) {
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
        }
    }
}

void wrapper() {
    static foreach(language; __traits(allMembers, Language)) {
        apiOutput ~= "\n";
        apiOutput ~= "/// Get special casing for character.\n";
        apiOutput ~= "/// Returns: non-null for a given entry if changed from input character.\n";
        apiOutput ~= "export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasing" ~ language ~
            "(dchar input) @trusted nothrow @nogc pure {\n";
        apiOutput ~= "    SpecialCasing ret;\n";
        apiOutput ~= "    sidero_utf_lut_getSpecialCasing2" ~ language ~ "(input, &ret);\n";
        apiOutput ~= "    return cast(immutable)ret;\n";
        apiOutput ~= "}\n";

        apiOutput ~= "export extern(C) bool sidero_utf_lut_getSpecialCasing2" ~ language ~
            "(dchar input, SpecialCasing*) @trusted nothrow @nogc pure;\n";

        implOutput ~= "export extern(C) bool sidero_utf_lut_getSpecialCasing2" ~ language ~
            "(dchar input, void* outputPtr) @trusted nothrow @nogc pure {\n";
        implOutput ~= "    Casing* output = cast(Casing*)outputPtr;\n";
        implOutput ~= "    auto sliced = cast(DicedCasing*)sidero_utf_lut_getSpecialCasing3" ~ language ~ "(input);\n";
        implOutput ~= "    if (sliced is null)\n";
        implOutput ~= "        return false;\n";
        implOutput ~= "    output.condition = sliced.condition;\n";
        implOutput ~= "    output.lowercase = LUT_SpecialCasingDString[sliced.lowerCaseOffset .. sliced.lowerCaseEnd];\n";
        implOutput ~= "    output.titlecase = LUT_SpecialCasingDString[sliced.titleCaseOffset .. sliced.titleCaseEnd];\n";
        implOutput ~= "    output.uppercase = LUT_SpecialCasingDString[sliced.upperCaseOffset .. sliced.upperCaseEnd];\n";
        implOutput ~= "    if (output.lowercase.length == 0)\n";
        implOutput ~= "        output.lowercase = null;\n";
        implOutput ~= "    if (output.titlecase.length == 0)\n";
        implOutput ~= "        output.titlecase = null;\n";
        implOutput ~= "    if (output.uppercase.length == 0)\n";
        implOutput ~= "        output.uppercase = null;\n";
        implOutput ~= "    return true;";
        implOutput ~= "}\n";

        generateReturn(implOutput, "sidero_utf_lut_getSpecialCasing3" ~ language, ranges[__traits(getMember, Language,
                language)], diceds[__traits(getMember, Language, language)]);
    }
}

void table() {
    implOutput ~= "static immutable LUT_SpecialCasingDString = cast(dstring)x\"";

    foreach(i, dchar c; casingsText) {
        implOutput.formattedWrite!"%08X"(c);
    }

    implOutput ~= "\";\n\n";
}
