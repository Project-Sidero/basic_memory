module sidero.base.text.unicode.characters.database;
import sidero.base.bitmanip : BitFlags;
import unidb = sidero.base.text.unicode.database;

export @safe nothrow @nogc pure:

/**
    Enum members: Unknown, Lithuanian, Turkish, Azeri.

    Used in some Unicode algorithms (such as casing).
*/
alias UnicodeLanguage = unidb.Language;
///
alias UnicodeLanguageFlags = BitFlags.For!UnicodeLanguage;

///
bool isTurkic(UnicodeLanguage input) {
    final switch(input) {
        case UnicodeLanguage.Unknown:
        case UnicodeLanguage.Lithuanian:
            return false;
        case UnicodeLanguage.Turkish:
        case UnicodeLanguage.Azeri:
            return true;
    }
}

///
bool isLower(dchar input) {
    return unidb.isUnicodeLower(input);
}

///
dchar toSimplifiedLower(dchar input) {
    auto got = unidb.sidero_utf_lut_getSimplifiedCasing(input);
    if (got.lower.length == 1)
        return got.lower[0];
    return input;
}

///
bool isUpper(dchar input) {
    return unidb.isUnicodeUpper(input);
}

///
dchar toSimplifiedUpper(dchar input) {
    auto got = unidb.sidero_utf_lut_getSimplifiedCasing(input);
    if (got.upper.length == 1)
        return got.upper[0];
    return input;
}

///
bool isTitle(dchar input) {
    return unidb.isUnicodeTitle(input);
}

///
dchar toSimplifiedTitle(dchar input) {
    auto got = unidb.sidero_utf_lut_getSimplifiedCasing(input);
    if (got.title.length == 1)
        return got.title[0];
    return input;
}

/// Lowercase + Uppercase + Lt + Lm + Lo + Nl + Other_Alphabetic
bool isAlpha(dchar input) {
    return unidb.isUnicodeAlpha(input);
}

///
bool isNumeric(dchar input) {
    return unidb.isUnicodeNumber(input);
}

///
bool isAlphaNumeric(dchar input) {
    return unidb.isUnicodeAlphaOrNumber(input);
}

///
bool isControl(dchar input) {
    return unidb.isUnicodeControl(input);
}

///
bool isGraphical(dchar input) {
    return unidb.isUnicodeGraphical(input);
}

///
bool isWhiteSpace(dchar input) {
    return unidb.isUnicodeWhiteSpace(input);
}

///
bool isCaseIgnorable(dchar input) {
    return unidb.isUnicodeCaseIgnorable(input);
}

///
bool isCased(dchar input) {
    return unidb.isUnicodeCased(input);
}

/// Get numeric value in the form of numerator / denominator. If not a number returns [0, 0].
long[2] getNumericValue(dchar input) {
    auto got = unidb.sidero_utf_lut_getNumeric(input);

    if (got is null)
        return [0, 0];

    assert(got.length == 2);
    return got[0 .. 2];
}
