/**
 Unicode database access routines
 License: Artistic-v2
*/
module sidero.base.text.unicode.database;
// Generated do not modify

/// Add 1 to end to foreach
struct ValueRange {
    ///
    dchar start, end;
    @safe nothrow @nogc pure const:

    this(dchar index) {
        this.start = index;
        this.end = index;
    }

    this(dchar start, dchar end) {
        assert(end >= start);

        this.start = start;
        this.end = end;
    }

    ///
    size_t spread() {
        return cast(size_t)((end + 1) - start);
    }

    /// Does argument fall within range. start <= index <= end.
    bool within(dchar index) {
        return start <= index && end >= index;
    }
}

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

// Is character cased
bool isUnicodeCased(dchar input) @safe nothrow @nogc pure {
    switch(sidero_utf_lut_getGeneralCategory(input)) {
        case GeneralCategory.Lt:
        case GeneralCategory.Ll:
        case GeneralCategory.Lu:
            return true;

        default:
            return sidero_utf_lut_isMemberOfOther_Lowercase(input) || sidero_utf_lut_isMemberOfOther_Uppercase(input);
    }
}

// Is character Grapheme extend
bool isUnicodeGraphemeExtend(dchar input) @safe nothrow @nogc pure {
    switch(sidero_utf_lut_getGeneralCategory(input)) {
        case GeneralCategory.Me:
        case GeneralCategory.Mn:
            return true;
        default:
            return sidero_utf_lut_isMemberOfOther_Grapheme_Extend(input);
    }
}


/// Lookup Casefolding for character.
/// Returns: null if unchanged.
extern(C) immutable(dstring) sidero_utf_lut_getCaseFolding(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding for character.
/// Returns: null if unchanged.
extern(C) immutable(dstring) sidero_utf_lut_getCaseFoldingTurkic(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding (simple) for character.
/// Returns: The casefolded character.
extern(C) immutable(dchar) sidero_utf_lut_getCaseFoldingFast(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding length for character.
/// Returns: 0 if unchanged.
extern(C) immutable(size_t) sidero_utf_lut_lengthOfCaseFolding(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding length for character.
/// Returns: 0 if unchanged.
extern(C) immutable(size_t) sidero_utf_lut_lengthOfCaseFoldingTurkic(dchar input) @trusted nothrow @nogc pure;

/// Is excluded from composition.
/// Returns: false if not set.
extern(C) immutable(bool) sidero_utf_lut_isCompositionExcluded(dchar input) @trusted nothrow @nogc pure;

/// Is character a hangul syllable?
extern(C) immutable(bool) sidero_utf_lut_isHangulSyllable(dchar input) @trusted nothrow @nogc pure;

/// Gets the ranges of values in a given Hangul syllable type.
export immutable(ValueRange[]) sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc pure {
    return cast(immutable(ValueRange[]))sidero_utf_lut_hangulSyllables2(type);
}
private extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure;

/// Is character part of full composition execlusions.
extern(C) immutable(bool) sidero_utf_lut_isFullCompositionExcluded(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag None.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingNone(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Font.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingFont(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag NoBreak.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingNoBreak(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Initial.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingInitial(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Medial.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingMedial(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Final.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingFinal(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Isolated.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingIsolated(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Circle.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCircle(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Super.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSuper(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Sub.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSub(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Vertical.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingVertical(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Wide.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingWide(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Narrow.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingNarrow(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Small.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSmall(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Square.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSquare(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Fraction.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingFraction(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Compat.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCompat(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag None.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingNone(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Font.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingFont(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag NoBreak.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingNoBreak(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Initial.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingInitial(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Medial.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingMedial(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Final.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingFinal(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Isolated.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingIsolated(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Circle.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingCircle(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Super.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSuper(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Sub.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSub(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Vertical.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingVertical(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Wide.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingWide(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Narrow.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingNarrow(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Small.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSmall(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Square.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSquare(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Fraction.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingFraction(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Compat.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingCompat(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if compatibility.
extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCompatibility(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if compatibility.
extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingCompatibility(dchar input) @trusted nothrow @nogc pure;

/// Get decomposition map for character.
/// Returns: null if unchanged.
export immutable(DecompositionMapping) sidero_utf_lut_getDecompositionMap(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getDecompositionMap2(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(DecompositionMapping*)) got;
}
extern(C) immutable(void*) sidero_utf_lut_getDecompositionMap2(dchar input) @trusted nothrow @nogc pure;

/// Get length of fully decomposed for character.
extern(C) immutable(size_t) sidero_utf_lut_lengthOfFullyDecomposed(dchar input) @trusted nothrow @nogc pure;

/// Get composition for character pair.
/// Returns: dchar.init if not set.
export dchar sidero_utf_lut_getCompositionCanonical(dchar L, dchar C) @trusted nothrow @nogc pure {
    ulong temp = C;
    temp <<= 32;
    temp |= L;
    return sidero_utf_lut_getCompositionCanonical2(temp);
}
extern(C) immutable(dchar) sidero_utf_lut_getCompositionCanonical2(ulong input) @trusted nothrow @nogc pure;

/// Get composition for character pair.
/// Returns: dchar.init if not set.
export dchar sidero_utf_lut_getCompositionCompatibility(dchar L, dchar C) @trusted nothrow @nogc pure {
    ulong temp = C;
    temp <<= 32;
    temp |= L;
    return sidero_utf_lut_getCompositionCompatibility2(temp);
}
extern(C) immutable(dchar) sidero_utf_lut_getCompositionCompatibility2(ulong input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if canonical.
alias sidero_utf_lut_getDecompositionMappingCanonical = sidero_utf_lut_getDecompositionMappingNone;

/// Lookup decomposition mapping length for character if canonical.
alias sidero_utf_lut_lengthOfDecompositionMappingCanonical = sidero_utf_lut_lengthOfDecompositionMappingNone;

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

/// Lookup CCC for character.
/// Returns: 0 if not set.
extern(C) immutable(ubyte) sidero_utf_lut_getCCC(dchar input) @trusted nothrow @nogc pure;

/// Get simplified casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSimplifiedCasing(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSimplifiedCasing2(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
extern(C) immutable(void*) sidero_utf_lut_getSimplifiedCasing2(dchar input) @trusted nothrow @nogc pure;

/// Lookup general category for character.
extern(C) immutable(GeneralCategory) sidero_utf_lut_getGeneralCategory(dchar input) @trusted nothrow @nogc pure;

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

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfWhite_Space(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfBidi_Control(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfJoin_Control(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfDash(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfHyphen(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfQuotation_Mark(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfTerminal_Punctuation(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_Math(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfHex_Digit(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfASCII_Hex_Digit(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_Alphabetic(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfIdeographic(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfDiacritic(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfExtender(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_Lowercase(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_Uppercase(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfNoncharacter_Code_Point(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_Grapheme_Extend(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfIDS_Binary_Operator(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfIDS_Trinary_Operator(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfRadical(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfUnified_Ideograph(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfDeprecated(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfSoft_Dotted(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfLogical_Order_Exception(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_ID_Start(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfOther_ID_Continue(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfSentence_Terminal(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfVariation_Selector(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfPattern_White_Space(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfPattern_Syntax(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark(dchar input) @trusted nothrow @nogc pure;

/// Is character member of property.
extern(C) immutable(bool) sidero_utf_lut_isMemberOfRegional_Indicator(dchar input) @trusted nothrow @nogc pure;

/// Is character whitespace?
alias isUnicodeWhiteSpace = sidero_utf_lut_isMemberOfWhite_Space;

/// Lookup word break property for character.
extern(C) immutable(WordBreakProperty) sidero_utf_lut_getWordBreakProperty(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingNone(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2None(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2None(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingLithuanian(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2Lithuanian(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2Lithuanian(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingTurkish(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2Turkish(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2Turkish(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingAzeri(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2Azeri(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2Azeri(dchar input) @trusted nothrow @nogc pure;

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

    if (got is null)
        got = cast(void*)sidero_utf_lut_getSimplifiedCasing2(input);

    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}

/// Get casing for character in regards to turkic or simplified mapping.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingTurkic(dchar input) @trusted nothrow @nogc pure {
    void* got = cast(void*)sidero_utf_lut_getSpecialCasing2Turkish(input);
    if (got is null)
        got = cast(void*)sidero_utf_lut_getSpecialCasing2Azeri(input);
    if (got is null)
        got = cast(void*)sidero_utf_lut_getSpecialCasing2None(input);
    if (got is null)
        got = cast(void*)sidero_utf_lut_getSimplifiedCasing2(input);

    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}

/// Get the Line break class
extern(C) immutable(LineBreakClass) sidero_utf_lut_getLineBreakClass(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji class?
extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Presentation class?
extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Presentation(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Modifier class?
extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Modifier(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Modifier_Base class?
extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Modifier_Base(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Component class?
extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Component(dchar input) @trusted nothrow @nogc pure;


/// Is member of Extended_Pictographic class?
extern(C) immutable(bool) sidero_utf_lut_isMemberOfExtended_Pictographic(dchar input) @trusted nothrow @nogc pure;


/// Get the Script for a character
extern(C) immutable(Script) sidero_utf_lut_getScript(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Unknown
extern(C) immutable(bool) sidero_utf_lut_isScriptUnknown(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Hungarian
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Hungarian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Coptic
extern(C) immutable(bool) sidero_utf_lut_isScriptCoptic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ol_Chiki
extern(C) immutable(bool) sidero_utf_lut_isScriptOl_Chiki(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cyrillic
extern(C) immutable(bool) sidero_utf_lut_isScriptCyrillic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Thaana
extern(C) immutable(bool) sidero_utf_lut_isScriptThaana(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Inscriptional_Parthian
extern(C) immutable(bool) sidero_utf_lut_isScriptInscriptional_Parthian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nabataean
extern(C) immutable(bool) sidero_utf_lut_isScriptNabataean(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ogham
extern(C) immutable(bool) sidero_utf_lut_isScriptOgham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Meroitic_Hieroglyphs
extern(C) immutable(bool) sidero_utf_lut_isScriptMeroitic_Hieroglyphs(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Makasar
extern(C) immutable(bool) sidero_utf_lut_isScriptMakasar(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Siddham
extern(C) immutable(bool) sidero_utf_lut_isScriptSiddham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Persian
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Persian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Imperial_Aramaic
extern(C) immutable(bool) sidero_utf_lut_isScriptImperial_Aramaic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Myanmar
extern(C) immutable(bool) sidero_utf_lut_isScriptMyanmar(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Deseret
extern(C) immutable(bool) sidero_utf_lut_isScriptDeseret(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kaithi
extern(C) immutable(bool) sidero_utf_lut_isScriptKaithi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Medefaidrin
extern(C) immutable(bool) sidero_utf_lut_isScriptMedefaidrin(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kayah_Li
extern(C) immutable(bool) sidero_utf_lut_isScriptKayah_Li(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hiragana
extern(C) immutable(bool) sidero_utf_lut_isScriptHiragana(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ahom
extern(C) immutable(bool) sidero_utf_lut_isScriptAhom(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Devanagari
extern(C) immutable(bool) sidero_utf_lut_isScriptDevanagari(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tibetan
extern(C) immutable(bool) sidero_utf_lut_isScriptTibetan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nko
extern(C) immutable(bool) sidero_utf_lut_isScriptNko(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Brahmi
extern(C) immutable(bool) sidero_utf_lut_isScriptBrahmi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Osage
extern(C) immutable(bool) sidero_utf_lut_isScriptOsage(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nushu
extern(C) immutable(bool) sidero_utf_lut_isScriptNushu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cuneiform
extern(C) immutable(bool) sidero_utf_lut_isScriptCuneiform(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Takri
extern(C) immutable(bool) sidero_utf_lut_isScriptTakri(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Toto
extern(C) immutable(bool) sidero_utf_lut_isScriptToto(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Latin
extern(C) immutable(bool) sidero_utf_lut_isScriptLatin(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hanunoo
extern(C) immutable(bool) sidero_utf_lut_isScriptHanunoo(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Limbu
extern(C) immutable(bool) sidero_utf_lut_isScriptLimbu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Saurashtra
extern(C) immutable(bool) sidero_utf_lut_isScriptSaurashtra(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lisu
extern(C) immutable(bool) sidero_utf_lut_isScriptLisu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Egyptian_Hieroglyphs
extern(C) immutable(bool) sidero_utf_lut_isScriptEgyptian_Hieroglyphs(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Elbasan
extern(C) immutable(bool) sidero_utf_lut_isScriptElbasan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Palmyrene
extern(C) immutable(bool) sidero_utf_lut_isScriptPalmyrene(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tagbanwa
extern(C) immutable(bool) sidero_utf_lut_isScriptTagbanwa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Italic
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Italic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Caucasian_Albanian
extern(C) immutable(bool) sidero_utf_lut_isScriptCaucasian_Albanian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Malayalam
extern(C) immutable(bool) sidero_utf_lut_isScriptMalayalam(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Inherited
extern(C) immutable(bool) sidero_utf_lut_isScriptInherited(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sora_Sompeng
extern(C) immutable(bool) sidero_utf_lut_isScriptSora_Sompeng(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Linear_B
extern(C) immutable(bool) sidero_utf_lut_isScriptLinear_B(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nyiakeng_Puachue_Hmong
extern(C) immutable(bool) sidero_utf_lut_isScriptNyiakeng_Puachue_Hmong(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Meroitic_Cursive
extern(C) immutable(bool) sidero_utf_lut_isScriptMeroitic_Cursive(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Thai
extern(C) immutable(bool) sidero_utf_lut_isScriptThai(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mende_Kikakui
extern(C) immutable(bool) sidero_utf_lut_isScriptMende_Kikakui(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Sogdian
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Sogdian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Turkic
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Turkic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Samaritan
extern(C) immutable(bool) sidero_utf_lut_isScriptSamaritan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_South_Arabian
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_South_Arabian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hanifi_Rohingya
extern(C) immutable(bool) sidero_utf_lut_isScriptHanifi_Rohingya(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Balinese
extern(C) immutable(bool) sidero_utf_lut_isScriptBalinese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mandaic
extern(C) immutable(bool) sidero_utf_lut_isScriptMandaic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script SignWriting
extern(C) immutable(bool) sidero_utf_lut_isScriptSignWriting(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tifinagh
extern(C) immutable(bool) sidero_utf_lut_isScriptTifinagh(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tai_Viet
extern(C) immutable(bool) sidero_utf_lut_isScriptTai_Viet(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Syriac
extern(C) immutable(bool) sidero_utf_lut_isScriptSyriac(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Soyombo
extern(C) immutable(bool) sidero_utf_lut_isScriptSoyombo(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Elymaic
extern(C) immutable(bool) sidero_utf_lut_isScriptElymaic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hatran
extern(C) immutable(bool) sidero_utf_lut_isScriptHatran(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Chorasmian
extern(C) immutable(bool) sidero_utf_lut_isScriptChorasmian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Glagolitic
extern(C) immutable(bool) sidero_utf_lut_isScriptGlagolitic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Osmanya
extern(C) immutable(bool) sidero_utf_lut_isScriptOsmanya(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Linear_A
extern(C) immutable(bool) sidero_utf_lut_isScriptLinear_A(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mro
extern(C) immutable(bool) sidero_utf_lut_isScriptMro(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Chakma
extern(C) immutable(bool) sidero_utf_lut_isScriptChakma(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Modi
extern(C) immutable(bool) sidero_utf_lut_isScriptModi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bassa_Vah
extern(C) immutable(bool) sidero_utf_lut_isScriptBassa_Vah(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Han
extern(C) immutable(bool) sidero_utf_lut_isScriptHan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Multani
extern(C) immutable(bool) sidero_utf_lut_isScriptMultani(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bopomofo
extern(C) immutable(bool) sidero_utf_lut_isScriptBopomofo(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Adlam
extern(C) immutable(bool) sidero_utf_lut_isScriptAdlam(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khitan_Small_Script
extern(C) immutable(bool) sidero_utf_lut_isScriptKhitan_Small_Script(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lao
extern(C) immutable(bool) sidero_utf_lut_isScriptLao(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Psalter_Pahlavi
extern(C) immutable(bool) sidero_utf_lut_isScriptPsalter_Pahlavi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Anatolian_Hieroglyphs
extern(C) immutable(bool) sidero_utf_lut_isScriptAnatolian_Hieroglyphs(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Canadian_Aboriginal
extern(C) immutable(bool) sidero_utf_lut_isScriptCanadian_Aboriginal(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Common
extern(C) immutable(bool) sidero_utf_lut_isScriptCommon(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gothic
extern(C) immutable(bool) sidero_utf_lut_isScriptGothic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Yi
extern(C) immutable(bool) sidero_utf_lut_isScriptYi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sinhala
extern(C) immutable(bool) sidero_utf_lut_isScriptSinhala(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Rejang
extern(C) immutable(bool) sidero_utf_lut_isScriptRejang(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lepcha
extern(C) immutable(bool) sidero_utf_lut_isScriptLepcha(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tai_Tham
extern(C) immutable(bool) sidero_utf_lut_isScriptTai_Tham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Dives_Akuru
extern(C) immutable(bool) sidero_utf_lut_isScriptDives_Akuru(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Meetei_Mayek
extern(C) immutable(bool) sidero_utf_lut_isScriptMeetei_Mayek(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tirhuta
extern(C) immutable(bool) sidero_utf_lut_isScriptTirhuta(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Marchen
extern(C) immutable(bool) sidero_utf_lut_isScriptMarchen(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Wancho
extern(C) immutable(bool) sidero_utf_lut_isScriptWancho(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Phoenician
extern(C) immutable(bool) sidero_utf_lut_isScriptPhoenician(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gurmukhi
extern(C) immutable(bool) sidero_utf_lut_isScriptGurmukhi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khudawadi
extern(C) immutable(bool) sidero_utf_lut_isScriptKhudawadi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khojki
extern(C) immutable(bool) sidero_utf_lut_isScriptKhojki(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Newa
extern(C) immutable(bool) sidero_utf_lut_isScriptNewa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Dogra
extern(C) immutable(bool) sidero_utf_lut_isScriptDogra(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Oriya
extern(C) immutable(bool) sidero_utf_lut_isScriptOriya(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tagalog
extern(C) immutable(bool) sidero_utf_lut_isScriptTagalog(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sundanese
extern(C) immutable(bool) sidero_utf_lut_isScriptSundanese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Permic
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Permic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Shavian
extern(C) immutable(bool) sidero_utf_lut_isScriptShavian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lycian
extern(C) immutable(bool) sidero_utf_lut_isScriptLycian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Miao
extern(C) immutable(bool) sidero_utf_lut_isScriptMiao(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tangut
extern(C) immutable(bool) sidero_utf_lut_isScriptTangut(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bengali
extern(C) immutable(bool) sidero_utf_lut_isScriptBengali(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Inscriptional_Pahlavi
extern(C) immutable(bool) sidero_utf_lut_isScriptInscriptional_Pahlavi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Vithkuqi
extern(C) immutable(bool) sidero_utf_lut_isScriptVithkuqi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Armenian
extern(C) immutable(bool) sidero_utf_lut_isScriptArmenian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script New_Tai_Lue
extern(C) immutable(bool) sidero_utf_lut_isScriptNew_Tai_Lue(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sogdian
extern(C) immutable(bool) sidero_utf_lut_isScriptSogdian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Buhid
extern(C) immutable(bool) sidero_utf_lut_isScriptBuhid(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Manichaean
extern(C) immutable(bool) sidero_utf_lut_isScriptManichaean(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Greek
extern(C) immutable(bool) sidero_utf_lut_isScriptGreek(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Braille
extern(C) immutable(bool) sidero_utf_lut_isScriptBraille(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Avestan
extern(C) immutable(bool) sidero_utf_lut_isScriptAvestan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Arabic
extern(C) immutable(bool) sidero_utf_lut_isScriptArabic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Javanese
extern(C) immutable(bool) sidero_utf_lut_isScriptJavanese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lydian
extern(C) immutable(bool) sidero_utf_lut_isScriptLydian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Pau_Cin_Hau
extern(C) immutable(bool) sidero_utf_lut_isScriptPau_Cin_Hau(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cypro_Minoan
extern(C) immutable(bool) sidero_utf_lut_isScriptCypro_Minoan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Buginese
extern(C) immutable(bool) sidero_utf_lut_isScriptBuginese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Batak
extern(C) immutable(bool) sidero_utf_lut_isScriptBatak(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nandinagari
extern(C) immutable(bool) sidero_utf_lut_isScriptNandinagari(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cham
extern(C) immutable(bool) sidero_utf_lut_isScriptCham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gunjala_Gondi
extern(C) immutable(bool) sidero_utf_lut_isScriptGunjala_Gondi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cypriot
extern(C) immutable(bool) sidero_utf_lut_isScriptCypriot(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ugaritic
extern(C) immutable(bool) sidero_utf_lut_isScriptUgaritic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Georgian
extern(C) immutable(bool) sidero_utf_lut_isScriptGeorgian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sharada
extern(C) immutable(bool) sidero_utf_lut_isScriptSharada(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tamil
extern(C) immutable(bool) sidero_utf_lut_isScriptTamil(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cherokee
extern(C) immutable(bool) sidero_utf_lut_isScriptCherokee(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Pahawh_Hmong
extern(C) immutable(bool) sidero_utf_lut_isScriptPahawh_Hmong(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Syloti_Nagri
extern(C) immutable(bool) sidero_utf_lut_isScriptSyloti_Nagri(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kharoshthi
extern(C) immutable(bool) sidero_utf_lut_isScriptKharoshthi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Zanabazar_Square
extern(C) immutable(bool) sidero_utf_lut_isScriptZanabazar_Square(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Katakana
extern(C) immutable(bool) sidero_utf_lut_isScriptKatakana(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Telugu
extern(C) immutable(bool) sidero_utf_lut_isScriptTelugu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ethiopic
extern(C) immutable(bool) sidero_utf_lut_isScriptEthiopic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Vai
extern(C) immutable(bool) sidero_utf_lut_isScriptVai(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bamum
extern(C) immutable(bool) sidero_utf_lut_isScriptBamum(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hangul
extern(C) immutable(bool) sidero_utf_lut_isScriptHangul(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mongolian
extern(C) immutable(bool) sidero_utf_lut_isScriptMongolian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Uyghur
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Uyghur(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mahajani
extern(C) immutable(bool) sidero_utf_lut_isScriptMahajani(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khmer
extern(C) immutable(bool) sidero_utf_lut_isScriptKhmer(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Grantha
extern(C) immutable(bool) sidero_utf_lut_isScriptGrantha(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kannada
extern(C) immutable(bool) sidero_utf_lut_isScriptKannada(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Yezidi
extern(C) immutable(bool) sidero_utf_lut_isScriptYezidi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_North_Arabian
extern(C) immutable(bool) sidero_utf_lut_isScriptOld_North_Arabian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tai_Le
extern(C) immutable(bool) sidero_utf_lut_isScriptTai_Le(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hebrew
extern(C) immutable(bool) sidero_utf_lut_isScriptHebrew(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gujarati
extern(C) immutable(bool) sidero_utf_lut_isScriptGujarati(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tangsa
extern(C) immutable(bool) sidero_utf_lut_isScriptTangsa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Carian
extern(C) immutable(bool) sidero_utf_lut_isScriptCarian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bhaiksuki
extern(C) immutable(bool) sidero_utf_lut_isScriptBhaiksuki(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Masaram_Gondi
extern(C) immutable(bool) sidero_utf_lut_isScriptMasaram_Gondi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Runic
extern(C) immutable(bool) sidero_utf_lut_isScriptRunic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Duployan
extern(C) immutable(bool) sidero_utf_lut_isScriptDuployan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Warang_Citi
extern(C) immutable(bool) sidero_utf_lut_isScriptWarang_Citi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Phags_Pa
extern(C) immutable(bool) sidero_utf_lut_isScriptPhags_Pa(dchar input) @trusted nothrow @nogc pure;

