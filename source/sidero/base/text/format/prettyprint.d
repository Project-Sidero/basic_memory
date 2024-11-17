module sidero.base.text.format.prettyprint;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.traits;
import sidero.base.attributes;

export @safe nothrow @nogc:

/**
Formats arguments based upon format and configuration, ignores fields with PrettyPrintIgnore UDA.

The expectation of the depth and where the previous builder will be at:

```
[...prefix...] [...text...]
----^ depth will always be 0 relatively
---------------^ previously written text
----------------------------^ there will be a new line here if `startWithoutPrefix` is `false`
```

Always call ``emitPrefix`` prior to writing anything that could be on a new line.
Calling a formatting or to string function should never require a call to ``emitPrefix`` before it.
Let the called function do it, and set ``startWithoutPrefix`` instead.

Always increase your depth after doing a newline when you give a new category of information.

Never end what you write in a new line.
*/
struct PrettyPrint {
    /// For each line emit: prefix? prefixToRepeat{depth} prefixSuffix?
    String_UTF8 prefix, prefixToRepeat, prefixSuffix;
    /// The text divider to emit for between arguments to pretty printer
    String_UTF8 betweenArgumentDivider;
    /// The text divider to emit for between sequential values
    String_UTF8 betweenValueDivider;

    ///
    uint depth;
    ///
    bool useQuotes;
    ///
    bool startWithoutPrefix;

export @safe nothrow @nogc:

    /// Some good defaults for a pretty printer
    static PrettyPrint defaults() {
        PrettyPrint ret;

        ret.prefixToRepeat = String_UTF8("\t");
        ret.prefixSuffix = String_UTF8("- ");
        ret.betweenArgumentDivider = String_UTF8(", ");
        ret.betweenValueDivider = String_UTF8(", ");

        return ret;
    }

    ///
    this(return scope ref PrettyPrint other) scope {
        this.tupleof = other.tupleof;
    }

    ///
    void opCall(Args...)(scope StringBuilder_UTF16 builder, scope Args args) {
        this.opCall(builder.byUTF8, args);
    }

    ///
    void opCall(Args...)(scope StringBuilder_UTF32 builder, scope Args args) {
        this.opCall(builder.byUTF8, args);
    }

    ///
    void opCall(Args...)(scope StringBuilder_UTF8 builder, scope Args args) @trusted {
        if(builder.length == 0 || builder.endsWith("\n"))
            this.handlePrefix(builder);

        foreach(i, ref arg; args) {
            if(i > 0 && !this.betweenArgumentDivider.isNull)
                builder ~= this.betweenArgumentDivider;

            this.handle(builder, arg, useQuotes);
        }
    }

    ///
    void emitPrefix(scope StringBuilder_UTF8 builder, bool useSuffix = false) {
        this.handlePrefix(builder, false, true, useSuffix);
    }

    /*private:*/
    import sidero.base.traits;
    import sidero.base.text.format.write;

    enum haveToString(T) = __traits(hasMember, T, "toString") && (__traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                value.toString(builder);
            }) || __traits(compiles, { StringBuilder_UTF8 builder; T value; builder ~= value.toString(); }) || __traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                value.toString(&builder.put);
            }));

    enum haveToStringPretty(T) = __traits(hasMember, T, "toStringPretty") && (__traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                PrettyPrint pp;
                value.toStringPretty(builder, pp);
            }) || __traits(compiles, { StringBuilder_UTF8 builder; T value; value.toStringPretty(builder); }) || __traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                PrettyPrint pp;
                builder ~= value.toStringPretty(pp);
            }) || __traits(compiles, { StringBuilder_UTF8 builder; T value; builder ~= value.toStringPretty(); }) || __traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                PrettyPrint pp;
                value.toStringPretty(&builder.put, pp);
            }) || __traits(compiles, { StringBuilder_UTF8 builder; T value; value.toStringPretty(&builder.put); }));

    void handlePrefix(scope StringBuilder_UTF8 builder, bool onlyRepeat = false, bool usePrefix = true, bool useSuffix = true) {
        if(this.startWithoutPrefix) {
            this.startWithoutPrefix = false;
            return;
        }

        if(!onlyRepeat && usePrefix)
            builder ~= this.prefix;

        if(!this.prefixToRepeat.isNull) {
            foreach(i; 0 .. this.depth) {
                builder ~= this.prefixToRepeat;
            }
        }

        if(!onlyRepeat && useSuffix)
            builder ~= this.prefixSuffix;
    }

    void handle(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useQuotes = true, bool useName = true,
            bool forcePrint = false) @trusted {
        import sidero.base.text.format.rawwrite;

        alias ActualType = Unqual!Type;

        static if(is(ActualType == Type)) {
            static if(__traits(compiles, hasUDA!(ActualType, PrettyPrintIgnore))) {
                if(!forcePrint && hasUDA!(ActualType, PrettyPrintIgnore))
                    return;
            }

            if(builder.endsWith(")") || builder.endsWith("]")) {
                if(!this.betweenValueDivider.isNull)
                    builder ~= this.betweenValueDivider;
            }

            static if(isSomeString!ActualType) {
                handleStringSlice(builder, input, useQuotes);
            } else static if(isReadOnlyString!ActualType || isBuilderString!ActualType) {
                handleString(builder, input, useQuotes);
            } else static if(isStaticArray!ActualType && (isSomeString!(typeof(ActualType.init[])))) {
                auto temp = input[];
                this.handle(builder, temp, useQuotes, useName, forcePrint);
            } else static if(isFunctionPointer!ActualType) {
                handleFunctionPointer(builder, input);
            } else static if(isPointer!ActualType && __traits(compiles, typeof(*input))) {
                handlePointer(builder, input);
            } else static if(is(ActualType : Result!WrappedType, WrappedType) || is(ActualType : ResultReference!WrappedType, WrappedType)) {
                handleResult!WrappedType(builder, input, useQuotes, useName, forcePrint);
            } else static if(is(ActualType == struct) || is(ActualType == class)) {
                handleStructClass(builder, input, useQuotes, useName, forcePrint);
            } else static if(isArray!ActualType) {
                handleSlice(builder, input, useName);
            } else static if(isAssociativeArray!ActualType) {
                handleAA(builder, input, useName);
            } else static if(is(ActualType == enum)) {
                handleEnum(builder, input, useQuotes, useName, forcePrint);
            } else static if(is(ActualType == char) || is(ActualType == wchar) || is(ActualType == dchar)) {
                rawWrite(builder, input, FormatSpecifier.init, useQuotes);
            } else {
                builder.formattedWrite(""c, input);
            }
        } else {
            handle(builder, *cast(ActualType*)&input, useQuotes, useName, forcePrint);
        }
    }

    void handleStringSlice(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useQuotes = true) {
        if(input is null) {
            builder ~= "null"c;
            return;
        }

        if(useQuotes)
            builder ~= "\""c;

        size_t oldOffset = builder.length;
        builder ~= cast()input;
        builder[oldOffset .. $].escape(useQuotes ? '"' : 0);

        if(useQuotes)
            builder ~= "\""c;
    }

    void handleString(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useQuotes = true) {
        if(input.isNull) {
            builder ~= "null"c;
            return;
        }

        if(useQuotes)
            builder ~= "\""c;

        size_t oldOffset = builder.length;
        builder ~= cast()input;
        builder[oldOffset .. $].escape(useQuotes ? '"' : 0);

        if(useQuotes)
            builder ~= "\""c;
    }

    void handleFunctionPointer(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) {
        builder ~= Type.stringof;

        if(input is null) {
            builder ~= "@null"c;
            return;
        }

        static if(is(Type == function)) {
            builder.formattedWrite("@{:p}"c, cast(void*)input);
        } else static if(is(Type == delegate)) {
            builder.formattedWrite("@(ptr={:p}, funcptr={:p})"c, input.ptr, input.funcptr);
        }
    }

    void handlePointer(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) @trusted {
        alias SubType = typeof(*input);
        enum EntryName = __traits(fullyQualifiedName, SubType);

        builder ~= EntryName;

        if(input !is null) {
            static if(is(SubType == class) || isAssociativeArray!SubType || isDynamicArray!SubType) {
                if(*input is null) {
                    builder ~= "@null"c;
                } else {
                    static if(is(SubType == class) || isAssociativeArray!SubType) {
                        builder.formattedWrite("@{:p}", cast(void*)input);
                    } else static if(isArray!SubType) {
                        builder.formattedWrite("@{:p}", cast(void*)input.ptr);
                    }
                }
            }
        }

        static if(!(is(SubType == struct) || isBasicType!SubType))
            builder ~= "*"c;

        if(input is null)
            builder ~= "@null"c;
        else {
            builder.formattedWrite("@{:p}", cast(void*)input);

            static if(!is(SubType == void)) {
                builder ~= "("c;
                this.handle(builder, *input, true, false);
                builder ~= ")"c;
            }
        }
    }

    void handleResult(WrappedType, Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useQuotes,
            bool useName, bool forcePrint) {
        if(input && !input.isNull) {
            // ok print the thing

            static if(!is(WrappedType == void)) {
                if(input) {
                    this.handle(builder, input.get(), true, useName, forcePrint);
                }
                return;
            }
        }

        builder.formattedWrite(""c, input);
    }

    void handleStructClass(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useQuotes, bool useName, bool forcePrint) @trusted {
        import std.meta : Filter;

        static FQN = __traits(fullyQualifiedName, Type);
        static TypeIdentifierName = __traits(identifier, Type);

        if(useName) {
            builder ~= FQN;

            static if(is(Type == class)) {
                if(input is null)
                    builder ~= "@null"c;
                else
                    builder.formattedWrite("@{:p}", cast(void*)input);
            }
        }

        static if(is(Type == class)) {
            if(input is null)
                return;
        }

        builder ~= "("c;
        this.depth++;

        {
            bool isFirst = true;

            static foreach(name; FieldNameTuple!Type) {
                {
                    alias member = __traits(getMember, input, name);
                    enum accessible = __traits(getVisibility, member) != "private" && () {
                        bool ret = true;

                        foreach(attr; __traits(getAttributes, member)) {
                            if(is(attr == PrettyPrintIgnore))
                                ret = false;
                        }

                        return ret;
                    }();
                    bool ignore = !accessible;

                    static foreach(name2; FieldNameTuple!Type) {
                        {
                            alias member2 = __traits(getMember, input, name2);

                            if(name != name2) {
                                ignore = ignore || member.offsetof == member2.offsetof;
                            }
                        }
                    }

                    static if(accessible) {
                        if(!ignore) {
                            if(!isFirst)
                                builder ~= ", "c;
                            else
                                isFirst = false;

                            builder ~= "\n"c;

                            this.handlePrefix(builder, false, true, false);
                            builder ~= name;
                            builder ~= ": "c;
                            this.handle(builder, __traits(getMember, input, name), true);
                        }
                    }
                }
            }

            static if(is(Type == class)) {
                static foreach(i, Base; BaseClassesTuple!Type) {
                    handlePrefix(builder, false, true, false);
                    builder ~= "---- "c;
                    builder ~= __traits(fullyQualifiedName, Base);
                    builder ~= " ----\n"c;
                    isFirst = true;

                    static foreach(name; FieldNameTuple!Base) {
                        {
                            alias member = __traits(getMember, input, name);
                            enum accessible = __traits(getVisibility, member) != "private" && () {
                                bool ret = true;

                                foreach(attr; __traits(getAttributes, member)) {
                                    if(is(attr == PrettyPrintIgnore))
                                        ret = false;
                                }

                                return ret;
                            }();
                            bool ignore = !accessible;

                            static foreach(name2; FieldNameTuple!Type) {
                                {
                                    alias member2 = __traits(getMember, input, name2);

                                    if(name != name2) {
                                        ignore = ignore || member.offsetof == member2.offsetof;
                                    }
                                }
                            }

                            static if(accessible) {
                                if(!ignore) {
                                    if(!isFirst)
                                        builder ~= ", "c;
                                    else
                                        isFirst = false;

                                    builder ~= "\n";
                                    handlePrefix(builder, false, true, false);
                                    builder ~= name;
                                    builder ~= ": "c;
                                    handle(builder, __traits(getMember, input, name), true);
                                }
                            }
                        }
                    }
                }
            }
        }

        {
            bool isFirst = true;

            static foreach(name; FieldNameTuple!Type) {
                {
                    alias member = __traits(getMember, input, name);
                    enum accessible = __traits(getVisibility, member) != "private";
                    enum explicitIgnore = () {
                        bool ret = true;

                        foreach(attr; __traits(getAttributes, member)) {
                            if(is(attr == PrettyPrintIgnore))
                                ret = false;
                        }

                        return ret;
                    }();
                    bool ignore = !accessible, overload;

                    static foreach(name2; FieldNameTuple!Type) {
                        {
                            alias member2 = __traits(getMember, input, name2);

                            if(name != name2) {
                                ignore = ignore || member.offsetof == member2.offsetof;
                                overload = overload || member.offsetof == member2.offsetof;
                            }
                        }
                    }

                    static if(accessible && !explicitIgnore) {
                        if(ignore) {
                            if(isFirst) {
                                isFirst = false;
                                builder ~= "\n"c;

                                handlePrefix(builder, false, true, false);
                                builder ~= "---- ignoring ----"c;
                            } else
                                builder ~= ","c;

                            builder ~= "\n"c;
                            handlePrefix(builder, false, true, false);

                            if(accessible)
                                builder ~= "private "c;
                            if(overload)
                                builder ~= "union "c;

                            builder ~= name;
                        }
                    }
                }
            }

            static if(is(Type == class)) {
                static foreach(i, Base; BaseClassesTuple!Type) {
                    handlePrefix(builder, false, true, false);
                    builder ~= "---- "c;
                    builder ~= __traits(fullyQualifiedName, Base);
                    builder ~= " ----\n"c;
                    isFirst = true;

                    static foreach(name; FieldNameTuple!Base) {
                        {
                            alias member = __traits(getMember, input, name);
                            enum accessible = __traits(getVisibility, member) != "private";
                            enum explicitIgnore = () {
                                bool ret = true;

                                foreach(attr; __traits(getAttributes, member)) {
                                    if(is(attr == PrettyPrintIgnore))
                                        ret = false;
                                }

                                return ret;
                            }();
                            bool ignore = !accessible, overload;

                            static foreach(name2; FieldNameTuple!Type) {
                                {
                                    alias member2 = __traits(getMember, input, name2);

                                    if(name != name2) {
                                        ignore = ignore || member.offsetof == member2.offsetof;
                                        overload = overload || member.offsetof == member2.offsetof;
                                    }
                                }
                            }

                            static if(accessible && !explicitIgnore) {
                                if(ignore) {
                                    if(isFirst) {
                                        isFirst = false;
                                        builder ~= "\n"c;

                                        handlePrefix(builder, false, true, false);
                                        builder ~= "---- ignoring ----"c;
                                    } else
                                        builder ~= ","c;

                                    builder ~= "\n"c;
                                    handlePrefix(builder, false, true, false);

                                    if(accessible)
                                        builder ~= "private "c;
                                    if(overload)
                                        builder ~= "union "c;

                                    builder ~= name;
                                }
                            }
                        }
                    }
                }
            }
        }

        static if(isIterable!Type && (HaveNonStaticOpApply!Type || !__traits(hasMember, Type, "opApply"))) {
            if(builder.endsWith("("c))
                builder ~= "["c;
            else
                builder ~= " ["c;

            static if(__traits(compiles, {
                    foreach(key, value; input) {
                    }
                })) {
                foreach(k, v; input) {
                    builder ~= "\n"c;
                    handlePrefix(builder);

                    handle(builder, k);
                    builder ~= ": "c;

                    handle(builder, v);
                    builder ~= ","c;
                }
            } else static if(__traits(compiles, {
                    foreach(value; input) {
                    }
                })) {
                foreach(v; input) {
                    builder ~= "\n"c;
                    handlePrefix(builder);
                    handle(builder, v);
                    builder ~= ","c;
                }
            } else
                builder ~= "..."c;

            if(builder.endsWith(","c))
                builder.clobberInsert(builder.length - 1, "]"c);
            else
                builder ~= "]"c;
        }

        {
            bool hadToString;

            static if(haveToStringPretty!Type) {
                {
                    alias Symbols = __traits(getOverloads, Type, "toStringPretty");

                    static foreach(SymbolId; 0 .. Symbols.length) {
                        {
                            alias gotUDAs = Filter!(isDesiredUDA!PrettyPrintIgnore, __traits(getAttributes, Symbols[SymbolId]));

                            if(!hadToString) {
                                static if(gotUDAs.length == 0) {
                                    size_t offsetForToString = builder.length;

                                    PrettyPrint toCallPrettyPrint = this;
                                    toCallPrettyPrint.startWithoutPrefix = true;
                                    toCallPrettyPrint.depth++;
                                    toCallPrettyPrint.useQuotes = true;

                                    static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(builder, toCallPrettyPrint))) {
                                        __traits(child, input, Symbols[SymbolId])(builder, toCallPrettyPrint);
                                        hadToString = true;
                                    } else static if(__traits(compiles, __traits(child, input,
                                            Symbols[SymbolId])(&builder.put, toCallPrettyPrint))) {
                                        __traits(child, input, Symbols[SymbolId])(&builder.put, toCallPrettyPrint);
                                        hadToString = true;
                                    } else static if(__traits(compiles, builder ~= __traits(child, input,
                                            Symbols[SymbolId])(toCallPrettyPrint))) {
                                        builder ~= __traits(child, input, Symbols[SymbolId])(toCallPrettyPrint);
                                        hadToString = true;
                                    } else static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(builder))) {
                                        __traits(child, input, Symbols[SymbolId])(builder);
                                        hadToString = true;
                                    } else static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(&builder.put))) {
                                        __traits(child, input, Symbols[SymbolId])(&builder.put);
                                        hadToString = true;
                                    } else static if(__traits(compiles, builder ~= __traits(child, input, Symbols[SymbolId])())) {
                                        builder ~= __traits(child, input, Symbols[SymbolId])();
                                        hadToString = true;
                                    }

                                    if(hadToString && builder.length > offsetForToString) {
                                        auto prior = builder[0 .. offsetForToString], subset = builder[offsetForToString .. $];

                                        if(subset == FQN) {
                                            builder.remove(offsetForToString, ptrdiff_t.max);
                                        } else if(subset.startsWith(TypeIdentifierName)) {
                                            builder.remove(offsetForToString, TypeIdentifierName.length);

                                            if(subset.startsWith("(")) {
                                                builder.remove(offsetForToString, 1);

                                                if(subset.endsWith(")"))
                                                    subset.remove(-1, 1);
                                            } else if(subset.startsWith("@")) {
                                                prior.remove(-1, 1);

                                                if(subset.endsWith(")"))
                                                    subset.remove(-1, 1);
                                            }
                                        } else if(subset.startsWith(", "c)) {
                                            builder.remove(offsetForToString, 1);
                                            builder.insert(offsetForToString + 1, "->\n"c);
                                        } else if(subset.contains("\n") || subset.length > 40) {
                                            // forty was chosen mostly at random,
                                            // but its half a lot of max line lengths (80) so can't be too bad
                                            builder.insert(offsetForToString, "->\n"c);
                                        } else if(!prior.endsWith("("c)) {
                                            builder.insert(offsetForToString, " ->\n"c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            static if(haveToString!Type) {
                {
                    alias Symbols = __traits(getOverloads, Type, "toString");

                    static foreach(SymbolId; 0 .. Symbols.length) {
                        {
                            alias gotUDAs = Filter!(isDesiredUDA!PrettyPrintIgnore, __traits(getAttributes, Symbols[SymbolId]));

                            if(!hadToString) {
                                static if(gotUDAs.length == 0) {
                                    size_t offsetForToString = builder.length;

                                    static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(builder))) {
                                        __traits(child, input, Symbols[SymbolId])(builder);
                                        hadToString = true;
                                    } else static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(&builder.put))) {
                                        __traits(child, input, Symbols[SymbolId])(&builder.put);
                                        hadToString = true;
                                    } else static if(__traits(compiles, builder ~= __traits(child, input, Symbols[SymbolId])())) {
                                        builder ~= __traits(child, input, Symbols[SymbolId])();
                                        hadToString = true;
                                    }

                                    if(hadToString && builder.length > offsetForToString) {
                                        auto prior = builder[0 .. offsetForToString], subset = builder[offsetForToString .. $];

                                        if(subset == FQN) {
                                            builder.remove(offsetForToString, ptrdiff_t.max);
                                        } else if(subset.startsWith(TypeIdentifierName)) {
                                            builder.remove(offsetForToString, TypeIdentifierName.length);

                                            if(subset.startsWith("(")) {
                                                builder.remove(offsetForToString, 1);

                                                if(subset.endsWith(")"))
                                                    subset.remove(-1, 1);
                                            } else if(subset.startsWith("@")) {
                                                prior.remove(-1, 1);

                                                if(subset.endsWith(")"))
                                                    subset.remove(-1, 1);
                                            }
                                        } else if(subset.contains("\n"c) || subset.length > 60) {
                                            // sixty was chosen mostly at random,
                                            // but its half a lot of max line lengths (80) so can't be too bad
                                            builder.insert(offsetForToString, "->\n"c);
                                        } else if(!prior.endsWith("("c)) {
                                            builder.insert(offsetForToString, " ->\n"c);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        this.depth--;

        if(builder.endsWith(","c))
            builder.clobberInsert(builder.length - 1, ")"c);
        else
            builder ~= ")"c;
    }

    void handleSlice(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName) @trusted {
        alias SubType = Unqual!(typeof(input[0]));
        enum EntryName = __traits(fullyQualifiedName, SubType);
        this.handlePrefix(builder);

        if(useName) {
            builder ~= EntryName;

            static if(isDynamicArray!Type) {
                if(input is null)
                    builder ~= "@null"c;
                else
                    builder.formattedWrite("@{:p}", cast(void*)input.ptr);
            }
        }

        static if(!is(SubType == void)) {
            builder ~= "[\n"c;
            this.depth++;

            foreach(i, ref entry; input) {
                if(i > 0 && !this.betweenValueDivider.isNull) {
                    builder ~= this.betweenValueDivider;
                    builder ~= "\n"c;
                }

                handlePrefix(builder);
                this.handle(builder, entry, true, true, true);
            }

            this.depth--;
            builder ~= "]"c;
        } else {
            builder ~= "=0x"c;
            auto temp = cast()input[];

            if(temp.length <= 20) {
                // fairly random number (40) / 2

                while(temp.length > 0) {
                    builder.formattedWrite("{:.2X}", *cast(const(ubyte)*)&temp[0]);
                    temp = temp[1 .. $];
                }
            } else {
                size_t count;
                this.depth++;

                builder ~= "\n"c;
                handlePrefix(builder);

                while(temp.length > 0) {
                    if(count == 20) {
                        count = 0;
                        builder ~= "\n"c;
                        handlePrefix(builder);
                    } else
                        count++;

                    builder.formattedWrite("{:.2X}", *cast(const(ubyte)*)&temp[0]);
                    temp = temp[1 .. $];
                }

                this.depth--;
            }
        }
    }

    void handleAA(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName) {
        alias Key = KeyType!Type;
        alias Value = ValueType!Type;
        enum KeyName = __traits(fullyQualifiedName, Key);
        enum ValueName = __traits(fullyQualifiedName, Value);

        enum EntryName = ValueName ~ "[" ~ KeyName ~ "]";

        if(useName) {
            builder ~= EntryName;
            builder.formattedWrite("@{:p}"c, cast(void*)input);
        }

        builder ~= "[\n"c;
        this.depth++;

        version(D_BetterC) {
        } else {
            try {
                foreach(key, ref value; input) {
                    handlePrefix(builder);
                    this.handle(key, true, true, true);
                    builder ~= ": "c;

                    this.handle(value, true, true, true);
                    builder ~= "\n"c;
                }
            } catch(Exception) {
            }
        }

        this.depth--;
        builder ~= "]"c;
    }

    void handleEnum(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useQuotes, bool useName, bool forcePrint) {
        enum FQN = __traits(fullyQualifiedName, Type);
        builder ~= FQN;
        auto actualValue = cast(OriginalType!Type)input;

        static foreach(m; __traits(allMembers, Type)) {
            if(__traits(getMember, Type, m) == input) {
                builder ~= "."c;
                builder ~= m;
                return;
            }
        }

        builder ~= "("c;
        this.handle(builder, actualValue, useQuotes, useName, forcePrint);
        builder ~= ")"c;
    }
}
