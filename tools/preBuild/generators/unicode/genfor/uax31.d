module generators.unicode.genfor.uax31;
import generators.unicode.data.DerivedCoreProperties;
import generators.unicode.defs;
import utilities.setops;
import utilities.inverselist;
import utilities.intervallist;
import std.algorithm : sort;

void genForUAX31Tables() {
    implOutput ~= "module sidero.base.implOutput.unicode.uax31;\n";
    implOutput ~= "import sidero.base.containers.set.interval;\n";
    implOutput ~= "// Generated do not modify\n\n";

    start_C;
    continue_C;
    start_JS;
    continue_JS;
}

private:

void start_C() {
    ValueRanges ranges = ValueRanges(DerivedCoreProperties_Binary[DerivedCorePropertyBinary.XID_Start].dup);
    ranges.add(ValueRange(0x5F)); // add _
    ranges.ranges.sort!((a, b) => a.start < b.start);

    implOutput ~= "\n";

    apiOutput ~= "\n";
    apiOutput ~= "/// Is UAX31 for C start set.\n";
    apiOutput ~= "/// Returns: false if not set.\n";

    generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isUAX31_C_Start", ranges.ranges, true, false);
}

void continue_C() {
    implOutput ~= "\n";

    apiOutput ~= "\n";
    apiOutput ~= "/// Is UAX31 for C continue set.\n";
    apiOutput ~= "/// Returns: false if not set.\n";

    generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isUAX31_C_Continue", DerivedCoreProperties_Binary[DerivedCorePropertyBinary.XID_Continue], true, false);
}

void start_JS() {
    ValueRanges ranges = ValueRanges(DerivedCoreProperties_Binary[DerivedCorePropertyBinary.ID_Start].dup);
    ranges.add(ValueRange(0x24)); // add $
    ranges.add(ValueRange(0x5F)); // add _
    ranges.ranges.sort!((a, b) => a.start < b.start);

    implOutput ~= "\n";

    apiOutput ~= "\n";
    apiOutput ~= "/// Is UAX31 for Javascript start set.\n";
    apiOutput ~= "/// Returns: false if not set.\n";

    generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isUAX31_JS_Start", ranges.ranges, true, false);
}

void continue_JS() {
    ValueRanges ranges = ValueRanges(DerivedCoreProperties_Binary[DerivedCorePropertyBinary.ID_Continue].dup);
    ranges.add(ValueRange(0x24)); // add $
    // ranges.add(ValueRange(0x5F)); // add _, already in ID_Continue
    //ranges.add(ValueRange(0x200C, 0x200D)); // add ZWJ and ZWNJ, already exists in ID_Continue
    ranges.ranges.sort!((a, b) => a.start < b.start);

    implOutput ~= "\n";

    apiOutput ~= "\n";
    apiOutput ~= "/// Is UAX31 for Javascript continue set.\n";
    apiOutput ~= "/// Returns: false if not set.\n";

    generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isUAX31_JS_Continue", ranges.ranges, true, false);
}
