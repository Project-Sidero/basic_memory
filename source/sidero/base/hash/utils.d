module sidero.base.hash.utils;
export @safe nothrow @nogc:

///
alias HashFunction(Type) = ulong function(scope ref Type);

///
ulong hashOf() @trusted {
    import sidero.base.hash.fnv;

    return fnv_64_1a(null);
}

///
ulong hashOf(Type)(scope ref Type value) @trusted {
    return hashOf(value, hashOf());
}

///
ulong hashOf(Type)(scope ref Type value, ulong previousHash) @trusted {
    import sidero.base.hash.fnv;

    ulong ret = previousHash;

    // probably not the best of algorith, but hey... it'll work (hopefully)
    void handle(Type2)(scope ref Type2 input) {
        static if(__traits(hasMember, Type2, "toHash")) {
            auto got = input.toHash();
            handle(got);
        } else {
            import std.traits : isArray, isBasicType;

            static if (isArray!Type2) {
                static if (isBasicType!(typeof(Type2.init[0]))) {
                    ret = fnv_64_1a(cast(ubyte[])input, ret);
                } else {
                    foreach (ref v; input) {
                        handle(v);
                    }
                }
            } else {
                static if (__traits(isIntegral, Type2)) {
                    ubyte[Type2.sizeof] buffer;
                    auto temp = cast()input;

                    static foreach(i; 0 .. Type2.sizeof) {
                        buffer[i] = temp & 0xFF;
                        static if (i + 1 < Type2.sizeof)
                            temp >>= 8;
                    }

                    ret = fnv_64_1a(buffer[], ret);
                } else {
                    ubyte* ptr = cast(ubyte*)&input;
                    scope array = ptr[0 .. Type2.sizeof];
                    ret = fnv_64_1a(array, ret);
                }
            }
        }
    }

    handle(value);
    return ret;
}
