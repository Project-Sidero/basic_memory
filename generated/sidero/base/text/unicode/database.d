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

/// Lookup CCC for character.
/// Returns: 0 if not set.
export extern(C) ubyte sidero_utf_lut_getCCC(dchar against) @safe nothrow @nogc pure;

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
export extern(C) WordBreakProperty sidero_utf_lut_getWordBreakProperty(dchar against) @safe nothrow @nogc pure;

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
export extern(C) LineBreakClass sidero_utf_lut_getLineBreakClass(dchar against) @safe nothrow @nogc pure;

/// Is member of Emoji class?
export extern(C) bool sidero_utf_lut_isMemberOfEmoji(dchar against) @safe nothrow @nogc pure;

/// Is member of Emoji_Presentation class?
export extern(C) bool sidero_utf_lut_isMemberOfEmoji_Presentation(dchar against) @safe nothrow @nogc pure;

/// Is member of Emoji_Modifier class?
export extern(C) bool sidero_utf_lut_isMemberOfEmoji_Modifier(dchar against) @safe nothrow @nogc pure;

/// Is member of Emoji_Modifier_Base class?
export extern(C) bool sidero_utf_lut_isMemberOfEmoji_Modifier_Base(dchar against) @safe nothrow @nogc pure;

/// Is member of Emoji_Component class?
export extern(C) bool sidero_utf_lut_isMemberOfEmoji_Component(dchar against) @safe nothrow @nogc pure;

/// Is member of Extended_Pictographic class?
export extern(C) bool sidero_utf_lut_isMemberOfExtended_Pictographic(dchar against) @safe nothrow @nogc pure;

/// Get the Script for a character
export extern(C) Script sidero_utf_lut_getScript(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Unknown
export extern(C) bool sidero_utf_lut_isScriptUnkown(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Hungarian
export extern(C) bool sidero_utf_lut_isScriptOld_Hungarian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Coptic
export extern(C) bool sidero_utf_lut_isScriptCoptic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Ol_Chiki
export extern(C) bool sidero_utf_lut_isScriptOl_Chiki(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Cyrillic
export extern(C) bool sidero_utf_lut_isScriptCyrillic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Thaana
export extern(C) bool sidero_utf_lut_isScriptThaana(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Inscriptional_Parthian
export extern(C) bool sidero_utf_lut_isScriptInscriptional_Parthian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Nabataean
export extern(C) bool sidero_utf_lut_isScriptNabataean(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Ogham
export extern(C) bool sidero_utf_lut_isScriptOgham(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Meroitic_Hieroglyphs
export extern(C) bool sidero_utf_lut_isScriptMeroitic_Hieroglyphs(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Makasar
export extern(C) bool sidero_utf_lut_isScriptMakasar(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Siddham
export extern(C) bool sidero_utf_lut_isScriptSiddham(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Persian
export extern(C) bool sidero_utf_lut_isScriptOld_Persian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Imperial_Aramaic
export extern(C) bool sidero_utf_lut_isScriptImperial_Aramaic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Myanmar
export extern(C) bool sidero_utf_lut_isScriptMyanmar(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Deseret
export extern(C) bool sidero_utf_lut_isScriptDeseret(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Kaithi
export extern(C) bool sidero_utf_lut_isScriptKaithi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Medefaidrin
export extern(C) bool sidero_utf_lut_isScriptMedefaidrin(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Kayah_Li
export extern(C) bool sidero_utf_lut_isScriptKayah_Li(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Hiragana
export extern(C) bool sidero_utf_lut_isScriptHiragana(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Ahom
export extern(C) bool sidero_utf_lut_isScriptAhom(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Devanagari
export extern(C) bool sidero_utf_lut_isScriptDevanagari(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tibetan
export extern(C) bool sidero_utf_lut_isScriptTibetan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Nko
export extern(C) bool sidero_utf_lut_isScriptNko(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Brahmi
export extern(C) bool sidero_utf_lut_isScriptBrahmi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Osage
export extern(C) bool sidero_utf_lut_isScriptOsage(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Nushu
export extern(C) bool sidero_utf_lut_isScriptNushu(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Cuneiform
export extern(C) bool sidero_utf_lut_isScriptCuneiform(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Takri
export extern(C) bool sidero_utf_lut_isScriptTakri(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Toto
export extern(C) bool sidero_utf_lut_isScriptToto(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Latin
export extern(C) bool sidero_utf_lut_isScriptLatin(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Hanunoo
export extern(C) bool sidero_utf_lut_isScriptHanunoo(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Limbu
export extern(C) bool sidero_utf_lut_isScriptLimbu(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Saurashtra
export extern(C) bool sidero_utf_lut_isScriptSaurashtra(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Lisu
export extern(C) bool sidero_utf_lut_isScriptLisu(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Egyptian_Hieroglyphs
export extern(C) bool sidero_utf_lut_isScriptEgyptian_Hieroglyphs(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Elbasan
export extern(C) bool sidero_utf_lut_isScriptElbasan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Palmyrene
export extern(C) bool sidero_utf_lut_isScriptPalmyrene(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tagbanwa
export extern(C) bool sidero_utf_lut_isScriptTagbanwa(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Italic
export extern(C) bool sidero_utf_lut_isScriptOld_Italic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Caucasian_Albanian
export extern(C) bool sidero_utf_lut_isScriptCaucasian_Albanian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Malayalam
export extern(C) bool sidero_utf_lut_isScriptMalayalam(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Inherited
export extern(C) bool sidero_utf_lut_isScriptInherited(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Sora_Sompeng
export extern(C) bool sidero_utf_lut_isScriptSora_Sompeng(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Linear_B
export extern(C) bool sidero_utf_lut_isScriptLinear_B(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Nyiakeng_Puachue_Hmong
export extern(C) bool sidero_utf_lut_isScriptNyiakeng_Puachue_Hmong(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Meroitic_Cursive
export extern(C) bool sidero_utf_lut_isScriptMeroitic_Cursive(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Thai
export extern(C) bool sidero_utf_lut_isScriptThai(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Mende_Kikakui
export extern(C) bool sidero_utf_lut_isScriptMende_Kikakui(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Sogdian
export extern(C) bool sidero_utf_lut_isScriptOld_Sogdian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Turkic
export extern(C) bool sidero_utf_lut_isScriptOld_Turkic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Samaritan
export extern(C) bool sidero_utf_lut_isScriptSamaritan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_South_Arabian
export extern(C) bool sidero_utf_lut_isScriptOld_South_Arabian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Hanifi_Rohingya
export extern(C) bool sidero_utf_lut_isScriptHanifi_Rohingya(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Balinese
export extern(C) bool sidero_utf_lut_isScriptBalinese(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Mandaic
export extern(C) bool sidero_utf_lut_isScriptMandaic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script SignWriting
export extern(C) bool sidero_utf_lut_isScriptSignWriting(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tifinagh
export extern(C) bool sidero_utf_lut_isScriptTifinagh(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tai_Viet
export extern(C) bool sidero_utf_lut_isScriptTai_Viet(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Syriac
export extern(C) bool sidero_utf_lut_isScriptSyriac(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Soyombo
export extern(C) bool sidero_utf_lut_isScriptSoyombo(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Elymaic
export extern(C) bool sidero_utf_lut_isScriptElymaic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Hatran
export extern(C) bool sidero_utf_lut_isScriptHatran(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Chorasmian
export extern(C) bool sidero_utf_lut_isScriptChorasmian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Glagolitic
export extern(C) bool sidero_utf_lut_isScriptGlagolitic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Osmanya
export extern(C) bool sidero_utf_lut_isScriptOsmanya(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Linear_A
export extern(C) bool sidero_utf_lut_isScriptLinear_A(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Mro
export extern(C) bool sidero_utf_lut_isScriptMro(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Chakma
export extern(C) bool sidero_utf_lut_isScriptChakma(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Modi
export extern(C) bool sidero_utf_lut_isScriptModi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Bassa_Vah
export extern(C) bool sidero_utf_lut_isScriptBassa_Vah(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Han
export extern(C) bool sidero_utf_lut_isScriptHan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Multani
export extern(C) bool sidero_utf_lut_isScriptMultani(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Bopomofo
export extern(C) bool sidero_utf_lut_isScriptBopomofo(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Adlam
export extern(C) bool sidero_utf_lut_isScriptAdlam(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Khitan_Small_Script
export extern(C) bool sidero_utf_lut_isScriptKhitan_Small_Script(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Lao
export extern(C) bool sidero_utf_lut_isScriptLao(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Psalter_Pahlavi
export extern(C) bool sidero_utf_lut_isScriptPsalter_Pahlavi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Anatolian_Hieroglyphs
export extern(C) bool sidero_utf_lut_isScriptAnatolian_Hieroglyphs(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Canadian_Aboriginal
export extern(C) bool sidero_utf_lut_isScriptCanadian_Aboriginal(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Common
export extern(C) bool sidero_utf_lut_isScriptCommon(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Gothic
export extern(C) bool sidero_utf_lut_isScriptGothic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Yi
export extern(C) bool sidero_utf_lut_isScriptYi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Sinhala
export extern(C) bool sidero_utf_lut_isScriptSinhala(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Rejang
export extern(C) bool sidero_utf_lut_isScriptRejang(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Lepcha
export extern(C) bool sidero_utf_lut_isScriptLepcha(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tai_Tham
export extern(C) bool sidero_utf_lut_isScriptTai_Tham(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Dives_Akuru
export extern(C) bool sidero_utf_lut_isScriptDives_Akuru(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Meetei_Mayek
export extern(C) bool sidero_utf_lut_isScriptMeetei_Mayek(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tirhuta
export extern(C) bool sidero_utf_lut_isScriptTirhuta(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Marchen
export extern(C) bool sidero_utf_lut_isScriptMarchen(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Wancho
export extern(C) bool sidero_utf_lut_isScriptWancho(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Phoenician
export extern(C) bool sidero_utf_lut_isScriptPhoenician(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Gurmukhi
export extern(C) bool sidero_utf_lut_isScriptGurmukhi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Khudawadi
export extern(C) bool sidero_utf_lut_isScriptKhudawadi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Khojki
export extern(C) bool sidero_utf_lut_isScriptKhojki(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Newa
export extern(C) bool sidero_utf_lut_isScriptNewa(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Dogra
export extern(C) bool sidero_utf_lut_isScriptDogra(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Oriya
export extern(C) bool sidero_utf_lut_isScriptOriya(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tagalog
export extern(C) bool sidero_utf_lut_isScriptTagalog(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Sundanese
export extern(C) bool sidero_utf_lut_isScriptSundanese(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Permic
export extern(C) bool sidero_utf_lut_isScriptOld_Permic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Shavian
export extern(C) bool sidero_utf_lut_isScriptShavian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Lycian
export extern(C) bool sidero_utf_lut_isScriptLycian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Miao
export extern(C) bool sidero_utf_lut_isScriptMiao(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tangut
export extern(C) bool sidero_utf_lut_isScriptTangut(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Bengali
export extern(C) bool sidero_utf_lut_isScriptBengali(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Inscriptional_Pahlavi
export extern(C) bool sidero_utf_lut_isScriptInscriptional_Pahlavi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Vithkuqi
export extern(C) bool sidero_utf_lut_isScriptVithkuqi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Armenian
export extern(C) bool sidero_utf_lut_isScriptArmenian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script New_Tai_Lue
export extern(C) bool sidero_utf_lut_isScriptNew_Tai_Lue(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Sogdian
export extern(C) bool sidero_utf_lut_isScriptSogdian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Buhid
export extern(C) bool sidero_utf_lut_isScriptBuhid(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Manichaean
export extern(C) bool sidero_utf_lut_isScriptManichaean(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Greek
export extern(C) bool sidero_utf_lut_isScriptGreek(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Braille
export extern(C) bool sidero_utf_lut_isScriptBraille(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Avestan
export extern(C) bool sidero_utf_lut_isScriptAvestan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Arabic
export extern(C) bool sidero_utf_lut_isScriptArabic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Javanese
export extern(C) bool sidero_utf_lut_isScriptJavanese(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Lydian
export extern(C) bool sidero_utf_lut_isScriptLydian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Pau_Cin_Hau
export extern(C) bool sidero_utf_lut_isScriptPau_Cin_Hau(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Cypro_Minoan
export extern(C) bool sidero_utf_lut_isScriptCypro_Minoan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Buginese
export extern(C) bool sidero_utf_lut_isScriptBuginese(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Batak
export extern(C) bool sidero_utf_lut_isScriptBatak(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Nandinagari
export extern(C) bool sidero_utf_lut_isScriptNandinagari(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Cham
export extern(C) bool sidero_utf_lut_isScriptCham(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Gunjala_Gondi
export extern(C) bool sidero_utf_lut_isScriptGunjala_Gondi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Cypriot
export extern(C) bool sidero_utf_lut_isScriptCypriot(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Ugaritic
export extern(C) bool sidero_utf_lut_isScriptUgaritic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Georgian
export extern(C) bool sidero_utf_lut_isScriptGeorgian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Sharada
export extern(C) bool sidero_utf_lut_isScriptSharada(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tamil
export extern(C) bool sidero_utf_lut_isScriptTamil(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Cherokee
export extern(C) bool sidero_utf_lut_isScriptCherokee(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Pahawh_Hmong
export extern(C) bool sidero_utf_lut_isScriptPahawh_Hmong(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Syloti_Nagri
export extern(C) bool sidero_utf_lut_isScriptSyloti_Nagri(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Kharoshthi
export extern(C) bool sidero_utf_lut_isScriptKharoshthi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Zanabazar_Square
export extern(C) bool sidero_utf_lut_isScriptZanabazar_Square(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Katakana
export extern(C) bool sidero_utf_lut_isScriptKatakana(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Telugu
export extern(C) bool sidero_utf_lut_isScriptTelugu(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Ethiopic
export extern(C) bool sidero_utf_lut_isScriptEthiopic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Vai
export extern(C) bool sidero_utf_lut_isScriptVai(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Bamum
export extern(C) bool sidero_utf_lut_isScriptBamum(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Hangul
export extern(C) bool sidero_utf_lut_isScriptHangul(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Mongolian
export extern(C) bool sidero_utf_lut_isScriptMongolian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_Uyghur
export extern(C) bool sidero_utf_lut_isScriptOld_Uyghur(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Mahajani
export extern(C) bool sidero_utf_lut_isScriptMahajani(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Khmer
export extern(C) bool sidero_utf_lut_isScriptKhmer(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Grantha
export extern(C) bool sidero_utf_lut_isScriptGrantha(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Kannada
export extern(C) bool sidero_utf_lut_isScriptKannada(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Yezidi
export extern(C) bool sidero_utf_lut_isScriptYezidi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Old_North_Arabian
export extern(C) bool sidero_utf_lut_isScriptOld_North_Arabian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tai_Le
export extern(C) bool sidero_utf_lut_isScriptTai_Le(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Hebrew
export extern(C) bool sidero_utf_lut_isScriptHebrew(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Gujarati
export extern(C) bool sidero_utf_lut_isScriptGujarati(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tangsa
export extern(C) bool sidero_utf_lut_isScriptTangsa(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Carian
export extern(C) bool sidero_utf_lut_isScriptCarian(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Bhaiksuki
export extern(C) bool sidero_utf_lut_isScriptBhaiksuki(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Masaram_Gondi
export extern(C) bool sidero_utf_lut_isScriptMasaram_Gondi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Runic
export extern(C) bool sidero_utf_lut_isScriptRunic(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Duployan
export extern(C) bool sidero_utf_lut_isScriptDuployan(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Warang_Citi
export extern(C) bool sidero_utf_lut_isScriptWarang_Citi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Phags_Pa
export extern(C) bool sidero_utf_lut_isScriptPhags_Pa(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Kawi
export extern(C) bool sidero_utf_lut_isScriptKawi(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Nag_Mundari
export extern(C) bool sidero_utf_lut_isScriptNag_Mundari(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Garay
export extern(C) bool sidero_utf_lut_isScriptGaray(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Gurung_Khema
export extern(C) bool sidero_utf_lut_isScriptGurung_Khema(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Kirat_Rai
export extern(C) bool sidero_utf_lut_isScriptKirat_Rai(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Ol_Onal
export extern(C) bool sidero_utf_lut_isScriptOl_Onal(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Sunuwar
export extern(C) bool sidero_utf_lut_isScriptSunuwar(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Todhri
export extern(C) bool sidero_utf_lut_isScriptTodhri(dchar against) @safe nothrow @nogc pure;
/// Is the character a member of the script Tulu_Tigalari
export extern(C) bool sidero_utf_lut_isScriptTulu_Tigalari(dchar against) @safe nothrow @nogc pure;

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
