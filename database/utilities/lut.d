module utilities.lut;
import utilities.sequential_ranges;
import std.traits : isNumeric, isSomeChar, isArray;

/*

Some possible improvements:

1. Split out the (w|d|)string storage, so it can be shared between LUT's
2. For each LUTDatem, when it is a lookup in a table, see if we can prevent duplicating entries.
3. Support a secondary lookup.
4. TRIES

*/

struct LookupTableGenerator(MetaDataEntry, MetaDataGroup = SequentialRangeSplitGroup, size_t NumberOfLayers = 0, KeyType = dchar)
        if (isNumeric!KeyType || isSomeChar!KeyType) {

    SequentialRanges!(MetaDataEntry, SequentialRangeSplitGroup, NumberOfLayers, KeyType) sr;
    string lutType, externType;
    string name;
    string defaultReturn;
    MetaDataEntry delegate(dchar) @safe defaultEntryDel;
    void delegate(ref Appender!string, ref MetaDataEntry) @safe outputValueDel;
    string[string] typeToReplacedName;

    string[2] build() {
        resultAppender = appender!string();
        lutName = format!"LUT_%X"(hashOf(name));

        prepare();
        emitSignature();
        emitFunction();
        emitTables;

        resultAppender ~= "\n";
        return [sigAppender.data.idup, resultAppender.data.idup];
    }

private:
    import std.array : Appender, appender;
    import std.format : formattedWrite, format;

    static string TabPrefix = () {
        string ret;
        foreach (i; 0 .. NumberOfLayers + 2)
            ret ~= "    ";
        return ret;
    }();

    Appender!string resultAppender, sigAppender;
    string lutName;
    LUTCondition topCondition;

    Appender!string wipString, wipWString, wipDString;
    size_t wipStringSoFar, wipWStringSoFar, wipDStringSoFar;
    size_t[string] stringToOffset;
    size_t[wstring] wstringToOffset;
    size_t[dstring] dstringToOffset;

    void prepare() {
        size_t entriesSoFar;
        ValueRange!KeyType[NumberOfLayers] actualValueRanges;

        LUTCondition* evalLayer(scope size_t[] layerIndexes, ValueRange!KeyType datemVR, scope ValueRange!KeyType[] layerRanges) {
            LUTCondition* parent = &topCondition;

            foreach (layerOffset, layer; layerIndexes) {
                if (layer == 0)
                    actualValueRanges[layerOffset] = layerRanges[layerOffset];
            }

            foreach_reverse (layerOffset, layer; layerIndexes) {
                if (layer == 0) {
                    parent.children ~= LUTCondition(parent);
                    parent = &parent.children[$ - 1];
                    parent.depth = parent.parent.depth + 1;
                    parent.range = actualValueRanges[layerOffset];
                } else {
                    parent = &parent.children[$ - 1];
                }
            }

            return parent;
        }

        foreach (datem, layerIndex; sr) {
            LUTCondition* condition = evalLayer(layerIndex[], datem.range, datem.rangeOnLayer[]);
            condition.data ~= prepareDatem(datem, entriesSoFar);
        }

        void updateDepth(LUTCondition* condition, size_t depth) {
            condition.depth = depth;

            foreach (ref child; condition.children) {
                updateDepth(&child, depth + 1);
            }
        }

        void moveToParent(LUTCondition* condition) {
        Retry:
            if (condition.children.length == 1) {
                LUTCondition* child = &condition.children[0];
                condition.range = child.range;
                condition.children = child.children;
                condition.data ~= child.data;

                updateDepth(condition, condition.depth);
                goto Retry;
            } else {
                foreach (ref child; condition.children) {
                    moveToParent(&child);
                }
            }
        }

        moveToParent(&topCondition);

        version (none) {
            import std.stdio;

            void print(LUTCondition* condition, size_t depth) {
                string prefix = TabPrefix[0 .. depth * 4];

                foreach (i; 0 .. depth)
                    write(" |");
                write(" .");

                write(prefix);
                writefln!"if (input >= 0x%X && input <= 0x%X)"(condition.range.start, condition.range.end);

                foreach (ref child; condition.children) {
                    print(&child, depth + 1);
                }
            }

            print(&topCondition, 0);
        }
    }

    LUTDatem prepareDatem(ref sr.Datem datem, ref size_t entriesSoFar) {
        LUTDatem lutDatem;
        lutDatem.datem = datem;
        lutDatem.entriesCount = datem.allTheSame ? 1 : datem.metadataEntries.length;

        if (lutDatem.entriesCount > 1 || lutType[$ - 1] == '*') {
            lutDatem.entriesOffset = entriesSoFar;
            lutDatem.entriesInLUT = lutDatem.entriesCount;
            entriesSoFar += lutDatem.entriesInLUT;
        } else
            lutDatem.entriesOffset = -1;

        return lutDatem;
    }

    void emitSignature() {
        sigAppender.formattedWrite!"export extern(C) immutable(%s) %s(%s input) @trusted nothrow @nogc pure;\n"(externType.length > 0
                ? externType : lutType, name, KeyType.stringof);
    }

    void emitFunction() {
        resultAppender.formattedWrite!"export extern(C) immutable(%s) %s(%s input) @trusted nothrow @nogc pure {\n"(lutType,
                name, KeyType.stringof);

        void handleData(LUTDatem[] data, size_t depth, bool forceCheck = false) {
            bool haveMoreThanOne = data.length > 1;
            string currentPrefixCondition = TabPrefix[0 .. depth * 4],
                currentPrefixReturn = TabPrefix[0 .. (depth + cast(size_t)(haveMoreThanOne || forceCheck)) * 4];

            foreach (i, lutDatem; data) {
                if (haveMoreThanOne || forceCheck) {
                    resultAppender ~= currentPrefixCondition;
                    if (i > 0)
                        resultAppender ~= "else ";

                    resultAppender ~= "if (";
                    if (lutDatem.datem.range.isSingle)
                        resultAppender.formattedWrite!"input == 0x%X"(lutDatem.datem.range.start);
                    else if (i == 0 && NumberOfLayers > 0 && !forceCheck && depth > 1)
                        resultAppender.formattedWrite!"input <= 0x%X"(lutDatem.datem.range.end);
                    else if (i == data.length - 1 && NumberOfLayers > 0 && !forceCheck && depth > 1)
                        resultAppender.formattedWrite!"input >= 0x%X"(lutDatem.datem.range.start);
                    else
                        resultAppender.formattedWrite!"input >= 0x%X && input <= 0x%X"(lutDatem.datem.range.start,
                                lutDatem.datem.range.end);
                    resultAppender ~= ")\n";
                }

                resultAppender ~= currentPrefixReturn;

                if (lutDatem.entriesOffset >= 0) {
                    resultAppender ~= "return cast(" ~ lutType ~ ")";
                    if (lutType[$ - 1] == '*')
                        resultAppender ~= "&";

                    resultAppender.formattedWrite!"%s[cast(size_t)(%s + (input - 0x%X))]"(lutName, lutDatem.entriesOffset,
                    cast(size_t)lutDatem.datem.range.start);
                    resultAppender ~= ";\n";
                } else {
                    if (lutType == "long[]") {
                        resultAppender ~= "{ static immutable ret = ";
                        emitLiteral(resultAppender, lutDatem.datem.metadataEntries[0]);
                        resultAppender ~= ";\n";

                        resultAppender ~= currentPrefixReturn;
                        resultAppender ~= "return ret";
                        resultAppender ~= "; }\n";
                    } else {
                        resultAppender ~= "return cast(" ~ lutType ~ ")";
                        emitLiteral(resultAppender, lutDatem.datem.metadataEntries[0]);
                        resultAppender ~= ";\n";
                    }
                }

            }
        }

        void handleCondition(LUTCondition[] siblings, size_t depth) {
            string currentPrefix = TabPrefix[0 .. depth * 4];

            foreach (i, sibling; siblings) {
                resultAppender ~= currentPrefix;
                if (i > 0)
                    resultAppender ~= "} else ";

                resultAppender ~= "if (";

                if (sibling.range.isSingle)
                    resultAppender.formattedWrite!"input == 0x%X"(sibling.range.start);
                else if (i == 0 && depth > 1 && depth > 1)
                    resultAppender.formattedWrite!"input <= 0x%X"(sibling.range.end);
                else if (i == siblings.length - 1 && depth > 1)
                    resultAppender.formattedWrite!"input >= 0x%X"(sibling.range.start);
                else
                    resultAppender.formattedWrite!"input >= 0x%X && input <= 0x%X"(sibling.range.start, sibling.range.end);

                resultAppender ~= ") {\n";

                if (sibling.children.length > 0) {
                    handleCondition(sibling.children, depth + 1);
                } else {
                    handleData(sibling.data, depth + 1);
                }
            }

            if (siblings.length > 0) {
                resultAppender ~= currentPrefix;
                resultAppender ~= "}\n";
            }
        }

        if (topCondition.data.length > 0)
            handleData(topCondition.data, 1, true);
        else
            handleCondition(topCondition.children, 1);

        emitReturn;
        resultAppender ~= "}\n";
    }

    void emitReturn() {
        if (defaultReturn) {
            resultAppender ~= "    return " ~ defaultReturn ~ ";\n";
            return;
        }

        switch (lutType) {
        case "string":
        case "wstring":
        case "dstring":
        case "void*":
        case "void[]":
        case "long[]":
            resultAppender ~= "    return null;\n";
            break;
        default:
            resultAppender ~= "    return typeof(return).init;\n";
            break;
        }
    }

    void emitTables() {
        size_t doneSoFar = resultAppender.data.length;

        emitLUT;

        if (resultAppender.data.length == doneSoFar && (wipString.data.length + wipWString.data.length + wipDString.data.length > 0))
            resultAppender ~= "private {\n";
        emitStringTables;

        if (resultAppender.data.length > doneSoFar)
            resultAppender ~= "}\n";
    }

    void emitLUT() {
        void handle(ref LUTDatem lutDatem) {
            if (lutDatem.entriesInLUT == 0)
                return;

            version (none)
                resultAppender ~= "\t";

            foreach (i, entry; lutDatem.datem.metadataEntries) {
                emitLiteral(resultAppender, entry);
                resultAppender ~= ", ";
            }

            version (none)
                resultAppender ~= "\n";
        }

        void recurse(ref LUTCondition condition) {
            if (condition.data.length > 0) {
                foreach (datem; condition.data) {
                    handle(datem);
                }
            } else {
                foreach (child; condition.children) {
                    recurse(child);
                }
            }
        }

        bool checkNeed(ref LUTCondition condition) {
            if (condition.data.length > 0) {
                foreach (lutDatem; condition.data) {
                    if (lutDatem.entriesInLUT > 0)
                        return true;
                }

                return false;
            } else {
                foreach (child; condition.children) {
                    if (checkNeed(child))
                        return true;
                }
            }

            return false;
        }

        if (!checkNeed(topCondition))
            return;
        resultAppender ~= "private {\n";

        resultAppender ~= TabPrefix[0 .. 4];
        resultAppender ~= "static immutable ";
        resultAppender ~= lutName ~ " = [";
        recurse(topCondition);
        resultAppender ~= "];\n";
    }

    void emitLiteral(Type)(ref Appender!string into, Type entry) {
        size_t addString(string value) {
            if (auto got = (value in stringToOffset))
                return *got;

            string sanitized;
            sanitized.reserve(value.length);
            size_t result = wipStringSoFar;

            foreach (char c; value) {
                sanitized ~= format!"0x%.2X, "(c);
                wipStringSoFar++;
            }

            stringToOffset[value] = result;
            wipString ~= sanitized;
            return result;
        }

        size_t addWString(wstring value) {
            if (auto got = (value in wstringToOffset))
                return *got;

            wstring sanitized;
            sanitized.reserve(value.length);
            size_t result = wipWStringSoFar;

            foreach (wchar c; value) {
                if (c <= ubyte.max)
                    sanitized ~= format!"0x%.2X, "w(c);
                else
                    sanitized ~= format!"0x%.4X, "w(c);
                wipWStringSoFar++;
            }

            wstringToOffset[value] = result;
            wipWString ~= sanitized;
            return result;
        }

        size_t addDString(dstring value) {
            if (auto got = (value in dstringToOffset))
                return *got;

            dstring sanitized;
            sanitized.reserve(value.length);
            size_t result = wipDStringSoFar;

            foreach (dchar c; value) {
                if (c <= ubyte.max)
                    sanitized ~= format!"0x%.2X, "d(c);
                else if (c <= ushort.max)
                    sanitized ~= format!"0x%.4X, "d(c);
                else
                    sanitized ~= format!"0x%.8X, "d(c);
                wipDStringSoFar++;
            }

            dstringToOffset[value] = result;
            wipDString ~= sanitized;
            return result;
        }

        static if (is(Type == MetaDataEntry)) {
            if (outputValueDel !is null) {
                outputValueDel(into, entry);
                return;
            }
        }

        static if (is(Type == string)) {
            if (entry.length == 0)
                into ~= "null";
            else {
                size_t offset = addString(entry);
                into.formattedWrite!"%s_String[%s .. %s]"(lutName, offset, offset + entry.length);
            }
        } else static if (is(Type == wstring)) {
            if (entry.length == 0)
                into ~= "null";
            else {
                size_t offset = addWString(entry);
                into.formattedWrite!"%s_WString[%s .. %s]"(lutName, offset, offset + entry.length);
            }
        } else static if (is(Type == dstring)) {
            if (entry.length == 0)
                into ~= "null";
            else {
                size_t offset = addDString(entry);
                into.formattedWrite!"%s_DString[%s .. %s]"(lutName, offset, offset + entry.length);
            }
        } else static if (is(Type == enum)) {
            into.formattedWrite!"%s.%s"(typeToReplacedName.get(__traits(identifier, Type), __traits(identifier, Type)), entry);
        } else static if (isNumeric!Type) {
            into.formattedWrite!"%s"(entry);

            static if (is(Type == long)) {
                into ~= "L";
            }
        } else static if (isSomeChar!Type) {
            into.formattedWrite!"0x%X"(entry);
        } else static if (is(Type == bool)) {
            into.formattedWrite!"%s"(entry);
        } else static if (is(Type == struct)) {
            into ~= typeToReplacedName.get(__traits(identifier, Type), __traits(identifier, Type));
            into ~= "(";

            static foreach (i; 0 .. Type.tupleof.length) {
                if (i > 0)
                    into ~= ", ";
                emitLiteral(into, entry.tupleof[i]);
            }

            into ~= ")";
        } else static if (isArray!Type) {
            into ~= "[";

            foreach(i, value; entry) {
                if (i > 0)
                    into ~= ", ";
                emitLiteral(into, value);
            }

            into ~= "]";
        }
    }

    void emitStringTables() {
        string currentPrefix = TabPrefix[0 .. 4];

        if (wipString.data.length > 0) {
            resultAppender ~= currentPrefix;
            resultAppender ~= "static immutable string " ~ lutName ~ "_String = cast(string)[cast(ubyte)";
            resultAppender ~= wipString.data;
            resultAppender ~= "];\n";
        }

        if (wipWString.data.length > 0) {
            resultAppender ~= currentPrefix;
            resultAppender ~= "static immutable wstring " ~ lutName ~ "_WString = cast(wstring)[cast(ushort)";
            resultAppender ~= wipWString.data;
            resultAppender ~= "];\n";
        }

        if (wipDString.data.length > 0) {
            resultAppender ~= currentPrefix;
            resultAppender ~= "static immutable dstring " ~ lutName ~ "_DString = cast(dstring)[cast(uint)";
            resultAppender ~= wipDString.data;
            resultAppender ~= "];\n";
        }
    }

    struct LUTCondition {
        LUTCondition* parent;
        size_t depth;

        ValueRange!KeyType range;
        LUTCondition[] children;
        LUTDatem[] data;
    }

    struct LUTDatem {
        ptrdiff_t entriesOffset;
        size_t entriesCount, entriesInLUT;
        typeof(sr).Datem datem;
    }
}
