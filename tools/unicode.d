#!/usr/bin/env dub
/+ dub.sdl:
	name "unicode_builder"
+/
module tools.unicode;

void main() {
    import std.file : readText;

    string readOnlyText = readText("source/sidero/base/text/unicode/readonly.d");
    string builderText = readText("source/sidero/base/text/unicode/builder.d");

    readOnlyText.processFile("readonly", "String_UTF", "readonly_utf8", "String_UTF8", "char");
    readOnlyText.processFile("readonly", "String_UTF", "readonly_utf16", "String_UTF16", "wchar");
    readOnlyText.processFile("readonly", "String_UTF", "readonly_utf32", "String_UTF32", "dchar");
    builderText.processFile("builder", "StringBuilder_UTF", "builder_utf8", "StringBuilder_UTF8", "char");
    builderText.processFile("builder", "StringBuilder_UTF", "builder_utf16", "StringBuilder_UTF16", "wchar");
    builderText.processFile("builder", "StringBuilder_UTF", "builder_utf32", "StringBuilder_UTF32", "dchar");
}

void processFile(string originalText, string originalModuleName, string originalTypeName, string moduleName,
        string typeName, string charName) {
    import std.array : replace;
    import std.file : write;

    string result = originalText.replace("sidero.base.text.unicode." ~ originalModuleName, "sidero.base.text.unicode." ~ moduleName)
        .replace("Char = char", "Char = " ~ charName).replace(originalTypeName ~ "!char", originalTypeName ~ "8")
        .replace(originalTypeName ~ "!wchar", originalTypeName ~ "16").replace(originalTypeName ~ "!dchar",
                originalTypeName ~ "32").replace("struct " ~ originalTypeName, "struct " ~ typeName);

    write("imports/sidero/base/text/unicode/" ~ moduleName ~ ".d", result);
}
