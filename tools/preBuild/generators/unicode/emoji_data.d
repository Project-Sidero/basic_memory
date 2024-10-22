module generators.unicode.emoji_data;
import constants;

void emojiData() {
    import std.file : readText, write, append;
    import std.format : formattedWrite;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "emoji/emoji-data.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.emoji_data;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    static foreach(Em; __traits(allMembers, EmojiClass)) {
        {
            api ~= "\n";
            api ~= "/// Is member of " ~ Em ~ " class?\n";
            generateIsCheck(api, internal, "sidero_utf_lut_isMemberOf" ~ Em, state.values[__traits(getMember, EmojiClass, Em)]);
        }
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "emoji_data.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges : ValueRange;
import utilities.inverselist;

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
            static foreach(m; __traits(allMembers, EmojiClass)) {
        case m:
                enum property = __traits(getMember, EmojiClass, m);
                if(state.values[property].length == 0)
                    state.values[property] ~= range;
                else {
                    if(range.start == state.values[property][$ - 1].end + 1)
                        state.values[property][$ - 1].end = range.end;
                    else
                        state.values[property] ~= range;
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

        ValueRange!dchar range = valueRangeFromString(charRangeStr);
        handleLine(range, line);
    }
}

struct TotalState {
    ValueRange!dchar[][EmojiClass.max + 1] values;
}

enum EmojiClass {
    Emoji, ///
    Emoji_Presentation, ///
    Emoji_Modifier, ///
    Emoji_Modifier_Base, ///
    Emoji_Component, ///
    Extended_Pictographic, ///
}
