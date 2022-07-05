module generators.unicode.casefolding;

void caseFolding() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText("unicode-14/CaseFolding.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.casefolding;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    {
        SequentialRanges!(dstring, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.common)
            sr.add(entry.codepoint, entry.replacedBy);
        foreach (entry; state.full)
            sr.add(entry.codepoint, entry.replacedBy);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar codepoint) @trusted => cast(dstring)[codepoint]);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(dstring, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "dstring";
        lut.name = "sidero_utf_lut_getCaseFolding";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup Casefolding for character.\n";
        api ~= "/// Returns: null if unchanged.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(dstring, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.turkic)
            sr.add(entry.codepoint, entry.replacedBy);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar codepoint) @trusted => cast(dstring)[codepoint]);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(dstring, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "dstring";
        lut.name = "sidero_utf_lut_getCaseFoldingTurkic";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup Casefolding for character.\n";
        api ~= "/// Returns: null if unchanged.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(dchar, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.common)
            sr.add(entry.codepoint, entry.replacedBy[0]);
        foreach (entry; state.simple)
            sr.add(entry.codepoint, entry.replacedBy[0]);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar codepoint) => codepoint);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(dchar, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "dchar";
        lut.name = "sidero_utf_lut_getCaseFoldingFast";
        lut.defaultReturn = "input";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup Casefolding (simple) for character.\n";
        api ~= "/// Returns: The casefolded character.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(size_t, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.common)
            sr.add(entry.codepoint, entry.replacedBy.length);
        foreach (entry; state.full)
            sr.add(entry.codepoint, entry.replacedBy.length);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar codepoint) => cast(size_t)1);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(size_t, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "size_t";
        lut.name = "sidero_utf_lut_lengthOfCaseFolding";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup Casefolding length for character.\n";
        api ~= "/// Returns: 0 if unchanged.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    {
        SequentialRanges!(size_t, SequentialRangeSplitGroup, 2) sr;

        foreach (entry; state.turkic)
            sr.add(entry.codepoint, entry.replacedBy.length);

        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose((dchar codepoint) => cast(size_t)1);
        sr.calculateTrueSpread;
        sr.layerByRangeMax(0, ushort.max / 4);
        sr.layerByRangeMax(1, ushort.max / 2);

        LookupTableGenerator!(size_t, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "size_t";
        lut.name = "sidero_utf_lut_lengthOfCaseFoldingTurkic";

        auto gotDcode = lut.build();

        api ~= "\n";
        api ~= "/// Lookup Casefolding length for character.\n";
        api ~= "/// Returns: 0 if unchanged.\n";
        api ~= gotDcode[0];

        internal ~= gotDcode[1];
    }

    append("generated/sidero/base/text/unicode/database.d", api.data);
    write("generated/sidero/base/internal/unicode/casefolding.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;

void processEachLine(string inputText, ref TotalState state) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    void handleLine(dchar codepoint, string line) {
        Entry entry;
        entry.codepoint = codepoint;

        ptrdiff_t offset;

        offset = line.countUntil(';');
        if (offset < 0) // no status
            return;

        string status = line[0 .. offset].strip;
        line = line[offset + 1 .. $];

        offset = line.countUntil(';');
        if (offset > 0)
            line = line[0 .. offset];
        offset = line.countUntil('#');
        if (offset > 0)
            line = line[0 .. offset];

        line = line.strip;

        while (line.length > 0) {
            entry.replacedBy ~= cast(dchar)parse!uint(line, 16);
            line = line.strip;
        }

        switch (status) {
        case "C":
            state.common ~= entry;
            break;
        case "F":
            state.full ~= entry;
            break;
        case "S":
            state.simple ~= entry;
            break;
        case "T":
            state.turkic ~= entry;
            break;
        default:
            assert(0, status);
        }
    }

    foreach (line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if (offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if (line.length < 5) // anything that low can't represent a functional line
            continue;

        offset = line.countUntil(';');
        if (offset < 0) // no char range
            continue;
        string charRangeStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        dchar codepoint = parse!uint(charRangeStr, 16);
        handleLine(codepoint, line);
    }
}

struct TotalState {
    Entry[] common, full, simple, turkic;
}

struct Entry {
    dchar codepoint;
    dstring replacedBy;
}
