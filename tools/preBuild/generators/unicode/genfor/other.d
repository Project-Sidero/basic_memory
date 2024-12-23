module generators.unicode.genfor.other;
import generators.unicode.data.UnicodeData;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;

void genForOther() {
    implOutput ~= "module sidero.base.internal.unicode.other;\n";
    implOutput ~= "// Generated do not modify\n\n";

    getNumeric;
    getGeneralCategory;
}

private:

void getNumeric() {
    dchar[] ranges;
    long[2][] numdemos;

    foreach(entry; UnicodeData.entries) {
        foreach(c; entry.range.start .. entry.range.end + 1) {
            if(entry.numericValueNumerator != 0 || entry.numericValueDenominator != 0) {
                ranges ~= c;
                numdemos ~= [entry.numericValueNumerator, entry.numericValueDenominator];
            }
        }
    }

    apiOutput ~= "\n";
    apiOutput ~= "/// Lookup numeric numerator/denominator for character.\n";
    apiOutput ~= "/// Returns: null if not set.\n";
    generateReturn(apiOutput, implOutput, "sidero_utf_lut_getNumeric", ranges, numdemos);
}

void getGeneralCategory() {
    ValueRange[] ranges;
    ubyte[] gcs;

    foreach(entry; UnicodeData.entries) {
        ranges ~= entry.range;
        gcs ~= cast(ubyte)entry.generalCategory;
    }

    apiOutput ~= "\n";
    apiOutput ~= "/// Lookup general category for character.\n";
    generateReturn(apiOutput, implOutput, "sidero_utf_lut_getGeneralCategory", ranges, gcs, "GeneralCategory");
}
