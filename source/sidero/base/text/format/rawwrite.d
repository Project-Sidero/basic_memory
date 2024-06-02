module sidero.base.text.format.rawwrite;
import sidero.base.text.format.specifier;
import sidero.base.text.unicode.characters.defs;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.traits;
import sidero.base.allocators;
import sidero.base.errors;

export @safe nothrow @nogc:

///
bool rawWrite(Builder, Input)(return scope ref Builder output, scope Input input,
        scope FormatSpecifier format = FormatSpecifier.init, bool quote = false) @trusted if (isBuilderString!Builder) {
    alias ActualType = Unqual!Input;

    static if(!is(ActualType == Input)) {
        return rawWrite(output, () @trusted { return cast(ActualType)input; }(), format);
    } else {
        if(output.isNull)
            output = Builder(globalAllocator());

        enum IsStaticArray = isStaticArray!ActualType;
        enum StaticArrayString = IsStaticArray && isSomeString!(typeof(ActualType.init[]));

        static if(is(Input == enum)) {
            return writeEnum(output, input, format);
        } else static if(is(Input == bool)) {
            return writeBool(output, input, format);
        } else static if(is(Input == char) || (isUTF!Builder && (is(Input == wchar) || is(Input == dchar)))) {
            return writeChar(output, input, format, quote);
        } else static if(isPointer!Input || is(Input == function) || is(Input == delegate)) {
            return writePointer(output, input, format);
        } else static if(__traits(isIntegral, Input)) {
            return writeIntegral(output, input, format);
        } else static if(__traits(isFloating, Input)) {
            return writeFloat(output, input, format);
        } else static if(isASCII!Input || (isUTFBuilder!Builder && (isUTF!Input || isSomeString!Input || StaticArrayString))) {
            return writeString(output, input, format, quote);
        } else static if(is(Input : Result!WrappedType, WrappedType) || is(Input : ResultReference!WrappedType, WrappedType)) {
            return writeError!WrappedType(output, input, format, quote);
        } else static if(is(Input == Expected)) {
            return writeExpected(output, input.wanted, input.get);
        } else static if(isAssociativeArray!Input) {
            return writeAA(output, input, format);
        } else static if(is(Input == struct) || is(Input == class)) {
            return writeStructClass(output, input, format);
        } else static if(IsStaticArray) {
            return writeIterable(output, input[], format);
        } else static if(isDynamicArray!Input || (isIterable!Input && !(HaveNonStaticOpApply!ActualType ||
                __traits(hasMember, ActualType, "opApply")))) {
            return writeIterable(output, input, format);
        } else static if(is(Input == union)) {
            return writeUnion(output, input);
        } else static if(is(Input == interface)) {
            return writeInterface(output, input);
        } else {
            static assert(0, Input.stringof ~ " cannot be written.");
        }
    }
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

///
@trusted unittest {
    StringBuilder_UTF8 builder;

    assert(rawWrite(builder, cast(void*)0xFF0022, FormatSpecifier.from("{:#X}")));
    assert(builder == "0xFF0022");

    assert(rawWrite(builder, cast(void*)null, FormatSpecifier.from("{}")));
    assert(builder == "0xFF0022null");

    assert(rawWrite(builder, cast(void*)null, FormatSpecifier.from("{:d}")));
    assert(builder == "0xFF0022null0");

    assert(rawWrite(builder, "Hi there!", FormatSpecifier.from("{:}")));
    assert(builder == "0xFF0022null0Hi there!");
}

///
unittest {
    StringBuilder_UTF8 builder;

    enum E1 : int {
        A = 1,
        B = 3,
        Z = 2
    }

    assert(rawWrite(builder, E1.B, FormatSpecifier.from("{}")));
    assert(builder == "E1.B");

    assert(rawWrite(builder, cast(E1)99, FormatSpecifier.from("{}")));
    assert(builder == "E1.BE1(99)");
}

///
unittest {
    StringBuilder_UTF8 builder;

    assert(rawWrite(builder, Result!int(22), FormatSpecifier.from("{}")));
    assert(builder == "22");

    assert(rawWrite(builder, Expected(1, 0), FormatSpecifier.from("{}")));
    assert(builder == "22Expected(wanted: 1 != got: 0)");

    assert(rawWrite(builder, Result!int(NullPointerException), FormatSpecifier.from("{}")));
}

///
unittest {
    StringBuilder_UTF8 builder;

    assert(rawWrite(builder, [1, 2, 3], FormatSpecifier.from("{}")));
    assert(builder == "[1, 2, 3]");

    assert(rawWrite(builder, ["Hello", "There!"], FormatSpecifier.from("{}")));
    assert(builder == "[1, 2, 3][\"Hello\", \"There!\"]");

    debug {
        assert(rawWrite(builder, [22: "D", 51: "Z"], FormatSpecifier.from("{}")));
        assert(builder == "[1, 2, 3][\"Hello\", \"There!\"][22: \"D\", 51: \"Z\"]" ||
                builder == "[1, 2, 3][\"Hello\", \"There!\"][51: \"Z\", 22: \"D\"]");
    }
}

///
unittest {
    StringBuilder_UTF8 builder;

    union U1 {
        ubyte[4] i;
    }

    assert(rawWrite(builder, U1([0xDE, 0xAD, 0xBE, 0xEF]), FormatSpecifier.from("{}")));
    assert(builder == "U1(0xDEADBEEF)");
}

///
@trusted unittest {
    StringBuilder_UTF8 builder;

    interface I1 {
    }

    class C1 : I1 {
    }

    __gshared clasz = new C1;

    assert(rawWrite(builder, cast(I1)clasz, FormatSpecifier.from("{}")));
    assert(builder.startsWith("I1@"));
}

///
@trusted unittest {
    StringBuilder_UTF8 builder;

    struct S1 {
        int x;
        bool z;
    }

    static struct S2 {
        int x;

        string toString() @safe nothrow @nogc {
            return "Hi there!";
        }
    }

    interface I1 {
    }

    class C1 : I1 {
        int x;
    }

    __gshared clasz = new C1;

    assert(rawWrite(builder, S1(1, false), FormatSpecifier.from("{}")));
    assert(builder == "S1(1, false)");

    assert(rawWrite(builder, S2(11), FormatSpecifier.from("{}")));
    assert(builder == "S1(1, false)S2(11 -> Hi there!)");

    assert(rawWrite(builder, clasz, FormatSpecifier.from("{}")));
}

///
unittest {
    StringBuilder_UTF8 builder;

    static struct S1 {
        int x;

        bool formattedWrite(scope ref StringBuilder_ASCII builder, scope FormatSpecifier format) @safe nothrow @nogc {
            return false;
        }

        bool formattedWrite(scope ref StringBuilder_UTF8 builder, scope FormatSpecifier format) @safe nothrow @nogc {
            if(x == 0 || format.fullFormatSpec.length == 0)
                return false;

            builder ~= format.fullFormatSpec;
            return true;
        }
    }

    assert(rawWrite(builder, S1(64), FormatSpecifier.from("{:custom}")));
    assert(builder == "S1(custom)");

    assert(rawWrite(builder, S1(0), FormatSpecifier.from("{:custom}")));
    assert(builder == "S1(custom)S1(0)");
}

/*private:*/
import sidero.base.text.format.write;
import sidero.base.text.format.escaping;

bool addSign(Builder)(scope ref Builder output, scope FormatSpecifier format, bool positive) {
    final switch(format.sign) {
    case FormatSpecifier.Sign.NegativeOnly:
        if(!positive) {
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
    final switch(format.type) {
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

    case FormatSpecifier.Type.Pointer: /// 0x
    case FormatSpecifier.Type.Hex: // 0x
    case FormatSpecifier.Type.HexCapital: /// 0x
        output ~= "0x";
        break;
    }
}

void handleFill(Builder)(scope ref Builder output, scope FormatSpecifier format,
        scope void delegate() @safe nothrow @nogc prefixDel, scope void delegate() @safe nothrow @nogc mainDel) @trusted {

    final switch(format.alignment) {
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

        foreach(_; diff .. format.minimumWidth) {
            static if(is(Builder == StringBuilder_ASCII)) {
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

        foreach(_; diff .. format.minimumWidth) {
            static if(is(Builder == StringBuilder_ASCII)) {
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

        foreach(_; diff .. (format.minimumWidth + 1) / 2) {
            static if(is(Builder == StringBuilder_ASCII)) {
                output.insert(priorLength, cast(ubyte)format.fillCharacter);
            } else {
                output.insert(priorLength, format.fillCharacter);
            }
        }

        foreach(_; diff .. (format.minimumWidth + 1) / 2) {
            static if(is(Builder == StringBuilder_ASCII)) {
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

        foreach(_; diff .. format.minimumWidth) {
            static if(is(Builder == StringBuilder_ASCII)) {
                output.insert(priorLength2, cast(ubyte)format.fillCharacter);
            } else {
                output.insert(priorLength2, format.fillCharacter);
            }
        }
        break;
    }
}

bool writeIntegral(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) {
    import sidero.base.traits : isSigned;

    if(format.alignment == FormatSpecifier.Alignment.None) {
        format.alignment = FormatSpecifier.Alignment.SignAwarePadding;
        format.fillCharacter = '0';
    }

    string alphabet = "0123456789ABCDEF";
    ubyte base;

    final switch(format.type) {
    case FormatSpecifier.Type.Float:
    case FormatSpecifier.Type.FloatHex:
    case FormatSpecifier.Type.FloatHexCapital:
    case FormatSpecifier.Type.FloatScientific:
    case FormatSpecifier.Type.FloatScientificCapital:
    case FormatSpecifier.Type.FloatShortest:
    case FormatSpecifier.Type.FloatShortestCapital:
        return false;

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

    case FormatSpecifier.Type.Pointer:
    case FormatSpecifier.Type.HexCapital:
        base = 16;
        break;

    case FormatSpecifier.Type.Hex:
        alphabet = "0123456789abcdef";
        base = 16;
        break;
    }

    handleFill(output, format, () @trusted {
        addSign(output, format, input >= 0);

        if(format.useAlternativeForm) {
            addPrefix(output, format);
        }
    }, () @trusted {
        assert(base > 0);
        assert(base < 17);
        assert(base <= alphabet.length);
        assert(alphabet.length >= base);

        const priorLength = output.length;
        bool doneOnce;

        while(input != 0 || !doneOnce) {
            auto digit = input % base;

            static if(isSigned!Input) {
                // if we do this outside, Input.min won't work
                if(digit < 0)
                    digit = -digit;
            }

            assert(digit >= 0);
            assert(digit < base);

            static if(is(Builder == StringBuilder_ASCII)) {
                output.insert(cast(ptrdiff_t)priorLength, cast(ubyte)alphabet[digit]);
            } else {
                output.insert(cast(ptrdiff_t)priorLength, cast(dchar)alphabet[digit]);
            }

            input /= base;
            doneOnce = true;
        }

        if(format.type == FormatSpecifier.Type.Hex || format.type == FormatSpecifier.Type.HexCapital) {
            if((output.length - priorLength) % 2 == 1) {
                // make sure that we have at least mod 2 characters
                output.insert(priorLength, "0"c);
            }
        }
    });

    return true;
}

bool writeBool(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) {
    if(format.type == FormatSpecifier.Type.Default) {
        // true/false
        handleFill(output, format, () {}, () { output ~= input ? "true"c : "false"c; });
    } else {
        // 1/0
        return writeIntegral(output, cast(int)input, format);
    }

    return true;
}

bool writeChar(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format, bool quote) {
    if(quote)
        output ~= "'"c;

    static if(isASCII!Input) {
        if(input >= 128)
            return false;

        if(quote) {
            handleFill(output, format, () {}, () { quoteChar(output, cast(ubyte)input); });
        } else {
            handleFill(output, format, () {}, () { output ~= [cast(ubyte)input]; });
        }
    } else {
        if(quote) {
            handleFill(output, format, () {}, () { quoteChar(output, input); });
        } else {
            handleFill(output, format, () {}, () { output ~= [input]; });
        }
    }

    if(quote)
        output ~= "'"c;
    return true;
}

bool writeFloat(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    import core.stdc.stdio : snprintf;

    if(format.alignment == FormatSpecifier.Alignment.None) {
        format.alignment = FormatSpecifier.Alignment.SignAwarePadding;
        format.fillCharacter = '0';
    }

    static if(is(Input == double) || is(Input == real)) {
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

        if(format.precision > 0 && format.precision < int.max) {
            auto did = snprintf(&formatText[used], formatText.length - (used + 2), ".%d", format.precision);
            if(did > 0)
                used += did;
        }

        foreach(c; FormatSize) {
            formatText[used++] = c;
        }

        formatText[used++] = Formats[format.type];
        formatText[used++] = '\0';
    }

    static if(is(Input == double) || is(Input == real)) {
        auto did = snprintf(buffer.ptr, buffer.length, formatText.ptr, cast(double)input);
    } else {
        auto did = snprintf(buffer.ptr, buffer.length, formatText.ptr, cast(float)input);
    }

    if(did <= 0)
        return false;

    char[] prefix, bufferUsed = buffer[0 .. did];
    bool haveSign;

    {
        size_t prefixLength;

        if(did > 0) {
            if(bufferUsed[0] == '-' || bufferUsed[0] == '+') {
                haveSign = true;
                prefixLength++;
            }
        }

        if(did - prefixLength > 1 && (format.type == FormatSpecifier.Type.Hex || format.type == FormatSpecifier.Type.HexCapital)) {
            if(bufferUsed[prefixLength] == '0' && bufferUsed[prefixLength + 1] == 'x') {
                prefixLength += 2;
            }
        }

        prefix = bufferUsed[0 .. prefixLength];
        bufferUsed = bufferUsed[prefixLength .. $];
    }

    handleFill(output, format, () {
        if(!haveSign)
            addSign(output, format, !(input < 0));
        output ~= prefix;
    }, () { output ~= bufferUsed; });
    return true;
}

bool writePointer(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    bool useNullText;

    if(format.type == FormatSpecifier.Type.Default) {
        format.type = FormatSpecifier.Type.HexCapital;
        format.useAlternativeForm = true;
        useNullText = true;
    } else if(format.type == FormatSpecifier.Type.Pointer) {
        format.type = FormatSpecifier.Type.HexCapital;
        useNullText = true;
    }

    if(useNullText && input is null) {
        output ~= "null"c;
        return true;
    }

    static if(is(Input == delegate)) {
        size_t pointer = cast(size_t)input.funcptr;
    } else {
        size_t pointer = cast(size_t)input;
    }

    if(writeIntegral(output, pointer, format)) {
        if(input !is null) {
            static if(isFunctionPointer!Input) {
                static if(is(Input == delegate)) {
                    output ~= "("c;

                    if(useNullText && input is null) {
                        output ~= "null"c;
                    } else {
                        writeIntegral(output, cast(size_t)input.ptr, format);
                    }

                    output ~= ")"c;
                }
            } else static if(__traits(compiles, typeof(*(Input.init)))) {
                alias PointerAt = typeof(*(Input.init));

                static if(isCopyable!PointerAt) {
                    output ~= "("c;
                    formattedWriteImpl(output, String_UTF32.init, true, *input);
                    output ~= ")"c;
                }
            }
        }

        return true;
    }

    return false;
}

bool writeEnum(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    output ~= __traits(identifier, Input);

    {
        auto tempInput = cast(OriginalType!Input)input;

        static foreach(m; __traits(allMembers, Input)) {
            if(__traits(getMember, Input, m) == input) {
                output ~= "."c;
                output ~= m;
                goto Done;
            }
        }

        // backup if it didn't occur, lets print out whatever the value is
        output ~= "("c;
        formattedWriteImpl(output, String_UTF32.init, true, tempInput);
        output ~= ")"c;
    }

Done:
    return true;
}

bool writeString(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format, bool quote) @trusted {
    if(quote) {
        output ~= "\""c;

        foreach(c; input) {
            quoteChar(output, c);
        }

        output ~= "\""c;
    } else
        output ~= input;

    return true;
}

bool writeError(WrappedType, Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format, bool quote) @trusted {
    if(input) {
        // ok print the thing

        if(input.isNull) {
            output ~= "no-error but null"c;
        } else static if(is(WrappedType == void)) {
            output ~= "no-error"c;
        } else {
            WrappedType* wrapped = &input.assumeOkay();
            formattedWriteImpl(output, String_UTF32.init, true, *wrapped);
        }
    } else {
        output ~= "error: "c;

        output ~= input.getError.info.id;
        output ~= ":"c;
        output ~= input.getError.info.message;

        output ~= "`"c;
        output ~= input.getError.moduleName;
        output ~= ":"c;
        writeIntegral(output, input.getError.line, FormatSpecifier.init);
        output ~= "`"c;
    }

    return true;
}

bool writeExpected(Builder)(scope ref Builder output, size_t wanted, size_t got) @trusted {
    if(wanted != got) {
        output ~= "Expected(wanted: "c;
        writeIntegral(output, wanted, FormatSpecifier.init);

        output ~= " != got: "c;
        writeIntegral(output, got, FormatSpecifier.init);

        output ~= ")"c;
    } else {
        output ~= "Expected("c;
        writeIntegral(output, wanted, FormatSpecifier.init);
        output ~= ")"c;
    }

    return true;
}

bool writeIterable(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    if(format.useIterableCharacters) {
        if(format.iterableStartCharacter != notACharacter)
            output ~= [format.iterableStartCharacter];
    } else
        output ~= "["c;

    size_t i;

    static if(isDynamicArray!Input) {
        alias SubType = Unqual!(typeof(input[0]));

        static if(is(SubType == void)) {
        } else {
            foreach(v; cast(SubType[])input[]) {
                if(i++ > 0) {
                    if(format.useIterableCharacters) {
                        if(format.iterableDividerCharacter != notACharacter)
                            output ~= [format.iterableDividerCharacter];
                    } else
                        output ~= ","c;

                    output ~= " "c;
                }

                formattedWriteImpl(output, format.innerFormatSpec, true, v);
            }
        }
    } else {
        foreach(v; input) {
            if(i++ > 0) {
                if(format.useIterableCharacters) {
                    if(format.iterableDividerCharacter != notACharacter)
                        output ~= [format.iterableDividerCharacter];
                } else
                    output ~= ","c;

                output ~= " "c;
            }

            formattedWriteImpl(output, format.innerFormatSpec, true, v);
        }
    }

    if(format.useIterableCharacters) {
        if(format.iterableEndCharacter != notACharacter)
            output ~= [format.iterableEndCharacter];
    } else
        output ~= "]"c;
    return true;
}

bool writeAA(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    if(format.useIterableCharacters) {
        if(format.iterableStartCharacter != notACharacter)
            output ~= [format.iterableStartCharacter];
    } else
        output ~= "["c;

    bool isFirst = true;

    version(D_BetterC) {
    } else {
        try {
            foreach(key, value; input) {
                if(isFirst)
                    isFirst = false;
                else {
                    if(format.useIterableCharacters) {
                        if(format.iterableDividerCharacter != notACharacter)
                            output ~= [format.iterableDividerCharacter];
                    } else
                        output ~= ","c;

                    output ~= " "c;
                }

                formattedWriteImpl(output, String_UTF32.init, true, key);
                output ~= ": "c;
                formattedWriteImpl(output, String_UTF32.init, true, value);
            }
        } catch(Exception) {
        }
    }

    if(format.useIterableCharacters) {
        if(format.iterableEndCharacter != notACharacter)
            output ~= [format.iterableEndCharacter];
    } else
        output ~= "]"c;
    return true;
}

bool writeUnion(Builder, Input)(scope ref Builder output, scope Input input) @trusted {
    output ~= __traits(identifier, Input) ~ "(";

    size_t leftToGo = Input.sizeof;
    ubyte* ptr = cast(ubyte*)&input;

    output ~= "0x"c;
    FormatSpecifier format = FormatSpecifier.from(String_UTF8("{:X}"));

    while(leftToGo > 0) {
        writeIntegral(output, *ptr, format);

        ptr++;
        leftToGo--;
    }

    output ~= ")"c;
    return true;
}

bool writeInterface(Builder, Input)(scope ref Builder output, scope Input input) @trusted {
    output ~= __traits(identifier, Input) ~ "@"c;

    if(input is null) {
        output ~= "null"c;
    } else {
        writePointer(output, cast(void*)input, FormatSpecifier.init);
    }

    return true;
}

bool writeStructClass(Builder, Input)(scope ref Builder output, scope Input input, scope FormatSpecifier format) @trusted {
    import std.meta;

    enum haveToString(T) = __traits(hasMember, T, "toString") && (__traits(compiles, {
                Builder builder;
                T value;
                value.toString(builder);
            }) || __traits(compiles, { Builder builder; T value; builder ~= value.toString(); }) || __traits(compiles, {
                Builder builder;
                T value;
                value.toString(&builder.put);
            }));
    enum haveFormattedWrite = __traits(compiles, {
            Builder builder;
            Input value;
            bool got = value.formattedWrite(builder, FormatSpecifier.init);
        });

    output ~= __traits(identifier, Input);

    static if(is(Input == class)) {
        if(input is null) {
            output ~= "null"c;
        } else {
            writePointer(output, cast(void*)input, FormatSpecifier.init);
        }
    }

    output ~= "("c;
    bool isFirst = true, customPrinted;

    static if(haveFormattedWrite) {
        const priorLength = output.length;

        static if(__traits(hasMember, Input, "DefaultFormat")) {
            if(format.fullFormatSpec.length == 0)
                format.fullFormatSpec = Input.DefaultFormat;
        }

        if(input.formattedWrite(output, format)) {
            // ok
            customPrinted = true;
        } else if(output.length > priorLength) {
            // rollback
            output.remove(priorLength, ptrdiff_t.max);
        }
    }

    if(!customPrinted) {
        static foreach(name; FieldNameTuple!Input) {
            {
                alias member = __traits(getMember, input, name);
                bool ignore;

                foreach(attr; __traits(getAttributes, member)) {
                    ignore = ignore || is(attr == PrintIgnore) || is(attr == PrettyPrintIgnore);
                }

                static foreach(name2; FieldNameTuple!Input) {
                    {
                        alias member2 = __traits(getMember, input, name2);

                        if(name != name2) {
                            ignore = ignore || member.offsetof == member2.offsetof;
                        }
                    }
                }

                if(!ignore) {
                    if(!isFirst)
                        output ~= ", "c;
                    else
                        isFirst = false;

                    formattedWriteImpl(output, String_UTF32.init, true, __traits(getMember, input, name));
                }
            }
        }

        static if(is(Input == class)) {
            static foreach_reverse(i, Base; BaseClassesTuple!Input) {
                static foreach(name; FieldNameTuple!Base) {
                    {
                        alias member = __traits(getMember, cast(Base)input, name);
                        bool ignore;

                        foreach(attr; __traits(getAttributes, member)) {
                            ignore = ignore || is(attr == PrintIgnore) || is(attr == PrettyPrintIgnore);
                        }

                        static foreach(name2; FieldNameTuple!Base) {
                            {
                                alias member2 = __traits(getMember, cast(Base)input, name2);

                                if(name != name2) {
                                    ignore = ignore || member.offsetof == member2.offsetof;
                                }
                            }
                        }

                        if(!ignore) {
                            if(!isFirst)
                                output ~= ", "c;
                            else
                                isFirst = false;

                            formattedWrite(output, FormatSpecifier.init, true, __traits(getMember, cast(Base)input, name));
                        }
                    }
                }
            }
        }

        static if(haveToString!Input) {
            {
                bool hadToString;
                alias Symbols = __traits(getOverloads, Input, "toString");

                static foreach(SymbolId; 0 .. Symbols.length) {
                    {
                        alias gotUDAs = Filter!(isDesiredUDA!PrintIgnore, __traits(getAttributes, Symbols[SymbolId]));
                        alias gotUDAsPretty = Filter!(isDesiredUDA!PrettyPrintIgnore, __traits(getAttributes, Symbols[SymbolId]));

                        if(!hadToString) {
                            static if(gotUDAs.length == 0 && gotUDAsPretty.length == 0) {
                                const offsetForToString = output.length;
                                const hadOpenBracket = output.endsWith("("c);

                                static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(output))) {
                                    __traits(child, input, Symbols[SymbolId])(output);
                                    hadToString = true;
                                } else static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(&output.put))) {
                                    __traits(child, input, Symbols[SymbolId])(&output.put);
                                    hadToString = true;
                                } else static if(__traits(compiles, output ~= __traits(child, input, Symbols[SymbolId])())) {
                                    output ~= __traits(child, input, Symbols[SymbolId])();
                                    hadToString = true;
                                }

                                if(hadToString && output.length > offsetForToString) {
                                    static FQN = __traits(fullyQualifiedName, Input);
                                    static TypeIdentifierName = __traits(identifier, Input);

                                    auto subset = output[offsetForToString .. $];

                                    if(subset == FQN) {
                                        output.remove(offsetForToString, FQN.length);
                                    } else if(subset.startsWith(TypeIdentifierName)) {
                                        output.remove(offsetForToString, TypeIdentifierName.length);

                                        if(subset.startsWith("(")) {
                                            output.remove(offsetForToString, 1);

                                            if(subset.endsWith(")"))
                                                subset.remove(-1, 1);
                                        }
                                    } else if(!hadOpenBracket)
                                        output.insert(offsetForToString, " -> "c);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    output ~= ")"c;
    return true;
}
