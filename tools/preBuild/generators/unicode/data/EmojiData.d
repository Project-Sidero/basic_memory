module generators.unicode.data.EmojiData;
import utilities.setops;

__gshared EmojiData_State EmojiData;

struct EmojiData_State {
    ValueRange[][EmojiClass.max + 1] values;
}

enum EmojiClass {
    Emoji,
    Emoji_Presentation,
    Emoji_Modifier,
    Emoji_Modifier_Base,
    Emoji_Component,
    Extended_Pictographic,
}

void processEmojiData(string inputText) {
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
            static foreach(m; __traits(allMembers, EmojiClass)) {
                case m:
                    enum property = __traits(getMember, EmojiClass, m);
                    if(EmojiData.values[property].length == 0)
                    EmojiData.values[property] ~= range;
                    else {
                        if(range.start == EmojiData.values[property][$ - 1].end + 1)
                        EmojiData.values[property][$ - 1].end = range.end;
                        else
                        EmojiData.values[property] ~= range;
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
