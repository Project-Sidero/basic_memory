module sidero.base.text.unicode.characters.database;
import unidb = sidero.base.text.unicode.database;

@safe nothrow @nogc pure

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

///
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
