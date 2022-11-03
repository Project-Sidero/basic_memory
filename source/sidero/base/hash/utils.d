module sidero.base.hash.utils;

///
alias HashFunction(Type) = ulong function(scope ref Type) @safe nothrow @nogc;

///
ulong hashOf() @trusted nothrow @nogc {
    import sidero.base.hash.fnv;
    return fnv_64_1a(null);
}

///
ulong hashOf(Type)(scope ref Type value) @trusted nothrow @nogc {
    return hashOf(value, hashOf());
}

///
ulong hashOf(Type)(scope ref Type value, ulong previousHash) @trusted nothrow @nogc {
    import sidero.base.hash.fnv;

    ulong ret = previousHash;

    // probably not the best of algorith, but hey... it'll work (hopefully)
    void handle(Type2)(scope ref Type2 input) {
        static if (__traits(hasMember, Type2, "toHash")) {
            auto got = value.toHash();
            handle(got);
        } else {
            import std.traits : isArray, isBasicType;

            static if (isArray!Type2 && !isBasicType!(typeof(Type2.init[0]))) {
                foreach (ref v; input) {
                    handle(v);
                }
            } else {
                ubyte* ptr = cast(ubyte*)&value;
                ret = fnv_64_1a(ptr[0 .. Type.sizeof], ret);
            }
        }
    }

    handle(value);
    return ret;
}
