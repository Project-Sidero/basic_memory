/**
Tables for use with UAX31 for identifiers.
*/
module sidero.base.text.unicode.characters.uax31;
import unidb = sidero.base.text.unicode.database;

export @safe nothrow @nogc:

/// You should handle ``_A-Za-z`` separately to avoid decoding.
bool isUAX31_C_Start(dchar against) {
    return against in unidb.sidero_utf_lut_isUAX31_C_Start_Set;
}

/// You should handle ``_A-Za-z`` separately to avoid decoding.
bool isUAX31_C_Continue(dchar against) {
    return against in unidb.sidero_utf_lut_isUAX31_C_Continue_Set;
}

/// You should handle ``_$A-Za-z`` separately to avoid decoding.
bool isUAX31_Javascript_Start(dchar against) {
    return against in unidb.sidero_utf_lut_isUAX31_JS_Start_Set;
}

/// You should handle ``_A-Za-z`` separately to avoid decoding.
bool isUAX31_Javascript_Continue(dchar against) {
    return against in unidb.sidero_utf_lut_isUAX31_JS_Continue_Set;
}
