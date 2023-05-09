module sidero.base.containers.utils;

export @safe nothrow @nogc:

///
int genericCompare(Type)(scope Type first, scope Type second) @trusted {
    import std.traits : isArray;

    enum isSlice = isArray!Type;
    enum CanCompareDirectly = __traits(compiles, { bool got = Type.init < Type.init; });
    enum HaveOpCmp = __traits(compiles, { int got = Type.init.opCmp(Type.init); });

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
            foreach (offset, ref v1; first) {
                int got = genericCompare(cast()v1, cast()second[offset]);
                if (got != 0)
                    return got;
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
