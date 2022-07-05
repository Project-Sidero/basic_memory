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
