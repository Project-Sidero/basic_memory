module generators.unicode.genfor.break_line;
import generators.unicode.data.LineBreak;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;

void genForLineBreak() {
    implOutput ~= "module sidero.base.internal.unicode.linebreak;\n";
    implOutput ~= "// Generated do not modify\n\n";

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Get the Line break class\n";

        ValueRange[] ranges;
        ubyte[] values;
        seqEntries(ranges, values, LineBreak.pairs);

        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getLineBreakClass", ranges, values, "LineBreakClass");
    }
}

private:

void seqEntries(out ValueRange[] ranges, out ubyte[] lineBreaks, Pair[] entries) {
    import std.algorithm : sort;

    sort!"a.range.start < b.range.start"(entries);

    ranges.reserve(entries.length);
    lineBreaks.reserve(entries.length);

    foreach(v; entries) {
        assert(v.range.start <= v.range.end);
        ranges ~= v.range;
        lineBreaks ~= v.lineBreak;
    }
}
