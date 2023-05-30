module sidero.base.text.format.write;
import sidero.base.text.format.specifier;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.traits;
import sidero.base.allocators;

export @safe nothrow @nogc:

///
StringBuilder_UTF8 formattedWrite(Args...)(scope String_ASCII formatString, scope Args args) {
    StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
    return formattedWriteImpl(ret, String_UTF8(cast(const(char)[])formatString.unsafeGetLiteral()).byUTF32, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(scope String_UTF8 formatString, scope Args args) @trusted {
    StringBuilder_UTF8 ret = StringBuilder_UTF8(globalAllocator());
    return formattedWriteImpl(ret, formatString.byUTF32, args);
}

///
StringBuilder_UTF16 formattedWrite(Args...)(scope String_UTF16 formatString, scope Args args) @trusted {
    StringBuilder_UTF16 ret = StringBuilder_UTF16(globalAllocator());
    return formattedWriteImpl(ret, formatString.byUTF32, args);
}

///
StringBuilder_UTF32 formattedWrite(Args...)(scope String_UTF32 formatString, scope Args args) @trusted {
    StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
    return formattedWriteImpl(ret, formatString.byUTF32, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(scope return ref StringBuilder_ASCII output, scope String_ASCII formatString, scope Args args) {
    return formattedWriteImpl(output, String_UTF8(cast(const(char)[])formatString.unsafeGetLiteral()).byUTF32, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(scope return ref StringBuilder_UTF8 output, scope String_UTF8 formatString, scope Args args) {
    return formattedWriteImpl(output, formatString.byUTF32, args);
}

///
StringBuilder_UTF16 formattedWrite(Args...)(scope return ref StringBuilder_UTF16 output, scope String_UTF16 formatString, scope Args args) {
    return formattedWriteImpl(output, formatString.byUTF32, args);
}

///
StringBuilder_UTF32 formattedWrite(Args...)(scope return ref StringBuilder_UTF32 output, scope String_UTF32 formatString, scope Args args) {
    return formattedWriteImpl(output, formatString, args);
}

///
unittest {
    assert(formattedWrite(String_UTF8("{1:.1f} {:s}: {:s}"), 1, -1234.0, String_UTF8("success")) == "-1234.0 1: success");
}

private:

Builder formattedWriteImpl(Builder, Args...)(return scope ref Builder output, scope String_UTF32 formatString, scope Args args) @trusted {
    bool handleArg(size_t id)(scope FormatSpecifier format) {
        import sidero.base.text.format.rawwrite;

        alias ArgType = Args[id];

        static if (isASCII!ArgType) {
            output ~= args[id];
            return true;
        } else static if (isUTFBuilder!Builder && isUTF!ArgType) {
            output ~= args[id];
            return true;
        } else
            return rawWrite(output, args[id], format);
    }

    bool[Args.length] areArgsHandled;

    OuterLoop: while (!formatString.empty) {
        size_t argId;

        foreach (id, b; areArgsHandled) {
            if (!b) {
                argId = id;
                break;
            }
        }

        {
            size_t soFar;
            bool wasLeftBrace;

            foreach (c; formatString) {
                if (wasLeftBrace) {
                    if (c == '{') {
                        wasLeftBrace = false;
                        soFar++;
                    } else {
                        soFar--;
                        break;
                    }
                } else if (c == '{') {
                    wasLeftBrace = true;
                    soFar++;
                } else {
                    soFar++;
                }
            }

            static if (is(Builder == StringBuilder_ASCII)) {
                foreach (c; formatString[0 .. soFar]) {
                    output ~= [cast(ubyte)c];
                }
            } else {
                output ~= formatString[0 .. soFar];
            }

            if (formatString.length > soFar)
                formatString = formatString[soFar .. $];
            else
                formatString = String_UTF32.init;
        }

        FormatSpecifier format;

        if (!formatString.empty) {
            format = FormatSpecifier.from(formatString, false);

            if (format.argId >= 0)
                argId = format.argId;
        }

    ArgSwitch:
        switch (argId) {
            static foreach (I; 0 .. Args.length) {
        case I:
                if (handleArg!I(format)) {
                    break ArgSwitch;
                } else
                    break OuterLoop;
            }

        default:
            break OuterLoop;
        }

        areArgsHandled[argId] = true;
    }

    return output;
}
