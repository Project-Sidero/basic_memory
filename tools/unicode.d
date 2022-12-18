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
    import std.algorithm : countUntil, startsWith;
    import std.array : replace, appender;
    import std.file : write;

    string[] toFind = [
        "sidero.base.text.unicode." ~ originalModuleName,
        "Char = char",
        originalTypeName ~ "!char",
        originalTypeName ~ "!wchar",
        originalTypeName ~ "!dchar",
        "struct " ~ originalTypeName,
    ];
    string[] toReplace = [
        "sidero.base.text.unicode." ~ moduleName,
        "Char = " ~ charName,
        originalTypeName ~ "8",
        originalTypeName ~ "16",
        originalTypeName ~ "32",
        "struct " ~ typeName
    ];

    auto result = appender!string;
    result.reserve(1024 * 1024 * 8);

    while(originalText.length > 0) {
        string temp = originalText;

        ptrdiff_t index, matched = -1;

        foreach(i; 0 .. toFind.length) {
            index = temp.countUntil(toFind[i]);

            if (index > 0) {
                temp = temp[0 .. index];
                matched = i;
            }
        }

        result ~= temp;
        originalText = originalText[temp.length .. $];

        if (matched >= 0) {
            result ~= toReplace[matched];
            originalText = originalText[toFind[matched].length .. $];
        }
    }

    write("imports/sidero/base/text/unicode/" ~ moduleName ~ ".d", result.data);
}
