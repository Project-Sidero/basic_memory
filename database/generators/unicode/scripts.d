module generators.unicode.scripts;
import generators.constants;

void handleScripts() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText("unicode-14/Scripts.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.scripts;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach(range, value; state.values) {
            foreach(c; range.start .. range.end + 1)
                sr.add(c, cast(ubyte)value);
        }

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWithDiff(null, 64);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "ubyte";
        lut.externType = "Script";
        lut.name = "sidero_utf_lut_getScript";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Get the Script for a character\n";
        api ~= gotDcode[0];
        api ~= "\n";

        internal ~= gotDcode[1];
    }

    static foreach(Sm; __traits(allMembers, Script)) {
        {
            SequentialRanges!(bool, SequentialRangeSplitGroup, 2) sr;

            foreach(range, value; state.values) {
                static if(__traits(getMember, Script, Sm) == Script.Unknown) {
                    // inverse
                    foreach(c; range.start .. range.end + 1)
                        sr.add(c, false);
                } else {
                    if(value == __traits(getMember, Script, Sm)) {
                        foreach(c; range.start .. range.end + 1)
                            sr.add(c, true);
                    }
                }
            }

            sr.splitForSame;
            sr.calculateTrueSpread;
            static if(__traits(getMember, Script, Sm) == Script.Unknown) {
                sr.joinWithDiff((dchar key) => true, 64);
            } else {
                sr.joinWithDiff((dchar key) => false, 64);
            }
            sr.calculateTrueSpread;
            sr.layerByRangeMax(0, ushort.max / 4);
            sr.layerByRangeMax(1, ushort.max / 2);

            LookupTableGenerator!(bool, SequentialRangeSplitGroup, 2) lut;
            lut.sr = sr;
            lut.lutType = "bool";
            lut.name = "sidero_utf_lut_isScript" ~ Sm;

            static if(__traits(getMember, Script, Sm) == Script.Unknown) {
                lut.defaultReturn = "true";
            }

            auto gotDcode = lut.build();

            api ~= "/// Is the character a member of the script " ~ Sm ~ "\n";
            api ~= gotDcode[0];
            api ~= "\n";

            internal ~= gotDcode[1];
        }
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "scripts.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange!dchar valueRangeFromString(string charRangeStr) {
        ValueRange!dchar ret;

        ptrdiff_t offsetOfSeperator = charRangeStr.countUntil("..");
        if(offsetOfSeperator < 0) {
            ret.start = parse!uint(charRangeStr, 16);
            ret.end = ret.start;
        } else {
            string startStr = charRangeStr[0 .. offsetOfSeperator], endStr = charRangeStr[offsetOfSeperator + 2 .. $];
            ret.start = parse!uint(startStr, 16);
            ret.end = parse!uint(endStr, 16);
        }

        return ret;
    }

    void handleLine(ValueRange!dchar range, string line) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

    SLB:
        switch(line) {
            static foreach(m; __traits(allMembers, Script)) {
        case m:
                state.values[range] = __traits(getMember, Script, m);
                break SLB;
            }

        default:
            assert(0, line);
        }
    }

    foreach(line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if(line.length < 5) // anything that low can't represent a functional line
            continue;

        offset = line.countUntil(';');
        if(offset < 0) // no char range
            continue;
        string charRangeStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        ValueRange!dchar range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}

struct TotalState {
    Script[ValueRange!dchar] values;
}

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
