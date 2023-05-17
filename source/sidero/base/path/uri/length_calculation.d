module sidero.base.path.uri.length_calculation;
import sidero.base.text;

export @safe nothrow @nogc:

///
size_t calculateLengthOfScheme(scope String_UTF8.LiteralType input, bool requireSuffix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfSchemeImpl(temp, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope String_UTF16.LiteralType input, bool requireSuffix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfSchemeImpl(temp, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope String_UTF32.LiteralType input, bool requireSuffix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfSchemeImpl(temp, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope String_ASCII input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope String_UTF8 input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope String_UTF16 input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope String_UTF32 input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope StringBuilder_ASCII input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope StringBuilder_UTF8 input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope StringBuilder_UTF16 input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t calculateLengthOfScheme(scope StringBuilder_UTF32 input, bool requireSuffix = true) {
    return calculateLengthOfSchemeImpl(input, requireSuffix);
}

///
unittest {
    assert(calculateLengthOfScheme("smb://a/b/c.d") == "smb".length);
    assert(calculateLengthOfScheme("smb:/a/b/c.d") == "smb".length);
    assert(calculateLengthOfScheme("s://a/b/c.d") == "s".length);

    assert(calculateLengthOfScheme("abc") == 0);
    assert(calculateLengthOfScheme("ab") == 0);
    assert(calculateLengthOfScheme("a/b/c.d") == 0);

    assert(calculateLengthOfScheme("d:/") == "d".length);
    assert(calculateLengthOfScheme("d://") == "d".length);
    assert(calculateLengthOfScheme("d://a/b.c") == "d".length);
    assert(calculateLengthOfScheme("D://a/b.c") == "D".length);

    assert(calculateLengthOfScheme("a\U00001F30Fz:/") == 0);
}

/// Returns the prefix, length, suffix of user info section
size_t[3] calculateLengthOfUserInfo(scope String_UTF8.LiteralType input, bool requireSuffix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfUserInfoImpl(temp, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope String_UTF16.LiteralType input, bool requireSuffix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfUserInfoImpl(temp, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope String_UTF32.LiteralType input, bool requireSuffix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfUserInfoImpl(temp, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope String_ASCII input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope String_UTF8 input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope String_UTF16 input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope String_UTF32 input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope StringBuilder_ASCII input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope StringBuilder_UTF8 input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope StringBuilder_UTF16 input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input.byUTF32, requireSuffix);
}

/// Ditto
size_t[3] calculateLengthOfUserInfo(scope StringBuilder_UTF32 input, bool requireSuffix = true) {
    return calculateLengthOfUserInfoImpl(input, requireSuffix);
}

///
unittest {
    assert(calculateLengthOfUserInfo("//a%42%43d:a%42%43d@adr") == [2, 17, 1]);
    assert(calculateLengthOfUserInfo("//a%42%43d:a%42%43d", false) == [2, 17, 0]);
    assert(calculateLengthOfUserInfo("a%42%43d:a%42%43d", false) == [0, 17, 0]);
    assert(calculateLengthOfUserInfo("/abc") == [0, 0, 0]);
    assert(calculateLengthOfUserInfo("abc@") == [0, 3, 1]);
    assert(calculateLengthOfUserInfo("abc", false) == [0, 3, 0]);
    assert(calculateLengthOfUserInfo("a\u2606z"d, false) == [0, 3, 0]);
}

///
size_t calculateLengthOfHost(scope String_UTF8.LiteralType input) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfHostImpl(temp);
}

/// Ditto
size_t calculateLengthOfHost(scope String_UTF16.LiteralType input) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfHostImpl(temp);
}

/// Ditto
size_t calculateLengthOfHost(scope String_UTF32.LiteralType input) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfHostImpl(temp);
}

/// Ditto
size_t calculateLengthOfHost(scope String_ASCII input) {
    return calculateLengthOfHostImpl(input);
}

/// Ditto
size_t calculateLengthOfHost(scope String_UTF8 input) {
    return calculateLengthOfHostImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfHost(scope String_UTF16 input) {
    return calculateLengthOfHostImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfHost(scope String_UTF32 input) {
    return calculateLengthOfHostImpl(input);
}

/// Ditto
size_t calculateLengthOfHost(scope StringBuilder_ASCII input) {
    return calculateLengthOfHostImpl(input);
}

/// Ditto
size_t calculateLengthOfHost(scope StringBuilder_UTF8 input) {
    return calculateLengthOfHostImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfHost(scope StringBuilder_UTF16 input) {
    return calculateLengthOfHostImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfHost(scope StringBuilder_UTF32 input) {
    return calculateLengthOfHostImpl(input);
}

///
unittest {
    assert(calculateLengthOfHost("abc") == 3);
    assert(calculateLengthOfHost("123.456.789.000") == 15);
    assert(calculateLengthOfHost("a%42%43d") == 8);
    assert(calculateLengthOfHost("a+c") == 3);
    assert(calculateLengthOfHost("a\u2606z"d) == 3);

    assert(calculateLengthOfHost("[AAAA:BBBB:CCCC:DDDD:EEEE:FFFF:1111:2222]") == 41);
    assert(calculateLengthOfHost("[AAAA:BBBB::FFFF:1111:2222]") == 27);
    assert(calculateLengthOfHost("[::1]") == 5);
    assert(calculateLengthOfHost("[64:ff9b::192.0.2.128]") == 22);
    assert(calculateLengthOfHost("[v1337.BAD:BEEF+458]") == 20);
}

///
size_t[2] calculateLengthOfPort(scope String_UTF8.LiteralType input, bool requirePrefix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfPortImpl(temp, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope String_UTF16.LiteralType input, bool requirePrefix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfPortImpl(temp, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope String_UTF32.LiteralType input, bool requirePrefix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfPortImpl(temp, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope String_ASCII input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope String_UTF8 input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input.byUTF32, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope String_UTF16 input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input.byUTF32, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope String_UTF32 input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope StringBuilder_ASCII input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope StringBuilder_UTF8 input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input.byUTF32, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope StringBuilder_UTF16 input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input.byUTF32, requirePrefix);
}

/// Ditto
size_t[2] calculateLengthOfPort(scope StringBuilder_UTF32 input, bool requirePrefix = true) {
    return calculateLengthOfPortImpl(input, requirePrefix);
}

///
unittest {
    assert(calculateLengthOfPort("1234", false) == [0, 4]);
    assert(calculateLengthOfPort("1234") == [0, 0]);
    assert(calculateLengthOfPort(":1234") == [1, 4]);
    assert(calculateLengthOfPort(":a") == [1, 0]);
    assert(calculateLengthOfPort("a") == [0, 0]);
    assert(calculateLengthOfPort(":a") == [1, 0]);
    assert(calculateLengthOfPort(":359") == [1, 3]);
    assert(calculateLengthOfPort("1\u26062") == [0, 0]);
}

///
size_t[4] calculateLengthOfConnectionInfo(scope String_UTF8.LiteralType input, ptrdiff_t lengthOfScheme = -1) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfConnectionInfoImpl(temp, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope String_UTF16.LiteralType input, ptrdiff_t lengthOfScheme = -1) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfConnectionInfoImpl(temp, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope String_UTF32.LiteralType input, ptrdiff_t lengthOfScheme = -1) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfConnectionInfoImpl(temp, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope String_ASCII input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope String_UTF8 input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input.byUTF32, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope String_UTF16 input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input.byUTF32, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope String_UTF32 input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope StringBuilder_ASCII input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope StringBuilder_UTF8 input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input.byUTF32, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope StringBuilder_UTF16 input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input.byUTF32, lengthOfScheme);
}

/// Ditto
size_t[4] calculateLengthOfConnectionInfo(scope StringBuilder_UTF32 input, ptrdiff_t lengthOfScheme = -1) {
    return calculateLengthOfConnectionInfoImpl(input, lengthOfScheme);
}

///
unittest {
    size_t[4] got;

    got = calculateLengthOfConnectionInfo("urn://abc");
    assert(got == [3, 0, 3, 0]);
    got = calculateLengthOfConnectionInfo("urn:/");
    assert(got == [2, 0, 0, 0]);
    got = calculateLengthOfConnectionInfo("urn:");
    assert(got == [1, 0, 0, 0]);

    got = calculateLengthOfConnectionInfo("urn://abc:1234");
    assert(got == [3, 0, 3, 5]);

    got = calculateLengthOfConnectionInfo("urn://123.456.789.000");
    assert(got == [3, 0, 15, 0]);
    got = calculateLengthOfConnectionInfo("urn://a%42%43d");
    assert(got == [3, 0, 8, 0]);
    got = calculateLengthOfConnectionInfo("urn://a+c");
    assert(got == [3, 0, 3, 0]);

    got = calculateLengthOfConnectionInfo("urn://[AAAA:BBBB:CCCC:DDDD:EEEE:FFFF:1111:2222]");
    assert(got == [3, 0, 41, 0]);
    got = calculateLengthOfConnectionInfo("urn://[AAAA:BBBB::FFFF:1111:2222]");
    assert(got == [3, 0, 27, 0]);
    got = calculateLengthOfConnectionInfo("urn://[::1]");
    assert(got == [3, 0, 5, 0]);
    got = calculateLengthOfConnectionInfo("urn://[64:ff9b::192.0.2.128]");
    assert(got == [3, 0, 22, 0]);
    got = calculateLengthOfConnectionInfo("urn://[v1337.BAD:BEEF+458]");
    assert(got == [3, 0, 20, 0]);

    got = calculateLengthOfConnectionInfo("urn://@abc");
    assert(got == [3, 1, 3, 0]);
    got = calculateLengthOfConnectionInfo("urn://@123.456.789.000");
    assert(got == [3, 1, 15, 0]);
    got = calculateLengthOfConnectionInfo("urn://user@abc");
    assert(got == [3, 5, 3, 0]);
    got = calculateLengthOfConnectionInfo("urn://user@123.456.789.000");
    assert(got == [3, 5, 15, 0]);
    got = calculateLengthOfConnectionInfo("urn://user:pass@abc");
    assert(got == [3, 10, 3, 0]);
    got = calculateLengthOfConnectionInfo("urn://user:pass@123.456.789.000");
    assert(got == [3, 10, 15, 0]);
    got = calculateLengthOfConnectionInfo("urn://a%42%43d:a%42%43d@abc");
    assert(got == [3, 18, 3, 0]);
    got = calculateLengthOfConnectionInfo("urn://a%42%43d:a%42%43d@123.456.789.000");
    assert(got == [3, 18, 15, 0]);
}

///
size_t[2] calculateLengthOfQuery(scope String_UTF8.LiteralType input, bool requireFirstPrefix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfQueryImpl(temp, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope String_UTF16.LiteralType input, bool requireFirstPrefix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfQueryImpl(temp, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope String_UTF32.LiteralType input, bool requireFirstPrefix = true) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfQueryImpl(temp, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope String_ASCII input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope String_UTF8 input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input.byUTF32, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope String_UTF16 input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input.byUTF32, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope String_UTF32 input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope StringBuilder_ASCII input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope StringBuilder_UTF8 input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input.byUTF32, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope StringBuilder_UTF16 input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input.byUTF32, requireFirstPrefix);
}

/// Ditto
size_t[2] calculateLengthOfQuery(scope StringBuilder_UTF32 input, bool requireFirstPrefix = true) {
    return calculateLengthOfQueryImpl(input, requireFirstPrefix);
}

///
unittest {
    assert(calculateLengthOfQuery("?abc=efg") == [0, 8]);
    assert(calculateLengthOfQuery("?abc=efg&bool") == [0, 13]);
    assert(calculateLengthOfQuery("?abc=efg/path/segments") == [0, 22]);
    assert(calculateLengthOfQuery("?abc=efg/path/segments#fragment") == [0, 22]);
    assert(calculateLengthOfQuery("?abc=efg/path/%AA%88segments") == [0, 28]);
    assert(calculateLengthOfQuery("?/path/segments") == [0, 15]);
    assert(calculateLengthOfQuery("/path/segments") == [14, 0]);
    assert(calculateLengthOfQuery("/path/seg%EEme%FFnts") == [20, 0]);

    assert(calculateLengthOfQuery("?abc=efg") == [0, 8]);
    assert(calculateLengthOfQuery("?abc=efg&bool") == [0, 13]);
    assert(calculateLengthOfQuery("?abc=efg/path/segments") == [0, 22]);
    assert(calculateLengthOfQuery("?/path/segments") == [0, 15]);
    assert(calculateLengthOfQuery("/path/segments") == [14, 0]);
    assert(calculateLengthOfQuery("/") == [1, 0]);

    assert(calculateLengthOfQuery("/a\u2606z?eg=\u2607"d) == [4, 5]);
}

///
size_t calculateLengthOfFragment(scope String_UTF8.LiteralType input) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfFragmentImpl(temp);
}

/// Ditto
size_t calculateLengthOfFragment(scope String_UTF16.LiteralType input) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfFragmentImpl(temp);
}

/// Ditto
size_t calculateLengthOfFragment(scope String_UTF32.LiteralType input) {
    scope String_UTF32 temp;
    temp.__ctor(input);
    return calculateLengthOfFragmentImpl(temp);
}

/// Ditto
size_t calculateLengthOfFragment(scope String_ASCII input) {
    return calculateLengthOfFragmentImpl(input);
}

/// Ditto
size_t calculateLengthOfFragment(scope String_UTF8 input) {
    return calculateLengthOfFragmentImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfFragment(scope String_UTF16 input) {
    return calculateLengthOfFragmentImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfFragment(scope String_UTF32 input) {
    return calculateLengthOfFragmentImpl(input);
}

/// Ditto
size_t calculateLengthOfFragment(scope StringBuilder_ASCII input) {
    return calculateLengthOfFragmentImpl(input);
}

/// Ditto
size_t calculateLengthOfFragment(scope StringBuilder_UTF8 input) {
    return calculateLengthOfFragmentImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfFragment(scope StringBuilder_UTF16 input) {
    return calculateLengthOfFragmentImpl(input.byUTF32);
}

/// Ditto
size_t calculateLengthOfFragment(scope StringBuilder_UTF32 input) {
    return calculateLengthOfFragmentImpl(input);
}

///
unittest {
    assert(calculateLengthOfFragment("whatever") == 0);
    assert(calculateLengthOfFragment("#") == 1);
    assert(calculateLengthOfFragment("#foobar") == 7);
    assert(calculateLengthOfFragment("#foo%AA%BBbar") == 13);
    assert(calculateLengthOfFragment("#foobar/thing") == 13);
    assert(calculateLengthOfFragment("#foobar?thing") == 13);
    assert(calculateLengthOfFragment("foobar/thing") == 0);
    assert(calculateLengthOfFragment("#fo\u2606bar"d) == 7);
}

private:

size_t calculateLengthOfSchemeImpl(Input)(scope Input input, bool requireSuffix = true) @trusted {
    import sidero.base.text.ascii.characters : isAlpha, isAlphaNumeric, isNumeric;

    input = input[];

    bool checkIfAlpha(C)(C input) {
        return input <= 128 && isAlpha(cast(ubyte)input);
    }

    bool checkIfAlphaNum(C)(C input) {
        return input <= 128 && isAlphaNumeric(cast(ubyte)input);
    }

    // check for initial ALPHA
    // scheme        = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
    if (input.empty || !checkIfAlpha(input.front))
        return 0;
    const lengthAtStart = input.length;
    input.popFront;

    // sum *( ALPHA / DIGIT / "+" / "-" / "." )
    bool foundSuffix;
    size_t lengthBeforeEnd = input.length;

    while (!input.empty) {
        auto c = input.front;

        if (checkIfAlphaNum(c) || c == '+' || c == '-' || c == '.') {
            input.popFront;
            continue;
        } else if (requireSuffix && c == ':')
            foundSuffix = true;
        lengthBeforeEnd = input.length;
        break;
    }

    // if scheme doesn't end with a ':' its not a URI
    // URI           = scheme ":" hier-part [ "?" query ] [ "#" fragment ]

    if (requireSuffix && !foundSuffix) {
        // oh no didn't find the suffix and we need it
        return 0;
    }

    return lengthAtStart - lengthBeforeEnd;
}

size_t[3] calculateLengthOfUserInfoImpl(Input)(scope Input input, bool requireSuffix = true) @trusted {
    import sidero.base.text.ascii.characters : isAlphaNumeric, isNumeric;

    input = input[];

    bool checkIfAlphaNum(C)(C input) {
        return input <= 128 && isAlphaNumeric(cast(ubyte)input);
    }

    bool checkIfNum(C)(C input) {
        return input <= 128 && isNumeric(cast(ubyte)input);
    }

    size_t prefix, length, suffix, suffixAt;

    if (input.startsWith("//")) {
        input = input[2 .. $];
        prefix = 2;
    } else if (input.startsWith("/"))
        return typeof(return).init;

    // userinfo      = *( unreserved / pct-encoded / sub-delims / ":" )

    {
        ptrdiff_t atOffset = input.indexOf("@");

        if (atOffset >= 0) {
            input = input[0 .. atOffset];
            suffix = 1;
            suffixAt = prefix + atOffset;
        }
    }

    if (requireSuffix && suffix == 0)
        return typeof(return).init;

    {
        int inHex;

        Loop: while (!input.empty) {
            const c = input.front;
            const priorLength = input.length;

            if (inHex > 0) {
                // pct-encoded
                if (checkIfNum(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                    inHex++;

                    if (inHex == 3)
                        inHex = 0;
                } else
                    break Loop;
            } else {
                switch (c) {
                case '!':
                case '$':
                case '&': .. case '.':
                case '_':
                case '~':
                case ':':
                case ';':
                case '=':
                    break;
                case '%':
                    // pct-encoded
                    if (inHex > 0)
                        break Loop;
                    inHex = 1;
                    break;
                default:
                    if (checkIfAlphaNum(c) || c >= 128)
                        break;
                    break Loop;
                }
            }

            input.popFront;
            length += priorLength - input.length;
        }

        if (suffix > 0 && !input.empty)
            return typeof(return).init;
    }

    if (suffix > 0 && suffixAt != prefix + length)
        return typeof(return).init;

    return [prefix, length, suffix];
}

size_t calculateLengthOfHostImpl(Input)(scope Input input) @trusted {
    import sidero.base.text.ascii.characters : isAlpha, isAlphaNumeric, isNumeric;

    input = input[];

    size_t length;
    bool doIPV4, wasIPV6;
    // host          = IP-literal / IPv4address / reg-name

    bool checkIfAlpha(C)(C input) {
        return input <= 128 && isAlpha(cast(ubyte)input);
    }

    bool checkIfAlphaNum(C)(C input) {
        return input <= 128 && isAlphaNumeric(cast(ubyte)input);
    }

    bool checkIfNum(C)(C input) {
        return input <= 128 && isNumeric(cast(ubyte)input);
    }

    if (input.startsWith("[")) {
        // IP-literal    = "[" ( IPv6address / IPvFuture  ) "]"

        ptrdiff_t possibleLengthOfHost = input.indexOf("]");

        // "[" ((v 1*HEXDIG) / (h16 ":"))
        if (possibleLengthOfHost < 0)
            return 0;
        Input ipLiteral = input[1 .. possibleLengthOfHost];

        if (ipLiteral.startsWith("v")) {
            // IPvFuture     = "v" 1*HEXDIG "." 1*( unreserved / sub-delims / ":" )

            ipLiteral = ipLiteral[1 .. $];
            if (ipLiteral.empty)
                return 0;

            bool gotDot;
            foreach (c; ipLiteral) {
                if (gotDot) {
                    // 1*( unreserved / sub-delims / ":" )

                    switch (c) {
                    case '!':
                    case '$':
                    case '&': .. case '.':
                    case ':':
                    case ';':
                    case '=':
                    case '_':
                    case '~':
                        break;
                    default:
                        if (checkIfAlphaNum(c) || c >= 128)
                            break;
                        return 0;
                    }
                } else if (c == '.') {
                    gotDot = true;
                } else if (checkIfNum(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                    // 1*HEXDIG
                } else
                    return 0;
            }

            if (!gotDot) {
                return 0;
            }

            length = possibleLengthOfHost + 1;
        } else {
            /*
                IPv6address   =                   6( h16 ":" ) ls32
                     /                       "::" 5( h16 ":" ) ls32
                     / [               h16 ] "::" 4( h16 ":" ) ls32
                     / [ *1( h16 ":" ) h16 ] "::" 3( h16 ":" ) ls32
                     / [ *2( h16 ":" ) h16 ] "::" 2( h16 ":" ) ls32
                     / [ *3( h16 ":" ) h16 ] "::"    h16 ":"   ls32
                     / [ *4( h16 ":" ) h16 ] "::"              ls32
                     / [ *5( h16 ":" ) h16 ] "::"              h16
                     / [ *6( h16 ":" ) h16 ] "::"

                h16           = 1*4HEXDIG
                ls32          = ( h16 ":" h16 ) / IPv4address
                */

            if (ipLiteral.empty)
                return 0;

            length = 1;
            uint inHexDigits;

            const startingLength = ipLiteral.length;
            ptrdiff_t colonColonOffset = ipLiteral.indexOf("::");
            size_t leftHexCount, rightHexCount;
            bool postColonColon;

            foreach (c; ipLiteral) {
                if (postColonColon) {
                    if (leftHexCount > 8)
                        return 0;

                    /*
                          6( h16 ":" ) ls32
                        / 5( h16 ":" ) ls32
                        / 4( h16 ":" ) ls32
                        / 3( h16 ":" ) ls32
                        / 2( h16 ":" ) ls32
                        / 1( h16 ":" ) ls32
                        /              ls32
                        /              h16
                        */

                    if (c == ':')
                        inHexDigits = 0;
                    else if (checkIfNum(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                        if (inHexDigits == 4 || rightHexCount == 8)
                            return 0;

                        if (inHexDigits == 0)
                            rightHexCount++;
                        inHexDigits++;
                    } else {
                        doIPV4 = true;
                        wasIPV6 = true;

                        length -= inHexDigits + 1;
                        break;
                    }
                } else if (colonColonOffset >= 0 && startingLength - ipLiteral.length > colonColonOffset) {
                    if (leftHexCount > 8)
                        return 0;

                    postColonColon = startingLength - ipLiteral.length >= (colonColonOffset + 2);
                    inHexDigits = 0;
                } else {
                    /*
                         / [               h16 ]
                         / [ *1( h16 ":" ) h16 ]
                         / [ *2( h16 ":" ) h16 ]
                         / [ *3( h16 ":" ) h16 ]
                         / [ *4( h16 ":" ) h16 ]
                         / [ *5( h16 ":" ) h16 ]
                         / [ *6( h16 ":" ) h16 ]
                        */

                    if (c == ':')
                        inHexDigits = 0;
                    else if (checkIfNum(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                        if (inHexDigits == 4)
                            return 0;

                        if (inHexDigits == 0)
                            leftHexCount++;
                        inHexDigits++;
                    } else
                        return 0;
                }

                length++;
            }

            if (!doIPV4)
                length++;
        }
    } else {
        doIPV4 = true;
    }

    if (doIPV4) {
        // IPv4address   = dec-octet "." dec-octet "." dec-octet "." dec-octet

        if (wasIPV6) {
            // unfortunately we do care about the ipv4 exactness, so we'll do a seperate parse.

            /*
                dec-octet     = DIGIT                 ; 0-9
                 / %x31-39 DIGIT         ; 10-99
                 / "1" 2DIGIT            ; 100-199
                 / "2" %x30-34 DIGIT     ; 200-249
                 / "25" %x30-35          ; 250-255
                */

            int inOctets, inDecOctet, octetValue;

            foreach (c; input[length .. $]) {
                if (c == '.') {
                    inDecOctet = 0;
                    inOctets++;
                    octetValue = 0;
                    length++;
                } else if (c == ']')
                    break;

                if (inOctets == 5)
                    break;

                if (c != '.') {
                    if (inDecOctet > 2 || c < '0' || c > '9')
                        break;

                    octetValue *= 10;
                    octetValue += c - '0';

                    length++;
                    inDecOctet++;

                    if (inDecOctet == 3 && octetValue > 255)
                        break;
                }
            }

            if (input.length < length + 1 || !input[length .. $].startsWith("]"))
                return 0;

            length++;
        } else {
            // reg-name      = *( unreserved / pct-encoded / sub-delims )
            // IPv4address is a subset of reg-name so we won't bother to validate that.
            //  since we don't need that information here.

            if (input.startsWith(".")) {
                // yeahhhhh so certainly not a host name and certainly not an ipv4 address
            } else {
                int inHex;
                Loop: foreach (c; input) {
                    if (c == ':' || c == '/')
                        break;

                    if (inHex > 0) {
                        // pct-encoded
                        if (checkIfNum(c) || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                            inHex++;

                            if (inHex == 3)
                                inHex = 0;
                        } else
                            break;
                    } else {
                        switch (c) {
                        case '!':
                        case '$':
                        case '&': .. case '.':
                        case ';':
                        case '=':
                        case '_':
                        case '~':
                            break;

                        case '%':
                            // pct-encoded
                            if (inHex > 0)
                                return 0;
                            inHex = 1;
                            break;

                        default:
                            if (checkIfAlphaNum(c) || c>= 128)
                                break;
                            break Loop;
                        }
                    }
                    length++;
                }
            }
        }
    }

    return length;
}

size_t[2] calculateLengthOfPortImpl(Input)(scope Input input, bool requirePrefix = true) @trusted {
    import sidero.base.text.ascii.characters : isNumeric;

    size_t prefix, length;

    // port          = *DIGIT

    if (requirePrefix) {
        if (input.startsWith(":")) {
            prefix = 1;
            input = input[1 .. $];
        } else
            return typeof(return).init;
    }

    foreach (c; input) {
        if (c < 128 && isNumeric(cast(ubyte)c)) {
            length++;
        } else
            break;
    }

    return [prefix, length];
}

size_t[4] calculateLengthOfConnectionInfoImpl(Input)(scope Input input, ptrdiff_t lengthOfScheme = -1) @trusted {
    input = input[];

    /*
 hier-part   = "//" authority path-abempty
  / path-absolute
  / path-rootless
  / path-empty
    */

    size_t lengthOfPrefix, lengthOfUser, lengthOfHost, lengthOfPort;

    if (lengthOfScheme < 0)
        lengthOfScheme = calculateLengthOfSchemeImpl(input);

    if (lengthOfScheme > 0) {
        input = input[lengthOfScheme + 1 .. $];
        lengthOfPrefix = 1;
    }

    if (input.startsWith("/") && !input.startsWith("//")) {
        lengthOfPrefix += 1;
        /*
  / path-absolute
  / path-rootless
  / path-empty
        */
    } else {
        bool haveSlashSlash;

        if (input.startsWith("//")) {
            lengthOfPrefix += 2;
            haveSlashSlash = true;
        }

        // "//" authority path-abempty
        // authority   = [ userinfo "@" ] host [ ":" port ]

        {
            size_t[3] userLengths = calculateLengthOfUserInfoImpl(input);

            if (userLengths[2] > 0)
                lengthOfUser = userLengths[1] + userLengths[2];
        }

        if (haveSlashSlash)
            input = input[2 + lengthOfUser .. $];
        else if (lengthOfUser > 0)
            input = input[lengthOfUser .. $];

        if (lengthOfScheme == 0 || haveSlashSlash || lengthOfUser > 0) {
            lengthOfHost = calculateLengthOfHostImpl(input);
            input = input[lengthOfHost .. $];
        }

        {
            size_t[2] portLengths = calculateLengthOfPortImpl(input);
            lengthOfPort = portLengths[0] + portLengths[1];

            if (lengthOfHost == 1 && lengthOfPort == 1) {
                lengthOfHost = 0;
                lengthOfPort = 0;
            }
        }
    }

    return [lengthOfPrefix, lengthOfUser, lengthOfHost, lengthOfPort];
}

size_t[2] calculateLengthOfQueryImpl(Input)(scope Input input, bool requireFirstPrefix = true) @trusted {
    import sidero.base.text.ascii.characters : isAlphaNumeric;

    input = input[];

    size_t lengthOfSegments, lengthOfQuery;
    bool gotQuery;

    bool checkIfAlphaNum(C)(C input) {
        return input <= 128 && isAlphaNumeric(cast(ubyte)input);
    }

    // URI           = scheme ":" hier-part [ "?" query ] [ "#" fragment ]

    {
        // query         = *( pchar / "/" / "?" )
        // pchar = unreserved / pct-encoded / sub-delims / ":" / "@"

        if (requireFirstPrefix && !(input.startsWith("/") || input.startsWith("?"))) {
            // oh noes
            return typeof(return).init;
        }

        int inHex;

        Loop: foreach (c; input) {
            if (inHex > 0) {
                // pct-encoded
                if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                    inHex++;

                    if (inHex == 3)
                        inHex = 0;
                } else
                    break;
            } else {
                switch (c) {
                case '!':
                case '$':
                case '&': .. case '/':
                case ':':
                case ';':
                case '=':
                case '@':
                case '_':
                case '~':
                    break;

                case '%':
                    // pct-encoded
                    if (inHex > 0)
                        break Loop;
                    inHex = 1;
                    break;

                case '?':
                    gotQuery = true;
                    break;

                default:
                    if (checkIfAlphaNum(c) || c >= 128)
                        break;
                    break Loop;
                }
            }

            if (gotQuery)
                lengthOfQuery++;
            else
                lengthOfSegments++;
        }
    }

    return [lengthOfSegments, lengthOfQuery];
}

size_t calculateLengthOfFragmentImpl(Input)(scope Input input) {
    import sidero.base.text.ascii.characters : isAlphaNumeric;

    bool checkIfAlphaNum(C)(C input) {
        return input <= 128 && isAlphaNumeric(cast(ubyte)input);
    }

    if (input.startsWith("#")) {
        // fragment      = *( pchar / "/" / "?" )
        // pchar = unreserved / pct-encoded / sub-delims / ":" / "@"

        size_t length = 1;
        int inHex;

        Loop: foreach (c; input[1 .. $]) {
            if (inHex > 0) {
                // pct-encoded
                if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
                    inHex++;

                    if (inHex == 3)
                        inHex = 0;
                } else
                    break;
            } else {
                switch (c) {
                case '!':
                case '$':
                case '&': .. case '/':
                case ':':
                case ';':
                case '=':
                case '?':
                case '@':
                case '_':
                case '~':
                    break;

                case '%':
                    // pct-encoded
                    if (inHex > 0)
                        break Loop;
                    inHex = 1;
                    break;

                default:
                    if (checkIfAlphaNum(c) || c >= 128)
                        break;
                    break Loop;
                }
            }

            length++;
        }

        return length;
    } else
        return 0;
}
