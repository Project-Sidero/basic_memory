module sidero.base.math.fixedpoint;
import sidero.base.math.bigint : BigInteger, BitsPerInteger, MaxDigitsPerInteger;

alias FP10_3 = FixedPoint!(10, 3);

struct FixedPoint(size_t NumberOfWholeDigits, size_t NumberOfFractionalDigits) {
    enum {
        NumberOfWholeBits = (NumberOfWholeDigits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger,
        NumberOfFractionalBits = (NumberOfFractionalDigits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger,
        NumberOfBits = NumberOfWholeBits + NumberOfFractionalBits,
        TotalNumberOfDigitsInStorage = (NumberOfBits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger,
    }

    BigInteger!TotalNumberOfDigitsInStorage storage;

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
    DoubleMaxDigits = 17,
    DoubleMaxPrecision = 100_000_000_000_000_000,
    DoubleMaxPrecisionMultiplier = DoubleMaxPrecision / 10,
    DoubleMaxDigitsToRepresent = 309,
}
