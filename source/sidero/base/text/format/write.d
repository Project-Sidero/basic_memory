module sidero.base.text.format.write;
import sidero.base.text.format.specifier;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.traits;
import sidero.base.allocators;

export @safe nothrow @nogc:

///
StringBuilder_UTF8 formattedWrite(Args...)(scope String_UTF8.LiteralType formatString, scope Args args) @trusted {
    scope String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);

    StringBuilder_UTF8 ret = StringBuilder_UTF8(globalAllocator());
    return formattedWriteImpl(ret, tempFormat, false, args);
}

///
StringBuilder_UTF16 formattedWrite(Args...)(scope String_UTF16.LiteralType formatString, scope Args args) @trusted {
    scope String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);

    StringBuilder_UTF16 ret = StringBuilder_UTF16(globalAllocator());
    return formattedWriteImpl(ret, tempFormat, false, args);
}

///
StringBuilder_UTF32 formattedWrite(Args...)(scope String_UTF32.LiteralType formatString, scope Args args) @trusted {
    scope String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);

    StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
    return formattedWriteImpl(ret, tempFormat, false, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(scope String_ASCII formatString, scope Args args) {
    StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
    return formattedWriteImpl(ret, String_UTF8(cast(const(char)[])formatString.unsafeGetLiteral()).byUTF32, false, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(scope String_UTF8 formatString, scope Args args) @trusted {
    StringBuilder_UTF8 ret = StringBuilder_UTF8(globalAllocator());
    return formattedWriteImpl(ret, formatString.byUTF32, false, args);
}

///
StringBuilder_UTF16 formattedWrite(Args...)(scope String_UTF16 formatString, scope Args args) @trusted {
    StringBuilder_UTF16 ret = StringBuilder_UTF16(globalAllocator());
    return formattedWriteImpl(ret, formatString.byUTF32, false, args);
}

///
StringBuilder_UTF32 formattedWrite(Args...)(scope String_UTF32 formatString, scope Args args) @trusted {
    StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
    return formattedWriteImpl(ret, formatString.byUTF32, false, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(return scope ref StringBuilder_UTF8 output,
        scope String_UTF8.LiteralType formatString, scope Args args) {
    scope String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);
    return formattedWriteImpl(output, tempFormat, false, args);
}

///
StringBuilder_UTF16 formattedWrite(Args...)(return scope ref StringBuilder_UTF16 output,
        scope String_UTF16.LiteralType formatString, scope Args args) {
    scope String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);
    return formattedWriteImpl(output, tempFormat, false, args);
}

///
StringBuilder_UTF32 formattedWrite(Args...)(return scope ref StringBuilder_UTF32 output,
        scope String_UTF32.LiteralType formatString, scope Args args) {
    scope String_UTF32 tempFormat;
    tempFormat.__ctor(formatString);
    return formattedWriteImpl(output, tempFormat, false, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(return scope ref StringBuilder_ASCII output, scope String_ASCII formatString, scope Args args) {
    return formattedWriteImpl(output, String_UTF8(cast(const(char)[])formatString.unsafeGetLiteral()).byUTF32, false, args);
}

///
StringBuilder_UTF8 formattedWrite(Args...)(return scope ref StringBuilder_UTF8 output, scope String_UTF8 formatString, scope Args args) {
    return formattedWriteImpl(output, formatString.byUTF32, false, args);
}

///
StringBuilder_UTF16 formattedWrite(Args...)(return scope ref StringBuilder_UTF16 output, scope String_UTF16 formatString, scope Args args) {
    return formattedWriteImpl(output, formatString.byUTF32, false, args);
}

///
StringBuilder_UTF32 formattedWrite(Args...)(return scope ref StringBuilder_UTF32 output, scope String_UTF32 formatString, scope Args args) {
    return formattedWriteImpl(output, formatString, false, args);
}

///
unittest {
    assert(formattedWrite(String_UTF8("{1:.1f} {:s}: {:s}"), 1, -1234.0, String_UTF8("success")) == "-1234.0 1: success");
}

//package(sidero.base.text.format):

Builder formattedWriteImpl(Builder, Args...)(return scope ref Builder output, scope String_UTF8 formatString, bool quote, scope Args args) @trusted {
    return formattedWriteImpl(output, formatString.byUTF32, quote, args);
}

Builder formattedWriteImpl(Builder, Args...)(return scope ref Builder output, scope String_UTF16 formatString, bool quote, scope Args args) @trusted {
    return formattedWriteImpl(output, formatString.byUTF32, quote, args);
}

Builder formattedWriteImpl(Builder, Args...)(return scope ref Builder output, scope String_UTF32 formatString, bool quote, scope Args args) @trusted {
    import sidero.base.text.format.rawwrite;
    import std.traits : Unqual;

    size_t argsHandled;
    bool[Args.length] areArgsHandled;

    OuterLoop: while (!formatString.empty || argsHandled < Args.length) {
        size_t argId = size_t.max;

        foreach (id, b; areArgsHandled) {
            if (!b) {
                argId = id;
                break;
            }
        }

        {
            size_t soFar;

            {
                size_t notConsumed = formatString.length;
                bool wasLeftBrace;
                auto temp = formatString.save;

                while(!temp.empty) {
                    dchar c = temp.front;

                    if (wasLeftBrace) {
                        if (c == '{') {
                            wasLeftBrace = false;
                            temp.popFront;
                            notConsumed = temp.length;
                        } else {
                            break;
                        }
                    } else if (c == '{') {
                        notConsumed = temp.length;
                        temp.popFront;
                        wasLeftBrace = true;
                    } else {
                        temp.popFront;
                        notConsumed = temp.length;
                    }
                }

                if (temp.empty && wasLeftBrace)
                    notConsumed = 0;

                soFar = formatString.length - notConsumed;
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

        FormatSpecifier format = FormatSpecifier.from(formatString, false);
        if (format.argId >= 0)
            argId = format.argId;

    ArgSwitch:
        switch (argId) {
        case size_t.max:
            break ArgSwitch;

            static foreach (I; 0 .. Args.length) {
        case I:
                if (rawWrite(output, cast(Unqual!(Args[I]))args[I], format, quote)) {
                    if (!areArgsHandled[argId])
                        argsHandled++;
                    areArgsHandled[argId] = true;
                    break ArgSwitch;
                } else
                    break OuterLoop;
            }

        default:
            break OuterLoop;
        }
    }

    return output;
}
