module sidero.base.math.fixedpoint;
import sidero.base.math.bigint : BigInteger, BigInteger_Double, BitsPerInteger, MaxDigitsPerInteger;

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
    this(double input) {
        bool truncated;
        this.__ctor(input, truncated);
    }

    ///
    this(double input, out bool truncated) {
        import core.stdc.math : frexp, round;
        import core.bitop : bsr, bsf;

        ulong significandInteger;
        int exponent;

        {
            // extract the significand of input so it is between 0..1
            int originalExponent;
            double significand = frexp(input, &originalExponent);

            if(significand < 0) {
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
                amountAbove = lastNonZeroBit >= NumberOfFractionalBits ? (lastNonZeroBit - NumberOfFractionalBits) : 0;

            if(-(exponent - amountAbove) >= NumberOfFractionalBits) {
                // -51 - 1 = -52 = 52 >= 9 = true
                truncated = true;
            } else if(exponent - amountAbove >= NumberOfWholeBits) {
                // 3 - 0 = -3 >= 9 = false
                truncated = true;
            }

            if(amountAbove > 0) {
                // if we are above the fractional portion already, lets bring us back down to 0..1
                significandInteger >>= amountAbove;
            }
        }

        this.storage = typeof(this.storage)(significandInteger);

        if (exponent > 0) {
            this.storage <<= exponent;
        } else {
            this.storage >>= -exponent;
        }
    }

    ///
    double asDouble(out bool truncated) scope const {
        import core.stdc.math : ldexp;

        double significand = 0;
        long significandInteger;
        int exponent;

        // first get our representation to be (0 .. 1) * 2^exponent
        const firstNonZeroBit = storage.firstNonZeroBitLSB;
        BigInteger!TotalNumberOfDigitsInStorage temp = this.storage;

        if(firstNonZeroBit > 0) {
            // 666 = 0010 1001 1010 | 0000 0
            // firstNonZeroBit = 7
            // NumberOfFractionalBits = 5

            // calculate the exponent
            if(firstNonZeroBit > NumberOfFractionalBits + 1) {
                // 7 - (5 + 1) = 7 - 6 = 1
                exponent = cast(int)(firstNonZeroBit - (NumberOfFractionalBits + 1));
            } else {
                exponent = cast(int)-firstNonZeroBit;
            }

            // move least set bit to be bit 0
            temp >>= firstNonZeroBit;

            // are we truncated?
            truncated = temp >= DoubleMaxPrecision;

            {
                size_t inputBitCount, outputBitCount, offset;

                while(inputBitCount < DoublePrecisionBitCount && offset < temp.storage.length) {
                    size_t canDo = BitsPerInteger;
                    if(canDo > outputBitCount - DoublePrecisionBitCount)
                        canDo = outputBitCount - DoublePrecisionBitCount;

                    const mask = (ulong(1) << (canDo + 1)) - 1;

                    significandInteger = ((temp.storage[offset++] & mask) >> inputBitCount) << outputBitCount;
                    inputBitCount += canDo;
                    outputBitCount += canDo;
                }
            }

            if(storage.isNegative)
                significandInteger *= -1;

            significand = cast(double)significandInteger;
        }

        return ldexp(significand, exponent);
    }
}

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

private:

enum {
    DoublePrecisionBitCount = 53,
    DoubleMaxPrecision = 100_000_000_000_000_000,
}
