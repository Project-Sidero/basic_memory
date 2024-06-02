module unicode.normalizationtests;
import constants;
import sidero.base.text.unicode.normalization;
import sidero.base.text.unicode.database;
import sidero.base.allocators.api;
import sidero.base.allocators.predefined;
import std.stdio;

void normalizationTests() {
    try {
        GeneralPurposeAllocator gpa;
        RCAllocator allocator = RCAllocator.instanceOf(&gpa);

        writeln("============ NFD =============");

        // NFD
        foreach(testId, nte; normalizationTestEntries) {
            writeln("Testing: ", testId, ": ", nte);
            // source; NFC; NFD; NFKC; NFKD

            // c3 ==  toNFD(c1) ==  toNFD(c2) ==  toNFD(c3)
            assert(nte.NFD == toNFD(nte.source, allocator));
            assert(nte.NFD == toNFD(nte.NFC, allocator));
            assert(nte.NFD == toNFD(nte.NFD, allocator));

            // c5 ==  toNFD(c4) ==  toNFD(c5)
            assert(nte.NFKD == toNFD(nte.NFKC, allocator));
            assert(nte.NFKD == toNFD(nte.NFKD, allocator));

            allocator.deallocateAll;
        }

        writeln("============ NFKD =============");

        // NFKD
        foreach(testId, nte; normalizationTestEntries) {
            writeln("Testing: ", testId, ": ", nte);
            // source; NFC; NFD; NFKC; NFKD

            // c5 == toNFKD(c1) == toNFKD(c2) == toNFKD(c3) == toNFKD(c4) == toNFKD(c5)
            assert(nte.NFKD == toNFKD(nte.source, allocator));
            assert(nte.NFKD == toNFKD(nte.NFC, allocator));
            assert(nte.NFKD == toNFKD(nte.NFD, allocator));
            assert(nte.NFKD == toNFKD(nte.NFKC, allocator));
            assert(nte.NFKD == toNFKD(nte.NFKD, allocator));

            allocator.deallocateAll;
        }

        writeln("============ NFC =============");

        // NFC
        foreach(testId, nte; normalizationTestEntries) {
            writeln("Testing: ", testId, ": ", nte);
            // source; NFC; NFD; NFKC; NFKD

            // c2 ==  toNFC(c1) ==  toNFC(c2) ==  toNFC(c3)
            assert(nte.NFC == toNFC(nte.source, allocator), "c2 == toNFC(c1)");
            assert(nte.NFC == toNFC(nte.NFC, allocator), "c2 == toNFC(c2)");
            assert(nte.NFC == toNFC(nte.NFD, allocator), "c2 == toNFC(c3)");

            // c4 ==  toNFC(c4) ==  toNFC(c5)
            assert(nte.NFKC == toNFC(nte.NFKC, allocator), "c4 == toNFC(c4)");
            assert(nte.NFKC == toNFC(nte.NFKD, allocator), "c4 == toNFC(c5)");

            allocator.deallocateAll;
        }

        writeln("============ NFKC =============");

        // NFKC
        foreach(testId, nte; normalizationTestEntries) {
            writeln("Testing: ", testId, ": ", nte);
            // source; NFC; NFD; NFKC; NFKD

            // c4 == toNFKC(c1) == toNFKC(c2) == toNFKC(c3) == toNFKC(c4) == toNFKC(c5)
            assert(nte.NFKC == toNFKC(nte.source, allocator));
            assert(nte.NFKC == toNFKC(nte.NFC, allocator));
            assert(nte.NFKC == toNFKC(nte.NFD, allocator));
            assert(nte.NFKC == toNFKC(nte.NFKC, allocator));
            assert(nte.NFKC == toNFKC(nte.NFKD, allocator));

            allocator.deallocateAll;
        }
    } catch(Throwable e) {
        writeln("Failure ", e.toString());
        stdout.flush;
        assert(0);
    }
}

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

    foreach(line; readText(UnicodeDatabaseDirectory ~ "NormalizationTest.txt").lineSplitter) {
        ptrdiff_t offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];

        line = line.strip;

        string[] splitValues = line.split(';');

        if(splitValues.length < 5 || splitValues.length > 6)
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
