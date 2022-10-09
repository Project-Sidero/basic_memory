///
module sidero.base.text.format;
import sidero.base.text.ascii.readonly;
import sidero.base.text.ascii.builder;
import sidero.base.text.unicode.readonly;
import sidero.base.text.unicode.builder;

/// UDA for formatting
struct PrintIgnore {
}
/// UDA for pretty formatting
struct PrettyPrintIgnore {
}

///
StringBuilder_UTF8 format(Format, Args...)(scope Format format, scope Args args) {
    StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());
    builder.formattedWrite(format, args);
    return builder;
}

///
unittest {
    assert(format("hello %s", "world!").length == "hello world!".length);
}

///
StringBuilder_UTF8 format(alias Format, Args...)(scope Args args) {
    StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());
    builder.formattedWrite!Format(args);
    return builder;
}

///
unittest {
    assert(format!"hello %s"("world!").length == "hello world!".length);
}

///
void formattedWrite(alias Format, Builder, Args...)(scope Builder builder, scope Args args)
        if (isBuilderString!Builder && isSomeString!(typeof(Format))) {
    static assert(CheckParameters!(Format, Args));
    formattedWrite(builder, Format, args);
}

///
void formattedWrite(Builder, Format, Args...)(scope Builder builder, scope Format format, scope Args args)
        if (isBuilderString!Builder && (isReadOnlyString!Format || isSomeString!Format)) {
    import std.algorithm : startsWith;

    auto rfs = RetrieveFormatSpecifier!Format(format);
    auto fv = FormatValue!Builder(builder);

    size_t offset;

    foreach (rfs.ForeachType spec; rfs) {
        if (!spec.startsWith("%")) {
            builder ~= spec;
        } else {
        Switch:
            switch (offset++) {
                static foreach (i; 0 .. Args.length) {
            case i:
                    fv(spec, args[i]);
                    break Switch;
                }

            default:
                assert(0, "Not enough arguments given format specifiers");
            }
        }
    }

    static foreach (i; 0 .. Args.length) {
        if (offset < i)
            fv(String_ASCII(""), args[i]);
    }
}

private:
import sidero.base.allocators;
import std.traits;

enum isReadOnlyString(String) = is(String == String_ASCII) || is(String == String_UTF!Char, Char);
enum isBuilderString(String) = is(String == StringBuilder_ASCII) || is(String == StringBuilder_UTF!Char, Char);
enum isASCII(String) = is(String == String_ASCII) || is(String == StringBuilder_ASCII);
enum isUTF(String) = is(String == String_UTF!Char, Char) || is(String == StringBuilder_UTF!Char, Char);

struct FormatValue(Builder) if (isBuilderString!Builder) {
    Builder builder;
    RCAllocator allocator;
    char[64] stackBuffer;
    char[] actualBuffer;

    enum haveToString(T) = __traits(hasMember, T, "toString") && (__traits(compiles, {
                Builder builder;
                T value;
                value.toString(builder);
            }) || __traits(compiles, { Builder builder; T value; builder ~= value.toString(); }) || __traits(compiles, {
                Builder builder;
                T value;
                value.toString(&builder.put);
            }));

scope:

    this(scope Builder builder) @trusted {
        this.builder = builder;

        actualBuffer = stackBuffer[];
        allocator = globalAllocator();
    }

    @disable this(this);

    ~this() {
        if (actualBuffer.length > stackBuffer.length) {
            allocator.dispose(actualBuffer);
        }
    }

    alias opCall = write;

    void write(Format, Input)(scope Format format, scope Input input, bool needQuotes = false) @trusted
            if (isReadOnlyString!Format) {

        static if (is(Builder == StringBuilder_ASCII) && isUTF!Format) {
            static assert(0, "You cannot use an ASCII string builder with Unicode format specifier");
        }

        import core.stdc.stdio : snprintf;

        alias ActualType = Unqual!Input;

        assert(format.isNull || format.isPtrNullTerminated, "Format specifier must be null terminated");

        static if (isReadOnlyString!ActualType || isBuilderString!ActualType || isSomeString!ActualType) {
            if (needQuotes)
                builder ~= "\"";

            builder ~= input;

            if (needQuotes)
                builder ~= "\"";
        } else static if (isBasicType!ActualType || isPointer!ActualType) {
            static if (isSomeChar!ActualType) {
                if (needQuotes)
                    builder ~= "'";

                ActualType[1] temp = [input];
                builder ~= temp[];

                if (needQuotes)
                    builder ~= "'";
            } else {
                if (format.length == 0 || format == "%s") {
                    static if (isPointer!ActualType) {
                        if (input is null) {
                            builder ~= "null";
                            return;
                        } else
                            format = Format(DefaultFormatForType!ActualType);
                    } else static if (is(ActualType == bool)) {
                        builder ~= input ? "true" : "false";
                        return;
                    } else
                        format = Format(DefaultFormatForType!ActualType);
                }

                assert(format.isPtrNullTerminated);

                int done;
                while ((done = snprintf(actualBuffer.ptr, actualBuffer.length, cast(char*)format.ptr, cast(ActualType)input)) > actualBuffer
                        .length) {
                    checkBufferLength(done + 1);
                }

                builder ~= actualBuffer[0 .. done];

                static if (isPointer!ActualType && !is(ActualType == void*)) {
                    alias PointerAt = typeof(*(ActualType.init));

                    static if (isCopyable!PointerAt) {
                        builder ~= "(";
                        scope temp = *input;
                        this.write(String_ASCII.init, temp, true);
                        builder ~= ")";
                    }
                }
            }
        } else static if (isAssociativeArray!ActualType) {
            builder ~= ActualType.stringof ~ "[";
            bool isFirst = true;

            foreach (key, value2; input) {
                if (isFirst)
                    isFirst = false;
                else
                    builder ~= ", ";

                this.write(String_ASCII.init, key, true);
                builder ~= ": ";
                this.write(String_ASCII.init, value2, true);
            }

            builder ~= "]";
        } else static if (isIterable!ActualType) {
            builder ~= __traits(identifier, ActualType) ~ "[";

            size_t i;
            foreach (v; input) {
                if (i++ > 0)
                    output ~= ", ";

                this.write(String_ASCII.init, v, true);
            }

            builder ~= "]";
        } else static if (is(ActualType == struct) || is(ActualType == class)) {
            builder ~= __traits(identifier, ActualType);

            static if (is(ActualType == class)) {
                if (input is null) {
                    builder ~= "null";
                } else {
                    this.write(String_ASCII("0x%X\0"), cast(void*)input, true);
                }
            }

            builder ~= "(";
            bool isFirst = true;

            static if (is(ActualType == class)) {
                static foreach_reverse (i, Base; BaseClassesTuple!ActualType) {
                    static foreach (name; FieldNameTuple!Base) {
                        static if (!(hasUDA!(__traits(getMember, input, name), PrintIgnore) ||
                                hasUDA!(__traits(getMember, input, name), PrettyPrintIgnore)) && __traits(getVisibility,
                                __traits(getMember, input, name)) != "private") {
                            static if (__traits(compiles, __traits(getMember, input, name))) {
                                if (!isFirst)
                                    builder ~= ", ";
                                else
                                    isFirst = false;

                                this.write(String_ASCII.init, __traits(getMember, cast(Base)input, name), true);
                            }
                        }
                    }
                }
            }

            static foreach (name; FieldNameTuple!ActualType) {
                static if (__traits(compiles, __traits(getMember, input, name)) && !(hasUDA!(__traits(getMember,
                        input, name), PrintIgnore) || hasUDA!(__traits(getMember, input, name), PrettyPrintIgnore)) &&
                        __traits(getVisibility, __traits(getMember, input, name)) != "private") {
                    if (!isFirst)
                        builder ~= ", ";
                    else
                        isFirst = false;

                    this.write(String_ASCII.init, __traits(getMember, input, name), true);
                }
            }

            static if (haveToString!ActualType) {
                size_t offsetForToString = builder.length;

                static if (__traits(compiles, { input.toString(builder); })) {
                    input.toString(builder);
                } else static if (__traits(compiles, { builder ~= input.toString(); })) {
                    builder ~= input.toString();
                } else static if (__traits(compiles, { input.toString(&builder.put); })) {
                    input.toString(&builder.put);
                }

                if (builder.length > offsetForToString) {
                    auto subset = builder[offsetForToString .. $];

                    static FQN = fullyQualifiedName!ActualType;

                    if (subset == FQN)
                        builder.remove(offsetForToString, FQN.length);
                    else
                        builder.insert(offsetForToString, cast(string)" -> ");
                }
            }

            builder ~= ")";
        } else static if (is(ActualType == union)) {
            builder ~= __traits(identifier, ActualType) ~ "(";

            size_t leftToGo = ActualType.sizeof;
            ubyte* ptr = cast(ubyte*)&input;

            builder ~= "0x";

            while (leftToGo > 0) {
                this.write(String_ASCII("%X\0"), *ptr, true);

                ptr++;
                leftToGo--;
            }

            builder ~= ")";
        } else static if (is(ActualType == interface)) {
            builder ~= __traits(identifier, ActualType) ~ "@";

            if (input is null) {
                builder ~= "null";
            } else {
                this.write(String_ASCII("0x%X\0"), cast(void*)input, true);
            }
        } else
            pragma(msg, "Attempting to formatWrite " ~ Input.stringof ~ " but it is currently unimplemented in " ~ __MODULE__);
    }

    void checkBufferLength(size_t needed) {
        if (actualBuffer.length >= needed)
            return;

        if (actualBuffer.length > stackBuffer.length) {
            if (allocator.expandArray(actualBuffer, needed - actualBuffer.length))
                return;

            allocator.dispose(actualBuffer);
        }

        actualBuffer = allocator.makeArray!char(needed);
        assert(actualBuffer.length >= needed);
    }
}

unittest {
    auto fv = FormatValue!StringBuilder_UTF8(StringBuilder_UTF8());

    fv(String_UTF8(""), false);
    fv(String_UTF8(""), cast(real)1);
    fv(String_UTF8(""), cast(byte)-2);
    fv(String_UTF8(""), cast(ubyte)3);

    fv(String_UTF8(""), cast(short)-4);
    fv(String_UTF8(""), cast(ushort)5);
    fv(String_UTF8(""), cast(int)-6);
    fv(String_UTF8(""), cast(uint)7);
    fv(String_UTF8(""), cast(long)-8);
    fv(String_UTF8(""), cast(ulong)9);

    fv(String_UTF8(""), cast(char)64);
    fv(String_UTF8(""), cast(wchar)92);
    fv(String_UTF8(""), cast(dchar)94);

    fv(String_UTF8(""), cast(float)-10.5);
    fv(String_UTF8(""), cast(double)-11.5);

    fv(String_UTF8(""), &fv);
    fv(String_UTF8(""), [12: 13]);

    static union Union {
        int x;
        float y;
    }

    fv(String_UTF8(""), Union(14));

    interface Interface {

    }

    static class Parent {
        double d = 22;
    }

    static class Class : Parent, Interface {
        int x = 7;
    }

    Class clasz = new Class;
    fv(String_UTF8(""), cast(Interface)clasz);
    fv(String_UTF8(""), clasz);

    static struct Struct {
        bool b = true;

        string toString() {
            return "Hi there!";
        }
    }

    Struct struc;
    fv(String_UTF8(""), struc);
}

enum DefaultFormatForType(Type) = () {
    static if (is(Type == real))
        return "%Lf\0";
    else static if (is(Type == byte))
        return "%hhi\0";
    else static if (is(Type == ubyte))
        return "%hhu\0";
    else static if (is(Type == short))
        return "%hi\0";
    else static if (is(Type == ushort))
        return "%hu\0";
    else static if (is(Type == int))
        return "%li\0";
    else static if (is(Type == uint))
        return "%lu\0";
    else static if (is(Type == long))
        return "%lli\0";
    else static if (is(Type == ulong))
        return "%llu\0";
    else static if (is(Type == char))
        return "%c\0";
    else static if (is(Type == wchar))
        return "%hc\0";
    else static if (is(Type == dchar))
        return "%lc\0";
    else static if (is(Type == float))
        return "%f\0";
    else static if (is(Type == double))
        return "%Lf\0";
    else static if (isPointer!Type)
        return "%p\0";
    else
        return "";
}();

// Will extra specifiers strings as zero terminated ASCII/UTF8, for in band mixed in text no alterations.
struct RetrieveFormatSpecifier(String) if (isReadOnlyString!String || isSomeString!String) {
@safe nothrow @nogc:

    private {
        static if (isSomeString!String) {
            String_UTF!(Unqual!(ForeachType!String)) source;
        } else {
            String source;
        }

        static if (isASCII!(typeof(source))) {
            alias ForeachType = String_ASCII;
        } else {
            alias ForeachType = String_UTF8;
        }

        RCAllocator allocator;
        char[64] stackBuffer;
        char[] actualBuffer;
    }

scope:

    this(scope String source) @trusted {
        static if (is(typeof(this.source) == typeof(source))) {
            this.source = source;
        } else {
            this.source = typeof(this.source)(source);
        }

        actualBuffer = stackBuffer[];
        allocator = globalAllocator();
    }

    @disable this(this);

    ~this() {
        if (actualBuffer.length > stackBuffer.length) {
            allocator.dispose(actualBuffer);
        }
    }

    int opApply(Del)(scope Del del) @trusted {
        auto working = this.source;

        static if (isUTF!String) {
            working = working.byUTF8;
        }

        int result;

        while (result == 0 && working.length > 0) {
            ptrdiff_t firstPercentage = working.indexOf("%");

            if (firstPercentage < 0)
                break;

            if (firstPercentage > 0) {
                auto temp = working[0 .. firstPercentage];
                result = del(temp);

                if (result)
                    break;

                working = working[firstPercentage .. $];
            }

            {
                ptrdiff_t formatStringLength = 1;

                foreach (c; working[1 .. $]) {
                    formatStringLength++;

                    if (isValidSpecifierEnd(c, formatStringLength))
                        break;
                }

                auto temp = working[0 .. formatStringLength];
                checkBufferLength(temp.length + 1);

                size_t soFar;
                foreach (c; temp)
                    actualBuffer[soFar++] = c;
                actualBuffer[soFar++] = 0;

                temp = typeof(temp)(actualBuffer[0 .. soFar]);

                result = del(temp);
                working = working[formatStringLength .. $];
            }
        }

        if (result == 0 && working.length > 0) {
            result = del(working);
        }

        return result;
    }

    void checkBufferLength(size_t needed) {
        if (actualBuffer.length >= needed)
            return;

        if (actualBuffer.length > stackBuffer.length) {
            if (allocator.expandArray(actualBuffer, needed - actualBuffer.length))
                return;

            allocator.dispose(actualBuffer);
        }

        actualBuffer = allocator.makeArray!char(needed);
        assert(actualBuffer.length >= needed);
    }
}

unittest {
    static string[] Expected = ["hello", "%s", "%%", "world!", "%i"];
    auto rfs = RetrieveFormatSpecifier!string("hello%s%%world!%i");

    size_t counter;
    foreach (rfs.ForeachType specifier; rfs) {
        assert(counter < Expected.length);

        assert(specifier == Expected[counter]);
        assert(specifier.isPtrNullTerminated || !specifier.startsWith("%"));

        counter++;
    }
}

bool isValidSpecifierEnd(char c, ptrdiff_t index) @safe nothrow @nogc pure {
    switch (c) {
    case 'd':
    case 'i':
    case 'u':
    case 'o':
    case 'x':
    case 'X':
    case 'f':
    case 'F':
    case 'e':
    case 'E':
    case 'g':
    case 'G':
    case 'a':
    case 'A':
    case 'c':
    case 's':
    case 'p':
    case 'n':
        return true;

    case '%':
        if (index == 2)
            return true;
        else
            goto default;

    default:
        return false;
    }
}

// This is a very strict type check, except for %s which accepts anything
template CheckParameters(alias Format, Args...) if (isSomeString!(typeof(Format))) {
    enum CheckParameters = () {
        import std.string : indexOf;

        auto working = Format;

        ptrdiff_t index;

        static foreach (i; 0 .. Args.length) {
            for (;;) {
                alias Arg = Args[i];

                index = working.indexOf('%');
                assert(index >= 0, "Not enough format specifiers for arguments");

                working = working[index .. $];
                index = 1;

                foreach (c; working[1 .. $]) {
                    index++;
                    if (isValidSpecifierEnd(c, index))
                        break;
                }

                assert(index > 1, "Incomplete format specifier (length)");
                char spec = working[index - 1];
                assert(isValidSpecifierEnd(spec, index), "Incomplete format specifier");

                if (spec == '%') {
                    working = working[index .. $];
                    continue;
                }

                switch (spec) {
                case 'd':
                case 'i':
                case 'u':
                case 'o':
                case 'x':
                case 'X':
                    if (isIntegral!Arg)
                        break;
                    assert(0, "%[diuoxX] must be paired with an integral type not " ~ Arg.stringof);

                case 'f':
                case 'F':
                case 'e':
                case 'E':
                case 'g':
                case 'G':
                case 'a':
                case 'A':
                    if (isFloatingPoint!Arg)
                        break;
                    assert(0, "%[fFeEgGaA] Must be paired with a floating point type not " ~ Arg.stringof);
                case 'c':
                    if (isSomeChar!Arg || is(Arg == ubyte))
                        break;
                    assert(0, "%c must be paired with some sort of character not " ~ Arg.stringof);

                case 's':
                    version (none) {
                        if (isReadOnlyString!Arg || isBuilderString!Arg || isUTF!Arg || isSomeString!Arg)
                            break;
                        assert(0, "%s must be paired with some sort of string not " ~ Arg.stringof);
                    }
                    // everything goes to this, not just strings
                    break;

                case 'p':
                    if (isPointer!Arg)
                        break;
                    assert(0, "%p must be paired with a pointer not " ~ Arg.stringof);

                case 'n':
                    static if (isPointer!Arg) {
                        alias PointedTo = typeof(*(Arg.init));
                        if (isIntegral!PointedTo)
                            break;
                        assert(0, "%n must be apired with a pointer to an integer not " ~ Arg.stringof);
                    } else
                        assert(0, "%n must be paired with a pointer to integer not " ~ Arg.stringof);

                default:
                    assert(0, "Unrecognized format specifier " ~ working[0 .. index]);
                }

                working = working[index .. $];
                break;
            }
        }

        assert(working.indexOf('%') < 0, "Not enough arguments for format specifier");
        return true;
    }();
}

static assert(!is(CheckParameters!("Abc%s")));
static assert(!is(CheckParameters!("Abc", int)));
static assert(CheckParameters!("%%%X%f%c%s%s%s%p%n", byte, double, wchar, string, StringBuilder_ASCII, String_UTF8, char*, int*));
