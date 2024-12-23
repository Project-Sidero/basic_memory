module utilities.intervallist;
import utilities.setops;
import std.array : Appender;
import std.format;

void generateIsCheck(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, ValueRange[] ranges, bool emitSet, bool invert = false) {

    if(!emitSet) {
        import utilities.inverselist;

        generateIsCheckInverseList(interfaceAppender, implementationAppender, functionName, ranges, invert);
        return;
    }

    {
        int lastOut = -1;

        implementationAppender ~= "static immutable dchar[] Table_";
        implementationAppender ~= functionName;
        implementationAppender ~= " = cast(dchar[])x\"";

        const startLength = implementationAppender.data.length;

        foreach(range; ranges) {
            version(none) {
                import std.stdio;

                writeln(lastOut, " < ", cast(uint)range.start, " < ", cast(uint)range.end);
            }

            assert(lastOut < cast(int)range.start);
            implementationAppender.formattedWrite!"%08X%08X"(range.start, range.end);
            lastOut = range.end;
        }

        const diff = implementationAppender.data.length - startLength;
        assert(diff % 8 == 0);

        implementationAppender ~= "\";\n\n";
    }

    {
        interfaceAppender ~= "deprecated ";
        interfaceAppender ~= "export extern(C) bool ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(dchar against) @safe nothrow @nogc pure;\n";

        interfaceAppender ~= "///\n";
        interfaceAppender ~= "export extern(C) IntervalSet!dchar ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "_Set() @safe nothrow @nogc;\n";
    }

    {
        implementationAppender ~= "export extern(C) bool ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(dchar against) @trusted nothrow @nogc pure {\n";

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender.formattedWrite!(q{    ptrdiff_t low, high = Table_%s.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_%s[mid << 1], end = Table_%s[(mid << 1) | 1];

        if (against >= start && against <= end)
            return %s;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return %s;
})(functionName, functionName, functionName, !invert, invert);

        }

        implementationAppender ~= "}\n";
    }

    {
        implementationAppender ~= "export extern(C) IntervalSet!dchar ";
        implementationAppender ~= functionName;
        implementationAppender ~= "_Set() @trusted nothrow @nogc {\n";

        implementationAppender ~= "    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(";
        implementationAppender ~= "cast(dstring)Table_";
        implementationAppender ~= functionName;
        implementationAppender ~= ");\n";

        implementationAppender ~= "    return cast(IntervalSet!dchar)Set;\n";
        implementationAppender ~= "}\n";
    }
}
