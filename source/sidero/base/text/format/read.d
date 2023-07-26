module sidero.base.text.format.read;
import sidero.base.text.format.specifier;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.traits;
import sidero.base.allocators;

export @safe nothrow @nogc:

///
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_UTF8.LiteralType formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);
    return formattedReadImpl(input, tempFormat, args);
}

/// Ditto
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_UTF16.LiteralType formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);
    return formattedReadImpl(input, tempFormat, args);
}

/// Ditto
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_UTF32.LiteralType formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);
    return formattedReadImpl(input, tempFormat, args);
}

/// Ditto
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_ASCII formatString, scope ref Args args) @trusted
        if (isUTF!Input || isASCII!Input) {
    return formattedReadImpl(input, String_UTF8(cast(const(char)[])formatString.unsafeGetLiteral()).byUTF32, args);
}

/// Ditto
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_UTF8 formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    return formattedReadImpl(input, formatString.byUTF32, args);
}

/// Ditto
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_UTF16 formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    return formattedReadImpl(input, formatString.byUTF32, args);
}

/// Ditto
Expected formattedRead(Input, Args...)(scope ref Input input, scope String_UTF32 formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    return formattedReadImpl(input, formatString, args);
}

///
unittest {
    int a, b;

    String_UTF8 input = String_UTF8("5432.AA");
    auto got = formattedRead(input, String_UTF8("{:d}.{:x}"), a, b);
    assert(got.get == 2);
    assert(a == 5432);
    assert(b == 170);
}

///
unittest {
    String_ASCII a;
    StringBuilder_UTF8 b;

    String_UTF8 input = String_UTF8("say hello\u2713 or this");
    auto got = formattedRead(input, String_UTF8("{:s}{:s}"), a, b);
    assert(got.get == 2);
    assert(a == "say hello"c);
    assert(b == "\u2713 or this"c);
}

private:

Expected formattedReadImpl(Input, Args...)(scope ref Input input, scope String_UTF32 formatString, scope ref Args args) @trusted {
    Input inputTemp = input.save;
    size_t successfullyHandled;

    bool handleArg(size_t id)(scope FormatSpecifier format) {
        import sidero.base.text.format.rawread;

        alias ArgType = Args[id];

        static if(isASCII!ArgType || isUTF!ArgType) {
            return formattedReadStringImpl(*&inputTemp, formatString, args[id]);
        } else
            return rawRead(*&inputTemp, args[id], format);
    }

    bool[Args.length] areArgsHandled;

    OuterLoop: while(successfullyHandled < Args.length || !formatString.empty) {
        size_t argId = size_t.max;

        foreach(id, b; areArgsHandled) {
            if(!b) {
                argId = id;
                break;
            }
        }

        {
            bool wasLeftBrace;
            while(!inputTemp.empty && !formatString.empty) {
                if(wasLeftBrace) {
                    if(!formatString.startsWith("{"))
                        break;

                    wasLeftBrace = false;
                    formatString.popFront;
                    continue;
                } else if(formatString.startsWith("{")) {
                    formatString.popFront;
                    wasLeftBrace = true;
                    continue;
                }

                static if(isASCII!Input) {
                    auto c2 = formatString.front;
                    ubyte c;
                    if(c2 >= 128)
                        goto FailStartsWith;
                    c = cast(ubyte)c2;
                } else {
                    auto c = formatString.front;
                }

                if(inputTemp.startsWith([c])) {
                    inputTemp.popFront;
                    formatString.popFront;
                    continue;
                }

            FailStartsWith:
                if(successfullyHandled > 0) {
                    successfullyHandled--;
                    break OuterLoop;
                } else
                    break OuterLoop;
            }

            if(inputTemp.empty && !formatString.empty) {
                if(successfullyHandled > 0) {
                    successfullyHandled--;
                    break OuterLoop;
                } else
                    break OuterLoop;
            }
        }

        FormatSpecifier format = !formatString.empty ? FormatSpecifier.from(formatString, true) : FormatSpecifier.init;
        if(format.argId >= 0)
            argId = format.argId;

    ArgSwitch:
        switch(argId) {
        case size_t.max:
            break ArgSwitch;

            static foreach(I; 0 .. Args.length) {
        case I:
                if(handleArg!I(format)) {
                    if(!areArgsHandled[argId]) {
                        areArgsHandled[argId] = true;
                        successfullyHandled++;
                    }
                    break ArgSwitch;
                } else
                    break OuterLoop;
            }

        default:
            break OuterLoop;
        }

        input = inputTemp.save;
        inputTemp = input;
    }

    return Expected(Args.length, successfullyHandled);
}

bool formattedReadStringImpl(Input, ArgType)(scope ref Input input, scope ref String_UTF32 formatString, scope ref ArgType output) @trusted {
    String_UTF32 possibleEndCondition;

    {
        bool wasLeftBrace;

        String_UTF32 tempFormat = formatString.save;
        ptrdiff_t potentialLength = ptrdiff_t.max;

        while(!tempFormat.empty) {
            if(wasLeftBrace) {
                if(!tempFormat.startsWith("{")) {
                    potentialLength = tempFormat.length;
                    break;
                }

                wasLeftBrace = false;
                tempFormat.popFront;
            } else if(tempFormat.startsWith("{")) {
                tempFormat.popFront;
                wasLeftBrace = true;
            } else
                break;
        }

        possibleEndCondition = formatString[0 .. potentialLength];
    }

    static if(isASCII!ArgType) {
        // disallow any char above 128

        String_UTF32 tempPEC = possibleEndCondition.save;

        while(!tempPEC.empty) {
            dchar c = tempPEC.front;

            if(c >= 128) {
                possibleEndCondition = possibleEndCondition[0 .. -tempPEC.length];
                break;
            }

            tempPEC.popFront;
        }
    }

    Input toCopy;

    {
        ptrdiff_t index = input.indexOf(possibleEndCondition);

        static if(isASCII!ArgType) {
            const canDo = index >= 0 ? index : input.length;
            size_t willDo;

            foreach(c; input[0 .. canDo]) {
                if(c >= 128)
                    break;
                willDo++;
            }

            if(willDo == input.length) {
                toCopy = input;
                input = Input.init;
            } else {
                toCopy = input[0 .. willDo];
                input = input[willDo .. $];
            }
        } else {
            if(index < 0) {
                toCopy = input;
                input = Input.init;
            } else {
                toCopy = input[0 .. index];
                input = input[index .. $];
            }
        }
    }

    static if(isASCII!ArgType) {
        static if(is(ArgType == String_ASCII)) {
            StringBuilder_ASCII builder = StringBuilder_ASCII();
        } else {
            StringBuilder_ASCII builder = output;
        }

        foreach(c; toCopy) {
            builder ~= [cast(ubyte)c];
        }

        static if(is(ArgType == String_ASCII)) {
            output = builder.asReadOnly();
        }

        return true;
    } else static if(isUTF!ArgType) {
        static if(is(ArgType == String_UTF8)) {
            auto builder = StringBuilder_UTF8();
        } else static if(is(ArgType == String_UTF16)) {
            auto builder = StringBuilder_UTF16();
        } else static if(is(ArgType == String_UTF32)) {
            auto builder = StringBuilder_UTF32();
        } else {
            auto builder = output;
        }

        const assign = builder.isNull;
        builder ~= toCopy;

        static if(isUTFReadOnly!ArgType) {
            output = builder.asReadOnly();
        } else if(assign) {
            output = builder;
        }

        return true;
    } else
        static assert(0);
}
