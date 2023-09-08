module sidero.base.math.fixedpoint;
import sidero.base.math.bigint : BigInteger, BigInteger_Double, BitsPerInteger, MaxDigitsPerInteger, PerIntegerType;

export @safe nothrow @nogc:

///
alias FixedPoint_Double = FixedPoint!(309, 309);

///
struct FixedPoint(size_t NumberOfWholeDigits, size_t NumberOfFractionalDigits) {
    enum {
        ///
        NumberOfWholeBits = (NumberOfWholeDigits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger,
        ///
        NumberOfFractionalBits = (NumberOfFractionalDigits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger,
        ///
        NumberOfBits = NumberOfWholeBits + NumberOfFractionalBits,
        ///
        TotalNumberOfDigitsInStorage = (NumberOfBits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger,
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
