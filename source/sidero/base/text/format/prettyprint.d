module sidero.base.text.format.prettyprint;
import sidero.base.text;
import sidero.base.errors;
import sidero.base.traits;
import sidero.base.attributes;

unittest {
    import sidero.base.allocators;

    StringBuilder_UTF8 builder = StringBuilder_UTF8(RCAllocator.init);
    PrettyPrint pp = PrettyPrint.defaults;

    int[] array = [1, 2, 3];
    string str = "abc";
    void function() funcptr;
    void delegate() del;

    int i = 42;
    int* iptr = &i;

    Result!int r = 2;

    int[int] aa;
    aa[1] = 99;

    enum E {
        A,
        B
    }

    struct S1 {
        int field;
        E e;
    }

    class C1 {
        int field;
        E e;
    }

    struct S2 {
        int field;

        union {
            int o1;
            bool o2;
        }
    }

    class C2 {
        int afield;

        union {
            int o1;
            bool o2;
        }
    }

    class C3 : C2 {
        int achildfield;
    }

    static struct S3 {
        float f = 0;

        int opApply(scope int delegate(int) @safe nothrow @nogc del) @safe nothrow @nogc {
            return del(2);
        }
    }

    static struct S4 {
        int thing;

    @safe nothrow @nogc:

        string toString() scope {
            return "S4(Hello!)";
        }
    }

    static struct S5 {
        bool var;

    @safe nothrow @nogc:

        void toStringPretty(StringBuilder_UTF8 builder, PrettyPrint pp) scope {
            pp.emitPrefix(builder);
            builder ~= "S5(stuff)";
        }
    }

    E e;
    S1 s1;
    C1 c1 = new C1;
    S2 s2;
    C3 c3 = new C3;
    S3 s3;
    S4 s4;
    S5 s5;

    pp(builder, array, str, funcptr, del, iptr, r, aa, e, s1, c1, s2, c3, s3, s4, s5);
}

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
    /// The text divider to emit for between sequential values
    String_UTF8 betweenValueDivider;

    ///
    uint depth;
    ///
    bool useInitialTypeName;
    ///
    bool startWithoutPrefix;
    ///
    bool startWithoutThePrefixSuffix;

export @safe nothrow @nogc:

    /// Some good defaults for a pretty printer
    static PrettyPrint defaults() {
        PrettyPrint ret;

        ret.prefixToRepeat = String_UTF8("    ");
        ret.prefixSuffix = String_UTF8("- ");
        ret.betweenValueDivider = String_UTF8(", ");
        ret.useInitialTypeName = true;

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
        foreach(i, ref arg; args) {
            if(i > 0) {
                if(!this.betweenValueDivider.isNull)
                    builder ~= this.betweenValueDivider;

                builder ~= "\n";
            }

            this.handle(builder, arg, this.useInitialTypeName);
        }
    }

    ///
    void emitPrefix(scope StringBuilder_UTF8 builder, bool useSuffix = false) {
        this.handlePrefix(builder, false, true, useSuffix);
    }

private:
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
            }) || __traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                PrettyPrint pp;
                builder ~= value.toStringPretty(pp);
            }) || __traits(compiles, {
                StringBuilder_UTF8 builder;
                T value;
                PrettyPrint pp;
                value.toStringPretty(&builder.put, pp);
            }));

    void handlePrefix()(scope StringBuilder_UTF8 builder, bool onlyRepeat = false, bool usePrefix = true, bool useSuffix = true) {
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

        if(startWithoutThePrefixSuffix)
            startWithoutThePrefixSuffix = false;
        else if(!onlyRepeat && useSuffix)
            builder ~= this.prefixSuffix;
    }

    void handle(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName = true, bool forcePrint = false) @trusted {
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

            static if(isAnyString!ActualType) {
                handleString(builder, input);
            } else static if(isStaticArray!ActualType && (isSomeString!(typeof(ActualType.init[])))) {
                auto temp = input[];
                this.handle(builder, temp, useName, forcePrint);
            } else static if(isFunctionPointer!ActualType || isDelegate!ActualType) {
                handleFunctionPointer(builder, input);
            } else static if(isPointer!ActualType && __traits(compiles, typeof(*input))) {
                handlePointer(builder, input);
            } else static if(is(ActualType : Result!WrappedType, WrappedType) || is(ActualType : ResultReference!WrappedType, WrappedType)) {
                handleResult!WrappedType(builder, input, useName, forcePrint);
            } else static if(is(ActualType == struct) || is(ActualType == class)) {
                handleStructClass(builder, input, useName, forcePrint);
            } else static if(isArray!ActualType) {
                handleSlice(builder, input, useName);
            } else static if(isAssociativeArray!ActualType) {
                handleAA(builder, input, useName);
            } else static if(is(ActualType == enum)) {
                handleEnum(builder, input, useName, forcePrint);
            } else static if(is(ActualType == char) || is(ActualType == wchar) || is(ActualType == dchar)) {
                rawWrite(builder, input, FormatSpecifier.init);
            } else {
                this.handlePrefix(builder, false, true, true);
                builder.formattedWrite(""c, input);
            }
        } else {
            handle(builder, *cast(ActualType*)&input, useName, forcePrint);
        }
    }

    void handleString(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) {
        this.handlePrefix(builder);
        builder ~= "\""c;

        size_t oldOffset = builder.length;
        builder ~= cast()input;
        builder[oldOffset .. $].escape('"');

        static if(isUTF8!Type)
            builder ~= "\"c"c;
        else static if(isUTF16!Type)
            builder ~= "\"w"c;
        else static if(isUTF32!Type)
            builder ~= "\"d"c;
        else
            builder ~= "\""c;
    }

    void handleFunctionPointer(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) @trusted {
        enum FQN = __traits(fullyQualifiedName, Type);

        this.handlePrefix(builder);
        builder ~= "(" ~ FQN;

        static if(isFunctionPointer!Type) {
            builder.formattedWrite(")@{:p}"c, cast(void*)input);
        } else if(input.ptr is input.funcptr) {
            builder.formattedWrite(")@{:p}"c, input.ptr);
        } else {
            builder.formattedWrite(")@{:p}:{:p}"c, input.ptr, input.funcptr);
        }
    }

    void handlePointer(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) @trusted {
        alias SubType = typeof(*input);
        enum EntryName = __traits(fullyQualifiedName, SubType);

        this.handlePrefix(builder);
        builder ~= EntryName;

        static if(isArray!Type) {
            builder.formattedWrite("@{:p}", cast(void*)input.ptr);
        } else {
            builder.formattedWrite("@{:p}", cast(void*)input);
        }

        if (input !is null) {
            static if(!is(SubType == void)) {
                builder ~= "("c;
                this.startWithoutPrefix = true;
                this.handle(builder, *input, true);
                builder ~= ")"c;
            }
        }
    }

    void handleResult(WrappedType, Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName, bool forcePrint) {
        if(input && !input.isNull) {
            // ok print the thing

            static if(!is(WrappedType == void)) {
                if(input) {
                    this.handle(builder, input.get(), useName, forcePrint);
                }

                return;
            }
        }

        this.handlePrefix(builder);
        builder.formattedWrite(""c, input);
    }

    void handleStructClass(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName, bool forcePrint) @trusted {
        enum FQN = __traits(fullyQualifiedName, Type);
        enum TypeIdentifierName = __traits(identifier, Type);

        this.handlePrefix(builder);

        if(useName) {
            builder ~= FQN;

            static if(is(Type == class)) {
                builder.formattedWrite("@{:p}", cast(void*)input);
            }
        }

        static if(is(Type == class)) {
            if(input is null)
                return;
        }

        builder ~= "("c;
        this.depth++;

        enum CanIterate = isIterable!Type && (HaveNonStaticOpApply!Type || !__traits(hasMember, Type, "opApply"));
        enum HaveToString = haveToString!Type;
        enum HaveToStringPretty = haveToStringPretty!Type;

        static if(HaveToStringPretty) {
            handleStructClassToString!true(builder, input, false);
        } else {
            bool hadAField = handleStructClassFields(builder, input);
            hadAField = handleStructClassOverlappedFields(builder, input) || hadAField;

            static if(HaveToString) {
                handleStructClassToString!false(builder, input, hadAField);
            }

            static if(CanIterate) {
                static if(__traits(compiles, {
                        foreach(key, value; input) {
                        }
                    })) {
                    foreach(k, v; input) {
                        if(i == 0) {
                            builder ~= "\n";
                            this.handlePrefix(builder, false, true, false);
                            builder ~= "[...]"c;

                        } else if(i > 0)
                            builder ~= this.betweenValueDivider;
                        i++;

                        builder ~= "\n"c;

                        handle(builder, k);
                        builder ~= ": "c;

                        handle(builder, v);
                        builder ~= this.betweenValueDivider;
                    }
                } else static if(__traits(compiles, {
                        foreach(value; input) {
                        }
                    })) {
                    size_t i;

                    foreach(v; input) {
                        if(i == 0) {
                            builder ~= "\n";
                            this.handlePrefix(builder, false, true, false);
                            builder ~= "[...]"c;

                        } else if(i > 0)
                            builder ~= this.betweenValueDivider;
                        i++;

                        builder ~= "\n"c;
                        handle(builder, v);
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

    bool handleStructClassFields(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) {
        bool isFirst = true;
        bool hadAField;

        enum IsFieldAccessible(Type2, string name, string[] FieldNames) = __traits(getVisibility, __traits(getMember, input, name)) != "private" && () {
            alias member = __traits(getMember, cast(Type)input, name);
            bool accessible = true;

            foreach(attr; __traits(getAttributes, member)) {
                if(is(attr == PrettyPrintIgnore))
                    accessible = false;
            }

            if(accessible) {
                static foreach(name2; FieldNames) {
                    {
                        alias member2 = __traits(getMember, cast(Type)input, name2);

                        if(name != name2)
                            accessible = accessible && member.offsetof != member2.offsetof;
                    }
                }
            }

            return accessible;
        }();

        void handleField(Type2, string name)() @trusted {
            if(!isFirst)
                builder ~= this.betweenValueDivider;
            else
                isFirst = false;

            builder ~= "\n"c;
            this.handlePrefix(builder, false, true, false);
            builder ~= name;
            builder ~= ": "c;

            this.startWithoutPrefix = true;
            this.handle(builder, __traits(getMember, cast(Type2)input, name));
            this.startWithoutPrefix = false;

            hadAField = true;
        }

        {
            enum FieldNames = [FieldNameTuple!Type];

            static foreach(name; FieldNames) {
                if(IsFieldAccessible!(Type, name, FieldNames))
                    handleField!(Type, name)();
            }
        }

        static if(is(Type == class)) {
            static foreach(i, Base; BaseClassesTuple!Type) {
                builder ~= "\n";
                handlePrefix(builder, false, true, false);
                builder ~= "---- "c;
                builder ~= __traits(fullyQualifiedName, Base);
                builder ~= " ----"c;
                isFirst = true;

                {
                    this.depth++;
                    enum FieldNames = [FieldNameTuple!Base];

                    static foreach(name; FieldNames) {
                        if(IsFieldAccessible!(Base, name, FieldNames))
                            handleField!(Base, name)();
                    }

                    this.depth--;
                }
            }
        }

        return hadAField;
    }

    bool handleStructClassOverlappedFields(Type)(scope StringBuilder_UTF8 builder, scope ref Type input) {
        bool isFirst = true, isFirstOfType = true;
        bool hadAField;

        enum IsFieldIgnored(Type2, string name) = () {
            alias member = __traits(getMember, cast(Type2)input, name);
            const isPrivate = __traits(getVisibility, member) == "private";
            bool ignored = false;

            foreach(attr; __traits(getAttributes, member)) {
                if(is(attr == PrettyPrintIgnore))
                    ignored = true;
            }

            return [ignored, isPrivate];
        }();

        enum IsFieldOverlapped(Type2, string name, string[] FieldNames) = __traits(getVisibility, __traits(getMember, input, name)) != "private" && () {
            alias member = __traits(getMember, cast(Type2)input, name);

            static foreach(name2; FieldNames) {
                if(name != name2 && member.offsetof == __traits(getMember, cast(Type2)input, name2).offsetof)
                    return true;
            }

            return false;
        }();

        void handleField(Type2, string name)(bool ignored, bool overlapped) @trusted {
            alias member = __traits(getMember, cast(Type2)input, name);
            enum FQN = __traits(fullyQualifiedName, typeof(member));

            if(isFirst) {
                isFirst = false;

                builder ~= "\n";
                this.handlePrefix(builder, false, true, false);
                builder ~= "==== ignoring ===="c;
            }

            if(!isFirstOfType) {
                builder ~= this.betweenValueDivider;
            } else {
                isFirstOfType = false;

                this.depth++;

                builder ~= "\n";
                handlePrefix(builder, false, true, false);
                builder ~= "---- "c;
                builder ~= __traits(fullyQualifiedName, Type2);
                builder ~= " ----"c;

                this.depth--;
            }

            {
                hadAField = true;

                this.depth += 2;

                builder ~= "\n";
                this.handlePrefix(builder, false, true, false);

                if(ignored)
                    builder ~= "private "c;

                if(overlapped)
                    builder.formattedWrite("union@{:d} ", member.offsetof);

                builder ~= name;
                builder ~= " " ~ FQN;

                this.depth -= 2;
            }
        }

        {
            enum FieldNames = [FieldNameTuple!Type];

            static foreach(name; FieldNames) {
                {
                    enum ignored = IsFieldIgnored!(Type, name);
                    enum overlapped = IsFieldOverlapped!(Type, name, FieldNames);

                    static if((ignored[0] && !ignored[1]) || overlapped) {
                        handleField!(Type, name)(ignored[0], overlapped);
                    }
                }
            }
        }

        static if(is(Type == class)) {
            static foreach(i, Base; BaseClassesTuple!Type) {
                isFirstOfType = true;

                {
                    enum FieldNames = [FieldNameTuple!Base];

                    static foreach(name; FieldNames) {
                        {
                            enum ignored = IsFieldIgnored!(Base, name);
                            enum overlapped = IsFieldOverlapped!(Base, name, FieldNames);

                            static if((ignored[0] && !ignored[1]) || overlapped) {
                                handleField!(Base, name)(ignored[0], overlapped);
                            }
                        }
                    }
                }
            }
        }

        return hadAField;
    }

    void handleStructClassToString(bool IsPretty, Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool hadFields) @trusted {
        import std.meta : Filter;

        static FQN = __traits(fullyQualifiedName, Type);
        static TypeIdentifierName = __traits(identifier, Type);

        enum ToStringName = IsPretty ? "toStringPretty" : "toString";
        alias Symbols = __traits(getOverloads, Type, ToStringName);

        void cleanup(size_t offsetForToString) {
            auto before = builder[0 .. offsetForToString], after = builder[offsetForToString .. $];

            if(after.startsWith(FQN)) {
                builder.remove(offsetForToString, ptrdiff_t.max);
            } else if(after.startsWith(TypeIdentifierName)) {
                builder.remove(offsetForToString, TypeIdentifierName.length);
            }

            if(after.startsWith("(")) {
                builder.remove(offsetForToString, 1);

                if(after.endsWith(")"))
                    after.remove(-1, 1);
            }

            if(hadFields) {
                const startBuilderLength = builder.length;

                before ~= ",\n";
                this.handlePrefix(before, false, true, false);
                before ~= ":: text ::\n";

                this.handlePrefix(before, false, true, false);
            }
        }

        static foreach(SymbolId; 0 .. Symbols.length) {
            {
                alias gotUDAs = Filter!(isDesiredUDA!PrettyPrintIgnore, __traits(getAttributes, Symbols[SymbolId]));
                bool gotOne = true;

                static if(gotUDAs.length == 0) {
                    const offsetForToString = builder.length;

                    static if(IsPretty) {
                        PrettyPrint toCallPrettyPrint = this;
                        toCallPrettyPrint.startWithoutPrefix = true;
                        toCallPrettyPrint.depth--;

                        static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(builder, toCallPrettyPrint))) {
                            __traits(child, input, Symbols[SymbolId])(builder, toCallPrettyPrint);
                        } else static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(&builder.put, toCallPrettyPrint))) {
                            __traits(child, input, Symbols[SymbolId])(&builder.put, toCallPrettyPrint);
                        } else static if(__traits(compiles, builder ~= __traits(child, input, Symbols[SymbolId])(toCallPrettyPrint))) {
                            builder ~= __traits(child, input, Symbols[SymbolId])(toCallPrettyPrint);
                        } else
                            gotOne = false;
                    } else {
                        static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(builder))) {
                            __traits(child, input, Symbols[SymbolId])(builder);
                        } else static if(__traits(compiles, __traits(child, input, Symbols[SymbolId])(&builder.put))) {
                            __traits(child, input, Symbols[SymbolId])(&builder.put);
                        } else static if(__traits(compiles, builder ~= __traits(child, input, Symbols[SymbolId])())) {
                            builder ~= __traits(child, input, Symbols[SymbolId])();
                        } else
                            gotOne = false;
                    }

                    if(gotOne && builder.length > offsetForToString) {
                        cleanup(offsetForToString);
                        return;
                    }
                }
            }
        }
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

                this.handle(builder, entry, true, true);
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

    void handleAA(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName) @trusted {
        alias Key = KeyType!Type;
        alias Value = ValueType!Type;
        enum KeyName = __traits(fullyQualifiedName, Key);
        enum ValueName = __traits(fullyQualifiedName, Value);

        enum EntryName = ValueName ~ "[" ~ KeyName ~ "]";
        this.handlePrefix(builder);

        if(useName) {
            builder ~= EntryName;
            builder.formattedWrite("@{:p}"c, cast(void*)input);
        }

        builder ~= "[\n"c;
        this.depth++;

        version(D_BetterC) {
        } else {
            try {
                foreach(ref key, ref value; input) {
                    this.handle(builder, key, true, true);
                    builder ~= ": "c;

                    this.startWithoutPrefix = true;
                    this.handle(builder, value, true, true);
                }
            } catch(Exception) {
            }
        }

        this.startWithoutPrefix = false;
        this.depth--;
        builder ~= "]"c;
    }

    void handleEnum(Type)(scope StringBuilder_UTF8 builder, scope ref Type input, bool useName, bool forcePrint) {
        enum FQN = __traits(fullyQualifiedName, Type);
        auto actualValue = cast(OriginalType!Type)input;

        this.handlePrefix(builder);
        builder ~= FQN;

        static foreach(m; __traits(allMembers, Type)) {
            if(__traits(getMember, Type, m) == input) {
                builder ~= "."c;
                builder ~= m;
                return;
            }
        }

        builder ~= "("c;
        this.handle(builder, actualValue, useName, forcePrint);
        builder ~= ")"c;
    }
}
