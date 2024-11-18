///
module sidero.base.traits;
import sidero.base.text;
public import std.traits;

export:

///
enum isAnyString(String) = isSomeString!String || isASCII!String || isUTFReadOnly!String || isUTFBuilder!String;

///
enum isReadOnlyString(String) = is(String == String_ASCII) || isUTFReadOnly!String;
///
enum isBuilderString(String) = is(String == StringBuilder_ASCII) || isUTFBuilder!String;

///
enum isASCII(String) = is(String == String_ASCII) || is(String == StringBuilder_ASCII);
///
enum isUTFReadOnly(String) = is(String == String_UTF8) || is(String == String_UTF16) || is(String == String_UTF32);
///
enum isUTFBuilder(String) = is(String == StringBuilder_UTF8) || is(String == StringBuilder_UTF16) || is(String == StringBuilder_UTF32);
///
enum isUTF(String) = isUTFReadOnly!String || isUTFBuilder!String;

///
enum isUTF8(String) = is(String : const(char)[]) || is(String == String_UTF8) || is(String == StringBuilder_UTF8);
///
enum isUTF16(String) = is(String : const(wchar)[]) || is(String == String_UTF16) || is(String == StringBuilder_UTF16);
///
enum isUTF32(String) = is(String : const(dchar)[]) || is(String == String_UTF32) || is(String == StringBuilder_UTF32);

///
enum isAnyPointer(Type) = (isPointer!Type && !(isFunctionPointer!Type || isDelegate!Type)) || isDynamicArray!Type ||
    isAssociativeArray!Type || is(Type == class);

///
enum HaveOpApply(InType, ArgType) = __traits(hasMember, InType, "opApply") && __traits(compiles, GetOpApply!(ArgType, InType));

// Looks for ref ArgType for opApply parameter
auto GetOpApply(ArgType, InType)(scope return ref InType input) @trusted nothrow @nogc {
    int handle(ref ArgType) @safe nothrow @nogc {
        return 0;
    }

    alias Overloads = __traits(getOverloads, input, "opApply");

    static foreach(i; 0 .. Overloads.length) {
        static if(__traits(compiles, Overloads[i](&handle))) {
            return &Overloads[i];
        }
    }

    assert(0);
}

///
enum HaveNonStaticOpApply(InType) = __traits(hasMember, InType, "opApply") && () {
    InType inType;
    alias Overloads = __traits(getOverloads, inType, "opApply");

    bool result;

    static foreach(i; 0 .. Overloads.length) {
        if(!__traits(isStaticFunction, Overloads[i])) {
            result = true;
        }
    }

    return result;
}();

/// Originally from `std.traits`. License: Boost
template isDesiredUDA(alias attribute) {
    template isDesiredUDA(alias toCheck) {
        static if(is(typeof(attribute)) && !__traits(isTemplate, attribute)) {
            static if(__traits(compiles, toCheck == attribute))
                enum isDesiredUDA = toCheck == attribute;
            else
                enum isDesiredUDA = false;
        } else static if(is(typeof(toCheck))) {
            static if(__traits(isTemplate, attribute))
                enum isDesiredUDA = isInstanceOf!(attribute, typeof(toCheck));
            else
                enum isDesiredUDA = is(typeof(toCheck) == attribute);
        } else static if(__traits(isTemplate, attribute))
            enum isDesiredUDA = isInstanceOf!(attribute, toCheck);
        else
            enum isDesiredUDA = is(toCheck == attribute);
    }
}

/// Originally from `std.traits`. License: Boost
template SetFunctionAttributes(T, string linkage, uint attrs) if (is(T == function)) {
    // To avoid a lot of syntactic headaches, we just use the above version to
    // operate on the corresponding function pointer type and then remove the
    // indirection again.
    alias SetFunctionAttributes = FunctionTypeOf!(SetFunctionAttributes!(T*, linkage, attrs));
}

/// Originally from `core.internal.traits`. License: Boost
template hasIndirections(T) {
    import std.meta : anySatisfy;

    static if(is(T == struct) || is(T == union))
        enum hasIndirections = anySatisfy!(.hasIndirections, typeof(T.tupleof));
    else static if(is(T == E[N], E, size_t N))
        enum hasIndirections = T.sizeof && is(E == void) ? true : hasIndirections!(BaseElemOf!E);
    else static if(isFunctionPointer!T)
        enum hasIndirections = false;
    else
        enum hasIndirections = isPointer!T || isDelegate!T || isDynamicArray!T || __traits(isAssociativeArray, T) ||
            is(T == class) || is(T == interface);
}

private:

template SetFunctionAttributes(T, string linkage, uint attrs) if (isFunctionPointer!T || isDelegate!T) {
    mixin({
        import sidero.base.algorithm : canFind;

        static assert(!(attrs & FunctionAttribute.trusted) || !(attrs & FunctionAttribute.safe),
            "Cannot have a function/delegate that is both trusted and safe.");

        static immutable linkages = ["D", "C", "Windows", "C++", "System"];
        static assert(canFind(linkages, linkage), "Invalid linkage '" ~ linkage ~ "', must be one of " ~ linkages.stringof ~ ".");

        string result = "alias ";

        static if(linkage != "D")
            result ~= "extern(" ~ linkage ~ ") ";

        static if(attrs & FunctionAttribute.ref_)
            result ~= "ref ";

        result ~= "ReturnType!T";

        static if(isDelegate!T)
            result ~= " delegate";
        else
            result ~= " function";

        result ~= "(";

        static if(Parameters!T.length > 0)
            result ~= "Parameters!T";

        enum varStyle = variadicFunctionStyle!T;
        static if(varStyle == Variadic.c)
            result ~= ", ...";
        else static if(varStyle == Variadic.d)
            result ~= "...";
        else static if(varStyle == Variadic.typesafe)
            result ~= "...";

        result ~= ")";

        static if(attrs & FunctionAttribute.pure_)
            result ~= " pure";
        static if(attrs & FunctionAttribute.nothrow_)
            result ~= " nothrow";
        static if(attrs & FunctionAttribute.property)
            result ~= " @property";
        static if(attrs & FunctionAttribute.trusted)
            result ~= " @trusted";
        static if(attrs & FunctionAttribute.safe)
            result ~= " @safe";
        static if(attrs & FunctionAttribute.nogc)
            result ~= " @nogc";
        static if(attrs & FunctionAttribute.system)
            result ~= " @system";
        static if(attrs & FunctionAttribute.const_)
            result ~= " const";
        static if(attrs & FunctionAttribute.immutable_)
            result ~= " immutable";
        static if(attrs & FunctionAttribute.inout_)
            result ~= " inout";
        static if(attrs & FunctionAttribute.shared_)
            result ~= " shared";
        static if(attrs & FunctionAttribute.return_)
            result ~= " return";
        static if(attrs & FunctionAttribute.live)
            result ~= " @live";

        result ~= " SetFunctionAttributes;";
        return result;
    }());
}
