module sidero.base.path.uri.abstraction;
import sidero.base.path.uri.errors;
import sidero.base.allocators;
import sidero.base.attributes;
import sidero.base.errors;
import sidero.base.text;
import sidero.base.containers.dynamicarray;
import sidero.base.typecons;

export @safe nothrow @nogc:

/*
network-path
//userinfo@host:port/path

absolute-path
/path

relative-path
./path
path
 */

///
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
    URIAddress dup(return scope RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull)
            return URIAddress.init;

        if (allocator.isNull)
            allocator = globalAllocator();

        URIAddressState* state = cast(URIAddressState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        URIAddress ret;
        ret.state = allocator.make!URIAddressState;

        *ret.state = *state;
        ret.state.allocator = allocator;
        ret.state.storage = state.storage.dup(allocator);
        return ret;
    }

    ///
    URIAddressRelativeTo relativeTo() scope const @trusted {
        if (isNull)
            return typeof(return).init;

        URIAddressState* state = cast(URIAddressState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.relativeTo;
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path?query#fragment").assumeOkay.relativeTo == URIAddressRelativeTo.Nothing);
        assert(URIAddress.from("//user:pass@host/path?query#fragment").assumeOkay.relativeTo == URIAddressRelativeTo.Network);
        assert(URIAddress.from("/path").assumeOkay.relativeTo == URIAddressRelativeTo.Absolute);
        assert(URIAddress.from("./path").assumeOkay.relativeTo == URIAddressRelativeTo.Path);
    }

    ///
    String_ASCII scheme() scope const @trusted {
        if (isNull || state.lengthOfScheme == 0)
            return String_ASCII.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage[state.offsetOfScheme .. state.offsetOfScheme + state.lengthOfScheme].asReadOnly();
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path?query#fragment").assumeOkay.scheme == "myscheme");
    }

    ///
    String_ASCII userInfo() scope const @trusted {
        if (isNull || state.lengthOfConnectionInfo == 0)
            return String_ASCII.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage[state.offsetOfConnectionInfo .. state.offsetOfConnectionInfo + state.lengthOfConnectionInfo].asReadOnly();
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path?query#fragment").assumeOkay.userInfo == "user:pass");
    }

    ///
    StringBuilder_UTF8 decodedUserInfo() scope const @trusted {
        import sidero.base.encoding.uri;

        if (isNull || state.lengthOfConnectionInfo == 0)
            return StringBuilder_UTF8.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfConnectionInfo .. state.offsetOfConnectionInfo + state.lengthOfConnectionInfo];
        auto ret = URIUserInfoEncoding.decode(sliced);

        if (ret)
            return ret.get;
        else
            return StringBuilder_UTF8.init;
    }

    ///
    String_ASCII host() scope const @trusted {
        if (isNull || state.lengthOfHost == 0)
            return String_ASCII.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage[state.offsetOfHost .. state.offsetOfHost + state.lengthOfHost].asReadOnly();
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path?query#fragment").assumeOkay.host == "host");
    }

    ///
    StringBuilder_UTF8 decodedHost() scope const @trusted {
        import sidero.base.encoding.bootstring;

        if (isNull || state.lengthOfHost == 0)
            return StringBuilder_UTF8.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfHost .. state.offsetOfHost + state.lengthOfHost];
        auto ret = IDNAPunycode.decode(sliced);

        if (ret)
            return ret.get.byUTF8;
        else
            return StringBuilder_UTF8.init;
    }

    ///
    Optional!ushort port() scope const @trusted {
        if (isNull || state.lengthOfPort == 0)
            return typeof(return).init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfPort() .. state.offsetOfPort() + state.lengthOfPort];

        ushort ret;
        if (!formattedRead(sliced, String_ASCII("{:d}"), ret))
            return typeof(return).init;
        return typeof(return)(ret);
    }

    ///
    @trusted unittest {
        auto got = URIAddress.from("myscheme://host:1234/path").assumeOkay.port;
        assert(!got.isNull);
        assert(got == 1234);

        got = URIAddress.from("myscheme://host:/path").assumeOkay.port;
        assert(got.isNull);
    }

    ///
    DynamicArray!String_ASCII segments(scope return RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull || state.lengthOfPath == 0)
            return typeof(return).init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfPath .. state.offsetOfPath + state.lengthOfPath].asReadOnly(allocator);

        DynamicArray!String_ASCII ret = DynamicArray!String_ASCII(0, allocator);
        ret.reserve(sliced.count("/") + 1);

        while (!sliced.empty) {
            ptrdiff_t index = sliced.indexOf("/");

            if (index < 0) {
                ret ~= sliced;
                sliced = String_ASCII.init;

            } else if (index == 0) {
                sliced = sliced[1 .. $];
            } else {
                ret ~= sliced[0 .. index];
                sliced = sliced[index + 1 .. $];
            }
        }

        return ret;
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path/goes/here?query#fragment")
                .assumeOkay.segments == [String_ASCII("path"), String_ASCII("goes"), String_ASCII("here")]);
    }

    ///
    DynamicArray!StringBuilder_UTF8 decodedSegments(scope return RCAllocator allocator = RCAllocator.init) scope const @trusted {
        import sidero.base.encoding.uri;

        if (isNull || state.lengthOfPath == 0)
            return typeof(return).init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfPath .. state.offsetOfPath + state.lengthOfPath].asReadOnly(allocator);

        StringBuilder_UTF8 buffer = StringBuilder_UTF8(allocator);

        DynamicArray!StringBuilder_UTF8 ret = DynamicArray!StringBuilder_UTF8(0, allocator);
        ret.reserve(sliced.count("/") + 1);

        while (!sliced.empty) {
            const oldLength = buffer.length;
            ptrdiff_t index = sliced.indexOf("/");

            if (index < 0) {
                cast(void)URIQueryFragmentEncoding.decode(buffer, sliced);
                sliced = String_ASCII.init;
                ret ~= buffer[oldLength .. $];
            } else if (index == 0) {
                sliced = sliced[1 .. $];
                continue;
            } else {
                cast(void)URIQueryFragmentEncoding.decode(buffer, sliced[0 .. index]);
                sliced = sliced[index + 1 .. $];
                ret ~= buffer[oldLength .. $];
            }
        }

        return ret;
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path/goes/here?query#fragment")
                .assumeOkay.decodedSegments == [
                    StringBuilder_UTF8("path"), StringBuilder_UTF8("goes"), StringBuilder_UTF8("here")
        ]);
    }

    ///
    DynamicArray!String_ASCII queries(scope return RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull || state.lengthOfQuery < 2)
            return typeof(return).init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfQuery .. state.offsetOfQuery + state.lengthOfQuery].asReadOnly(allocator);

        DynamicArray!String_ASCII ret = DynamicArray!String_ASCII(0, allocator);
        ret.reserve(sliced.count("&") + 1);

        while (!sliced.empty) {
            ptrdiff_t index = sliced.indexOf("&");

            if (index < 0) {
                ret ~= sliced;
                sliced = String_ASCII.init;
            } else if (index == 0) {
                sliced = sliced[1 .. $];
            } else {
                ret ~= sliced[0 .. index];
                sliced = sliced[index + 1 .. $];
            }
        }

        return ret;
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path/goes/here?query1=2&query4#fragment")
                .assumeOkay.queries == [String_ASCII("query1=2"), String_ASCII("query4")]);
    }

    ///
    DynamicArray!StringBuilder_UTF8 decodedQueries(scope return RCAllocator allocator = RCAllocator.init) scope const @trusted {
        import sidero.base.encoding.uri;

        if (isNull || state.lengthOfQuery == 0)
            return typeof(return).init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfQuery .. state.offsetOfQuery + state.lengthOfQuery].asReadOnly(allocator);

        StringBuilder_UTF8 buffer = StringBuilder_UTF8(allocator);

        DynamicArray!StringBuilder_UTF8 ret = DynamicArray!StringBuilder_UTF8(0, allocator);
        ret.reserve(sliced.count("&") + 1);

        while (!sliced.empty) {
            const oldLength = buffer.length;
            ptrdiff_t index = sliced.indexOf("&");

            if (index < 0) {
                cast(void)URIQueryFragmentEncoding.decode(buffer, sliced);
                sliced = String_ASCII.init;
                ret ~= buffer[oldLength .. $];
            } else if (index == 0) {
                sliced = sliced[1 .. $];
                continue;
            } else {
                cast(void)URIQueryFragmentEncoding.decode(buffer, sliced[0 .. index]);
                sliced = sliced[index + 1 .. $];
                ret ~= buffer[oldLength .. $];
            }
        }

        return ret;
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path/goes/here?query1=2&query4#fragment")
                .assumeOkay.decodedQueries == [StringBuilder_UTF8("query1=2"), StringBuilder_UTF8("query4")]);
    }

    ///
    String_ASCII fragment() scope const @trusted {
        if (isNull || state.lengthOfFragment == 0)
            return String_ASCII.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage[state.offsetOfFragment .. state.offsetOfFragment + state.lengthOfFragment].asReadOnly();
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("myscheme://user:pass@host/path?query#fragment").assumeOkay.fragment == "fragment");
    }

    ///
    StringBuilder_UTF8 decodedFragment() scope const @trusted {
        import sidero.base.encoding.uri;
        import sidero.base.encoding.bootstring;

        if (isNull || state.lengthOfFragment == 0)
            return StringBuilder_UTF8.init;

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        auto sliced = state.storage[state.offsetOfFragment .. state.offsetOfFragment + state.lengthOfFragment];
        auto ret = URIQueryFragmentEncoding.decode(sliced);

        if (ret)
            return ret.get;
        else
            return StringBuilder_UTF8.init;
    }

    ///
    bool isAbsolute() scope const {
        auto got = this.relativeTo;
        return !isNull && got == URIAddressRelativeTo.Nothing;
    }

    ///
    ErrorResult makeAbsolute(scope URIAddress contextAddress = URIAddress.init) scope {
        if (isNull)
            return ErrorResult(NullPointerException);
        else if (state is contextAddress.state)
            return ErrorResult(MalformedInputException("Context address is the same as the this instance"));

        URIAddressState* state = cast(URIAddressState*)this.state;
        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        // do this twice if we are anything other than another context which will resolve path relativeness after we handle the form
        foreach (_; 0 .. 2) {
            const allowedToTryAgain = state.relativeTo != URIAddressRelativeTo.AnotherContext;

            final switch (state.relativeTo) {
            case URIAddressRelativeTo.Nothing:
                return ErrorResult.init;

            case URIAddressRelativeTo.AnotherContext:
                // our path segments include parents, which means that the path is actually incomplete
                // so we need to take the path segments from context address, prepend them
                // if there is enough new path segments, the result will be an absolute path

                if (contextAddress.isNull)
                    return ErrorResult(MalformedInputException("Missing context path"));

                URIAddressState* cstate = cast(URIAddressState*)contextAddress.state;
                cstate.mutex.pureLock;
                scope (exit)
                    cstate.mutex.unlock;

                if (cstate.lengthOfPath == 0)
                    return ErrorResult(MalformedInputException(
                            "Need a path provided to make a another context relative address into a absolute one"));

                StringBuilder_ASCII sliced = cstate.storage[cstate.offsetOfPath() .. contextAddress.state.offsetOfPath() +
                    cstate.lengthOfPath];
                state.storage.insert(state.offsetOfPath(), sliced);
                state.lengthOfPath += sliced.length;
                break;
            case URIAddressRelativeTo.Network:
                if (contextAddress.isNull)
                    return ErrorResult(MalformedInputException("Missing context path"));

                URIAddressState* cstate = cast(URIAddressState*)contextAddress.state;
                cstate.mutex.pureLock;
                scope (exit)
                    cstate.mutex.unlock;

                if (cstate.lengthOfScheme == 0)
                    return ErrorResult(MalformedInputException("Context address must contain a scheme to make a network path absolute"));

                StringBuilder_ASCII sliced = cstate.storage[0 .. cstate.lengthOfScheme];
                state.storage.prepend(":"c);
                state.storage.prepend(sliced);
                state.lengthOfScheme = cstate.lengthOfScheme;
                state.lengthOfSchemeSuffix++;
                break;
            case URIAddressRelativeTo.Absolute:
                if (contextAddress.isNull)
                    return ErrorResult(MalformedInputException("Missing context path"));

                URIAddressState* cstate = cast(URIAddressState*)contextAddress.state;
                cstate.mutex.pureLock;
                scope (exit)
                    cstate.mutex.unlock;

                if (cstate.relativeTo != URIAddressRelativeTo.Nothing)
                    return ErrorResult(MalformedInputException(
                            "To make a relative absolute path absolute it requires an absolute path and context address is not."));

                StringBuilder_ASCII sliced = cstate.storage[0 .. cstate.offsetOfPath()];
                state.storage.prepend(sliced);

                state.lengthOfScheme = cstate.lengthOfScheme;
                state.lengthOfSchemeSuffix = cstate.lengthOfSchemeSuffix;
                state.lengthOfConnectionInfo = cstate.lengthOfConnectionInfo;
                state.lengthOfConnectionInfoSuffix = cstate.lengthOfConnectionInfoSuffix;
                state.lengthOfHost = cstate.lengthOfHost;
                state.lengthOfPort = cstate.lengthOfPort;
                state.lengthOfPortPrefix = cstate.lengthOfPortPrefix;
                break;
            case URIAddressRelativeTo.Path:
                if (contextAddress.isNull)
                    return ErrorResult(MalformedInputException("Missing context path"));

                URIAddressState* cstate = cast(URIAddressState*)contextAddress.state;
                cstate.mutex.pureLock;
                scope (exit)
                    cstate.mutex.unlock;

                if (cstate.relativeTo != URIAddressRelativeTo.Nothing)
                    return ErrorResult(MalformedInputException(
                            "To make a relative path absolute it requires an absolute path and context address is not."));

                state.storage.prepend("/"c);
                state.lengthOfPath++;

                StringBuilder_ASCII sliced = cstate.storage[0 .. cstate.offsetOfPath()];
                state.storage.prepend(sliced);

                state.lengthOfScheme = cstate.lengthOfScheme;
                state.lengthOfSchemeSuffix = cstate.lengthOfSchemeSuffix;
                state.lengthOfConnectionInfo = cstate.lengthOfConnectionInfo;
                state.lengthOfConnectionInfoSuffix = cstate.lengthOfConnectionInfoSuffix;
                state.lengthOfHost = cstate.lengthOfHost;
                state.lengthOfPort = cstate.lengthOfPort;
                state.lengthOfPortPrefix = cstate.lengthOfPortPrefix;
                break;
            }

            state.relativeTo = URIAddressRelativeTo.AnotherContext;
            this.evaluateRelativeComponents;

            if (!allowedToTryAgain)
                break;
        }

        if (state.relativeTo == URIAddressRelativeTo.AnotherContext) {
            // we failed to make absolute, error
            return ErrorResult(MalformedInputException("Not enough path segments in context address to resolve relative segments"));
        } else
            return ErrorResult.init;
    }

    /// Ditto
    Result!URIAddress asAbsolute(scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
        URIAddress ret = this.dup(allocator);
        auto error = ret.makeAbsolute(contextAddress);

        if (error)
            return typeof(return)(ret);
        else
            return typeof(return)(error.getError());
    }

    ///
    @trusted unittest {
        assert(URIAddress.from("scheme://host/path").assumeOkay.asAbsolute(URIAddress.from("scheme://host2:1234/path2")
                .assumeOkay).assumeOkay == String_ASCII("scheme://host/path"));
        assert(URIAddress.from("//host/path").assumeOkay.asAbsolute(URIAddress.from("scheme://host2:1234/path2")
                .assumeOkay).assumeOkay == String_ASCII("scheme://host/path"));
        assert(URIAddress.from("/path").assumeOkay.asAbsolute(URIAddress.from("scheme://host/path2").assumeOkay)
                .assumeOkay == String_ASCII("scheme://host/path"));
        assert(URIAddress.from("./path").assumeOkay.asAbsolute(URIAddress.from("scheme://host/path2").assumeOkay)
                .assumeOkay == String_ASCII("scheme://host/path"));
        assert(URIAddress.from("scheme://host/..").assumeOkay.asAbsolute(URIAddress.from("scheme://host2:1234/my/path/was")
                .assumeOkay).assumeOkay == String_ASCII("scheme://host/my/path"));
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
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_ASCII input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF8.LiteralType input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return URIAddress.from(String_UTF32(input), encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF16.LiteralType input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return URIAddress.from(String_UTF32(input), encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF32.LiteralType input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return URIAddress.from(String_UTF32(input), encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF8 input, bool encode = true, scope URIAddress contextAddress = URIAddress.init,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF16 input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope String_UTF32 input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_UTF8 input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_UTF16 input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input.byUTF32, encode, contextAddress, allocator);
        }

        /// Ditto
        Result!URIAddress from(scope StringBuilder_UTF32 input, bool encode = true,
                scope URIAddress contextAddress = URIAddress.init, scope return RCAllocator allocator = RCAllocator.init) {
            return parseURIFromString(input, encode, contextAddress, allocator);
        }

        ///
        @trusted unittest {
            assert(URIAddress.from("").assumeOkay.isNull);
            assert(URIAddress.from("scheme:").assumeOkay == String_ASCII("scheme:"));
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
            assert(URIAddress.from("scheme://host/path//another//").assumeOkay == String_ASCII("scheme://host/path/another"));
            assert(URIAddress.from("mailto:Joe@example.com").assumeOkay == String_ASCII("mailto:Joe@example.com"));
            assert(URIAddress.from("//userinfo@host:1234/path").assumeOkay == String_ASCII("//userinfo@host:1234/path"));
            assert(URIAddress.from("/path").assumeOkay == String_ASCII("/path"));
            assert(URIAddress.from("../path").assumeOkay == String_ASCII("../path"));
            assert(URIAddress.from("./path").assumeOkay == String_ASCII("./path"));
            assert(URIAddress.from("./..").assumeOkay == String_ASCII("./.."));
            assert(URIAddress.from("./path/../another").assumeOkay == String_ASCII("./another"));
            assert(URIAddress.from("./../..").assumeOkay == String_ASCII("./../.."));
            assert(URIAddress.from("host").assumeOkay == String_ASCII("host"));
        }
    }

private:
    ErrorInfo evaluateRelativeComponents() scope {
        StringBuilder_ASCII storage = state.storage.dup(state.allocator);
        StringBuilder_ASCII allComponents = storage[state.offsetOfPath() .. state.offsetOfPath() + state.lengthOfPath],
            components = allComponents.save;

        bool isFirst = true, haveUnresolvedParent;

        while (components.length > 0) {
            StringBuilder_ASCII component, fullComponent;
            const indexOfSeparator = components.indexOf("/");

            if (indexOfSeparator < 0) {
                component = components;
                fullComponent = component;
                components = StringBuilder_ASCII.init;
            } else {
                component = components[0 .. indexOfSeparator];
                fullComponent = components[0 .. indexOfSeparator + 1];
                components = components[indexOfSeparator + 1 .. $];
            }
            const lengthOfFullComponent = fullComponent.length;

            if (component == "..") {
                // we want to remove the prior component, but first we need to figure out where that is!
                StringBuilder_ASCII upUntilThis = allComponents[0 .. $ - (lengthOfFullComponent + components.length)];
                // it is in the form of path/../ or path/..

                if (upUntilThis.length == lengthOfFullComponent) {
                    // not legal if this is an absolute path, so swap it for AnotherContext
                    if (state.relativeTo == URIAddressRelativeTo.Nothing)
                        state.relativeTo = URIAddressRelativeTo.AnotherContext;
                    haveUnresolvedParent = true;
                } else if (upUntilThis.length > lengthOfFullComponent) {
                    ptrdiff_t lastSeparatorIndex = upUntilThis[0 .. $ - 1].lastIndexOf("/");

                    if (lastSeparatorIndex < 0) {
                        if (!upUntilThis.endsWith("./") && upUntilThis != "../") {
                            upUntilThis.remove(0, upUntilThis.length);
                        } else {
                            haveUnresolvedParent = true;
                        }
                    } else if (upUntilThis[lastSeparatorIndex + 1 .. $] != "../") {
                        allComponents[lastSeparatorIndex + 1 .. $ - components.length].remove(0, size_t.max);
                    } else {
                        haveUnresolvedParent = true;
                    }
                } else {
                    haveUnresolvedParent = true;
                }
            } else if (component == "." && !isFirst) {
                component.remove(-1, 1);
            }

            isFirst = false;
        }

        // Turn multiple back slahes into one
        allComponents.replace("//", "/");

        // remove a trailing slash
        if (allComponents != "./" && allComponents.endsWith("/")) {
            allComponents.remove(-1, 1);
        }

        if (!haveUnresolvedParent && state.relativeTo == URIAddressRelativeTo.AnotherContext)
            state.relativeTo = URIAddressRelativeTo.Nothing;
        else if (haveUnresolvedParent && state.relativeTo == URIAddressRelativeTo.Nothing)
            state.relativeTo = URIAddressRelativeTo.AnotherContext;

        state.lengthOfPath = allComponents.length;
        state.storage = storage;
        return ErrorInfo.init;
    }

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

///
enum URIAddressRelativeTo {
    ///
    Nothing,
    /// Have parent segments that need evaluation in a way we cannot without an absolute path
    AnotherContext,
    /// Starts with two /
    Network,
    /// Starts with a single /
    Absolute,
    /// Does not start with a /
    Path
}

private @hidden:
import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

struct URIAddressState {
    shared(ptrdiff_t) refCount = 1;
    RCAllocator allocator;
    TestTestSetLockInline mutex;

    StringBuilder_ASCII storage;

    URIAddressRelativeTo relativeTo;

    size_t lengthOfScheme, lengthOfSchemeSuffix;
    size_t lengthOfConnectionInfo, lengthOfConnectionInfoSuffix;
    size_t lengthOfHost;
    size_t lengthOfPort, lengthOfPortPrefix;
    size_t lengthOfPath;
    size_t lengthOfQuery, lengthOfQueryPrefix;
    size_t lengthOfFragment, lengthOfFragmentPrefix;

@safe nothrow @nogc:

    void opAssign(ref URIAddressState other) scope {
        static foreach (i; 4 .. this.tupleof.length) {
            this.tupleof[i] = other.tupleof[i];
        }
    }

    size_t offsetOfScheme() const {
        return 0;
    }

    size_t offsetOfConnectionInfo() const {
        return this.lengthOfScheme + this.lengthOfSchemeSuffix;
    }

    size_t offsetOfHost() const {
        return this.offsetOfConnectionInfo() + this.lengthOfConnectionInfo + this.lengthOfConnectionInfoSuffix;
    }

    size_t offsetOfPort() const {
        return this.offsetOfHost() + this.lengthOfHost + this.lengthOfPortPrefix;
    }

    size_t offsetOfPath() const {
        return this.offsetOfPort() + this.lengthOfPort;
    }

    size_t offsetOfQuery() const {
        return this.offsetOfPath() + this.lengthOfPath + this.lengthOfQueryPrefix;
    }

    size_t offsetOfFragment() const {
        return this.offsetOfQuery() + this.lengthOfQuery + this.lengthOfFragmentPrefix;
    }
}

// scheme :
// scheme ://

// (scheme ://) authority (/ path) (? query) (# fragment)
// (scheme :) (path)

Result!URIAddress parseURIFromString(Input)(scope Input input, bool encode, scope URIAddress contextAddress,
        scope return RCAllocator allocator) @trusted {
    import sidero.base.path.uri.length_calculation;
    import sidero.base.encoding.uri;
    import sidero.base.encoding.bootstring;

    if (allocator.isNull)
        allocator = globalAllocator();

    const lengthOfScheme = calculateLengthOfScheme(input);

    // [ :/ , user@ , host , :port ]
    auto lengthOfConnectionInfo = calculateLengthOfConnectionInfo(input, lengthOfScheme);

    // do not try to consume the hostname, if there is nothing to distringuish it from a relative path
    if (!contextAddress.isNull && lengthOfScheme == 0 && lengthOfConnectionInfo[0] == 0 && lengthOfConnectionInfo[1] == 0 &&
            lengthOfConnectionInfo[3] == 0)
        lengthOfConnectionInfo[2] = 0;

    const lengthOfSchemeOrConnectionInfo = lengthOfScheme + lengthOfConnectionInfo[0] + lengthOfConnectionInfo[1] +
        lengthOfConnectionInfo[2] + lengthOfConnectionInfo[3];

    // [ /segments , ?query ]
    const lengthOfQuery = calculateLengthOfQuery(input[lengthOfSchemeOrConnectionInfo .. $], lengthOfSchemeOrConnectionInfo > 0);

    // #fragment
    const lengthOfFragment = calculateLengthOfFragment(input[lengthOfScheme + lengthOfConnectionInfo[0] +
        lengthOfConnectionInfo[1] + lengthOfConnectionInfo[2] + lengthOfConnectionInfo[3] + lengthOfQuery[0] + lengthOfQuery[1] .. $]);

    if (lengthOfSchemeOrConnectionInfo == 0 && (lengthOfQuery[0] == 0 && lengthOfQuery[1] == 0 && lengthOfFragment == 0))
        return typeof(return).init;

    URIAddress ret;
    ret.state = allocator.make!URIAddressState;
    ret.state.allocator = allocator;
    ret.state.storage = StringBuilder_ASCII(allocator);

    {
        auto slice = input[];

        // scheme
        auto scheme = slice[0 .. lengthOfScheme];
        slice = slice[lengthOfScheme .. $];

        // ://
        auto schemeSuffix = slice[0 .. lengthOfConnectionInfo[0]];
        slice = slice[lengthOfConnectionInfo[0] .. $];

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

        if (lengthOfSchemeOrConnectionInfo == 0) {
            // some sort of relative path

            if (segments.startsWith("/")) {
                ret.state.relativeTo = URIAddressRelativeTo.Absolute;
            } else {
                ret.state.relativeTo = URIAddressRelativeTo.Path;
            }
        } else if (lengthOfScheme == 0 && lengthOfConnectionInfo[0] == 2 && schemeSuffix == "//"c) {
            // a relative path, network
            ret.state.relativeTo = URIAddressRelativeTo.Network;
        }

        {
            auto defaultScheme = contextAddress.scheme;
            bool needToAddSchemeSuffix;

            if ((lengthOfScheme + lengthOfConnectionInfo[0]) == 0 && defaultScheme.length > 0) {
                auto lowered = defaultScheme.toLower();

                ret.state.storage ~= lowered;
                needToAddSchemeSuffix = true;

            } else {
                auto lowered = scheme.asMutable.toLower;

                foreach (c; lowered) {
                    ret.state.storage ~= [cast(ubyte)c];
                }
            }

            ret.state.lengthOfScheme = ret.state.storage.length - previousLength;

            if (needToAddSchemeSuffix) {
                if (lengthOfConnectionInfo[2] > 0) {
                    // ://
                    ret.state.storage ~= "://";
                    lengthOfConnectionInfo[0] = 3;
                } else {
                    // :
                    ret.state.storage ~= ":";
                    lengthOfConnectionInfo[0] = 1;
                }

                ret.state.lengthOfSchemeSuffix = lengthOfConnectionInfo[0];
            } else if (lengthOfConnectionInfo[0] > 0) {
                foreach (c; schemeSuffix) {
                    ret.state.storage ~= [cast(ubyte)c];
                }
                ret.state.lengthOfSchemeSuffix = lengthOfConnectionInfo[0];
            }

            previousLength = ret.state.storage.length;
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

    {
        auto got = ret.evaluateRelativeComponents;
        if (got.isSet)
            return typeof(return)(got);
    }

    return typeof(return)(ret);
}
