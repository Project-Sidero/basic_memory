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
export extern(C) immutable(dstring) sidero_utf_lut_getCaseFolding(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding for character.
/// Returns: null if unchanged.
export extern(C) immutable(dstring) sidero_utf_lut_getCaseFoldingTurkic(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding (simple) for character.
/// Returns: The casefolded character.
export extern(C) immutable(dchar) sidero_utf_lut_getCaseFoldingFast(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding length for character.
/// Returns: 0 if unchanged.
export extern(C) immutable(size_t) sidero_utf_lut_lengthOfCaseFolding(dchar input) @trusted nothrow @nogc pure;

/// Lookup Casefolding length for character.
/// Returns: 0 if unchanged.
export extern(C) immutable(size_t) sidero_utf_lut_lengthOfCaseFoldingTurkic(dchar input) @trusted nothrow @nogc pure;

/// Is excluded from composition.
/// Returns: false if not set.
export extern(C) bool sidero_utf_lut_isCompositionExcluded(dchar against) @safe nothrow @nogc pure;

/// Is character a hangul syllable?
export extern(C) bool sidero_utf_lut_isHangulSyllable(dchar against) @safe nothrow @nogc pure;
/// Gets the ranges of values in a given Hangul syllable type.
export immutable(ValueRange[]) sidero_utf_lut_hangulSyllables(HangulSyllableType type) @trusted nothrow @nogc pure {
    return cast(immutable(ValueRange[]))sidero_utf_lut_hangulSyllables2(type);
}
private extern(C) immutable(void[]) sidero_utf_lut_hangulSyllables2(HangulSyllableType type) @safe nothrow @nogc pure;

/// Is character part of full composition execlusions.
export extern(C) bool sidero_utf_lut_isFullCompositionExcluded(dchar against) @safe nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag None.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingNone(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Font.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingFont(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag NoBreak.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingNoBreak(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Initial.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingInitial(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Medial.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingMedial(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Final.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingFinal(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Isolated.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingIsolated(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Circle.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCircle(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Super.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSuper(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Sub.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSub(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Vertical.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingVertical(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Wide.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingWide(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Narrow.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingNarrow(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Small.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSmall(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Square.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingSquare(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Fraction.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingFraction(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if in compatibility formatting tag Compat.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCompat(dchar input) @trusted nothrow @nogc pure;

/// Lookup decomposition mapping for character if compatibility.
export extern(C) immutable(dstring) sidero_utf_lut_getDecompositionMappingCompatibility(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag None.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingNone(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Font.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingFont(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag NoBreak.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingNoBreak(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Initial.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingInitial(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Medial.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingMedial(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Final.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingFinal(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Isolated.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingIsolated(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Circle.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingCircle(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Super.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSuper(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Sub.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSub(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Vertical.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingVertical(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Wide.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingWide(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Narrow.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingNarrow(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Small.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSmall(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Square.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingSquare(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Fraction.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingFraction(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if in compatibility formatting tag Compat.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingCompat(dchar input) @trusted nothrow @nogc pure;

/// Lookup length of decomposition mapping for character if compatibility.
export extern(C) immutable(ubyte) sidero_utf_lut_lengthOfDecompositionMappingCompatibility(dchar input) @trusted nothrow @nogc pure;

/// Get decomposition map for character.
/// Returns: None for tag if unchanged.
export immutable(DecompositionMapping) sidero_utf_lut_getDecompositionMap(dchar input) @trusted nothrow @nogc pure {
    DecompositionMapping ret;
    sidero_utf_lut_getDecompositionMap2(input, &ret);
    return cast(immutable)ret;
}
export extern(C) void sidero_utf_lut_getDecompositionMap2(dchar input, void*) @trusted nothrow @nogc pure;

/// Lookup CCC for character.
/// Returns: 0 if not set.
export extern(C) immutable(ubyte) sidero_utf_lut_getCCC(dchar input) @trusted nothrow @nogc pure;

/// Get composition for character pair.
/// Returns: dchar.init if not set.
export dchar sidero_utf_lut_getCompositionCanonical(dchar L, dchar C) @trusted nothrow @nogc pure {
    ulong temp = C;
    temp <<= 32;
    temp |= L;
    return sidero_utf_lut_getCompositionCanonical2(temp);
}
export extern(C) immutable(dchar) sidero_utf_lut_getCompositionCanonical2(ulong input) @trusted nothrow @nogc pure;

/// Get composition for character pair.
/// Returns: dchar.init if not set.
export dchar sidero_utf_lut_getCompositionCompatibility(dchar L, dchar C) @trusted nothrow @nogc pure {
    ulong temp = C;
    temp <<= 32;
    temp |= L;
    return sidero_utf_lut_getCompositionCompatibility2(temp);
}
export extern(C) immutable(dchar) sidero_utf_lut_getCompositionCompatibility2(ulong input) @trusted nothrow @nogc pure;

/// Get simplified casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSimplifiedCasing(dchar input) @trusted nothrow @nogc pure {
    SpecialCasing ret;
    sidero_utf_lut_getSimplifiedCasing2(input, &ret);
    return cast(immutable)ret;
}
export extern(C) void sidero_utf_lut_getSimplifiedCasing2(dchar input, void*) @trusted nothrow @nogc pure;

/// Get length of fully decomposed for character.
export extern(C) immutable(size_t) sidero_utf_lut_lengthOfFullyDecomposed(dchar input) @trusted nothrow @nogc pure;

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

/// Lookup numeric numerator/denominator for character.
/// Returns: null if not set.
export extern(C) immutable(long[]) sidero_utf_lut_getNumeric(dchar input) @trusted nothrow @nogc pure;

/// Lookup general category for character.
export extern(C) immutable(GeneralCategory) sidero_utf_lut_getGeneralCategory(dchar input) @trusted nothrow @nogc pure;

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
export extern(C) bool sidero_utf_lut_isMemberOfWhite_Space(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfBidi_Control(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfJoin_Control(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfDash(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfHyphen(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfQuotation_Mark(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfTerminal_Punctuation(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_Math(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfHex_Digit(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfASCII_Hex_Digit(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_Alphabetic(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfIdeographic(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfDiacritic(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfExtender(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_Lowercase(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_Uppercase(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfNoncharacter_Code_Point(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_Grapheme_Extend(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfIDS_Binary_Operator(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfIDS_Trinary_Operator(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfIDS_Unary_Operator(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfRadical(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfUnified_Ideograph(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfDeprecated(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfSoft_Dotted(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfLogical_Order_Exception(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_ID_Start(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfOther_ID_Continue(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfSentence_Terminal(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfVariation_Selector(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfPattern_White_Space(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfPattern_Syntax(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfRegional_Indicator(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfID_Compat_Math_Start(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfID_Compat_Math_Continue(dchar against) @safe nothrow @nogc pure;

/// Is character member of property.
export extern(C) bool sidero_utf_lut_isMemberOfModifier_Combining_Mark(dchar against) @safe nothrow @nogc pure;

/// Is character whitespace?
alias isUnicodeWhiteSpace = sidero_utf_lut_isMemberOfWhite_Space;

/// Lookup word break property for character.
export extern(C) immutable(WordBreakProperty) sidero_utf_lut_getWordBreakProperty(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingNone(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2None(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
export extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2None(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingLithuanian(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2Lithuanian(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
export extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2Lithuanian(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingTurkish(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2Turkish(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
export extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2Turkish(dchar input) @trusted nothrow @nogc pure;

/// Get special casing for character.
/// Returns: non-null for a given entry if changed from input character.
export immutable(SpecialCasing) sidero_utf_lut_getSpecialCasingAzeri(dchar input) @trusted nothrow @nogc pure {
    auto got = sidero_utf_lut_getSpecialCasing2Azeri(input);
    if (got is null) return typeof(return).init;
    return *cast(immutable(SpecialCasing*)) got;
}
export extern(C) immutable(void*) sidero_utf_lut_getSpecialCasing2Azeri(dchar input) @trusted nothrow @nogc pure;

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

/// Get the Line break class
export extern(C) immutable(LineBreakClass) sidero_utf_lut_getLineBreakClass(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji class?
export extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Presentation class?
export extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Presentation(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Modifier class?
export extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Modifier(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Modifier_Base class?
export extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Modifier_Base(dchar input) @trusted nothrow @nogc pure;


/// Is member of Emoji_Component class?
export extern(C) immutable(bool) sidero_utf_lut_isMemberOfEmoji_Component(dchar input) @trusted nothrow @nogc pure;


/// Is member of Extended_Pictographic class?
export extern(C) immutable(bool) sidero_utf_lut_isMemberOfExtended_Pictographic(dchar input) @trusted nothrow @nogc pure;


/// Get the Script for a character
export extern(C) immutable(Script) sidero_utf_lut_getScript(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Unknown
export extern(C) immutable(bool) sidero_utf_lut_isScriptUnknown(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Hungarian
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Hungarian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Coptic
export extern(C) immutable(bool) sidero_utf_lut_isScriptCoptic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ol_Chiki
export extern(C) immutable(bool) sidero_utf_lut_isScriptOl_Chiki(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cyrillic
export extern(C) immutable(bool) sidero_utf_lut_isScriptCyrillic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Thaana
export extern(C) immutable(bool) sidero_utf_lut_isScriptThaana(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Inscriptional_Parthian
export extern(C) immutable(bool) sidero_utf_lut_isScriptInscriptional_Parthian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nabataean
export extern(C) immutable(bool) sidero_utf_lut_isScriptNabataean(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ogham
export extern(C) immutable(bool) sidero_utf_lut_isScriptOgham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Meroitic_Hieroglyphs
export extern(C) immutable(bool) sidero_utf_lut_isScriptMeroitic_Hieroglyphs(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Makasar
export extern(C) immutable(bool) sidero_utf_lut_isScriptMakasar(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Siddham
export extern(C) immutable(bool) sidero_utf_lut_isScriptSiddham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Persian
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Persian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Imperial_Aramaic
export extern(C) immutable(bool) sidero_utf_lut_isScriptImperial_Aramaic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Myanmar
export extern(C) immutable(bool) sidero_utf_lut_isScriptMyanmar(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Deseret
export extern(C) immutable(bool) sidero_utf_lut_isScriptDeseret(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kaithi
export extern(C) immutable(bool) sidero_utf_lut_isScriptKaithi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Medefaidrin
export extern(C) immutable(bool) sidero_utf_lut_isScriptMedefaidrin(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kayah_Li
export extern(C) immutable(bool) sidero_utf_lut_isScriptKayah_Li(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hiragana
export extern(C) immutable(bool) sidero_utf_lut_isScriptHiragana(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ahom
export extern(C) immutable(bool) sidero_utf_lut_isScriptAhom(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Devanagari
export extern(C) immutable(bool) sidero_utf_lut_isScriptDevanagari(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tibetan
export extern(C) immutable(bool) sidero_utf_lut_isScriptTibetan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nko
export extern(C) immutable(bool) sidero_utf_lut_isScriptNko(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Brahmi
export extern(C) immutable(bool) sidero_utf_lut_isScriptBrahmi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Osage
export extern(C) immutable(bool) sidero_utf_lut_isScriptOsage(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nushu
export extern(C) immutable(bool) sidero_utf_lut_isScriptNushu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cuneiform
export extern(C) immutable(bool) sidero_utf_lut_isScriptCuneiform(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Takri
export extern(C) immutable(bool) sidero_utf_lut_isScriptTakri(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Toto
export extern(C) immutable(bool) sidero_utf_lut_isScriptToto(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Latin
export extern(C) immutable(bool) sidero_utf_lut_isScriptLatin(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hanunoo
export extern(C) immutable(bool) sidero_utf_lut_isScriptHanunoo(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Limbu
export extern(C) immutable(bool) sidero_utf_lut_isScriptLimbu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Saurashtra
export extern(C) immutable(bool) sidero_utf_lut_isScriptSaurashtra(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lisu
export extern(C) immutable(bool) sidero_utf_lut_isScriptLisu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Egyptian_Hieroglyphs
export extern(C) immutable(bool) sidero_utf_lut_isScriptEgyptian_Hieroglyphs(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Elbasan
export extern(C) immutable(bool) sidero_utf_lut_isScriptElbasan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Palmyrene
export extern(C) immutable(bool) sidero_utf_lut_isScriptPalmyrene(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tagbanwa
export extern(C) immutable(bool) sidero_utf_lut_isScriptTagbanwa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Italic
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Italic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Caucasian_Albanian
export extern(C) immutable(bool) sidero_utf_lut_isScriptCaucasian_Albanian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Malayalam
export extern(C) immutable(bool) sidero_utf_lut_isScriptMalayalam(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Inherited
export extern(C) immutable(bool) sidero_utf_lut_isScriptInherited(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sora_Sompeng
export extern(C) immutable(bool) sidero_utf_lut_isScriptSora_Sompeng(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Linear_B
export extern(C) immutable(bool) sidero_utf_lut_isScriptLinear_B(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nyiakeng_Puachue_Hmong
export extern(C) immutable(bool) sidero_utf_lut_isScriptNyiakeng_Puachue_Hmong(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Meroitic_Cursive
export extern(C) immutable(bool) sidero_utf_lut_isScriptMeroitic_Cursive(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Thai
export extern(C) immutable(bool) sidero_utf_lut_isScriptThai(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mende_Kikakui
export extern(C) immutable(bool) sidero_utf_lut_isScriptMende_Kikakui(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Sogdian
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Sogdian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Turkic
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Turkic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Samaritan
export extern(C) immutable(bool) sidero_utf_lut_isScriptSamaritan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_South_Arabian
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_South_Arabian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hanifi_Rohingya
export extern(C) immutable(bool) sidero_utf_lut_isScriptHanifi_Rohingya(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Balinese
export extern(C) immutable(bool) sidero_utf_lut_isScriptBalinese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mandaic
export extern(C) immutable(bool) sidero_utf_lut_isScriptMandaic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script SignWriting
export extern(C) immutable(bool) sidero_utf_lut_isScriptSignWriting(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tifinagh
export extern(C) immutable(bool) sidero_utf_lut_isScriptTifinagh(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tai_Viet
export extern(C) immutable(bool) sidero_utf_lut_isScriptTai_Viet(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Syriac
export extern(C) immutable(bool) sidero_utf_lut_isScriptSyriac(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Soyombo
export extern(C) immutable(bool) sidero_utf_lut_isScriptSoyombo(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Elymaic
export extern(C) immutable(bool) sidero_utf_lut_isScriptElymaic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hatran
export extern(C) immutable(bool) sidero_utf_lut_isScriptHatran(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Chorasmian
export extern(C) immutable(bool) sidero_utf_lut_isScriptChorasmian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Glagolitic
export extern(C) immutable(bool) sidero_utf_lut_isScriptGlagolitic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Osmanya
export extern(C) immutable(bool) sidero_utf_lut_isScriptOsmanya(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Linear_A
export extern(C) immutable(bool) sidero_utf_lut_isScriptLinear_A(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mro
export extern(C) immutable(bool) sidero_utf_lut_isScriptMro(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Chakma
export extern(C) immutable(bool) sidero_utf_lut_isScriptChakma(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Modi
export extern(C) immutable(bool) sidero_utf_lut_isScriptModi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bassa_Vah
export extern(C) immutable(bool) sidero_utf_lut_isScriptBassa_Vah(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Han
export extern(C) immutable(bool) sidero_utf_lut_isScriptHan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Multani
export extern(C) immutable(bool) sidero_utf_lut_isScriptMultani(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bopomofo
export extern(C) immutable(bool) sidero_utf_lut_isScriptBopomofo(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Adlam
export extern(C) immutable(bool) sidero_utf_lut_isScriptAdlam(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khitan_Small_Script
export extern(C) immutable(bool) sidero_utf_lut_isScriptKhitan_Small_Script(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lao
export extern(C) immutable(bool) sidero_utf_lut_isScriptLao(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Psalter_Pahlavi
export extern(C) immutable(bool) sidero_utf_lut_isScriptPsalter_Pahlavi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Anatolian_Hieroglyphs
export extern(C) immutable(bool) sidero_utf_lut_isScriptAnatolian_Hieroglyphs(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Canadian_Aboriginal
export extern(C) immutable(bool) sidero_utf_lut_isScriptCanadian_Aboriginal(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Common
export extern(C) immutable(bool) sidero_utf_lut_isScriptCommon(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gothic
export extern(C) immutable(bool) sidero_utf_lut_isScriptGothic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Yi
export extern(C) immutable(bool) sidero_utf_lut_isScriptYi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sinhala
export extern(C) immutable(bool) sidero_utf_lut_isScriptSinhala(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Rejang
export extern(C) immutable(bool) sidero_utf_lut_isScriptRejang(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lepcha
export extern(C) immutable(bool) sidero_utf_lut_isScriptLepcha(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tai_Tham
export extern(C) immutable(bool) sidero_utf_lut_isScriptTai_Tham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Dives_Akuru
export extern(C) immutable(bool) sidero_utf_lut_isScriptDives_Akuru(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Meetei_Mayek
export extern(C) immutable(bool) sidero_utf_lut_isScriptMeetei_Mayek(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tirhuta
export extern(C) immutable(bool) sidero_utf_lut_isScriptTirhuta(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Marchen
export extern(C) immutable(bool) sidero_utf_lut_isScriptMarchen(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Wancho
export extern(C) immutable(bool) sidero_utf_lut_isScriptWancho(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Phoenician
export extern(C) immutable(bool) sidero_utf_lut_isScriptPhoenician(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gurmukhi
export extern(C) immutable(bool) sidero_utf_lut_isScriptGurmukhi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khudawadi
export extern(C) immutable(bool) sidero_utf_lut_isScriptKhudawadi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khojki
export extern(C) immutable(bool) sidero_utf_lut_isScriptKhojki(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Newa
export extern(C) immutable(bool) sidero_utf_lut_isScriptNewa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Dogra
export extern(C) immutable(bool) sidero_utf_lut_isScriptDogra(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Oriya
export extern(C) immutable(bool) sidero_utf_lut_isScriptOriya(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tagalog
export extern(C) immutable(bool) sidero_utf_lut_isScriptTagalog(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sundanese
export extern(C) immutable(bool) sidero_utf_lut_isScriptSundanese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Permic
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Permic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Shavian
export extern(C) immutable(bool) sidero_utf_lut_isScriptShavian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lycian
export extern(C) immutable(bool) sidero_utf_lut_isScriptLycian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Miao
export extern(C) immutable(bool) sidero_utf_lut_isScriptMiao(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tangut
export extern(C) immutable(bool) sidero_utf_lut_isScriptTangut(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bengali
export extern(C) immutable(bool) sidero_utf_lut_isScriptBengali(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Inscriptional_Pahlavi
export extern(C) immutable(bool) sidero_utf_lut_isScriptInscriptional_Pahlavi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Vithkuqi
export extern(C) immutable(bool) sidero_utf_lut_isScriptVithkuqi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Armenian
export extern(C) immutable(bool) sidero_utf_lut_isScriptArmenian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script New_Tai_Lue
export extern(C) immutable(bool) sidero_utf_lut_isScriptNew_Tai_Lue(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sogdian
export extern(C) immutable(bool) sidero_utf_lut_isScriptSogdian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Buhid
export extern(C) immutable(bool) sidero_utf_lut_isScriptBuhid(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Manichaean
export extern(C) immutable(bool) sidero_utf_lut_isScriptManichaean(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Greek
export extern(C) immutable(bool) sidero_utf_lut_isScriptGreek(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Braille
export extern(C) immutable(bool) sidero_utf_lut_isScriptBraille(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Avestan
export extern(C) immutable(bool) sidero_utf_lut_isScriptAvestan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Arabic
export extern(C) immutable(bool) sidero_utf_lut_isScriptArabic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Javanese
export extern(C) immutable(bool) sidero_utf_lut_isScriptJavanese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Lydian
export extern(C) immutable(bool) sidero_utf_lut_isScriptLydian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Pau_Cin_Hau
export extern(C) immutable(bool) sidero_utf_lut_isScriptPau_Cin_Hau(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cypro_Minoan
export extern(C) immutable(bool) sidero_utf_lut_isScriptCypro_Minoan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Buginese
export extern(C) immutable(bool) sidero_utf_lut_isScriptBuginese(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Batak
export extern(C) immutable(bool) sidero_utf_lut_isScriptBatak(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nandinagari
export extern(C) immutable(bool) sidero_utf_lut_isScriptNandinagari(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cham
export extern(C) immutable(bool) sidero_utf_lut_isScriptCham(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gunjala_Gondi
export extern(C) immutable(bool) sidero_utf_lut_isScriptGunjala_Gondi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cypriot
export extern(C) immutable(bool) sidero_utf_lut_isScriptCypriot(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ugaritic
export extern(C) immutable(bool) sidero_utf_lut_isScriptUgaritic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Georgian
export extern(C) immutable(bool) sidero_utf_lut_isScriptGeorgian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sharada
export extern(C) immutable(bool) sidero_utf_lut_isScriptSharada(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tamil
export extern(C) immutable(bool) sidero_utf_lut_isScriptTamil(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Cherokee
export extern(C) immutable(bool) sidero_utf_lut_isScriptCherokee(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Pahawh_Hmong
export extern(C) immutable(bool) sidero_utf_lut_isScriptPahawh_Hmong(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Syloti_Nagri
export extern(C) immutable(bool) sidero_utf_lut_isScriptSyloti_Nagri(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kharoshthi
export extern(C) immutable(bool) sidero_utf_lut_isScriptKharoshthi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Zanabazar_Square
export extern(C) immutable(bool) sidero_utf_lut_isScriptZanabazar_Square(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Katakana
export extern(C) immutable(bool) sidero_utf_lut_isScriptKatakana(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Telugu
export extern(C) immutable(bool) sidero_utf_lut_isScriptTelugu(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ethiopic
export extern(C) immutable(bool) sidero_utf_lut_isScriptEthiopic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Vai
export extern(C) immutable(bool) sidero_utf_lut_isScriptVai(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bamum
export extern(C) immutable(bool) sidero_utf_lut_isScriptBamum(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hangul
export extern(C) immutable(bool) sidero_utf_lut_isScriptHangul(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mongolian
export extern(C) immutable(bool) sidero_utf_lut_isScriptMongolian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_Uyghur
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_Uyghur(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Mahajani
export extern(C) immutable(bool) sidero_utf_lut_isScriptMahajani(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Khmer
export extern(C) immutable(bool) sidero_utf_lut_isScriptKhmer(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Grantha
export extern(C) immutable(bool) sidero_utf_lut_isScriptGrantha(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kannada
export extern(C) immutable(bool) sidero_utf_lut_isScriptKannada(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Yezidi
export extern(C) immutable(bool) sidero_utf_lut_isScriptYezidi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Old_North_Arabian
export extern(C) immutable(bool) sidero_utf_lut_isScriptOld_North_Arabian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tai_Le
export extern(C) immutable(bool) sidero_utf_lut_isScriptTai_Le(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Hebrew
export extern(C) immutable(bool) sidero_utf_lut_isScriptHebrew(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gujarati
export extern(C) immutable(bool) sidero_utf_lut_isScriptGujarati(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tangsa
export extern(C) immutable(bool) sidero_utf_lut_isScriptTangsa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Carian
export extern(C) immutable(bool) sidero_utf_lut_isScriptCarian(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Bhaiksuki
export extern(C) immutable(bool) sidero_utf_lut_isScriptBhaiksuki(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Masaram_Gondi
export extern(C) immutable(bool) sidero_utf_lut_isScriptMasaram_Gondi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Runic
export extern(C) immutable(bool) sidero_utf_lut_isScriptRunic(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Duployan
export extern(C) immutable(bool) sidero_utf_lut_isScriptDuployan(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Warang_Citi
export extern(C) immutable(bool) sidero_utf_lut_isScriptWarang_Citi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Phags_Pa
export extern(C) immutable(bool) sidero_utf_lut_isScriptPhags_Pa(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kawi
export extern(C) immutable(bool) sidero_utf_lut_isScriptKawi(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Nag_Mundari
export extern(C) immutable(bool) sidero_utf_lut_isScriptNag_Mundari(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Garay
export extern(C) immutable(bool) sidero_utf_lut_isScriptGaray(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Gurung_Khema
export extern(C) immutable(bool) sidero_utf_lut_isScriptGurung_Khema(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Kirat_Rai
export extern(C) immutable(bool) sidero_utf_lut_isScriptKirat_Rai(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Ol_Onal
export extern(C) immutable(bool) sidero_utf_lut_isScriptOl_Onal(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Sunuwar
export extern(C) immutable(bool) sidero_utf_lut_isScriptSunuwar(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Todhri
export extern(C) immutable(bool) sidero_utf_lut_isScriptTodhri(dchar input) @trusted nothrow @nogc pure;

/// Is the character a member of the script Tulu_Tigalari
export extern(C) immutable(bool) sidero_utf_lut_isScriptTulu_Tigalari(dchar input) @trusted nothrow @nogc pure;


/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemePrepend(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeCR(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeLF(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeControl(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeExtend(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeRegional_Indicator(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeSpacingMark(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeL(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeV(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeT(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeLV(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeLVT(dchar against) @safe nothrow @nogc pure;

/// Is character member of grapheme break property.
export extern(C) bool sidero_utf_lut_isMemberOfGraphemeZWJ(dchar against) @safe nothrow @nogc pure;
