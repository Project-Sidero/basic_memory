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
    "(" StandardFormat|opt ")" IterationCharacters|opt
    "(" Format|opt ")" IterationCharacters|opt
    StandardFormat
    String

IterationCharacters:
    Character
    Character Character Character

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
    String_UTF8 fullFormatSpec, innerFormatSpec;

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

    ///
    bool useIterableCharacters;
    ///
    dchar iterableDividerCharacter = notACharacter;
    ///
    dchar iterableStartCharacter = notACharacter;
    ///
    dchar iterableEndCharacter = notACharacter;

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

        String_UTF8 todo = String_UTF8("pre{9:({:*^ #02.3d}),[}post{}error");
        fs = FormatSpecifier.from(todo);

        assert(todo == "post{}error");
        assert(fs.fullFormatSpec == "({:*^ #02.3d}),[");
        assert(fs.innerFormatSpec == "{:*^ #02.3d}");
        assert(fs.fillCharacter == '*');
        assert(fs.alignment == Alignment.Center);
        assert(fs.sign == Sign.SpaceForPositiveAndNegative);
        assert(fs.useAlternativeForm);
        assert(fs.requireSignAwarePadding);
        assert(fs.minimumWidth == 2);
        assert(fs.precision == 3);
        assert(fs.type == Type.Decimal);
        assert(fs.useIterableCharacters);
        assert(fs.iterableDividerCharacter == ',');
        assert(fs.iterableStartCharacter == '[');
        assert(fs.iterableEndCharacter == notACharacter);

        fs = FormatSpecifier.from(String_UTF8("{:0<10d}"));
        assert(fs != FormatSpecifier.init);
        assert(fs.fillCharacter == '0');
        assert(fs.alignment == FormatSpecifier.Alignment.Left);
        assert(fs.minimumWidth == 10);
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

        WhiteSpace, /// Skips white space
    }

    static FormatSpecifier defaults() {
        return FormatSpecifier.init;
    }

private @hidden:

    static FormatSpecifier fromImpl(FormatString)(return scope ref FormatString format, bool alreadyInBrace = false) @trusted {
        if(!alreadyInBrace) {
            ptrdiff_t index = format.indexOf("{");

            if(index < 0) {
                format = FormatString.init;
                return FormatSpecifier.init;
            } else {
                format = format[index + 1 .. $];
            }
        }

        FormatSpecifier ret = FormatSpecifier.defaults;

        // argId
        {
            ret.argId = 0;
            if(!readInt(format, ret.argId) || ret.argId < 0) {
                ret.argId = -1;
            }
        }

        // ":" FormatSpec
        if(!format.empty && format.front == ':') {
            format.popFront;
        }

        format = format[];

        size_t amountInInner, amountLeft;
        ret.fullFormatSpec = format.save.byUTF8;
        ret.parseSpec(amountInInner, amountLeft);

        {
            int countBracketPairs = 1;

            auto leftOver = format.save;
            while(!leftOver.empty) {
                ptrdiff_t index = leftOver.indexOf("}"c);

                if(index > 0) {
                    countBracketPairs += leftOver[0 .. index].count("{"c);

                    auto prev = leftOver[index - 1];
                    leftOver = leftOver[index + 1 .. $];

                    if(prev.startsWith("\\"c) || prev.startsWith("}"c)) {
                    } else if(countBracketPairs > 1) {
                        countBracketPairs--;
                    } else {
                        break;
                    }
                } else {
                    leftOver = leftOver[1 .. $];

                    if(countBracketPairs > 1) {
                        countBracketPairs--;
                    } else {
                        break;
                    }
                }
            }

            ret.fullFormatSpec = format[0 .. $ - leftOver.length].byUTF8;
            format = leftOver;

            if(ret.fullFormatSpec.endsWith("}"c))
                ret.fullFormatSpec = ret.fullFormatSpec[0 .. $ - 1];
        }

        if(ret.useIterableCharacters)
            ret.innerFormatSpec = ret.fullFormatSpec[1 .. $ - (amountInInner + 1)];

        return ret;
    }

    void parseSpec(out size_t amountInInner, out size_t amountLeft) scope {
        {
            // argId and fullFormatSpec are already initialized
            this.tupleof[2 .. $] = FormatSpecifier.init.tupleof[2 .. $];
        }

        String_UTF32 format = this.fullFormatSpec.save.byUTF32;
        scope(exit) {
            amountLeft = format.save.length;
        }

        bool peekNext(out dchar next) {
            auto temp = format.save();

            if(temp.empty)
                return false;
            temp.popFront;

            if(temp.empty)
                return false;

            next = temp.front;
            return true;
        }

        Alignment parseAlignment(dchar c) {
            switch(c) {
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

        bool expectingCloseBrace;

        // "({:" StandardFormat "})" IterationCharacters|opt
        if(!format.empty && format.front == '(') {
            dchar temp;

            if(peekNext(temp) && (this.alignment = parseAlignment(temp)) == Alignment.None) {
                format.popFront;

                if(!format.empty && format.front == '{') {
                    expectingCloseBrace = true;
                    format.popFront;

                    while(!format.empty) {
                        dchar was = format.front;
                        format.popFront;
                        if(was == ':')
                            break;
                    }
                }

                useIterableCharacters = true;
            }
        }

        if(format.startsWith("/")) {
            format.popFront;
            this.type = Type.WhiteSpace;
            return;
        } else {
            // Alignment|opt
            //    "<"
            //    ">"
            //    "="
            //    "^"
            if(!format.empty) {
                dchar temp;

                if(peekNext(temp) && (this.alignment = parseAlignment(temp)) != Alignment.None) {
                    this.fillCharacter = format.front;
                    format.popFront;
                    format.popFront;
                } else if((this.alignment = parseAlignment(format.front)) != Alignment.None) {
                    // no fill
                    // ok all parsed out, nothing to do except pop.
                    format.popFront;
                }
            }

            // Sign|opt
            //    "+"
            //    "-"
            //    " "
            if(!format.empty) {
                switch(format.front) {
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
            if(!format.empty) {
                if(format.front == '#') {
                    this.useAlternativeForm = true;
                    format.popFront;
                }
            }

            // MinimumWidth|opt
            //    "0" Integer
            //    Integer
            if(!format.empty) {
                if(format.front == '0') {
                    this.requireSignAwarePadding = true;
                    format.popFront;
                }

                if(!readInt(format, this.minimumWidth) || this.minimumWidth < 0) {
                    this.minimumWidth = 0;
                }
            }

            // Precision|opt
            //    "." Integer
            if(!format.empty) {
                this.precision = 0;

                if(format.front == '.') {
                    format.popFront;

                    if(!readInt(format, this.precision) || this.precision < 0) {
                        this.precision = int.max;
                    }
                } else {
                    this.precision = int.max;
                }
            }

            // Type|opt
            if(!format.empty) {
                switch(format.front) {
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

                case 's':
                    // default
                    format.popFront;
                    break;

                default:
                    break;
                }
            }
        }

        {
            // "})" IterationCharacters|opt
            // IterationCharacters:
            //     Character
            //     Character Character Character
            bool wantIterableCharacters = useIterableCharacters;

            if(expectingCloseBrace) {
                if(!format.empty && format.front == '}') {
                    format.popFront;
                } else
                    wantIterableCharacters = false;
            }

            if(wantIterableCharacters && !format.empty && format.front == ')') {
                format.popFront;
            } else
                wantIterableCharacters = false;

            if(wantIterableCharacters) {
                if(!format.empty && format.front != '}') {
                    this.iterableDividerCharacter = format.front;
                    format.popFront;
                    amountInInner++;
                }

                if(!format.empty && format.front != '}') {
                    this.iterableStartCharacter = format.front;
                    format.popFront;
                    amountInInner++;
                }

                if(!format.empty && format.front != '}') {
                    this.iterableEndCharacter = format.front;
                    format.popFront;
                    amountInInner++;
                }
            }
        }
    }
}

private:

bool readInt(Input)(scope ref Input input, scope ref int ret) {
    uint done;
    bool negate;

    if(!input.empty && input.front == '-') {
        negate = true;
        input.popFront;
    }

    Loop: while(!input.empty) {
        uint c = cast(uint)input.front;

        switch(c) {
        case '0': .. case '9':
            uint diff = c - '0';

            ret *= 10;
            ret += diff;

            input.popFront;
            done++;
            break;

        default:
            break Loop;
        }
    }

    if(negate)
        ret *= -1;

    return done > 0;
}
