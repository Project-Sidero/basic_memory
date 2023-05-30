module sidero.base.text.format.specifier;
import sidero.base.text;
import sidero.base.text.unicode.characters.defs;
import sidero.base.attributes;
import sidero.base.errors;
import sidero.base.traits;
import sidero.base.allocators;

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
    Alignment|opt Sign|opt AlternativeForm|opt MinimumWidth|opt Precision|opt Type|opt

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

Precision:
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
    int precision = int.max;

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
        assert(fs.precision == 3);
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

        Pointer, /// p, includes the prefix 0x and is in hex
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

        // Precision|opt
        //    "." Integer
        if (!format.empty) {
            this.precision = 0;

            if (format.front == '.') {
                format.popFront;

                if (!readInt(format, this.precision) || this.precision < 0) {
                    this.precision = int.max;
                }
            } else {
                this.precision = int.max;
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
                this.type = Type.Pointer;
                format.popFront;
                break;

            default:
                break;
            }
        }
    }
}

private:

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
