module sidero.base.text.format.escaping;
import sidero.base.text;
import sidero.base.attributes;

export @safe nothrow @nogc:

/// Escapes all of the standard escapes for ASCII and optionally do quotes (must provide as character literal as to which to use)
StringBuilder_ASCII escape(return scope StringBuilder_ASCII builder, char quote = 0) {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_ASCII builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Ditto
StringBuilder_UTF8 escape(return scope StringBuilder_UTF8 builder, dchar quote = 0) {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF8 builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Ditto
StringBuilder_UTF16 escape(return scope StringBuilder_UTF16 builder, dchar quote = 0) {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF16 builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Ditto
StringBuilder_UTF32 escape(return scope StringBuilder_UTF32 builder, dchar quote = 0) {
    return escapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF32 builder = "\\\0\a\b\f\n\r\t\v\"";
    builder.escape('"');
    assert(builder == "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"");
}

/// Unescapes all of the standard escapes for ASCII and optionally do quotes (must provide as character literal as to which to use)
StringBuilder_ASCII unescape(return scope StringBuilder_ASCII builder, char quote = 0) {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_ASCII builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

/// Ditto
StringBuilder_UTF8 unescape(return scope StringBuilder_UTF8 builder, dchar quote = 0) {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF8 builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

/// Ditto
StringBuilder_UTF16 unescape(return scope StringBuilder_UTF16 builder, dchar quote = 0) {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF16 builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

/// Ditto
StringBuilder_UTF32 unescape(return scope StringBuilder_UTF32 builder, dchar quote = 0) {
    return unescapeImpl(builder, quote);
}

///
unittest {
    StringBuilder_UTF32 builder = "\\\\\\0\\a\\b\\f\\n\\r\\t\\v\\\"";
    builder.unescape('"');
    assert(builder == "\\\0\a\b\f\n\r\t\v\"");
}

///
StringBuilder_ASCII quoteChar(return scope StringBuilder_ASCII builder, ubyte c) {
    quoteCharImpl(builder, c);
    return builder;
}

///
StringBuilder_UTF8 quoteChar(return scope StringBuilder_UTF8 builder, dchar c) {
    quoteCharImpl(builder, c);
    return builder;
}

///
StringBuilder_UTF16 quoteChar(return scope StringBuilder_UTF16 builder, dchar c) {
    quoteCharImpl(builder, c);
    return builder;
}

///
StringBuilder_UTF32 quoteChar(return scope StringBuilder_UTF32 builder, dchar c) {
    quoteCharImpl(builder, c);
    return builder;
}

private @hidden:
import sidero.base.traits;

Builder escapeImpl(Builder, Char)(return scope Builder builder, Char quote) @trusted {
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

Builder unescapeImpl(Builder, Char)(return scope Builder builder, Char quote) {
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

void quoteCharImpl(Builder, Char)(scope ref Builder output, Char c) {
    switch (c) {
        case '\\':
            output ~= "\\\\";
            break;

        case '\0':
            output ~= "\\0";
            break;

        case '\a':
            output ~= "\\a";
            break;

        case '\b':
            output ~= "\\b";
            break;

        case '\f':
            output ~= "\\f";
            break;

        case '\n':
            output ~= "\\n";
            break;

        case '\r':
            output ~= "\\r";
            break;

        case '\t':
            output ~= "\\t";
            break;

        case '\v':
            output ~= "\\v";
            break;
        default:
            output ~= [c];
            break;
    }
}
