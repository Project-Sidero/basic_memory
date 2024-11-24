module sidero.base.math.bigint;
import sidero.base.errors;
import sidero.base.text;
import sidero.base.containers.dynamicarray;
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
struct BigInteger(PerIntegerType NumberOfDigits_) if (NumberOfDigits_ > 0) {
    ///
    enum NumberOfDigits = NumberOfDigits_;

    ///
    PerIntegerType[neededStorageGivenDigits(NumberOfDigits)] storage;
    ///
    bool isNegative;
    ///
    bool wasOverflown;

    private {
        static BigInteger parseHexImpl(Str)(Str input, out bool truncated, out size_t used) @safe nothrow @nogc {
            BigInteger ret;
            used = parse16Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        void toStringImpl(scope void delegate(scope char[]) @safe nothrow @nogc del) scope const @safe nothrow @nogc {
            import sidero.base.algorithm : reverse;

            ubyte[(MaxDigitsPerInteger * storage.length) + 1] buffer = void;
            buffer[0] = '-';
            buffer[1] = '0';

            size_t offset = 1;
            bool hitNonZero;

            {
                BigInteger temp = this;
                BigInteger div = BigInteger(10);
                BigInteger quotient, modulas;

                while(temp != 0) {
                    bool overflow;
                    cast(void)unsignedDivide(quotient.storage[], modulas.storage[], temp.storage[], div.storage[], overflow);

                    const digit = modulas.storage[0] & 0xFF;
                    assert(digit < 10);

                    if(digit != 0 || hitNonZero) {
                        buffer[offset++] = cast(char)('0' + digit);
                        hitNonZero = true;
                    }

                    temp = quotient;
                }

                reverse(buffer[1 .. offset]);
            }

            bool excludeNegative = !this.isNegative;

            if(offset == 1) {
                offset++;
                excludeNegative = true;
            }

            del(cast(char[])buffer[excludeNegative .. offset]);
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

            ///
            size_t numberOfBits() {
                return storage.length * BitsPerInteger;
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
    }

    ///
    void opAssign(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        this.isNegative = other.isNegative;

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
            String_UTF8 ret;

            toStringImpl((scope char[] buffer) @trusted { ret = String_UTF8(buffer).dup; });

            return ret;
        }

        ///
        void toString(scope ref StringBuilder_UTF8 builder) scope const {
            toStringImpl((scope char[] buffer) @trusted { builder ~= String_UTF8(buffer); });
        }

        ///
        void toString(scope ref StringBuilder_UTF16 builder) scope const {
            toStringImpl((scope char[] buffer) @trusted { builder ~= String_UTF8(buffer); });
        }

        ///
        void toString(scope ref StringBuilder_UTF32 builder) scope const {
            toStringImpl((scope char[] buffer) @trusted { builder ~= String_UTF8(buffer); });
        }

        ///
        static BigInteger parseHex(scope String_UTF8.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope String_UTF8.LiteralType input, out bool truncated) {
            BigInteger ret;
            parse16Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        ///
        static BigInteger parseHex(scope String_UTF16.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope String_UTF16.LiteralType input, out bool truncated) {
            BigInteger ret;
            parse16Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        ///
        static BigInteger parseHex(scope String_UTF32.LiteralType text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope String_UTF32.LiteralType input, out bool truncated) {
            BigInteger ret;
            parse16Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        ///
        static BigInteger parseHex(scope String_UTF8 text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope ref String_UTF8 input, out bool truncated) @trusted {
            BigInteger ret;
            const used = parse16Impl(ret.storage[], ret.isNegative, input, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static BigInteger parseHex(scope String_UTF16 text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope ref String_UTF16 input, out bool truncated) @trusted {
            BigInteger ret;
            const used = parse16Impl(ret.storage[], ret.isNegative, input, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static BigInteger parseHex(scope String_UTF32 text) {
            bool truncated;
            return parseHex(text, truncated);
        }

        ///
        static BigInteger parseHex(scope ref String_UTF32 input, out bool truncated) @trusted {
            BigInteger ret;
            const used = parse16Impl(ret.storage[], ret.isNegative, input, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF8.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope String_UTF8.LiteralType input, out bool truncated) {
            BigInteger ret;
            parse10Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF16.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope String_UTF16.LiteralType input, out bool truncated) {
            BigInteger ret;
            parse10Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF32.LiteralType text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope String_UTF32.LiteralType input, out bool truncated) {
            BigInteger ret;
            parse10Impl(ret.storage[], ret.isNegative, input, truncated);
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF8 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF8 input, out bool truncated) @trusted {
            BigInteger ret;
            const used = parse10Impl(ret.storage[], ret.isNegative, input, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF16 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF16 input, out bool truncated) @trusted {
            BigInteger ret;
            const used = parse10Impl(ret.storage[], ret.isNegative, input, truncated);

            input = input[used .. $];
            return ret;
        }

        ///
        static BigInteger parse(scope String_UTF32 text) {
            bool truncated;
            return parse(text, truncated);
        }

        ///
        static BigInteger parse(scope ref String_UTF32 input, out bool truncated) @trusted {
            BigInteger ret;
            const used = parse10Impl(ret.storage[], ret.isNegative, input, truncated);

            input = input[used .. $];
            return ret;
        }
    }
}

///
struct DynamicBigInteger {
    ///
    bool isNegative;
    ///
    bool wasOverflown;

    private {
        DynamicArray!long storage_;
        size_t digitCount_;

        void makeStorable(T)(T input) scope @safe nothrow @nogc {
            size_t neededDigits;

            if(input < 0)
                input *= -1;

            do {
                input /= 10;
                neededDigits++;
            }
            while(input > 0);

            this.needDigits(neededDigits);
        }

        static DynamicBigInteger parseDecImpl(Str)(scope Str input, out size_t used) @trusted nothrow @nogc {
            bool truncated;

            DynamicBigInteger ret;
            ret.digitCount_ = (((input.length / 2) + 1) * 8) / BitsPerInteger;
            ret.needDigits(ret.digitCount_);

            used = parse10Impl(ret.storage.unsafeGetLiteral, ret.isNegative, input, truncated);
            return ret;
        }

        static DynamicBigInteger parseHexImpl(Str)(scope Str input, out size_t used) @trusted nothrow @nogc {
            bool truncated;

            DynamicBigInteger ret;
            ret.digitCount_ = (((input.length / 2) + 1) * 8) / BitsPerInteger;
            ret.needDigits(ret.digitCount_);

            used = parse16Impl(ret.storage.unsafeGetLiteral, ret.isNegative, input, truncated);
            return ret;
        }

        void toStringImpl(scope void delegate(scope const(char)[]) @safe nothrow @nogc del) scope @trusted nothrow @nogc {
            import sidero.base.algorithm : reverse;

            if(this.digitCount_ == 0) {
                del("0");
                return;
            }

            DynamicArray!char buffer;
            buffer.length = this.digitCount_ + 1;

            cast(void)(buffer[0] = '-');
            cast(void)(buffer[1] = '0');

            size_t offset = 1;
            bool hitNonZero;

            {
                DynamicBigInteger temp = this.dup;
                DynamicBigInteger div = DynamicBigInteger(10);

                DynamicBigInteger quotient, modulas;
                quotient.needDigits(this.digitCount_);
                modulas.needDigits(this.digitCount_);

                while(temp != 0) {
                    bool overflow;
                    cast(void)unsignedDivide(quotient.storage_.unsafeGetLiteral, modulas.storage_.unsafeGetLiteral,
                            temp.storage_.unsafeGetLiteral, div.storage_.unsafeGetLiteral, overflow);

                    auto mc = modulas.storage_[0];
                    assert(mc);
                    const digit = mc & 0xFF;
                    assert(digit < 10);

                    if(digit != 0 || hitNonZero) {
                        cast(void)(buffer[offset++] = cast(char)('0' + digit));
                        hitNonZero = true;
                    }

                    temp = quotient;
                }

                reverse(buffer.unsafeGetLiteral[1 .. offset]);
            }

            bool excludeNegative = !this.isNegative;

            if(offset == 1) {
                offset++;
                excludeNegative = true;
            }

            del(buffer.unsafeGetLiteral[excludeNegative .. offset]);
        }
    }

export @safe nothrow @nogc:

    static foreach(T; AliasSeq!(ubyte, ushort, uint, ulong)) {
        ///
        this(T input) scope @trusted {
            makeStorable(input);

            bool truncated;
            importValue(this.storage_.unsafeGetLiteral, input, truncated);
        }
    }

    static foreach(T; AliasSeq!(byte, short, int, long)) {
        ///
        this(T input) scope @trusted {
            makeStorable(input);

            bool truncated;
            importSignedValue(this.storage_.unsafeGetLiteral, this.isNegative, input, truncated);
        }
    }

    ///
    this(size_t OtherDigits)(return scope ref const BigInteger!OtherDigits other) scope {
        this.isNegative = other.isNegative;
        this.storage_ = DynamicArray!long(other.storage[]);
    }

    this(return scope ref DynamicBigInteger other) scope {
        this.tupleof = other.tupleof;
    }

    ~this() scope {
    }

    ///
    bool isNull() scope const {
        return this.storage_.isNull;
    }

    ///
    DynamicBigInteger dup() return scope {
        DynamicBigInteger ret = this;
        ret.storage_ = ret.storage_.dup;
        return ret;
    }

    ///
    size_t haveDigits() scope const {
        return this.digitCount_;
    }

    ///
    void needDigits(size_t count) scope @trusted nothrow @nogc {
        if(count == 0)
            count = 1;
        if(this.digitCount_ >= count)
            return;

        const oldSize = this.storage_.length;
        const newSize = neededStorageGivenDigits(count);
        const diffSize = newSize - oldSize;

        this.digitCount_ = count;
        if(diffSize == 0)
            return;

        this.storage_.length = newSize;
        long[] slice = this.storage_.unsafeGetLiteral;

        foreach_reverse(i; 0 .. oldSize) {
            slice[i + diffSize] = slice[i];
        }

        foreach(i; 0 .. diffSize) {
            slice[i] = 0;
        }
    }

    ///
    DynamicArray!long storage() return scope {
        return this.storage_;
    }

    ///
    DynamicBigInteger min() {
        DynamicBigInteger ret;
        ret.digitCount_ = this.digitCount_;
        ret.needDigits(this.digitCount_);
        ret.isNegative = true;

        foreach(ref v; ret.storage) {
            v = PerIntegerMask;
        }

        return ret;
    }

    ///
    DynamicBigInteger max() {
        DynamicBigInteger ret;
        ret.digitCount_ = this.digitCount_;
        ret.needDigits(this.digitCount_);

        foreach(ref v; ret.storage_) {
            v = PerIntegerMask;
        }

        return ret;
    }

    static {
        ///
        DynamicBigInteger negativeOne() {
            return DynamicBigInteger(-1);
        }

        ///
        DynamicBigInteger zero() {
            return DynamicBigInteger(0);
        }

        ///
        DynamicBigInteger one() {
            return DynamicBigInteger(1);
        }
    }

    ///
    size_t numberOfBits() {
        return this.storage_.length * BitsPerInteger;
    }

    /// Returns zero if all are zero
    size_t firstNonZeroBitLSB() scope const @trusted {
        return .firstNonZeroBitLSB(this.storage_.unsafeGetLiteral);
    }

    /// Returns zero if all are zero
    size_t lastNonZeroBitLSB() scope const @trusted {
        return .lastNonZeroBitLSB(this.storage_.unsafeGetLiteral);
    }

    ///
    void opOpAssign(string op : "/", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "/", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret, remainder;
        ret.needDigits(OtherDigits);
        remainder.needDigits(OtherDigits);

        auto errorResult = signedDivision(ret.storage_.unsafeGetLiteral, ret.isNegative,
                remainder.storage_.unsafeGetLiteral, ret.isNegative, this.storage_.unsafeGetLiteral, this.isNegative,
                other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "/")(scope DynamicBigInteger other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "/")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret, remainder;
        ret.needDigits(OtherDigits);
        remainder.needDigits(OtherDigits);

        auto errorResult = signedDivision(ret.storage_.unsafeGetLiteral, ret.isNegative,
                remainder.storage_.unsafeGetLiteral, ret.isNegative, this.storage_.unsafeGetLiteral, this.isNegative,
                other.storage_.unsafeGetLiteral, other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "*", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "*", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret;
        ret.needDigits(OtherDigits);

        auto errorResult = signedMultiply(ret.storage_.unsafeGetLiteral, ret.isNegative,
                this.storage_.unsafeGetLiteral, this.isNegative, other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "*")(scope DynamicBigInteger other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "*")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret;
        ret.needDigits(OtherDigits);

        auto errorResult = signedMultiply(ret.storage_.unsafeGetLiteral, ret.isNegative,
                this.storage_.unsafeGetLiteral, this.isNegative, other.storage_.unsafeGetLiteral, other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    DynamicBigInteger opUnary(string op : "-")() scope @trusted {
        DynamicBigInteger ret = this.dup;
        ret.isNegative = !ret.isNegative;
        return ret;
    }

    ///
    DynamicBigInteger opUnary(string op : "++")() scope @trusted {
        this.opOpAssign!"+"(BigInteger!1(1));
        return this;
    }

    ///
    DynamicBigInteger opUnary(string op : "--")() scope @trusted {
        this.opOpAssign!"-"(BigInteger!1(1));
        return this;
    }

    ///
    void opOpAssign(string op : "+", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "+", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        DynamicBigInteger ret;
        ret.needDigits(OtherDigits);

        auto errorResult = signedAddition(ret.storage_.unsafeGetLiteral, ret.isNegative,
                this.storage_.unsafeGetLiteral, this.isNegative, other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "+")(scope DynamicBigInteger other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "+")(scope DynamicBigInteger other) scope {
        static assert(OtherDigits <= NumberOfDigits, "Argument number of digits must be less than ours");

        DynamicBigInteger ret;
        ret.needDigits(OtherDigits);

        auto errorResult = signedAddition(ret.storage_.unsafeGetLiteral, ret.isNegative,
                this.storage_.unsafeGetLiteral, this.isNegative, other.storage_.unsafeGetLiteral, other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "-", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "-", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret;
        ret.needDigits(OtherDigits);

        auto errorResult = signedSubtraction(ret.storage_.unsafeGetLiteral, ret.isNegative,
                this.storage_.unsafeGetLiteral, this.isNegative, other.storage[], other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "-")(scope DynamicBigInteger other) scope {
        bool tempWasOverflown = this.wasOverflown;

        this = this.opBinary!op(other);

        this.wasOverflown = this.wasOverflown || tempWasOverflown;
    }

    ///
    DynamicBigInteger opBinary(string op : "-")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret;
        ret.needDigits(OtherDigits);

        auto errorResult = signedSubtraction(ret.storage_.unsafeGetLiteral, ret.isNegative,
                this.storage_.unsafeGetLiteral, this.isNegative, other.storage_.unsafeGetLiteral, other.isNegative, ret.wasOverflown);
        assert(errorResult);

        return ret;
    }

    ///
    void opOpAssign(string op : "<<")(scope size_t amount) scope {
        leftShift(this.storage_.unsafeGetLiteral, amount);
    }

    ///
    DynamicBigInteger opBinary(string op : "<<")(scope size_t amount) scope {
        DynamicBigInteger ret = this.dup;
        leftShift(ret.storage_.unsafeGetLiteral, amount);
        return ret;
    }

    ///
    void opOpAssign(string op : ">>")(scope size_t amount) scope {
        rightShift(this.storage_.unsafeGetLiteral, amount);
    }

    ///
    DynamicBigInteger opBinary(string op : ">>")(scope size_t amount) scope {
        DynamicBigInteger ret = this.dup;
        rightShift(ret.storage_.unsafeGetLiteral, amount);
        return ret;
    }

    ///
    void opOpAssign(string op : "|", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        auto errorInfo = bitwiseOr(this.storage_.unsafeGetLiteral, other.storage[]);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "|", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = bitwiseOr(ret.storage_.unsafeGetLiteral, other.storage[]);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "|")(scope DynamicBigInteger other) scope {
        auto errorInfo = bitwiseOr(this.storage_.unsafeGetLiteral, other.storage_.unsafeGetLiteral);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "|")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = bitwiseOr(ret.storage_.unsafeGetLiteral, other.storage_.unsafeGetLiteral);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "&", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        auto errorInfo = bitwiseAnd(this.storage_.unsafeGetLiteral, other.storage[]);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "&", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = bitwiseAnd(ret.storage_.unsafeGetLiteral, other.storage[]);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "&")(scope DynamicBigInteger other) scope {
        auto errorInfo = bitwiseAnd(this.storage_.unsafeGetLiteral, other.storage_.unsafeGetLiteral);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "&")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = bitwiseAnd(ret.storage_.unsafeGetLiteral, other.storage_.unsafeGetLiteral);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        auto errorInfo = bitwiseXor(this.storage_.unsafeGetLiteral, other.storage[]);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = bitwiseXor(ret.storage_.unsafeGetLiteral, other.storage[]);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "^")(scope DynamicBigInteger other) scope {
        auto errorInfo = bitwiseXor(this.storage_.unsafeGetLiteral, other.storage_.unsafeGetLiteral);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "^")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = bitwiseXor(ret.storage_.unsafeGetLiteral, other.storage_.unsafeGetLiteral);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "^^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        this.needDigits(OtherDigits);

        auto errorInfo = signedPower(this.storage_.unsafeGetLiteral, this.isNegative, temp.storage_.unsafeGetLiteral,
                temp.isNegative, other.storage[], other.isNegative, ret.overflow);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "^^", size_t OtherDigits)(scope BigInteger!OtherDigits other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(OtherDigits);

        auto errorInfo = signedPower(ret.storage_.unsafeGetLiteral, ret.isNegative, this.storage_.unsafeGetLiteral,
                this.isNegative, other.storage[], other.isNegative, ret.overflow);
        assert(errorInfo);

        return ret;
    }

    ///
    void opOpAssign(string op : "^^")(scope DynamicBigInteger other) scope {
        this.needDigits(other.digitCount_);

        auto errorInfo = signedPower(this.storage_.unsafeGetLiteral, this.isNegative, temp.storage_.unsafeGetLiteral,
                temp.isNegative, other.storage_.unsafeGetLiteral, other.isNegative, ret.overflow);
        assert(errorInfo);
    }

    ///
    DynamicBigInteger opBinary(string op : "^^")(scope DynamicBigInteger other) scope {
        DynamicBigInteger ret = this.dup;
        ret.needDigits(other.digitCount_);

        auto errorInfo = signedPower(ret.storage_.unsafeGetLiteral, ret.isNegative, this.storage_.unsafeGetLiteral,
                this.isNegative, other.storage_.unsafeGetLiteral, other.isNegative, ret.overflow);
        assert(errorInfo);

        return ret;
    }

    ///
    void opAssign(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope {
        this.destroy;
        this.needDigits(OtherDigits);

        this.isNegative = other.isNegative;

        foreach(i, v; other.storage) {
            this.storage_[i] = v;
        }
    }

    ///
    void opAssign(return scope DynamicBigInteger other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    void opOpAssign(string op)(long other) scope {
        this.opOpAssign!op(BigInteger_64(other));
    }

    ///
    BigInteger opBinary(string op)(long other) scope const {
        return this.opBinary!op(BigInteger_64(other));
    }

    ///
    export int opEquals(long other) scope const {
        return opCmp(BigInteger_64(other)) == 0;
    }

    ///
    int opEquals(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope const @trusted {
        return signedCompare(this.storage_.unsafeGetLiteral, this.isNegative, other.storage[], other.isNegative) == 0;
    }

    ///
    int opEquals(scope DynamicBigInteger other) scope const @trusted {
        return signedCompare(this.storage_.unsafeGetLiteral, this.isNegative, other.storage_.unsafeGetLiteral, other.isNegative) == 0;
    }

    ///
    export int opCmp(long other) scope const {
        return opCmp(BigInteger_64(other));
    }

    ///
    int opCmp(size_t OtherDigits)(scope const BigInteger!OtherDigits other) scope const @trusted {
        return signedCompare(this.storage_.unsafeGetLiteral, this.isNegative, other.storage[], other.isNegative);
    }

    ///
    int opCmp(scope const DynamicBigInteger other) scope const @trusted {
        return signedCompare(this.storage_.unsafeGetLiteral, this.isNegative, other.storage_.unsafeGetLiteral, other.isNegative);
    }

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils : hashOf;

        scope temp = this.storage_.unsafeGetLiteral;
        return hashOf(temp);
    }

    ///
    String_UTF8 toString() scope {
        String_UTF8 ret;

        toStringImpl((scope const(char)[] buffer) @trusted { ret = String_UTF8(buffer).dup; });

        return ret;
    }

    ///
    void toString(scope ref StringBuilder_UTF8 builder) scope {
        toStringImpl((scope const(char)[] buffer) @trusted { builder ~= String_UTF8(buffer); });
    }

    ///
    void toString(scope ref StringBuilder_UTF16 builder) scope {
        toStringImpl((scope const(char)[] buffer) @trusted { builder ~= String_UTF8(buffer); });
    }

    ///
    void toString(scope ref StringBuilder_UTF32 builder) scope {
        toStringImpl((scope const(char)[] buffer) @trusted { builder ~= String_UTF8(buffer); });
    }

    ///
    static DynamicBigInteger parseHex(scope String_UTF8.LiteralType input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseHexImpl(input, used);
        return ret;
    }

    ///
    static DynamicBigInteger parseHex(scope String_UTF16.LiteralType input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseHexImpl(input, used);
        return ret;
    }

    ///
    static DynamicBigInteger parseHex(scope String_UTF32.LiteralType input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseHexImpl(input, used);
        return ret;
    }

    ///
    static DynamicBigInteger parseHex(scope ref String_UTF8 input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseHexImpl(input, used);
        input = input[used .. $];
        return ret;
    }

    ///
    static DynamicBigInteger parseHex(scope ref String_UTF16 input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseHexImpl(input, used);
        input = input[used .. $];
        return ret;
    }

    ///
    static DynamicBigInteger parseHex(scope ref String_UTF32 input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseHexImpl(input, used);
        input = input[used .. $];
        return ret;
    }

    ///
    static DynamicBigInteger parse(scope String_UTF8.LiteralType input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseDecImpl(input, used);
        return ret;
    }

    ///
    static DynamicBigInteger parse(scope String_UTF16.LiteralType input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseDecImpl(input, used);
        return ret;
    }

    ///
    static DynamicBigInteger parse(scope String_UTF32.LiteralType input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseDecImpl(input, used);
        return ret;
    }

    ///
    static DynamicBigInteger parse(scope ref String_UTF8 input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseDecImpl(input, used);
        input = input[used .. $];
        return ret;
    }

    ///
    static DynamicBigInteger parse(scope ref String_UTF16 input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseDecImpl(input, used);
        input = input[used .. $];
        return ret;
    }

    ///
    static DynamicBigInteger parse(scope ref String_UTF32 input) {
        size_t used;
        DynamicBigInteger ret = DynamicBigInteger.parseDecImpl(input, used);
        input = input[used .. $];
        return ret;
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
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8.LiteralType input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

///
unittest {
    alias BI = BigInteger!10;
    typeof(BI.storage) storage;
    bool isNegative, truncated;

    assert(parseHexValue(storage[], isNegative, "-12345678", truncated) == 9);
    assert(isNegative);
    assert(!truncated);
    assert(storage[0] == 0x12345678);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16.LiteralType input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32.LiteralType input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8 input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16 input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32 input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF8 input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF16 input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseHexValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF32 input, out bool truncated) {
    return parse16Impl(output, isNegative, input, truncated);
}

///
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8.LiteralType input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

///
unittest {
    alias BI = BigInteger!MaxDigitsPerInteger;
    typeof(BI.storage) storage;
    bool isNegative, truncated;

    assert(parseDecimalValue(storage[], isNegative, "-1234", truncated) == 5);
    assert(isNegative);
    assert(!truncated);
    assert(storage[0] == 1234);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16.LiteralType input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32.LiteralType input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF8 input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF16 input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope String_UTF32 input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF8 input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF16 input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
}

/// Ditto
size_t parseDecimalValue(scope PerIntegerType[] output, out bool isNegative, scope StringBuilder_UTF32 input, out bool truncated) {
    return parse10Impl(output, isNegative, input, truncated);
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
            size_t quotient2, haveShifted = canShift;
            PerIntegerType[] divisor2 = quotient;

            foreach(i, v; divisor) {
                divisor2[i] = v;
            }

            leftShift(divisor2, canShift);

            while(quotient2 <= (ulong.max >> 4) && haveShifted >= 4) {
                size_t quotientTemp;

                while(unsignedCompare(remainder, divisor2) >= 0) {
                    cast(void)unsignedSubtraction(remainder, divisor2);
                    quotientTemp++;
                }

                quotient2 <<= 4;
                quotient2 += quotientTemp;
                haveShifted -= 4;

                rightShift(divisor2, 4);
            }

            importValue(quotient, quotient2, overflow);
            leftShift(quotient, haveShifted + 4);
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
    else if(output.ptr is input1.ptr)
        return ErrorResult(MalformedInputException("Output array must not be first input array"));
    else if(output.ptr is input2.ptr)
        return ErrorResult(MalformedInputException("Output array must not be second input array"));

    foreach(ref v; output) {
        v = 0;
    }

    unsignedMultiplyAddImpl(output, input1, input2, overflow);
    return ErrorResult.init;
}

///
unittest {
    PerIntegerType input = PerIntegerType(1) << (BitsPerInteger - 3), multiplier = 8, expected = PerIntegerType(1) << BitsPerInteger;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageInput, storageMultiplier, storageExpected;
    bool truncated, overflow;

    importValue(storageInput[], input, truncated);
    importValue(storageMultiplier[], multiplier, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(unsignedMultiply(storageOutput[], storageInput[], storageMultiplier[], overflow));
    assert(!overflow);
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
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
    else if(output.ptr is input1.ptr)
        return ErrorResult(MalformedInputException("Output array must not be the same array as input 1"));
    else if(output.ptr is input2.ptr)
        return ErrorResult(MalformedInputException("Output array must not be the same array as input 2"));

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
    else if(output.ptr is input.ptr)
        return ErrorResult(MalformedInputException("Output array must not be the same array as input"));

    foreach(powerOfMaxPerInteger, toAdd; input) {
        unsignedAdditionImpl(output, toAdd, powerOfMaxPerInteger, overflow);
    }

    return ErrorResult.init;
}

///
unittest {
    PerIntegerType input = PerIntegerType(1) << (BitsPerInteger - 1), expected = PerIntegerType(1) << BitsPerInteger;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageInput, storageExpected;
    bool truncated, overflow;

    importValue(storageOutput[], input, truncated);
    importValue(storageInput[], input, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(unsignedAddition(storageOutput[], storageInput[], overflow));
    assert(!overflow);
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
}

/// Add an unsigned integer at a given bit position
void unsignedAddition(scope PerIntegerType[] output, ulong input, size_t bitOffsetFromLSB, ref bool overflow) {
    size_t powerOf2Offset = bitOffsetFromLSB / BitsPerInteger;
    const leftOver = bitOffsetFromLSB % BitsPerInteger;

    if(leftOver != 0) {
        const toAdd = input & ((1 << (leftOver + 1)) - 1);
        const toAddShifted = toAdd << leftOver;

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

/// Non-even shift
unittest {
    const lsh = BitsPerInteger - 1;
    PerIntegerType input = PerIntegerType(1) << lsh, expected = PerIntegerType(1) << BitsPerInteger;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageExpected;
    bool truncated, overflow;

    importValue(storageOutput[], input, truncated);
    importValue(storageExpected[], expected, truncated);

    unsignedAddition(storageOutput[], 1, lsh, overflow);
    assert(!overflow);
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
}

/// Even shift
unittest {
    PerIntegerType input = PerIntegerType(1) << BitsPerInteger - 1, expected = PerIntegerType(1) << BitsPerInteger;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageExpected;
    bool truncated, overflow;

    importValue(storageOutput[], input, truncated);
    importValue(storageExpected[], expected, truncated);

    unsignedAddition(storageOutput[], input, 0, overflow);
    assert(!overflow);
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
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

/// Negative - Positive
unittest {
    PerIntegerType input = PerIntegerType(1) << BitsPerInteger, expected = input | 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageInput, storageSubtraction, storageExpected;
    bool truncated, overflow, isNegative;

    importValue(storageInput[], input, truncated);
    importValue(storageSubtraction[], 1, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(signedSubtraction(storageOutput[], isNegative, storageInput[], true, storageSubtraction[], false, overflow));
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
    assert(isNegative);
    assert(!overflow);
}

/// Positive - Negative
unittest {
    PerIntegerType input = PerIntegerType(1) << BitsPerInteger, expected = input + 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageInput, storageSubtraction, storageExpected;
    bool truncated, overflow, isNegative;

    importValue(storageInput[], input, truncated);
    importValue(storageSubtraction[], 1, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(signedSubtraction(storageOutput[], isNegative, storageInput[], false, storageSubtraction[], true, overflow));
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
    assert(!isNegative);
    assert(!overflow);
}

/// Negative - Negative
unittest {
    PerIntegerType input = PerIntegerType(1) << BitsPerInteger, expected = input - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageInput, storageSubtraction, storageExpected;
    bool truncated, overflow, isNegative;

    importValue(storageInput[], input, truncated);
    importValue(storageSubtraction[], 1, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(signedSubtraction(storageOutput[], isNegative, storageInput[], true, storageSubtraction[], true, overflow));
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
    assert(isNegative);
    assert(!overflow);
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
unittest {
    PerIntegerType input = PerIntegerType(1) << BitsPerInteger, expected = (PerIntegerType(1) << BitsPerInteger) - 1;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storageOutput, storageInput, storageSubtraction, storageExpected;
    bool truncated;

    importValue(storageInput[], input, truncated);
    importValue(storageSubtraction[], 1, truncated);
    importValue(storageExpected[], expected, truncated);

    assert(unsignedSubtraction(storageOutput[], storageInput[], storageSubtraction[]));
    assert(unsignedCompare(storageOutput[], storageExpected[]) == 0);
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

        foreach(i; 0 .. entriesToIgnore) {
            output[i] = 0;
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
                    output[dstByteOffset] = temp & PerIntegerMask;
                }

                if(srcByteOffset == 0)
                    break;

                srcByteOffset--;

                {
                    // 1.1) abcd efgh +efg -> d+++ -> abcd efgh defg
                    // 2.1) abcd efgh +ijk -> h+++ -> abcd efgh hijk
                    // 2.2) abcd +efg hijk -> d+++ -> abcd defg hijk
                    const temp = output[srcByteOffset] >> bitsToIgnore;
                    output[dstByteOffset] |= temp & PerIntegerMask;
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

///
unittest {
    PerIntegerType expected1 = PerIntegerType(1) << (BitsPerInteger - 1), expected2 = PerIntegerType(1) << BitsPerInteger;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage1, storage2, storageExpected1, storageExpected2;
    bool truncated;

    importValue(storage1, 1, truncated);
    importValue(storage2, 1, truncated);
    importValue(storageExpected1, expected1, truncated);
    importValue(storageExpected2, expected2, truncated);

    leftShift(storage1, BitsPerInteger - 1);
    assert(unsignedCompare(storage1[], storageExpected1[]) == 0);

    leftShift(storage2, BitsPerInteger);
    assert(unsignedCompare(storage2[], storageExpected2[]) == 0);
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

        foreach(i; output.length - entriesToIgnore .. output.length) {
            output[i] = 0;
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
unittest {
    PerIntegerType input1 = PerIntegerType(1) << (BitsPerInteger - 1), input2 = PerIntegerType(1) << BitsPerInteger;

    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage1, storage2, storageExpected;
    bool truncated;

    importValue(storage1, input1, truncated);
    importValue(storage2, input2, truncated);
    importValue(storageExpected, 1, truncated);

    rightShift(storage1, BitsPerInteger - 1);
    assert(unsignedCompare(storage1[], storageExpected[]) == 0);

    rightShift(storage2, BitsPerInteger);
    assert(unsignedCompare(storage2[], storageExpected[]) == 0);
}

///
ErrorResult bitwiseAnd(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    return bitwiseAnd(output, output, input);
}

///
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage, storageExpected;
    bool truncated;

    importValue(storage[], 15, truncated);
    importValue(storageExpected[], 5, truncated);

    assert(bitwiseAnd(storage[], storageExpected[]));
    assert(unsignedCompare(storage[], storageExpected[]) == 0);
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
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage, storageExpected;
    bool truncated;

    importValue(storage[], 15, truncated);
    importValue(storageExpected[], 5, truncated);

    assert(bitwiseAnd(storage[], storage[], storageExpected[]));
    assert(unsignedCompare(storage[], storageExpected[]) == 0);
}

///
ErrorResult bitwiseOr(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    return bitwiseOr(output, output, input);
}

///
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage, storageOr, storageExpected;
    bool truncated;

    importValue(storage[], 14, truncated);
    importValue(storageOr[], 1, truncated);
    importValue(storageExpected[], 15, truncated);

    assert(bitwiseOr(storage[], storageOr[]));
    assert(unsignedCompare(storage[], storageExpected[]) == 0);
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
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage, storageOr, storageExpected;
    bool truncated;

    importValue(storage[], 14, truncated);
    importValue(storageOr[], 1, truncated);
    importValue(storageExpected[], 15, truncated);

    assert(bitwiseOr(storage[], storage[], storageOr[]));
    assert(unsignedCompare(storage[], storageExpected[]) == 0);
}

///
ErrorResult bitwiseXor(scope PerIntegerType[] output, scope const(PerIntegerType)[] input) {
    return bitwiseXor(output, output, input);
}

///
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage, storageXor, storageExpected;
    bool truncated;

    importValue(storage[], 14, truncated);
    importValue(storageXor[], 3, truncated);
    importValue(storageExpected[], 13, truncated);

    assert(bitwiseXor(storage[], storageXor[]));
    assert(unsignedCompare(storage[], storageExpected[]) == 0);
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
        v = (input1[offset] ^ input2[offset]) & PerIntegerMask;
    }

    foreach(offset, ref v; output[min .. input1.length]) {
        v = (input1[offset + min] ^ 0) & PerIntegerMask;
    }

    foreach(ref v; output[input1.length .. $]) {
        v = 0;
    }

    return ErrorResult.init;
}

///
unittest {
    alias BI = BigInteger!(MaxDigitsPerInteger * 2);
    typeof(BI.storage) storage, storageXor, storageExpected;
    bool truncated;

    importValue(storage[], 14, truncated);
    importValue(storageXor[], 3, truncated);
    importValue(storageExpected[], 13, truncated);

    assert(bitwiseXor(storage[], storage[], storageXor[]));
    assert(unsignedCompare(storage[], storageExpected[]) == 0);
}

/// Will heap allocate and mutates exponent
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
    return unsignedPower(output, input, exponent, overflow);
}

/// Will heap allocate and mutates exponent
ErrorResult unsignedPower(scope PerIntegerType[] output, scope const(PerIntegerType)[] input,
        scope PerIntegerType[] exponent, out bool overflow) {
    foreach(i, ref v; output) {
        v = input[i];
    }

    ErrorResult ret;

    void bySquare(scope PerIntegerType[] mantissa, scope PerIntegerType[] exponent) {
        bool allZero = true;
        foreach(b; exponent) {
            if(b > 0) {
                allZero = false;
                break;
            }
        }

        if(allZero) {
            mantissa[0] = 1;

            foreach(ref b; mantissa[1 .. $])
                b = 0;
        } else if((exponent[0] & 1) == 0) {
            rightShift(exponent, 1);
            leftShift(mantissa, 1);
            bySquare(mantissa, exponent);
        } else {
            import sidero.base.algorithm : max;

            static immutable one = [1L];

            SmallArrayPerInteger temp1 = SmallArrayPerInteger(max(exponent.length, mantissa.length));
            ret = unsignedSubtraction(temp1.buffer, exponent, one);
            if(!ret)
                return;

            rightShift(exponent, 1);
            ret = unsignedMultiply(temp1.buffer, mantissa, mantissa, overflow);
            if(!ret)
                return;

            SmallArrayPerInteger temp2 = SmallArrayPerInteger(temp1.buffer);
            bySquare(temp2.buffer, exponent);
            ret = unsignedMultiply(mantissa, temp1.buffer, temp2.buffer, overflow);
            if(!ret)
                return;
        }
    }

    bySquare(output, exponent);

    return ret;
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

size_t parse10Impl(Str)(scope PerIntegerType[] output, out bool isNegative, scope Str input, out bool truncated) @trusted {
    import sidero.base.allocators;

    PerIntegerType temp;
    size_t used, digits;

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
        } else if(c == '_')
            continue;
        else
            break;

        store(false);
    }

    store(true);

    if(used == 1 && isNegative) {
        used = 0;
        isNegative = false;
    }

    return used;
}

size_t parse16Impl(Str)(scope PerIntegerType[] output, out bool isNegative, Str input, out bool truncated) {
    PerIntegerType temp;
    size_t used, count, totalBitCount;
    ptrdiff_t offset = output.length - 1;

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
        } else if(c == '_')
            continue;
        else
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

    if(totalBitCount > output.length * BitsPerInteger)
        truncated = true;

    if(used == 1 && isNegative) {
        used = 0;
        isNegative = false;
    }

    return used;
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
    if(powerOfMaxPerInteger >= output.length) {
        if(toAdd != 0)
            overflow = true;
        return;
    }

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

size_t neededStorageGivenDigits(size_t neededDigits) {
    return (neededDigits + MaxDigitsPerInteger - 1) / MaxDigitsPerInteger;
}

struct SmallArrayPerInteger {
    import sidero.base.containers.dynamicarray;

    PerIntegerType[] buffer;
    PerIntegerType[64] stackBuffer;
    DynamicArray!PerIntegerType heapBuffer;

@safe nothrow @nogc:

    this(size_t needed) @trusted {
        if(needed > stackBuffer.length) {
            heapBuffer.length = needed;
            buffer = heapBuffer.unsafeGetLiteral;
        } else
            buffer = stackBuffer[0 .. needed];
    }

    this(const(PerIntegerType)[] needed) @trusted {
        this.__ctor(needed.length);

        foreach(i; 0 .. needed.length) {
            buffer[i] = needed[i];
        }
    }
}
