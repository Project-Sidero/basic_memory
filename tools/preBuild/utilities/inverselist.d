module utilities.inverselist;
import utilities.sequential_ranges : ValueRange;
import std.array : Appender;
import std.format;

void generateIsCheck(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, ValueRange!dchar[] ranges, bool invert = false) {
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

            foreach(range; ranges) {
                version(none) {
                    import std.stdio;

                    writeln(lastOut, " < ", cast(uint)range.start, " < ", cast(uint)range.end);
                }

                assert(lastOut < cast(int)range.start);
                implementationAppender.formattedWrite!"%08X%08X"(range.start, range.end + 1);
                lastOut = range.end + 1;
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender ~= q{
    ptrdiff_t low, high = Table.length;

    while(low < high) {
        const mid = low + ((high - low) / 2);

        if (against >= Table[mid])
            low = mid + 1;
        else if (against < Table[mid])
            high = mid;
    }

    const pos = high - 1;
    return (pos & 1) };

            implementationAppender ~= invert ? "!= 0;\n" : "== 0;\n";
        }

        implementationAppender ~= "}\n";
    }
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
    string functionName, ValueRange!dchar[] ranges, bool[] returnValues, string returnTypeName="bool") {
    generateIntegerReturn!(bool, 2)(interfaceAppender, implementationAppender, functionName, ranges, returnValues, returnTypeName);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
    string functionName, dchar[] ranges, bool[] returnValues, string returnTypeName="bool") {
    generateIntegerReturn!(bool, 2)(interfaceAppender, implementationAppender, functionName, ranges, returnValues, returnTypeName);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, ValueRange!dchar[] ranges, ubyte[] returnValues, string returnTypeName="ubyte") {
    generateIntegerReturn!(ubyte, 2)(interfaceAppender, implementationAppender, functionName, ranges, returnValues, returnTypeName);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, dchar[] ranges, ubyte[] returnValues, string returnTypeName="ubyte") {
    generateIntegerReturn!(ubyte, 2)(interfaceAppender, implementationAppender, functionName, ranges, returnValues, returnTypeName);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, ValueRange!dchar[] ranges, dchar[] returnValues) {
    generateIntegerReturn!(dchar, 8)(interfaceAppender, implementationAppender, functionName, ranges, returnValues);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, dchar[] ranges, dchar[] returnValues) {
    generateIntegerReturn!(dchar, 8)(interfaceAppender, implementationAppender, functionName, ranges, returnValues);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, ValueRange!dchar[] ranges, uint[] returnValues) {
    generateIntegerReturn!(uint, 8)(interfaceAppender, implementationAppender, functionName, ranges, returnValues);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, dchar[] ranges, uint[] returnValues) {
    generateIntegerReturn!(uint, 8)(interfaceAppender, implementationAppender, functionName, ranges, returnValues);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
    string functionName, ValueRange!dchar[] ranges, ulong[] returnValues) {
    generateIntegerReturn!(ulong, 16)(interfaceAppender, implementationAppender, functionName, ranges, returnValues);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
    string functionName, dchar[] ranges, ulong[] returnValues) {
    generateIntegerReturn!(ulong, 16)(interfaceAppender, implementationAppender, functionName, ranges, returnValues);
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, ValueRange!dchar[] ranges, dstring[] returnValues) {
    {
        interfaceAppender ~= "export extern(C) dstring ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(dchar against) @safe nothrow @nogc pure;\n";
    }

    {
        implementationAppender ~= "export extern(C) dstring ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(dchar against) @trusted nothrow @nogc pure {\n";

        {
            int lastOut = -1;
            implementationAppender ~= "    static immutable dchar[] Table = cast(dchar[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(range; ranges) {
                version(none) {
                    import std.stdio;

                    writeln(lastOut, " < ", cast(uint)range.start, " < ", cast(uint)range.end);
                }

                assert(range.start <= range.end);
                assert(lastOut < cast(int)range.start);
                implementationAppender.formattedWrite!"%08X%08X"(range.start, range.end);
                lastOut = range.end;
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        dstring returnInterned;
        uint[dstring] returnMap;
        uint mappedIntoReturnSoFar;

        {
            foreach(returnValue; returnValues) {
                if(returnValue !in returnMap) {
                    returnInterned ~= returnValue;
                    returnMap[returnValue] = mappedIntoReturnSoFar;
                    mappedIntoReturnSoFar += returnValue.length;
                }
            }
        }

        {
            implementationAppender ~= "    static immutable uint[] ReturnValues = cast(uint[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                implementationAppender.formattedWrite!"%08X%08X"(returnMap[returnValue], returnMap[returnValue] + returnValue.length);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 16 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            implementationAppender ~= "    static immutable dstring ReturnValuesInterned = cast(dstring)x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                foreach(c; returnValue)
                    implementationAppender.formattedWrite!"%08X"(c);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender ~= q{
    immutable(dchar[2][]) Table2 = (cast(immutable(dchar[2])*)Table.ptr)[0 .. Table.length / 2];
    ptrdiff_t low, high = Table2.length - 1;

    while(low <= high) {
        const mid = low + ((high - low) / 2);

        if (Table2[mid][0] <= against && against <= Table2[mid][1]) {
            const offset = ReturnValues[mid << 1];
            const offset2 = ReturnValues[(mid << 1) + 1];
            return ReturnValuesInterned[offset .. offset2];
        }

        if (Table2[mid][1] < against)
            low = mid + 1;
        else
            high = mid - 1;
    }

    return null;
};
        }

        implementationAppender ~= "}\n";
    }
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, dchar[] ranges, dstring[] returnValues) {
    {
        interfaceAppender ~= "export extern(C) dstring ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(dchar against) @safe nothrow @nogc pure;\n";
    }

    {
        implementationAppender ~= "export extern(C) dstring ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(dchar against) @trusted nothrow @nogc pure {\n";

        {
            implementationAppender ~= "    static immutable dchar[] Table = cast(dchar[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(range; ranges) {
                implementationAppender.formattedWrite!"%08X"(range);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        dstring returnInterned;
        uint[dstring] returnMap;
        uint mappedIntoReturnSoFar;

        {
            foreach(returnValue; returnValues) {
                if(returnValue !in returnMap) {
                    returnInterned ~= returnValue;
                    returnMap[returnValue] = mappedIntoReturnSoFar;
                    mappedIntoReturnSoFar += returnValue.length;
                }
            }
        }

        {
            implementationAppender ~= "    static immutable uint[] ReturnValues = cast(uint[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                implementationAppender.formattedWrite!"%08X%08X"(returnMap[returnValue], returnMap[returnValue] + returnValue.length);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 16 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            implementationAppender ~= "    static immutable dstring ReturnValuesInterned = cast(dstring)x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                foreach(c; returnValue)
                    implementationAppender.formattedWrite!"%08X"(c);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender ~= q{
    ptrdiff_t low, high = Table.length - 1;

    while(low <= high) {
        const mid = low + ((high - low) / 2);

        if (Table[mid] == against) {
            const offset = ReturnValues[mid << 1];
            const offset2 = ReturnValues[(mid << 1) + 1];
            return ReturnValuesInterned[offset .. offset2];
        } else if (Table[mid] < against)
            low = mid + 1;
        else
            high = mid - 1;
    }

    return null;
};
        }

        implementationAppender ~= "}\n";
    }
}

void generateReturn(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
    string functionName, ulong[] ranges, dchar[] returnValues) {
    {
        interfaceAppender ~= "export extern(C) dchar ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(ulong against) @safe nothrow @nogc pure;\n";
    }

    {
        implementationAppender ~= "export extern(C) dchar ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(ulong against) @trusted nothrow @nogc pure {\n";

        {
            implementationAppender ~= "    static immutable ulong[] Table = cast(ulong[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(range; ranges) {
                implementationAppender.formattedWrite!"%016X"(range);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 16 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            implementationAppender ~= "    static immutable dchar[] ReturnValues = cast(dchar[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                enum Format = "%08X";
                implementationAppender.formattedWrite!Format(returnValue);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender ~= q{
    ptrdiff_t low, high = Table.length - 1;

    while(low <= high) {
        const mid = low + ((high - low) / 2);

        if (Table[mid] == against)
            return ReturnValues[mid];
        else if (Table[mid] < against)
            low = mid + 1;
        else
            high = mid - 1;
    }

    return dchar.init;
};
        }

        implementationAppender ~= "}\n";
    }
}

private:

void generateIntegerReturn(Type, uint SizeToPrint)(ref Appender!string interfaceAppender,
        ref Appender!string implementationAppender, string functionName, ValueRange!dchar[] ranges, Type[] returnValues, string returnTypeName = Type.stringof) {
    {
        interfaceAppender ~= "export extern(C) ";
        interfaceAppender ~= returnTypeName;
        interfaceAppender ~= " ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(dchar against) @safe nothrow @nogc pure;\n";
    }

    {
        implementationAppender ~= "export extern(C) ";
        implementationAppender ~= Type.stringof;
        implementationAppender ~= " ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(dchar against) @trusted nothrow @nogc pure {\n";

        {
            int lastOut = -1;
            implementationAppender ~= "    static immutable Table = cast(immutable(dchar[]))x\"";
            const startLength = implementationAppender.data.length;

            foreach(range; ranges) {
                version(none) {
                    import std.stdio;

                    writeln(lastOut, " < ", cast(uint)range.start, " < ", cast(uint)range.end);
                }

                assert(range.start <= range.end);
                assert(lastOut < cast(int)range.start);
                implementationAppender.formattedWrite!"%08X%08X"(range.start, range.end);
                lastOut = range.end;
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            implementationAppender ~= "    static immutable ";
            implementationAppender ~= Type.stringof;
            implementationAppender ~= "[] ReturnValues = cast(";
            implementationAppender ~= Type.stringof;
            implementationAppender ~= "[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                enum Format = "%0" ~ SizeToPrint.stringof[0 .. $ - 1] ~ "X";
                implementationAppender.formattedWrite!Format(returnValue);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % SizeToPrint == 0);

            implementationAppender ~= "\";\n";
        }

        {
            implementationAppender ~= q{
    immutable(dchar[2][]) Table2 = (cast(immutable(dchar[2])*)Table.ptr)[0 .. Table.length / 2];
    ptrdiff_t low, high = Table2.length - 1;

    while(low <= high) {
        const mid = low + ((high - low) / 2);

        if (Table2[mid][0] <= against && against <= Table2[mid][1])
            return ReturnValues[mid];

        if (Table2[mid][1] < against)
            low = mid + 1;
        else
            high = mid - 1;
    }

    return typeof(return).init;
};
        }

        implementationAppender ~= "}\n";
    }
}

void generateIntegerReturn(Type, uint SizeToPrint)(ref Appender!string interfaceAppender, ref Appender!string implementationAppender,
        string functionName, dchar[] ranges, Type[] returnValues, string returnTypeName = Type.stringof) {
    {
        interfaceAppender ~= "export extern(C) ";
        interfaceAppender ~= returnTypeName;
        interfaceAppender ~= " ";
        interfaceAppender ~= functionName;
        interfaceAppender ~= "(dchar against) @safe nothrow @nogc pure;\n";
    }

    {
        implementationAppender ~= "export extern(C) ";
        implementationAppender ~= Type.stringof;
        implementationAppender ~= " ";
        implementationAppender ~= functionName;
        implementationAppender ~= "(dchar against) @trusted nothrow @nogc pure {\n";

        {
            implementationAppender ~= "    static immutable dchar[] Table = cast(dchar[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(range; ranges) {
                implementationAppender.formattedWrite!"%08X"(range);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % 8 == 0);

            implementationAppender ~= "\";\n";
        }

        {
            implementationAppender ~= "    static immutable ";
            implementationAppender ~= Type.stringof;
            implementationAppender ~= "[] ReturnValues = cast(";
            implementationAppender ~= Type.stringof;
            implementationAppender ~= "[])x\"";
            const startLength = implementationAppender.data.length;

            foreach(returnValue; returnValues) {
                enum Format = "%0" ~ SizeToPrint.stringof[0 .. $ - 1] ~ "X";
                implementationAppender.formattedWrite!Format(returnValue);
            }

            const diff = implementationAppender.data.length - startLength;
            assert(diff % SizeToPrint == 0);

            implementationAppender ~= "\";\n";
        }

        {
            // classic charInSet binary search as per Unicode Demystified pg.505

            implementationAppender ~= q{
    ptrdiff_t low, high = Table.length - 1;

    while(low <= high) {
        const mid = low + ((high - low) / 2);

        if (Table[mid] == against)
            return ReturnValues[mid];
        else if (Table[mid] < against)
            low = mid + 1;
        else
            high = mid - 1;
    }

    return typeof(return).init;
};
        }

        implementationAppender ~= "}\n";
    }
}