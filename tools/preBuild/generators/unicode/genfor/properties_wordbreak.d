module generators.unicode.genfor.properties_wordbreak;
import generators.unicode.data.WordBreakProperty;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;

void genForWordBreakProperty() {
    implOutput ~= "module sidero.base.internal.unicode.wordbreakproperty;\n";
    implOutput ~= "// Generated do not modify\n\n";

    {
        ValueRange[] ranges;
        ubyte[] properties;
        seqEntries(ranges, properties, WordBreakProperty.ranges);

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup word break property for character.\n";
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getWordBreakProperty", ranges, properties, "WordBreakProperty");
    }
}

private:

void seqEntries(out ValueRange[] ranges, out ubyte[] lineBreaks, WordBreakProperty_Entry[] entries) {
    import std.algorithm : sort;

    sort!"a.range.start < b.range.start"(entries);

    ranges.reserve(entries.length);
    lineBreaks.reserve(entries.length);

    foreach(v; entries) {
        assert(v.range.start <= v.range.end);
        ranges ~= v.range;
        lineBreaks ~= cast(ubyte)v.property;
    }
}
