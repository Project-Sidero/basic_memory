module generators.unicode.external;
import constants;

void createAPIfile() {
    import std.array : appender;
    import std.file : write;

    auto api = appender!string();
    api ~= "/**\n";
    api ~= " Unicode database access routines\n";
    api ~= " License: Artistic-v2\n";
    api ~= "*/\n";
    api ~= "module sidero.base.text.unicode.database;\n";
    api ~= "// Generated do not modify\n";

    api ~= `
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

`;

    write(UnicodeAPIFile, api.data);
}
