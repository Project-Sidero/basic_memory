module generators.unicode.casefolding;
import constants;

void caseFolding() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "CaseFolding.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.casefolding;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();


    dchar[] codepoints, replacedBysDchar;
    dstring[] replacedBys;
    uint[] replacedByUints;

    {
        api ~= "\n";
        api ~= "/// Lookup Casefolding for character.\n";
        api ~= "/// Returns: null if unchanged.\n";

        joinEntries(codepoints, replacedBys, state.common, state.full);
        generateReturn(api, internal, "sidero_utf_lut_getCaseFolding", codepoints, replacedBys);
    }

    {
        api ~= "\n";
        api ~= "/// Lookup Casefolding for character.\n";
        api ~= "/// Returns: null if unchanged.\n";

        joinEntries(codepoints, replacedBys, state.turkic);
        generateReturn(api, internal, "sidero_utf_lut_getCaseFoldingTurkic", codepoints, replacedBys);
    }

    {
        api ~= "\n";
        api ~= "/// Lookup Casefolding (simple) for character.\n";
        api ~= "/// Returns: The casefolded character.\n";

        joinEntries(codepoints, replacedBysDchar, state.common, state.simple);
        generateReturn(api, internal, "sidero_utf_lut_getCaseFoldingFast", codepoints, replacedBysDchar);
    }

    {
        api ~= "\n";
        api ~= "/// Lookup Casefolding length for character.\n";
        api ~= "/// Returns: 0 if unchanged.\n";

        joinEntriesLength(codepoints, replacedByUints, state.common, state.full);
        generateReturn(api, internal, "sidero_utf_lut_lengthOfCaseFolding", codepoints, replacedByUints);
    }

    {
        api ~= "\n";
        api ~= "/// Lookup Casefolding length for character.\n";
        api ~= "/// Returns: 0 if unchanged.\n";

        joinEntriesLength(codepoints, replacedByUints, state.turkic);
        generateReturn(api, internal, "sidero_utf_lut_lengthOfCaseFoldingTurkic", codepoints, replacedByUints);
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "casefolding.d", internal.data);
}

private:
import std.array : appender;
import utilities.sequential_ranges;
import utilities.lut;
import utilities.inverselist;

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

void joinEntries(out dchar[] codepoints, out dstring[] replacedBys, Entry[][] entries...) {
    import std.algorithm : sort;

    Entry[] total;

    foreach(entry; entries) {
        total ~= entry;
    }

    sort!"a.codepoint < b.codepoint"(total);

    codepoints.reserve(total.length);
    replacedBys.reserve(total.length);

    dchar lastCodepoint;

    foreach(v; total) {
        assert(lastCodepoint != v.codepoint);

        codepoints ~= v.codepoint;
        replacedBys ~= v.replacedBy;
        lastCodepoint = v.codepoint;
    }
}

void joinEntries(out dchar[] codepoints, out dchar[] replacedBys, Entry[][] entries...) {
    import std.algorithm : sort;

    Entry[] total;

    foreach(entry; entries) {
        total ~= entry;
    }

    sort!"a.codepoint < b.codepoint"(total);

    codepoints.reserve(total.length);
    replacedBys.reserve(total.length);

    dchar lastCodepoint;

    foreach(v; total) {
        assert(lastCodepoint != v.codepoint);

        codepoints ~= v.codepoint;
        replacedBys ~= v.replacedBy[0];
        lastCodepoint = v.codepoint;
    }
}

void joinEntriesLength(out dchar[] codepoints, out uint[] replacedBys, Entry[][] entries...) {
    import std.algorithm : sort;

    Entry[] total;

    foreach(entry; entries) {
        total ~= entry;
    }

    sort!"a.codepoint < b.codepoint"(total);

    codepoints.reserve(total.length);
    replacedBys.reserve(total.length);

    dchar lastCodepoint;

    foreach(v; total) {
        assert(lastCodepoint != v.codepoint);

        codepoints ~= v.codepoint;
        replacedBys ~= cast(uint)v.replacedBy.length;
        lastCodepoint = v.codepoint;
    }
}
