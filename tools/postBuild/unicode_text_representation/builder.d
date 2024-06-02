module unicode_text_representation.builder;
import constants;

void generateUnicodeBuilders() {
    generateForFile("builder_utf8");
    generateForFile("builder_utf16");
    generateForFile("builder_utf32");
}

private:

void generateForFile(string filename) {
    import std.file : write, readText;
    import std.regex;
    import std.array : replace;

    string text = readText(GeneratedImportsDirectory ~ filename ~ ".di");

    {
        auto r = regex(r"[^\n]*opApplyImpl[^\{]*\{[^\{]*\{[^\}]*\}[^\}]*\}\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);

        r = regex(r"[^\n]*opApplyReverseImpl[^\{]*\{[^\{]*\{[^\}]*\}[^\}]*\}\r?\n", "s");
        text = replaceAll!(capture => "")(text, r);
    }

    {
        text.replace("StateIterator state;", "size_t[2] state;");
        text.replace("import sidero.base.text.unicode.internal.builder;", "");
    }

    {
        text = text.replace("scope scope", "scope");
        text = text.replace("scope @nogc scope", "scope @nogc");
        text = text.replace("scope @disable const scope", "scope @disable const");
    }

    write(OutputUnicodeDirectory ~ filename ~ ".di", text);
}
