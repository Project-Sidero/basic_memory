module generators.unicode.scripts;
import constants;

void handleScripts() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "Scripts.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.scripts;\n\n";
    internal ~= "// Generated do not modify\n";
    internal ~= "import sidero.base.containers.set.interval;\n";

    auto api = appender!string();

    {
        api ~= "\n";
        api ~= "/// Get the Script for a character\n";

        ValueRange[] ranges;
        ubyte[] scripts;
        seqEntries(ranges, scripts, state.pairs);
        generateReturn(api, internal, "sidero_utf_lut_getScript", ranges, scripts, "Script");

        {
            ValueRange[] ranges2;

            foreach(r; ranges) {
                if(ranges2.length == 0)
                    ranges2 ~= r;
                else if(ranges2[$ - 1].end + 1 == r.start)
                    ranges2[$ - 1].end = r.end;
                else
                    ranges2 ~= r;
            }

            api ~= "/// Is the character a member of the script Unknown\n";
            generateIsCheck(api, internal, "sidero_utf_lut_isScriptUnknown", ranges2, true, true);
        }
    }

    static foreach(Sm; __traits(allMembers, Script)) {
        {
            enum script = __traits(getMember, Script, Sm);

            static if(script != Script.Unknown) {
                api ~= "/// Is the character a member of the script " ~ Sm ~ "\n";
                generateIsCheck(api, internal, "sidero_utf_lut_isScript" ~ Sm, state.scriptRanges[script], true);
            }
        }
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "scripts.d", internal.data);
}

private:
import std.array : appender;
import utilities.setops;
import utilities.inverselist;
import utilities.intervallist;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange valueRangeFromString(string charRangeStr) {
        ValueRange ret;

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

    void handleLine(ValueRange range, string line) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

    SLB:
        switch(line) {
            static foreach(m; __traits(allMembers, Script)) {
        case m:
                enum script = __traits(getMember, Script, m);
                state.pairs ~= Pair(range, script);

                if(state.scriptRanges[script].length == 0)
                    state.scriptRanges[script] ~= range;
                else {
                    if(range.start == state.scriptRanges[script][$ - 1].end + 1)
                        state.scriptRanges[script][$ - 1].end = range.end;
                    else
                        state.scriptRanges[script] ~= range;
                }
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

        ValueRange range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}

struct TotalState {
    Pair[] pairs;
    ValueRange[][Script.max + 1] scriptRanges;
}

struct Pair {
    ValueRange range;
    Script script;
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
    Kawi, ///
    Nag_Mundari, ///
    Garay, ///
    Gurung_Khema, ///
    Kirat_Rai, ///
    Ol_Onal, ///
    Sunuwar, ///
    Todhri, ///
    Tulu_Tigalari, ///
}

void seqEntries(out ValueRange[] ranges, out ubyte[] scripts, Pair[] entries) {
    import std.algorithm : sort;

    sort!"a.range.start < b.range.start"(entries);

    ranges.reserve(entries.length);
    scripts.reserve(entries.length);

    foreach(v; entries) {
        assert(v.range.start <= v.range.end);
        ranges ~= v.range;
        scripts ~= v.script;
    }
}
