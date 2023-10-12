module sidero.base.datetime.formats;
import sidero.base.datetime.calendars.gregorian;
import sidero.base.datetime.time.timeofday;
import sidero.base.datetime.time.timezone;
import sidero.base.datetime.defs;
import sidero.base.text;
import sidero.base.errors;

export @safe nothrow @nogc:

/// https://datatracker.ietf.org/doc/html/rfc5280
Result!(DateTime!GregorianDate) parseRFC5280(scope String_UTF8.LiteralType input) @trusted {
    scope temp = String_UTF8(input);
    return parseRFC5280Impl(temp);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope String_UTF16.LiteralType input) @trusted {
    scope temp = String_UTF16(input);
    return parseRFC5280Impl(temp);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope String_UTF32.LiteralType input) @trusted {
    scope temp = String_UTF32(input);
    return parseRFC5280Impl(temp);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope String_UTF8 input) {
    return parseRFC5280Impl(input);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope String_UTF16 input) {
    return parseRFC5280Impl(input);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope String_UTF32 input) {
    return parseRFC5280Impl(input);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope StringBuilder_UTF8 input) {
    return parseRFC5280Impl(input);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope StringBuilder_UTF16 input) {
    return parseRFC5280Impl(input);
}

/// Ditto
Result!(DateTime!GregorianDate) parseRFC5280(scope StringBuilder_UTF32 input) {
    return parseRFC5280Impl(input);
}

///
unittest {
    auto got = parseRFC5280("231011100426Z");
    assert(got);

    assert(got.year == 2023);
    assert(got.month == 10);
    assert(got.day == 11);
    assert(got.hour == 10);
    assert(got.minute == 4);
    assert(got.second == 26);
    assert(got.nanoSecond == 0);
}

///
unittest {
    auto got = parseRFC5280("501011100426Z");
    assert(got);

    assert(got.year == 1950);
    assert(got.month == 10);
    assert(got.day == 11);
    assert(got.hour == 10);
    assert(got.minute == 4);
    assert(got.second == 26);
    assert(got.nanoSecond == 0);
}

///
unittest {
    auto got = parseRFC5280("20231011100426Z");
    assert(got);

    assert(got.year == 2023);
    assert(got.month == 10);
    assert(got.day == 11);
    assert(got.hour == 10);
    assert(got.minute == 4);
    assert(got.second == 26);
    assert(got.nanoSecond == 0);
}

private:

///
Result!(DateTime!GregorianDate) parseRFC5280Impl(Str)(scope Str input) {
    if(input.length < "YYMMDDHHMMSSZ".length)
        return typeof(return)(MalformedInputException("Too short for RFC5280 UTCTime"));

    ushort year;
    ubyte month, day, hour, minute, second;

    if(input.length < "YYYYMMDDHHMMSSZ".length) {
        // UTCTime
        if(input[12] != "Z")
            return typeof(return)(MalformedInputException("RFC5280 UTCTime does not have Z at expected location"));

        // >= 50 = 19YY
        // < 50 = 20YY

        auto err = formattedRead(input, "{:.2d}{:.2d}{:.2d}{:.2d}{:.2d}{:.2d}Z", year, month, day, hour, minute, second);
        if(!err)
            return typeof(return)(MalformedInputException("RFC5280 UTCTime did not get all components"));

        if(year >= 50)
            year += 1900;
        else
            year += 2000;
    } else {
        // GeneralizedTime
        if(input[14] != "Z")
            return typeof(return)(MalformedInputException("RFC5280 GeneralizedTime does not have Z at expected location"));

        auto err = formattedRead(input, "{:.4d}{:.2d}{:.2d}{:.2d}{:.2d}{:.2d}Z", year, month, day, hour, minute, second);
        if(!err)
            return typeof(return)(MalformedInputException("RFC5280 GeneralizedTime did not get all components"));
    }

    return typeof(return)(DateTime!GregorianDate(GregorianDate(year, month, day), TimeOfDay(hour, minute,
    second), TimeZone.from(0)));
}
