/// Bootstring aka Punycode https://www.rfc-editor.org/rfc/rfc3492
module sidero.base.encoding.bootstring;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.allocators;

/**
Note: will not add deliminator just because a deliminator exists, you must check for have encoding.

Warning: Only supports Punycode, parts required for other arguments is missing.
*/
struct BootString(uint Base, uint Tmin, uint Tmax, uint Skew, uint Damp, uint InitialBias, uint InitialN, ubyte Deliminator) {
    static assert(Base == 36, "BootString implementation only implemented for Punycode");
export @safe nothrow @nogc static:

    ///
    bool needsEncoding(dchar c) {
        return c >= 0x80;
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_ASCII input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_ASCII input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_UTF8 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_UTF16 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_UTF32 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_UTF8 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_UTF16 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_UTF32 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_ASCII input) {
        bool haveEncoded;
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_ASCII input) {
        bool haveEncoded;
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF8 input) {
        bool haveEncoded;
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF16 input) {
        bool haveEncoded;
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF32 input) {
        bool haveEncoded;
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF8 input) {
        bool haveEncoded;
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF16 input) {
        bool haveEncoded;
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF32 input) {
        bool haveEncoded;
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_ASCII input, out bool haveEncoded) {
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_ASCII input, out bool haveEncoded) {
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF8 input, out bool haveEncoded) {
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF16 input, out bool haveEncoded) {
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF32 input, out bool haveEncoded) {
        return encode_(output, input, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF8 input, out bool haveEncoded) {
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF16 input, out bool haveEncoded) {
        return encode_(output, input.byUTF32, haveEncoded);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF32 input, out bool haveEncoded) {
        return encode_(output, input, haveEncoded);
    }

    ///
    Result!StringBuilder_UTF32 decode(scope String_ASCII input) {
        StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
        auto result = decode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_UTF32 decode(scope StringBuilder_ASCII input) {
        StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
        auto result = decode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF8 output, scope String_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF16 output, scope String_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF32 output, scope String_ASCII input) {
        return decode_(output, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF8 output, scope StringBuilder_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF16 output, scope StringBuilder_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF32 output, scope StringBuilder_ASCII input) {
        return decode_(output, input);
    }

private:
    ErrorResult encode_(Input)(scope StringBuilder_ASCII output, scope Input input, out bool haveEncoded) @trusted {
        size_t n = InitialN, delta, bias = InitialBias, numberOfBasicCharacters;

        if(input.length == 0)
            return ErrorResult.init;

        ubyte encodeDigit(uint c, int flag) {
            return cast(ubyte)(c + 22 + 75 * (c < 26) - ((flag != 0) << 5));
        }

        {
            int inHex;

            foreach(c; input) {
                if(c == '%') {
                    if(inHex > 0)
                        return ErrorResult(MalformedInputException("Error percentage while handling percentage encoding"));

                    output ~= [cast(ubyte)c];
                    numberOfBasicCharacters++;

                    inHex = 1;
                } else if(inHex > 0) {
                    switch(c) {
                    case '0': .. case '9':
                    case 'A': .. case 'Z':
                        output ~= [cast(ubyte)c];
                        break;
                    case 'a': .. case 'z':
                        enum aToA = 'A' - 'a';
                        output ~= [cast(ubyte)(c + aToA)];
                        break;
                    default:
                        return ErrorResult(MalformedInputException("Error percentage encoding character out of range"));
                    }

                    numberOfBasicCharacters++;

                    inHex++;
                    if(inHex == 3)
                        inHex = 0;
                } else if(c < 0x80) {
                    // basic character
                    output ~= [cast(ubyte)c];
                    numberOfBasicCharacters++;
                }
            }
        }

        if(numberOfBasicCharacters == input.length)
            return ErrorResult.init;
        haveEncoded = true;
        output ~= [Deliminator];

        size_t amountConsumed = numberOfBasicCharacters;

        while(amountConsumed < input.encodingLength) {
            uint m = uint.max;

            foreach(c; input) {
                if(c >= n && c < m)
                    m = c;
            }

            if(m - n > (uint.max - delta) / (amountConsumed + 1))
                return ErrorResult(MalformedInputException("Error delta location calculation would overflow"));
            delta += (m - n) * (amountConsumed + 1);
            n = m;

            foreach(c; input) {
                if(c < n || c < 0x80) {
                    delta++;
                    if(delta == 0)
                        return ErrorResult(MalformedInputException("Error delta location calculation has overflown"));
                }

                if(c == n) {
                    uint q = cast(uint)delta;

                    for(size_t k = Base;; k += Base) {
                        const t = k <= bias ? Tmin : (k >= bias + Tmax) ? Tmax : (k - bias);

                        if(q < t)
                            break;

                        output ~= [encodeDigit(cast(uint)(t + ((q - t) % (Base - t))), 0)];
                        q = cast(uint)((q - t) / (Base - t));
                    }

                    output ~= [encodeDigit(q, 0)];
                    bias = adapt(delta, amountConsumed + 1, amountConsumed == numberOfBasicCharacters);
                    delta = 0;
                    amountConsumed++;
                }
            }

            delta++;
            n++;
        }

        return ErrorResult.init;
    }

    ErrorResult decode_(Input)(scope StringBuilder_UTF32 output, scope Input input) @trusted {
        dchar toInsert = InitialN;
        const startingOutputLength = output.length;
        size_t outputPosition, bias = InitialBias;
        bool isFirst = true;

        bool copyIfBasic(scope Input from) {
            foreach(c; from) {
                if(c > (2 ^^ Base) - 1)
                    return false;
            }

            output ~= from;
            return true;
        }

        // a-z,0-9
        ubyte decodeDigit(ubyte from) {
            switch(from) {
            case '0': .. case '9':
                return cast(ubyte)(from - 22);
            case 'A': .. case 'Z':
                return cast(ubyte)(from - 'A');
            case 'a': .. case 'z':
                return cast(ubyte)(from - 'a');
            default:
                return Base;
            }
        }

        {
            ptrdiff_t lastDelimIndex = input.lastIndexOf([Deliminator]);
            if(lastDelimIndex < 0) {
                if(copyIfBasic(input)) {
                    input = Input.init;
                } else {
                    return ErrorResult(MalformedInputException(
                            "Found non-basic character [0..(2^base)-1] inclusive before final deliminator."));
                }
            } else {
                if(copyIfBasic(input[0 .. lastDelimIndex])) {
                    input = input[lastDelimIndex + 1 .. $];
                } else {
                    return ErrorResult(MalformedInputException(
                            "Found non-basic character [0..(2^base)-1] inclusive before final deliminator."));
                }
            }
        }

        while(!input.empty) {
            size_t oldOutputPosition = outputPosition;
            size_t w = 1;

            for(size_t k = Base;; k += Base) {
                if(input.empty) {
                    // nothing to consume, OH NOES
                    return ErrorResult(MalformedInputException("Expected input, but empty"));
                }

                const digit = decodeDigit(input.front);
                input.popFront;

                if(digit >= Base)
                    return ErrorResult(MalformedInputException("Input is out of range of the valid basic characters"));
                else if(digit > (size_t.max - outputPosition) / w)
                    return ErrorResult(MalformedInputException("Could not add input character, would overflow"));

                outputPosition += digit * w;
                const t = k <= bias ? Tmin : (k >= bias + Tmax ? Tmax : (k - bias));

                if(digit < t)
                    break;
                else if(w > size_t.max / (Base - t))
                    return ErrorResult(MalformedInputException("Could not add input character, would overflow accumulator"));

                w *= Base - t;
            }

            if(outputPosition / (output.length + 1) > size_t.max - toInsert)
                return ErrorResult(MalformedInputException("Could not add input character, would overflow accumulator"));
            toInsert += outputPosition / (output.length + 1);

            bias = adapt(outputPosition - oldOutputPosition, output.length + 1, isFirst);
            outputPosition %= (output.length + 1);

            output.insert(startingOutputLength + outputPosition, toInsert);
            outputPosition++;
            isFirst = false;
        }

        return ErrorResult.init;
    }

    size_t adapt(size_t delta, size_t numPoints, bool firstTime) {
        if(firstTime)
            delta /= Damp;
        else
            delta /= 2;

        delta += delta / numPoints;
        size_t k;

        while(delta > ((Base - Tmin) * Tmax) / 2) {
            delta /= Base - Tmin;
            k += Base;
        }

        return k + (((Base - Tmin + 1) * delta) / (delta + Skew));
    }
}

///
alias Punycode = BootString!(36, 1, 26, 38, 700, 72, 128, '-');

///
unittest {
    assert(Punycode.decode(String_ASCII("Hello World!-wi44b")).assumeOkay == "Hello \u9EDEWorld!");
    assert(Punycode.decode(String_ASCII("-egbpdaj6bu4bxfgehfvwxn"))
            .assumeOkay == "\u0644\u064A\u0647\u0645\u0627\u0628\u062A\u0643\u0644\u0645\u0648\u0634\u0639\u0631\u0628\u064A\u061F");
    assert(Punycode.decode(String_ASCII("-ihqwcrb4cv8a8dqg056pqjye")).assumeOkay == "\u4ED6\u4EEC\u4E3A\u4EC0\u4E48\u4E0D\u8BF4\u4E2D\u6587");
    assert(Punycode.decode(String_ASCII("-ihqwctvzc91f659drss3x8bo0yb"))
            .assumeOkay == "\u4ED6\u5011\u7232\u4EC0\u9EBD\u4E0D\u8AAA\u4E2D\u6587");
    assert(Punycode.decode(String_ASCII("Proprostnemluvesky-uyb24dma41a")).assumeOkay == "\u0050\u0072\u006F\u010D\u0070\u0072\u006F\u0073\u0074\u011B\u006E\u0065\u006D\u006C\u0075\u0076\u00ED\u010D\u0065\u0073\u006B\u0079");
    assert(Punycode.decode(String_ASCII("-4dbcagdahymbxekheh6e0a7fei0b")).assumeOkay == "\u05DC\u05DE\u05D4\u05D4\u05DD\u05E4\u05E9\u05D5\u05D8\u05DC\u05D0\u05DE\u05D3\u05D1\u05E8\u05D9\u05DD\u05E2\u05D1\u05E8\u05D9\u05EA");
    assert(Punycode.decode(String_ASCII("-i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd")).assumeOkay == "\u092F\u0939\u0932\u094B\u0917\u0939\u093F\u0928\u094D\u0926\u0940\u0915\u094D\u092F\u094B\u0902\u0928\u0939\u0940\u0902\u092C\u094B\u0932\u0938\u0915\u0924\u0947\u0939\u0948\u0902");
    assert(Punycode.decode(String_ASCII("-n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa"))
            .assumeOkay == "\u306A\u305C\u307F\u3093\u306A\u65E5\u672C\u8A9E\u3092\u8A71\u3057\u3066\u304F\u308C\u306A\u3044\u306E\u304B");
    assert(Punycode.decode(String_ASCII("-989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c")).assumeOkay == "\uC138\uACC4\uC758\uBAA8\uB4E0\uC0AC\uB78C\uB4E4\uC774\uD55C\uAD6D\uC5B4\uB97C\uC774\uD574\uD55C\uB2E4\uBA74\uC5BC\uB9C8\uB098\uC88B\uC744\uAE4C");
    assert(Punycode.decode(String_ASCII("-b1abfaaepdrnnbgefbaDotcwatmq2g4l")).assumeOkay == "\u043F\u043E\u0447\u0435\u043C\u0443\u0436\u0435\u043E\u043D\u0438\u043D\u0435\u0433\u043E\u0432\u043E\u0440\u044F\u0442\u043F\u043E\u0440\u0443\u0441\u0441\u043A\u0438");
    assert(Punycode.decode(String_ASCII("PorqunopuedensimplementehablarenEspaol-fmd56a")).assumeOkay == "\u0050\u006F\u0072\u0071\u0075\u00E9\u006E\u006F\u0070\u0075\u0065\u0064\u0065\u006E\u0073\u0069\u006D\u0070\u006C\u0065\u006D\u0065\u006E\u0074\u0065\u0068\u0061\u0062\u006C\u0061\u0072\u0065\u006E\u0045\u0073\u0070\u0061\u00F1\u006F\u006C");
    assert(Punycode.decode(String_ASCII("TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g")).assumeOkay == "\u0054\u1EA1\u0069\u0073\u0061\u006F\u0068\u1ECD\u006B\u0068\u00F4\u006E\u0067\u0074\u0068\u1EC3\u0063\u0068\u1EC9\u006E\u00F3\u0069\u0074\u0069\u1EBF\u006E\u0067\u0056\u0069\u1EC7\u0074");
    assert(Punycode.decode(String_ASCII("3B-ww4c5e180e575a65lsy2b")).assumeOkay == "\u0033\u5E74\u0042\u7D44\u91D1\u516B\u5148\u751F");
    assert(Punycode.decode(String_ASCII("-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n")).assumeOkay == "\u5B89\u5BA4\u5948\u7F8E\u6075\u002D\u0077\u0069\u0074\u0068\u002D\u0053\u0055\u0050\u0045\u0052\u002D\u004D\u004F\u004E\u004B\u0045\u0059\u0053");
    assert(Punycode.decode(String_ASCII("Hello-Another-Way--fc4qua05auwb3674vfr0b")).assumeOkay == "\u0048\u0065\u006C\u006C\u006F\u002D\u0041\u006E\u006F\u0074\u0068\u0065\u0072\u002D\u0057\u0061\u0079\u002D\u305D\u308C\u305E\u308C\u306E\u5834\u6240");
    assert(Punycode.decode(String_ASCII("2-u9tlzr9756bt3uc0v")).assumeOkay == "\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B\u0032");
    assert(Punycode.decode(String_ASCII("MajiKoi5-783gue6qz075azm5e"))
            .assumeOkay == "\u004D\u0061\u006A\u0069\u3067\u004B\u006F\u0069\u3059\u308B\u0035\u79D2\u524D");
    assert(Punycode.decode(String_ASCII("de-jg4avhby1noc0d")).assumeOkay == "\u30D1\u30D5\u30A3\u30FC\u0064\u0065\u30EB\u30F3\u30D0");
    assert(Punycode.decode(String_ASCII("-d9juau41awczczp")).assumeOkay == "\u305D\u306E\u30B9\u30D4\u30FC\u30C9\u3067");
    assert(Punycode.decode(String_ASCII("-> $1.00 <--")).assumeOkay == "\u002D\u003E\u0020\u0024\u0031\u002E\u0030\u0030\u0020\u003C\u002D");
    assert(Punycode.decode(String_ASCII("-")).assumeOkay == "");
}

///
unittest {
    assert(Punycode.encode(String_UTF8("Hello \u9EDEWorld!")).assumeOkay == "Hello World!-wi44b");
    assert(Punycode.encode(String_UTF8(
            "\u0644\u064A\u0647\u0645\u0627\u0628\u062A\u0643\u0644\u0645\u0648\u0634\u0639\u0631\u0628\u064A\u061F"))
            .assumeOkay == "-egbpdaj6bu4bxfgehfvwxn");
    assert(Punycode.encode(String_UTF8("\u4ED6\u4EEC\u4E3A\u4EC0\u4E48\u4E0D\u8BF4\u4E2D\u6587")).assumeOkay == "-ihqwcrb4cv8a8dqg056pqjye");
    assert(Punycode.encode(String_UTF8("\u4ED6\u5011\u7232\u4EC0\u9EBD\u4E0D\u8AAA\u4E2D\u6587"))
            .assumeOkay == "-ihqwctvzc91f659drss3x8bo0yb");
    assert(Punycode.encode(String_UTF8("\u0050\u0072\u006F\u010D\u0070\u0072\u006F\u0073\u0074\u011B\u006E\u0065\u006D\u006C\u0075\u0076\u00ED\u010D\u0065\u0073\u006B\u0079"))
            .assumeOkay == "Proprostnemluvesky-uyb24dma41a");
    assert(Punycode.encode(String_UTF8("\u05DC\u05DE\u05D4\u05D4\u05DD\u05E4\u05E9\u05D5\u05D8\u05DC\u05D0\u05DE\u05D3\u05D1\u05E8\u05D9\u05DD\u05E2\u05D1\u05E8\u05D9\u05EA"))
            .assumeOkay == "-4dbcagdahymbxekheh6e0a7fei0b");
    assert(Punycode.encode(String_UTF8("\u092F\u0939\u0932\u094B\u0917\u0939\u093F\u0928\u094D\u0926\u0940\u0915\u094D\u092F\u094B\u0902\u0928\u0939\u0940\u0902\u092C\u094B\u0932\u0938\u0915\u0924\u0947\u0939\u0948\u0902"))
            .assumeOkay == "-i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd");
    assert(Punycode.encode(String_UTF8(
            "\u306A\u305C\u307F\u3093\u306A\u65E5\u672C\u8A9E\u3092\u8A71\u3057\u3066\u304F\u308C\u306A\u3044\u306E\u304B"))
            .assumeOkay == "-n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa");
    assert(Punycode.encode(String_UTF8("\uC138\uACC4\uC758\uBAA8\uB4E0\uC0AC\uB78C\uB4E4\uC774\uD55C\uAD6D\uC5B4\uB97C\uC774\uD574\uD55C\uB2E4\uBA74\uC5BC\uB9C8\uB098\uC88B\uC744\uAE4C"))
            .assumeOkay == "-989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c");
    assert(Punycode.encode(String_UTF8("\u043F\u043E\u0447\u0435\u043C\u0443\u0436\u0435\u043E\u043D\u0438\u043D\u0435\u0433\u043E\u0432\u043E\u0440\u044F\u0442\u043F\u043E\u0440\u0443\u0441\u0441\u043A\u0438"))
            .assumeOkay == "-b1abfaaepdrnnbgefbadotcwatmq2g4l");
    assert(Punycode.encode(String_UTF8("\u0050\u006F\u0072\u0071\u0075\u00E9\u006E\u006F\u0070\u0075\u0065\u0064\u0065\u006E\u0073\u0069\u006D\u0070\u006C\u0065\u006D\u0065\u006E\u0074\u0065\u0068\u0061\u0062\u006C\u0061\u0072\u0065\u006E\u0045\u0073\u0070\u0061\u00F1\u006F\u006C"))
            .assumeOkay == "PorqunopuedensimplementehablarenEspaol-fmd56a");
    assert(Punycode.encode(String_UTF8("\u0054\u1EA1\u0069\u0073\u0061\u006F\u0068\u1ECD\u006B\u0068\u00F4\u006E\u0067\u0074\u0068\u1EC3\u0063\u0068\u1EC9\u006E\u00F3\u0069\u0074\u0069\u1EBF\u006E\u0067\u0056\u0069\u1EC7\u0074"))
            .assumeOkay == "TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g");
    assert(Punycode.encode(String_UTF8("\u0033\u5E74\u0042\u7D44\u91D1\u516B\u5148\u751F")).assumeOkay == "3B-ww4c5e180e575a65lsy2b");
    assert(Punycode.encode(String_UTF8("\u5B89\u5BA4\u5948\u7F8E\u6075\u002D\u0077\u0069\u0074\u0068\u002D\u0053\u0055\u0050\u0045\u0052\u002D\u004D\u004F\u004E\u004B\u0045\u0059\u0053"))
            .assumeOkay == "-with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n");
    assert(Punycode.encode(String_UTF8("\u0048\u0065\u006C\u006C\u006F\u002D\u0041\u006E\u006F\u0074\u0068\u0065\u0072\u002D\u0057\u0061\u0079\u002D\u305D\u308C\u305E\u308C\u306E\u5834\u6240"))
            .assumeOkay == "Hello-Another-Way--fc4qua05auwb3674vfr0b");
    assert(Punycode.encode(String_UTF8("\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B\u0032")).assumeOkay == "2-u9tlzr9756bt3uc0v");
    assert(Punycode.encode(String_UTF8("\u004D\u0061\u006A\u0069\u3067\u004B\u006F\u0069\u3059\u308B\u0035\u79D2\u524D"))
            .assumeOkay == "MajiKoi5-783gue6qz075azm5e");
    assert(Punycode.encode(String_UTF8("\u30D1\u30D5\u30A3\u30FC\u0064\u0065\u30EB\u30F3\u30D0")).assumeOkay == "de-jg4avhby1noc0d");
    assert(Punycode.encode(String_UTF8("\u305D\u306E\u30B9\u30D4\u30FC\u30C9\u3067")).assumeOkay == "-d9juau41awczczp");
    assert(Punycode.encode(String_UTF8("\u002D\u003E\u0020\u0024\u0031\u002E\u0030\u0030\u0020\u003C\u002D")).assumeOkay == "-> $1.00 <-");
    assert(Punycode.encode(String_UTF8("")).assumeOkay == "");
}

/// Punycode + ACE prefix support (xn--).
struct IDNAPunycode {
export @safe nothrow @nogc static:

    ///
    bool needsEncoding(dchar c) {
        return c >= 0x80;
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_ASCII input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_ASCII input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_UTF8 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_UTF16 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope String_UTF32 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_UTF8 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_UTF16 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_ASCII encode(scope StringBuilder_UTF32 input) {
        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        auto result = encode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_ASCII input) {
        return encode_(output, input);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_ASCII input) {
        return encode_(output, input);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF8 input) {
        return encode_(output, input.byUTF32);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF16 input) {
        return encode_(output, input.byUTF32);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope String_UTF32 input) {
        return encode_(output, input);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF8 input) {
        return encode_(output, input.byUTF32);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF16 input) {
        return encode_(output, input.byUTF32);
    }

    ///
    ErrorResult encode(scope StringBuilder_ASCII output, scope StringBuilder_UTF32 input) {
        return encode_(output, input);
    }

    ///
    Result!StringBuilder_UTF32 decode(scope String_ASCII input) {
        StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
        auto result = decode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    Result!StringBuilder_UTF32 decode(scope StringBuilder_ASCII input) {
        StringBuilder_UTF32 ret = StringBuilder_UTF32(globalAllocator());
        auto result = decode(ret, input);

        if(!result)
            return typeof(return)(result.getError);
        else
            return typeof(return)(ret);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF8 output, scope String_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF16 output, scope String_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF32 output, scope String_ASCII input) {
        return decode_(output, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF8 output, scope StringBuilder_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF16 output, scope StringBuilder_ASCII input) {
        return decode_(output.byUTF32, input);
    }

    ///
    ErrorResult decode(scope StringBuilder_UTF32 output, scope StringBuilder_ASCII input) {
        return decode_(output, input);
    }

private:
    ErrorResult encode_(Input)(scope StringBuilder_ASCII output, scope Input input) @trusted {
        const originalLength = output.length;

        bool haveEncoded;
        auto result = Punycode.encode(output, input, haveEncoded);
        if(!result)
            return result;

        if(haveEncoded) {
            if(output[originalLength .. $].lastIndexOf(['-']) != 0)
                output.insert(originalLength, "xn--");
            else
                output.insert(originalLength, "xn-");
        }

        return result;
    }

    ErrorResult decode_(Input)(scope StringBuilder_UTF32 output, scope Input input) @trusted {
        if(input.startsWith("xn--")) {
            // got a prefix, but do we have a deliminator?
            if(input.lastIndexOf(['-']) == 3) {
                // dangit, we need to keep one from ACE prefix!
                input = input[3 .. $];
            } else {
                input = input[4 .. $];
            }
        }

        return Punycode.decode(output, input);
    }
}

///
unittest {
    assert(IDNAPunycode.decode(String_ASCII("xn--Hello World!-wi44b")).assumeOkay == "Hello \u9EDEWorld!");
    assert(IDNAPunycode.decode(String_ASCII("xn--egbpdaj6bu4bxfgehfvwxn"))
            .assumeOkay == "\u0644\u064A\u0647\u0645\u0627\u0628\u062A\u0643\u0644\u0645\u0648\u0634\u0639\u0631\u0628\u064A\u061F");
    assert(IDNAPunycode.decode(String_ASCII("xn--ihqwcrb4cv8a8dqg056pqjye"))
            .assumeOkay == "\u4ED6\u4EEC\u4E3A\u4EC0\u4E48\u4E0D\u8BF4\u4E2D\u6587");
    assert(IDNAPunycode.decode(String_ASCII("xn--ihqwctvzc91f659drss3x8bo0yb"))
            .assumeOkay == "\u4ED6\u5011\u7232\u4EC0\u9EBD\u4E0D\u8AAA\u4E2D\u6587");
    assert(IDNAPunycode.decode(String_ASCII("xn--Proprostnemluvesky-uyb24dma41a")).assumeOkay == "\u0050\u0072\u006F\u010D\u0070\u0072\u006F\u0073\u0074\u011B\u006E\u0065\u006D\u006C\u0075\u0076\u00ED\u010D\u0065\u0073\u006B\u0079");
    assert(IDNAPunycode.decode(String_ASCII("xn--4dbcagdahymbxekheh6e0a7fei0b")).assumeOkay == "\u05DC\u05DE\u05D4\u05D4\u05DD\u05E4\u05E9\u05D5\u05D8\u05DC\u05D0\u05DE\u05D3\u05D1\u05E8\u05D9\u05DD\u05E2\u05D1\u05E8\u05D9\u05EA");
    assert(IDNAPunycode.decode(String_ASCII("xn--i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd")).assumeOkay == "\u092F\u0939\u0932\u094B\u0917\u0939\u093F\u0928\u094D\u0926\u0940\u0915\u094D\u092F\u094B\u0902\u0928\u0939\u0940\u0902\u092C\u094B\u0932\u0938\u0915\u0924\u0947\u0939\u0948\u0902");
    assert(IDNAPunycode.decode(String_ASCII("xn--n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa"))
            .assumeOkay == "\u306A\u305C\u307F\u3093\u306A\u65E5\u672C\u8A9E\u3092\u8A71\u3057\u3066\u304F\u308C\u306A\u3044\u306E\u304B");
    assert(IDNAPunycode.decode(String_ASCII("xn--989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c")).assumeOkay == "\uC138\uACC4\uC758\uBAA8\uB4E0\uC0AC\uB78C\uB4E4\uC774\uD55C\uAD6D\uC5B4\uB97C\uC774\uD574\uD55C\uB2E4\uBA74\uC5BC\uB9C8\uB098\uC88B\uC744\uAE4C");
    assert(IDNAPunycode.decode(String_ASCII("xn--b1abfaaepdrnnbgefbaDotcwatmq2g4l")).assumeOkay == "\u043F\u043E\u0447\u0435\u043C\u0443\u0436\u0435\u043E\u043D\u0438\u043D\u0435\u0433\u043E\u0432\u043E\u0440\u044F\u0442\u043F\u043E\u0440\u0443\u0441\u0441\u043A\u0438");
    assert(IDNAPunycode.decode(String_ASCII("xn--PorqunopuedensimplementehablarenEspaol-fmd56a")).assumeOkay == "\u0050\u006F\u0072\u0071\u0075\u00E9\u006E\u006F\u0070\u0075\u0065\u0064\u0065\u006E\u0073\u0069\u006D\u0070\u006C\u0065\u006D\u0065\u006E\u0074\u0065\u0068\u0061\u0062\u006C\u0061\u0072\u0065\u006E\u0045\u0073\u0070\u0061\u00F1\u006F\u006C");
    assert(IDNAPunycode.decode(String_ASCII("xn--TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g")).assumeOkay == "\u0054\u1EA1\u0069\u0073\u0061\u006F\u0068\u1ECD\u006B\u0068\u00F4\u006E\u0067\u0074\u0068\u1EC3\u0063\u0068\u1EC9\u006E\u00F3\u0069\u0074\u0069\u1EBF\u006E\u0067\u0056\u0069\u1EC7\u0074");
    assert(IDNAPunycode.decode(String_ASCII("xn--3B-ww4c5e180e575a65lsy2b"))
            .assumeOkay == "\u0033\u5E74\u0042\u7D44\u91D1\u516B\u5148\u751F");
    assert(IDNAPunycode.decode(String_ASCII("xn---with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n")).assumeOkay == "\u5B89\u5BA4\u5948\u7F8E\u6075\u002D\u0077\u0069\u0074\u0068\u002D\u0053\u0055\u0050\u0045\u0052\u002D\u004D\u004F\u004E\u004B\u0045\u0059\u0053");
    assert(IDNAPunycode.decode(String_ASCII("xn--Hello-Another-Way--fc4qua05auwb3674vfr0b")).assumeOkay == "\u0048\u0065\u006C\u006C\u006F\u002D\u0041\u006E\u006F\u0074\u0068\u0065\u0072\u002D\u0057\u0061\u0079\u002D\u305D\u308C\u305E\u308C\u306E\u5834\u6240");
    assert(IDNAPunycode.decode(String_ASCII("xn--2-u9tlzr9756bt3uc0v")).assumeOkay == "\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B\u0032");
    assert(IDNAPunycode.decode(String_ASCII("xn--MajiKoi5-783gue6qz075azm5e"))
            .assumeOkay == "\u004D\u0061\u006A\u0069\u3067\u004B\u006F\u0069\u3059\u308B\u0035\u79D2\u524D");
    assert(IDNAPunycode.decode(String_ASCII("xn--de-jg4avhby1noc0d")).assumeOkay == "\u30D1\u30D5\u30A3\u30FC\u0064\u0065\u30EB\u30F3\u30D0");
    assert(IDNAPunycode.decode(String_ASCII("xn--d9juau41awczczp")).assumeOkay == "\u305D\u306E\u30B9\u30D4\u30FC\u30C9\u3067");
    assert(IDNAPunycode.decode(String_ASCII("xn---> $1.00 <--"))
            .assumeOkay == "\u002D\u003E\u0020\u0024\u0031\u002E\u0030\u0030\u0020\u003C\u002D");
    assert(IDNAPunycode.decode(String_ASCII("xn--")).assumeOkay == "");
}

///
unittest {
    assert(IDNAPunycode.encode(String_UTF8("Hello \u9EDEWorld!")).assumeOkay == "xn--Hello World!-wi44b");
    assert(IDNAPunycode.encode(String_UTF8(
            "\u0644\u064A\u0647\u0645\u0627\u0628\u062A\u0643\u0644\u0645\u0648\u0634\u0639\u0631\u0628\u064A\u061F"))
            .assumeOkay == "xn--egbpdaj6bu4bxfgehfvwxn");
    assert(IDNAPunycode.encode(String_UTF8("\u4ED6\u4EEC\u4E3A\u4EC0\u4E48\u4E0D\u8BF4\u4E2D\u6587"))
            .assumeOkay == "xn--ihqwcrb4cv8a8dqg056pqjye");
    assert(IDNAPunycode.encode(String_UTF8("\u4ED6\u5011\u7232\u4EC0\u9EBD\u4E0D\u8AAA\u4E2D\u6587"))
            .assumeOkay == "xn--ihqwctvzc91f659drss3x8bo0yb");
    assert(IDNAPunycode.encode(String_UTF8("\u0050\u0072\u006F\u010D\u0070\u0072\u006F\u0073\u0074\u011B\u006E\u0065\u006D\u006C\u0075\u0076\u00ED\u010D\u0065\u0073\u006B\u0079"))
            .assumeOkay == "xn--Proprostnemluvesky-uyb24dma41a");
    assert(IDNAPunycode.encode(String_UTF8("\u05DC\u05DE\u05D4\u05D4\u05DD\u05E4\u05E9\u05D5\u05D8\u05DC\u05D0\u05DE\u05D3\u05D1\u05E8\u05D9\u05DD\u05E2\u05D1\u05E8\u05D9\u05EA"))
            .assumeOkay == "xn--4dbcagdahymbxekheh6e0a7fei0b");
    assert(IDNAPunycode.encode(String_UTF8("\u092F\u0939\u0932\u094B\u0917\u0939\u093F\u0928\u094D\u0926\u0940\u0915\u094D\u092F\u094B\u0902\u0928\u0939\u0940\u0902\u092C\u094B\u0932\u0938\u0915\u0924\u0947\u0939\u0948\u0902"))
            .assumeOkay == "xn--i1baa7eci9glrd9b2ae1bj0hfcgg6iyaf8o0a1dig0cd");
    assert(IDNAPunycode.encode(String_UTF8(
            "\u306A\u305C\u307F\u3093\u306A\u65E5\u672C\u8A9E\u3092\u8A71\u3057\u3066\u304F\u308C\u306A\u3044\u306E\u304B"))
            .assumeOkay == "xn--n8jok5ay5dzabd5bym9f0cm5685rrjetr6pdxa");
    assert(IDNAPunycode.encode(String_UTF8("\uC138\uACC4\uC758\uBAA8\uB4E0\uC0AC\uB78C\uB4E4\uC774\uD55C\uAD6D\uC5B4\uB97C\uC774\uD574\uD55C\uB2E4\uBA74\uC5BC\uB9C8\uB098\uC88B\uC744\uAE4C"))
            .assumeOkay == "xn--989aomsvi5e83db1d2a355cv1e0vak1dwrv93d5xbh15a0dt30a5jpsd879ccm6fea98c");
    assert(IDNAPunycode.encode(String_UTF8("\u043F\u043E\u0447\u0435\u043C\u0443\u0436\u0435\u043E\u043D\u0438\u043D\u0435\u0433\u043E\u0432\u043E\u0440\u044F\u0442\u043F\u043E\u0440\u0443\u0441\u0441\u043A\u0438"))
            .assumeOkay == "xn--b1abfaaepdrnnbgefbadotcwatmq2g4l");
    assert(IDNAPunycode.encode(String_UTF8("\u0050\u006F\u0072\u0071\u0075\u00E9\u006E\u006F\u0070\u0075\u0065\u0064\u0065\u006E\u0073\u0069\u006D\u0070\u006C\u0065\u006D\u0065\u006E\u0074\u0065\u0068\u0061\u0062\u006C\u0061\u0072\u0065\u006E\u0045\u0073\u0070\u0061\u00F1\u006F\u006C"))
            .assumeOkay == "xn--PorqunopuedensimplementehablarenEspaol-fmd56a");
    assert(IDNAPunycode.encode(String_UTF8("\u0054\u1EA1\u0069\u0073\u0061\u006F\u0068\u1ECD\u006B\u0068\u00F4\u006E\u0067\u0074\u0068\u1EC3\u0063\u0068\u1EC9\u006E\u00F3\u0069\u0074\u0069\u1EBF\u006E\u0067\u0056\u0069\u1EC7\u0074"))
            .assumeOkay == "xn--TisaohkhngthchnitingVit-kjcr8268qyxafd2f1b9g");
    assert(IDNAPunycode.encode(String_UTF8("\u0033\u5E74\u0042\u7D44\u91D1\u516B\u5148\u751F")).assumeOkay == "xn--3B-ww4c5e180e575a65lsy2b");
    assert(IDNAPunycode.encode(String_UTF8("\u5B89\u5BA4\u5948\u7F8E\u6075\u002D\u0077\u0069\u0074\u0068\u002D\u0053\u0055\u0050\u0045\u0052\u002D\u004D\u004F\u004E\u004B\u0045\u0059\u0053"))
            .assumeOkay == "xn---with-SUPER-MONKEYS-pc58ag80a8qai00g7n9n");
    assert(IDNAPunycode.encode(String_UTF8("\u0048\u0065\u006C\u006C\u006F\u002D\u0041\u006E\u006F\u0074\u0068\u0065\u0072\u002D\u0057\u0061\u0079\u002D\u305D\u308C\u305E\u308C\u306E\u5834\u6240"))
            .assumeOkay == "xn--Hello-Another-Way--fc4qua05auwb3674vfr0b");
    assert(IDNAPunycode.encode(String_UTF8("\u3072\u3068\u3064\u5C4B\u6839\u306E\u4E0B\u0032")).assumeOkay == "xn--2-u9tlzr9756bt3uc0v");
    assert(IDNAPunycode.encode(String_UTF8("\u004D\u0061\u006A\u0069\u3067\u004B\u006F\u0069\u3059\u308B\u0035\u79D2\u524D"))
            .assumeOkay == "xn--MajiKoi5-783gue6qz075azm5e");
    assert(IDNAPunycode.encode(String_UTF8("\u30D1\u30D5\u30A3\u30FC\u0064\u0065\u30EB\u30F3\u30D0")).assumeOkay == "xn--de-jg4avhby1noc0d");
    assert(IDNAPunycode.encode(String_UTF8("\u305D\u306E\u30B9\u30D4\u30FC\u30C9\u3067")).assumeOkay == "xn--d9juau41awczczp");
    assert(IDNAPunycode.encode(String_UTF8("\u002D\u003E\u0020\u0024\u0031\u002E\u0030\u0030\u0020\u003C\u002D"))
            .assumeOkay == "-> $1.00 <-");
    assert(IDNAPunycode.encode(String_UTF8("")).assumeOkay == "");
}
