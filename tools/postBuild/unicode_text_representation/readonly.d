module unicode_text_representation.readonly;
import constants;

void generateUnicodeReadOnly() {
    generateForFile("readonly_utf8");
    generateForFile("readonly_utf16");
    generateForFile("readonly_utf32");
}

private:

void generateForFile(string filename) {
    import std.file : write, readText;
    import std.regex;
    import std.array : replace;

    string text = readText(GeneratedImportsDirectory ~ filename ~ ".di");
    // [^\{]*\{     [^\}]*\}
    {
        auto r = regex(r"[^\n]*opApplyImpl" ~ r"[^\{]*\{[^\{]*\{[^\{]*\{[^\}]*\}" ~ r"[^\{]*\{[^\}]*\}[^\}]*\}" ~
                r"[^\{]*\{[^\}]*\}" ~ r"[^\{]*\{[^\}]*\}[^\}]*\}" ~ r"\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);

        r = regex(r"[^\n]*opApplyReverseImpl" ~ r"[^\{]*\{[^\{]*\{[^\{]*\{[^\}]*\}" ~ r"[^\{]*\{[^\}]*\}[^\}]*\}" ~
                r"[^\{]*\{[^\}]*\}" ~ r"[^\{]*\{[^\}]*\}[^\}]*\}" ~ r"\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);
    }

    {
        auto r = regex(r"[^\n]*struct Iterator" ~ r"[^\{]*\{[^\{]*\{[^\{]*\{" ~ r"[^\}]*\}[^\}]*\}[^\}]*\}" ~ r"\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);

        text = text.replace("Iterator*", "size_t");

        r = regex(r"[^\n]*setupIterator" ~ r"[^\{]*\{[^\}]*\}" ~ r"\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);
    }

    {
        auto r = regex(r"[^\n]*struct LifeTime" ~ r"[^\{]*\{[^\}]*\}" ~ r"\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);

        text = text.replace("LifeTime*", "size_t");

        r = regex(r"[^\n]*initForLiteral" ~ r"[^\{]*\{[^\{]*\{[^\{]*\{[^\}]*\}" ~
                r"[^\{]*\{[^\{]*\{[^\{]*\{[^\}]*\}[^\}]*\}[^\}]*\}" ~ r"[^\{]*\{[^\}]*\}[^\}]*\}[^\}]*\}" ~ r"\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);
    }

    {
        text = text.replace("scope scope", "scope");
        text = text.replace("scope @disable const scope", "scope @disable const");
    }

    write(OutputUnicodeDirectory ~ filename ~ ".di", text);
}
