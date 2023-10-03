module sidero.base.path.hostname;
import sidero.base.text;

///
struct Hostname {
    private {
        String_ASCII text;
        Type type_;
    }

export @safe nothrow @nogc:

    ///
    this(ref return scope Hostname other) scope {
        this.tupleof = other.tupleof;
    }

    ///
    ~this() scope {
    }

    ///
    bool isNull() scope const {
        return text.isNull;
    }

    ///
    String_ASCII get() return scope {
        return this.text;
    }

    ///
    Type type() scope const {
        return type_;
    }

    ///
    void opAssign(return scope Hostname other) scope {
        this.__ctor(other);
    }

    ///
    StringBuilder_UTF8 decoded() scope {
        import sidero.base.encoding.bootstring;

        auto ret = IDNAPunycode.decode(text);

        if(ret)
            return ret.get.byUTF8;
        else
            return StringBuilder_UTF8.init;
    }

    ///
    static Hostname fromEncoded(return scope String_ASCII input) {
        return Hostname(input).determineType;
    }

    ///
    unittest {
        Hostname example = Hostname.fromEncoded(String_ASCII("example.com"));
        assert(!example.isNull);
        assert(example.type == Type.Domain);
        assert(example.get == String_ASCII("example.com"));
        assert(example.decoded == String_UTF8("example.com"));
    }

    ///
    unittest {
        Hostname example = Hostname.fromEncoded(String_ASCII("127.0.0.1"));
        assert(!example.isNull);
        assert(example.type == Type.IPv4);
        assert(example.get == String_ASCII("127.0.0.1"));
        assert(example.decoded == String_UTF8("127.0.0.1"));
    }

    ///
    unittest {
        Hostname example = Hostname.fromEncoded(String_ASCII("[::1]"));
        assert(!example.isNull);
        assert(example.type == Type.IPv6);
        assert(example.get == String_ASCII("[::1]"));
        assert(example.decoded == String_UTF8("[::1]"));
    }

    ///
    static Hostname from(return scope String_UTF8.LiteralType input) @trusted {
        auto temp = String_UTF8(input);
        return Hostname.from(temp);
    }

    ///
    static Hostname from(return scope String_UTF16.LiteralType input) @trusted {
        auto temp = String_UTF8(input);
        return Hostname.from(temp);
    }

    ///
    static Hostname from(return scope String_UTF32.LiteralType input) @trusted {
        auto temp = String_UTF8(input);
        return Hostname.from(temp);
    }

    ///
    static Hostname from(return scope String_UTF8 input) {
        return Hostname.fromDecoded(input).determineType;
    }

    ///
    static Hostname from(return scope String_UTF16 input) {
        return Hostname.fromDecoded(input).determineType;
    }

    ///
    static Hostname from(return scope String_UTF32 input) {
        return Hostname.fromDecoded(input).determineType;
    }

    ///
    static Hostname from(return scope StringBuilder_UTF8 input) {
        return Hostname.fromDecoded(input).determineType;
    }

    ///
    static Hostname from(return scope StringBuilder_UTF16 input) {
        return Hostname.fromDecoded(input).determineType;
    }

    ///
    static Hostname from(return scope StringBuilder_UTF32 input) {
        return Hostname.fromDecoded(input).determineType;
    }

    ///
    unittest {
        Hostname example = Hostname.from("Hello \u9EDEWorld!");
        assert(!example.isNull);
        assert(example.type == Type.Domain);
        assert(example.get == String_ASCII("xn--Hello World!-wi44b"));
        assert(example.decoded == String_UTF8("Hello \u9EDEWorld!"));
    }

    ///
    bool opEquals(scope Hostname other) scope const {
        return this.text == other.text;
    }

    ///
    int opCmp(scope Hostname other) scope const {
        return this.text.opCmp(other.text);
    }

    ///
    ulong toHash() scope const {
        return this.text.toHash();
    }

    ///
    String_ASCII toString() scope return {
        return this.text;
    }

    ///
    enum Type {
        ///
        Unknown,
        ///
        IPv4,
        ///
        IPv6,
        ///
        IPfuture,
        ///
        Domain,
    }

private:

    Hostname determineType() return scope {
        // a very non-verifying bit determinance of what type of hostname this is

        if(text.startsWith("[")) {
            if(text[1 .. $].startsWith("v")) {
                this.type_ = Type.IPfuture;
                return this;
            } else {
                this.type_ = Type.IPv6;
                return this;
            }
        } else {
            String_ASCII tryASCII = text.save;
            ubyte[4] octet;

            if(formattedRead(tryASCII, String_ASCII("{:d}.{:d}.{:d}.{:d}"), octet[0], octet[1], octet[2], octet[3])) {
                // is ipv4
                this.type_ = Type.IPv4;
                return this;
            } else {
                this.type_ = Type.Domain;
                return this;
            }
        }
    }

    static Hostname fromDecoded(Input)(return scope Input input) {
        import sidero.base.encoding.bootstring;

        auto got = IDNAPunycode.encode(input);
        if(got)
            return Hostname(got.get.asReadOnly);
        else
            return Hostname.init;
    }
}
