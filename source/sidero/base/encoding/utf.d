/**
UTF-8 encoding: https://datatracker.ietf.org/doc/html/rfc3629
UTF-16 encoding: https://datatracker.ietf.org/doc/html/rfc2781
 */
module sidero.base.encoding.utf;
import sidero.base.text.unicode.characters.defs;
import std.traits : isSomeString, isSomeFunction;

export:

///
alias ForeachOverUTF32handle = int delegate(ref dchar) @safe nothrow @nogc;
///
alias ForeachOverUTF32Delegate = int delegate(scope ForeachOverUTF32handle) @safe nothrow @nogc;
///
alias ForeachOverUTF32PeekDelegate = void delegate(size_t amountRead, size_t lastIteratedAmount) @safe nothrow @nogc;

@safe nothrow @nogc {
    ///
    ForeachOverAnyUTF foreachOverAnyUTF(return scope const(char)[] arg, size_t limitCharacters = size_t.max,
            return scope ForeachOverUTF32PeekDelegate peekDel = null) {
        return ForeachOverAnyUTF(arg, limitCharacters, peekDel);
    }

    ///
    ForeachOverAnyUTF foreachOverAnyUTF(return scope const(wchar)[] arg, size_t limitCharacters = size_t.max,
            return scope ForeachOverUTF32PeekDelegate peekDel = null) {
        return ForeachOverAnyUTF(arg, limitCharacters, peekDel);
    }

    ///
    ForeachOverAnyUTF foreachOverAnyUTF(return scope const(dchar)[] arg, size_t limitCharacters = size_t.max,
            return scope ForeachOverUTF32PeekDelegate peekDel = null) {
        return ForeachOverAnyUTF(arg, limitCharacters, peekDel);
    }
}

///
struct ForeachOverAnyUTF {
    private {
        union {
            ForeachOverUTF!(const(char)[]) utf8;
            ForeachOverUTF!(const(wchar)[]) utf16;
            ForeachOverUTF!(const(dchar)[]) utf32;
        }

        int size;
    }

    @disable this(this);

export @safe nothrow @nogc scope:

    ///
    this(return scope const(char)[] input, size_t limitCharacters = size_t.max, return scope ForeachOverUTF32PeekDelegate peekDel = null) @trusted {
        utf8.value = input;
        utf8.peekAtReadAmountDelegate = peekDel;
        utf8.limitCharacters = limitCharacters;
        size = 8;
    }

    ///
    this(return scope const(wchar)[] input, size_t limitCharacters = size_t.max, return scope ForeachOverUTF32PeekDelegate peekDel = null) @trusted {
        utf16.value = input;
        utf16.peekAtReadAmountDelegate = peekDel;
        utf16.limitCharacters = limitCharacters;
        size = 16;
    }

    ///
    this(return scope const(dchar)[] input, size_t limitCharacters = size_t.max, return scope ForeachOverUTF32PeekDelegate peekDel = null) @trusted {
        utf32.value = input;
        utf32.peekAtReadAmountDelegate = peekDel;
        utf32.limitCharacters = limitCharacters;
        size = 32;
    }

    ///
    int opApply(scope ForeachOverUTF32handle del) @trusted {
        if(size == 8)
            return utf8.opApply(del);
        else if(size == 16)
            return utf16.opApply(del);
        else if(size == 32)
            return utf32.opApply(del);
        else
            assert(0);
    }
}

///
ForeachOverUTF!Type foreachOverUTF(Type)(return scope Type arg) {
    return typeof(return)(arg);
}

///
struct ForeachOverUTF(Type) if (isSomeString!Type) {
    ///
    Type value;
    ///
    size_t limitCharacters = size_t.max;

    @disable this(this);

export @safe nothrow @nogc:

    ///
    ForeachOverUTF32PeekDelegate peekAtReadAmountDelegate;

    ///
    int opApply(scope ForeachOverUTF32handle del) scope {
        Type temp = value;
        int result;

        size_t lastIteratedAmount, amountRead, numberOfCharacters;

        while(temp.length > 0 && result == 0 && numberOfCharacters < limitCharacters) {
            size_t consumed;
            dchar got;

            static if(typeof(temp[0]).sizeof == dchar.sizeof) {
                got = temp[0];
                consumed = 1;
            } else {
                consumed = decode(temp, got);
            }

            amountRead += consumed;
            lastIteratedAmount = consumed;

            result = del(got);
            temp = temp[consumed .. $];
            numberOfCharacters++;
        }

        if(peekAtReadAmountDelegate !is null)
            peekAtReadAmountDelegate(amountRead, lastIteratedAmount);

        return result;
    }
}

/// Supports UTF-8 and UTF-16
void decode(T, U)(scope U refill, scope T handle) if (isSomeFunction!T && isSomeFunction!U) {
    import std.traits : ReturnType;

    auto input = refill();
    dchar temp;

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    enum codePointUnits = isUTF8 ? 4 : 2;

    while(input.length > 0) {
        if(input.length < codePointUnits) {
            typeof(cast()input[0])[8] buffer = void;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refill();

            size_t toCopy = 8 - inBuffer;
            if(toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while(inBuffer > 0) {
                size_t consumed = decode(tempInput, temp);

                static if(is(ReturnType!handle == bool)) {
                    if(consumed > 0 && handle(temp))
                        return;
                } else {
                    if(consumed > 0)
                        handle(temp);
                }

                if(consumed >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumed .. $];
                } else
                    inBuffer -= consumed;

                tempInput = tempInput[consumed .. $];
            }
        } else {
            size_t consumed = decode(input, temp);

            static if(is(ReturnType!handle == bool)) {
                if(consumed > 0 && handle(temp))
                    return;
            } else {
                if(consumed > 0)
                    handle(temp);
            }

            input = input[consumed .. $];
        }

        if(input.length == 0)
            input = refill();
    }
}

///
unittest {
    string[] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    wstring[] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    foreach(entry; 0 .. inputs8.length) {
        string input = inputs8[entry];
        dstring output = outputs[entry];

        decode(() { string temp = input; input = null; return temp; }, (dchar got) {
            assert(output[0] == got);
            output = output[1 .. $];
        });

        assert(output.length == 0);
    }

    foreach(entry; 0 .. inputs16.length) {
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
void decode(T)(const(char)[] input, scope T handle) if (isSomeFunction!T) {
    import std.traits : ReturnType;

    dchar temp;

    while(input.length > 0) {
        size_t consumed = decode(input, temp);

        static if(is(ReturnType!handle == bool)) {
            if(consumed > 0 && handle(temp))
                return;
        } else {
            static assert(is(ReturnType!handle == void), "I don't know how to handle a non-void or bool return type");
            if(consumed > 0)
                handle(temp);
        }

        input = input[consumed .. $];
    }
}

///
unittest {
    string[] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    foreach(entry; 0 .. inputs8.length) {
        string input = inputs8[entry];
        dstring output = outputs[entry];

        decode(input, (dchar got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

///
void decode(T)(const(wchar)[] input, scope T handle) if (isSomeFunction!T) {
    import std.traits : ReturnType;

    dchar temp;

    while(input.length > 0) {
        size_t consumed = decode(input, temp);

        static if(is(ReturnType!handle == bool)) {
            if(consumed > 0 && handle(temp))
                return;
        } else {
            static assert(is(ReturnType!handle == void), "I don't know how to handle a non-void or bool return type");
            if(consumed > 0)
                handle(temp);
        }

        input = input[consumed .. $];
    }
}

///
unittest {
    wstring[] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    foreach(entry; 0 .. inputs16.length) {
        wstring input = inputs16[entry];
        dstring output = outputs[entry];

        decode(input, (dchar got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

///
void encodeUTF8(T)(const(dchar)[] input, scope T handle) if (isSomeFunction!T) {
    char[4] temp = void;

    while(input.length > 0) {
        size_t given = encodeUTF8(input[0], temp);

        if(given > 0)
            handle(temp[0]);
        if(given > 1)
            handle(temp[1]);
        if(given > 2)
            handle(temp[2]);
        if(given > 3)
            handle(temp[3]);
        input = input[1 .. $];
    }
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    string[] outputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];

    foreach(entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        string output = outputs8[entry];

        encodeUTF8(input, (char got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

///
void encodeUTF16(T)(const(dchar)[] input, scope T handle) if (isSomeFunction!T) {
    wchar[2] temp = void;

    while(input.length > 0) {
        size_t given = encodeUTF16(input[0], temp);

        if(given > 0)
            handle(temp[0]);
        if(given > 1)
            handle(temp[1]);

        input = input[1 .. $];
    }
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    wstring[] outputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];

    foreach(entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        wstring output = outputs16[entry];

        encodeUTF16(input, (wchar got) { assert(output[0] == got); output = output[1 .. $]; });
        assert(output.length == 0);
    }
}

/// Supports UTF-8 and UTF-16
size_t decodeLength(T)(scope T refill) if (isSomeFunction!T) {
    size_t result;
    auto input = refill();

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    while(input.length > 0) {
        if(input.length < 4) {
            typeof(cast()input[0])[8] buffer;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refill();

            size_t toCopy = 8 - inBuffer;
            if(toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while(inBuffer > 0) {
                size_t consumed = decodeLength(tempInput[0]);
                result += consumed;

                if(consumed >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumed .. $];
                } else
                    inBuffer -= consumed;

                tempInput = tempInput[consumed .. $];
            }
        } else {
            size_t consumed = decodeLength(input[0]);
            result += consumed;
            input = input[consumed .. $];
        }

        if(input.length == 0)
            input = refill();
    }

    return result;
}

///
unittest {
    foreach(inputString; ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"]) {
        string input = inputString;

        size_t got = decodeLength(() { string temp = input; input = null; return temp; });

        assert(got == inputString.length);
    }

    foreach(inputString; ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, "\u4CD8\uB4DF"w]) {
        wstring input = inputString;

        size_t got = decodeLength(() { wstring temp = input; input = null; return temp; });

        assert(got == inputString.length);
    }
}

///
size_t encodeLengthUTF8(T)(scope T refill) if (isSomeFunction!T) {
    size_t result;
    auto input = refill();

    enum isUTF32 = is(typeof(cast()input[0]) == dchar);
    static assert(isUTF32, __FUNCTION__ ~ " only supports dchar arrays");

    while(input.length > 0) {
        foreach(dchar c; input) {
            result += encodeLengthUTF8(c);
        }

        input = refill();
    }

    return result;
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    string[] outputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];

    foreach(entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        string output = outputs8[entry];

        assert(encodeLengthUTF8(() { dstring temp = input; input = null; return temp; }) == output.length);
    }
}

///
size_t encodeLengthUTF16(T)(scope T refill) if (isSomeFunction!T) {
    size_t result;
    auto input = refill();

    enum isUTF32 = is(typeof(cast()input[0]) == dchar);
    static assert(isUTF32, __FUNCTION__ ~ " only supports dchar arrays");

    while(input.length > 0) {
        foreach(dchar c; input) {
            result += encodeLengthUTF16(c);
        }

        input = refill();
    }

    return result;
}

///
unittest {
    dstring[] inputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];
    wstring[] outputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];

    foreach(entry; 0 .. inputs.length) {
        dstring input = inputs[entry];
        wstring output = outputs16[entry];

        assert(encodeLengthUTF16(() { dstring temp = input; input = null; return temp; }) == output.length);
    }
}

/// Supports UTF-8 and UTF-16
void reEncode(T, U)(scope U refill, scope T handle) if (isSomeFunction!T && isSomeFunction!U) {
    auto input = refill();
    dchar temp;

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    enum codePointUnits = isUTF8 ? 4 : 2;

    while(input.length > 0) {
        if(input.length < codePointUnits) {
            typeof(cast()input[0])[8] buffer = void;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refill();

            size_t toCopy = 8 - inBuffer;
            if(toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while(inBuffer > 0) {
                static if(isUTF8) {
                    size_t[2] consumedGot = reEncode(input, temp);

                    if(consumedGot[1] > 0)
                        handle(temp[0]);
                    if(consumedGot[1] > 1)
                        handle(temp[1]);
                } else static if(isUTF16) {
                    size_t[2] consumedGot = reEncode(input, temp);

                    if(consumedGot[1] > 0)
                        handle(temp[0]);
                    if(consumedGot[1] > 1)
                        handle(temp[1]);
                    if(consumedGot[1] > 2)
                        handle(temp[2]);
                    if(consumedGot[1] > 3)
                        handle(temp[3]);
                }

                if(consumedGot[0] >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumedGot[0] .. $];
                } else
                    inBuffer -= consumedGot[0];

                tempInput = tempInput[consumedGot[0] .. $];
            }
        } else {
            static if(isUTF8) {
                size_t[2] consumedGot = reEncode(input, temp);

                if(consumedGot[1] > 0)
                    handle(temp[0]);
                if(consumedGot[1] > 1)
                    handle(temp[1]);

                input = input[consumedGot[0] .. $];
            } else static if(isUTF16) {
                size_t[2] consumedGot = reEncode(input, temp);

                if(consumedGot[1] > 0)
                    handle(temp[0]);
                if(consumedGot[1] > 1)
                    handle(temp[1]);
                if(consumedGot[1] > 2)
                    handle(temp[2]);
                if(consumedGot[1] > 3)
                    handle(temp[3]);

                input = input[consumedGot[0] .. $];
            }
        }

        if(input.length == 0)
            input = refill();
    }
}

///
void reEncode(T)(scope const(char)[] input, scope T handle) if (isSomeFunction!T) {
    wchar[2] temp = void;

    while(input.length > 0) {
        size_t[2] consumedGot = reEncode(input, temp);

        if(consumedGot[1] > 0)
            handle(temp[0]);
        if(consumedGot[1] > 1)
            handle(temp[1]);

        input = input[consumedGot[0] .. $];
    }
}

///
void reEncode(T)(scope const(wchar)[] input, scope T handle) if (isSomeFunction!T) {
    char[4] temp = void;

    while(input.length > 0) {
        size_t[2] consumedGot = reEncode(input, temp);

        if(consumedGot[1] > 0)
            handle(temp[0]);
        if(consumedGot[1] > 1)
            handle(temp[1]);
        if(consumedGot[1] > 2)
            handle(temp[2]);
        if(consumedGot[1] > 3)
            handle(temp[3]);

        input = input[consumedGot[0] .. $];
    }
}

///
dchar decode(Char)(scope bool delegate() @safe nothrow @nogc empty, scope Char delegate() @safe nothrow @nogc front,
        scope void delegate() @safe nothrow @nogc popFront, ref size_t consumed) {
    assert(empty !is null);
    assert(front !is null);
    assert(popFront !is null);

    consumed = 1;
    dchar result = replacementCharacter;

    Char[4 / Char.sizeof] temp = void;
    size_t soFar, expecting;

    while(!empty()) {
        Char got = front();

        static if(is(Char == char)) {
            if(soFar == 0) {
                if(got < 0x80) {
                    // ok only need one
                    result = cast(dchar)got;

                    consumed = 1;
                    popFront();
                    break;
                } else if((got & 0xE0) == 0xC0) {
                    temp[soFar++] = got;
                    expecting = 2;

                    popFront();
                    continue;
                } else if((got & 0xF0) == 0xE0) {
                    temp[soFar++] = got;
                    expecting = 3;

                    popFront();
                    continue;
                } else if((got & 0xF8) == 0xF0 && got <= 0xF4) {
                    temp[soFar++] = got;
                    expecting = 4;

                    popFront();
                    continue;
                } else {
                    // unknown state

                    popFront();
                    break;
                }
            } else if(soFar == 1) {
                if(expecting == 2) {
                    result = (cast(dchar)temp[0] & 0x1F) << 6;
                    result |= got & 0x3F;

                    consumed = 2;
                    popFront();
                    break;
                } else {
                    temp[soFar++] = got;

                    popFront();
                    continue;
                }
            } else if(soFar == 2) {
                if(expecting == 3) {
                    result = (cast(dchar)temp[0] & 0x0F) << 12;
                    result |= (cast(dchar)temp[1] & 0x3F) << 6;
                    result |= got & 0x3F;

                    consumed = 3;
                    popFront();
                    break;
                } else {
                    temp[soFar++] = got;

                    popFront();
                    continue;
                }
            } else {
                result = (cast(dchar)temp[0] & 0x07) << 18;
                result |= (cast(dchar)temp[1] & 0x3F) << 12;
                result |= (cast(dchar)temp[2] & 0x3F) << 6;
                result |= got & 0x3F;

                consumed = 4;
                popFront();
                break;
            }
        } else static if(is(Char == wchar)) {
            if(soFar == 0) {
                if(got < 0xD800 || got >= 0xE000) {
                    result = got;

                    consumed = 1;
                    popFront();
                    break;
                } else {
                    temp[soFar++] = got;

                    popFront();
                    continue;
                }
            } else if(soFar == 1) {
                if(temp[0] >= 0xD800 && temp[0] <= 0xDBFF && got >= 0xDC00 && got <= 0xDFFF) {
                    result = (temp[0] & 0x03FF) << 10;
                    result |= got & 0x03FF;
                    result += 0x10000;

                    consumed = 2;
                    popFront();
                    break;
                } else {
                    // unknown state
                    break;
                }
            }
        } else static if(is(Char == dchar)) {
            result = got;

            consumed = 1;
            popFront();
            break;
        }
    }

    return result;
}

///
unittest {
    string[] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    wstring[] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    {
        foreach(entry; 0 .. inputs8.length) {
            string input = inputs8[entry];
            dstring output = outputs[entry];

            char front() {
                return input[0];
            }

            bool empty() {
                return input.length == 0;
            }

            void popFront() {
                input = input[1 .. $];
            }

            while(!empty()) {
                size_t consumed;
                dchar got = decode(&empty, &front, &popFront, consumed);

                assert(output[0] == got);
                output = output[1 .. $];
            }

            assert(output.length == 0);
        }
    }

    {
        foreach(entry; 0 .. inputs16.length) {
            wstring input = inputs16[entry];
            dstring output = outputs[entry];

            wchar front() {
                return input[0];
            }

            bool empty() {
                return input.length == 0;
            }

            void popFront() {
                input = input[1 .. $];
            }

            while(!empty()) {
                size_t consumed;
                dchar got = decode(&empty, &front, &popFront, consumed);

                assert(output[0] == got);
                output = output[1 .. $];
            }

            assert(output.length == 0);
        }
    }
}

///
dchar decodeFromEnd(Char)(scope bool delegate() @safe nothrow @nogc empty, scope Char delegate() @safe nothrow @nogc back,
        scope void delegate() @safe nothrow @nogc popBack, ref size_t consumed) {
    assert(empty !is null);
    assert(back !is null);
    assert(popBack !is null);

    consumed = 1;
    dchar result = replacementCharacter;

    Char[4 / Char.sizeof] temp = void;
    size_t soFar;

    while(!empty()) {
        Char got = back();

        static if(is(Char == char)) {
            // C0 = 1100 0000 done
            // & C0) == 80 = 1000 0000 next

            if(soFar == 0) {
                if(got < 0x80) {
                    result = got;

                    consumed = 1;
                    popBack();
                    break;
                } else if((got & 0xC0) == 0x80) {
                    // continuation
                    soFar++;
                    temp[$ - soFar] = got;

                    popBack();
                    continue;
                } else {
                    // unknown
                    popBack();
                    break;
                }
            } else if(soFar == 1) {
                if((got & 0xE0) == 0xC0) {
                    result = (cast(dchar)got & 0x1F) << 6;
                    result |= temp[$ - 1] & 0x3F;

                    consumed = 2;
                    popBack();
                    break;
                } else if((got & 0xC0) == 0x80) {
                    // continuation
                    soFar++;
                    temp[$ - soFar] = got;

                    popBack();
                    continue;
                } else {
                    // unknown
                    break;
                }
            } else if(soFar == 2) {
                if((got & 0xF0) == 0xE0) {
                    result = (cast(dchar)got & 0x0F) << 12;
                    result |= (cast(dchar)temp[$ - 2] & 0x3F) << 6;
                    result |= temp[$ - 1] & 0x3F;

                    consumed = 3;
                    popBack();
                    break;
                } else if((got & 0xC0) == 0x80) {
                    // continuation
                    soFar++;
                    temp[$ - soFar] = got;

                    popBack();
                    continue;
                } else {
                    // unknown
                    break;
                }
            } else if(soFar == 3) {
                if((got & 0xF8) == 0xF0 && got <= 0xF4) {
                    result = (cast(dchar)got & 0x07) << 18;
                    result |= (cast(dchar)temp[$ - 3] & 0x3F) << 12;
                    result |= (cast(dchar)temp[$ - 2] & 0x3F) << 6;
                    result |= temp[$ - 1] & 0x3F;

                    consumed = 4;
                    popBack();
                    break;
                } else {
                    // unknown
                    break;
                }
            }
        } else static if(is(Char == wchar)) {
            if(soFar == 0) {
                if(got < 0xD800 || got >= 0xE000) {
                    result = got;

                    consumed = 1;
                    popBack();
                    break;
                } else if(got >= 0xDC00 && got <= 0xDFFF) {
                    soFar++;
                    temp[$ - soFar] = got;

                    popBack();
                    continue;
                } else {
                    // unknown state
                    popBack();
                    break;
                }
            } else {
                if(got >= 0xD800 && got <= 0xDBFF) {
                    result = (got & 0x03FF) << 10;
                    result |= temp[$ - 1] & 0x03FF;
                    result += 0x10000;

                    consumed = 2;
                    popBack();
                    break;
                } else {
                    // unknown state
                    break;
                }
            }
        } else static if(is(Char == dchar)) {
            result = got;

            consumed = 1;
            popBack();
            break;
        }
    }

    return result;
}

///
unittest {
    string[] inputs8 = ["\x41\xE2\x89\xA2\xCE\x91\x2E", "\xED\x95\x9C\xEA\xB5\xAD\xEC\x96\xB4", "\xF0\xA3\x8E\xB4"];
    wstring[] inputs16 = ["\x41\u2262\u0391\x2E"w, "\uD55C\uAD6D\uC5B4"w, cast(wstring)cast(ubyte[])"\x4C\xD8\xB4\xDF"];
    dstring[] outputs = ["\u0041\u2262\u0391\u002E"d, "\uD55C\uAD6D\uC5B4"d, "\U000233B4"d];

    {
        foreach(entry; 0 .. inputs8.length) {
            string input = inputs8[entry];
            dstring output = outputs[entry];

            char back() {
                return input[$ - 1];
            }

            bool empty() {
                return input.length == 0;
            }

            void popBack() {
                input = input[0 .. $ - 1];
            }

            while(!empty()) {
                size_t consumed;
                dchar got = decodeFromEnd(&empty, &back, &popBack, consumed);

                assert(output[$ - 1] == got);
                output = output[0 .. $ - 1];
            }

            assert(output.length == 0);
        }
    }

    {
        foreach(entry; 0 .. inputs16.length) {
            wstring input = inputs16[entry];
            dstring output = outputs[entry];

            wchar back() {
                return input[$ - 1];
            }

            bool empty() {
                return input.length == 0;
            }

            void popBack() {
                input = input[0 .. $ - 1];
            }

            while(!empty()) {
                size_t consumed;
                dchar got = decodeFromEnd(&empty, &back, &popBack, consumed);

                assert(output[$ - 1] == got);
                output = output[0 .. $ - 1];
            }

            assert(output.length == 0);
        }
    }
}

@safe nothrow @nogc pure:

///
size_t[2] reEncode(scope const(char)[] input, ref wchar[2] output) {
    if(input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decode(input, temp);
    size_t given = encodeUTF16(temp, output);

    return [consumed, given];
}

///
size_t[2] reEncodeFromEnd(scope const(char)[] input, ref wchar[2] output) {
    if(input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decodeFromEnd(input, temp);
    size_t given = encodeUTF16(temp, output);

    return [consumed, given];
}

///
size_t[2] reEncode(scope const(wchar)[] input, ref char[4] output) {
    if(input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decode(input, temp);
    size_t given = encodeUTF8(temp, output);

    return [consumed, given];
}

///
size_t[2] reEncodeFromEnd(scope const(wchar)[] input, ref char[4] output) {
    if(input.length == 0)
        return [0, 0];

    dchar temp;
    size_t consumed = decodeFromEnd(input, temp);
    size_t given = encodeUTF8(temp, output);

    return [consumed, given];
}

/// Supports UTF-8 and UTF-16
size_t reEncodeLength(U)(scope U refill) if (is(U == function) || is(U == delegate)) {
    import sidero.base.text.unicode.characters.defs : replacementCharacter;

    auto input = refill();
    dchar temp;

    enum isUTF8 = is(typeof(cast()input[0]) == char);
    enum isUTF16 = is(typeof(cast()input[0]) == wchar);
    static assert(isUTF8 || isUTF16, __FUNCTION__ ~ " only supports char and wchar arrays");

    enum codePointUnits = isUTF8 ? 4 : 2;
    size_t result;

    while(input.length > 0) {
        if(input.length < codePointUnits) {
            typeof(cast()input[0])[8] buffer;
            buffer[0 .. input.length] = input[];
            size_t inBuffer = input.length;

            input = refill();

            size_t toCopy = 8 - inBuffer;
            if(toCopy > input.length)
                toCopy = input.length;

            buffer[inBuffer .. inBuffer + toCopy] = input[0 .. toCopy];
            auto tempInput = buffer[0 .. inBuffer + toCopy];

            while(inBuffer > 0) {
                size_t consumed = decode(tempInput, temp, false);

                if(consumed == 0) {
                    temp = replacementCharacter;
                    consumed = 1;
                }

                static if(isUTF8) {
                    result += encodeLengthUTF16(temp);
                } else static if(isUTF16) {
                    result += encodeLengthUTF8(temp);
                }

                if(consumed >= inBuffer) {
                    consumed -= inBuffer;
                    inBuffer = 0;

                    input = input[consumed .. $];
                } else
                    inBuffer -= consumed;

                tempInput = tempInput[consumed .. $];
            }
        } else {
            while(input.length > 0) {
                size_t consumed = decode(input, temp, false);

                if(consumed == 0) {
                    if(input.length >= codePointUnits) {
                        temp = replacementCharacter;
                        consumed = 1;
                    } else
                        break;
                }

                static if(isUTF8) {
                    result += encodeLengthUTF16(temp);
                } else static if(isUTF16) {
                    result += encodeLengthUTF8(temp);
                }

                input = input[consumed .. $];
            }
        }

        if(input.length == 0)
            input = refill();
    }
}

///
size_t reEncodeLength(scope const(char)[] input) {
    size_t total;

    while(input.length > 0) {
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

    foreach(entry; 0 .. inputs8.length) {
        string input = inputs8[entry];
        wstring output = outputs16[entry];

        assert(reEncodeLength(input) == output.length);
    }
}

///
size_t reEncodeLength(scope const(wchar)[] input) {
    size_t total;

    while(input.length > 0) {
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

    foreach(entry; 0 .. inputs16.length) {
        wstring input = inputs16[entry];
        string output = outputs8[entry];

        assert(reEncodeLength(input) == output.length);
    }
}

/// Returns: number of code points from start that fulfills the number of characters or 0 if it wasn't completed
size_t codePointsFromStart(scope const(char)[] input, size_t countCharacters) {
    size_t ret;

    while(countCharacters > 0) {
        if(input.length == 0)
            return 0;

        size_t got = decodeLength(input[0]);
        ret += got;

        input = input[got .. $];
        countCharacters--;
    }

    return ret;
}

///
unittest {
    static immutable Text = "it is bold";
    assert(codePointsFromStart(Text, 4) == 4);
}

/// Returns: number of code points from end that fulfills the number of characters or 0 if it wasn't completed
size_t codePointsFromEnd(scope const(char)[] input, size_t countCharacters) {
    size_t ret;

    while(countCharacters > 0) {
        if(input.length == 0)
            return 0;

        size_t got = decodeLengthFromEnd(input);
        ret += got;

        input = input[got .. $];
        countCharacters--;
    }

    return ret;
}

///
unittest {
    static immutable Text = "it is bold";
    assert(codePointsFromEnd(Text, 4) == 4);
}

/// Returns: number of code points from start that fulfills the number of characters or 0 if it wasn't completed
size_t codePointsFromStart(scope const(wchar)[] input, size_t countCharacters) {
    size_t ret;

    while(countCharacters > 0) {
        if(input.length == 0)
            return 0;

        size_t got = decodeLength(input[0]);
        ret += got;

        input = input[got .. $];
        countCharacters--;
    }

    return ret;
}

///
unittest {
    static immutable Text = "it is bold"w;
    assert(codePointsFromStart(Text, 4) == 4);
}

/// Returns: number of code points from end that fulfills the number of characters or 0 if it wasn't completed
size_t codePointsFromEnd(scope const(wchar)[] input, size_t countCharacters) {
    size_t ret;

    while(countCharacters > 0) {
        if(input.length == 0)
            return 0;

        size_t got = decodeLengthFromEnd(input);
        ret += got;

        input = input[got .. $];
        countCharacters--;
    }

    return ret;
}

///
unittest {
    static immutable Text = "it is bold"w;
    assert(codePointsFromEnd(Text, 4) == 4);
}

/// Returns: number of code points from start that fulfills the number of characters or 0 if it wasn't completed
size_t codePointsFromStart(scope const(dchar)[] input, size_t countCharacters) {
    return input.length >= countCharacters ? countCharacters : 0;
}

///
unittest {
    static immutable Text = "it is bold"d;
    assert(codePointsFromStart(Text, 4) == 4);
}

/// Returns: number of code points from end that fulfills the number of characters or 0 if it wasn't completed
size_t codePointsFromEnd(scope const(dchar)[] input, size_t countCharacters) {
    return input.length >= countCharacters ? countCharacters : 0;
}

///
unittest {
    static immutable Text = "it is bold"d;
    assert(codePointsFromEnd(Text, 4) == 4);
}

///
size_t decode(scope const(char)[] input, ref dchar result, bool advanceIfUnrecognized = true) {
    size_t consumed;
    result = replacementCharacter;

    if(input.length >= 1 && input[0] < 0x80) {
        result = input[0];
        consumed = 1;
    } else if(input.length >= 2 && (input[0] & 0xE0) == 0xC0) {
        result = (cast(dchar)input[0] & 0x1F) << 6;
        result |= input[1] & 0x3F;
        consumed = 2;
    } else if(input.length >= 3 && (input[0] & 0xF0) == 0xE0) {
        result = (cast(dchar)input[0] & 0x0F) << 12;
        result |= (cast(dchar)input[1] & 0x3F) << 6;
        result |= input[2] & 0x3F;
        consumed = 3;
    } else if(input.length >= 4 && (input[0] & 0xF8) == 0xF0 && input[0] <= 0xF4) {
        result = (cast(dchar)input[0] & 0x07) << 18;
        result |= (cast(dchar)input[1] & 0x3F) << 12;
        result |= (cast(dchar)input[2] & 0x3F) << 6;
        result |= input[3] & 0x3F;
        consumed = 4;
    } else {
        // unrecognizable
        consumed = cast(size_t)(advanceIfUnrecognized && input.length > 0);
    }

    // surrogate half, reserved for UTF-16.
    if(result >= 0xD800 && result <= 0xDFFF)
        result = replacementCharacter;

    return consumed;
}

///
size_t decodeFromEnd(scope const(char)[] input, ref dchar result, bool advanceIfUnrecognized = true) {
    size_t consumed;
    result = replacementCharacter;

    if(input.length >= 1 && input[$ - 1] < 0x80) {
        result = input[$ - 1];
        consumed = 1;
    } else if(input.length >= 2 && (input[$ - 2] & 0xE0) == 0xC0) {
        result = (cast(dchar)input[$ - 2] & 0x1F) << 6;
        result |= input[$ - 1] & 0x3F;
        consumed = 2;
    } else if(input.length >= 3 && (input[$ - 3] & 0xF0) == 0xE0) {
        result = (cast(dchar)input[$ - 3] & 0x0F) << 12;
        result |= (cast(dchar)input[$ - 2] & 0x3F) << 6;
        result |= input[$ - 1] & 0x3F;
        consumed = 3;
    } else if(input.length >= 4 && (input[$ - 4] & 0xF8) == 0xF0 && input[$ - 4] <= 0xF4) {
        result = (cast(dchar)input[$ - 4] & 0x07) << 18;
        result |= (cast(dchar)input[$ - 3] & 0x3F) << 12;
        result |= (cast(dchar)input[$ - 2] & 0x3F) << 6;
        result |= input[$ - 1] & 0x3F;
        consumed = 4;
    } else {
        // unrecognizable
        consumed = cast(size_t)(advanceIfUnrecognized && input.length > 0);
    }

    // surrogate half, reserved for UTF-16.
    if(result >= 0xD800 && result <= 0xDFFF)
        result = replacementCharacter;

    return consumed;
}

///
size_t decode(scope const(wchar)[] input, ref dchar result, bool advanceIfUnrecognized = true) {
    size_t consumed;
    result = replacementCharacter;

    if(input.length >= 1 && input[0] < 0xD800 || input[0] >= 0xE000) {
        result = input[0];
        consumed = 1;
    } else if(input.length >= 2 && input[0] >= 0xD800 && input[0] <= 0xDBFF && input[1] >= 0xDC00 && input[1] <= 0xDFFF) {
        result = (input[0] & 0x03FF) << 10;
        result |= input[1] & 0x03FF;
        result += 0x10000;
        consumed = 2;
    } else {
        // unrecognizable
        consumed = cast(size_t)(advanceIfUnrecognized && input.length > 0);
    }

    return consumed;
}

///
size_t decodeFromEnd(scope const(wchar)[] input, ref dchar result, bool advanceIfUnrecognized = true) {
    size_t consumed;
    result = replacementCharacter;

    if(input.length >= 1 && input[$ - 1] < 0xD800 || input[$ - 1] >= 0xE000) {
        result = input[$ - 1];
        consumed = 1;
    } else if(input.length >= 2 && input[$ - 2] >= 0xD800 && input[$ - 2] <= 0xDBFF && input[$ - 1] >= 0xDC00 && input[$ - 1] <= 0xDFFF) {
        result = (input[$ - 2] & 0x03FF) << 10;
        result |= input[$ - 1] & 0x03FF;
        result += 0x10000;
        consumed = 2;
    } else {
        // unrecognizable
        consumed = cast(size_t)(advanceIfUnrecognized && input.length > 0);
    }

    return consumed;
}

///
size_t decodeLength(scope char input) {
    size_t consumed = 1;

    if((input & 0xE0) == 0xC0) {
        consumed = 2;
    } else if((input & 0xF0) == 0xE0) {
        consumed = 3;
    } else if((input & 0xF8) == 0xF0 && input <= 0xF4) {
        consumed = 4;
    }

    return consumed;
}

///
size_t decodeLengthFromEnd(scope const(char)[] input) {
    size_t consumed = cast(size_t)(input.length > 0);

    if(input.length >= 2 && (input[$ - 2] & 0xE0) == 0xC0) {
        consumed = 2;
    } else if(input.length >= 3 && (input[$ - 3] & 0xF0) == 0xE0) {
        consumed = 3;
    } else if(input.length >= 4 && (input[$ - 4] & 0xF8) == 0xF0 && input[$ - 4] <= 0xF4) {
        consumed = 4;
    }

    return consumed;
}

///
size_t decodeLength(scope wchar input) {
    size_t consumed = 1;

    if(input >= 0xD800 && input <= 0xDBFF)
        consumed = 2;

    return consumed;
}

///
size_t decodeLengthFromEnd(scope const(wchar)[] input) {
    size_t consumed = cast(size_t)(input.length > 0);

    if(input.length >= 2 && input[$ - 2] >= 0xD800 && input[$ - 2] <= 0xDBFF && input[$ - 1] >= 0xDC00 && input[$ - 1] <= 0xDFFF)
        consumed = 2;

    return consumed;
}

///
size_t decodeLength(scope const(dchar)[] input) {
    return input.length > 0 ? 1 : 0;
}

///
alias encode = encodeUTF8;
///
alias encode = encodeUTF16;

///
size_t encodeUTF8(dchar input, ref char[4] output) {
    if(input <= 0x7F) {
        output[0] = cast(char)input;
        return 1;
    } else if(input <= 0x07FF) {
        output[0] = cast(char)(0xC0 | (input >> 6));
        output[1] = cast(char)(0x80 | (input & 0x3F));
        return 2;
    } else if(input <= 0xFFFF) {
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
size_t encodeUTF16(dchar input, ref wchar[2] output) {
    if(input <= 0xD7FF || (input >= 0xE000 && input <= 0xFFFF)) {
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

    foreach(dchar c; input)
        total += encodeLengthUTF8(c);

    return total;
}

///
size_t encodeLengthUTF16(scope const(dchar)[] input) {
    size_t total;

    foreach(dchar c; input)
        total += encodeLengthUTF16(c);

    return total;
}

///
size_t encodeLengthUTF8(dchar input) {
    if(input <= 0x7F)
        return 1;
    else if(input <= 0x07FF)
        return 2;
    else if(input <= 0xFFFF)
        return 3;
    else
        return 4;
}

///
size_t encodeLengthUTF16(dchar input) {
    if(input <= 0xD7FF || (input >= 0xE000 && input <= 0xFFFF))
        return 1;
    else
        return 2;
}
