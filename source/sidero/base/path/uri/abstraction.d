module sidero.base.path.uri.abstraction;
import sidero.base.path.uri.errors;
import sidero.base.allocators;
import sidero.base.attributes;
import sidero.base.errors;
import sidero.base.text;

export @safe nothrow @nogc:

struct URIAddress {
    private {
        URIAddressState* state;
    }

export @safe nothrow @nogc:

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    bool opEquals(scope String_ASCII other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope StringBuilder_ASCII other) scope const {
        return this.toString().equals(other);
    }

    ///
    bool opEquals(scope URIAddress other) scope const {
        return this.toString() == other.toString();
    }

    ///
    int opCmp(scope String_ASCII other) scope const {
        return cmpImpl(other);
    }

    ///
    int opCmp(scope StringBuilder_ASCII other) scope const {
        return cmpImpl(other);
    }

    ///
    int opCmp(scope URIAddress other) scope const {
        return this.toString() == other.toString();
    }

    ///
    String_ASCII toString(return scope RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull)
            return String_ASCII.init;

        URIAddressState* state = cast(URIAddressState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage.asReadOnly(allocator);
    }

    static {
        /// Consturct a file path given a platform rule set (default is host platform)
        Result!URIAddress from(scope String_ASCII input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_ASCII input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF8.LiteralType input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return URIAddress.from(String_UTF32(input), encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF16.LiteralType input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return URIAddress.from(String_UTF32(input), encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF32.LiteralType input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return URIAddress.from(String_UTF32(input), encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF8 input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF16 input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF32 input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_UTF8 input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_UTF16 input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, defaultScheme, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_UTF32 input, bool encode = true,
                scope String_ASCII defaultScheme = String_ASCII.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, defaultScheme, allocator);
        }

        ///
        @trusted unittest {
            assert(URIAddress.from("scheme://@host:1234/path/segments").assumeOkay == String_ASCII("scheme://host:1234/path/segments"));
            assert(URIAddress.from("scheme://user:@host:1234/path/segments")
                    .assumeOkay == String_ASCII("scheme://user:@host:1234/path/segments"));
            assert(URIAddress.from("scheme://user:pass@host:1234?query=args/path/segments")
                    .assumeOkay == String_ASCII("scheme://user:pass@host:1234?query=args/path/segments"));
            assert(URIAddress.from("scheme://@host:#").assumeOkay == String_ASCII("scheme://host"));
            assert(URIAddress.from("SCHEME://HOST:").assumeOkay == String_ASCII("scheme://host"));
            assert(URIAddress.from("scheme://@host").assumeOkay == String_ASCII("scheme://host"));
            assert(URIAddress.from("scheme://host#").assumeOkay == String_ASCII("scheme://host"));
            assert(URIAddress.from("scheme://ho%aast#").assumeOkay == String_ASCII("scheme://ho%AAst"));
            assert(URIAddress.from("scheme://host/path//another//").assumeOkay == String_ASCII("scheme://host/path/another/"));
            assert(URIAddress.from("mailto:Joe@example.com").assumeOkay == String_ASCII("mailto:Joe@example.com"));
        }
    }

private @hidden:
    int cmpImpl(Input)(scope Input other) scope const @trusted {
        if (isNull)
            return other.isNull ? 0 : -1;
        else if (other.isNull)
            return 1;

        URIAddressState* state = cast(URIAddressState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage.compare(other);
    }
}

private @hidden:
import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

struct URIAddressState {
    shared(ptrdiff_t) refCount = 1;
    RCAllocator allocator;
    TestTestSetLockInline mutex;

    StringBuilder_ASCII storage;

    size_t lengthOfScheme, lengthOfSchemeSuffix;
    size_t lengthOfConnectionInfo, lengthOfConnectionInfoSuffix;
    size_t lengthOfHost;
    size_t lengthOfPort, lengthOfPortPrefix;
    size_t lengthOfPath;
    size_t lengthOfQuery, lengthOfQueryPrefix;
    size_t lengthOfFragment, lengthOfFragmentPrefix;
}

// scheme :
// scheme ://

// (scheme ://) authority (/ path) (? query) (# fragment)
// (scheme :) (path)

Result!URIAddress parseURIFromString(Input)(scope Input input, bool encode, scope String_ASCII defaultScheme,
        scope return RCAllocator allocator) @trusted {
    import sidero.base.path.uri.length_calculation;
    import sidero.base.encoding.uri;
    import sidero.base.encoding.bootstring;

    if (allocator.isNull)
        allocator = globalAllocator();

    const lengthOfScheme = calculateLengthOfScheme(input);

    // [ :/ , user@ , host , :port ]
    auto lengthOfConnectionInfo = calculateLengthOfConnectionInfo(input, lengthOfScheme);

    if (lengthOfConnectionInfo[2] == 0) {
        // we cannot represent a URI if we don't have a host
        return typeof(return)(MalformedInputException("A URI requires a host"));
    }

    // [ /segments , ?query ]
    const lengthOfQuery = calculateLengthOfQuery(input[lengthOfScheme + lengthOfConnectionInfo[0] +
        lengthOfConnectionInfo[1] + lengthOfConnectionInfo[2] + lengthOfConnectionInfo[3] .. $]);
    // #fragment
    const lengthOfFragment = calculateLengthOfFragment(input[lengthOfScheme + lengthOfConnectionInfo[0] +
        lengthOfConnectionInfo[1] + lengthOfConnectionInfo[2] + lengthOfConnectionInfo[3] + lengthOfQuery[0] + lengthOfQuery[1] .. $]);

    URIAddress ret;
    ret.state = allocator.make!URIAddressState;
    ret.state.allocator = allocator;
    ret.state.storage = StringBuilder_ASCII(allocator);

    {
        auto slice = input[];

        // scheme://
        auto scheme = slice[0 .. lengthOfScheme + lengthOfConnectionInfo[0]];
        slice = slice[lengthOfScheme + lengthOfConnectionInfo[0] .. $];

        auto connectionInfo = slice[0 .. lengthOfConnectionInfo[1]];
        slice = slice[lengthOfConnectionInfo[1] .. $];

        auto host = slice[0 .. lengthOfConnectionInfo[2]];
        slice = slice[lengthOfConnectionInfo[2] .. $];

        auto port = slice[0 .. lengthOfConnectionInfo[3]];
        slice = slice[lengthOfConnectionInfo[3] .. $];

        auto segments = slice[0 .. lengthOfQuery[0]];
        slice = slice[lengthOfQuery[0] .. $];

        auto query = slice[0 .. lengthOfQuery[1]];
        slice = slice[lengthOfQuery[1] .. $];

        auto fragment = slice[0 .. lengthOfFragment];

        size_t previousLength;

        {
            if (lengthOfScheme == 0 && defaultScheme.length > 0) {
                auto lowered = defaultScheme.toLower();

                ret.state.storage ~= lowered;

                if (lengthOfConnectionInfo[2] > 0) {
                    // ://
                    ret.state.storage ~= "://";
                    lengthOfConnectionInfo[0] = 3;
                } else {
                    // :
                    ret.state.storage ~= ":";
                    lengthOfConnectionInfo[0] = 1;
                }
            } else {
                auto lowered = scheme.asMutable.toLower;

                foreach (c; lowered) {
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.lengthOfScheme = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;

            if (ret.state.lengthOfScheme > 0) {
                assert(ret.state.lengthOfScheme > lengthOfConnectionInfo[0]);
                ret.state.lengthOfScheme -= lengthOfConnectionInfo[0];
                ret.state.lengthOfSchemeSuffix = lengthOfConnectionInfo[0];
            }
        }

        if (lengthOfConnectionInfo[1] > 1) {
            if (encode) {
                URIUserInfoEncoding.encode(ret.state.storage, connectionInfo[0 .. $ - 1]);
            } else {
                foreach (c; connectionInfo[0 .. $ - 1]) {
                    if (URIUserInfoEncoding.needsEncoding(c))
                        return typeof(return)(MalformedInputException("URI connection info needs encoding"));
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.storage ~= "@";

            ret.state.lengthOfConnectionInfo = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;

            // @
            assert(ret.state.lengthOfConnectionInfo > 0);
            ret.state.lengthOfConnectionInfo--;
            ret.state.lengthOfConnectionInfoSuffix = 1;
        }

        {
            auto lowered = host.asMutable.toLower;

            if (encode) {
                auto error = IDNAPunycode.encode(ret.state.storage, lowered);
                if (!error)
                    return typeof(return)(error.getError());
            } else {
                foreach (c; lowered) {
                    if (IDNAPunycode.needsEncoding(c))
                        return typeof(return)(MalformedInputException("URI host needs encoding"));
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.lengthOfHost = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;
        }

        if (lengthOfConnectionInfo[3] > 1) {
            foreach (c; port) {
                ret.state.storage ~= [cast(ubyte)c];
            }

            ret.state.lengthOfPort = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;

            // :
            ret.state.lengthOfPort--;
            ret.state.lengthOfPortPrefix = 1;
        }

        {
            auto deduped = segments.asMutable;
            deduped.replace("//", "/");

            if (encode) {
                URIQueryFragmentEncoding.encode(ret.state.storage, deduped);
            } else {
                foreach (c; deduped) {
                    if (URIQueryFragmentEncoding.needsEncoding(c))
                        return typeof(return)(MalformedInputException("URI path segments needs encoding"));
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.lengthOfPath = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;
        }

        if (lengthOfQuery[1] > 0) {
            if (encode) {
                URIQueryFragmentEncoding.encode(ret.state.storage, query);
            } else {
                foreach (c; query) {
                    if (URIQueryFragmentEncoding.needsEncoding(c))
                        return typeof(return)(MalformedInputException("URI query needs encoding"));
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.lengthOfQuery = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;

            // ?
            ret.state.lengthOfQuery--;
            ret.state.lengthOfQueryPrefix = 1;
        }

        if (lengthOfFragment > 1) {
            ret.state.storage ~= "#";

            if (encode) {
                URIQueryFragmentEncoding.encode(ret.state.storage, fragment[1 .. $]);
            } else {
                foreach (c; fragment[1 .. $]) {
                    if (URIQueryFragmentEncoding.needsEncoding(c))
                        return typeof(return)(MalformedInputException("URI fragment needs encoding"));
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.lengthOfFragment = ret.state.storage.length - previousLength;
            previousLength = ret.state.storage.length;

            // #
            ret.state.lengthOfFragment--;
            ret.state.lengthOfFragmentPrefix = 1;
        }
    }

    return typeof(return)(ret);
}
