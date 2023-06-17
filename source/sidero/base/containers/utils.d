module sidero.base.containers.utils;

export @safe nothrow @nogc:

///
int genericCompare(Type)(scope Type first, scope Type second) @trusted {
    import std.traits : isArray, Unqual;

    enum isSlice = isArray!Type;
    enum CanCompareDirectly = __traits(compiles, { bool got = first < second; });
    enum HaveOpCmp = __traits(compiles, { int got = first.opCmp(second); });

    static if (HaveOpCmp) {
        return first.opCmp(second);
    } else static if (!isSlice && CanCompareDirectly) {
        if (first < second)
            return -1;
        else if (first > second)
            return 1;
        else
            return 0;
    } else static if (isSlice) {
        if (first.length < second.length)
            return -1;
        else if (first.length > second.length)
            return 1;
        else {
            static if (is(Unqual!Type == void[])) {
                foreach (offset, ref v1; cast(ubyte[])first) {
                    int got = genericCompare(v1, (cast(ubyte[])second)[offset]);
                    if (got != 0)
                        return got;
                }
            } else {
                foreach (offset, ref v1; first) {
                    int got = genericCompare(cast()v1, cast()second[offset]);
                    if (got != 0)
                        return got;
                }
            }

            return 0;
        }
    } else static if (is(Type == struct)) {
        int got;

        static foreach (offset; 0 .. first.tupleof.length) {
            got = genericCompare(first.tupleof[offset], second.tupleof[offset]);
            if (got != 0)
                return got;
        }

        return got;
    } else
        static assert(0, "Not Comparable " ~ Type.stringof);
}
