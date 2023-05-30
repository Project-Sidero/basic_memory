module sidero.base.text.format.rawwrite;
import sidero.base.text.format.specifier;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.traits;
import sidero.base.allocators;

export @safe nothrow @nogc:

///
bool rawWrite(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format = FormatSpecifier.init)
        if (isBuilderString!Builder) {
    if (output.isNull)
        output = Builder(globalAllocator());

    static if (is(Input == bool)) {
        return writeBool(output, input, format);
    } else static if (is(Input == char) || (isUTF!Builder && (is(Input == wchar) || is(Input == dchar)))) {
        return writeChar(output, input, format);
    } else static if (__traits(isIntegral, Input)) {
        return writeIntegral(output, input, format);
    } else static if (__traits(isFloating, Input)) {
        return writeFloat(output, input, format);
    } else
        static assert(0, Input.stringof ~ " cannot be written.");
}

///
unittest {
    StringBuilder_UTF8 builder;
    assert(rawWrite(builder, true, FormatSpecifier.from("{:s}")));
    assert(builder == "true");

    assert(rawWrite(builder, false, FormatSpecifier.from("{:+#b}")));
    assert(builder == "true+0b0");

    assert(rawWrite(builder, true, FormatSpecifier.from("{:+03b}")));
    assert(builder == "true+0b0+01");

    assert(rawWrite(builder, true, FormatSpecifier.from("{: <+3b}")));
    assert(builder == "true+0b0+01 +1");

    assert(rawWrite(builder, false, FormatSpecifier.from("{: >2b}")));
    assert(builder == "true+0b0+01 +10 ");

    assert(rawWrite(builder, true, FormatSpecifier.from("{: ^3b}")));
    assert(builder == "true+0b0+01 +10  1 ");

    assert(rawWrite(builder, -1234, FormatSpecifier.from("{:s}")));
    assert(builder == "true+0b0+01 +10  1 -1234");

    assert(rawWrite(builder, -3.95, FormatSpecifier.from("{:06.2s}")));
    assert(builder == "true+0b0+01 +10  1 -1234-03.95");
}

private:

bool addSign(Builder)(scope ref Builder output, scope FormatSpecifier format, bool positive) {
    final switch (format.sign) {
    case FormatSpecifier.Sign.NegativeOnly:
        if (!positive) {
            output ~= "-"c;
            return true;
        }
        return false;
    case FormatSpecifier.Sign.PositiveAndNegative:
        output ~= positive ? "+"c : "-"c;
        return true;
    case FormatSpecifier.Sign.SpaceForPositiveAndNegative:
        output ~= positive ? " "c : "-"c;
        return true;
    }
}

void addPrefix(Builder)(scope ref Builder output, scope FormatSpecifier format) {
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
        output ~= "0b";
        break;

    case FormatSpecifier.Type.BinaryCapital: // 0B
        output ~= "0B";
        break;

    case FormatSpecifier.Type.Octal: // 0
        output ~= "0";
        break;

    case FormatSpecifier.Type.Pointers: /// 0x
    case FormatSpecifier.Type.Hex: // 0x
        output ~= "0x";
        break;

    case FormatSpecifier.Type.HexCapital: /// 0X
        output ~= "0X";
        break;
    }
}

void handleFill(Builder)(scope ref Builder output, scope FormatSpecifier format,
        scope void delegate() @safe nothrow @nogc prefixDel, scope void delegate() @safe nothrow @nogc mainDel) {

    final switch (format.alignment) {
    case FormatSpecifier.Alignment.None:
        prefixDel();
        mainDel();
        break;

    case FormatSpecifier.Alignment.Left:
        const priorLength = output.length;

        prefixDel();
        mainDel();

        const completeLength = output.length;
        const diff = completeLength - priorLength;

        foreach (_; diff .. format.minimumWidth) {
            static if (is(Builder == StringBuilder_ASCII)) {
                output.insert(priorLength, cast(ubyte)format.fillCharacter);
            } else {
                output.insert(priorLength, format.fillCharacter);
            }
        }
        break;

    case FormatSpecifier.Alignment.Right:
        const priorLength = output.length;

        prefixDel();
        mainDel();

        const completeLength = output.length;
        const diff = completeLength - priorLength;

        foreach (_; diff .. format.minimumWidth) {
            static if (is(Builder == StringBuilder_ASCII)) {
                output ~= [cast(ubyte)format.fillCharacter];
            } else {
                output ~= [format.fillCharacter];
            }
        }
        break;

    case FormatSpecifier.Alignment.Center:
        const priorLength = output.length;

        prefixDel();
        mainDel();

        const completeLength = output.length;
        const diff = completeLength - priorLength;

        foreach (_; diff .. (format.minimumWidth + 1) / 2) {
            static if (is(Builder == StringBuilder_ASCII)) {
                output.insert(priorLength, cast(ubyte)format.fillCharacter);
            } else {
                output.insert(priorLength, format.fillCharacter);
            }
        }

        foreach (_; diff .. (format.minimumWidth + 1) / 2) {
            static if (is(Builder == StringBuilder_ASCII)) {
                output ~= [cast(ubyte)format.fillCharacter];
            } else {
                output ~= [format.fillCharacter];
            }
        }
        break;

    case FormatSpecifier.Alignment.SignAwarePadding:
        const priorLength = output.length;

        prefixDel();
        const priorLength2 = output.length;

        mainDel();

        const completeLength = output.length;
        const diff = completeLength - priorLength;

        foreach (_; diff .. format.minimumWidth) {
            static if (is(Builder == StringBuilder_ASCII)) {
                output.insert(priorLength2, cast(ubyte)format.fillCharacter);
            } else {
                output.insert(priorLength2, format.fillCharacter);
            }
        }
        break;
    }
}

bool writeIntegral(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) {
    if (format.alignment == FormatSpecifier.Alignment.None) {
        format.alignment = FormatSpecifier.Alignment.SignAwarePadding;
        format.fillCharacter = '0';
    }

    string alphabet = "0123456789ABCDEF";
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
    case FormatSpecifier.Type.HexCapital:
        base = 16;
        break;

    case FormatSpecifier.Type.Hex:
        alphabet = "0123456789abcdef";
        base = 16;
        break;
    }

    handleFill(output, format, () {
        addSign(output, format, input >= 0);

        if (format.useAlternativeForm) {
            addPrefix(output, format);
        }
    }, () {
        const priorLength = output.length;
        bool doneOnce;

        if (input < 0)
            input *= -1;

        while (input != 0 || !doneOnce) {
            auto digit = input % base;

            static if (is(Builder == StringBuilder_ASCII)) {
                output.insert(cast(long)priorLength, cast(ubyte)alphabet[digit]);
            } else {
                output.insert(cast(long)priorLength, cast(dchar)alphabet[digit]);
            }

            input /= base;
            doneOnce = true;
        }

        if (format.type == FormatSpecifier.Type.Hex || format.type == FormatSpecifier.Type.HexCapital) {
            if ((output.length - priorLength) % 2 == 1) {
                // make sure that we have at least mod 2 characters
                output.insert(priorLength, "0"c);
            }
        }
    });

    return true;
}

bool writeBool(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) {
    if (format.type == FormatSpecifier.Type.Default) {
        // true/false
        handleFill(output, format, () {}, () { output ~= input ? "true"c : "false"c; });
    } else {
        // 1/0
        return writeIntegral(output, cast(int)input, format);
    }

    return true;
}

bool writeChar(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) {
    static if (isASCII!Input) {
        if (input >= 128)
            return false;

        handleFill(output, format, () {}, () { output ~= [cast(ubyte)input]; });
    } else {
        handleFill(output, format, () {}, () { output ~= [input]; });
    }

    return true;
}

bool writeFloat(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    import core.stdc.stdio : snprintf;

    if (format.alignment == FormatSpecifier.Alignment.None) {
        format.alignment = FormatSpecifier.Alignment.SignAwarePadding;
        format.fillCharacter = '0';
    }

    static if (is(Input == double) || is(Input == real)) {
        enum FormatSize = "l";
    } else {
        enum FormatSize = "";
    }

    enum FormatDefault = 'f';

    static immutable char[__traits(allMembers, FormatSpecifier.Type).length] Formats = [
        FormatDefault, FormatDefault, FormatDefault, FormatDefault, FormatDefault, FormatDefault, FormatDefault, 'f',
        'a', 'A', 'e', 'E', 'g', 'G', FormatDefault
    ];

    char[64] formatText = void, buffer;

    {
        size_t used = 1;
        formatText[0] = '%';

        if (format.precision > 0 && format.precision < int.max) {
            auto did = snprintf(&formatText[used], formatText.length - (used + 2), ".%d", format.precision);
            if (did > 0)
                used += did;
        }

        foreach (c; FormatSize) {
            formatText[used++] = c;
        }

        formatText[used++] = Formats[format.type];
        formatText[used++] = '\0';
    }

    static if (is(Input == double) || is(Input == real)) {
        auto did = snprintf(buffer.ptr, buffer.length, formatText.ptr, cast(double)input);
    } else {
        auto did = snprintf(buffer.ptr, buffer.length, formatText.ptr, cast(float)input);
    }

    if (did <= 0)
        return false;

    char[] prefix, bufferUsed = buffer[0 .. did];
    bool haveSign;

    {
        size_t prefixLength;

        if (did > 0) {
            if (bufferUsed[0] == '-' || bufferUsed[0] == '+') {
                haveSign = true;
                prefixLength++;
            }
        }

        if (did - prefixLength > 1 && (format.type == FormatSpecifier.Type.Hex || format.type == FormatSpecifier.Type.HexCapital)) {
            if (bufferUsed[prefixLength] == '0' && bufferUsed[prefixLength + 1] == 'x') {
                prefixLength += 2;
            }
        }

        prefix = bufferUsed[0 .. prefixLength];
        bufferUsed = bufferUsed[prefixLength .. $];
    }

    handleFill(output, format, () {
        if (!haveSign)
            addSign(output, format, !(input < 0));
        output ~= prefix;
    }, () { output ~= bufferUsed; });
    return true;
}
