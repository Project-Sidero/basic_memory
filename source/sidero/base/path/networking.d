module sidero.base.path.networking;
import sidero.base.path.uri;
import sidero.base.attributes;
import sidero.base.text;
import sidero.base.containers.dynamicarray;
import sidero.base.allocators;

/// port, IPv4, IPv6 are stored in big endian suitable for network API's. Hostname is stored as IDN/Punycode.
struct NetworkAddress {
    private @PrintIgnore @PrettyPrintIgnore {
        Type type_;
        ushort port_;

        String_ASCII hostname_;
        union {
            uint ipv4_;
            ushort[8] ipv6_;
        }
    }

export @safe nothrow @nogc:

    ///
    this(scope return ref NetworkAddress other) scope {
        this.tupleof = other.tupleof;
    }

    ///
    Type type() scope const {
        return this.type_;
    }

    ///
    ushort port() scope const {
        version (LittleEndian) {
            import std.bitmanip : swapEndian;

            return swapEndian(this.port_);
        } else
            return this.port_;
    }

    ///
    ushort networkOrderPort() scope const {
        return this.port_;
    }

    ///
    void onNetworkOrder(scope void delegate(uint value) @safe nothrow @nogc on4,
            scope void delegate(ushort[8] value) @safe nothrow @nogc on6, scope void delegate() @safe nothrow @nogc onAny4,
            scope void delegate() @safe nothrow @nogc onAny6, scope void delegate(
                scope String_ASCII hostname) @safe nothrow @nogc onHostname, scope void delegate() @safe nothrow @nogc onNone) scope {
        final switch (this.type_) {
        case Type.Invalid:
            onNone();
            break;
        case Type.IPv4:
            on4(ipv4_);
            break;
        case Type.IPv6:
            on6(ipv6_);
            break;
        case Type.Any4:
            onAny4();
            break;
        case Type.Any6:
            onAny6();
            break;
        case Type.Hostname:
            onHostname(this.hostname_);
            break;
        }
    }

    ///
    void onSystemOrder(scope void delegate(uint value) @safe nothrow @nogc on4,
            scope void delegate(ushort[8] value) @safe nothrow @nogc on6, scope void delegate() @safe nothrow @nogc onAny4,
            scope void delegate() @safe nothrow @nogc onAny6, scope void delegate(
                scope String_ASCII hostname) @safe nothrow @nogc onHostname, scope void delegate() @safe nothrow @nogc onNone) scope {
        import std.bitmanip : swapEndian;

        final switch (this.type_) {
        case Type.Invalid:
            onNone();
            break;
        case Type.IPv4:
            on4(swapEndian(ipv4_));
            break;
        case Type.IPv6:
            on6([
                swapEndian(ipv6_[0]), swapEndian(ipv6_[1]), swapEndian(ipv6_[2]), swapEndian(ipv6_[3]),
                swapEndian(ipv6_[4]), swapEndian(ipv6_[5]), swapEndian(ipv6_[6]), swapEndian(ipv6_[7])
            ]);
            break;
        case Type.Any4:
            onAny4();
            break;
        case Type.Any6:
            onAny6();
            break;
        case Type.Hostname:
            onHostname(this.hostname_);
            break;
        }
    }

    ///
    static NetworkAddress fromIPv4(ushort port, ubyte a, ubyte b, ubyte c, ubyte d, bool isPortNetworkEndian = false) {
        import std.bitmanip;

        NetworkAddress ret;
        ret.type_ = Type.IPv4;
        ret.port_ = port;
        ret.ipv4_ = littleEndianToNative!uint([a, b, c, d]);

        if (!isPortNetworkEndian) {
            version (LittleEndian) {
                ret.port_ = swapEndian(ret.port_);
            }
        }

        return ret;
    }

    ///
    static NetworkAddress fromIPv4(ushort port, uint value, bool isPortNetworkEndian = false, bool isIPNetworkEndian = false) {
        import std.bitmanip;

        NetworkAddress ret;
        ret.type_ = Type.IPv4;
        ret.port_ = port;
        ret.ipv4_ = value;

        if (!isPortNetworkEndian) {
            version (LittleEndian) {
                ret.port_ = swapEndian(ret.port_);
            }
        }

        if (!isIPNetworkEndian) {
            version (LittleEndian) {
                ret.ipv4_ = swapEndian(ret.ipv4_);
            }
        }

        return ret;
    }

    ///
    static NetworkAddress fromIPv6(ushort port, ushort a, ushort b, ushort c, ushort d, ushort e, ushort f, ushort g, ushort h,
            bool isPortNetworkEndian = false, bool isIPNetworkEndian = false) {
        import std.bitmanip;

        return NetworkAddress.fromIPv6(port, [a, b, c, d, e, f, g, h], isPortNetworkEndian, isIPNetworkEndian);
    }

    ///
    static NetworkAddress fromIPv6(ushort port, ushort[8] segments, bool isPortNetworkEndian = false, bool isIPNetworkEndian = false) {
        import std.bitmanip;

        NetworkAddress ret;
        ret.type_ = Type.IPv6;
        ret.port_ = port;
        ret.ipv6_ = segments;

        if (!isPortNetworkEndian) {
            version (LittleEndian) {
                ret.port_ = swapEndian(ret.port_);
            }
        }

        if (!isIPNetworkEndian) {
            version (LittleEndian) {
                ret.ipv6_ = [
                    swapEndian(ret.ipv6_[0]), swapEndian(ret.ipv6_[1]), swapEndian(ret.ipv6_[2]),
                    swapEndian(ret.ipv6_[3]), swapEndian(ret.ipv6_[4]), swapEndian(ret.ipv6_[5]),
                    swapEndian(ret.ipv6_[6]), swapEndian(ret.ipv6_[7]),
                ];
            }
        }

        return ret;
    }

    ///
    static NetworkAddress fromAnyIPv4(ushort port, bool isPortNetworkEndian = false) {
        import std.bitmanip;

        NetworkAddress ret;
        ret.type_ = Type.Any4;
        ret.port_ = port;

        if (!isPortNetworkEndian) {
            version (LittleEndian) {
                ret.port_ = swapEndian(ret.port_);
            }
        }
        return ret;
    }

    ///
    static NetworkAddress fromAnyIPv6(ushort port, bool isPortNetworkEndian = false) {
        import std.bitmanip;

        NetworkAddress ret;
        ret.type_ = Type.Any6;
        ret.port_ = port;

        if (!isPortNetworkEndian) {
            version (LittleEndian) {
                ret.port_ = swapEndian(ret.port_);
            }
        }
        return ret;
    }

    /// parse a URI compliant hostname/ip
    static NetworkAddress from(scope String_ASCII input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope StringBuilder_ASCII input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope String_UTF8.LiteralType input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope String_UTF16.LiteralType input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope String_UTF32.LiteralType input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope String_UTF8 input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope String_UTF16 input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope String_UTF32 input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope StringBuilder_UTF8 input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope StringBuilder_UTF16 input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    /// Ditto
    static NetworkAddress from(scope StringBuilder_UTF32 input, ushort port, bool isPortNetworkEndian = false) {
        auto got = URIAddress.from(input);
        if (!got)
            return NetworkAddress.init;

        return NetworkAddress.fromURIHost(got.host, port, isPortNetworkEndian);
    }

    ///
    unittest {
        NetworkAddress.from("127.0.0.1"c, 0).onNetworkOrder((uint address) {
            // ipv4
            assert(address == 0x100007F);
        }, (ushort[8] address) {
            // ipv6
            assert(0);
        }, () {
            // any ipv4
            assert(0);
        }, () {
            // any ipv6
            assert(0);
        }, (scope String_ASCII hostname) { assert(0); }, () {
            // invalid
            assert(0);
        });

        NetworkAddress.from("0.0.0.0"c, 0).onNetworkOrder((uint address) {
            // ipv4
            assert(0);
        }, (ushort[8] address) {
            // ipv6
            assert(0);
        }, () {
            // any ipv4
            assert(true);
        }, () {
            // any ipv6
            assert(0);
        }, (scope String_ASCII hostname) { assert(0); }, () {
            // invalid
            assert(0);
        });

        NetworkAddress.from("[CDEF::1234:127.0.0.1]"c, 0).onNetworkOrder((uint address) {
            // ipv4
            assert(0);
        }, (ushort[8] address) {
            // ipv6
            assert(address == [0xEFCD, 0, 0, 0, 0, 0x3412, 0x7F, 0x100]);
        }, () {
            // any ipv4
            assert(0);
        }, () {
            // any ipv6
            assert(0);
        }, (scope String_ASCII hostname) { assert(0); }, () {
            // invalid
            assert(0);
        });

        NetworkAddress.from("[::]"c, 0).onNetworkOrder((uint address) {
            // ipv4
            assert(0);
        }, (ushort[8] address) {
            // ipv6
            assert(0);
        }, () {
            // any ipv4
            assert(0);
        }, () {
            // any ipv6
            assert(true);
        }, (scope String_ASCII hostname) { assert(0); }, () {
            // invalid
            assert(0);
        });

        NetworkAddress.from("host.name"c, 0).onNetworkOrder((uint address) {
            // ipv4
            assert(0);
        }, (ushort[8] address) {
            // ipv6
            assert(0);
        }, () {
            // any ipv4
            assert(0);
        }, () {
            // any ipv6
            assert(0);
        }, (scope String_ASCII hostname) { assert(hostname == "host.name"); }, () {
            // invalid
            assert(0);
        });
    }

    ///
    unittest {
        NetworkAddress.from("127.0.0.1"c, 0).onSystemOrder((uint address) {
            // ipv4
            assert(address == 0x7F_00_00_01);
        }, (ushort[8] address) {
            // ipv6
            assert(0);
        }, () {
            // any ipv4
            assert(0);
        }, () {
            // any ipv6
            assert(0);
        }, (scope String_ASCII hostname) { assert(0); }, () {
            // invalid
            assert(0);
        });

        NetworkAddress.from("[CDEF::1234:127.0.0.1]"c, 0).onSystemOrder((uint address) {
            // ipv4
            assert(0);
        }, (ushort[8] address) {
            // ipv6
            assert(address == [0xCDEF, 0, 0, 0, 0, 0x1234, 0x7F00, 0x1]);
        }, () {
            // any ipv4
            assert(0);
        }, () {
            // any ipv6
            assert(0);
        }, (scope String_ASCII hostname) { assert(0); }, () {
            // invalid
            assert(0);
        });
    }

    ///
    DynamicArray!NetworkAddress resolve(scope return RCAllocator allocator = RCAllocator.init) scope @trusted {
        auto ret = DynamicArray!NetworkAddress(allocator);

        final switch (this.type_) {
        case Type.Invalid:
        case Type.Any4:
        case Type.Any6:
            break;

        case Type.IPv4:
        case Type.IPv6:
            ret ~= this;
            break;

        case Type.Hostname:
            // this Windows specific version of function isn't required as ours is already encoded approprietely to ANSI
            version (none) {
                {
                    String_UTF16 hn16 = String_UTF16(cast(string)this.hostname_.unsafeGetLiteral).dup;
                    ADDRINFOW* result, current;

                    // use GetAddrInfoW https://learn.microsoft.com/en-us/windows/win32/api/ws2tcpip/nf-ws2tcpip-getaddrinfow
                    if (GetAddrInfoW(hn16.ptr, null, null, &result) == 0) {
                        current = result;

                        while (current !is null) {
                            if (current.ai_addr.sa_family == AF_INET) {
                                sockaddr_in* address = cast(sockaddr_in*)current.ai_addr;
                                ret ~= NetworkAddress.fromIPv4(this.port_, address.sin_addr.s_addr, true, true);
                            } else if (current.ai_addr.sa_family == AF_INET6) {
                                sockaddr_in6* address = cast(sockaddr_in6*)current.ai_addr;
                                ret ~= NetworkAddress.fromIPv6(this.port_, address.sin6_addr.s6_addr16, true, true);
                            }

                            current = current.ai_next;
                        }

                        FreeAddrInfoW(result);
                        break;
                    } else {
                        // use fallback getaddrinfo
                    }
                }
            }

            {
                addrinfo* result, current;

                if (getaddrinfo(cast(char*)this.hostname_.ptr, null, null, &result) == 0) {
                    current = result;

                    while (current !is null) {
                        if (current.ai_addr.sa_family == AF_INET) {
                            sockaddr_in* address = cast(sockaddr_in*)current.ai_addr;
                            ret ~= NetworkAddress.fromIPv4(this.port_, address.sin_addr.s_addr, true, true);
                        } else if (current.ai_addr.sa_family == AF_INET6) {
                            sockaddr_in6* address = cast(sockaddr_in6*)current.ai_addr;
                            ret ~= NetworkAddress.fromIPv6(this.port_, address.sin6_addr.s6_addr16, true, true);
                        }

                        current = current.ai_next;
                    }

                    freeaddrinfo(result);
                }
            }
            break;
        }

        return ret;
    }

    ///
    StringBuilder_UTF8 toString(return scope RCAllocator allocator = RCAllocator.init) scope const @trusted {
        StringBuilder_UTF8 sink = StringBuilder_UTF8(allocator);
        this.toString(sink);
        return sink;
    }

    ///
    void toString(Sink)(scope ref Sink sink) scope const @trusted {
        import std.bitmanip : swapEndian;

        bool doPort = true;

        (cast(NetworkAddress*)&this).onNetworkOrder((uint address) {
            // ipv4
            sink.formattedWrite("{:d}.{:d}.{:d}.{:d}", address & 0xFF, (address >> 8) & 0xFF, (address >> 16) & 0xFF, (address >> 24) & 0xFF);
        }, (ushort[8] address) {
            // ipv6
            sink.formattedWrite("[{:4X}:{:4X}:{:4X}:{:4X}:{:4X}:{:4X}:{:4X}:{:4X}]", swapEndian(address[0]),
                swapEndian(address[1]), swapEndian(address[2]), swapEndian(address[3]), swapEndian(address[4]),
                swapEndian(address[5]), swapEndian(address[6]), swapEndian(address[7]));
        }, () {
            // any ipv4
            sink ~= "0.0.0.0"c;
        }, () {
            // any ipv6
            sink ~= "[::]"c;
        }, (scope String_ASCII hostname) {
            import sidero.base.encoding.bootstring;

            if (!IDNAPunycode.decode(sink, hostname))
                doPort = false;
        }, () {
            // invalid
            doPort = false;
        });

        if (doPort)
            sink.formattedWrite(":{:d}", this.port());
    }

    ///
    ulong toHash() scope const @trusted {
        import sidero.base.hash.utils;
        return hashOf(*cast(NetworkAddress*)&this);
    }

    ///
    enum Type {
        ///
        Invalid,
        ///
        IPv4,
        ///
        IPv6,
        ///
        Any4,
        ///
        Any6,
        ///
        Hostname
    }

    package(sidero.base.path) static NetworkAddress fromURIHost(scope return String_ASCII input, ushort port, bool isPortNetworkEndian) {
        import std.bitmanip : swapEndian;

        if (input.isNull) {
            return NetworkAddress.init;
        }

        assert(input.isPtrNullTerminated);

        NetworkAddress ret;
        ret.port_ = port;

        if (!isPortNetworkEndian) {
            version (LittleEndian) {
                ret.port_ = swapEndian(ret.port_);
            }
        }

        // fill in type + dns/ipv4/ipv6
        if (!ret.fillInAddress(input)) {
            return NetworkAddress.init;
        }

        // handle conversion from any address to the right type
        final switch (ret.type_) {
        case Type.IPv4:
            // ipv4 any: 0.0.0.0
            if (ret.ipv4_ == 0)
                ret.type_ = Type.Any4;
            break;

        case Type.IPv6:
            // ipv6 any: :: or 0000:0000:0000:0000:0000:0000:0000:0000
            if (ret.ipv6_[0] == 0 && ret.ipv6_[1] == 0 && ret.ipv6_[2] == 0 && ret.ipv6_[3] == 0 && ret.ipv6_[4] == 0 &&
                    ret.ipv6_[5] == 0 && ret.ipv6_[6] == 0 && ret.ipv6_[7] == 0)
                ret.type_ = Type.Any6;
            break;

        case Type.Hostname:
            break;

        case Type.Invalid:
        case Type.Any4:
        case Type.Any6:
            assert(0);
        }

        return ret;
    }

private:
    bool fillInAddress(scope return String_ASCII input) scope @trusted {
        import std.bitmanip : littleEndianToNative;

        if (input.startsWith("[")) {
            const possibleLengthOfHost = input.indexOf("]");

            if (possibleLengthOfHost < 0)
                return false;
            String_ASCII ipLiteral = input[1 .. possibleLengthOfHost];

            if (ipLiteral.startsWith("v")) {
                // NOPE: we don't support future ip addresses since its gotta map something to actual system API's...
                return false;
            } else {
                //lets slice and dice to produce three strings
                String_ASCII before, after, ipv4;

                {
                    ptrdiff_t index;

                    index = ipLiteral.indexOf("::"c);
                    if (index >= 0) {
                        before = ipLiteral[0 .. index];
                        ipLiteral = ipLiteral[index + 2 .. $];
                    } else {
                        before = ipLiteral;
                        ipLiteral = String_ASCII.init;
                    }

                    index = ipLiteral.lastIndexOf(":"c);
                    if (index >= 0) {
                        if (ipLiteral[index + 1 .. $].contains("."c)) {
                            after = ipLiteral[0 .. index];
                            ipv4 = ipLiteral[index + 1 .. $];
                            ipLiteral = String_ASCII.init;
                        } else {
                            after = ipLiteral;
                            ipLiteral = String_ASCII.init;
                        }
                    } else {
                        after = ipLiteral;
                        ipLiteral = String_ASCII.init;
                    }
                }

                foreach (offset16; 0 .. 8) {
                    if (before.empty)
                        break;

                    ushort hexent;
                    cast(void)formattedRead(before, String_ASCII("{:x}:"), hexent);
                    this.ipv6_[offset16] = (((hexent & 0xFF) << 8) | (hexent >> 8)) & 0xFFFF;
                }

                const readIPv4 = ipv4.length > 0;

                if (readIPv4) {
                    foreach (offset8; 0 .. 4) {
                        if (ipv4.empty)
                            break;

                        const offset16 = 6 + (offset8 / 2);
                        const isLower = (offset8 & 1) == 0;

                        ubyte octet;
                        cast(void)formattedRead(ipv4, String_ASCII("{:d}."), octet);

                        if (isLower)
                            this.ipv6_[offset16] = octet;
                        else
                            this.ipv6_[offset16] |= (octet << 8) & 0xFFFF;
                    }
                }

                {
                    ushort[2] temp;
                    uint used;

                    const max = readIPv4 ? 6 : 8;
                    foreach (offset16; 0 .. 2) {
                        if (after.empty)
                            break;

                        cast(void)formattedRead(after, String_ASCII("{:x}:"), temp[used]);
                        used++;
                    }

                    foreach (i; 0 .. used) {
                        this.ipv6_[max - (used - i)] = (((temp[i] & 0xFF) << 8) | (temp[i] >> 8)) & 0xFFFF;
                    }
                }

                this.type_ = Type.IPv6;
                return true;
            }
        } else {
            String_ASCII tryASCII = input.save;
            ubyte[4] octet;

            if (formattedRead(tryASCII, String_ASCII("{:d}.{:d}.{:d}.{:d}"), octet[0], octet[1], octet[2], octet[3])) {
                // is ipv4
                this.ipv4_ = littleEndianToNative!uint([octet[0], octet[1], octet[2], octet[3]]);
                this.type_ = Type.IPv4;
                return true;
            } else {
                // try to handle as if it was a hostname
                this.hostname_ = input;
                this.type_ = Type.Hostname;
                return true;
            }
        }
    }
}

private:

version (Windows) {
    import core.sys.windows.winsock2 : sockaddr, AF_INET, AF_INET6, sockaddr_in, sockaddr_in6, getaddrinfo, freeaddrinfo, addrinfo;

    enum {
        AI_V4MAPPED = 0x0800,
    }

    struct ADDRINFOW {
        int ai_flags;
        int ai_family;
        int ai_socktype;
        int ai_protocol;
        size_t ai_addrlen;
        wchar* ai_canonname;
        sockaddr* ai_addr;
        ADDRINFOW* ai_next;
    }

    extern (Windows) nothrow @nogc {
        int GetAddrInfoW(const(wchar)*, wchar*, const ADDRINFOW*, ADDRINFOW**);
        void FreeAddrInfoW(ADDRINFOW*);
    }
} else version (Posix) {
    import core.sys.posix.sys.socket : sockaddr, AF_INET, AF_INET6;
    import core.sys.posix.netinet.in_ : sockaddr_in, sockaddr_in6;
    import core.sys.posix.netdb : getaddrinfo, freeaddrinfo, addrinfo;
} else
    static assert(0, "Not implemented");
