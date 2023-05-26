module sidero.base.text.format.rawread;
import sidero.base.text.format.defs;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.traits;

export @safe nothrow @nogc:

///
bool rawRead(Input, Output)(scope ref Input input, scope out Output output, scope FormatSpecifier format = FormatSpecifier.init)
        if (isUTF!Input || isASCII!Input) {
    if (input.empty)
        return false;

    static if (is(Output == bool)) {
        return readBool(input, output, format);
    } else static if (is(Output == char) || is(Output == wchar) || is(Output == dchar)) {
        return readChar(input, output, format);
    } else static if (__traits(isIntegral, Output)) {
        return readIntegral(input, output, format);
    } else
        static assert(0, Output.stringof ~ " cannot be read into.");
}

///
unittest {
    bool b;
    String_UTF8 from;

    from = String_UTF8("t");
    assert(rawRead(from, b, FormatSpecifier.from("{:s}")));
    assert(b);

    from = String_UTF8("true");
    assert(rawRead(from, b, FormatSpecifier.from("{:s}")));
    assert(b);

    from = String_UTF8("1");
    assert(rawRead(from, b, FormatSpecifier.from("{:b}")));
    assert(b);

    from = String_UTF8("f");
    assert(rawRead(from, b, FormatSpecifier.from("{:s}")));
    assert(!b);

    from = String_UTF8("false");
    assert(rawRead(from, b, FormatSpecifier.from("{:s}")));
    assert(!b);

    from = String_UTF8("0");
    assert(rawRead(from, b, FormatSpecifier.from("{:b}")));
    assert(!b);
}

///
unittest {
    int i;
    String_UTF8 from;

    from = String_UTF8("1234");
    assert(rawRead(from, i, FormatSpecifier.from("")));
    assert(i == 1234);

    from = String_UTF8("-1234");
    assert(rawRead(from, i, FormatSpecifier.from("")));
    assert(i == -1234);

    from = String_UTF8("1234");
    assert(rawRead(from, i, FormatSpecifier.from("{:x}")));
    assert(i == 4660);

    from = String_UTF8("-1234");
    assert(rawRead(from, i, FormatSpecifier.from("{:x}")));
    assert(i == -4660);
}

///
unittest {
    dchar c;
    String_UTF8 from;

    from = String_UTF8("hello");
    assert(rawRead(from, c, FormatSpecifier.from("")));
    assert(c == 'h');
}

private @hidden:

bool removeAlternativeFormPrefix(Input)(scope ref Input input, scope FormatSpecifier format) {
    if (!format.useAlternativeForm)
        return true;

    string needed;

    final switch (format.type) {
    case FormatSpecifier.Type.Default:
    case FormatSpecifier.Type.Decimal:
    case FormatSpecifier.Type.Float:
    case FormatSpecifier.Type.FloatHex:
    case FormatSpecifier.Type.FloatHexCapital:
    case FormatSpecifier.Type.FloatScientific:
    case FormatSpecifier.Type.FloatScientificCapital:
    case FormatSpecifier.Type.FloatShortest:
    case FormatSpecifier.Type.FloatShortestCapital:
        break;

    case FormatSpecifier.Type.Binary: // 0b
        needed = "0b";
        break;

    case FormatSpecifier.Type.BinaryCapital: // 0B
        needed = "0B";
        break;

    case FormatSpecifier.Type.Octal: // 0
        needed = "0";
        break;

    case FormatSpecifier.Type.Pointers: /// 0x
    case FormatSpecifier.Type.Hex: // 0x
        needed = "0x";
        break;

    case FormatSpecifier.Type.HexCapital: /// 0X
        needed = "0X";
        break;
    }

    while (!input.empty && needed.length > 0) {
        auto c = input.front;

        if (c != needed[0])
            return false;

        input.popFront;
        needed = needed[1 .. $];
    }

    return needed.length == 0;
}

bool readBool(Input)(scope ref Input input, scope ref bool output, scope FormatSpecifier format) @trusted {
    scope inputTemp = input.save;

    inputTemp.stripLeft;

    if (!removeAlternativeFormPrefix(inputTemp, format))
        return false;

    if (format.type == FormatSpecifier.Type.Default) {
        // true/false
        auto c = inputTemp.front;
        string toGo1, toGo2;

        switch (c) {
        case 't':
        case 'T':
            toGo1 = "rue";
            toGo2 = "RUE";
            output = true;
            break;

        case 'f':
        case 'F':
            toGo1 = "alse";
            toGo2 = "ALSE";
            output = false;
            break;

        default:
            return false;
        }

        inputTemp.popFront;

        if (!inputTemp.empty) {
            while (toGo1.length > 0) {
                if (inputTemp.empty)
                    return false;

                c = inputTemp.front;

                if (!(c == toGo1[0] || c == toGo2[0]))
                    return false;

                inputTemp.popFront;
                toGo1 = toGo1[1 .. $];
                toGo2 = toGo2[1 .. $];
            }
        }

        input = inputTemp;
        return true;
    } else {
        // 0/1
        auto c = input.front;

        switch (c) {
        case '0':
            output = false;
            break;
        case '1':
            output = true;
            break;

        default:
            return false;
        }

        input.popFront;
        input = inputTemp;
        return true;
    }
}

bool readChar(Input, Output)(scope ref Input input, scope ref Output output, scope FormatSpecifier format) @trusted {
    if (input.empty)
        return false;

    static if (isASCII!Input) {
        auto c = input.front;

        if (c >= 128)
            return false;

        output = cast(Output)c;
        input.popFront;
    } else {
        static if (is(Output == char)) {
            auto tempInput = input.byUTF8;
            output = tempInput.front;
        } else static if (is(Output == wchar)) {
            auto tempInput = input.byUTF16;
            output = tempInput.front;
        } else static if (is(Output == dchar)) {
            auto tempInput = input.byUTF32;
            output = tempInput.front;
        }

        tempInput.popFront;

        static if (is(Input == String_UTF!char)) {
            input = tempInput.byUTF8;
        } else static if (is(Input == String_UTF!wchar)) {
            input = tempInput.byUTF16;
        } else static if (is(Input == String_UTF!dchar)) {
            input = tempInput.byUTF32;
        } else static if (is(Input == StringBuilder_UTF!char)) {
            input = tempInput.byUTF8;
        } else static if (is(Input == StringBuilder_UTF!wchar)) {
            input = tempInput.byUTF16;
        } else static if (is(Input == StringBuilder_UTF!dchar)) {
            input = tempInput.byUTF32;
        } else
            static assert(0);
    }

    return true;
}

bool readIntegral(Input, Output)(scope ref Input input, scope ref Output output, scope FormatSpecifier format) @trusted {
    scope inputTemp = input.save;

    if (!removeAlternativeFormPrefix(inputTemp, format))
        return false;

    ubyte base;

    final switch (format.type) {
    case FormatSpecifier.Type.Float:
    case FormatSpecifier.Type.FloatHex:
    case FormatSpecifier.Type.FloatHexCapital:
    case FormatSpecifier.Type.FloatScientific:
    case FormatSpecifier.Type.FloatScientificCapital:
    case FormatSpecifier.Type.FloatShortest:
    case FormatSpecifier.Type.FloatShortestCapital:
        break;

    case FormatSpecifier.Type.Binary:
    case FormatSpecifier.Type.BinaryCapital:
        base = 2;
        break;

    case FormatSpecifier.Type.Octal:
        base = 8;
        break;

    case FormatSpecifier.Type.Default:
    case FormatSpecifier.Type.Decimal:
        base = 10;
        break;

    case FormatSpecifier.Type.Pointers:
    case FormatSpecifier.Type.Hex:
    case FormatSpecifier.Type.HexCapital:
        base = 16;
        break;
    }

    if (base == 0)
        return false;

    bool negate;

    {
        bool haveSign;

        if (!inputTemp.empty) {
            auto c = inputTemp.front;

            if (c == '-') {
                negate = true;
                haveSign = true;
                inputTemp.popFront;
            } else if (c == '+') {
                haveSign = true;
                inputTemp.popFront;
            }
        }

        final switch (format.sign) {
        case FormatSpecifier.Sign.NegativeOnly:
            break;
        case FormatSpecifier.Sign.PositiveAndNegative:
            // we require positve or negative sign
            if (!haveSign)
                return false;
            break;
        case FormatSpecifier.Sign.SpaceForPositiveAndNegative:
            if (!haveSign) {
                const priorLength = inputTemp.length;
                inputTemp.stripLeft;

                if (priorLength != inputTemp.length) {
                    haveSign = true;
                } else
                    return false;
            }
            break;
        }
    }

    {
        bool doneOne;

        Loop: while (!inputTemp.empty) {
            auto c = inputTemp.front;
            uint digit;

            switch (c) {
            case '0': .. case '9':
                digit = c - '0';
                break;
            case 'A': .. case 'Z':
                digit = (c - 'A') + 10;
                break;
            case 'a': .. case 'z':
                digit = (c - 'a') + 10;
                break;
            default:
                break Loop;
            }

            if (digit > base)
                break Loop;

            output *= cast(Output)base;
            output += digit;
            inputTemp.popFront;
            doneOne = true;
        }

        if (!doneOne)
            return false;
    }

    if (negate)
        output *= -1;

    input = inputTemp;
    return true;
}
