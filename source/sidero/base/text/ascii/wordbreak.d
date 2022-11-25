/**
*/
module sidero.base.text.ascii.wordbreak;
import sidero.base.text.wordbreak;
export:

/**
This function is based upon Unicode's word break algorithm as defined in [TR29](https://unicode.org/reports/tr29/#Word_Boundary_Rules).

Returns:
    Start of next segment offset or -1.
*/
ptrdiff_t findNextWordBreakASCII(Char, alias Us)(scope ref WordBreaker!(Char, Us) wordBreaker) @nogc {
    import sidero.base.text.ascii.characters;

    size_t toSkip, offset, nextDiff;
    bool readyToGo;

    typeof(wordBreaker).Entry lastValue, currentValue;

    Loop: while (wordBreaker.haveValueDel()) {
        typeof(wordBreaker).Entry nextValue;

        lastValue = currentValue;
        currentValue = wordBreaker.nextDel();
        offset += nextDiff;
        nextDiff = currentValue.entriesForValue;

        if (toSkip > 0) {
            toSkip--;
            continue Loop;
        }

        if (readyToGo)
            return offset;

        if (wordBreaker.haveValueDel())
            nextValue = wordBreaker.peekDel();

        if (currentValue == '\r' && nextValue == '\n') {
            // WB3
            if (offset == 0) {
                toSkip = 1;
                readyToGo = true;
                continue Loop;
            } else {
                readyToGo = true;
                continue Loop;
            }
        } else if (currentValue == 0xB || currentValue == 0xC || currentValue == '\r' || currentValue == '\n') {
            // WB3a WB3b
            return offset == 0 ? 1 : offset;
        }

        if ((lastValue == ' ' && currentValue == ' ') || (currentValue == ' ' && nextValue == ' ')) {
            // WB3d
            continue Loop;
        }

        if (currentValue == ' ') {
            // not listed in rules *sigh* but it is used as part of the demo, so adding here
            if (offset > 0) {
                return offset;
            } else if (nextValue != ' ') {
                readyToGo = true;
                continue Loop;
            }
        }

        if ((lastValue.value.isAlpha && currentValue.value.isAlpha) || (currentValue.value.isAlpha && nextValue.value.isAlpha)) {
            // WB5
            continue Loop;
        }

        if (lastValue.value.isAlpha && (currentValue == ':' || currentValue == '.' || currentValue == '\'') && nextValue.value.isAlpha) {
            // WB6 WB7
            toSkip = 1;
            continue Loop;
        }

        if ((lastValue.value.isNumeric && currentValue.value.isAlphaNumeric) || (lastValue.value.isAlphaNumeric &&
        currentValue.value.isNumeric)) {
            // WB8 WB9 WB10
            continue Loop;
        }

        if (lastValue.value.isNumeric && (currentValue == '.' || currentValue == '\'') && nextValue.value.isNumeric) {
            // WB11 WB12
            toSkip = 1;
            continue Loop;
        }

        if (offset > 0)
            return offset;
    }

    return readyToGo ? (offset + nextDiff) : -1;
}

///
unittest {
    alias WBr = WordBreaker!(ubyte, findNextWordBreakASCII);

    string literal = "Alice was beginning to get very tired of sitting by her sister\non the bank, and of having nothing to do:  once or twice she had\npeeped into the book her sister was reading, but it had no\npictures or conversations in it, `and what is the use of a book,'\nthought Alice `without pictures or conversation?'";

    string[] against = [
    "Alice", " ", "was", " ", "beginning", " ", "to", " ", "get", " ", "very", " ", "tired", " ", "of", " ",
    "sitting", " ", "by", " ", "her", " ", "sister", "\n", "on", " ", "the", " ", "bank", ",", " ", "and", " ",
    "of", " ", "having", " ", "nothing", " ", "to", " ", "do", ":  once", " ", "or", " ", "twice", " ", "she", " ",
    "had", "\n", "peeped", " ", "into", " ", "the", " ", "book", " ", "her", " ", "sister", " ", "was", " ",
    "reading", ",", " ", "but", " ", "it", " ", "had", " ", "no", "\n", "pictures", " ", "or", " ",
    "conversations", " ", "in", " ", "it", ",", " ", "`and", " ", "what", " ", "is", " ", "the", " ", "use", " ",
    "of", " ", "a", " ", "book", ",", "'", "\n", "thought", " ", "Alice", " ", "`without", " ", "pictures", " ",
    "or", " ", "conversation", "?",
    ];

    ptrdiff_t lastOffset, currentOffset;
    bool findNext() @trusted {
        size_t offsetForIterator = currentOffset;

        const temp = WBr(() { return WBr.Entry(1, literal[offsetForIterator++]); }, () {
            return WBr.Entry(1, literal[offsetForIterator]);
        }, () { return offsetForIterator + 1 < literal.length; }, literal.length - offsetForIterator, literal.length).perform();

        if (temp <= 0)
            return false;

        lastOffset = currentOffset;
        currentOffset += temp;
        return true;
    }

    size_t soFar;
    while (findNext()) {
        string data = literal[lastOffset .. currentOffset];
        assert(data == against[soFar++]);
    }
}
