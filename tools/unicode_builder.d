#!/usr/bin/env dub
/+ dub.sdl:
	name "unicode_builder"
+/
module tools.unicode_builder;

string originalText;

void main() {
    import std.file : readText;

    originalText = readText("source/sidero/base/text/unicode/builder.d");

    processFile("builder_utf8", "StringBuilder_UTF8", "char");
    processFile("builder_utf16", "StringBuilder_UTF16", "wchar");
    processFile("builder_utf32", "StringBuilder_UTF32", "dchar");
}

void processFile(string moduleName, string typeName, string charName) {
    import std.array : replace;
    import std.file : write;

    string result = originalText.replace("sidero.base.text.unicode.builder", "sidero.base.text.unicode." ~ moduleName)
        .replace("Char = char", "Char = " ~ charName).replace("StringBuilder_UTF!char",
                "StringBuilder_UTF8").replace("StringBuilder_UTF!wchar", "StringBuilder_UTF16").replace("StringBuilder_UTF!dchar",
                "StringBuilder_UTF32").replace("struct StringBuilder_UTF", "struct " ~ typeName);

    write("imports/sidero/base/text/unicode/" ~ moduleName ~ ".d", result);
}
