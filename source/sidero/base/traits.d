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
enum isAnyPointer(Type) = (isPointer!Type && !(isFunctionPointer!Type || isDelegate!Type)) || isDynamicArray!Type ||
    isAssociativeArray!Type || is(Type == class);

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

/// Originally from std.traits. License: Boost
enum fullyQualifiedName(T) = fqnType!(T, false, false, false, false);

/// Ditto
enum fullyQualifiedName(alias T) = fqnSym!(T);

/// originally from std.traits. License: Boost
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

private:

template fqnSym(alias T : X!A, alias X, A...) {
    template fqnTuple(T...) {
        static if(T.length == 0)
            enum fqnTuple = "";
        else static if(T.length == 1) {
            static if(isExpressionTuple!T)
                enum fqnTuple = T[0].stringof;
            else
                enum fqnTuple = fullyQualifiedName!(T[0]);
        } else
            enum fqnTuple = fqnTuple!(T[0]) ~ ", " ~ fqnTuple!(T[1 .. $]);
    }

    enum fqnSym = fqnSym!(__traits(parent, X)) ~ '.' ~ __traits(identifier, X) ~ "!(" ~ fqnTuple!A ~ ")";
}

template fqnSym(alias T) {
    static if(__traits(compiles, __traits(parent, T)) && !__traits(isSame, T, __traits(parent, T)))
        enum parentPrefix = fqnSym!(__traits(parent, T)) ~ ".";
    else
        enum parentPrefix = null;

    static string adjustIdent(string s) {
        import sidero.base.algorithm : skipOver, findSplit;

        if(s.skipOver("package ") || s.skipOver("module "))
            return s;
        return s.findSplit("(")[0];
    }

    enum fqnSym = parentPrefix ~ adjustIdent(__traits(identifier, T));
}

template fqnType(T, bool alreadyConst, bool alreadyImmutable, bool alreadyShared, bool alreadyInout) {
    import std.meta : AliasSeq;

    // Convenience tags
    enum {
        _const = 0,
        _immutable = 1,
        _shared = 2,
        _inout = 3
    }

    alias qualifiers = AliasSeq!(is(T == const), is(T == immutable), is(T == shared), is(T == inout));
    alias noQualifiers = AliasSeq!(false, false, false, false);

    string storageClassesString(uint psc)() @property {
        import std.conv : text;

        alias PSC = ParameterStorageClass;

        return text(psc & PSC.scope_ ? "scope " : "", psc & PSC.return_ ? "return " : "", psc & PSC.in_ ? "in " : "",
                psc & PSC.out_ ? "out " : "", psc & PSC.ref_ ? "ref " : "", psc & PSC.lazy_ ? "lazy " : "",);
    }

    string parametersTypeString(T)() @property {
        alias parameters = Parameters!(T);
        alias parameterStC = ParameterStorageClassTuple!(T);

        enum variadic = variadicFunctionStyle!T;
        static if(variadic == Variadic.no)
            enum variadicStr = "";
        else static if(variadic == Variadic.c)
            enum variadicStr = ", ...";
        else static if(variadic == Variadic.d)
            enum variadicStr = parameters.length ? ", ..." : "...";
        else static if(variadic == Variadic.typesafe)
            enum variadicStr = " ...";
        else
            static assert(0, "New variadic style has been added, please update fullyQualifiedName implementation");

        static if(parameters.length) {
            import std.algorithm.iteration : map;
            import std.array : join;
            import std.meta : staticMap;
            import std.range : zip;

            string result = join(map!(a => (a[0] ~ a[1]))(zip([staticMap!(storageClassesString, parameterStC)],
                    [staticMap!(fullyQualifiedName, parameters)])), ", ");

            return result ~= variadicStr;
        } else
            return variadicStr;
    }

    string linkageString(T)() @property {
        enum linkage = functionLinkage!T;

        if(linkage != "D")
            return "extern(" ~ linkage ~ ") ";
        else
            return "";
    }

    string functionAttributeString(T)() @property {
        alias FA = FunctionAttribute;
        enum attrs = functionAttributes!T;

        static if(attrs == FA.none)
            return "";
        else
            return (attrs & FA.pure_ ? " pure" : "") ~ (attrs & FA.nothrow_ ? " nothrow" : "") ~ (attrs & FA.ref_ ?
                    " ref" : "") ~ (attrs & FA.property ? " @property" : "") ~ (attrs & FA.trusted ?
                    " @trusted" : "") ~ (attrs & FA.safe ? " @safe" : "") ~ (attrs & FA.nogc ?
                    " @nogc" : "") ~ (attrs & FA.return_ ? " return" : "") ~ (attrs & FA.live ? " @live" : "");
    }

    string addQualifiers(string typeString, bool addConst, bool addImmutable, bool addShared, bool addInout) {
        auto result = typeString;
        if(addShared) {
            result = "shared(" ~ result ~ ")";
        }
        if(addConst || addImmutable || addInout) {
            result = (addConst ? "const" : addImmutable ? "immutable" : "inout") ~ "(" ~ result ~ ")";
        }
        return result;
    }

    // Convenience template to avoid copy-paste
    template chain(string current) {
        enum chain = addQualifiers(current, qualifiers[_const] && !alreadyConst, qualifiers[_immutable] &&
                    !alreadyImmutable, qualifiers[_shared] && !alreadyShared, qualifiers[_inout] && !alreadyInout);
    }

    static if(is(T == string)) {
        enum fqnType = "string";
    } else static if(is(T == wstring)) {
        enum fqnType = "wstring";
    } else static if(is(T == dstring)) {
        enum fqnType = "dstring";
    } else static if(is(T == typeof(null))) {
        enum fqnType = "typeof(null)";
    } else static if(isBasicType!T && !is(T == enum)) {
        enum fqnType = chain!((Unqual!T).stringof);
    } else static if(isAggregateType!T || is(T == enum)) {
        enum fqnType = chain!(fqnSym!T);
    } else static if(isStaticArray!T) {
        enum LengthText = () {
            size_t temp = T.length;
            string ret;

            while(temp > 0) {
                size_t next = temp / 10;

                char c = cast(char)((temp - (next * 10)) + '0');
                ret = "" ~ c ~ ret;

                temp = next;
            }

            return ret;
        }();
        enum fqnType = chain!(fqnType!(typeof(T.init[0]), qualifiers) ~ "[" ~ LengthText ~ "]");
    } else static if(isArray!T) {
        enum fqnType = chain!(fqnType!(typeof(T.init[0]), qualifiers) ~ "[]");
    } else static if(isAssociativeArray!T) {
        enum fqnType = chain!(fqnType!(ValueType!T, qualifiers) ~ '[' ~ fqnType!(KeyType!T, noQualifiers) ~ ']');
    } else static if(isSomeFunction!T) {
        static if(is(T F == delegate)) {
            enum qualifierString = (is(F == shared) ? " shared" : "") ~ (is(F == inout) ? " inout" :  is(F == immutable) ?
                        " immutable" :  is(F == const) ? " const" : "");
            enum fqnType = chain!(linkageString!T ~ fqnType!(ReturnType!T,
                        noQualifiers) ~ " delegate(" ~ parametersTypeString!(T) ~ ")" ~ functionAttributeString!T ~ qualifierString);
        } else {
            enum fqnType = chain!(linkageString!T ~ fqnType!(ReturnType!T, noQualifiers) ~ (isFunctionPointer!T ?
                        " function(" : "(") ~ parametersTypeString!(T) ~ ")" ~ functionAttributeString!T);
        }
    } else static if(isPointer!T) {
        enum fqnType = chain!(fqnType!(PointerTarget!T, qualifiers) ~ "*");
    } else static if(is(T : __vector(V[N]), V, size_t N)) {
        import std.conv : to;

        enum fqnType = chain!("__vector(" ~ fqnType!(V, qualifiers) ~ "[" ~ N.to!string ~ "])");
    } else // In case something is forgotten
        static assert(0, "Unrecognized type " ~ T.stringof ~ ", can't convert to fully qualified string");
}
