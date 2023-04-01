module sidero.base.algorithm;
import std.range : isInputRange, isBidirectionalRange, isForwardRange;
import sidero.base.traits;

export @safe nothrow @nogc:

///
bool startsWith(Input1, Input2)(scope Input1 input1, scope Input2 input2)
        if ((isInputRange!Input1 || isDynamicArray!Input1) && (isInputRange!Input2 || isDynamicArray!Input2)) {
    for (;;) {
        static if (isDynamicArray!Input1) {
            if (input1.length == 0)
                return false;

            auto value1 = input1[0];
        } else {
            if (input1.empty)
                return false;

            auto value1 = input1.front;
        }

        static if (isDynamicArray!Input2) {
            if (input2.length == 0)
                return true;

            auto value2 = input2[0];
        } else {
            if (input2.empty)
                return true;

            auto value2 = input2.front;
        }

        if (value1 != value2)
            return false;

        static if (isDynamicArray!Input1) {
            input1 = input1[1 .. $];
        } else {
            input1.popFront;
        }

        static if (isDynamicArray!Input2) {
            input2 = input2[1 .. $];
        } else {
            input2.popFront;
        }
    }
}

///
unittest {
    static Input1 = "hello world", Input2 = "hello";
    assert(Input1.startsWith(Input2));
}

///
bool endsWith(Input1, Input2)(scope Input1 input1, scope Input2 input2)
        if ((isBidirectionalRange!Input1 || isDynamicArray!Input1) && (isBidirectionalRange!Input2 || isDynamicArray!Input2)) {
    for (;;) {
        static if (isDynamicArray!Input1) {
            if (input1.length == 0)
                return false;

            auto value1 = input1[$ - 1];
        } else {
            if (input1.empty)
                return false;

            auto value1 = input1.back;
        }

        static if (isDynamicArray!Input2) {
            if (input2.length == 0)
                return true;

            auto value2 = input2[$ - 1];
        } else {
            if (input2.empty)
                return true;

            auto value2 = input2.back;
        }

        if (value1 != value2)
            return false;

        static if (isDynamicArray!Input1) {
            input1 = input1[0 .. $ - 1];
        } else {
            input1.popBack;
        }

        static if (isDynamicArray!Input2) {
            input2 = input2[0 .. $ - 1];
        } else {
            input2.popBack;
        }
    }
}

///
unittest {
    static Input1 = "hello world", Input2 = "world";
    assert(Input1.endsWith(Input2));
}

///
bool skipOver(Input1, Input2)(scope ref Input1 input1, scope Input2 input2)
        if ((isInputRange!Input1 || isDynamicArray!Input1) && (isInputRange!Input2 || isDynamicArray!Input2)) {
    if (input1.startsWith(input1)) {
        static if (isDynamicArray!Input1) {
            size_t count;

            foreach (_; input2)
                count++;

            input1 = input1[count .. $];
        } else {
            foreach (_; input2)
                input1.popFront;
        }

        return true;
    } else
        return false;
}

/// See std.algorithm.searching, heavily modified. License: Boost.
InputRange find(alias pred = "a == b", InputRange, Element)(InputRange haystack, scope Element needle)
        if ((isInputRange!InputRange || isDynamicArray!InputRange)) {
    import std.functional : unaryFun, binaryFun;
    import std.range : ElementType, ElementEncodingType;

    alias R = InputRange;
    alias E = Element;
    alias predFun = binaryFun!pred;
    static if (is(typeof(pred == "a == b")))
        enum isDefaultPred = pred == "a == b";
    else
        enum isDefaultPred = false;
    enum isIntegralNeedle = isSomeChar!E || isIntegral!E || isBoolean!E;

    alias EType = ElementType!R;

    // If the haystack is a SortedRange we can use binary search to find the needle.
    // Works only for the default find predicate and any SortedRange predicate.
    // https://issues.dlang.org/show_bug.cgi?id=8829
    import std.range : SortedRange;

    static if (is(InputRange : SortedRange!TT, TT) && isDefaultPred) {
        auto lb = haystack.lowerBound(needle);
        if (lb.length == haystack.length || haystack[lb.length] != needle)
            return haystack[$ .. $];

        return haystack[lb.length .. $];
    } else static if (isNarrowString!R) {
        alias EEType = ElementEncodingType!R;
        alias UEEType = Unqual!EEType;

        //These are two special cases which can search without decoding the UTF stream.
        static if (isDefaultPred && isIntegralNeedle) {
            import std.utf : canSearchInCodeUnits;

            //This special case deals with UTF8 search, when the needle
            //is represented by a single code point.
            //Note: "needle <= 0x7F" properly handles sign via unsigned promotion
            static if (is(UEEType == char)) {
                if (!__ctfe && canSearchInCodeUnits!char(needle)) {
                    static inout(R) trustedMemchr(ref return scope inout(R) haystack, ref const scope E needle) @trusted nothrow pure {
                        import core.stdc.string : memchr;

                        auto ptr = memchr(haystack.ptr, needle, haystack.length);
                        return ptr ? haystack[cast(char*)ptr - haystack.ptr .. $] : haystack[$ .. $];
                    }

                    return trustedMemchr(haystack, needle);
                }
            }

            //Ditto, but for UTF16
            static if (is(UEEType == wchar)) {
                if (canSearchInCodeUnits!wchar(needle)) {
                    foreach (i, ref EEType e; haystack) {
                        if (e == needle)
                            return haystack[i .. $];
                    }
                    return haystack[$ .. $];
                }
            }
        }

        //Default implementation.
        foreach (i, ref e; haystack)
            if (haystack[i .. $].startsWith(needle))
                return haystack[i .. $];
        return haystack[$ .. $];
    } else static if (isArray!R) {
        // https://issues.dlang.org/show_bug.cgi?id=10403 optimization
        static if (isDefaultPred && isIntegral!EType && EType.sizeof == 1 && isIntegralNeedle) {
            import std.algorithm.comparison : max, min;

            R findHelper(return scope ref R haystack, ref E needle) @trusted nothrow pure {
                import core.stdc.string : memchr;

                EType* ptr = null;
                //Note: we use "min/max" to handle sign mismatch.
                if (min(EType.min, needle) == EType.min && max(EType.max, needle) == EType.max) {
                    ptr = cast(EType*)memchr(haystack.ptr, needle, haystack.length);
                }

                return ptr ? haystack[ptr - haystack.ptr .. $] : haystack[$ .. $];
            }

            if (!__ctfe)
                return findHelper(haystack, needle);
        }

        //Default implementation.
        foreach (i, ref e; haystack)
            if (predFun(e, needle))
                return haystack[i .. $];
        return haystack[$ .. $];
    } else {
        //Everything else. Walk.
        for (; !haystack.empty; haystack.popFront()) {
            if (predFun(haystack.front, needle))
                break;
        }
        return haystack;
    }
}

/// See std.algorithm.searching, heavily modified. License: Boost.
auto findSplit(alias pred = "a == b", R1, R2)(R1 haystack, R2 needle)
        if ((isInputRange!R1 || isDynamicArray!R1) && (isInputRange!R2 || isDynamicArray!R2)) {
    static struct Values(Args...) {
        Args args;
        alias args this;
    }

    static struct Result(S1, S2) if ((isForwardRange!S1 || isDynamicArray!S1) && (isForwardRange!S2 || isDynamicArray!S2)) {
        this(S1 pre, S1 separator, S2 post) {
            asTuple = typeof(asTuple)(pre, separator, post);
        }

        void opAssign(typeof(asTuple) rhs) {
            asTuple = rhs;
        }

        Values!(S1, S1, S2) asTuple;
        static if (hasConstEmptyMember!(typeof(asTuple[1]))) {
            bool opCast(T : bool)() const {
                return !asTuple[1].empty;
            }
        } else {
            bool opCast(T : bool)() {
                return !asTuple[1].empty;
            }
        }
        alias asTuple this;
    }

    static if (isSomeString!R1 && isSomeString!R2 || (isRandomAccessRange!R1 && hasSlicing!R1 && hasLength!R1 && hasLength!R2)) {
        auto balance = find!pred(haystack, needle);
        immutable pos1 = haystack.length - balance.length;

        static if (isDynamicArray!(typeof(balance))) {
            immutable pos2 = balance.length == 0 ? pos1 : pos1 + needle.length;
        } else {
            immutable pos2 = balance.empty ? pos1 : pos1 + needle.length;
        }

        return Result!(typeof(haystack[0 .. pos1]), typeof(haystack[pos2 .. haystack.length]))(haystack[0 .. pos1],
                haystack[pos1 .. pos2], haystack[pos2 .. haystack.length]);
    } else {
        import std.range : takeExactly;

        auto original = haystack.save;
        auto h = haystack.save;
        auto n = needle.save;
        size_t pos1, pos2;
        while (!n.empty && !h.empty) {
            if (binaryFun!pred(h.front, n.front)) {
                h.popFront();
                n.popFront();
                ++pos2;
            } else {
                haystack.popFront();
                n = needle.save;
                h = haystack.save;
                pos2 = ++pos1;
            }
        }
        if (!n.empty) // incomplete match at the end of haystack
        {
            pos1 = pos2;
        }
        return Result!(typeof(takeExactly(original, pos1)), typeof(h))(takeExactly(original, pos1), takeExactly(haystack, pos2 - pos1), h);
    }
}

private:
// From std.algorithm.searching. License: Boost
enum bool hasConstEmptyMember(T) = is(typeof(((const T* a) => (*a).empty)(null)) : bool);
