/**
UTF-8 encoding: https://datatracker.ietf.org/doc/html/rfc3629
UTF-16 encoding: https://datatracker.ietf.org/doc/html/rfc2781
 */
module sidero.base.encoding.utf;
import sidero.base.text.unicode.characters.defs;
import std.traits : isSomeString;

///
alias ForeachOverUTF32HandleDelegate = int delegate(ref dchar) @safe nothrow @nogc;
///
alias ForeachOverUTF32Delegate = int delegate(scope ForeachOverUTF32HandleDelegate) @safe nothrow @nogc;

///
ForeachOverUTF!Type foreachOverUTF(Type)(scope return Type arg) {
    return typeof(return)(arg);
}

///
struct ForeachOverUTF(Type) if (isSomeString!Type) {
    ///
    Type value;

    @disable this(this);

@safe nothrow @nogc:

    ///
    void delegate(size_t amountRead, size_t lastIteratedAmount) peekAtReadAmountDelegate;

    ///
    int opApply(scope ForeachOverUTF32HandleDelegate del) scope {
        Type temp = value;
        int result;

        size_t lastIteratedAmount, amountRead;

        while (temp.length > 0 && result == 0) {
            size_t consumed;
            dchar got;

            static if (typeof(temp[0]).sizeof == dchar.sizeof) {
                got = temp[0];
                consumed = 1;
            } else {
                consumed = decode(temp, got);
            }

            amountRead += consumed;
            lastIteratedAmount = consumed;

            result = del(got);
            temp = temp[consumed .. $];
        }

        if (peekAtReadAmountDelegate !is null)
            peekAtReadAmountDelegate(amountRead, lastIteratedAmount);

        return result;
    }
}

/// Supports UTF-8 and UTF-16
void decode(T, U)(scope U refillDelegate, scope T handleDelegate) if (is(T == delegate) && is(U == delegate)) {
    auto input = refillDelegate();
    dchar temp;

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    enum codePointUnits = isUTF8 ? 4 : 2;

    while (input.length > 0) {
        if (input.length < codePointUnits) {
            typeof(cast()input[0])[8] buffer;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refillDelegate();

            size_t toCopy = 8 - inBuffer;
            if (toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while (inBuffer > 0) {
                size_t consumed = decode(tempInput, temp);
                if (consumed > 0)
                    handleDelegate(temp);

                if (consumed >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumed .. $];
                } else
                    inBuffer -= consumed;

                tempInput = tempInput[consumed .. $];
            }
        } else {
            size_t consumed = decode(input, temp);
            if (consumed > 0)
                handleDelegate(temp);
            input = input[consumed .. $];
        }

        if (input.length == 0)
            input = refillDelegate();
    }
}

///
unittest {
    string[] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    wstring[] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    foreach (entry; 0 .. inputs8.length) {
        string input = inputs8[entry];
        dstring output = outputs[entry];

        decode(() { string temp = input; input = null; return temp; }, (dchar got) {
            assert(output[0] == got);
            output = output[1 .. $];
        });

        assert(output.length == 0);
    }

    foreach (entry; 0 .. inputs16.length) {
        wstring input = inputs16[entry];
        dstring output = outputs[entry];

        decode(() { wstring temp = input; input = null; return temp; }, (dchar got) {
            assert(output[0] == got);
            output = output[1 .. $];
        });

        assert(output.length == 0);
    }
}

///
void decode(T)(const(char)[] input, scope T handleDelegate) if (is(T == delegate)) {
    dchar temp;

    while (input.length > 0) {
        size_t consumed = decode(input, temp);
        if (consumed > 0)
            handleDelegate(temp);
        input = input[consumed .. $];
    }
}

///
unittest {
    string[] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    foreach (entry; 0 .. inputs8.length) {
        string input = inputs8[entry];
        dstring output = outputs[entry];

        decode(input, (dchar got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

///
void decode(T)(const(wchar)[] input, scope T handleDelegate) if (is(T == delegate)) {
    dchar temp;

    while (input.length > 0) {
        size_t consumed = decode(input, temp);
        if (consumed > 0)
            handleDelegate(temp);
        input = input[consumed .. $];
    }
}

///
unittest {
    wstring[] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    foreach (entry; 0 .. inputs16.length) {
        wstring input = inputs16[entry];
        dstring output = outputs[entry];

        decode(input, (dchar got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

///
void encodeUTF8(T)(const(dchar)[] input, scope T handleDelegate) if (is(T == delegate)) {
    char[4] temp;

    while (input.length > 0) {
        size_t given = encodeUTF8(input[0], temp);

        if (given > 0)
            handleDelegate(temp[0]);
        if (given > 1)
            handleDelegate(temp[1]);
        if (given > 2)
            handleDelegate(temp[2]);
        if (given > 3)
            handleDelegate(temp[3]);
        input = input[1 .. $];
    }
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    string[] outputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];

    foreach (entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        string output = outputs8[entry];

        encodeUTF8(input, (char got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

///
void encodeUTF16(T)(const(dchar)[] input, scope T handleDelegate) if (is(T == delegate)) {
    wchar[2] temp;

    while (input.length > 0) {
        size_t given = encodeUTF16(input[0], temp);

        if (given > 0)
            handleDelegate(temp[0]);
        if (given > 1)
            handleDelegate(temp[1]);

        input = input[1 .. $];
    }
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    wstring[] outputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];

    foreach (entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        wstring output = outputs16[entry];

        encodeUTF16(input, (wchar got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

/// Supports UTF-8 and UTF-16
size_t decodeLength(T)(scope T refillDelegate) if (is(T == delegate)) {
    size_t result;
    auto input = refillDelegate();

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    while (input.length > 0) {
        if (input.length < 4) {
            typeof(cast()input[0])[8] buffer;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refillDelegate();

            size_t toCopy = 8 - inBuffer;
            if (toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while (inBuffer > 0) {
                size_t consumed = decodeLength(tempInput);
                result += consumed;

                if (consumed >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumed .. $];
                } else
                    inBuffer -= consumed;

                tempInput = tempInput[consumed .. $];
            }
        } else {
            size_t consumed = decodeLength(input);
            result += consumed;
            input = input[consumed .. $];
        }

        if (input.length == 0)
            input = refillDelegate();
    }

    return result;
}

///
unittest {
    foreach (inputString; ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"]) {
        string input = inputString;

        size_t got = decodeLength(() { string temp = input; input = null; return temp; });

        assert(got == inputString.length);
    }

    foreach (inputString; ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, "\u4CD8\uB4DF"w]) {
        wstring input = inputString;

        size_t got = decodeLength(() { wstring temp = input; input = null; return temp; });

        assert(got == inputString.length);
    }
}

///
size_t encodeLengthUTF8(T)(scope T refillDelegate) if (is(T == delegate)) {
    size_t result;
    auto input = refillDelegate();

    enum isUTF32 = is(typeof(cast()input[0]) == dchar);
    static assert(isUTF32, __FUNCTION__ ~ " only supports dchar arrays");

    while (input.length > 0) {
        foreach (dchar c; input) {
            result += encodeLengthUTF8(c);
        }

        input = refillDelegate();
    }

    return result;
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    string[] outputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];

    foreach (entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        string output = outputs8[entry];

        assert(encodeLengthUTF8(() { dstring temp = input; input = null; return temp; }) == output.length);
    }
}

///
size_t encodeLengthUTF16(T)(scope T refillDelegate) if (is(T == delegate)) {
    size_t result;
    auto input = refillDelegate();

    enum isUTF32 = is(typeof(cast()input[0]) == dchar);
    static assert(isUTF32, __FUNCTION__ ~ " only supports dchar arrays");

    while (input.length > 0) {
        foreach (dchar c; input) {
            result += encodeLengthUTF16(c);
        }

        input = refillDelegate();
    }

    return result;
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    wstring[] outputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];

    foreach (entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        wstring output = outputs16[entry];

        assert(encodeLengthUTF16(() { dstring temp = input; input = null; return temp; }) == output.length);
    }
}

/// Supports UTF-8 and UTF-16
void reEncode(T, U)(scope U refillDelegate, scope T handleDelegate) if (is(T == delegate) && is(U == delegate)) {
    auto input = refillDelegate();
    dchar temp;

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    enum codePointUnits = isUTF8 ? 4 : 2;

    while (input.length > 0) {
        if (input.length < codePointUnits) {
            typeof(cast()input[0])[8] buffer;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refillDelegate();

            size_t toCopy = 8 - inBuffer;
            if (toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while (inBuffer > 0) {
                static if (isUTF8) {
                    size_t[2] consumedGot = reEncode(input, temp);

                    if (consumedGot[1] > 0)
                        handleDelegate(temp[0]);
                    if (consumedGot[1] > 1)
                        handleDelegate(temp[1]);
                } else static if (isUTF16) {
                    size_t[2] consumedGot = reEncode(input, temp);

                    if (consumedGot[1] > 0)
                        handleDelegate(temp[0]);
                    if (consumedGot[1] > 1)
                        handleDelegate(temp[1]);
                    if (consumedGot[1] > 2)
                        handleDelegate(temp[2]);
                    if (consumedGot[1] > 3)
                        handleDelegate(temp[3]);
                }

                if (consumedGot[0] >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumedGot[0] .. $];
                } else
                    inBuffer -= consumedGot[0];

                tempInput = tempInput[consumedGot[0] .. $];
            }
        } else {
            static if (isUTF8) {
                size_t[2] consumedGot = reEncode(input, temp);

                if (consumedGot[1] > 0)
                    handleDelegate(temp[0]);
                if (consumedGot[1] > 1)
                    handleDelegate(temp[1]);

                input = input[consumedGot[0] .. $];
            } else static if (isUTF16) {
                size_t[2] consumedGot = reEncode(input, temp);

                if (consumedGot[1] > 0)
                    handleDelegate(temp[0]);
                if (consumedGot[1] > 1)
                    handleDelegate(temp[1]);
                if (consumedGot[1] > 2)
                    handleDelegate(temp[2]);
                if (consumedGot[1] > 3)
                    handleDelegate(temp[3]);

                input = input[consumedGot[0] .. $];
            }
        }

        if (input.length == 0)
            input = refillDelegate();
    }
}

///
void reEncode(T)(scope const(char)[] input, scope T handleDelegate) if (is(T == delegate)) {
    wchar[2] temp;

    while (input.length > 0) {
        size_t[2] consumedGot = reEncode(input, temp);

        if (consumedGot[1] > 0)
            handleDelegate(temp[0]);
        if (consumedGot[1] > 1)
            handleDelegate(temp[1]);

        input = input[consumedGot[0] .. $];
    }
}

///
void reEncode(T)(scope const(wchar)[] input, scope T handleDelegate) if (is(T == delegate)) {
    char[4] temp;

    while (input.length > 0) {
        size_t[2] consumedGot = reEncode(input, temp);

        if (consumedGot[1] > 0)
            handleDelegate(temp[0]);
        if (consumedGot[1] > 1)
            handleDelegate(temp[1]);
        if (consumedGot[1] > 2)
            handleDelegate(temp[2]);
        if (consumedGot[1] > 3)
            handleDelegate(temp[3]);

        input = input[consumedGot[0] .. $];
    }
}

@safe nothrow @nogc pure:

///
size_t[2] reEncode(scope const(char)[] input, out wchar[2] output) {
    if (input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decode(input, temp);
    size_t given = encodeUTF16(temp, output);

    return [consumed, given];
}

///
size_t[2] reEncodeFromEnd(scope const(char)[] input, out wchar[2] output) {
    if (input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decodeFromEnd(input, temp);
    size_t given = encodeUTF16(temp, output);

    return [consumed, given];
}

///
size_t[2] reEncode(scope const(wchar)[] input, out char[4] output) {
    if (input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decode(input, temp);
    size_t given = encodeUTF8(temp, output);

    return [consumed, given];
}

///
size_t[2] reEncodeFromEnd(scope const(wchar)[] input, out char[4] output) {
    if (input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decodeFromEnd(input, temp);
    size_t given = encodeUTF8(temp, output);

    return [consumed, given];
}

///
size_t reEncodeLength(scope const(char)[] input) {
    size_t total;

    while (input.length > 0) {
        dchar temp;
        size_t consumed = decode(input, temp);
        total += encodeLengthUTF16(temp);
        input = input[consumed .. $];
    }

    return total;
}

///
@trusted unittest {
    string[3] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    wstring[3] outputs16 = [
        "\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"
    ];

    foreach (entry; 0 .. inputs8.length) {
        string input = inputs8[entry];
        wstring output = outputs16[entry];

        assert(reEncodeLength(input) == output.length);
    }
}

///
size_t reEncodeLength(scope const(wchar)[] input) {
    size_t total;

    while (input.length > 0) {
        dchar temp;
        size_t consumed = decode(input, temp);
        total += encodeLengthUTF8(temp);
        input = input[consumed .. $];
    }

    return total;
}

///
@trusted unittest {
    wstring[3] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    string[3] outputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];

    foreach (entry; 0 .. inputs16.length) {
        wstring input = inputs16[entry];
        string output = outputs8[entry];

        assert(reEncodeLength(input) == output.length);
    }
}

///
size_t decode(scope const(char)[] input, out dchar result) {
    size_t consumed;
    result = replacementCharacter;

    if (input.length >= 1 && input[0] < 0x80) {
        result = input[0];
        consumed = 1;
    } else if (input.length >= 2 && (input[0] & 0xE0) == 0xC0) {
        result = (cast(dchar)input[0] & 0x1F) << 6;
        result |= input[1] & 0x3F;
        consumed = 2;
    } else if (input.length >= 3 && (input[0] & 0xF0) == 0xE0) {
        result = (cast(dchar)input[0] & 0x0F) << 12;
        result |= (cast(dchar)input[1] & 0x3F) << 6;
        result |= input[2] & 0x3F;
        consumed = 3;
    } else if (input.length >= 4 && (input[0] & 0xF8) == 0xF0 && input[0] <= 0xF4) {
        result = (cast(dchar)input[0] & 0x07) << 18;
        result |= (cast(dchar)input[1] & 0x3F) << 12;
        result |= (cast(dchar)input[2] & 0x3F) << 6;
        result |= input[3] & 0x3F;
        consumed = 4;
    } else {
        // unrecognizable
        consumed = cast(size_t)(input.length > 0);
    }

    // surrogate half, reserved for UTF-16.
    if (result >= 0xD800 && result <= 0xDFFF)
        result = replacementCharacter;

    return consumed;
}

///
size_t decodeFromEnd(scope const(char)[] input, out dchar result) {
    size_t consumed;
    result = replacementCharacter;

    if (input.length >= 1 && input[$ - 1] < 0x80) {
        result = input[$ - 1];
        consumed = 1;
    } else if (input.length >= 2 && (input[$ - 2] & 0xE0) == 0xC0) {
        result = (cast(dchar)input[$ - 2] & 0x1F) << 6;
        result |= input[$ - 1] & 0x3F;
        consumed = 2;
    } else if (input.length >= 3 && (input[$ - 3] & 0xF0) == 0xE0) {
        result = (cast(dchar)input[$ - 3] & 0x0F) << 12;
        result |= (cast(dchar)input[$ - 2] & 0x3F) << 6;
        result |= input[$ - 1] & 0x3F;
        consumed = 3;
    } else if (input.length >= 4 && (input[$ - 4] & 0xF8) == 0xF0 && input[$ - 4] <= 0xF4) {
        result = (cast(dchar)input[$ - 4] & 0x07) << 18;
        result |= (cast(dchar)input[$ - 3] & 0x3F) << 12;
        result |= (cast(dchar)input[$ - 2] & 0x3F) << 6;
        result |= input[$ - 1] & 0x3F;
        consumed = 4;
    } else {
        // unrecognizable
        consumed = cast(size_t)(input.length > 0);
    }

    // surrogate half, reserved for UTF-16.
    if (result >= 0xD800 && result <= 0xDFFF)
        result = replacementCharacter;

    return consumed;
}

///
size_t decode(scope const(wchar)[] input, out dchar result) {
    size_t consumed;
    result = replacementCharacter;

    if (input.length >= 1 && input[0] < 0xD800 || input[0] >= 0xE000) {
        result = input[0];
        consumed = 1;
    } else if (input.length >= 2 && input[0] >= 0xD800 && input[0] <= 0xDBFF && input[1] >= 0xDC00 && input[1] <= 0xDFFF) {
        result = (input[0] & 0x03FF) << 10;
        result |= input[1] & 0x03FF;
        result += 0x10000;
        consumed = 2;
    } else {
        // unrecognizable
        consumed = cast(size_t)(input.length > 0);
    }

    return consumed;
}

///
size_t decodeFromEnd(scope const(wchar)[] input, out dchar result) {
    size_t consumed;
    result = replacementCharacter;

    if (input.length >= 1 && input[$ - 1] < 0xD800 || input[$ - 1] >= 0xE000) {
        result = input[$ - 1];
        consumed = 1;
    } else if (input.length >= 2 && input[$ - 2] >= 0xD800 && input[$ - 2] <= 0xDBFF && input[$ - 1] >= 0xDC00 && input[$ - 1] <= 0xDFFF) {
        result = (input[$ - 2] & 0x03FF) << 10;
        result |= input[$ - 1] & 0x03FF;
        result += 0x10000;
        consumed = 2;
    } else {
        // unrecognizable
        consumed = cast(size_t)(input.length > 0);
    }

    return consumed;
}

///
size_t decodeLength(scope const(char)[] input) {
    size_t consumed = cast(size_t)(input.length > 0);

    if (input.length >= 2 && (input[0] & 0xE0) == 0xC0) {
        consumed = 2;
    } else if (input.length >= 3 && (input[0] & 0xF0) == 0xE0) {
        consumed = 3;
    } else if (input.length >= 4 && (input[0] & 0xF8) == 0xF0 && input[0] <= 0xF4) {
        consumed = 4;
    }

    return consumed;
}

///
size_t decodeLengthFromEnd(scope const(char)[] input) {
    size_t consumed = cast(size_t)(input.length > 0);

    if (input.length >= 2 && (input[$ - 2] & 0xE0) == 0xC0) {
        consumed = 2;
    } else if (input.length >= 3 && (input[$ - 3] & 0xF0) == 0xE0) {
        consumed = 3;
    } else if (input.length >= 4 && (input[$ - 4] & 0xF8) == 0xF0 && input[$ - 4] <= 0xF4) {
        consumed = 4;
    }

    return consumed;
}

///
size_t decodeLength(scope const(wchar)[] input) {
    size_t consumed = cast(size_t)(input.length > 0);

    if (input.length >= 2 && input[0] >= 0xD800 && input[0] <= 0xDBFF && input[1] >= 0xDC00 && input[1] <= 0xDFFF)
        consumed = 2;

    return consumed;
}

///
size_t decodeLengthFromEnd(scope const(wchar)[] input) {
    size_t consumed = cast(size_t)(input.length > 0);

    if (input.length >= 2 && input[$ - 2] >= 0xD800 && input[$ - 2] <= 0xDBFF && input[$ - 1] >= 0xDC00 && input[$ - 1] <= 0xDFFF)
        consumed = 2;

    return consumed;
}

///
size_t encodeUTF8(dchar input, out char[4] output) {
    if (input <= 0x7F) {
        output[0] = cast(char)input;
        return 1;
    } else if (input <= 0x07FF) {
        output[0] = cast(char)(0xC0 | (input >> 6));
        output[1] = cast(char)(0x80 | (input & 0x3F));
        return 2;
    } else if (input <= 0xFFFF) {
        output[0] = cast(char)(0xE0 | (input >> 12));
        output[1] = cast(char)(0x80 | ((input >> 6) & 0x3F));
        output[2] = cast(char)(0x80 | (input & 0x3F));
        return 3;
    } else {
        output[0] = cast(char)(0xF0 | (input >> 18));
        output[1] = cast(char)(0x80 | ((input >> 12) & 0x3F));
        output[2] = cast(char)(0x80 | ((input >> 6) & 0x3F));
        output[3] = cast(char)(0x80 | (input & 0x3F));
        return 4;
    }
}

///
size_t encodeUTF16(dchar input, out wchar[2] output) {
    if (input < 0x10000) {
        output[0] = cast(wchar)input;
        return 1;
    } else {
        input -= 0x10000;
        output[0] = cast(wchar)(0xD800 | (input >> 10));
        output[1] = cast(wchar)(0xDC00 | (input & 0x03FF));
        return 2;
    }
}

///
size_t encodeLengthUTF8(scope const(dchar)[] input) {
    size_t total;

    foreach (dchar c; input)
        total += encodeLengthUTF8(c);

    return total;
}

///
size_t encodeLengthUTF16(scope const(dchar)[] input) {
    size_t total;

    foreach (dchar c; input)
        total += encodeLengthUTF16(c);

    return total;
}

///
size_t encodeLengthUTF8(dchar input) {
    if (input <= 0x7F)
        return 1;
    else if (input <= 0x07FF)
        return 2;
    else if (input <= 0xFFFF)
        return 3;
    else
        return 4;
}

///
size_t encodeLengthUTF16(dchar input) {
    if (input < 0x10000)
        return 1;
    else
        return 2;
}
