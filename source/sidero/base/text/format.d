///
module sidero.base.text.format;
import sidero.base.text;
import sidero.base.errors.result;
public import sidero.base.attributes : PrintIgnore, PrettyPrintIgnore;
import sidero.base.traits;
import sidero.base.attributes : hidden;

export:

/// See_Also: formattedWrite
StringBuilder_UTF8 format(Format, Args...)(scope Format format, scope Args args) {
    StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());
    builder.formattedWrite(format, args);
    return builder;
}

///
unittest {
    assert(format("hello %s", "world!").length == "hello world!".length);
}

/// See_Also: formattedWrite
StringBuilder_UTF8 format(alias Format, Args...)(scope Args args) {
    StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());
    builder.formattedWrite!Format(args);
    return builder;
}

///
unittest {
    assert(format!"hello %s"("world!").length == "hello world!".length);
}

/// Formats argument based upon format, ignores fields with PrintIgnore or PrettyPrintIgnore UDA.
void formattedWrite(alias Format, Builder, Args...)(scope Builder builder, scope Args args)
        if (isBuilderString!Builder && isSomeString!(typeof(Format))) {
    static assert(CheckParameters!(Format, Args));
    formattedWrite(builder, Format, args);
}

/// Ditto
void formattedWrite(Builder, Format, Args...)(scope Builder builder, scope Format format, scope Args args) @trusted
        if (isBuilderString!Builder && (isReadOnlyString!Format || isSomeString!Format)) {
    import sidero.base.algorithm : startsWith;

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
        if (offset <= i)
            fv(String_ASCII.init, args[i]);
    }
}

/// Formats arguments based upon format and configuration, ignores fields with PrettyPrintIgnore UDA.
struct PrettyPrint(ConstantsType)
        if (isReadOnlyString!ConstantsType || isBuilderString!ConstantsType || isSomeString!ConstantsType) {
    /// For each line emit: prefix? prefixToRepeat{depth} prefixSuffix?
    ConstantsType prefix, prefixToRepeat = ConstantsType("\t"), prefixSuffix = ConstantsType("- ");
    /// The text divider to emit for between arguments to pretty printer
    ConstantsType betweenArgumentDivider = ConstantsType(", ");
    /// The text divider to emit for between sequential values
    ConstantsType betweenValueDivider = ConstantsType(", ");

    ///
    uint depth;
    ///
    bool useQuotes;
export nothrow @nogc:

    ///
    void opCall(Builder, Args...)(scope Builder builder, scope Args args) @trusted if (isBuilderString!Builder) {
        static if (is(Builder == StringBuilder_ASCII) && isUTF!ConstantsType) {
            static assert(0, "You cannot use an ASCII string builder with Unicode prefix type");
        }

        Impl!Builder impl;
        impl.parent = &this;
        impl.builder = builder;

        if (builder.length == 0 || builder.endsWith("\n"))
            impl.handlePrefix;

        foreach (i, ref arg; args) {
            if (i > 0 && !betweenArgumentDivider.isNull)
                impl.builder ~= betweenArgumentDivider;

            impl.handle(arg, useQuotes);
        }
    }

private @hidden:
    static struct Impl(Builder) {
        PrettyPrint* parent;
        Builder builder;

        enum haveToString(T) = __traits(hasMember, T, "toString") && (__traits(compiles, {
                    Builder builder;
                    T value;
                    value.toString(builder);
                }) || __traits(compiles, { Builder builder; T value; builder ~= value.toString(); }) || __traits(compiles, {
                    Builder builder;
                    T value;
                    value.toString(&builder.put);
                }));

        enum haveToStringPretty(T) = __traits(hasMember, T, "toStringPretty") && (__traits(compiles, {
                    Builder builder;
                    T value;
                    value.toStringPretty(builder);
                }) || __traits(compiles, { Builder builder; T value; builder ~= value.toStringPretty(); }) || __traits(compiles, {
                    Builder builder;
                    T value;
                    value.toStringPretty(&builder.put);
                }));

        void handlePrefix(bool onlyRepeat = false, bool usePrefix = true, bool useSuffix = true) @safe nothrow @nogc {
            if (!onlyRepeat && usePrefix)
                builder ~= parent.prefix;

            if (!parent.prefixToRepeat.isNull) {
                foreach (i; 0 .. parent.depth) {
                    builder ~= parent.prefixToRepeat;
                }
            }

            if (!onlyRepeat && useSuffix)
                builder ~= parent.prefixSuffix;
        }

        void handle(Type)(scope ref Type input, bool useQuotes = true, bool useName = true, bool forcePrint = false) @trusted nothrow @nogc {
            static if (__traits(compiles, hasUDA!(ActualType, PrettyPrintIgnore))) {
                if (!forcePrint && hasUDA!(ActualType, PrettyPrintIgnore))
                    return;
            }

            alias ActualType = Unqual!Type;

            if (builder.endsWith(")") || builder.endsWith("]")) {
                if (!parent.betweenValueDivider.isNull)
                    builder ~= parent.betweenValueDivider;
            }

            static if (isSomeString!ActualType) {
                if (input is null) {
                    builder ~= "null";
                    return;
                }

                if (useQuotes)
                    builder ~= "\"";

                size_t oldOffset = builder.length;
                builder ~= input;
                builder[oldOffset .. $].escape(useQuotes ? '"' : 0);

                if (useQuotes)
                    builder ~= "\"";
            } else static if (isReadOnlyString!ActualType || isBuilderString!ActualType) {
                if (input.isNull) {
                    builder ~= "null";
                    return;
                }

                if (useQuotes)
                    builder ~= "\"";

                size_t oldOffset = builder.length;
                builder ~= cast()input;
                builder[oldOffset .. $].escape(useQuotes ? '"' : 0);

                if (useQuotes)
                    builder ~= "\"";
            } else static if (isStaticArray!Type && (isSomeString!(typeof(Type.init[])))) {
                auto temp = input[];
                this.handle(temp, true);
            } else static if (isFunctionPointer!ActualType) {
                builder ~= ActualType.stringof;

                if (input is null)
                    builder ~= "@null";
                else
                    builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)input);
            } else static if (isPointer!ActualType && __traits(compiles, typeof(*input))) {
                alias SubType = typeof(*input);

                static if (__traits(compiles, fullyQualifiedName!SubType))
                    enum EntryName = fullyQualifiedName!SubType;
                else
                    enum EntryName = SubType.stringof;

                builder ~= EntryName;

                if (input !is null) {
                    static if (is(SubType == class) || isAssociativeArray!SubType || isDynamicArray!SubType) {
                        if (*input is null) {
                            builder ~= "@null";
                        } else {
                            static if (is(SubType == class) || isAssociativeArray!SubType) {
                                builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)cast(void*)*input);
                            } else static if (isArray!SubType) {
                                builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)(*input).ptr);
                            }
                        }
                    }
                }

                static if (!(is(SubType == struct) || isBasicType!SubType))
                    builder ~= "*";

                if (input is null)
                    builder ~= "@null";
                else {
                    builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)input);

                    static if (!is(SubType == void)) {
                        handle(*input, true, false);
                    }
                }
            } else static if (is(ActualType : Result!WrappedType, WrappedType) || is(ActualType : ResultReference!WrappedType, WrappedType)) {
                if (input && !input.isNull) {
                    // ok print the thing

                    static if (!is(WrappedType == void)) {
                        scope temp = &input.assumeOkay();
                        handle(*temp, useQuotes, useName, forcePrint);
                        return;
                    }
                }

                builder.formattedWrite(String_ASCII.init, input);
            } else static if (is(ActualType == struct) || is(ActualType == class)) {
                static FQN = fullyQualifiedName!ActualType;

                if (useName) {
                    builder ~= FQN;

                    static if (is(ActualType == class)) {
                        if (input is null)
                            builder ~= "@null";
                        else
                            builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)cast(void*)input);
                    }
                }

                static if (is(ActualType == class)) {
                    if (input is null)
                        return;
                }

                builder ~= "(";
                parent.depth++;

                {
                    bool isFirst = true;

                    static foreach (name; FieldNameTuple!ActualType) {
                        {
                            alias member = __traits(getMember, input, name);
                            bool ignore = __traits(getVisibility, member) == "private";

                            foreach (attr; __traits(getAttributes, member)) {
                                ignore = ignore || is(attr == PrettyPrintIgnore);
                            }

                            static foreach (name2; FieldNameTuple!ActualType) {
                                {
                                    alias member2 = __traits(getMember, input, name2);

                                    if (name != name2) {
                                        ignore = ignore || member.offsetof == member2.offsetof;
                                    }
                                }
                            }

                            if (!ignore) {
                                if (!isFirst)
                                    builder ~= ", ";
                                else
                                    isFirst = false;

                                builder ~= "\n";

                                handlePrefix(false, true, false);
                                builder ~= name;
                                builder ~= ": ";
                                handle(__traits(getMember, input, name), true);
                            }
                        }
                    }

                    static if (is(ActualType == class)) {
                        static foreach (i, Base; BaseClassesTuple!ActualType) {
                            handlePrefix(false, true, false);
                            builder ~= "---- ";
                            builder ~= fullyQualifiedName!Base;
                            builder ~= " ----\n";
                            isFirst = true;

                            static foreach (name; FieldNameTuple!Base) {
                                {
                                    alias member = __traits(getMember, input, name);
                                    bool ignore = __traits(getVisibility, member) == "private", explicitIgnore;

                                    foreach (attr; __traits(getAttributes, member)) {
                                        explicitIgnore = explicitIgnore || is(attr == PrettyPrintIgnore);
                                    }

                                    static foreach (name2; FieldNameTuple!ActualType) {
                                        {
                                            alias member2 = __traits(getMember, input, name2);

                                            if (name != name2) {
                                                ignore = ignore || member.offsetof == member2.offsetof;
                                            }
                                        }
                                    }

                                    if (!ignore && !explicitIgnore) {
                                        if (!isFirst)
                                            builder ~= ", ";
                                        else
                                            isFirst = false;

                                        builder ~= "\n";
                                        handlePrefix(false, true, false);
                                        builder ~= name;
                                        builder ~= ": ";
                                        handle(__traits(getMember, input, name), true);
                                    }
                                }
                            }
                        }
                    }
                }

                {
                    bool isFirst = true;

                    static foreach (name; FieldNameTuple!ActualType) {
                        {
                            alias member = __traits(getMember, input, name);
                            bool accessible = __traits(getVisibility, member) == "private", explicitIgnore, ignore = accessible, overload;

                            foreach (attr; __traits(getAttributes, member)) {
                                explicitIgnore = explicitIgnore || is(attr == PrettyPrintIgnore);
                            }

                            static foreach (name2; FieldNameTuple!ActualType) {
                                {
                                    alias member2 = __traits(getMember, input, name2);

                                    if (name != name2) {
                                        ignore = ignore || member.offsetof == member2.offsetof;
                                        overload = overload || member.offsetof == member2.offsetof;
                                    }
                                }
                            }

                            if (ignore && !explicitIgnore) {
                                if (isFirst) {
                                    isFirst = false;
                                    builder ~= "\n";

                                    handlePrefix(false, true, false);
                                    builder ~= "---- ignoring ----";
                                } else
                                    builder ~= ",";

                                builder ~= "\n";
                                handlePrefix(false, true, false);

                                if (accessible)
                                    builder ~= "private ";
                                if (overload)
                                    builder ~= "union ";

                                builder ~= name;
                            }
                        }
                    }

                    static if (is(ActualType == class)) {
                        static foreach (i, Base; BaseClassesTuple!ActualType) {
                            handlePrefix(false, true, false);
                            builder ~= "---- ";
                            builder ~= fullyQualifiedName!Base;
                            builder ~= " ----\n";
                            isFirst = true;

                            static foreach (name; FieldNameTuple!Base) {
                                {
                                    alias member = __traits(getMember, input, name);
                                    bool accessible = __traits(getVisibility, member) == "private", explicitIgnore,
                                        ignore = accessible, overload;

                                    foreach (attr; __traits(getAttributes, member)) {
                                        explicitIgnore = explicitIgnore || is(attr == PrettyPrintIgnore);
                                    }

                                    static foreach (name2; FieldNameTuple!ActualType) {
                                        {
                                            alias member2 = __traits(getMember, input, name2);

                                            if (name != name2) {
                                                ignore = ignore || member.offsetof == member2.offsetof;
                                                overload = overload || member.offsetof == member2.offsetof;
                                            }
                                        }
                                    }

                                    if (ignore && !explicitIgnore) {
                                        if (isFirst) {
                                            isFirst = false;
                                            builder ~= "\n";

                                            handlePrefix(false, true, false);
                                            builder ~= "---- ignoring ----";
                                        } else
                                            builder ~= ",";

                                        builder ~= "\n";
                                        handlePrefix(false, true, false);

                                        if (accessible)
                                            builder ~= "private ";
                                        if (overload)
                                            builder ~= "union ";

                                        builder ~= name;
                                    }
                                }
                            }
                        }
                    }
                }

                static if (isIterable!ActualType && (HaveNonStaticOpApply!ActualType || !__traits(hasMember, ActualType, "opApply"))) {
                    if (builder.endsWith("("))
                        builder ~= "[";
                    else
                        builder ~= " [";

                    static if (__traits(compiles, {
                            foreach (key, value; input) {
                            }
                        })) {
                        foreach (k, v; input) {
                            builder ~= "\n";
                            handlePrefix();

                            handle(k);
                            builder ~= ": ";

                            handle(v);
                            builder ~= ",";
                        }
                    } else static if (__traits(compiles, {
                            foreach (value; input) {
                            }
                        })) {
                        foreach (v; input) {
                            builder ~= "\n";
                            handlePrefix();
                            handle(v);
                            builder ~= ",";
                        }
                    } else
                        builder ~= "...";

                    if (builder.endsWith(","))
                        builder.clobberInsert(builder.length - 1, cast(string)"]");
                    else
                        builder ~= "]";
                }

                static if (haveToStringPretty!ActualType && !hasUDA!(__traits(getMember, input, "toStringPretty"), PrettyPrintIgnore)) {
                    size_t offsetForToString = builder.length;

                    static if (__traits(compiles, builder.toStringPretty(output))) {
                        input.toStringPretty(builder);
                    } else static if (__traits(compiles, input.toStringPretty(&builder.put))) {
                        input.toStringPretty(&builder.put);
                    } else static if (__traits(compiles, builder ~= input.toStringPretty())) {
                        builder ~= input.toStringPretty();
                    }

                    if (builder.length > offsetForToString) {
                        Builder prior = builder[0 .. offsetForToString], subset = builder[offsetForToString .. $];

                        if (subset == FQN)
                            builder.remove(offsetForToString, size_t.max);
                        else if (subset.startsWith(", ")) {
                            builder.remove(offsetForToString, 1);
                            builder.insert(offsetForToString + 1, "->\n"c);
                        } else if (subset.contains("\n") || subset.length > 40) {
                            // forty was chosen mostly at random,
                            // but its half a lot of max line lengths (80) so can't be too bad
                            builder.insert(offsetForToString, "->\n"c);
                        } else if (!prior.endsWith("(")) {
                            builder.insert(offsetForToString, " ->\n"c);
                        }
                    }
                } else static if (haveToString!ActualType && !hasUDA!(__traits(getMember, input, "toString"), PrettyPrintIgnore)) {
                    size_t offsetForToString = builder.length;

                    static if (__traits(compiles, input.toString(builder))) {
                        input.toString(builder);
                    } else static if (__traits(compiles, input.toString(&builder.put))) {
                        input.toString(&builder.put);
                    } else static if (__traits(compiles, builder ~= input.toString())) {
                        builder ~= input.toString();
                    }

                    if (builder.length > offsetForToString) {
                        Builder prior = builder[0 .. offsetForToString], subset = builder[offsetForToString .. $];

                        if (subset == FQN) {
                            builder.remove(offsetForToString, size_t.max);
                        } else if (subset.contains("\n") || subset.length > 40) {
                            // forty was chosen mostly at random,
                            // but its half a lot of max line lengths (80) so can't be too bad
                            builder.insert(offsetForToString, "->\n"c);
                        } else if (!prior.endsWith("(")) {
                            builder.insert(offsetForToString, " ->\n"c);
                        }
                    }
                }

                parent.depth--;

                if (builder.endsWith(","))
                    builder.clobberInsert(builder.length - 1, ")"c);
                else
                    builder ~= ")";
            } else static if (isArray!ActualType) {
                alias SubType = Unqual!(typeof(input[0]));

                static if (__traits(compiles, fullyQualifiedName!SubType)) {
                    enum EntryName = fullyQualifiedName!SubType;
                } else
                    enum EntryName = __traits(identifier, SubType);

                bool handled;

                static if (isBasicType!SubType) {
                    if (input.length <= 5) {
                        if (useName) {
                            builder ~= EntryName;

                            static if (isDynamicArray!ActualType) {
                                if (input is null)
                                    builder ~= "@null";
                                else
                                    builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)input.ptr);
                            }
                        }

                        static if (!is(SubType == void)) {
                            builder ~= "[";

                            foreach (i, ref entry; input) {
                                if (i > 0 && !parent.betweenValueDivider.isNull)
                                    builder ~= parent.betweenValueDivider;
                                handle(entry);
                            }

                            builder ~= "]";
                        } else {
                            builder ~= "=0x[";
                            auto temp = cast()input;

                            while (temp.length > 0) {
                                builder.formattedWrite("%.2X", *cast(const(ubyte)*)&temp[0]);
                                temp = temp[1 .. $];
                            }

                            builder ~= "]";
                        }

                        handled = true;
                    }
                }

                if (!handled) {
                    if (useName) {
                        builder ~= EntryName;

                        static if (isDynamicArray!ActualType) {
                            if (input is null)
                                builder ~= "@null";
                            else
                                builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(size_t)input.ptr);
                        }
                    }

                    static if (!is(SubType == void)) {
                        builder ~= "[\n";
                        parent.depth++;

                        foreach (i, ref entry; input) {
                            handlePrefix();
                            handle(entry, true, true, true);
                            builder ~= "\n";
                        }

                        parent.depth--;
                        builder ~= "]";
                    } else {
                        builder ~= "=0x";
                        auto temp = cast()input;

                        while (temp.length > 0) {
                            builder.formattedWrite("%.2X", *cast(const(ubyte)*)&temp[0]);
                            temp = temp[1 .. $];
                        }

                        builder ~= "]";
                    }
                }
            } else static if (isAssociativeArray!ActualType) {
                alias Key = KeyType!ActualType;
                alias Value = ValueType!ActualType;

                static if (__traits(compiles, fullyQualifiedName!Key))
                    enum KeyName = fullyQualifiedName!Key;
                else
                    enum KeyName = Key.stringof;
                static if (__traits(compiles, fullyQualifiedName!Value))
                    enum ValueName = fullyQualifiedName!Value;
                else
                    enum ValueName = Value.stringof;

                enum EntryName = ValueName ~ "[" ~ KeyName ~ "]";

                if (useName) {
                    builder ~= EntryName;
                    builder.formattedWrite("@" ~ DefaultFormatForPointer, cast(void*)input);
                }

                builder ~= "[\n";
                parent.depth++;

                version (D_BetterC) {
                } else {
                    try {
                        foreach (key, ref value; input) {
                            handlePrefix();
                            handle(key, true, true, true);
                            builder ~= ": ";

                            handle(value, true, true, true);
                            builder ~= "\n";
                        }
                    } catch (Exception) {
                    }
                }

                parent.depth--;
                builder ~= "]";
            } else static if (is(ActualType == enum)) {
                import std.traits : OriginalType;

                enum FQN = fullyQualifiedName!ActualType;
                builder ~= FQN;

                static foreach (m; __traits(allMembers, ActualType)) {
                    if (__traits(getMember, ActualType, m) == input) {
                        builder ~= "."c;
                        builder ~= m;
                        goto Done;
                    }
                }

                builder ~= "("c;
                handle(cast(OriginalType!ActualType)input, useQuotes, useName, forcePrint);
                builder ~= ")"c;
            Done:
            } else {
                builder.formattedWrite(String_ASCII.init, input);
            }
        }
    }
}

///
unittest {
    PrettyPrint!String_UTF8 prettyPrint;
    prettyPrint.useQuotes = true;

    struct Pointer {
        int foobar = 27;
    }

    StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());

    Pointer pointer;
    ErrorResult errorResult;
    Result!int iResult = 3;

    static class Parent {
        double d = 22;
    }

    static class Class : Parent {
        int x = 7;
    }

    static struct Struct {
        bool b = true;

        string toString() {
            return "Hi there!";
        }
    }

    Class clasz = new Class;
    Struct struc;

    prettyPrint(builder, &pointer, errorResult, iResult, "hello \"\t world!", String_UTF8("More Text muahah1"),
            [12: 13], [22, 24], ["abc", "xyz"], clasz, struc);
}

/// Escapes all of the standard escapes for ASCII and optionally do quotes (must provide as character literal as to which to use)
StringBuilder_ASCII escape(return scope StringBuilder_ASCII builder, char quote = 0) @safe nothrow @nogc {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_ASCII builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Ditto
StringBuilder_UTF8 escape(return scope StringBuilder_UTF8 builder, dchar quote = 0) @safe nothrow @nogc {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF8 builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Ditto
StringBuilder_UTF16 escape(return scope StringBuilder_UTF16 builder, dchar quote = 0) @safe nothrow @nogc {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF16 builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Ditto
StringBuilder_UTF32 escape(return scope StringBuilder_UTF32 builder, dchar quote = 0) @safe nothrow @nogc {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF32 builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Unescapes all of the standard escapes for ASCII and optionally do quotes (must provide as character literal as to which to use)
StringBuilder_ASCII unescape(return scope StringBuilder_ASCII builder, char quote = 0) @safe nothrow @nogc {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_ASCII builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

/// Ditto
StringBuilder_UTF8 unescape(return scope StringBuilder_UTF8 builder, dchar quote = 0) @safe nothrow @nogc {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF8 builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

/// Ditto
StringBuilder_UTF16 unescape(return scope StringBuilder_UTF16 builder, dchar quote = 0) @safe nothrow @nogc {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF16 builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

/// Ditto
StringBuilder_UTF32 unescape(return scope StringBuilder_UTF32 builder, dchar quote = 0) @safe nothrow @nogc {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF32 builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

private @hidden:
import sidero.base.allocators;
import std.traits : isSomeChar, isPointer, isIntegral, isFloatingPoint, Unqual, ForeachType, isBasicType, isIterable,
    isAssociativeArray, isArray, isDynamicArray, FieldNameTuple, hasUDA, KeyType, ValueType, BaseClassesTuple, isCopyable;

Builder escapeImpl(Builder, Char)(return scope Builder builder, Char quote) @trusted nothrow @nogc
        if (isBuilderString!Builder) {
    static if (isUTF!Builder) {
        static Find = ["\\"d, "\0", "\a", "\b", "\f", "\n", "\r", "\t", "\v"];
        static Replace = ["\\\\"d, "\\0", "\\a", "\\b", "\\f", "\\n", "\\r", "\\t", "\\v"];
    } else static if (isASCII!Builder) {
        static Find = ["\\", "\0", "\a", "\b", "\f", "\n", "\r", "\t", "\v"];
        static Replace = ["\\\\", "\\0", "\\a", "\\b", "\\f", "\\n", "\\r", "\\t", "\\v"];
    }

    foreach (i; 0 .. Find.length)
        builder.replace(Find[i], Replace[i]);

    if (quote != 0) {
        Char[2] temp = ['\\', quote];
        builder.replace(temp[1 .. 2], temp[]);
    }

    return builder;
}

Builder unescapeImpl(Builder, Char)(return scope Builder builder, Char quote) @safe nothrow @nogc
        if (isBuilderString!Builder) {
    static if (isUTF!Builder) {
        static Find = ["\\\\"d, "\\0", "\\a", "\\b", "\\f", "\\n", "\\r", "\\t", "\\v"];
        static Replace = ["\\"d, "\0", "\a", "\b", "\f", "\n", "\r", "\t", "\v"];
    } else static if (isASCII!Builder) {
        static Find = ["\\\\", "\\0", "\\a", "\\b", "\\f", "\\n", "\\r", "\\t", "\\v"];
        static Replace = ["\\", "\0", "\a", "\b", "\f", "\n", "\r", "\t", "\v"];
    }

    foreach (i; 0 .. Find.length)
        builder.replace(Find[i], Replace[i]);

    if (quote != 0) {
        Char[2] temp = ['\\', quote];
        builder.replace(temp[], temp[1 .. 2]);
    }

    return builder;
}

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

scope @hidden:

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

    void opCall(Format, Input)(scope Format format, scope Input input, bool needQuotes = false) @trusted
            if (isReadOnlyString!Format) {
        this.write(format, input, needQuotes);
    }

    void write(Format, Input)(scope Format format, ref scope Input input, bool needQuotes = false) @trusted
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

            size_t oldOffset = builder.length;
            builder ~= input;
            builder[oldOffset .. $].escape(needQuotes ? '"' : 0);

            if (needQuotes)
                builder ~= "\"";
        } else static if (isStaticArray!ActualType && (isSomeString!(typeof(ActualType.init[])))) {
            this.write(format, input[], true);
        } else static if (is(ActualType == enum)) {
            import std.traits : OriginalType;

            builder ~= __traits(identifier, ActualType);

            static foreach (m; __traits(allMembers, ActualType)) {
                if (__traits(getMember, ActualType, m) == input) {
                    builder ~= "."c;
                    builder ~= m;
                    goto Done;
                }
            }

            builder ~= "("c;
            write(format, cast(OriginalType!ActualType)input, needQuotes);
            builder ~= ")"c;
        Done:
        } else static if (isBasicType!ActualType || isPointer!ActualType) {
            static if (isSomeChar!ActualType) {
                if (needQuotes)
                    builder ~= "'";

                ActualType[1] temp = [input];

                size_t oldOffset = builder.length;
                builder ~= temp[];
                builder[oldOffset .. $].escape(needQuotes ? '\'' : 0);

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

                static if (isPointer!ActualType && __traits(compiles, typeof(*(ActualType.init))) && !isFunctionPointer!ActualType) {
                    alias PointerAt = typeof(*(ActualType.init));

                    static if (isCopyable!PointerAt) {
                        builder ~= "(";
                        scope temp = *input;
                        this.write(String_ASCII.init, temp, true);
                        builder ~= ")";
                    }
                }
            }
        } else static if (is(ActualType : Result!WrappedType, WrappedType) || is(ActualType : ResultReference!WrappedType, WrappedType)) {
            if (input) {
                // ok print the thing

                if (input.isNull) {
                    builder ~= "no-error but null";
                } else static if (is(WrappedType == void)) {
                    builder ~= "no-error";
                } else {
                    WrappedType* wrapped = &input.assumeOkay();
                    this.write!(Format, WrappedType)(format, *wrapped, true);
                }
            } else {
                builder ~= "error: ";

                builder ~= input.error.info.id;
                builder ~= ":";
                builder ~= input.error.info.message;

                builder ~= "`";
                builder ~= input.error.moduleName;
                builder ~= ":";
                this.write(String_ASCII.init, input.error.line);
                builder ~= "`";
            }
        } else static if (isAssociativeArray!ActualType) {
            builder ~= ActualType.stringof ~ "[";
            bool isFirst = true;

            version (D_BetterC) {
            } else {
                try {
                    foreach (key, value2; input) {
                        if (isFirst)
                            isFirst = false;
                        else
                            builder ~= ", ";

                        this.write(String_ASCII.init, key, true);
                        builder ~= ": ";
                        this.write(String_ASCII.init, value2, true);
                    }
                } catch (Exception) {
                }
            }

            builder ~= "]";
        } else static if (isArray!ActualType) {
            builder ~= ActualType.stringof;

            if (input is null) {
                builder ~= "@null";
            } else {
                auto tempPtr = cast(size_t)input.ptr;
                this.write(String_ASCII("@0x" ~ DefaultFormatForPointer), tempPtr, true);

                builder ~= "[";

                size_t i;

                foreach (v; input) {
                    if (i++ > 0)
                        builder ~= ", ";

                    this.write(String_ASCII.init, v, true);
                }

                builder ~= "]";
            }
        } else static if (isIterable!ActualType && (HaveNonStaticOpApply!ActualType || !__traits(hasMember, ActualType, "opApply"))) {
            builder ~= "[";

            size_t i;

            foreach (v; input) {
                if (i++ > 0)
                    builder ~= ", ";

                this.write(String_ASCII.init, v, true);
            }

            builder ~= "]";
        } else static if (is(ActualType == struct) || is(ActualType == class)) {
            builder ~= __traits(identifier, ActualType);

            static if (is(ActualType == class)) {
                if (input is null) {
                    builder ~= "null";
                } else {
                    auto tempPtr = cast(void*)input;
                    this.write(String_ASCII("0x" ~ DefaultFormatForPointer), tempPtr, true);
                }
            }

            builder ~= "(";
            bool isFirst = true;

            static foreach (name; FieldNameTuple!ActualType) {
                {
                    alias member = __traits(getMember, input, name);
                    bool ignore;

                    foreach (attr; __traits(getAttributes, member)) {
                        ignore = ignore || is(attr == PrintIgnore) || is(attr == PrettyPrintIgnore);
                    }

                    static foreach (name2; FieldNameTuple!ActualType) {
                        {
                            alias member2 = __traits(getMember, input, name2);

                            if (name != name2) {
                                ignore = ignore || member.offsetof == member2.offsetof;
                            }
                        }
                    }

                    if (!ignore) {
                        if (!isFirst)
                            builder ~= ", ";
                        else
                            isFirst = false;

                        this.write(String_ASCII.init, __traits(getMember, input, name), true);
                    }
                }
            }

            static if (is(ActualType == class)) {
                static foreach_reverse (i, Base; BaseClassesTuple!ActualType) {
                    static foreach (name; FieldNameTuple!Base) {
                        {
                            alias member = __traits(getMember, cast(Base)input, name);
                            bool ignore;

                            foreach (attr; __traits(getAttributes, member)) {
                                ignore = ignore || is(attr == PrintIgnore) || is(attr == PrettyPrintIgnore);
                            }

                            static foreach (name2; FieldNameTuple!Base) {
                                {
                                    alias member2 = __traits(getMember, cast(Base)input, name2);

                                    if (name != name2) {
                                        ignore = ignore || member.offsetof == member2.offsetof;
                                    }
                                }
                            }

                            if (!ignore) {
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
                    static FQN = fullyQualifiedName!ActualType;
                    auto subset = builder[offsetForToString .. $];

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
                this.write(String_ASCII(DefaultFormatForPointer), *ptr, true);

                ptr++;
                leftToGo--;
            }

            builder ~= ")";
        } else static if (is(ActualType == interface)) {
            builder ~= __traits(identifier, ActualType) ~ "@";

            if (input is null) {
                builder ~= "null";
            } else {
                auto tempPtr = cast(void*)input;
                this.write(String_ASCII("0x" ~ DefaultFormatForPointer), tempPtr, true);
            }
        } else static if (is(ActualType == delegate)) {
            builder ~= ActualType.stringof ~ "@(";
            this.write(String_ASCII("context: 0x" ~ DefaultFormatForPointer ~ ", "), input.ptr, true);
            auto tempFuncPtr = cast(void*)input.funcptr;
            this.write(String_ASCII("function pointer: 0x" ~ DefaultFormatForPointer), tempFuncPtr, true);
            builder ~= ")";
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

    ErrorResult errorResult;
    fv(String_UTF8(""), errorResult);

    Result!int iResult = 3;
    fv(String_UTF8(""), iResult);
}

enum DefaultFormatForPointer = "%zX\0";

enum DefaultFormatForType(Type) = () {
    static if (is(Type == real) || is(Type == float) || is(Type == double))
        return "%." ~ Type.dig.stringof ~ "g\0";
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
    else static if (isPointer!Type)
        return "%p\0";
    else
        return "";
}();

// Will extra specifiers strings as zero terminated ASCII/UTF8, for in band mixed in text no alterations.
struct RetrieveFormatSpecifier(String) if (isReadOnlyString!String || isSomeString!String) {

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

scope @hidden:

    this(scope String source) nothrow @nogc @trusted {
        static if (is(typeof(this.source) == typeof(source))) {
            this.source = source;
        } else {
            this.source = typeof(this.source)(source);
        }

        actualBuffer = stackBuffer[];
        allocator = globalAllocator();
    }

    @disable this(this);

    ~this() @safe nothrow @nogc {
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

                static if (isSomeString!String) {
                    temp = cast(String)(actualBuffer[0 .. soFar]);
                } else {
                    temp = String(cast(String.LiteralType)actualBuffer[0 .. soFar]);
                }

                result = del(temp);
                working = working[formatStringLength .. $];
            }
        }

        if (result == 0 && working.length > 0) {
            result = del(working);
        }

        return result;
    }

    void checkBufferLength(size_t needed) @safe nothrow @nogc {
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

bool isValidSpecifierEnd()(char c, ptrdiff_t index) @safe nothrow @nogc pure {
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

ptrdiff_t indexOf(Char)(const(Char)[] input, Char toFind) if (isSomeChar!Char) {
    foreach (i, c; input) {
        if (c == toFind)
            return i;
    }

    return -1;
}
