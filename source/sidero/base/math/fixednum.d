/**
Fixed sized unsigned integer.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
*/
module sidero.base.math.fixednum;

/**
Fixed sized unsigned big integer implementation.

opBinary_Support_ulong:
    - <<
    - >>
    - &
    - +

opOpAssign_Support_BigInt:
    - <<
    - >>
    - &
    - +
    - *
    - ^
    - ^^
    - |
 */
struct FixedUNum(size_t ByteCount) {
    private {
        static assert((ByteCount > 0) && ((ByteCount & (~ByteCount + 1)) == ByteCount) && ByteCount >= 16,
                "FixedUnum!ByteCount must have ByteCount that is power of 2 and equal or above to 16.");

        enum {
            BytesPerSide = ByteCount / 2,
            TotalBits = ByteCount * 8,
            BitsPerSide = TotalBits / 2,
            BitsPerSideHalf = TotalBits / 4,
        }

        static if (ByteCount == 16) {
            ulong upper, lower;
        } else {
            FixedUNum!BytesPerSide upper, lower;
        }
    }

@safe nothrow @nogc pure:

    static if (ByteCount == 16) {
        ///
        this(ulong lower, ulong upper = 0) {
            this.lower = lower;
            this.upper = upper;
        }
    } else {
        ///
        this(ulong lower) {
            this.lower = FixedUNum!BytesPerSide(lower);
        }

        ///
        this(FixedUNum!BytesPerSide lower, FixedUNum!BytesPerSide upper = FixedUNum!BytesPerSide.init) {
            this.lower = lower;
            this.upper = upper;
        }
    }

    ///
    void opAssign(ulong lower) {
        this.lower = lower;
        this.upper = 0;
    }

    ///
    void opAssign(FixedUNum!ByteCount other) {
        this.lower = other.lower;
        this.upper = other.upper;
    }

    ///
    FixedUNum!ByteCount opBinary(string op)(ulong value) {
        FixedUNum!ByteCount ret = this;
        ret.opOpAssign!(op)(value);
        return ret;
    }

    ///
    FixedUNum!ByteCount opBinary(string op)(FixedUNum!ByteCount other) {
        FixedUNum!ByteCount ret = this;
        ret.opOpAssign!(op)(other);
        return ret;
    }

    ///
    void opOpAssign(string op)(ulong value) {
        static if (op == "<<") {
            if (value >= TotalBits) {
                this.upper = 0;
                this.lower = 0;
                return;
            } else if (value >= BitsPerSide) {
                this.upper = this.lower;
                this.lower = 0;
                if (value > BitsPerSide)
                    value -= BitsPerSide;
            }

            if (value > 0) {
                this.upper <<= value;
                if (value + 1 < BitsPerSide) {
                    foreach (i; 0 .. value)
                        this.upper |= (this.lower & (1 << (BitsPerSide - value))) >> (BitsPerSide - (value + 1));
                }
                this.lower <<= value;
            }
        } else static if (op == ">>") {
            if (value >= TotalBits) {
                this.upper = 0;
                this.lower = 0;
                return;
            } else if (value >= BitsPerSide) {
                this.lower = this.upper;
                this.upper = 0;
                if (value > BitsPerSide)
                    value -= BitsPerSide;
            }

            if (value > 0) {
                this.lower >>= value;
                if (value + 1 < BitsPerSide) {
                    foreach (i; 0 .. value)
                        this.lower |= (this.upper & (1 << i)) << (BitsPerSide - (value + 1));
                }
                this.upper >>= value;
            }
        } else static if (op == "&") {
            this.lower &= value;
            this.upper = 0;
        } else static if (op == "+") {
            this.lower += value;
            if (this.lower < value)
                this.upper++;
        } else
            static assert(0, "unknown op");
    }

    ///
    void opOpAssign(string op)(FixedUNum!ByteCount other) {
        static if (op == "+") {
            this.upper += other.upper;
            this.lower += other.lower;
            if (this.lower < other.lower)
                this.upper++;
        } else static if (op == "*") {
            typeof(upper) u1 = this.lower & typeof(upper).max, v1 = other.lower & typeof(upper).max, t = u1 * v1,
                w3 = t & typeof(upper).max, k = t >> BitsPerSideHalf;

            this.lower >>= BitsPerSideHalf;
            t = (this.lower * v1) + k;
            k = (t & typeof(upper).max);
            typeof(upper) w1 = t >> BitsPerSideHalf;

            other.lower >>= BitsPerSideHalf;
            t = (u1 * other.lower) + k;
            k = t >> BitsPerSideHalf;

            this.upper = (this.lower * other.lower) + w1 + k;
            this.lower = (t << BitsPerSideHalf) + w3;

            this.upper += (this.upper * other.lower) + (this.lower * other.upper);
        } else static if (op == "^^") {
            FixedUNum!ByteCount by = this;
            FixedUNum!ByteCount counter = FixedUNum!ByteCount(0);

            while (counter < other) {
                this *= by;
                counter += FixedUNum!ByteCount(1);
            }
        } else static if (op == "&") {
            this.upper &= other.upper;
            this.lower &= other.lower;
        } else static if (op == "^") {
            this.upper ^= other.upper;
            this.lower ^= other.lower;
        } else static if (op == "|") {
            this.upper |= other.upper;
            this.lower |= other.lower;
        } else
            static assert(0, "unkown op");
    }

    ///
    int opCmp(FixedUNum!ByteCount other) {
        if (other.upper > this.upper)
            return -1;
        else if (other.upper < this.upper)
            return 1;
        else if (other.lower > this.lower)
            return -1;
        else if (other.lower < this.lower)
            return 1;
        else
            return 0;
    }

    @property {
        static if (ByteCount == 16) {
            enum {
                ///
                min = 0,
                ///
                max = 0xFFFFFFFF
            }
        } else static if (ByteCount == 32) {
            enum {
                ///
                min = FixedUNum!ByteCount(0),
                ///
                max = FixedUNum!ByteCount(FixedUNum!BytesPerSide(0xFFFFFFFF, 0xFFFFFFFF),
                        FixedUNum!BytesPerSide(0xFFFFFFFF, 0xFFFFFFFF))
            }
        } else static if (ByteCount > 32) {
            enum {
                ///
                min = FixedUNum!ByteCount(0),
                ///
                max = FixedUNum!ByteCount(FixedUNum!BytesPerSide.max, FixedUNum!BytesPerSide.max)
            }
        }

        ///
        ubyte[ByteCount] bytes() {
            ubyte[ByteCount] ret;

            static if (ByteCount == 16) {
                import std.bitmanip : nativeToLittleEndian;

                ret[0 .. 8] = nativeToLittleEndian(this.lower);
                ret[8 .. 16] = nativeToLittleEndian(this.upper);
            } else {
                ret[0 .. ByteCount / 2] = this.lower.bytes;
                ret[ByteCount / 2 .. ByteCount] = this.upper.bytes;
            }

            return ret;
        }

        ///
        ubyte getFirstByte() {
            static if (ByteCount == 16) {
                import std.bitmanip : nativeToLittleEndian;
                return nativeToLittleEndian(this.lower)[0];
            } else
                return this.lower.getFirstByte();
        }
    }
}

///
unittest {
    auto v16 = FixedUNum!16(170);
    assert(v16.bytes == [170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    v16 >>= 2;
    assert(v16.bytes == [42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    v16 >>= 2;
    assert(v16.bytes == [10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);
    v16 <<= 2;
    assert(v16.bytes == [40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    auto v32 = FixedUNum!32(170);
    assert(v32.bytes == [
            170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
    v32 >>= 2;
    assert(v32.bytes == [
            42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
    v32 >>= 2;
    assert(v32.bytes == [
            10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
    v32 <<= 2;
    assert(v32.bytes == [
            40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);

    auto v64 = FixedUNum!64(170);
    assert(v64.bytes == [
            170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
    v64 >>= 2;
    assert(v64.bytes == [
            42, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
    v64 >>= 2;
    assert(v64.bytes == [
            10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
    v64 <<= 2;
    assert(v64.bytes == [
            40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            ]);
}
