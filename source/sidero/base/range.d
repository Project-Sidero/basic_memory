module sidero.base.range;
import sidero.base.traits;

/// From std.range.primitives, License: Boost
template ElementType(R)
{
    static if (is(typeof(R.init.front.init) T))
        alias ElementType = T;
    else
        alias ElementType = void;
}
/// Ditto
enum bool isInputRange(R) =
is(typeof(R.init) == R)
&& is(typeof((R r) { return r.empty; } (R.init)) == bool)
&& (is(typeof((return ref R r) => r.front)) || is(typeof(ref (return ref R r) => r.front)))
&& !is(typeof((R r) { return r.front; } (R.init)) == void)
&& is(typeof((R r) => r.popFront));
/// Ditto
enum bool isForwardRange(R) = isInputRange!R
&& is(typeof((R r) { return r.save; } (R.init)) == R);
/// Ditto
enum bool isBidirectionalRange(R) = isForwardRange!R
&& is(typeof((R r) => r.popBack))
&& (is(typeof((return ref R r) => r.back)) || is(typeof(ref (return ref R r) => r.back)))
&& is(typeof(R.init.back.init) == ElementType!R);

/// Ditto
@property bool empty(T)(auto ref scope T a)
if (is(typeof(a.length) : size_t))
{
    return !a.length;
}

/// Ditto
@property inout(T)[] save(T)(return scope inout(T)[] a) @safe pure nothrow @nogc
{
    return a;
}

/// Ditto
void popFront(T)(scope ref inout(T)[] a) @safe pure nothrow @nogc
if (!isAutodecodableString!(T[]) && !is(T[] == void[]))
{
    assert(a.length, "Attempting to popFront() past the end of an array of " ~ T.stringof);
    a = a[1 .. $];
}

/// Ditto
void popFront(C)(scope ref inout(C)[] str) @trusted pure nothrow
if (isAutodecodableString!(C[]))
{
    import std.algorithm.comparison : min;

    assert(str.length, "Attempting to popFront() past the end of an array of " ~ C.stringof);

    static if (is(immutable C == immutable char))
    {
        static immutable ubyte[] charWidthTab = [
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
            4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1
        ];

        immutable c = str[0];
        immutable charWidth = c < 192 ? 1 : charWidthTab.ptr[c - 192];
        str = str.ptr[min(str.length, charWidth) .. str.length];
    }
    else static if (is(immutable C == immutable wchar))
    {
        immutable u = str[0];
        immutable seqLen = 1 + (u >= 0xD800 && u <= 0xDBFF);
        str = str.ptr[min(seqLen, str.length) .. str.length];
    }
    else static assert(0, "Bad template constraint.");
}
/// Ditto
void popBack(T)(scope ref inout(T)[] a) @safe pure nothrow @nogc
if (!isAutodecodableString!(T[]) && !is(T[] == void[]))
{
    assert(a.length);
    a = a[0 .. $ - 1];
}

/// Ditto
void popBack(T)(scope ref inout(T)[] a) @safe pure
if (isAutodecodableString!(T[]))
{
    import std.utf : strideBack;
    assert(a.length, "Attempting to popBack() past the front of an array of " ~ T.stringof);
    a = a[0 .. $ - strideBack(a, $)];
}

/// Ditto
@property ref inout(T) front(T)(return scope inout(T)[] a) @safe pure nothrow @nogc
if (!isAutodecodableString!(T[]) && !is(T[] == void[]))
{
    assert(a.length, "Attempting to fetch the front of an empty array of " ~ T.stringof);
    return a[0];
}

/// Ditto
@property dchar front(T)(scope const(T)[] a) @safe pure
if (isAutodecodableString!(T[]))
{
    import sidero.base.encoding.utf : decode;
    assert(a.length, "Attempting to fetch the front of an empty array of " ~ T.stringof);
    dchar ret;
    decode(a, ret);
    return ret;
}

/// Ditto
@property ref inout(T) back(T)(return scope inout(T)[] a) @safe pure nothrow @nogc
if (!isAutodecodableString!(T[]) && !is(T[] == void[]))
{
    assert(a.length, "Attempting to fetch the back of an empty array of " ~ T.stringof);
    return a[$ - 1];
}

/// Ditto
@property dchar back(T)(scope const(T)[] a) @safe pure
if (isAutodecodableString!(T[]))
{
    import std.utf : decode, strideBack;
    assert(a.length, "Attempting to fetch the back of an empty array of " ~ T.stringof);
    size_t i = a.length - strideBack(a, a.length);
    return decode(a, i);
}
