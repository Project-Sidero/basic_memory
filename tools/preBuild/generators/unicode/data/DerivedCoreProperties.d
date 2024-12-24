module generators.unicode.data.DerivedCoreProperties;
import utilities.setops;

__gshared {
    ValueRange[][__traits(allMembers, DerivedCorePropertyBinary).length] DerivedCoreProperties_Binary;
    ValueRange[][__traits(allMembers, DerivedCorePropertyValue).length][__traits(allMembers, DerivedCorePropertyKey).length] DerivedCoreProperties_Map;
}

enum DerivedCorePropertyBinary {
    Math,
    Alphabetic,
    Lowercase,
    Uppercase,
    Cased,
    Case_Ignorable,
    Changes_When_Lowercased,
    Changes_When_Uppercased,
    Changes_When_Titlecased,
    Changes_When_Casefolded,
    Changes_When_Casemapped,
    ID_Start,
    ID_Continue,
    XID_Start,
    XID_Continue,
    Default_Ignorable_Code_Point,
    Grapheme_Extend,
    Grapheme_Base,
}

enum DerivedCorePropertyKey {
    InCB,
}

enum DerivedCorePropertyValue {
    Linker,
    Consonant,
    Extend
}

void processDerivedCoreProperties(string inputText) {
    import std.algorithm : countUntil, startsWith;
    import std.string : lineSplitter, strip, split;
    import std.conv : parse;

    LoopLine: foreach(line; inputText.lineSplitter) {
        {
            // handle end of line comment
            ptrdiff_t offset = line.countUntil('#');
            if(offset >= 0)
                line = line[0 .. offset];
            line = line.strip;
        }

        string[] fields = line.split(";");
        {
            foreach(ref field; fields) {
                field = field.strip;
            }

            if(fields.length == 0) {
                continue;
            } else if(fields.length != 2) {
                continue;
            }
        }

        ValueRange range;

        {
            range.start = parse!uint(fields[0], 16);

            if(fields[0].startsWith("..")) {
                fields[0] = fields[0][2 .. $];
                range.end = parse!uint(fields[0], 16);
            } else {
                range.end = range.start;
            }
        }

        switch(fields[1]) {
        case "Grapheme_Link":
            // deprecated
            break;

            static foreach(m; __traits(allMembers, DerivedCorePropertyBinary)) {
        case m:
                DerivedCoreProperties_Binary[cast(uint)__traits(getMember, DerivedCorePropertyBinary, m)] ~= range;
                continue LoopLine;
            }

            static foreach(m; __traits(allMembers, DerivedCorePropertyKey)) {
        case m:
                DerivedCorePropertyKey key = __traits(getMember, DerivedCorePropertyKey, m);

                switch(fields[2]) {
                    static foreach(m2; __traits(allMembers, DerivedCorePropertyValue)) {
                case m2:
                        DerivedCorePropertyValue value = __traits(getMember, DerivedCorePropertyValue, m2);
                        DerivedCoreProperties_Map[cast(uint)key][cast(uint)value] ~= range;
                        continue LoopLine;
                    }

                default:
                    assert(0, "Unrecognized " ~ fields[1] ~ "." ~ fields[2]);
                }
                continue LoopLine;
            }

        default:
            assert(0, "Unrecognized " ~ fields[1]);
        }
    }
}
