module verify_generated.testfile;

__gshared NormalizationTestEntry[] normalizationTestEntries;

struct NormalizationTestEntry {
    dstring source, NFC, NFD, NFKC, NFKD;
}

private:

shared static this() {
    import std.algorithm : countUntil, startsWith;
    import std.string : strip, lineSplitter;
    import std.conv : parse;
    import std.file : readText;
    import std.array : split;

    foreach(line; readText("unicode-14/NormalizationTest.txt").lineSplitter) {
        ptrdiff_t offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];

        line = line.strip;

        string[] splitValues = line.split(';');

        if (splitValues.length < 5 || splitValues.length > 6)
            continue;

        NormalizationTestEntry entry;
        string v;

        static foreach(i; 0 .. NormalizationTestEntry.tupleof.length) {
            v = splitValues[i].strip;

            while(v.length > 0) {
                entry.tupleof[i] ~= v.parse!uint(16);
                v = v.strip;
            }
        }

        normalizationTestEntries ~= entry;
    }
}

