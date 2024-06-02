module generators.unicode.unicodedata.ccc;
import generators.unicode.unicodedata.common;
import constants;
import utilities.sequential_ranges;
import utilities.lut;
import std.file : write;
import std.array : appender;

void CCC() {
    auto internalCCC = appender!string();
    internalCCC ~= "module sidero.base.internal.unicode.unicodedataCCC;\n\n";
    internalCCC ~= "// Generated do not modify\n";

    {
        SequentialRanges!(ubyte, SequentialRangeSplitGroup, 2) sr;

        foreach(entry; state.entries) {
            foreach(c; entry.range.start .. entry.range.end + 1)
                sr.add(cast(dchar)c, cast(ubyte)entry.canonicalCombiningClass);
        }

        sr.calculateTrueSpread;
        sr.joinWhenClose(null, 5, 32);
        sr.splitForSame;
        sr.calculateTrueSpread;
        sr.joinWhenClose(null, 5, 32);
        sr.calculateTrueSpread;
        sr.layerBySingleMulti(0);
        sr.layerJoinIfEndIsStart(0, 1);
        sr.layerByRangeMax(1, ushort.max / 8);

        LookupTableGenerator!(ubyte, SequentialRangeSplitGroup, 2) lut;
        lut.sr = sr;
        lut.lutType = "ubyte";
        lut.name = "sidero_utf_lut_getCCC";

        auto gotDcode = lut.build();

        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup CCC for character.\n";
        apiOutput ~= "/// Returns: 0 if not set.\n";
        apiOutput ~= gotDcode[0];

        internalCCC ~= gotDcode[1];
    }

    write(UnicodeLUTDirectory ~ "unicodedataCCC.d", internalCCC.data);
}
