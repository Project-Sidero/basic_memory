module sidero.base.text.format.defs;
import sidero.base.text;
import sidero.base.text.unicode.characters.defs;
import sidero.base.attributes;
import sidero.base.errors;
import sidero.base.traits;

export @safe nothrow @nogc:

/**
https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p0645r10.html

Grammar:

---
Format:
    "{" FormatContents|opt "}"
FormatContents:
    ArgId
    ":" FormatSpec
    ArgId ":" FormatSpec

ArgId:
    Integer

FormatSpec:
    StandardFormat
    String

StandardFormat:
    Alignment|opt Sign|opt AlternativeForm|opt MinimumWidth|opt MaximumWidth|opt Type|opt

Alignment:
    AlignmentOption
    Character AlignmentOption

AlignmentOption:
    "<"
    ">"
    "="
    "^"

Sign:
    "+"
    "-"
    " "

AlternativeForm:
    "#"

MinimumWidth:
    "0" Integer
    Integer

MaximumWidth:
    "." Integer

Type:
    "a"
    "A"
    "b"
    "B"
    "c"
    "d"
    "e"
    "E"
    "f"
    "F"
    "g"
    "G"
    "o"
    "p"
    "s"
    "x"
    "X"
---

*/
struct FormatSpecifier {
    ///
    int argId = -1;
    ///
    String_UTF8 fullFormatSpec;

    ///
    dchar fillCharacter = notACharacter;
    ///
    Alignment alignment;

    ///
    Sign sign;

    ///
    bool useAlternativeForm;

    ///
    bool requireSignAwarePadding;
    ///
    int minimumWidth;

    ///
    int maximumWidth = int.max;

    ///
    Type type;

export @safe nothrow @nogc:

    this(return scope ref FormatSpecifier other) scope {
        this.tupleof = other.tupleof;
    }

    ///
    bool haveFill() scope const {
        return fillCharacter != notACharacter;
    }

    ///
    static FormatSpecifier from(return scope String_UTF8.LiteralType format, bool alreadyInBrace = false) {
        String_UTF8 temp;
        temp.__ctor(format);
        return FormatSpecifier.from(temp, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope String_UTF16.LiteralType format, bool alreadyInBrace = false) {
        String_UTF16 temp;
        temp.__ctor(format);
        return FormatSpecifier.from(temp, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope String_UTF32.LiteralType format, bool alreadyInBrace = false) {
        String_UTF32 temp;
        temp.__ctor(format);
        return FormatSpecifier.from(temp, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope String_UTF8 format, bool alreadyInBrace = false) {
        auto temp = format;
        return FormatSpecifier.from(temp, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope String_UTF16 format, bool alreadyInBrace = false) {
        auto temp = format;
        return FormatSpecifier.from(temp, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope String_UTF32 format, bool alreadyInBrace = false) {
        auto temp = format;
        return FormatSpecifier.from(temp, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope ref String_UTF8 format, bool alreadyInBrace = false) {
        return FormatSpecifier.fromImpl(format, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope ref String_UTF16 format, bool alreadyInBrace = false) {
        return FormatSpecifier.fromImpl(format, alreadyInBrace);
    }

    ///
    static FormatSpecifier from(return scope ref String_UTF32 format, bool alreadyInBrace = false) {
        return FormatSpecifier.fromImpl(format, alreadyInBrace);
    }

    ///
    unittest {
        FormatSpecifier fs;

        fs = FormatSpecifier.from(String_UTF8(""));
        assert(fs == FormatSpecifier.init);

        String_UTF8 todo = String_UTF8("pre{9:*^ #02.3d}post{}error");
        fs = FormatSpecifier.from(todo);
        assert(todo == "post{}error");
        assert(fs.fullFormatSpec == "*^ #02.3d");
        assert(fs.fillCharacter == '*');
        assert(fs.alignment == Alignment.Center);
        assert(fs.sign == Sign.SpaceForPositiveAndNegative);
        assert(fs.useAlternativeForm);
        assert(fs.requireSignAwarePadding);
        assert(fs.minimumWidth == 2);
        assert(fs.maximumWidth == 3);
        assert(fs.type == Type.Decimal);
    }

    ///
    enum Alignment {
        ///
        None,
        ///
        Left,
        ///
        Right,
        ///
        Center,
        ///
        SignAwarePadding,
    }

    ///
    enum Sign {
        ///
        NegativeOnly,
        ///
        PositiveAndNegative,
        ///
        SpaceForPositiveAndNegative,
    }

    ///
    enum Type {
        Default,

        Binary, /// b, alternative form includes the prefix 0b
        BinaryCapital, /// B, alternative form includes the prefix 0B

        Decimal, /// d
        Octal, /// o, alternative form includes the prefix 0
        Hex, /// x, alternative form includes the prefix 0x
        HexCapital, /// X, alternative form includes the prefix 0X

        Float, /// f, precision defaults to 6 places
        FloatHex, /// a
        FloatHexCapital, /// A
        FloatScientific, /// e, precision defaults to 6 places
        FloatScientificCapital, /// E, precision defaults to 6 places
        FloatShortest, /// g, shortest representation of a float, defaults preicion to 6 places
        FloatShortestCapital, /// G shortest representation of a float, defaults to 6 places

        Pointers, /// p, includes the prefix 0x and is in hex
    }

private @hidden:

    static FormatSpecifier fromImpl(FormatString)(return scope ref FormatString format, bool alreadyInBrace = false) @trusted {
        if (!alreadyInBrace) {
            ptrdiff_t index = format.indexOf("{");

            if (index < 0) {
                format = FormatString.init;
                return FormatSpecifier.init;
            } else {
                format = format[index + 1 .. $];
            }
        }

        FormatSpecifier ret;

        // argId
        {
            ret.argId = 0;
            if (!readInt(format, ret.argId) || ret.argId < 0) {
                ret.argId = -1;
            }
        }

        // ":" FormatSpec
        if (!format.empty && format.front == ':') {
            format.popFront;
        }

        format = format[];

        ptrdiff_t index = format.indexOf("}");
        if (index < 0) {
            ret.fullFormatSpec = format.byUTF8;
            format = FormatString.init;
        } else {
            ret.fullFormatSpec = format[0 .. index].byUTF8;
            format = format[index + 1 .. $];
        }

        if (!ret.fullFormatSpec.empty)
            ret.parseSpec;

        return ret;
    }

    void parseSpec() scope {
        String_UTF32 format = this.fullFormatSpec.save.byUTF32;

        bool peekNext(out dchar next) {
            auto temp = format.save();

            if (temp.empty)
                return false;
            temp.popFront;

            if (temp.empty)
                return false;

            next = temp.front;
            return true;
        }

        Alignment parseAlignment(dchar c) {
            switch (c) {
            case '<':
                return Alignment.Left;
            case '>':
                return Alignment.Right;
            case '=':
                return Alignment.SignAwarePadding;
            case '^':
                return Alignment.Center;
            default:
                return Alignment.None;
            }
        }

        // Alignment|opt
        //    "<"
        //    ">"
        //    "="
        //    "^"
        if (!format.empty) {
            dchar temp;

            if (peekNext(temp) && (this.alignment = parseAlignment(temp)) != Alignment.None) {
                this.fillCharacter = format.front;
                format.popFront;
                format.popFront;
            } else if ((this.alignment = parseAlignment(format.front)) != Alignment.None) {
                // no fill
                // ok all parsed out, nothing to do except pop.
                format.popFront;
            }
        }

        // Sign|opt
        //    "+"
        //    "-"
        //    " "
        if (!format.empty) {
            switch (format.front) {
            case '+':
                this.sign = Sign.PositiveAndNegative;
                format.popFront;
                break;
            case '-':
                this.sign = Sign.NegativeOnly;
                format.popFront;
                break;
            case ' ':
                this.sign = Sign.SpaceForPositiveAndNegative;
                format.popFront;
                break;
            default:
                break;
            }
        }

        // AlternativeForm|opt
        //    "#"
        if (!format.empty) {
            if (format.front == '#') {
                this.useAlternativeForm = true;
                format.popFront;
            }
        }

        // MinimumWidth|opt
        //    "0" Integer
        //    Integer
        if (!format.empty) {
            if (format.front == '0') {
                this.requireSignAwarePadding = true;
                format.popFront;
            }

            if (!readInt(format, this.minimumWidth) || this.minimumWidth < 0) {
                this.minimumWidth = 0;
            }
        }

        // MaximumWidth|opt
        //    "." Integer
        if (!format.empty) {
            this.maximumWidth = 0;

            if (format.front == '.') {
                format.popFront;

                if (!readInt(format, this.maximumWidth) || this.maximumWidth < 0) {
                    this.maximumWidth = int.max;
                }
            } else {
                this.maximumWidth = int.max;
            }
        }

        // Type|opt
        if (!format.empty) {
            switch (format.front) {
            case 'b':
                this.type = Type.Binary;
                format.popFront;
                break;
            case 'B':
                this.type = Type.BinaryCapital;
                format.popFront;
                break;
            case 'd':
                this.type = Type.Decimal;
                format.popFront;
                break;
            case 'o':
                this.type = Type.Octal;
                format.popFront;
                break;
            case 'x':
                this.type = Type.Hex;
                format.popFront;
                break;
            case 'X':
                this.type = Type.HexCapital;
                format.popFront;
                break;

            case 'f':
                this.type = Type.Float;
                format.popFront;
                break;
            case 'a':
                this.type = Type.FloatHex;
                format.popFront;
                break;
            case 'A':
                this.type = Type.FloatHexCapital;
                format.popFront;
                break;
            case 'e':
                this.type = Type.FloatScientific;
                format.popFront;
                break;
            case 'E':
                this.type = Type.FloatScientificCapital;
                format.popFront;
                break;
            case 'g':
                this.type = Type.FloatShortest;
                format.popFront;
                break;
            case 'G':
                this.type = Type.FloatShortestCapital;
                format.popFront;
                break;

            case 'p':
                this.type = Type.Pointers;
                format.popFront;
                break;

            default:
                break;
            }
        }
    }
}

///
Expected!(Args.length) formattedRead(Input, Args...)(scope ref Input input, scope String_ASCII formatString, scope ref Args args) @trusted
        if (isUTF!Input || isASCII!Input) {
    return formattedReadImpl(input, String_UTF8(cast(const(char)[])formatString.unsafeGetLiteral()).byUTF32, args);
}

/// Ditto
Expected!(Args.length) formattedRead(Input, Args...)(scope ref Input input, scope String_UTF8 formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    return formattedReadImpl(input, formatString.byUTF32, args);
}

/// Ditto
Expected!(Args.length) formattedRead(Input, Args...)(scope ref Input input, scope String_UTF16 formatString, scope ref Args args)
        if (isUTF!Input && Args.length > 0) {
    return formattedReadImpl(input, formatString.byUTF32, args);
}

/// Ditto
Expected!(Args.length) formattedRead(Input, Args...)(scope ref Input input, scope String_UTF32 formatString, scope ref Args args)
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

private @hidden:

bool readInt(Input)(scope ref Input input, scope ref int ret) {
    uint place = 1;
    bool negate;

    if (!input.empty && input.front == '-') {
        negate = true;
        input.popFront;
    }

    Loop: while (!input.empty) {
        uint c = cast(uint)input.front;

        switch (c) {
        case '0': .. case '9':
            uint diff = c - '0';

            ret += diff * place;
            place *= 10;
            input.popFront;
            break;

        default:
            break Loop;
        }
    }

    if (negate)
        ret *= -1;

    return place > 1;
}

Expected!(Args.length) formattedReadImpl(Input, Args...)(scope ref Input input, scope String_UTF32 formatString, scope ref Args args) @trusted {
    Input inputTemp = input.save;
    size_t successfullyHandled;

    bool handleArg(size_t id)(scope FormatSpecifier format) {
        import sidero.base.text.format.rawread;

        alias ArgType = Args[id];

        static if (isASCII!ArgType || isUTF!ArgType) {
            return formattedReadStringImpl(inputTemp, formatString, args[id]);
        } else
            return rawRead(inputTemp, args[id], format);
    }

    bool[Args.length] areArgsHandled;

    OuterLoop: while (successfullyHandled < Args.length) {
        size_t argId;

        foreach (id, b; areArgsHandled) {
            if (!b) {
                argId = id;
                break;
            }
        }

        {
            bool wasLeftBrace;

            while (!inputTemp.empty && !formatString.empty) {
                if (wasLeftBrace) {
                    if (!formatString.startsWith("{"))
                        break;

                    wasLeftBrace = false;
                    formatString.popFront;
                } else if (formatString.startsWith("{")) {
                    formatString.popFront;
                    wasLeftBrace = true;
                } else if (inputTemp.startsWith([formatString.front])) {
                    inputTemp.popFront;
                    formatString.popFront;
                } else
                    break OuterLoop;
            }

            if (inputTemp.empty && !formatString.empty)
                break OuterLoop;
        }

        FormatSpecifier format;

        if (!formatString.empty) {
            format = FormatSpecifier.from(formatString, true);

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
        successfullyHandled++;

        input = inputTemp;
        inputTemp = input.save;
    }

    return typeof(return)(successfullyHandled);
}

bool formattedReadStringImpl(Input, ArgType)(scope ref Input input, scope ref String_UTF32 formatString, scope ref ArgType output) @trusted {

    String_UTF32 possibleEndCondition;

    {
        bool wasLeftBrace;

        String_UTF32 tempFormat = formatString.save;
        ptrdiff_t potentialLength = ptrdiff_t.max;

        while (!tempFormat.empty) {
            if (wasLeftBrace) {
                if (!tempFormat.startsWith("{")) {
                    potentialLength = tempFormat.length;
                    break;
                }

                wasLeftBrace = false;
                tempFormat.popFront;
            } else if (tempFormat.startsWith("{")) {
                tempFormat.popFront;
                wasLeftBrace = true;
            } else
                break;
        }

        possibleEndCondition = formatString[0 .. potentialLength];
    }

    static if (isASCII!ArgType) {
        // disallow any char above 128

        String_UTF32 tempPEC = possibleEndCondition.save;

        while (!tempPEC.empty) {
            dchar c = tempPEC.front;

            if (c >= 128) {
                possibleEndCondition = possibleEndCondition[0 .. -tempPEC.length];
                break;
            }

            tempPEC.popFront;
        }
    }

    Input toCopy;

    {
        ptrdiff_t index = input.indexOf(possibleEndCondition);

        static if (isASCII!ArgType) {
            const canDo = index >= 0 ? index : input.length;
            size_t willDo;

            foreach (c; input[0 .. canDo]) {
                if (c >= 128)
                    break;
                willDo++;
            }

            if (willDo == input.length) {
                toCopy = input;
                input = Input.init;
            } else {
                toCopy = input[0 .. willDo];
                input = input[willDo .. $];
            }
        } else {
            if (index < 0) {
                toCopy = input;
                input = Input.init;
            } else {
                toCopy = input[0 .. index];
                input = input[index .. $];
            }
        }
    }

    static if (isASCII!ArgType) {
        static if (is(ArgType == String_ASCII)) {
            StringBuilder_ASCII builder = StringBuilder_ASCII();
        } else {
            StringBuilder_ASCII builder = output;
        }

        foreach (c; toCopy) {
            builder ~= [cast(ubyte)c];
        }

        static if (is(ArgType == String_ASCII)) {
            output = builder.asReadOnly();
        }

        return true;
    } else static if (isUTF!ArgType) {
        static if (is(ArgType == String_UTF8)) {
            auto builder = StringBuilder_UTF8();
        } else static if (is(ArgType == String_UTF16)) {
            auto builder = StringBuilder_UTF16();
        } else static if (is(ArgType == String_UTF32)) {
            auto builder = StringBuilder_UTF32();
        } else {
            auto builder = output;
        }

        const assign = builder.isNull;
        builder ~= toCopy;

        static if (isUTFReadOnly!ArgType) {
            output = builder.asReadOnly();
        } else if (assign) {
            output = builder;
        }

        return true;
    } else
        static assert(0);
}
