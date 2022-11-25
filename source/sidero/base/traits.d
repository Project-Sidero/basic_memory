///
module sidero.base.traits;
import sidero.base.text;
public import std.traits;
export:

///
enum isAnyString(String) = isSomeString!String || is(String == String_ASCII) || is(String == String_UTF!Char, Char) ||
    is(String == StringBuilder_ASCII) || is(String == StringBuilder_UTF!Char, Char);

///
enum isReadOnlyString(String) = is(String == String_ASCII) || is(String == String_UTF!Char, Char);
///
enum isBuilderString(String) = is(String == StringBuilder_ASCII) || is(String == StringBuilder_UTF!Char, Char);

///
enum isASCII(String) = is(String == String_ASCII) || is(String == StringBuilder_ASCII);
///
enum isUTF(String) = is(String == String_UTF!Char, Char) || is(String == StringBuilder_UTF!Char, Char);

///
enum isAnyPointer(Type) = (isPointer!Type && !(isFunctionPointer!Type || isDelegate!Type)) || isDynamicArray!Type || isAssociativeArray!Type || is(Type == class);

enum HaveOpApply(InType, ArgType) = __traits(hasMember, InType, "opApply") && __traits(compiles, GetOpApply!(ArgType, InType));

// Looks for ref ArgType for opApply parameter
auto GetOpApply(ArgType, InType)(scope return ref InType input) @trusted nothrow @nogc {
    int handle(ref ArgType) @safe nothrow @nogc {
        return 0;
    }

    alias Overloads = __traits(getOverloads, input, "opApply");

    static foreach(i; 0 .. Overloads.length) {
        static if (__traits(compiles, Overloads[i](&handle))) {
            return &Overloads[i];
        }
    }

    assert(0);
}
