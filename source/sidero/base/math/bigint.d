module sidero.base.math.bigint;
import sidero.base.errors;
import sidero.base.text;
import std.meta : AliasSeq;
import core.bitop : bsr;

export @safe nothrow @nogc:

// http://www.sunshine2k.de/articles/coding/biguint/bigunsignedint.html

///
static if(size_t.sizeof == 4) {
    ///
    alias PerIntegerType = int;
    ///
    enum MaxDigitsPerInteger = 4;
} else static if(size_t.sizeof == 8) {
    ///
    alias PerIntegerType = long;
    ///
    enum MaxDigitsPerInteger = 9;
} else
    static assert(0, "Unimplemented");

///
enum {
    ///
    MaxPerInteger10 = PerIntegerType(10 ^^ MaxDigitsPerInteger),
    ///
    BitsPerInteger = bsr(MaxPerInteger10),
    ///
    PerIntegerMask = (1 << BitsPerInteger) - 1,
    ///
    MaxPerInteger = PerIntegerType(2 ^^ BitsPerInteger),
}

///
alias BigInteger_Bit = BigInteger!1;
///
alias BigInteger_8 = BigInteger!3;
///
alias BigInteger_16 = BigInteger!5;
///
alias BigInteger_32 = BigInteger!10;
///
alias BigInteger_64 = BigInteger!20;
///
alias BigInteger_128 = BigInteger!40;
///
alias BigInteger_256 = BigInteger!80;
///
alias BigInteger_512 = BigInteger!160;
///
alias BigInteger_Double = BigInteger!309;
///
alias BigInteger_1024 = BigInteger!320;

/// Number of digits is base 10, internally the base is target dependent
struct BigInteger(PerIntegerType NumberOfDigits) if (NumberOfDigits > 0) {
    ///
    PerIntegerType[(NumberOfDigits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger] storage;
    ///
    bool isNegative;
    ///
    bool wasOverflown;

    private {
        static BigInteger parseImpl(Str)(Str input, out bool truncated, out size_t used) @safe nothrow @nogc {
            import sidero.base.algorithm : reverse;

            BigInteger ret;

            PerIntegerType temp;
            size_t count, offset;

            foreach(c; input) {
                if(count == NumberOfDigits) {
                    if(count > 0)
                        ret.storage[offset++] = temp;
                    break;
                }

                if(used == 0 && c == '-') {
                    used++;
                    ret.isNegative = true;
                } else if(c >= '0' && c <= '9') {
                    used++;

                    temp *= 10;
                    temp += cast(PerIntegerType)(c - '0');
                    count++;

                    if(count == MaxDigitsPerInteger) {
                        ret.storage[offset++] = temp;
                        count = 0;
                    }
                } else
                    break;
            }

            if(used == 1 && ret.isNegative) {
                used = 0;
                ret.isNegative = false;
            }

            reverse(ret.storage[0 .. offset]);
            return ret;
        }

        static BigInteger parseHexImpl(Str)(Str input, out bool truncated, out size_t used) @safe nothrow @nogc {
            BigInteger ret;

            PerIntegerType temp;
            size_t count, totalBitCount;
            ptrdiff_t offset = ret.storage.length - 1;

            void store() {
                if(count >= BitsPerInteger) {
                    count -= BitsPerInteger;
                    ret.storage[offset] = temp >> count;
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
                    ret.isNegative = true;
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
                } else
                    break;

                store();
            }

            if(count > 0 && offset >= 0) {
                const toSet = temp << (BitsPerInteger - count);

                ret.storage[offset] = toSet;
                offset--;
                totalBitCount += count;
            }

            ret >>= (ret.storage.length * BitsPerInteger) - totalBitCount;

            if(used == 1 && ret.isNegative) {
                used = 0;
                ret.isNegative = false;
            }

            return ret;
        }
    }

    static if(BitsPerInteger >= 64) {
        ///
        alias MaxRepresentableInteger = long;
    } else static if(BitsPerInteger >= 32) {
        ///
        alias MaxRepresentableInteger = int;
    } else static if(BitsPerInteger >= 16) {
        ///
        alias MaxRepresentableInteger = short;
    } else {
        ///
        alias MaxRepresentableInteger = byte;
    }

@safe nothrow @nogc:

    export {
        static foreach(T; AliasSeq!(ubyte, ushort, uint, ulong)) {
            ///
            this(T input) scope {
                bool truncated;
                importValue(this.storage[], input, truncated);
            }

            ///
            this(T input, out bool truncated) scope {
                importValue(this.storage[], input, truncated);
            }
        }

        static foreach(T; AliasSeq!(byte, short, int, long)) {
            ///
            this(T input) scope {
                bool truncated;
                importSignedValue(this.storage[], this.isNegative, input, truncated);
            }

            ///
            this(T input, out bool truncated) scope {
                importSignedValue(this.storage[], this.isNegative, input, truncated);
            }
        }

        ///
        this(size_t OtherDigits)(return scope ref const BigInteger!OtherDigits other) scope {
            static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than or equal to ours");

            static if(OtherDigits == NumberOfDigits) {
                this.tupleof = other.tupleof;
            } else {
                foreach(i, v; other.storage) {
                    this.storage[i] = v;
                }
            }
        }

        ///
        bool hasOverflowed() scope const {
            return wasOverflown;
        }

        static {
            ///
            BigInteger min() {
                BigInteger ret;

                ret.isNegative = true;

                foreach(ref v; ret.storage) {
                    v = PerIntegerMask;
                }

                return ret;
            }

            ///
            BigInteger max() {
                BigInteger ret;

                foreach(ref v; ret.storage) {
                    v = PerIntegerMask;
                }

                return ret;
            }

            ///
            BigInteger negativeOne() {
                return BigInteger(-1);
            }

            ///
            BigInteger zero() {
                return BigInteger(0);
            }

            ///
            BigInteger one() {
                return BigInteger(1);
            }
        }
    }

    ///
    void opOpAssign(string op : "/", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    BigInteger opBinary(string op : "/", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret, remainder;

        auto errorResult = signedDivision(ret.storage[], ret.isNegative, remainder.storage[], ret.isNegative,
                this.storage[], this.isNegative, other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "*", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    BigInteger opBinary(string op : "*", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret;

        auto errorResult = signedMultiply(ret.storage[], ret.isNegative, this.storage[], this.isNegative,
                other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    BigInteger opUnary(string op : "-")() scope const {
        BigInteger ret = cast(BigInteger)this;
        ret.isNegative = !ret.isNegative;
        return ret;
    }

    ///
    BigInteger opUnary(string op : "++")() scope {
        this.opOpAssign!"+"(BigInteger!1(1));
        return this;
    }

    ///
    BigInteger opUnary(string op : "--")() scope {
        this.opOpAssign!"-"(BigInteger!1(1));
        return this;
    }

    ///
    void opOpAssign(string op : "+", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    BigInteger opBinary(string op : "+", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret;

        auto errorResult = signedAddition(ret.storage[], ret.isNegative, this.storage[], this.isNegative,
                other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "-", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    BigInteger opBinary(string op : "-", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret;

        auto errorResult = signedSubtraction(ret.storage[], ret.isNegative, this.storage[], this.isNegative,
                other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "<<")(scope size_t amount) scope {
        leftShift(this.storage[], amount);
    }

    ///
    BigInteger opBinary(string op : "<<")(scope size_t amount) scope const {
        BigInteger ret = cast(BigInteger)this;
        leftShift(ret.storage[], amount);
        return ret;
    }

    ///
    void opOpAssign(string op : ">>")(scope size_t amount) scope {
        rightShift(this.storage[], amount);
    }

    ///
    BigInteger opBinary(string op : ">>")(scope size_t amount) scope const {
        BigInteger ret = cast(BigInteger)this;
        rightShift(ret.storage[], amount);
        return ret;
    }

    ///
    void opOpAssign(string op : "|", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        auto errorInfo = bitwiseOr(this.storage[], other.storage[]);
        assert(errorInfo);
    }

    ///
    BigInteger opBinary(string op : "|", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret = cast(BigInteger)this;

        auto errorInfo = bitwiseOr(ret.storage[], other.storage[]);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "&", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        auto errorInfo = bitwiseAnd(this.storage[], other.storage[]);
        assert(errorInfo);
    }

    ///
    BigInteger opBinary(string op : "&", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret = cast(BigInteger)this;

        auto errorInfo = bitwiseAnd(ret.storage[], other.storage[]);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        auto errorInfo = bitwiseXor(this.storage[], other.storage[]);
        assert(errorInfo);
    }

    ///
    BigInteger opBinary(string op : "^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret = cast(BigInteger)this;

        auto errorInfo = bitwiseXor(ret.storage[], other.storage[]);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "^^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger temp = this;
        auto errorInfo = signedPower(this.storage[], this.isNegative, temp, temp.isNegative, other.storage[],
                other.isNegative, ret.overflow);
        assert(errorInfo);
    }

    ///
    BigInteger opBinary(string op : "^^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope const {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        BigInteger ret = cast(BigInteger)this;

        auto errorInfo = signedPower(ret.storage[], ret.isNegative, this.storage[], this.isNegative, other.storage[],
                other.isNegative, ret.overflow);
        assert(errorInfo);

        return ret;
    }

    export {
        /// Returns zero if all are zero
        size_t firstNonZeroBitLSB() scope const {
            return .firstNonZeroBitLSB(this.storage[]);
        }

        /// Returns zero if all are zero
        size_t lastNonZeroBitLSB() scope const {
            return .lastNonZeroBitLSB(this.storage[]);
        }

        ///
        void opAssign(scope const(PerIntegerType)[] input, bool isNegative, out bool truncated) scope {
            if(input.length > this.storage.length)
                truncated = true;

            foreach(i, v; input) {
                this.storage[i] = v;
            }
        }
    }

    ///
    void opAssign(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        foreach(i, v; other.storage) {
            this.storage[i] = v;
        }
    }

    ///
    void opOpAssign(string op)(MaxRepresentableInteger other) scope {
        this.opOpAssign!op(BigInteger(other));
    }

    ///
    BigInteger opBinary(string op)(MaxRepresentableInteger other) scope const {
        return this.opBinary!op(BigInteger(other));
    }

    ///
    export int opEquals(long other) scope const {
        return opCmp(BigInteger_64(other)) == 0;
    }

    ///
    int opEquals(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope const {
        return signedCompare(this.storage[], this.isNegative, other.storage[], other.isNegative) == 0;
    }

    ///
    export int opCmp(long other) scope const {
        return opCmp(BigInteger_64(other));
    }

    ///
    int opCmp(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope const {
        return signedCompare(this.storage[], this.isNegative, other.storage[], other.isNegative);
    }

    export {
        ///
        ulong toHash() scope const {
            import sidero.base.hash.utils : hashOf;

            scope temp = this.storage[];
            return hashOf(temp);
        }

        ///
        String_UTF8 toString() scope const {
            import std.algorithm : reverse;

            ubyte[(MaxDigitsPerInteger * storage.length) + 1] buffer = void;
            buffer[0] = '-';
            buffer[1] = '0';

            size_t offset = 1;

            foreach_reverse(PerIntegerType v; this.storage) {
                if(offset == 1 && v == 0)
                    continue;

                size_t start = offset, end = offset;

                foreach(digitPower; 0 .. MaxDigitsPerInteger) {
                    const digit = v % 10;
                    v /= 10;

                    buffer[offset++] = cast(char)('0' + digit);
                    end++;
                }

                reverse(buffer[start .. end]);
            }

            bool excludeNegative = !this.isNegative;

            if(offset == 1) {
                offset++;
                excludeNegative = true;
            }

            return String_UTF8(cast(char[])buffer[excludeNegative .. offset]).dup;
        }

        ///
        static BigInteger parseHex(scope String_UTF8.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope ref String_UTF8.LiteralType text, out bool truncated) {
            size_t used;
            return parseHexImpl(text, truncated, used);
        }

        ///
        static BigInteger parse(scope String_UTF8.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF8.LiteralType text, out bool truncated) {
            size_t used;
            return parseImpl(text, truncated, used);
        }

        ///
        static BigInteger parse(scope String_UTF16.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF16.LiteralType text, out bool truncated) {
            size_t used;
            return parseImpl(text, truncated, used);
        }

        ///
        static BigInteger parse(scope String_UTF32.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF32.LiteralType text, out bool truncated) {
            size_t used;
            return parseImpl(text, truncated, used);
        }

        ///
        static BigInteger parse(scope String_UTF8 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF8 text, out bool truncated) {
            String_UTF32 s32 = text.byUTF32;
            size_t used;

            BigInteger ret = parseImpl(s32, truncated, used);

            text = text[used .. $];
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF16 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF16 text, out bool truncated) {
            String_UTF32 s32 = text.byUTF32;
            size_t used;

            BigInteger ret = parseImpl(s32, truncated, used);

            text = text[used .. $];
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF32 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF32 text, out bool truncated) {
            String_UTF32 s32 = text.byUTF32;
            size_t used;

            BigInteger ret = parseImpl(s32, truncated, used);

            text = text[used .. $];
            return ret;
        }
    }
}

static foreach(T; AliasSeq!(byte, short, int, long)) {
    ///
    void importSignedValue(scope PerIntegerType[] output, out bool isNegative, T input, ref bool truncated) {
        if(input >= 0)
            importValue(output, input, truncated);
        else if(input == long.min) {
            importValue(output, long.max, truncated);
            unsignedAdditionImpl(output, 1, 0, truncated);
            isNegative = true;
        } else {
            importValue(output, -input, truncated);
            isNegative = true;
        }
    }
}

///
unittest {
    PerIntegerType toInput = (PerIntegerType(1) << (BitsPerInteger * 2)) - 1, expected1 = toInput & PerIntegerMask,
        expected2 = (toInput >> BitsPerInteger) & PerIntegerMask;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage;
    bool isNegative, truncated;
    importSignedValue(storage[], isNegative, -toInput, truncated);

    assert(isNegative);
    assert(!truncated);
    assert(storage[0] == expected1);
    assert(storage[1] == expected2);
}

static foreach(T; AliasSeq!(ubyte, ushort, uint, ulong)) {
    ///
    void importValue(scope PerIntegerType[] output, T value, out bool truncated) {
        size_t offset;

        while(offset < output.length) {
            output[offset++] = value & PerIntegerMask;
            value >>= BitsPerInteger;
        }

        if(value != 0 && offset == output.length)
            truncated = true;
    }
}

///
unittest {
    PerIntegerType toInput = (PerIntegerType(1) << (BitsPerInteger * 2)) - 1, expected1 = toInput & PerIntegerMask,
        expected2 = (toInput >> BitsPerInteger) & PerIntegerMask;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage;

    bool truncated;
    importValue(storage[], toInput, truncated);

    assert(!truncated);
    assert(storage[0] == expected1);
    assert(storage[1] == expected2);
}

///
int signedCompare(scope const(PerIntegerType)[] input1, bool input1IsNegative, scope const(PerIntegerType)[] input2, bool input2IsNegative) {
    if(input1IsNegative != input2IsNegative)
        return input1IsNegative ? -1 : 1;
    else
        return unsignedCompare(input1, input2);
}

/// Equals
unittest {
    PerIntegerType toInput = (PerIntegerType(1) << (BitsPerInteger * 2)) - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage;
    bool truncated;

    importValue(storage[], toInput, truncated);

    assert(signedCompare(storage[], false, storage[], false) == 0);
    assert(signedCompare(storage[], true, storage[], false) == -1);
    assert(signedCompare(storage[], false, storage[], true) == 1);
}

/// Not equals
unittest {
    PerIntegerType toInput1 = (PerIntegerType(1) << (BitsPerInteger * 2)) - 1, toInput2 = (PerIntegerType(1) << BitsPerInteger) - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage1, storage2;
    bool truncated;

    importValue(storage1[], toInput1, truncated);
    importValue(storage2[], toInput2, truncated);

    assert(signedCompare(storage1[], false, storage2[], false) == 1);
    assert(signedCompare(storage2[], false, storage1[], false) == -1);

    assert(signedCompare(storage1[], true, storage2[], false) == -1);
    assert(signedCompare(storage1[], false, storage2[], true) == 1);
}

///
int unsignedCompare(scope const(PerIntegerType)[] input1, scope const(PerIntegerType)[] input2) {
    size_t max = input1.length;

    if(input1.length > input2.length) {
        foreach(i; input2.length .. input1.length) {
            if(input1[i] != 0)
                return 1;
        }

        max = input2.length;
    } else if(input2.length > input1.length) {
        foreach(i; input1.length .. input2.length) {
            if(input2[i] != 0)
                return -1;
        }
    }

    // MSB -> LSB
    foreach_reverse(i; 0 .. max) {
        if(input1[i] > input2[i])
            return 1;
        else if(input1[i] < input2[i])
            return -1;
    }

    return 0;
}

/// Equals
unittest {
    PerIntegerType toInput = (PerIntegerType(1) << (BitsPerInteger * 2)) - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage;
    bool truncated;

    importValue(storage[], toInput, truncated);

    assert(unsignedCompare(storage[], storage[]) == 0);
}

/// Not equals
unittest {
    PerIntegerType toInput1 = (PerIntegerType(1) << (BitsPerInteger * 2)) - 1, toInput2 = (PerIntegerType(1) << BitsPerInteger) - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage1, storage2;
    bool truncated;

    importValue(storage1[], toInput1, truncated);
    importValue(storage2[], toInput2, truncated);

    assert(unsignedCompare(storage1[], storage2[]) == 1);
    assert(unsignedCompare(storage2[], storage1[]) == -1);
}

/// Returns zero if all are zero
size_t firstNonZeroBitLSB(scope const(PerIntegerType)[] input) {
    size_t ret;

    foreach(v; input) {
        if((v & PerIntegerMask) == 0) {
            ret += BitsPerInteger;
        } else {
            PerIntegerType bit = 1;

            foreach(_; 0 .. BitsPerInteger) {
                ret++;

                if((v & bit) != 0)
                    return ret;

                bit <<= 1;
            }
        }
    }

    if(input.length * BitsPerInteger == ret)
        return 0;

    return ret;
}

///
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger);
    typeof(BI.storage) storage;
    bool truncated;

    importValue(storage[], 0, truncated);
    assert(firstNonZeroBitLSB(storage[]) == 0);

    importValue(storage[], 1, truncated);
    assert(firstNonZeroBitLSB(storage[]) == 1);
    importValue(storage[], 3, truncated);
    assert(firstNonZeroBitLSB(storage[]) == 1);

    importValue(storage[], 2, truncated);
    assert(firstNonZeroBitLSB(storage[]) == 2);
    importValue(storage[], 6, truncated);
    assert(firstNonZeroBitLSB(storage[]) == 2);
}

/// Returns zero if all are zero
size_t lastNonZeroBitLSB(scope const(PerIntegerType)[] input) {
    size_t ret = input.length * BitsPerInteger;

    foreach_reverse(v; input) {
        if((v & PerIntegerMask) == 0) {
            ret -= BitsPerInteger;
        } else {
            PerIntegerType bit = 1 << (BitsPerInteger - 1);

            foreach_reverse(_; 0 .. BitsPerInteger) {
                if((v & bit) != 0)
                    return ret;

                bit >>= 1;
                ret--;
            }
        }
    }

    return ret;
}

///
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger);
    typeof(BI.storage) storage;
    bool truncated;

    importValue(storage[], 0, truncated);
    assert(lastNonZeroBitLSB(storage[]) == 0);

    importValue(storage[], 1, truncated);
    assert(lastNonZeroBitLSB(storage[]) == 1);
    importValue(storage[], 3, truncated);
    assert(lastNonZeroBitLSB(storage[]) == 2);

    importValue(storage[], 2, truncated);
    assert(lastNonZeroBitLSB(storage[]) == 2);
    importValue(storage[], 6, truncated);
    assert(lastNonZeroBitLSB(storage[]) == 3);
}

/// See_Also: unsignedDivision
ErrorResult signedDivide(scope PerIntegerType[] quotient, scope out bool quotientIsNegative, scope PerIntegerType[] remainder,
        scope out bool remainderIsNegative, scope const(PerIntegerType)[] dividend, bool input1IsNegative,
        scope const(PerIntegerType)[] divisor, bool input2IsNegative, out bool overflow) {
    quotientIsNegative = input1IsNegative != input2IsNegative;
    remainderIsNegative = input1IsNegative != input2IsNegative;

    auto ret = unsignedDivide(quotient, remainder, dividend, divisor, overflow);

    if(ret && firstNonZeroBitLSB(remainder) == 0)
        remainderIsNegative = false;

    return ret;
}

///
unittest {
    PerIntegerType dividend = PerIntegerType(1) << BitsPerInteger, divisor = PerIntegerType(1) << (BitsPerInteger - 1), expected = 2;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageQuotient, storageRemainder, storageDividend, storageDivisor, storageExpected;
    bool truncated, overflow;
    bool quotientIsNegative, remainderIsNegative;

    importValue(storageDividend[], dividend, truncated);
    importValue(storageDivisor[], divisor, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(signedDivide(storageQuotient[], quotientIsNegative, storageRemainder[], remainderIsNegative,
            storageDividend[], true, storageDivisor[], false, overflow));
    assert(!overflow);
    assert(unsignedCompare(storageQuotient[], storageExpected[]) == 0);
    assert(quotientIsNegative);
    assert(!remainderIsNegative);
}

/// Use an output of double the size if you don't want it to be truncated
ErrorResult unsignedDivide(scope PerIntegerType[] quotient, scope PerIntegerType[] remainder,
        scope const(PerIntegerType)[] dividend, scope const(PerIntegerType)[] divisor, out bool overflow) {

    if(quotient.length < dividend.length)
        return ErrorResult(MalformedInputException("Quotient array must be equal to or larger than dividend input array"));
    else if(quotient.length < divisor.length)
        return ErrorResult(MalformedInputException("Quotient array must be equal to or larger than divisor input array"));
    else if(remainder.length < dividend.length)
        return ErrorResult(MalformedInputException("Remainder array must be equal to or larger than dividend input array"));
    else if(remainder.length < divisor.length)
        return ErrorResult(MalformedInputException("Remainder array must be equal to or larger than divisor input array"));

    {
        bool allZero = true;

        foreach(v; divisor) {
            if(v != 0) {
                allZero = false;
                break;
            }
        }

        if(allZero)
            return ErrorResult(MalformedInputException("Divisor must not be zero"));
    }

    {
        foreach(ref v; quotient) {
            v = 0;
        }

        foreach(i, ref v; remainder[0 .. dividend.length]) {
            v = dividend[i];
        }

        foreach(ref v; remainder[dividend.length .. $]) {
            v = 0;
        }
    }

    {
        // lets see if we can speed up the school algorithm, by increasing our divisor by quite a significant amount

        const msbOfDividend = lastNonZeroBitLSB(dividend), msbOfDivisor = lastNonZeroBitLSB(divisor);
        const canShift = (msbOfDividend > msbOfDivisor && msbOfDivisor > 0) ? (msbOfDividend - (msbOfDivisor + 1)) : 0;

        if(canShift > 0) {
            PerIntegerType[] divisor2 = quotient;
            size_t quotient2;

            foreach(i, v; divisor) {
                divisor2[i] = v;
            }
            leftShift(divisor2, canShift);

            while(unsignedCompare(remainder, divisor2) >= 0) {
                cast(void)unsignedSubtraction(remainder, divisor2);
                quotient2++;
            }

            importValue(quotient, quotient2, overflow);
            leftShift(quotient, canShift);
        }
    }

    // school algorithm, correct but slow
    while(unsignedCompare(remainder, divisor) >= 0) {
        cast(void)unsignedSubtraction(remainder, divisor);
        unsignedAddition(quotient, 1, 0, overflow);
    }

    return ErrorResult.init;
}

/// Known fast test
unittest {
    PerIntegerType dividend = PerIntegerType(1) << BitsPerInteger, divisor = PerIntegerType(1) << (BitsPerInteger - 1), expected = 2;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageQuotient, storageRemainder, storageDividend, storageDivisor, storageExpected;
    bool truncated, overflow;

    importValue(storageDividend[], dividend, truncated);
    importValue(storageDivisor[], divisor, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(unsignedDivide(storageQuotient[], storageRemainder[], storageDividend[], storageDivisor[], overflow));
    assert(!overflow);
    assert(unsignedCompare(storageQuotient[], storageExpected[]) == 0);
}

/// Known slow test
unittest {
    PerIntegerType dividend = PerIntegerType(1) << BitsPerInteger, divisor = 2, expected = PerIntegerType(1) << (BitsPerInteger - 1);

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageQuotient, storageRemainder, storageDividend, storageDivisor, storageExpected;
    bool truncated, overflow;

    importValue(storageDividend[], dividend, truncated);
    importValue(storageDivisor[], divisor, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(unsignedDivide(storageQuotient[], storageRemainder[], storageDividend[], storageDivisor[], overflow));
    assert(!overflow);
    assert(unsignedCompare(storageQuotient[], storageExpected[]) == 0);
}

/// See_Also: unsignedMultiply
ErrorResult signedMultiply(scope PerIntegerType[] output, scope out bool outputIsNegative,
        scope const(PerIntegerType)[] input1, bool input1IsNegative, scope const(PerIntegerType)[] input2,
        bool input2IsNegative, out bool overflow) {
    outputIsNegative = input1IsNegative != input2IsNegative;
    return unsignedMultiply(output, input1, input2, overflow);
}

/// Use an output of double the size if you don't want it to be truncated
ErrorResult unsignedMultiply(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1,
        scope const(PerIntegerType)[] input2, out bool overflow) {
    // make input1 = biggest
    sortUSizeForArgs(input1, input2);

    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array must be equal to or larger than first input array"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array must be equal to or larger than second input array"));

    foreach(ref v; output) {
        v = 0;
    }

    unsignedMultiplyAddImpl(output, input1, input2, overflow);
    return ErrorResult.init;
}

/// See_Also: unsignedAddition
ErrorResult signedAddition(scope PerIntegerType[] output, scope out bool outputIsNegative,
        scope const(PerIntegerType)[] input1, bool input1IsNegative, scope const(PerIntegerType)[] input2,
        bool input2IsNegative, out bool overflow) {
    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to first input"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to second input"));

    // make input1 = biggest
    const swapped = sortValueForArgs(input1, input1IsNegative, input2, input2IsNegative);

    outputIsNegative = input1IsNegative;

    if(input1IsNegative == input2IsNegative) {
        auto errorResult = unsignedAddition(output, input2, overflow);
        if(!errorResult)
            return errorResult;
    } else {
        // > 5, -3 = 5 - -3 = 8
        // > -10, 5 = -10 - 5 = 15 = -15

        // NOT > 5, -10 = 5 - -10 = 15
        // -10, 5 = -10 - 5 = -15 = 15
        // NOT > -3, 5 = -3 - 5 = -8
        // 5, -3 = 5 - -3 = 8 = -8

        auto errorInfo = unsignedSubtraction(output, input2);
        if(!errorInfo)
            return errorInfo;

        if(swapped)
            outputIsNegative = input2IsNegative;
    }

    foreach(i; output) {
        if(i != 0)
            return ErrorResult.init;
    }

    outputIsNegative = false;
    return ErrorResult.init;
}

///  Use an output of double the size if you don't want it to be truncated
ErrorResult unsignedAddition(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1,
        scope const(PerIntegerType)[] input2, ref bool overflow) {
    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to first input"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to second input"));

    {
        foreach(i, v; input1) {
            output[i] = v;
        }

        foreach(ref v; output[input1.length .. $]) {
            v = 0;
        }
    }

    foreach(powerOfMaxPerInteger, toAdd; input2) {
        unsignedAdditionImpl(output, toAdd, powerOfMaxPerInteger, overflow);
    }

    return ErrorResult.init;
}

/// Ditto
ErrorResult unsignedAddition(scope PerIntegerType[] output, scope const(PerIntegerType)[] input, ref bool overflow) {
    if(output.length < input.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to input"));

    foreach(powerOfMaxPerInteger, toAdd; input) {
        unsignedAdditionImpl(output, toAdd, powerOfMaxPerInteger, overflow);
    }

    return ErrorResult.init;
}

/// Add an unsigned integer at a given bit position
void unsignedAddition(scope PerIntegerType[] output, ulong input, size_t bitOffsetFromLSB, ref bool overflow) {
    size_t powerOf2Offset = bitOffsetFromLSB / BitsPerInteger;
    const leftOver = bitOffsetFromLSB % BitsPerInteger;

    if(leftOver != 0) {
        const toAdd = input & ((1 << (leftOver + 1)) - 1);
        const toAddShifted = toAdd << (BitsPerInteger - leftOver);

        unsignedAdditionImpl(output, toAddShifted, powerOf2Offset, overflow);

        powerOf2Offset++;
        input >>= leftOver;
    }

    while(input != 0 && powerOf2Offset < output.length) {
        const toAdd = input & PerIntegerMask;

        unsignedAdditionImpl(output, toAdd, powerOf2Offset, overflow);

        input >>= BitsPerInteger;
        powerOf2Offset += BitsPerInteger;
    }

    if(input != 0)
        overflow = true;
}

/// See_Also: unsignedSubtraction
ErrorResult signedSubtraction(scope PerIntegerType[] output, scope out bool outputIsNegative,
        scope const(PerIntegerType)[] input1, bool input1IsNegative, scope const(PerIntegerType)[] input2,
        bool input2IsNegative, scope ref bool overflow) {

    // make input1 = biggest
    const swapped = sortValueForArgs(input1, input1IsNegative, input2, input2IsNegative);

    outputIsNegative = input1IsNegative;

    if(input1IsNegative == input2IsNegative) {
        // -5, -5 = -5 - -5 = 0
        // 5, 5, = 5 - 5 = 0
        // -10, -5 = -5

        // NOT > -5, -10 = -5 - 10 = 5
        // -10, -5 = -10 - -5 = -5 = 5
        // NOT > 5, 10 = 5 - 10 = -5
        // 10, 5 = 10 - 5 = 5 = -5

        auto errorInfo = unsignedSubtraction(output, input1, input2);
        if(!errorInfo)
            return errorInfo;

        if(swapped)
            outputIsNegative = !outputIsNegative;
    } else {
        auto errorInfo = unsignedAddition(output, input1, input2, overflow);
        if(!errorInfo)
            return errorInfo;
    }

    foreach(i; output) {
        if(i != 0)
            return ErrorResult.init;
    }

    outputIsNegative = false;
    return ErrorResult.init;
}

///
ErrorResult unsignedSubtraction(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1, scope const(PerIntegerType)[] input2) {
    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to first input"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to second input"));
    else if(output.ptr is input1.ptr)
        return ErrorResult(MalformedInputException("Output array must not be the first input"));
    else if(output.ptr is input2.ptr)
        return ErrorResult(MalformedInputException("Output array must not be the second input"));

    {
        foreach(i, v; input1) {
            output[i] = v;
        }

        foreach(ref v; output[input1.length .. $]) {
            v = 0;
        }
    }

    return unsignedSubtraction(output, input2);
}

///
ErrorResult unsignedSubtraction(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    if(output.length < input.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to input"));

    PerIntegerType zero;
    bool borrow;

    foreach(i, toSub; input) {
        auto temp = output[i] - toSub - borrow;

        if(temp < 0) {
            borrow = true;
            temp += MaxPerInteger;
        } else
            borrow = false;

        temp &= PerIntegerMask;
        output[i] = temp;
        zero += temp;
    }

    foreach(i; input.length .. output.length) {
        auto temp = output[i] - borrow;

        if(temp < 0) {
            borrow = true;
            temp += MaxPerInteger;
        } else
            borrow = false;

        temp &= PerIntegerMask;
        output[i] = temp;
        zero += temp;
    }

    return ErrorResult.init;
}

///
unittest {
    PerIntegerType input = PerIntegerType(1) << BitsPerInteger, expected = (PerIntegerType(1) << BitsPerInteger) - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageSubtraction, storageExpected;
    bool truncated;

    importValue(storageOutput[], input, truncated);
    importValue(storageSubtraction[], 1, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(unsignedSubtraction(storageOutput[], storageSubtraction[]));
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
}

/// Per integer shift LSB to MSB
void leftShift(scope PerIntegerType[] output, size_t amount) {
    const entriesToIgnore = amount / BitsPerInteger;
    const amountMod = amount % BitsPerInteger;
    const bitsToIgnore = BitsPerInteger - amountMod;

    if(entriesToIgnore >= output.length) {
        foreach(ref v; output) {
            v = 0;
        }

        return;
    } else if(amountMod == 0) {
        // we're moving whole integers around, so that is quite easy!
        foreach_reverse(i; 0 .. output.length - entriesToIgnore) {
            output[i + entriesToIgnore] = output[i];
        }
        return;
    }

    {
        // 1) abcd efgh ijkl
        // << 5
        // ++++ +abc defg
        // amountMod = 1
        // bitsToIgnore = 3

        // 2) abcd efgh ijkl
        // << 1
        // +abc defg hijk
        // amountMod = 1
        // bitsToIgnore == 3

        size_t dstByteOffset = output.length - 1;

        if(entriesToIgnore == 0 || dstByteOffset >= entriesToIgnore) {
            size_t srcByteOffset = dstByteOffset - entriesToIgnore;

            for(;;) {
                {
                    // 1.1) abcd efgh ijkl -> +efg -> abcd efgh +efg
                    // 1.2) abcd efgh defg -> +abc -> abcd +abc defg
                    // 2.1) abcd efgh ijkl -> +ijk -> abcd efgh +ijk
                    // 2.2) abcd efgh hijk -> +efg -> abcd +efg hijk
                    const temp = output[srcByteOffset] << amountMod;
                    output[dstByteOffset] = temp;
                }

                if(srcByteOffset == 0)
                    break;

                srcByteOffset--;

                {
                    // 1.1) abcd efgh +efg -> d+++ -> abcd efgh defg
                    // 2.1) abcd efgh +ijk -> h+++ -> abcd efgh hijk
                    // 2.2) abcd +efg hijk -> d+++ -> abcd defg hijk
                    const temp = output[srcByteOffset] >> bitsToIgnore;
                    output[dstByteOffset] |= temp;
                }

                dstByteOffset--;
            }
        }

        // implicit:
        // 1) abcd +abc defg -> abcd 0abc defg

        foreach(i; 0 .. dstByteOffset) {
            // 1.2) 0000 0abc defg
            output[i] = 0;
        }
    }
}

/// Per integer shift MSB to LSB
void rightShift(scope PerIntegerType[] output, size_t amount) {
    const entriesToIgnore = amount / BitsPerInteger;
    const amountMod = amount % BitsPerInteger;
    const bitsToIgnore = BitsPerInteger - amountMod;

    if(entriesToIgnore >= output.length) {
        foreach(ref v; output) {
            v = 0;
        }

        return;
    } else if(amountMod == 0) {
        // we're moving whole integers around, so that is quite easy!
        foreach(i; 0 .. output.length - entriesToIgnore) {
            output[i] = output[i + entriesToIgnore];
        }
        return;
    }

    {
        // 1) abcd efgh ijkl
        // >> 5
        // fghi jkl+ ++++
        // amountMod = 1
        // bitsToIgnore = 3

        // 2) abcd efgh ijkl
        // >> 1
        // bcde fghi jkl+
        // amountMod = 1
        // bitsToIgnore == 3

        size_t dstByteOffset;
        size_t srcByteOffset = entriesToIgnore;

        if(entriesToIgnore == 0 || srcByteOffset < output.length) {
            for(;;) {

                {
                    // 1.1) abcd efgh ijkl -> fgh+ -> fgh+ efgh ijkl
                    // 1.2) fghi efgh ijkl -> jkl+ -> fghi jkl+ ijkl
                    const temp = output[srcByteOffset] >> amountMod;
                    output[dstByteOffset] = temp & PerIntegerMask;
                }

                srcByteOffset++;

                if(srcByteOffset == output.length)
                    break;

                {
                    // 1.1) fgh+ efgh ijkl -> +++i -> fghi efgh ijkl
                    const temp = output[srcByteOffset] << bitsToIgnore;
                    output[dstByteOffset] |= temp & PerIntegerMask;
                }

                dstByteOffset++;
            }
        }

        // implicit:
        // 1) fghi jkl+ ijkl -> fghi jkl0 ijkl

        foreach(i; dstByteOffset + 1 .. output.length) {
            // 1.2) fghi jkl0 ijkl -> fghi jkl0 0000
            output[i] = 0;
        }
    }
}

///
ErrorResult bitwiseAnd(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    return bitwiseAnd(output, output, input);
}

///
ErrorResult bitwiseAnd(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1, scope const(PerIntegerType)[] input2) {
    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to first input"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to second input"));

    const min = input1.length > input2.length ? input2.length : input1.length;

    foreach(offset, ref v; output[0 .. min]) {
        v = input1[offset] & input2[offset];
    }

    foreach(ref v; output[min .. $]) {
        v = 0;
    }

    return ErrorResult.init;
}

///
ErrorResult bitwiseOr(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    return bitwiseOr(output, output, input);
}

///
ErrorResult bitwiseOr(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1, scope const(PerIntegerType)[] input2) {
    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to first input"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to second input"));

    sortUSizeForArgs(input1, input2);

    const min = input1.length > input2.length ? input2.length : input1.length;

    foreach(offset, ref v; output[0 .. min]) {
        v = input1[offset] | input2[offset];
    }

    foreach(offset, ref v; output[min .. input1.length]) {
        v = input1[offset + min];
    }

    foreach(ref v; output[input1.length .. $]) {
        v = 0;
    }

    return ErrorResult.init;
}

///
ErrorResult bitwiseXor(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    return bitwiseXor(output, output, input);
}

///
ErrorResult bitwiseXor(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1, scope const(PerIntegerType)[] input2) {
    if(output.length < input1.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to first input"));
    else if(output.length < input2.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to second input"));

    sortUSizeForArgs(input1, input2);

    const min = input1.length > input2.length ? input2.length : input1.length;

    foreach(offset, ref v; output[0 .. min]) {
        v = input1[offset] ^ input2[offset];
    }

    foreach(offset, ref v; output[min .. input1.length]) {
        v = input1[offset ^ min];
    }

    foreach(ref v; output[input1.length .. $]) {
        v = 0;
    }

    return ErrorResult.init;
}

/// Uses exponent as counter
ErrorResult signedPower(scope PerIntegerType[] output, scope out bool outputIsNegative, scope const(PerIntegerType)[] input,
        bool inputIsNegative, scope PerIntegerType[] exponent, bool exponentIsNegative, out bool overflow) {

    if(output.length < input.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to input"));
    else if(output.length < exponent.length)
        return ErrorResult(MalformedInputException("Output array length must be greater than or equal to exponent input"));

    if(exponentIsNegative) {
        foreach(ref v; output) {
            v = 0;
        }
        return ErrorResult.init;
    }

    outputIsNegative = inputIsNegative;
    unsignedPower(output, input, exponent, overflow);

    return ErrorResult.init;
}

/// Uses exponent as counter
void unsignedPower(scope PerIntegerType[] output, scope const(PerIntegerType)[] input, scope PerIntegerType[] exponent, out bool overflow) {

    foreach(ref v; output) {
        v = 0;
    }

    while(unsignedCompare(exponent, null) != 0) {
        unsignedMultiplyAddImpl(output, output, input, overflow);
        unsignedSubtractionImpl(exponent, 1, 0);
    }
}

private:

void sortUSizeForArgs(scope ref const(PerIntegerType)[] largest, scope ref const(PerIntegerType)[] smallest) @trusted {
    if(largest.length < smallest.length) {
        auto temp = smallest;
        smallest = largest;
        largest = temp;
    }
}

bool sortValueForArgs(scope ref const(PerIntegerType)[] largest, scope ref bool largestIsNegative,
        scope ref const(PerIntegerType)[] smallest, scope ref bool smallestIsNegative) @trusted {
    if(largest.length < smallest.length) {
        auto temp = smallest;
        smallest = largest;
        largest = temp;
        return true;
    } else if(largest.length > smallest.length) {
        return false;
    }

    // MSB -> LSB
    foreach_reverse(i; 0 .. largest.length) {
        if(largest[i] > smallest[i]) {
            return false;
        } else if(largest[i] < smallest[i]) {
            auto temp = smallest;
            smallest = largest;
            largest = temp;

            auto tempIN = smallestIsNegative;
            smallestIsNegative = largestIsNegative;
            largestIsNegative = tempIN;
            return true;
        }
    }

    return false;
}

void unsignedMultiplyAddImpl(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1,
        scope const(PerIntegerType)[] input2, ref bool overflow) {
    foreach_reverse(i; 0 .. input2.length) {
        unsignedMultiplyAddImpl(output, input1, input2[i], i, overflow);
    }
}

void unsignedMultiplyAddImpl(scope PerIntegerType[] output, scope const(PerIntegerType)[] input1, PerIntegerType input2,
        PerIntegerType powerOfMaxPerInteger, ref bool overflow) {
    assert(output.length >= input1.length);
    assert(output.length > powerOfMaxPerInteger);

    PerIntegerType carry;

    /*
    Does one iteration of long-multiplication:

        1   1 = input1
            1 = input2
    x_________________
    */

    foreach(i; 0 .. output.length) {
        PerIntegerType currentInteger = (input1.length > i ? (input1[i] * input2) : 0) + carry;

        if(currentInteger >= MaxPerInteger) {
            carry = currentInteger / MaxPerInteger;
            currentInteger %= MaxPerInteger;
        } else
            carry = 0;

        // this integer has been completed, needs to be added to output now
        unsignedAdditionImpl(output, currentInteger, powerOfMaxPerInteger + i, overflow);
    }

    if(carry > 0)
        overflow = true;
}

void unsignedAdditionImpl(scope PerIntegerType[] output, PerIntegerType toAdd, PerIntegerType powerOfMaxPerInteger, ref bool overflow) {
    assert(output.length > powerOfMaxPerInteger);
    bool carry;

    {
        output[powerOfMaxPerInteger] += toAdd;

        if(output[powerOfMaxPerInteger] >= MaxPerInteger) {
            carry = true;
            output[powerOfMaxPerInteger] -= MaxPerInteger;
        }
    }

    foreach(i; powerOfMaxPerInteger + 1 .. output.length) {
        output[i] += carry;

        if(output[i] >= MaxPerInteger) {
            carry = true;
            output[i] -= MaxPerInteger;
        } else
            carry = false;
    }

    if(carry)
        overflow = true;
}

void unsignedSubtractionImpl(scope PerIntegerType[] output, PerIntegerType toSubtract, PerIntegerType powerOfMaxPerInteger) {
    assert(output.length > powerOfMaxPerInteger);

    PerIntegerType zero;
    bool borrow;

    {
        auto temp = output[powerOfMaxPerInteger] - toSubtract;

        if(temp < 0) {
            borrow = true;
            temp += MaxPerInteger;
        } else
            borrow = false;

        output[powerOfMaxPerInteger] = temp;
        zero += temp;
    }

    foreach_reverse(i; powerOfMaxPerInteger + 1 .. output.length) {
        auto temp = output[i] - borrow;

        if(temp < 0) {
            borrow = true;
            temp += MaxPerInteger;
        } else
            borrow = false;

        output[i] = temp;
        zero += temp;
    }
}
