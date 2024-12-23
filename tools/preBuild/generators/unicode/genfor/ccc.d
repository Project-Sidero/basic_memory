module generators.unicode.genfor.ccc;
import generators.unicode.data.UnicodeData;
import generators.unicode.defs;
import constants;
import utilities.setops;
import utilities.inverselist;

void genForCCC() {
    implOutput ~= "module sidero.base.internal.unicode.unicodedataCCC;\n";
    implOutput ~= "// Generated do not modify\n\n";

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup CCC for character.\n";
        apiOutput ~= "/// Returns: 0 if not set.\n";

        ValueRange[] ranges;
        ubyte[] ccc;
        seqEntries(ranges, ccc, UnicodeData.entries);
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getCCC", ranges, ccc);
    }
}

private:

void seqEntries(out ValueRange[] ranges, out ubyte[] cccs, UnicodeData_Entry[] entries) {
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
