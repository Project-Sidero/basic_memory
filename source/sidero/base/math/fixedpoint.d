module sidero.base.math.fixedpoint;
import sidero.base.math.bigint : BigInteger, BigInteger_Double, BitsPerInteger, MaxDigitsPerInteger, PerIntegerType;
import sidero.base.text;

export @safe nothrow @nogc:

///
alias FixedPoint_1_0 = FixedPoint!(1, 0);
///
alias FixedPoint_1_1 = FixedPoint!(1, 1);
///
alias FixedPoint_Double = FixedPoint!(309, 309);

///
struct FixedPoint(size_t NumberOfWholeDigits, size_t NumberOfFractionalDigits) {
    private {
        import std.algorithm : min;
    }

    enum {
        ///
        NumberOfWholeBits = cast(size_t)(((NumberOfWholeDigits + MaxDigitsPerInteger - 1f) / MaxDigitsPerInteger) * BitsPerInteger),
        ///
        NumberOfFractionalBits = cast(
                size_t)(((NumberOfFractionalDigits + MaxDigitsPerInteger - 1f) / MaxDigitsPerInteger) * BitsPerInteger),
        ///
        NumberOfBits = NumberOfWholeBits + NumberOfFractionalBits,
        ///
        TotalNumberOfDigitsInStorage = NumberOfBits / BitsPerInteger,
        ///
        RealNumberOfWholeDigits = NumberOfWholeBits / BitsPerInteger,
        ///
        RealNumberOfFractionalDigits = NumberOfFractionalDigits / BitsPerInteger,
        ///
        TotalRealNumberOfDigits = RealNumberOfWholeDigits + RealNumberOfFractionalDigits,
    }
    enum {
        ///
        HalfDoubleFractionalDigits = min(1, NumberOfFractionalDigits),
        ///
        DoubleFractionalDigits = HalfDoubleFractionalDigits * 2,
        ///
        DoubleNumberOfFractionalBits = cast(
                size_t)(((DoubleFractionalDigits + MaxDigitsPerInteger - 1f) / MaxDigitsPerInteger) * BitsPerInteger),
        ///
        DoubleNumberOfWholeDigits = NumberOfWholeDigits * 2,
        ///
        DoubleNumberOfWholeBits = cast(size_t)(
                ((DoubleNumberOfWholeDigits + MaxDigitsPerInteger - 1f) / MaxDigitsPerInteger) * BitsPerInteger),
        ///
        DoubleNumberOfBits = DoubleNumberOfWholeBits + DoubleNumberOfFractionalBits,
        ///
        DoubleTotalDigits = DoubleNumberOfBits / BitsPerInteger,
    }
    enum {
        ///
        WholePlusDoubleNumberOfFractionalBits = NumberOfWholeBits + DoubleNumberOfFractionalBits,
        ///
        WholePlusDoubleFractionalDigits = WholePlusDoubleNumberOfFractionalBits / BitsPerInteger,
    }

    ///
    BigInteger!TotalNumberOfDigitsInStorage storage;

@safe nothrow @nogc:

    ///
    this(size_t OtherNumberOfWholeDigits, size_t OtherNumberOfFractionalDigits)(
            return scope ref const FixedPoint!(OtherNumberOfWholeDigits, OtherNumberOfFractionalDigits) other) scope {
        static assert(OtherNumberOfWholeDigits <= NumberOfWholeDigits, "Argument number of whole digits must be less than or equal to ours");
        static assert(OtherNumberOfFractionalDigits <= NumberOfFractionalDigits,
                "Argument number of fractional digits must be less than or equal to ours");

        this.tupleof = other.tupleof;

        static if(NumberOfFractionalBits != other.NumberOfFractionalBits) {
            this.storage <<= NumberOfFractionalBits - other.NumberOfFractionalBits;
        }
    }

    export {
        ///
        this(double input) {
            bool truncated;
            this.__ctor(input, truncated);
        }

        ///
        this(double input, out bool truncated) {
            loadFromDouble(this.storage.storage[], this.storage.isNegative, input, NumberOfWholeBits, NumberOfFractionalBits, truncated);
        }

        ///
        double asDouble(out bool truncated) scope const {
            BigInteger!TotalNumberOfDigitsInStorage temp = this.storage;
            return .asDouble(temp.storage[], this.storage.isNegative, NumberOfFractionalBits, truncated);
        }
    }

    ///
    FixedPoint opUnary(string op : "-")() scope const {
        FixedPoint ret = this;
        ret.storage.isNegative = !ret.storage.isNegative;
        return ret;
    }

    ///
    void opOpAssign(string op : "*", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope {
        import sidero.base.math.bigint : unsignedAddition;

        static assert(NumberOfWholeDigits >= OtherWholeDigits, "Multiplier whole digits must be less than or equal to whole digits");
        static assert(HalfDoubleFractionalDigits >= OtherFractionalDigits,
                "Multiplier fractional digits must be less than or equal to fractional digits (minimum of 1)");

        BigInteger!DoubleTotalDigits working = this.storage, input = other.storage;
        working <<= HalfDoubleFractionalDigits;
        unsignedAddition(working.storage[], 1, HalfDoubleFractionalDigits - 1);
        input <<= DoubleFractionalDigits - OtherFractionalDigits;

        working *= input;
        working >>= HalfDoubleFractionalDigits;

        foreach(i, ref v; this.storage.storage) {
            v = working.storage[i];
        }

        if(working.lastNonZeroBitLSB >= NumberOfBits)
            this.storage.wasOverflown = true;
    }

    ///
    FixedPoint opBinary(string op : "*", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope const {
        FixedPoint ret = this;
        ret *= other;
        return ret;
    }

    ///
    void opOpAssign(string op : "/", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope {
        static assert(NumberOfWholeDigits >= OtherWholeDigits, "Divisor whole digits must be less than or equal to whole digits");
        static assert(HalfDoubleFractionalDigits >= OtherFractionalDigits,
                "Divisor fractional digits must be less than or equal to fractional digits (minimum of 1)");

        BigInteger!WholePlusDoubleFractionalDigits working = this.storage, input = other.storage;
        working <<= HalfDoubleFractionalDigits;
        input <<= DoubleFractionalDigits - OtherFractionalDigits;

        working += input / 2;
        working /= input;
        working >>= HalfDoubleFractionalDigits;

        foreach(i, ref v; this.storage.storage) {
            v = working.storage[i];
        }
    }

    ///
    FixedPoint opBinary(string op : "/", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope const {
        FixedPoint ret = this;
        ret /= other;
        return ret;
    }

    ///
    void opOpAssign(string op : "%", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope {
        static assert(NumberOfWholeDigits >= OtherWholeDigits, "Modulas whole digits must be less than or equal to whole digits");
        static assert(HalfDoubleFractionalDigits >= OtherFractionalDigits,
                "Modulas fractional digits must be less than or equal to fractional digits (minimum of 1)");

        BigInteger!WholePlusDoubleFractionalDigits working = this.storage, input = other.storage;
        working <<= HalfDoubleFractionalDigits;
        input <<= DoubleFractionalDigits - OtherFractionalDigits;

        working %= input;
        working >>= HalfDoubleFractionalDigits;

        foreach(i, ref v; this.storage.storage) {
            v = working.storage[i];
        }
    }

    ///
    FixedPoint opBinary(string op : "%", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope const {
        FixedPoint ret = this;
        ret %= other;
        return ret;
    }

    ///
    void opOpAssign(string op : "+", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope {
        static assert(NumberOfWholeDigits >= OtherWholeDigits, "Modulas whole digits must be less than or equal to whole digits");
        static assert(HalfDoubleFractionalDigits >= OtherFractionalDigits,
                "Modulas fractional digits must be less than or equal to fractional digits (minimum of 1)");

        this.storage += other.storage;
    }

    ///
    FixedPoint opBinary(string op : "+", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope const {
        FixedPoint ret = this;
        ret += other;
        return ret;
    }

    ///
    void opOpAssign(string op : "-", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope {
        static assert(NumberOfWholeDigits >= OtherWholeDigits, "Modulas whole digits must be less than or equal to whole digits");
        static assert(HalfDoubleFractionalDigits >= OtherFractionalDigits,
                "Modulas fractional digits must be less than or equal to fractional digits (minimum of 1)");

        this.storage -= other.storage;
    }

    ///
    FixedPoint opBinary(string op : "-", size_t OtherWholeDigits, size_t OtherFractionalDigits)(FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope const {
        FixedPoint ret = this;
        ret -= other;
        return ret;
    }

    ///
    int opEquals(size_t OtherWholeDigits, size_t OtherFractionalDigits)(scope const FixedPoint!(OtherWholeDigits,
            OtherFractionalDigits) other) scope const {
        return this.storage.opCmp(other.storage) == 0;
    }

    ///
    int opCmp(size_t OtherWholeDigits, size_t OtherFractionalDigits)(scope const FixedPoint!(OtherWholeDigits, OtherFractionalDigits) other) scope const {
        return this.storage.opCmp(other.storage);
    }

    export {
        ///
        ulong toHash() scope const {
            return this.storage.toHash();
        }

        ///
        String_UTF8 toString() scope const {
            String_UTF8 ret;

            toStringImpl((scope char[] buffer) @trusted  { ret = String_UTF8(buffer).dup; });

            return ret;
        }

        ///
        void toString(scope ref StringBuilder_UTF8 builder) scope const {
            toStringImpl((scope char[] buffer) @trusted  { builder ~= String_UTF8(buffer); });
        }

        ///
        void toString(scope ref StringBuilder_UTF16 builder) scope const {
            toStringImpl((scope char[] buffer) @trusted  { builder ~= String_UTF8(buffer); });
        }

        ///
        void toString(scope ref StringBuilder_UTF32 builder) scope const {
            toStringImpl((scope char[] buffer) @trusted  { builder ~= String_UTF8(buffer); });
        }

        ///
        static FixedPoint parseHex(scope String_UTF8.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static FixedPoint parseHex(scope String_UTF8.LiteralType input, out bool truncated) {
            FixedPoint ret;
            parse16Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);
            return ret;
        }

        ///
        static FixedPoint parseHex(scope String_UTF16.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static FixedPoint parseHex(scope String_UTF16.LiteralType input, out bool truncated) {
            FixedPoint ret;
            parse16Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);
            return ret;
        }

        ///
        static FixedPoint parseHex(scope String_UTF32.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static FixedPoint parseHex(scope String_UTF32.LiteralType input, out bool truncated) {
            FixedPoint ret;
            parse16Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);
            return ret;
        }

        ///
        static FixedPoint parseHex(scope String_UTF8 text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static FixedPoint parseHex(scope ref String_UTF8 input, out bool truncated) {
            String_UTF32 s32 = input.byUTF32;

            FixedPoint ret;
            const used = parse16Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static FixedPoint parseHex(scope String_UTF16 text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static FixedPoint parseHex(scope ref String_UTF16 input, out bool truncated) {
            String_UTF32 s32 = input.byUTF32;

            FixedPoint ret;
            const used = parse16Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static FixedPoint parseHex(scope String_UTF32 text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static FixedPoint parseHex(scope ref String_UTF32 input, out bool truncated) {
            String_UTF32 s32 = input.byUTF32;

            FixedPoint ret;
            const used = parse16Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static FixedPoint parse(scope String_UTF8.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static FixedPoint parse(scope String_UTF8.LiteralType input, out bool truncated) {
            FixedPoint ret;
            parse10Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);
            return ret;
        }

        ///
        static FixedPoint parse(scope String_UTF16.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static FixedPoint parse(scope String_UTF16.LiteralType input, out bool truncated) {
            FixedPoint ret;
            parse10Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);
            return ret;
        }

        ///
        static FixedPoint parse(scope String_UTF32.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static FixedPoint parse(scope String_UTF32.LiteralType input, out bool truncated) {
            FixedPoint ret;
            parse10Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);
            return ret;
        }

        ///
        static FixedPoint parse(scope String_UTF8 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static FixedPoint parse(scope ref String_UTF8 input, out bool truncated) {
            String_UTF32 s32 = input.byUTF32;

            FixedPoint ret;
            const used = parse10Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static FixedPoint parse(scope String_UTF16 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static FixedPoint parse(scope ref String_UTF16 input, out bool truncated) {
            String_UTF32 s32 = input.byUTF32;

            FixedPoint ret;
            const used = parse10Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static FixedPoint parse(scope String_UTF32 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static FixedPoint parse(scope ref String_UTF32 input, out bool truncated) {
            String_UTF32 s32 = input.byUTF32;

            FixedPoint ret;
            const used = parse10Impl(ret.storage.storage[], ret.storage.isNegative, input, NumberOfFractionalBits, truncated);

            input = input[used .. $];
            return ret;
        }
    }

private:
    void toStringImpl(scope void delegate(scope char[]) @safe nothrow @nogc del) scope const @safe nothrow @nogc {
        import sidero.base.math.bigint : unsignedDivide;
        import std.algorithm : reverse;

        ubyte[(MaxDigitsPerInteger * storage.storage.length) + 4] buffer = void;
        buffer[0] = '-';
        buffer[1] = '0';
        buffer[2] = '.';
        buffer[3] = '0';

        size_t offset = 1, zeroStreak;
        bool hitNonZero;

        {
            BigInteger!TotalNumberOfDigitsInStorage temp = this.storage;
            BigInteger!3 div = BigInteger!3(10);
            size_t digitCount;

            while(temp != 0) {
                BigInteger!TotalNumberOfDigitsInStorage quotient, modulas;
                bool overflow;
                cast(void)unsignedDivide(quotient.storage[], modulas.storage[], temp.storage[], div.storage[], overflow);

                const digit = modulas.storage[0] & 0xFF;
                assert(digit < 10);

                digitCount++;

                if(digit != 0 || hitNonZero) {
                    buffer[offset++] = cast(char)('0' + digit);
                    hitNonZero = true;
                } else if(digitCount == RealNumberOfWholeDigits && !hitNonZero) {
                    assert(offset == 1);
                    offset += 2;
                }

                if(digit == 0) {
                    zeroStreak++;
                } else {
                    zeroStreak = 0;
                }

                temp = quotient;
            }

            reverse(buffer[1 .. offset]);
        }

        bool excludeNegative = !storage.isNegative;

        if(offset == 1) {
            offset = 4;
            excludeNegative = true;
        } else if(!hitNonZero) {
            assert(offset == 3);
            offset++;
            excludeNegative = true;
        } else {
            // remove any trailing zeros that would be moved to whole side
            assert(offset > zeroStreak);
            offset -= zeroStreak;
        }

        del(cast(char[])buffer[excludeNegative .. offset]);
    }
}

///
void loadFromDouble(scope PerIntegerType[] output, out bool isNegative, double input, size_t numberOfWholeBits,
        size_t numberOfFractionalBits, out bool truncated) {
    import sidero.base.math.bigint : importValue, leftShift, rightShift;
    import core.stdc.math : frexp, round;
    import core.bitop : bsr, bsf;

    ulong significandInteger;
    int exponent;

    {
        // extract the significand of input so it is between 0..1
        int originalExponent;
        double significand = frexp(input, &originalExponent);

        if(significand < 0) {
            isNegative = true;
            significand *= -1;
        }

        // make the entire significand to not be fractional
        significand *= ulong(2) ^^ DoublePrecisionBitCount;
        significandInteger = cast(ulong)round(significand);

        // for 0.1
        // -52 + -3 = -55
        // for 1.0
        // -52 + 1 = -51
        exponent = -DoublePrecisionBitCount + originalExponent;
    }

    {
        // it would probably be a good idea to detect truncation

        // nothing to set
        if(significandInteger == 0)
            return;

        // its 0..64
        const firstNonZeroBit = bsf(significandInteger), lastNonZeroBit = bsr(significandInteger),
            amountAbove = lastNonZeroBit >= numberOfFractionalBits ? (lastNonZeroBit - numberOfFractionalBits) : 0;

        if(-(exponent - amountAbove) >= numberOfFractionalBits) {
            // -51 - 1 = -52 = 52 >= 9 = true
            truncated = true;
        } else if(exponent - amountAbove >= numberOfWholeBits) {
            // 3 - 0 = -3 >= 9 = false
            truncated = true;
        }

        if(amountAbove > 0) {
            // if we are above the fractional portion already, lets bring us back down to 0..1
            significandInteger >>= amountAbove;
        }
    }

    bool tempTruncated;
    importValue(output, significandInteger, tempTruncated);
    if(tempTruncated)
        truncated = true;

    if(exponent > 0) {
        leftShift(output, exponent);
    } else {
        rightShift(output, -exponent);
    }
}

///
double asDouble(scope PerIntegerType[] input, bool isNegative, size_t numberOfFractionalBits, out bool truncated) {
    import sidero.base.math.bigint : rightShift, firstNonZeroBitLSB, lastNonZeroBitLSB;
    import core.stdc.math : ldexp;

    double significand = 0;
    long significandInteger;
    int exponent;

    // first get our representation to be (0 .. 1) * 2^exponent
    const firstNonZeroBit = input.firstNonZeroBitLSB;

    if(firstNonZeroBit > 0) {
        // 666 = 0010 1001 1010 | 0000 0
        // firstNonZeroBit = 7
        // NumberOfFractionalBits = 5

        // calculate the exponent
        if(firstNonZeroBit > numberOfFractionalBits + 1) {
            // 7 - (5 + 1) = 7 - 6 = 1
            exponent = cast(int)(firstNonZeroBit - (numberOfFractionalBits + 1));
        } else {
            exponent = cast(int)-firstNonZeroBit;
        }

        // move least set bit to be bit 0
        rightShift(input, firstNonZeroBit);

        // are we truncated?
        truncated = input.lastNonZeroBitLSB >= DoublePrecisionBitCount;

        {
            size_t inputBitCount, outputBitCount, offset;

            while(inputBitCount < DoublePrecisionBitCount && offset < input.length) {
                size_t canDo = BitsPerInteger;
                if(canDo > outputBitCount - DoublePrecisionBitCount)
                    canDo = outputBitCount - DoublePrecisionBitCount;

                const mask = (ulong(1) << (canDo + 1)) - 1;

                significandInteger = ((input[offset++] & mask) >> inputBitCount) << outputBitCount;
                inputBitCount += canDo;
                outputBitCount += canDo;
            }
        }

        if(isNegative)
            significandInteger *= -1;

        significand = cast(double)significandInteger;
    }

    return ldexp(significand, exponent);
}

///
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8.LiteralType input,
        size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16.LiteralType input,
        size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32.LiteralType input,
        size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8 input, size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16 input, size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32 input, size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF8 input,
        size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF16 input,
        size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF32 input,
        size_t fracBitCount, out bool truncated) {
    return parse16Impl(output, isNegative, input, fracBitCount, truncated);
}

///
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8.LiteralType input,
        size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16.LiteralType input,
        size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32.LiteralType input,
        size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8 input, size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16 input, size_t fracBitCount,
        out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32 input, size_t fracBitCount,
        out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF8 input,
        size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF16 input,
        size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF32 input,
        size_t fracBitCount, out bool truncated) {
    return parse10Impl(output, isNegative, input, fracBitCount, truncated);
}

private:

/*
http://www.coranac.com/tonc/text/fixed.htm

import std;
void main()
{
    int exponent;
    double significand = frexp(12345695, exponent);
    writeln(significand, " ", exponent);
    writefln!"%f"(ldexp(significand, exponent));

    ulong temp = cast(ulong)round(significand * 100_000);
    writeln(temp);

    temp *= cast(ulong)(2 ^^ exponent);
    temp /= 100_000;

    writeln(temp);
}

0.735861 24
12345695.000000
7358608
12345695

double requires 309 digits to represent min/max
*/

enum {
    DoublePrecisionBitCount = 53,
    DoubleMaxPrecision = 100_000_000_000_000_000,
}

size_t parse10Impl(Str)(scope PerIntegerType[] output, out bool isNegative, Str input, size_t fracBitCount, out bool truncated) {
    import sidero.base.allocators;
    import sidero.base.math.bigint : leftShift, rightShift, unsignedMultiply, unsignedAddition, lastNonZeroBitLSB;

    PerIntegerType temp;
    size_t used, digits, wholeBitCount;
    bool hitDot;

    RCAllocator allocator;
    PerIntegerType[64] smallArrayCopy;
    PerIntegerType[] outputArrayBuffer;

    if(output.length > smallArrayCopy.length) {
        allocator = globalAllocator();
        outputArrayBuffer = allocator.makeArray!PerIntegerType(output.length);
    } else
        outputArrayBuffer = smallArrayCopy[0 .. output.length];

    scope(exit) {
        if(!allocator.isNull)
            allocator.dispose(outputArrayBuffer);
    }

    void store(bool force) {
        if(digits == (MaxDigitsPerInteger - 1) || (digits > 0 && force)) {
            PerIntegerType[1] powerTemp = [PerIntegerType(10) ^^ digits];

            foreach(i, v; output)
                outputArrayBuffer[i] = v;

            cast(void)unsignedMultiply(output, outputArrayBuffer, powerTemp, truncated);

            unsignedAddition(output, temp, 0, truncated);

            temp = 0;
            digits = 0;
        }
    }

    foreach(c; input) {
        if(used == 0 && c == '-') {
            used++;
            isNegative = true;
        } else if(c >= '0' && c <= '9') {
            used++;
            digits++;

            temp *= 10;
            temp += cast(PerIntegerType)(c - '0');
        } else if(c == '.' && !hitDot) {
            wholeBitCount = lastNonZeroBitLSB(output);
            hitDot = true;
        } else
            break;

        store(false);
    }

    store(true);

    {
        const currentFracBits = lastNonZeroBitLSB(output) - wholeBitCount;

        if(fracBitCount > currentFracBits) {
            leftShift(output, fracBitCount - currentFracBits);
        } else if(fracBitCount < currentFracBits) {
            truncated = true;
            rightShift(output, currentFracBits - fracBitCount);
        }
    }

    if(used == 1 && isNegative) {
        used = 0;
        isNegative = false;
    }

    return used;
}

size_t parse16Impl(Str)(scope PerIntegerType[] output, out bool isNegative, Str input, size_t fracBitCount, out bool truncated) {
    import sidero.base.math.bigint : leftShift, rightShift, lastNonZeroBitLSB;

    PerIntegerType temp;
    size_t used, count, totalBitCount, wholeBitCount;
    ptrdiff_t offset = output.length - 1;
    bool hitDot;

    void store() {
        if(count >= BitsPerInteger) {
            count -= BitsPerInteger;
            output[offset] = temp >> count;
            offset--;

            temp &= (1 << count) - 1;
            totalBitCount += BitsPerInteger;
        }
    }

    foreach(c; input) {
        if(offset < 0)
            break;

        if(used == 0 && c == '-') {
            used++;
            isNegative = true;
        } else if(c >= '0' && c <= '9') {
            used++;

            temp <<= 4;
            temp |= cast(PerIntegerType)(c - '0');
            count += 4;
        } else if(c >= 'a' && c <= 'f') {
            used++;

            temp <<= 4;
            temp |= cast(PerIntegerType)(c - 'a') + 10;
            count += 4;
        } else if(c >= 'A' && c <= 'F') {
            used++;

            temp <<= 4;
            temp |= cast(PerIntegerType)(c - 'A') + 10;
            count += 4;
        } else if(c == '.' && !hitDot) {
            wholeBitCount = lastNonZeroBitLSB(output);
            hitDot = true;
        } else
            break;

        store();
    }

    if(count > 0 && offset >= 0) {
        const toSet = temp << (BitsPerInteger - count);

        output[offset] = toSet;
        offset--;
        totalBitCount += count;
        count = 0;
    }

    if(count > 0) {
        // we need to left shift because we have bits that we had to truncate before adding the bits on
        leftShift(output, count);
        output[0] |= temp;
        totalBitCount += count;
    } else {
        rightShift(output, (output.length * BitsPerInteger) - totalBitCount);
    }

    {
        const currentFracBits = totalBitCount - wholeBitCount;

        if(fracBitCount > currentFracBits) {
            leftShift(output, fracBitCount - currentFracBits);
        } else if(fracBitCount < currentFracBits) {
            truncated = true;
            rightShift(output, currentFracBits - fracBitCount);
        }
    }

    if(totalBitCount > output.length * BitsPerInteger)
        truncated = true;

    if(used == 1 && isNegative) {
        used = 0;
        isNegative = false;
    }

    return used;
}
