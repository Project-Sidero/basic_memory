module unicode.wordbreaktest;
import constants;
import sidero.base.text.unicode.wordbreak;
import sidero.base.text.wordbreak;
import std.stdio;

void wordBreakTests() {
    parseTestFile;

    alias WBr = WordBreaker!(dchar, findNextWordBreakUnicode);

    foreach(testId, ref test; tests) {
        ptrdiff_t lastOffset, currentOffset;
        bool findNext() @trusted {
            size_t offsetForIterator = currentOffset;

            const temp = WBr(() {
                return WBr.Entry(1, test.value[offsetForIterator++]);
            }, () {
                return offsetForIterator < test.value.length ? WBr.Entry(1, test.value[offsetForIterator]) : WBr.Entry(size_t.max);
            }, () {
                return offsetForIterator < test.value.length;
            }, test.value.length - offsetForIterator, test.value.length).perform();

            lastOffset = currentOffset;
            currentOffset += temp;

            return temp > 0;
        }

        writeln("=== ", testId, ": ", test.comment);

        version(none) {
            foreach(i; 0 .. test.value.length)
                writefln!"%s: %X %s %s"(i, test.value[i], test.value[i], test.canBreak[i]);
        }

        bool keepGoing;
        size_t soFar;
        do {
            keepGoing = findNext();

            version(none) {
                writeln(soFar, ": lastOffset: ", lastOffset, " currentOffset: ", currentOffset, " length: ",
                        currentOffset - lastOffset, " expected length: ", test.lengths[soFar]);
            }

            assert(currentOffset - lastOffset == test.lengths[soFar]);
            soFar++;
        }
        while(keepGoing && currentOffset < test.value.length);
    }
}

private:

void parseTestFile() {
    import std.algorithm : countUntil, startsWith;
    import std.string : strip, lineSplitter;
    import std.conv : parse, dtext;
    import std.file : readText;
    import std.array : split;

    enum divide = "\u00F7"d;
    enum multiply = "\u00D7"d;

    foreach(line; readText(UnicodeDatabaseDirectory ~ "auxiliary/WordBreakTest.txt").dtext.lineSplitter) {
        ptrdiff_t offset = line.countUntil('#');
        dstring comment;

        if(offset >= 0) {
            comment = line[offset + 1 .. $].strip;
            line = line[0 .. offset];
        }

        line = line.strip;

        {
            offset = line.countUntil(' ');
            if(offset < 0)
                continue;

            dstring operation = offset > 0 ? line[0 .. offset] : line;
            line = offset > 0 ? line[offset + 1 .. $] : null;
            assert(operation == divide);
        }

        Test test;
        test.comment = comment;

        size_t currentOffset, lastOffset;

        while(line.length > 0) {
            currentOffset++;
            offset = line.countUntil(' ');

            assert(offset > 0);
            dstring character = line[0 .. offset];
            line = line[offset + 1 .. $];

            offset = line.countUntil(' ');
            dstring operation = offset > 0 ? line[0 .. offset] : line;
            line = offset > 0 ? line[offset + 1 .. $] : null;

            assert(operation == divide || operation == multiply);

            if(operation == divide) {
                test.lengths ~= currentOffset - lastOffset;
                lastOffset = currentOffset;
            }

            test.value ~= character.parse!uint(16);
            assert(character.length == 0);
            test.canBreak ~= operation == divide;
        }

        if(currentOffset > lastOffset)
            test.lengths ~= currentOffset - lastOffset;

        assert(test.lengths.length > 0);
        tests ~= test;
    }
}

__gshared Test[] tests;

struct Test {
    dstring value;
    bool[] canBreak;
    size_t[] lengths;
    dstring comment;
}
