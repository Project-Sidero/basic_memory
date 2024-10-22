module utilities.inverselist;
import utilities.sequential_ranges : ValueRange;
import std.array : Appender;
import std.format;

void generateIsCheck(ref Appender!string interfaceAppender, ref Appender!string implementationAppender, string functionName, ValueRange!dchar[] ranges) {
    {
        interfaceAppender ~= "export extern(C) bool ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(dchar against) @safe nothrow @nogc pure;\n";
    }

    {
        implementationAppender ~= "export extern(C) bool ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(dchar against) @trusted nothrow @nogc pure {\n";

        {
            int lastOut = -1;
            implementationAppender ~= "    static immutable dchar[] Table = cast(dchar[])x\"";
            const startLength = implementationAppender.data.length;

            foreach (range; ranges) {
                version(none) {
                    import std.stdio;
                    writeln(lastOut, " < ", cast(uint)range.start, " < ", cast(uint)range.end);
                }

                assert(lastOut < cast(int)range.start);
                implementationAppender.formattedWrite!"%08X%08X"(range.start, range.end + 1);
                lastOut = range.end +1;
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender ~= q{
    size_t low, high = Table.length;

    while(low < high) {
        size_t mid = (low + high) / 2;

        if (against >= Table[mid])
            low = mid + 1;
        else if (against < Table[mid])
            high = mid;
    }

    const pos = high - 1;
    return (pos & 1) == 0;
};
        }

        implementationAppender ~= "}\n";
    }
}
