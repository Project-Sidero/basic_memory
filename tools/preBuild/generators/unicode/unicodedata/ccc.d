module generators.unicode.unicodedata.ccc;
import generators.unicode.unicodedata.common;
import constants;
import std.file : write;
import std.array : appender;

void CCC() {
    auto internalCCC = appender!string();
    internalCCC ~= "module sidero.base.internal.unicode.unicodedataCCC;\n";
    internalCCC ~= "// Generated do not modify\n\n";

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup CCC for character.\n";
        apiOutput ~= "/// Returns: 0 if not set.\n";

        ValueRange[] ranges;
        ubyte[] ccc;
        seqEntries(ranges, ccc, state.entries);
        generateReturn(apiOutput, internalCCC, "sidero_utf_lut_getCCC", ranges, ccc);
    }

    write(UnicodeLUTDirectory ~ "unicodedataCCC.d", internalCCC.data);
}

private:
import utilities.setops;
import utilities.inverselist;

void seqEntries(out ValueRange[] ranges, out ubyte[] cccs, Entry[] entries) {
    import std.algorithm : sort;

    sort!"a.range.start < b.range.start"(entries);

    ranges.reserve(entries.length);
    cccs.reserve(entries.length);

    foreach(v; entries) {
        assert(v.range.start <= v.range.end);
        ranges ~= v.range;
        cccs ~= cast(ubyte)v.canonicalCombiningClass;
    }
}
