/**
Unicode database access routines
License: Artistic-v2
*/
module sidero.base.text.unicode.database;
import sidero.base.containers.set.interval;
// Generated do not modify

///
enum Language {
    ///
    Unknown,
    ///
    Lithuanian,
    ///
    Turkish,
    //
    Azeri,
}

///
enum HangulSyllableType {
    /// Abbreviated as L
    LeadingConsonant,
    /// Abbreviated as V
    Vowel,
    /// Abbreviated as T
    TrailingConsonant,
    // Abbreviated as LV
    LV_Syllable,
    /// Abbreviated as LVT
    LVT_Syllable
}

///
enum GeneralCategory : ubyte {
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

///
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

///
enum CompatibilityFormattingTag : uint {
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

///
struct DecompositionMapping {
    ///
    CompatibilityFormattingTag tag;
    ///
    dstring decomposed;
    ///
    dstring fullyDecomposed, fullyDecomposedCompatibility;
}

///
enum WordBreakProperty : ubyte {
    None, ///
    Double_Quote, ///
    Single_Quote, ///
    Hebrew_Letter, ///
    CR, ///
    LF, ///
    Newline, ///
    Extend, ///
    Regional_Indicator, ///
    Format, ///
    Katakana, ///
    ALetter, ///
    MidLetter, ///
    MidNum, ///
    MidNumLet, ///
    Numeric, ///
    ExtendNumLet, ///
    ZWJ, ///
    WSegSpace, ///
}

///
enum SpecialCasingCondition : ubyte {
    None, ///
    Final_Sigma, ///
    Not_Final_Sigma, ///
    After_Soft_Dotted, ///
    More_Above, ///
    After_I, ///
    Not_Before_Dot, ///
}

///
struct SpecialCasing {
    ///
    dstring lower, title, upper;
    ///
    SpecialCasingCondition condition;
}

///
enum LineBreakClass : ubyte {
    XX, ///
    BK, ///
    CR, ///
    LF, ///
    CM, ///
    NL, ///
    SG, ///
    WJ, ///
    ZW, ///
    GL, ///
    SP, ///
    ZWJ, ///
    B2, ///
    BA, ///
    BB, ///
    HY, ///
    CB, ///
    CL, ///
    CP, ///
    EX, ///
    IN, ///
    NS, ///
    OP, ///
    QU, ///
    IS, ///
    NU, ///
    PO, ///
    PR, ///
    SY, ///
    AI, ///
    AL, ///
    CJ, ///
    EB, ///
    EM, ///
    H2, ///
    H3, ///
    HL, ///
    ID, ///
    JL, ///
    JV, ///
    JT, ///
    RI, ///
    SA, ///
    Unknown = XX, ///
}

///
enum Script : ubyte {
    Unknown, ///
    Old_Hungarian, ///
    Coptic, ///
    Ol_Chiki, ///
    Cyrillic, ///
    Thaana, ///
    Inscriptional_Parthian, ///
    Nabataean, ///
    Ogham, ///
    Meroitic_Hieroglyphs, ///
    Makasar, ///
    Siddham, ///
    Old_Persian, ///
    Imperial_Aramaic, ///
    Myanmar, ///
    Deseret, ///
    Kaithi, ///
    Medefaidrin, ///
    Kayah_Li, ///
    Hiragana, ///
    Ahom, ///
    Devanagari, ///
    Tibetan, ///
    Nko, ///
    Brahmi, ///
    Osage, ///
    Nushu, ///
    Cuneiform, ///
    Takri, ///
    Toto, ///
    Latin, ///
    Hanunoo, ///
    Limbu, ///
    Saurashtra, ///
    Lisu, ///
    Egyptian_Hieroglyphs, ///
    Elbasan, ///
    Palmyrene, ///
    Tagbanwa, ///
    Old_Italic, ///
    Caucasian_Albanian, ///
    Malayalam, ///
    Inherited, ///
    Sora_Sompeng, ///
    Linear_B, ///
    Nyiakeng_Puachue_Hmong, ///
    Meroitic_Cursive, ///
    Thai, ///
    Mende_Kikakui, ///
    Old_Sogdian, ///
    Old_Turkic, ///
    Samaritan, ///
    Old_South_Arabian, ///
    Hanifi_Rohingya, ///
    Balinese, ///
    Mandaic, ///
    SignWriting, ///
    Tifinagh, ///
    Tai_Viet, ///
    Syriac, ///
    Soyombo, ///
    Elymaic, ///
    Hatran, ///
    Chorasmian, ///
    Glagolitic, ///
    Osmanya, ///
    Linear_A, ///
    Mro, ///
    Chakma, ///
    Modi, ///
    Bassa_Vah, ///
    Han, ///
    Multani, ///
    Bopomofo, ///
    Adlam, ///
    Khitan_Small_Script, ///
    Lao, ///
    Psalter_Pahlavi, ///
    Anatolian_Hieroglyphs, ///
    Canadian_Aboriginal, ///
    Common, ///
    Gothic, ///
    Yi, ///
    Sinhala, ///
    Rejang, ///
    Lepcha, ///
    Tai_Tham, ///
    Dives_Akuru, ///
    Meetei_Mayek, ///
    Tirhuta, ///
    Marchen, ///
    Wancho, ///
    Phoenician, ///
    Gurmukhi, ///
    Khudawadi, ///
    Khojki, ///
    Newa, ///
    Dogra, ///
    Oriya, ///
    Tagalog, ///
    Sundanese, ///
    Old_Permic, ///
    Shavian, ///
    Lycian, ///
    Miao, ///
    Tangut, ///
    Bengali, ///
    Inscriptional_Pahlavi, ///
    Vithkuqi, ///
    Armenian, ///
    New_Tai_Lue, ///
    Sogdian, ///
    Buhid, ///
    Manichaean, ///
    Greek, ///
    Braille, ///
    Avestan, ///
    Arabic, ///
    Javanese, ///
    Lydian, ///
    Pau_Cin_Hau, ///
    Cypro_Minoan, ///
    Buginese, ///
    Batak, ///
    Nandinagari, ///
    Cham, ///
    Gunjala_Gondi, ///
    Cypriot, ///
    Ugaritic, ///
    Georgian, ///
    Sharada, ///
    Tamil, ///
    Cherokee, ///
    Pahawh_Hmong, ///
    Syloti_Nagri, ///
    Kharoshthi, ///
    Zanabazar_Square, ///
    Katakana, ///
    Telugu, ///
    Ethiopic, ///
    Vai, ///
    Bamum, ///
    Hangul, ///
    Mongolian, ///
    Old_Uyghur, ///
    Mahajani, ///
    Khmer, ///
    Grantha, ///
    Kannada, ///
    Yezidi, ///
    Old_North_Arabian, ///
    Tai_Le, ///
    Hebrew, ///
    Gujarati, ///
    Tangsa, ///
    Carian, ///
    Bhaiksuki, ///
    Masaram_Gondi, ///
    Runic, ///
    Duployan, ///
    Warang_Citi, ///
    Phags_Pa, ///
}

/// Is character case ignorable
bool isUnicodeCaseIgnorable(dchar input) @safe nothrow @nogc pure {
    switch(sidero_utf_lut_getGeneralCategory(input)) {
        case GeneralCategory.Mn:
        case GeneralCategory.Me:
        case GeneralCategory.Cf:
        case GeneralCategory.Lm:
        case GeneralCategory.Sk:
            return true;

        default:
            switch(sidero_utf_lut_getWordBreakProperty(input)) {
                case WordBreakProperty.MidLetter:
                case WordBreakProperty.MidNumLet:
                case WordBreakProperty.Single_Quote:
                    return true;

                default:
                    return false;
            }
    }
}

/// Lookup decomposition mapping for character if canonical.
alias sidero_utf_lut_getDecompositionMappingCanonical = sidero_utf_lut_getDecompositionMappingNone;

/// Lookup decomposition mapping length for character if canonical.
alias sidero_utf_lut_lengthOfDecompositionMappingCanonical = sidero_utf_lut_lengthOfDecompositionMappingNone;

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

/// Get simplified casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSimplifiedCasing(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    sidero_utf_lut_getSimplifiedCasing2(input, &ret);
    return cast(immutable)ret;
}
export extern(C) void sidero_utf_lut_getSimplifiedCasing2(dchar input, void*) @trusted nothrow @nogc pure;
export extern(C) IntervalSet!dchar sidero_utf_lut_isCased_Set() @safe nothrow @nogc;

/// Lookup CCC for character.
/// Returns: 0 if not set.
export extern(C) ubyte sidero_utf_lut_getCCC(dchar against) @safe nothrow @nogc pure;

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

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingNone(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    sidero_utf_lut_getSpecialCasing2None(input, &ret);
    return cast(immutable)ret;
}
export extern(C) bool sidero_utf_lut_getSpecialCasing2None(dchar input, SpecialCasing*) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingLithuanian(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    sidero_utf_lut_getSpecialCasing2Lithuanian(input, &ret);
    return cast(immutable)ret;
}
export extern(C) bool sidero_utf_lut_getSpecialCasing2Lithuanian(dchar input, SpecialCasing*) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingTurkish(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    sidero_utf_lut_getSpecialCasing2Turkish(input, &ret);
    return cast(immutable)ret;
}
export extern(C) bool sidero_utf_lut_getSpecialCasing2Turkish(dchar input, SpecialCasing*) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingAzeri(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    sidero_utf_lut_getSpecialCasing2Azeri(input, &ret);
    return cast(immutable)ret;
}
export extern(C) bool sidero_utf_lut_getSpecialCasing2Azeri(dchar input, SpecialCasing*) @trusted nothrow @nogc pure;

/// Lookup Casefolding for character.
/// Returns: null if unchanged.
export extern(C) dstring sidero_utf_lut_getCaseFolding(dchar against) @safe nothrow @nogc pure;

/// Lookup Casefolding for character.
/// Returns: null if unchanged.
export extern(C) dstring sidero_utf_lut_getCaseFoldingTurkic(dchar against) @safe nothrow @nogc pure;

/// Lookup Casefolding (simple) for character.
/// Returns: The casefolded character.
export extern(C) dchar sidero_utf_lut_getCaseFoldingFast(dchar against) @safe nothrow @nogc pure;

/// Lookup Casefolding length for character.
/// Returns: 0 if unchanged.
export extern(C) uint sidero_utf_lut_lengthOfCaseFolding(dchar against) @safe nothrow @nogc pure;

/// Lookup Casefolding length for character.
/// Returns: 0 if unchanged.
export extern(C) uint sidero_utf_lut_lengthOfCaseFoldingTurkic(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfWhite_Space_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfBidi_Control_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfJoin_Control_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfDash_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfHyphen_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfQuotation_Mark_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfTerminal_Punctuation_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Math_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfHex_Digit_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfASCII_Hex_Digit_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Alphabetic_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIdeographic_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfDiacritic_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfExtender_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Lowercase_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Uppercase_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfNoncharacter_Code_Point_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Grapheme_Extend_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIDS_Binary_Operator_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIDS_Trinary_Operator_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIDS_Unary_Operator_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfRadical_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfUnified_Ideograph_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfDeprecated_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfSoft_Dotted_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfLogical_Order_Exception_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_ID_Start_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_ID_Continue_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfSentence_Terminal_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfVariation_Selector_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfPattern_White_Space_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfPattern_Syntax_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfRegional_Indicator_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfID_Compat_Math_Start_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfID_Compat_Math_Continue_Set() @safe nothrow @nogc;

/// Is character member of property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfModifier_Combining_Mark_Set() @safe nothrow @nogc;

/// Is character part of full composition execlusions.
export extern(C) bool sidero_utf_lut_isFullCompositionExcluded(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemePrepend_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeCR_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeLF_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeControl_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeExtend_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeRegional_Indicator_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeSpacingMark_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeL_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeV_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeT_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeLV_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeLVT_Set() @safe nothrow @nogc;

/// Is character member of grapheme break property.
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfGraphemeZWJ_Set() @safe nothrow @nogc;

/// Lookup word break property for character.
export extern(C) WordBreakProperty sidero_utf_lut_getWordBreakProperty(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag None.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingNone(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Font.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingFont(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag NoBreak.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingNoBreak(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Initial.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingInitial(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Medial.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingMedial(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Final.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingFinal(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Isolated.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingIsolated(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Circle.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingCircle(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Super.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingSuper(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Sub.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingSub(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Vertical.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingVertical(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Wide.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingWide(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Narrow.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingNarrow(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Small.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingSmall(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Square.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingSquare(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Fraction.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingFraction(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Compat.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingCompat(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if compatibility.
export extern(C) dstring sidero_utf_lut_getDecompositionMappingCompatibility(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag None.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingNone(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Font.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingFont(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag NoBreak.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingNoBreak(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Initial.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingInitial(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Medial.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingMedial(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Final.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingFinal(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Isolated.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingIsolated(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Circle.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingCircle(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Super.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingSuper(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Sub.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingSub(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Vertical.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingVertical(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Wide.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingWide(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Narrow.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingNarrow(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Small.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingSmall(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Square.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingSquare(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Fraction.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingFraction(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Compat.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingCompat(dchar against) @safe nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if compatibility.
export extern(C) ubyte sidero_utf_lut_lengthOfDecompositionMappingCompatibility(dchar against) @safe nothrow @nogc pure;

/// Get decomposition map for character.
/// Returns: None for tag if unchanged.
export immutable(DecompositionMapping) sidero_utf_lut_getDecompositionMap(dchar input) @trusted nothrow @nogc pure {
    DecompositionMapping ret;
    sidero_utf_lut_getDecompositionMap2(input, &ret);
    return cast(immutable)ret;
}
export extern(C) void sidero_utf_lut_getDecompositionMap2(dchar input, void*) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character given the compatibility formatting tag.
export dstring sidero_utf_lut_getDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {
    final switch(tag) {
        case CompatibilityFormattingTag.None:
            return sidero_utf_lut_getDecompositionMappingNone(input);
        case CompatibilityFormattingTag.Font:
            return sidero_utf_lut_getDecompositionMappingFont(input);
        case CompatibilityFormattingTag.NoBreak:
            return sidero_utf_lut_getDecompositionMappingNoBreak(input);
        case CompatibilityFormattingTag.Initial:
            return sidero_utf_lut_getDecompositionMappingInitial(input);
        case CompatibilityFormattingTag.Medial:
            return sidero_utf_lut_getDecompositionMappingMedial(input);
        case CompatibilityFormattingTag.Final:
            return sidero_utf_lut_getDecompositionMappingFinal(input);
        case CompatibilityFormattingTag.Isolated:
            return sidero_utf_lut_getDecompositionMappingIsolated(input);
        case CompatibilityFormattingTag.Circle:
            return sidero_utf_lut_getDecompositionMappingCircle(input);
        case CompatibilityFormattingTag.Super:
            return sidero_utf_lut_getDecompositionMappingSuper(input);
        case CompatibilityFormattingTag.Sub:
            return sidero_utf_lut_getDecompositionMappingSub(input);
        case CompatibilityFormattingTag.Vertical:
            return sidero_utf_lut_getDecompositionMappingVertical(input);
        case CompatibilityFormattingTag.Wide:
            return sidero_utf_lut_getDecompositionMappingWide(input);
        case CompatibilityFormattingTag.Narrow:
            return sidero_utf_lut_getDecompositionMappingNarrow(input);
        case CompatibilityFormattingTag.Small:
            return sidero_utf_lut_getDecompositionMappingSmall(input);
        case CompatibilityFormattingTag.Square:
            return sidero_utf_lut_getDecompositionMappingSquare(input);
        case CompatibilityFormattingTag.Fraction:
            return sidero_utf_lut_getDecompositionMappingFraction(input);
        case CompatibilityFormattingTag.Compat:
            return sidero_utf_lut_getDecompositionMappingCompat(input);
    }
}

/// Lookup length of decomposition mapping for character given the compatibility formatting tag.
export ubyte sidero_utf_lut_lengthOfDecompositionMapping(dchar input, CompatibilityFormattingTag tag) @safe nothrow @nogc pure {
    final switch(tag) {
        case CompatibilityFormattingTag.None:
            return sidero_utf_lut_lengthOfDecompositionMappingNone(input);
        case CompatibilityFormattingTag.Font:
            return sidero_utf_lut_lengthOfDecompositionMappingFont(input);
        case CompatibilityFormattingTag.NoBreak:
            return sidero_utf_lut_lengthOfDecompositionMappingNoBreak(input);
        case CompatibilityFormattingTag.Initial:
            return sidero_utf_lut_lengthOfDecompositionMappingInitial(input);
        case CompatibilityFormattingTag.Medial:
            return sidero_utf_lut_lengthOfDecompositionMappingMedial(input);
        case CompatibilityFormattingTag.Final:
            return sidero_utf_lut_lengthOfDecompositionMappingFinal(input);
        case CompatibilityFormattingTag.Isolated:
            return sidero_utf_lut_lengthOfDecompositionMappingIsolated(input);
        case CompatibilityFormattingTag.Circle:
            return sidero_utf_lut_lengthOfDecompositionMappingCircle(input);
        case CompatibilityFormattingTag.Super:
            return sidero_utf_lut_lengthOfDecompositionMappingSuper(input);
        case CompatibilityFormattingTag.Sub:
            return sidero_utf_lut_lengthOfDecompositionMappingSub(input);
        case CompatibilityFormattingTag.Vertical:
            return sidero_utf_lut_lengthOfDecompositionMappingVertical(input);
        case CompatibilityFormattingTag.Wide:
            return sidero_utf_lut_lengthOfDecompositionMappingWide(input);
        case CompatibilityFormattingTag.Narrow:
            return sidero_utf_lut_lengthOfDecompositionMappingNarrow(input);
        case CompatibilityFormattingTag.Small:
            return sidero_utf_lut_lengthOfDecompositionMappingSmall(input);
        case CompatibilityFormattingTag.Square:
            return sidero_utf_lut_lengthOfDecompositionMappingSquare(input);
        case CompatibilityFormattingTag.Fraction:
            return sidero_utf_lut_lengthOfDecompositionMappingFraction(input);
        case CompatibilityFormattingTag.Compat:
            return sidero_utf_lut_lengthOfDecompositionMappingCompat(input);
    }
}

/// Get length of fully decomposed for character.
export extern(C) ushort sidero_utf_lut_lengthOfFullyDecomposed(dchar against) @safe nothrow @nogc pure;

/// Get composition for character pair.
/// Returns: dchar.init if not set.
export dchar sidero_utf_lut_getCompositionCanonical(dchar L, dchar C) @trusted nothrow @nogc pure {
    ulong temp = C;
    temp <<= 32;
    temp |= L;
    return sidero_utf_lut_getCompositionCanonical2(temp);
}
export extern(C) dchar sidero_utf_lut_getCompositionCanonical2(ulong against) @safe nothrow @nogc pure;

/// Get composition for character pair.
/// Returns: dchar.init if not set.
export dchar sidero_utf_lut_getCompositionCompatibility(dchar L, dchar C) @trusted nothrow @nogc pure {
    ulong temp = C;
    temp <<= 32;
    temp |= L;
    return sidero_utf_lut_getCompositionCompatibility2(temp);
}
export extern(C) dchar sidero_utf_lut_getCompositionCompatibility2(ulong against) @safe nothrow @nogc pure;

/// Is excluded from composition.
/// Returns: false if not set.
export extern(C) bool sidero_utf_lut_isCompositionExcluded(dchar against) @safe nothrow @nogc pure;

/// Is character a hangul syllable?
export extern(C) bool sidero_utf_lut_isHangulSyllable(dchar against) @safe nothrow @nogc pure;

/// Gets the ranges of values in a given Hangul syllable type.
export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc {
    final switch(type) {
        case HangulSyllableType.LeadingConsonant:
            return sidero_utf_lut_hangulSyllables_LeadingConsonant_Set();
        case HangulSyllableType.Vowel:
            return sidero_utf_lut_hangulSyllables_Vowel_Set();
        case HangulSyllableType.TrailingConsonant:
            return sidero_utf_lut_hangulSyllables_TrailingConsonant_Set();
        case HangulSyllableType.LV_Syllable:
            return sidero_utf_lut_hangulSyllables_LV_Syllable_Set();
        case HangulSyllableType.LVT_Syllable:
            return sidero_utf_lut_hangulSyllables_LVT_Syllable_Set();
    }
}
/// Gets the ranges of values in a Hangul syllable LeadingConsonant.
export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables_LeadingConsonant_Set() @safe nothrow @nogc;
/// Gets the ranges of values in a Hangul syllable Vowel.
export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables_Vowel_Set() @safe nothrow @nogc;
/// Gets the ranges of values in a Hangul syllable TrailingConsonant.
export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables_TrailingConsonant_Set() @safe nothrow @nogc;
/// Gets the ranges of values in a Hangul syllable LV_Syllable.
export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables_LV_Syllable_Set() @safe nothrow @nogc;
/// Gets the ranges of values in a Hangul syllable LVT_Syllable.
export extern(C) IntervalSet!dchar sidero_utf_lut_hangulSyllables_LVT_Syllable_Set() @safe nothrow @nogc;

/// Get the Line break class
export extern(C) LineBreakClass sidero_utf_lut_getLineBreakClass(dchar against) @safe nothrow @nogc pure;

/// Get the Script for a character
export extern(C) Script sidero_utf_lut_getScript(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Unknown
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptUnknown_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Hungarian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Hungarian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Coptic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCoptic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Ol_Chiki
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOl_Chiki_Set() @safe nothrow @nogc;
/// Is the character a member of the script Cyrillic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCyrillic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Thaana
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptThaana_Set() @safe nothrow @nogc;
/// Is the character a member of the script Inscriptional_Parthian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptInscriptional_Parthian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Nabataean
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNabataean_Set() @safe nothrow @nogc;
/// Is the character a member of the script Ogham
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOgham_Set() @safe nothrow @nogc;
/// Is the character a member of the script Meroitic_Hieroglyphs
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMeroitic_Hieroglyphs_Set() @safe nothrow @nogc;
/// Is the character a member of the script Makasar
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMakasar_Set() @safe nothrow @nogc;
/// Is the character a member of the script Siddham
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSiddham_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Persian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Persian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Imperial_Aramaic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptImperial_Aramaic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Myanmar
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMyanmar_Set() @safe nothrow @nogc;
/// Is the character a member of the script Deseret
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptDeseret_Set() @safe nothrow @nogc;
/// Is the character a member of the script Kaithi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKaithi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Medefaidrin
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMedefaidrin_Set() @safe nothrow @nogc;
/// Is the character a member of the script Kayah_Li
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKayah_Li_Set() @safe nothrow @nogc;
/// Is the character a member of the script Hiragana
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHiragana_Set() @safe nothrow @nogc;
/// Is the character a member of the script Ahom
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptAhom_Set() @safe nothrow @nogc;
/// Is the character a member of the script Devanagari
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptDevanagari_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tibetan
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTibetan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Nko
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNko_Set() @safe nothrow @nogc;
/// Is the character a member of the script Brahmi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBrahmi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Osage
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOsage_Set() @safe nothrow @nogc;
/// Is the character a member of the script Nushu
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNushu_Set() @safe nothrow @nogc;
/// Is the character a member of the script Cuneiform
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCuneiform_Set() @safe nothrow @nogc;
/// Is the character a member of the script Takri
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTakri_Set() @safe nothrow @nogc;
/// Is the character a member of the script Toto
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptToto_Set() @safe nothrow @nogc;
/// Is the character a member of the script Latin
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLatin_Set() @safe nothrow @nogc;
/// Is the character a member of the script Hanunoo
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHanunoo_Set() @safe nothrow @nogc;
/// Is the character a member of the script Limbu
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLimbu_Set() @safe nothrow @nogc;
/// Is the character a member of the script Saurashtra
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSaurashtra_Set() @safe nothrow @nogc;
/// Is the character a member of the script Lisu
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLisu_Set() @safe nothrow @nogc;
/// Is the character a member of the script Egyptian_Hieroglyphs
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptEgyptian_Hieroglyphs_Set() @safe nothrow @nogc;
/// Is the character a member of the script Elbasan
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptElbasan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Palmyrene
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptPalmyrene_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tagbanwa
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTagbanwa_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Italic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Italic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Caucasian_Albanian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCaucasian_Albanian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Malayalam
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMalayalam_Set() @safe nothrow @nogc;
/// Is the character a member of the script Inherited
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptInherited_Set() @safe nothrow @nogc;
/// Is the character a member of the script Sora_Sompeng
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSora_Sompeng_Set() @safe nothrow @nogc;
/// Is the character a member of the script Linear_B
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLinear_B_Set() @safe nothrow @nogc;
/// Is the character a member of the script Nyiakeng_Puachue_Hmong
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNyiakeng_Puachue_Hmong_Set() @safe nothrow @nogc;
/// Is the character a member of the script Meroitic_Cursive
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMeroitic_Cursive_Set() @safe nothrow @nogc;
/// Is the character a member of the script Thai
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptThai_Set() @safe nothrow @nogc;
/// Is the character a member of the script Mende_Kikakui
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMende_Kikakui_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Sogdian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Sogdian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Turkic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Turkic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Samaritan
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSamaritan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_South_Arabian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_South_Arabian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Hanifi_Rohingya
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHanifi_Rohingya_Set() @safe nothrow @nogc;
/// Is the character a member of the script Balinese
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBalinese_Set() @safe nothrow @nogc;
/// Is the character a member of the script Mandaic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMandaic_Set() @safe nothrow @nogc;
/// Is the character a member of the script SignWriting
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSignWriting_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tifinagh
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTifinagh_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tai_Viet
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTai_Viet_Set() @safe nothrow @nogc;
/// Is the character a member of the script Syriac
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSyriac_Set() @safe nothrow @nogc;
/// Is the character a member of the script Soyombo
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSoyombo_Set() @safe nothrow @nogc;
/// Is the character a member of the script Elymaic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptElymaic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Hatran
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHatran_Set() @safe nothrow @nogc;
/// Is the character a member of the script Chorasmian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptChorasmian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Glagolitic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGlagolitic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Osmanya
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOsmanya_Set() @safe nothrow @nogc;
/// Is the character a member of the script Linear_A
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLinear_A_Set() @safe nothrow @nogc;
/// Is the character a member of the script Mro
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMro_Set() @safe nothrow @nogc;
/// Is the character a member of the script Chakma
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptChakma_Set() @safe nothrow @nogc;
/// Is the character a member of the script Modi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptModi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Bassa_Vah
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBassa_Vah_Set() @safe nothrow @nogc;
/// Is the character a member of the script Han
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Multani
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMultani_Set() @safe nothrow @nogc;
/// Is the character a member of the script Bopomofo
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBopomofo_Set() @safe nothrow @nogc;
/// Is the character a member of the script Adlam
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptAdlam_Set() @safe nothrow @nogc;
/// Is the character a member of the script Khitan_Small_Script
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKhitan_Small_Script_Set() @safe nothrow @nogc;
/// Is the character a member of the script Lao
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLao_Set() @safe nothrow @nogc;
/// Is the character a member of the script Psalter_Pahlavi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptPsalter_Pahlavi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Anatolian_Hieroglyphs
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptAnatolian_Hieroglyphs_Set() @safe nothrow @nogc;
/// Is the character a member of the script Canadian_Aboriginal
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCanadian_Aboriginal_Set() @safe nothrow @nogc;
/// Is the character a member of the script Common
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCommon_Set() @safe nothrow @nogc;
/// Is the character a member of the script Gothic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGothic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Yi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptYi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Sinhala
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSinhala_Set() @safe nothrow @nogc;
/// Is the character a member of the script Rejang
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptRejang_Set() @safe nothrow @nogc;
/// Is the character a member of the script Lepcha
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLepcha_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tai_Tham
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTai_Tham_Set() @safe nothrow @nogc;
/// Is the character a member of the script Dives_Akuru
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptDives_Akuru_Set() @safe nothrow @nogc;
/// Is the character a member of the script Meetei_Mayek
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMeetei_Mayek_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tirhuta
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTirhuta_Set() @safe nothrow @nogc;
/// Is the character a member of the script Marchen
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMarchen_Set() @safe nothrow @nogc;
/// Is the character a member of the script Wancho
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptWancho_Set() @safe nothrow @nogc;
/// Is the character a member of the script Phoenician
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptPhoenician_Set() @safe nothrow @nogc;
/// Is the character a member of the script Gurmukhi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGurmukhi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Khudawadi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKhudawadi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Khojki
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKhojki_Set() @safe nothrow @nogc;
/// Is the character a member of the script Newa
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNewa_Set() @safe nothrow @nogc;
/// Is the character a member of the script Dogra
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptDogra_Set() @safe nothrow @nogc;
/// Is the character a member of the script Oriya
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOriya_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tagalog
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTagalog_Set() @safe nothrow @nogc;
/// Is the character a member of the script Sundanese
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSundanese_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Permic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Permic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Shavian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptShavian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Lycian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLycian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Miao
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMiao_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tangut
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTangut_Set() @safe nothrow @nogc;
/// Is the character a member of the script Bengali
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBengali_Set() @safe nothrow @nogc;
/// Is the character a member of the script Inscriptional_Pahlavi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptInscriptional_Pahlavi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Vithkuqi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptVithkuqi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Armenian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptArmenian_Set() @safe nothrow @nogc;
/// Is the character a member of the script New_Tai_Lue
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNew_Tai_Lue_Set() @safe nothrow @nogc;
/// Is the character a member of the script Sogdian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSogdian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Buhid
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBuhid_Set() @safe nothrow @nogc;
/// Is the character a member of the script Manichaean
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptManichaean_Set() @safe nothrow @nogc;
/// Is the character a member of the script Greek
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGreek_Set() @safe nothrow @nogc;
/// Is the character a member of the script Braille
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBraille_Set() @safe nothrow @nogc;
/// Is the character a member of the script Avestan
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptAvestan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Arabic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptArabic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Javanese
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptJavanese_Set() @safe nothrow @nogc;
/// Is the character a member of the script Lydian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptLydian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Pau_Cin_Hau
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptPau_Cin_Hau_Set() @safe nothrow @nogc;
/// Is the character a member of the script Cypro_Minoan
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCypro_Minoan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Buginese
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBuginese_Set() @safe nothrow @nogc;
/// Is the character a member of the script Batak
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBatak_Set() @safe nothrow @nogc;
/// Is the character a member of the script Nandinagari
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNandinagari_Set() @safe nothrow @nogc;
/// Is the character a member of the script Cham
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCham_Set() @safe nothrow @nogc;
/// Is the character a member of the script Gunjala_Gondi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGunjala_Gondi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Cypriot
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCypriot_Set() @safe nothrow @nogc;
/// Is the character a member of the script Ugaritic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptUgaritic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Georgian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGeorgian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Sharada
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSharada_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tamil
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTamil_Set() @safe nothrow @nogc;
/// Is the character a member of the script Cherokee
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCherokee_Set() @safe nothrow @nogc;
/// Is the character a member of the script Pahawh_Hmong
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptPahawh_Hmong_Set() @safe nothrow @nogc;
/// Is the character a member of the script Syloti_Nagri
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSyloti_Nagri_Set() @safe nothrow @nogc;
/// Is the character a member of the script Kharoshthi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKharoshthi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Zanabazar_Square
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptZanabazar_Square_Set() @safe nothrow @nogc;
/// Is the character a member of the script Katakana
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKatakana_Set() @safe nothrow @nogc;
/// Is the character a member of the script Telugu
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTelugu_Set() @safe nothrow @nogc;
/// Is the character a member of the script Ethiopic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptEthiopic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Vai
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptVai_Set() @safe nothrow @nogc;
/// Is the character a member of the script Bamum
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBamum_Set() @safe nothrow @nogc;
/// Is the character a member of the script Hangul
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHangul_Set() @safe nothrow @nogc;
/// Is the character a member of the script Mongolian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMongolian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_Uyghur
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_Uyghur_Set() @safe nothrow @nogc;
/// Is the character a member of the script Mahajani
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMahajani_Set() @safe nothrow @nogc;
/// Is the character a member of the script Khmer
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKhmer_Set() @safe nothrow @nogc;
/// Is the character a member of the script Grantha
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGrantha_Set() @safe nothrow @nogc;
/// Is the character a member of the script Kannada
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKannada_Set() @safe nothrow @nogc;
/// Is the character a member of the script Yezidi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptYezidi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Old_North_Arabian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOld_North_Arabian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tai_Le
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTai_Le_Set() @safe nothrow @nogc;
/// Is the character a member of the script Hebrew
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptHebrew_Set() @safe nothrow @nogc;
/// Is the character a member of the script Gujarati
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGujarati_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tangsa
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTangsa_Set() @safe nothrow @nogc;
/// Is the character a member of the script Carian
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptCarian_Set() @safe nothrow @nogc;
/// Is the character a member of the script Bhaiksuki
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptBhaiksuki_Set() @safe nothrow @nogc;
/// Is the character a member of the script Masaram_Gondi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptMasaram_Gondi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Runic
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptRunic_Set() @safe nothrow @nogc;
/// Is the character a member of the script Duployan
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptDuployan_Set() @safe nothrow @nogc;
/// Is the character a member of the script Warang_Citi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptWarang_Citi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Phags_Pa
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptPhags_Pa_Set() @safe nothrow @nogc;
/// Is the character a member of the script Kawi
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKawi_Set() @safe nothrow @nogc;
/// Is the character a member of the script Nag_Mundari
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptNag_Mundari_Set() @safe nothrow @nogc;
/// Is the character a member of the script Garay
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGaray_Set() @safe nothrow @nogc;
/// Is the character a member of the script Gurung_Khema
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptGurung_Khema_Set() @safe nothrow @nogc;
/// Is the character a member of the script Kirat_Rai
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptKirat_Rai_Set() @safe nothrow @nogc;
/// Is the character a member of the script Ol_Onal
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptOl_Onal_Set() @safe nothrow @nogc;
/// Is the character a member of the script Sunuwar
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptSunuwar_Set() @safe nothrow @nogc;
/// Is the character a member of the script Todhri
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTodhri_Set() @safe nothrow @nogc;
/// Is the character a member of the script Tulu_Tigalari
export extern(C) IntervalSet!dchar sidero_utf_lut_isScriptTulu_Tigalari_Set() @safe nothrow @nogc;

/// Is UAX31 for C start set.
/// Returns: false if not set.
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_C_Start_Set() @safe nothrow @nogc;

/// Is UAX31 for C continue set.
/// Returns: false if not set.
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_C_Continue_Set() @safe nothrow @nogc;

/// Is UAX31 for Javascript start set.
/// Returns: false if not set.
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_JS_Start_Set() @safe nothrow @nogc;

/// Is UAX31 for Javascript continue set.
/// Returns: false if not set.
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_JS_Continue_Set() @safe nothrow @nogc;

/// Lookup numeric numerator/denominator for character.
/// Returns: null if not set.
export extern(C) immutable(long[2])* sidero_utf_lut_getNumeric(dchar against) @safe nothrow @nogc pure;

/// Lookup general category for character.
export extern(C) GeneralCategory sidero_utf_lut_getGeneralCategory(dchar against) @safe nothrow @nogc pure;

/// Is member of Emoji class?
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfEmoji_Set() @safe nothrow @nogc;

/// Is member of Emoji_Presentation class?
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfEmoji_Presentation_Set() @safe nothrow @nogc;

/// Is member of Emoji_Modifier class?
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfEmoji_Modifier_Set() @safe nothrow @nogc;

/// Is member of Emoji_Modifier_Base class?
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfEmoji_Modifier_Base_Set() @safe nothrow @nogc;

/// Is member of Emoji_Component class?
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfEmoji_Component_Set() @safe nothrow @nogc;

/// Is member of Extended_Pictographic class?
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfExtended_Pictographic_Set() @safe nothrow @nogc;
