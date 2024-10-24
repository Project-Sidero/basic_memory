/**
This module parses the UCD DerivedCoreProperties.txt file.

Copyright:   Copyright (C) 1999-2024 by The D Language Foundation, All Rights Reserved
Authors:     $(LINK2 https://cattermole.co.nz, Richard (Rikki) Andrew Cattermole
License:     $(LINK2 https://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
*/
module generators.unicode.derivedcoreproperties;
import utilities.setops;
import constants;

ValueRanges propertyXID_StartRanges, propertyXID_ContinueRanges;
ValueRanges propertyID_StartRanges, propertyID_ContinueRanges;

void parseDerivedCoreProperties() {
    import std.file : readText;
    processEachLine(readText(UnicodeDatabaseDirectory ~ "DerivedCoreProperties.txt"));
}

void processEachLine(string inputText) {
    import std.algorithm : countUntil, startsWith;
    import std.string : lineSplitter, strip, split;
    import std.conv : parse;

    foreach(line; inputText.lineSplitter) {
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
        case "XID_Start":
            propertyXID_StartRanges.add(range);
            break;

        case "XID_Continue":
            propertyXID_ContinueRanges.add(range);
            break;

        case "ID_Start":
            propertyID_StartRanges.add(range);
            break;

        case "ID_Continue":
            propertyID_ContinueRanges.add(range);
            break;

        default:
            break;
        }
    }
}
