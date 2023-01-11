module sidero.base.datetime.time.internal.posix;
import sidero.base.text;
import sidero.base.errors;

package(sidero.base.datetime) @safe nothrow @nogc:

String_UTF8 getPosixLocalTimeZone() @trusted {
    import sidero.base.internal.filesystem;
    import sidero.base.containers.dynamicarray;

    // based upon https://stackoverflow.com/a/33881726

    // only available on *nix obviously
    version (Posix) {
        String_UTF8 findField(scope DynamicArray!char input, scope string field) {
            while(input.length > 0) {
                ptrdiff_t index = input.indexOf(field);

                if (index < 0)
                    return typeof(return).init;

                input = input[index .. $];
                index = input.indexOf("=");

                if (index < 0)
                    return typeof(return).init;

                String_UTF8 key = String_UTF8(input[0 .. index].unsafeGetLiteral);
                key.strip;

                input = input[index + 1 .. $];
                index = input.indexOf("\n");

                if (index >= 0)
                     input = input[0 .. index];

                String_UTF8 value = String_UTF8(input.unsafeGetLiteral);
                value.strip;

                if (key == field)
                    return value.dup;
            }

            return typeof(return).init;
        }

        {
            // /etc/timezone
            // read first line, strip, return
            auto read = readFile!char("/etc/timezone\0", tzFileSize[0]);

            if (read.length > 0) {
                tzFileSize[0] = read.length;

                String_UTF8 temp = String_UTF8(read.unsafeGetLiteral);

                ptrdiff_t index = temp.indexOf("\n");
                if (index >= 0)
                    temp = temp[0 .. index];
                temp.strip;

                localOlsonName = temp.dup;
                return localOlsonName;
            }

            if (tzFileSize[0] > 0)
                return localOlsonName;
        }

        {
            // /etc/sysconfig/clock
            // read, find ZONE field, strip, remove quotes, return
            auto read = readFile!char("/etc/sysconfig/clock\0", tzFileSize[1]);
            auto field = findField(read, "ZONE");

            if (field.length > 0) {
                tzFileSize[1] = read.length;
                localOlsonName = field;
            }

            if (tzFileSize[1] > 0)
                return localOlsonName;
        }

        {
            // /etc/TIMEZONE
            // read, find TZ field, strip, remove quotes, return
            auto read = readFile!char("/etc/sysconfig/clock\0", tzFileSize[2]);
            auto field = findField(read, "TZ");

            if (field.length > 0) {
                tzFileSize[2] = read.length;
                localOlsonName = field;
            }

            if (tzFileSize[2] > 0)
                return localOlsonName;
        }
    }

    return typeof(return).init;
}

Result!PosixTZ parsePosixTZ(scope String_UTF8 spec) @trusted {
    import sidero.base.text.unicode.characters.database;

    // https://github.com/eggert/tz/blob/main/localtime.c#L1123
    // https://pubs.opengroup.org/onlinepubs/9699919799.2018edition/basedefs/V1_chap08.html
    // https://www.gnu.org/software/libc/manual/html_node/TZ-Variable.html

    // prevent runaway string -> integer conversions
    if (spec.isEncodingChanged || !spec.isPtrNullTerminated)
        spec = spec.dup;

    if (spec.startsWith("/")) {
        // use a specific TZif file
        return typeof(return)(PosixTZ(spec));
    } else {
        String_UTF8 stdName, dstName;
        long stdOffset, dstOffset;
        PosixTZRule stdTransition, dstTransition;

        String_UTF8 zname() @safe nothrow @nogc {
            //  ([a-zA-Z]![,-+])*\0?

            size_t count;

            foreach (c; spec) {
                if (c.isAlpha)
                    count++;
                else
                    break;
            }

            auto ret = spec[0 .. count];
            spec = spec[count .. $];
            return ret;
        }

        String_UTF8 timeOfDay(scope ref long seconds) @trusted nothrow @nogc {
            import core.stdc.stdlib : strtoll;

            //  hh (:mm (:ss)?)?

            String_UTF8 original = spec;
            size_t length;

            String_UTF8 hour, minute, second;

            {
                size_t count;
                foreach (c; spec) {
                    if ((c >= '0' && c <= '9'))
                        count++;
                    else
                        break;
                }

                if (count == 0)
                    return typeof(return).init;

                length += count;
                hour = spec[0 .. count];
                spec = spec[count .. $];
            }

            if (spec.startsWith(":")) {
                spec = spec[1 .. $];
                length++;

                size_t count;
                foreach (c; spec) {
                    if ((c >= '0' && c <= '9'))
                        count++;
                    else
                        break;
                }

                if (count > 0) {
                    length += count;
                    minute = spec[0 .. count];
                    spec = spec[count .. $];
                }
            }

            if (spec.startsWith(":")) {
                spec = spec[1 .. $];
                length++;

                size_t count;
                foreach (c; spec) {
                    if ((c >= '0' && c <= '9'))
                        count++;
                    else
                        break;
                }

                if (count > 0) {
                    length += count;
                    second = spec[0 .. count];
                    spec = spec[count .. $];
                }
            }

            {
                auto literal = hour.unsafeGetLiteral;
                seconds = strtoll(literal.ptr, null, 10) * 60 * 60;
            }

            if (minute.length > 0) {
                auto literal = minute.unsafeGetLiteral;
                seconds += strtoll(literal.ptr, null, 10) * 60;
            }

            if (second.length > 0) {
                auto literal = second.unsafeGetLiteral;
                seconds += strtoll(literal.ptr, null, 10);
            }

            return original[0 .. length];
        }

        String_UTF8 timeDelta(scope ref long seconds) @safe nothrow @nogc {
            //  [-+]?timeOfDay

            bool wasNegative;

            if (spec.startsWith("+")) {
                spec = spec[1 .. $];
            } else if (spec.startsWith("-")) {
                wasNegative = true;
                spec = spec[1 .. $];
            }

            auto ret = timeOfDay(seconds);

            if (wasNegative)
                seconds *= -1;

            return ret;
        }

        String_UTF8 rule(scope ref PosixTZRule output) @trusted {
            import core.stdc.stdlib : strtoll;

            String_UTF8 original = spec;
            size_t matched;

            // rule: default 120s
            if (spec.startsWith("J")) {
                //  J[1-365] ruleTime?
                spec = spec[1 .. $];
                matched = 1;

                output.type = PosixTZRule.Type.JulianDay;

                auto literal = spec.unsafeGetLiteral;
                const(char)* end = literal.ptr;

                output.julianDay = cast(ushort)strtoll(literal.ptr, &end, 10);

                const count = end - literal.ptr;
                matched += count;
                spec = spec[count .. $];
            } else if (spec.startsWith("M")) {
                //  M[1-12].[1-5].[0-6] ruleTime?
                spec = spec[1 .. $];
                matched = 1;
                output.type = PosixTZRule.Type.DayInWeekOfMonth;

                {
                    auto literal = spec.unsafeGetLiteral;
                    const(char)* end = literal.ptr;

                    output.monthOfYear = cast(ubyte)strtoll(literal.ptr, &end, 10);

                    const count = end - literal.ptr;
                    matched += count;
                    spec = spec[count .. $];
                }

                if (spec.startsWith(".")) {
                    spec = spec[1 .. $];
                    matched++;

                    auto literal = spec.unsafeGetLiteral;
                    const(char)* end = literal.ptr;

                    output.weekOfMonth = cast(ubyte)strtoll(literal.ptr, &end, 10);

                    const count = end - literal.ptr;
                    matched += count;
                    spec = spec[count .. $];
                }

                if (spec.startsWith(".")) {
                    spec = spec[1 .. $];
                    matched++;

                    auto literal = spec.unsafeGetLiteral;
                    const(char)* end = literal.ptr;

                    output.dayOfWeek = cast(ubyte)strtoll(literal.ptr, &end, 10);

                    const count = end - literal.ptr;
                    matched += count;
                    spec = spec[count .. $];
                }
            } else {
                //  [0-365] ruleTime?, supports leap years, process via Julian calendar to gregorian

                output.type = PosixTZRule.Type.DayOfYear;

                auto literal = spec.unsafeGetLiteral;
                const(char)* end = literal.ptr;

                output.dayOfYear = cast(ushort)strtoll(literal.ptr, &end, 10);

                const count = end - literal.ptr;
                matched += count;
                spec = spec[count .. $];
            }

            if (matched == 0) {
                return String_UTF8.init;
            }

            if (spec.startsWith("/")) {
                spec = spec[1 .. $];
                matched++;

                auto found = timeDelta(output.secondsBias);
                if (found.length == 0)
                    output.secondsBias = 7200;
                else
                    matched += found.length;
            } else {
                output.secondsBias = 7200;
            }

            return original[0 .. matched];
        }

        {
            if (spec.startsWith("<")) {
                // < stdname >
                ptrdiff_t index = spec.indexOf(">");
                if (index < 0)
                    return typeof(return)(MalformedInputException("Standard name if in < ... > must have > after it"));
                stdName = spec[1 .. index];
                spec = spec[index + 1 .. $];
            } else {
                // stdname, zname
                stdName = zname();
            }

            if (stdName.length < 3)
                return typeof(return)(MalformedInputException("Standard name must be longer than 2 characters"));
        }

        {
            // stdoffset, timeDelta
            timeDelta(stdOffset);
        }

        {
            if (spec.startsWith("<")) {
                // < dstname >
                ptrdiff_t index = spec.indexOf(">");
                if (index < 0)
                    return typeof(return)(MalformedInputException("DST name if in < ... > must have > after it"));
                dstName = spec[1 .. index];
                spec = spec[index + 1 .. $];
            } else {
                // dstname, zname
                dstName = zname();
            }

            if (dstName.length > 0 && dstName.length < 3)
                return typeof(return)(MalformedInputException("DST name must be longer than 2 characters"));
        }

        if (dstName.length > 0) {
            // dstoffset, timeDelta
            timeDelta(dstOffset);
        } else {
            dstOffset = 60 * 60;
        }

        {
            // [,;]
            if (spec.startsWith(",") || spec.startsWith(";")) {
                spec = spec[1 .. $];

                // start, rule
                rule(dstTransition);

                if (dstTransition.type == PosixTZRule.Type.DayInWeekOfMonth) {
                    if (dstTransition.monthOfYear < 1 || dstTransition.monthOfYear > 12)
                        return typeof(return)(MalformedInputException("DST Month must be between 1 and 12 inclusive"));
                    else if (dstTransition.weekOfMonth < 1 || dstTransition.weekOfMonth > 5)
                        return typeof(return)(MalformedInputException("DST Week of month must be between 1 and 5 inclusive"));
                    else if (dstTransition.dayOfWeek > 6)
                        return typeof(return)(MalformedInputException("DST Day of week must be between 0 and 6 inclusive"));
                } else if (dstTransition.type == PosixTZRule.Type.JulianDay) {
                    if (dstTransition.julianDay < 1 || dstTransition.julianDay > 365)
                        return typeof(return)(MalformedInputException("DST Julian day must be between 1 and 365 inclusive"));
                } else if (dstTransition.type == PosixTZRule.Type.DayOfYear) {
                    if (dstTransition.dayOfYear > 365)
                        return typeof(return)(MalformedInputException("DST day in year must be between 0 and 365 inclusive"));
                }
            }
        }

        {
            // [,;]
            if (spec.startsWith(",") || spec.startsWith(";")) {
                spec = spec[1 .. $];

                // end, rule
                rule(stdTransition);

                if (stdTransition.type == PosixTZRule.Type.DayInWeekOfMonth) {
                    if (stdTransition.monthOfYear < 1 || stdTransition.monthOfYear > 12)
                        return typeof(return)(MalformedInputException("STD Month must be between 1 and 12 inclusive"));
                    else if (stdTransition.weekOfMonth < 1 || stdTransition.weekOfMonth > 5)
                        return typeof(return)(MalformedInputException("STD Week of month must be between 1 and 5 inclusive"));
                    else if (stdTransition.dayOfWeek > 6)
                        return typeof(return)(MalformedInputException("STD Day of week must be between 0 and 6 inclusive"));
                } else if (stdTransition.type == PosixTZRule.Type.JulianDay) {
                    if (stdTransition.julianDay < 1 || stdTransition.julianDay > 365)
                        return typeof(return)(MalformedInputException("STD Julian day must be between 1 and 365 inclusive"));
                } else if (stdTransition.type == PosixTZRule.Type.DayOfYear) {
                    if (stdTransition.dayOfYear > 365)
                        return typeof(return)(MalformedInputException("STD day in year must be between 0 and 365 inclusive"));
                }
            }
        }

        return typeof(return)(PosixTZ(String_UTF8.init, stdName, dstName, stdOffset, dstOffset, stdTransition, dstTransition));
    }
}

struct PosixTZ {
    String_UTF8 loadFromTZifFile;

    String_UTF8 stdName, dstName;
    long stdOffset, dstOffset; // seconds
    PosixTZRule transitionToStd, transitionToDST;

@safe nothrow @nogc:

    this(scope return ref PosixTZ other) scope {
        this.tupleof = other.tupleof;
    }

    bool loadFromFile() {
        return !loadFromTZifFile.isNull;
    }
}

struct PosixTZRule {
    Type type;

    union {
        //JulianDay, no leap day
        ushort julianDay;

        //DayOfYear, supports leap day
        ushort dayOfYear;

        //DayInWeekOfMonth
        struct {
            ubyte monthOfYear;
            ubyte weekOfMonth;
            ubyte dayOfWeek;
        }
    }

    long secondsBias /* = 7200 */ ;

@safe nothrow @nogc:

    this(scope return ref PosixTZRule other) scope {
        this.tupleof = other.tupleof;
    }

    enum Type {
        NoDST,
        JulianDay,
        DayOfYear,
        DayInWeekOfMonth,
    }
}

private:

__gshared {
    String_UTF8 localOlsonName;
    size_t[3] tzFileSize;
}

unittest {
    {
        auto got = parsePosixTZ(String_UTF8("WGT3WGST,M3.5.0/-2,M10.5.0/-1"));
        assert(got);

        assert(got.loadFromTZifFile.isNull);
        assert(got.stdName == "WGT");
        assert(got.dstName == "WGST");
        assert(got.stdOffset == 10800);
        assert(got.dstOffset == 0);

        assert(got.transitionToDST.type == PosixTZRule.Type.DayInWeekOfMonth);
        assert(got.transitionToDST.monthOfYear == 3);
        assert(got.transitionToDST.weekOfMonth == 5);
        assert(got.transitionToDST.dayOfWeek == 0);
        assert(got.transitionToDST.secondsBias == -7200);

        assert(got.transitionToStd.type == PosixTZRule.Type.DayInWeekOfMonth);
        assert(got.transitionToStd.monthOfYear == 10);
        assert(got.transitionToStd.weekOfMonth == 5);
        assert(got.transitionToStd.dayOfWeek == 0);
        assert(got.transitionToStd.secondsBias == -3600);
    }
    {
        auto got = parsePosixTZ(String_UTF8("WART4WARST,J1,J365/25"));
        assert(got);

        assert(got.loadFromTZifFile.isNull);
        assert(got.stdName == "WART");
        assert(got.dstName == "WARST");
        assert(got.stdOffset == 14400);
        assert(got.dstOffset == 0);

        assert(got.transitionToDST.type == PosixTZRule.Type.JulianDay);
        assert(got.transitionToDST.julianDay == 1);
        assert(got.transitionToDST.secondsBias == 7200);

        assert(got.transitionToStd.type == PosixTZRule.Type.JulianDay);
        assert(got.transitionToStd.julianDay == 365);
        assert(got.transitionToStd.secondsBias == 90000);
    }
}
