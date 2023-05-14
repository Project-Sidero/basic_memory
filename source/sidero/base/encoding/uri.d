module sidero.base.encoding.uri;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.allocators;

///
struct URIEncoding(alias NeedsEncoding) {
export @safe nothrow @nogc static:

    ///
    StringBuilder_ASCII encode(scope String_UTF8.LiteralType input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);

        scope String_UTF32 temp;
        temp.__ctor(input);
        encodeImpl(output, temp);

        return output;
    }

    ///
    StringBuilder_ASCII encode(scope String_UTF16.LiteralType input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);

        scope String_UTF32 temp;
        temp.__ctor(input);
        encodeImpl(output, temp);

        return output;
    }

    ///
    StringBuilder_ASCII encode(scope String_UTF32.LiteralType input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope String_ASCII input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope String_UTF8 input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input.byUTF32);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope String_UTF16 input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input.byUTF32);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope String_UTF32 input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope StringBuilder_ASCII input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope StringBuilder_UTF8 input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input.byUTF32);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope StringBuilder_UTF16 input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input.byUTF32);
        return output;
    }

    ///
    StringBuilder_ASCII encode(scope StringBuilder_UTF32 input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_ASCII output = StringBuilder_ASCII(allocator);
        encodeImpl(output, input);
        return output;
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_UTF8.LiteralType input) {
        if (output.isNull)
            return;

        scope String_UTF32 temp;
        temp.__ctor(input);
        encodeImpl(output, temp);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_UTF16.LiteralType input) {
        if (output.isNull)
            return;

        scope String_UTF32 temp;
        temp.__ctor(input);
        encodeImpl(output, temp);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_UTF32.LiteralType input) {
        if (output.isNull)
            return;

        encodeImpl(output, input);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_ASCII input) {
        if (output.isNull)
            return;

        encodeImpl(output, input);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_UTF8 input) {
        if (output.isNull)
            return;

        encodeImpl(output, input.byUTF32);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_UTF16 input) {
        if (output.isNull)
            return;

        encodeImpl(output, input.byUTF32);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope String_UTF32 input) {
        if (output.isNull)
            return;

        encodeImpl(output, input);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope StringBuilder_ASCII input) {
        if (output.isNull)
            return;

        encodeImpl(output, input);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF8 input) {
        if (output.isNull)
            return;

        encodeImpl(output, input.byUTF32);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF16 input) {
        if (output.isNull)
            return;

        encodeImpl(output, input.byUTF32);
    }

    ///
    void encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF32 input) {
        if (output.isNull)
            return;

        encodeImpl(output, input);
    }

    ///
    Result!StringBuilder_UTF8 decode(scope String_ASCII input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_UTF8 output = StringBuilder_UTF8(allocator);
        auto got = decodeImpl(output, input);

        if (!got)
            return typeof(return)(got.getError);
        return typeof(return)(output);
    }

    ///
    Result!StringBuilder_UTF8 decode(scope StringBuilder_ASCII input, scope return RCAllocator allocator = RCAllocator.init) @trusted {
        StringBuilder_UTF8 output = StringBuilder_UTF8(allocator);
        auto got = decodeImpl(output, input);

        if (!got)
            return typeof(return)(got.getError);
        return typeof(return)(output);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF8 output, scope String_ASCII input) {
        if (output.isNull)
            return ErrorResult(NullPointerException);

        return decodeImpl(output, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF16 output, scope String_ASCII input) {
        if (output.isNull)
            return ErrorResult(NullPointerException);

        return decodeImpl(output.byUTF8, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF32 output, scope String_ASCII input) {
        if (output.isNull)
            return ErrorResult(NullPointerException);

        return decodeImpl(output.byUTF8, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF8 output, scope StringBuilder_ASCII input) {
        if (output.isNull)
            return ErrorResult(NullPointerException);

        return decodeImpl(output, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF16 output, scope StringBuilder_ASCII input) {
        if (output.isNull)
            return ErrorResult(NullPointerException);

        return decodeImpl(output.byUTF8, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF32 output, scope StringBuilder_ASCII input) {
        if (output.isNull)
            return ErrorResult(NullPointerException);

        return decodeImpl(output.byUTF8, input);
    }

private:
    void encodeImpl(Input)(scope StringBuilder_ASCII output, scope Input input) {
        import sidero.base.text.ascii.characters : isGraphical;
        import sidero.base.encoding.utf : encodeUTF8;

        foreach (c; input) {
            const needEncoding = c >= 128 || !isGraphical(cast(ubyte)c) || NeedsEncoding(c);

            if (!needEncoding) {
                output ~= [cast(ubyte)c];
            } else {
                char[4] buffer;
                const amountEncoded = encodeUTF8(cast(dchar)c, buffer);

                foreach (v; buffer[0 .. amountEncoded]) {
                    // %pct-encode
                    output ~= "%";

                    version (none) {
                        auto temp1 = v, temp2 = v;
                        temp1 >>= 4;
                        temp1 &= 0xF;
                        temp2 &= 0xF;

                        typeof(temp1)[4] temp3 = ['0', '7', '0', '7'];
                        temp3[0 .. 2] += temp1;
                        temp3[2 .. 4] += temp2;

                        output ~= temp3[0 + cast(size_t)(temp1 > 9)];
                        output ~= temp3[2 + cast(size_t)(temp1 > 9)];
                    } else {
                        // this is the naive approach to this, shouldn't this be significantly slower?
                        // turns out NOPE, literally every compiler can optimize this better that the other version.

                        auto temp = (v >> 4) & 0xF;
                        output ~= [cast(char)(temp > 9 ? ('A' - 10 + temp) : ('0' + temp))];

                        temp = v & 0xF;
                        output ~= [cast(char)(temp > 9 ? ('A' - 10 + temp) : ('0' + temp))];
                    }
                }
            }
        }
    }

    ErrorResult decodeImpl(Input)(scope StringBuilder_UTF8 output, scope Input input) @trusted {
        import sidero.base.encoding.utf : decodeLength, decode, encodeUTF8;

        input = input[];

        Result!char decodeHex(ubyte[2] input) {
            ubyte ret;

            ubyte temp = cast(ubyte)input[0];
            if (temp >= '0' && temp <= '9')
                ret = cast(ubyte)(temp - '0');
            else if (temp >= 'A' && temp <= 'F')
                ret = cast(ubyte)((temp - 'A') + 10);
            else if (temp >= 'a' && temp <= 'f')
                ret = cast(ubyte)((temp - 'a') + 10);
            else
                return typeof(return)(MalformedInputException("Hex string in percentage encoding out of range"));

            ret <<= 4;

            temp = cast(ubyte)input[1];
            if (temp >= '0' && temp <= '9')
                ret |= cast(ubyte)(temp - '0');
            else if (temp >= 'A' && temp <= 'F')
                ret |= cast(ubyte)((temp - 'A') + 10);
            else if (temp >= 'a' && temp <= 'f')
                ret |= cast(ubyte)((temp - 'a') + 10);
            else
                return typeof(return)(MalformedInputException("Hex string in percentage encoding out of range"));

            return typeof(return)(cast(char)ret);
        }

        while (!input.empty) {
            ubyte triggerC = input.front;
            input.popFront;

            if (triggerC != '%') {
                // all good, copy straight
                output ~= [cast(char)triggerC];
            } else {
                // okay %pct-encode
                ubyte[8] encodedBuffer;
                char[4] decodeBuffer;

                {
                    if (input.empty)
                        return ErrorResult(MalformedInputException("Not enough bytes in percentage encoding of URI"));
                    encodedBuffer[0] = input.front;
                    input.popFront;

                    if (input.empty)
                        return ErrorResult(MalformedInputException("Not enough bytes in percentage encoding of URI"));
                    encodedBuffer[1] = input.front;
                    input.popFront;

                    auto got = decodeHex(encodedBuffer[0 .. 2]);
                    if (!got)
                        return ErrorResult(got.getError());
                    decodeBuffer[0] = got.get;
                }

                const numberNeeded = decodeLength(decodeBuffer[0]);

                foreach (outputOffset; 1 .. numberNeeded) {
                    if (input.empty)
                        return ErrorResult(MalformedInputException("Not enough bytes in percentage encoding of URI"));
                    else if (input.front != '%')
                        return ErrorResult(MalformedInputException("Percentage encoding is not UTF-8, not enough values"));
                    input.popFront;

                    if (input.empty)
                        return ErrorResult(MalformedInputException("Not enough bytes in percentage encoding of URI"));
                    encodedBuffer[outputOffset * 2] = input.front;
                    input.popFront;

                    if (input.empty)
                        return ErrorResult(MalformedInputException("Not enough bytes in percentage encoding of URI"));
                    encodedBuffer[(outputOffset * 2) + 1] = input.front;
                    input.popFront;

                    auto got = decodeHex(encodedBuffer[0 .. 2]);
                    if (!got)
                        return ErrorResult(got.getError());
                    decodeBuffer[outputOffset] = got.get;
                }

                {
                    dchar decoded;
                    const amountDecoded = decode(decodeBuffer[0 .. numberNeeded], decoded, false);
                    if (amountDecoded != numberNeeded)
                        return ErrorResult(MalformedInputException("Percentage encoding is not UTF-8"));

                    char[4] encodeAsBuffer;
                    const amount = encodeUTF8(decoded, encodeAsBuffer);

                    output ~= encodeAsBuffer[0 .. amount];
                }
            }
        }

        return ErrorResult.init;
    }
}

///
alias URIUserInfoEncoding = URIEncoding!((c) {
    switch (c) {
    case '!':
    case '$':
    case '&': .. case '.':
    case '0': .. case ';':
    case '=':
    case 'A': .. case 'Z':
    case '_':
    case 'a': .. case 'z':
    case '~':
        return false;
    default:
        return true;
    }
});

///
unittest {
    assert(URIUserInfoEncoding.encode(
            "\0\t\v\f\b\a\r\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~") == "%00%09%0B%0C%08%07%0D%0A%20!%22%23$%25&'()*+,-.%2F0123456789:;%3C=%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~");

    auto got = URIUserInfoEncoding.decode(String_ASCII("%00%09%0B%0C%08%07%0D%0A%20!%22%23$%25&'()*+,-.%2F0123456789:;%3C=%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~"));
    assert(got);
    assert(got.get == "\0\t\v\f\b\a\r\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
}

///
alias URIHostEncoding = URIEncoding!((c) {
    switch (c) {
    case '!':
    case '$':
    case '&': .. case '.':
    case '0': .. case '9':
    case ';':
    case '=':
    case 'A': .. case 'Z':
    case '_':
    case 'a': .. case 'z':
    case '~':
        return false;
    default:
        return true;
    }
});

///
unittest {
    assert(URIHostEncoding.encode(
            "\0\t\v\f\b\a\r\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~") == "%00%09%0B%0C%08%07%0D%0A%20!%22%23$%25&'()*+,-.%2F0123456789%3A;%3C=%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~");

    auto got = URIHostEncoding.decode(String_ASCII("%00%09%0B%0C%08%07%0D%0A%20!%22%23$%25&'()*+,-.%2F0123456789%3A;%3C=%3E%3F%40ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~"));
    assert(got);
    assert(got.get == "\0\t\v\f\b\a\r\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
}

///
alias URIQueryFragmentEncoding = URIEncoding!((c) {
    switch (c) {
    case '!':
    case '$':
    case '&': .. case ';':
    case '=':
    case '?': .. case 'Z':
    case '_':
    case 'a': .. case 'z':
    case '~':
        return false;
    default:
        return true;
    }
});

///
unittest {
    assert(URIQueryFragmentEncoding.encode(
            "\0\t\v\f\b\a\r\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~") == "%00%09%0B%0C%08%07%0D%0A%20!%22%23$%25&'()*+,-./0123456789:;%3C=%3E?@ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~");

    auto got = URIQueryFragmentEncoding.decode(String_ASCII("%00%09%0B%0C%08%07%0D%0A%20!%22%23$%25&'()*+,-./0123456789:;%3C=%3E?@ABCDEFGHIJKLMNOPQRSTUVWXYZ%5B%5C%5D%5E_%60abcdefghijklmnopqrstuvwxyz%7B%7C%7D~"));
    assert(got);
    assert(got.get == "\0\t\v\f\b\a\r\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
}
