module generators.unicode.uax31;
import generators.unicode.derivedcoreproperties;
import constants;

void uax31Tables() {
    import std.file : write, append;
    import std.algorithm : sort;

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.uax31;\n";
    internal ~= "import sidero.base.containers.set.interval;\n";
    internal ~= "// Generated do not modify\n\n";

    auto api = appender!string();

    {
        ValueRanges ranges = ValueRanges(propertyXID_StartRanges.ranges.dup);
        ranges.add(ValueRange(0x5F)); // add _
        ranges.ranges.sort!((a, b) => a.start < b.start);

        internal ~= "\n";

        api ~= "\n";
        api ~= "/// Is UAX31 for C start set.\n";
        api ~= "/// Returns: false if not set.\n";

        generateIsCheck(api, internal, "sidero_utf_lut_isUAX31_C_Start", ranges.ranges, true);
    }

    {
        internal ~= "\n";

        api ~= "\n";
        api ~= "/// Is UAX31 for C continue set.\n";
        api ~= "/// Returns: false if not set.\n";

        generateIsCheck(api, internal, "sidero_utf_lut_isUAX31_C_Continue", propertyXID_ContinueRanges.ranges, true);
    }

    {
        ValueRanges ranges = ValueRanges(propertyID_StartRanges.ranges.dup);
        ranges.add(ValueRange(0x24)); // add $
        ranges.add(ValueRange(0x5F)); // add _
        ranges.ranges.sort!((a, b) => a.start < b.start);

        internal ~= "\n";

        api ~= "\n";
        api ~= "/// Is UAX31 for Javascript start set.\n";
        api ~= "/// Returns: false if not set.\n";

        generateIsCheck(api, internal, "sidero_utf_lut_isUAX31_JS_Start", ranges.ranges, true);
    }

    {
        ValueRanges ranges = ValueRanges(propertyID_ContinueRanges.ranges.dup);
        ranges.add(ValueRange(0x24)); // add $
        // ranges.add(ValueRange(0x5F)); // add _, already in ID_Continue
        //ranges.add(ValueRange(0x200C, 0x200D)); // add ZWJ and ZWNJ, already exists in ID_Continue
        ranges.ranges.sort!((a, b) => a.start < b.start);

        internal ~= "\n";

        api ~= "\n";
        api ~= "/// Is UAX31 for Javascript continue set.\n";
        api ~= "/// Returns: false if not set.\n";

        generateIsCheck(api, internal, "sidero_utf_lut_isUAX31_JS_Continue", ranges.ranges, true);
    }

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "uax31.d", internal.data);
}

private:
import std.array : appender;
import utilities.setops;
import utilities.inverselist;
import utilities.intervallist;
