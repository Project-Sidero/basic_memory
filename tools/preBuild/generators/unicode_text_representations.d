module generators.unicode_text_representations;
import constants;
import std.array : Appender;

void generateUnicodeTextRepresentations() {
    import std.file : readText, write;
    import std.parallelism : parallel;

    result.reserve(1024 * 1024 * 8);

    string readOnlyText = readText("tools/templates/sidero/base/text/unicode/readonly.d");
    string builderText = readText("tools/templates/sidero/base/text/unicode/builder.d");

    Work[] work = [
        Work(readOnlyText, "readonly", "String_UTF", "readonly_utf8", "String_UTF8", "char"),
        Work(readOnlyText, "readonly", "String_UTF", "readonly_utf16", "String_UTF16", "wchar"),
        Work(readOnlyText, "readonly", "String_UTF", "readonly_utf32", "String_UTF32", "dchar"),
        Work(builderText, "builder", "StringBuilder_UTF", "builder_utf8", "StringBuilder_UTF8", "char"),
        Work(builderText, "builder", "StringBuilder_UTF", "builder_utf16", "StringBuilder_UTF16", "wchar"),
        Work(builderText, "builder", "StringBuilder_UTF", "builder_utf32", "StringBuilder_UTF32", "dchar"),
    ];

    foreach(ref todo; work.parallel) {
        result.clear;

        todo.processFile;

        write(UnicodeAPIDirectory ~ todo.moduleName ~ ".d", result.data);
    }
}

private:

Appender!(char[]) result;

struct Work {
    string originalText, originalModuleName, originalTypeName, moduleName, typeName, charName;
}

void processFile(ref Work work) {
    import std.algorithm : countUntil, startsWith;
    import std.array : replace;

    string[] toFind = [
        "sidero.base.text.unicode." ~ work.originalModuleName, "Char = char", work.originalTypeName ~ "!Char",
        work.originalTypeName ~ "!char", work.originalTypeName ~ "!wchar", work.originalTypeName ~ "!dchar",
        "struct " ~ work.originalTypeName,
    ];
    string[] toReplace = [
        "sidero.base.text.unicode." ~ work.moduleName, "Char = " ~ work.charName, work.typeName,
        work.originalTypeName ~ "8", work.originalTypeName ~ "16", work.originalTypeName ~ "32", "struct " ~ work.typeName
    ];

    string originalText = work.originalText;

    while(originalText.length > 0) {
        string temp = originalText;

        ptrdiff_t index, matched = -1;

        foreach(i; 0 .. toFind.length) {
            index = temp.countUntil(toFind[i]);

            if(index > 0) {
                temp = temp[0 .. index];
                matched = i;
            }
        }

        result ~= temp;
        originalText = originalText[temp.length .. $];

        if(matched >= 0) {
            result ~= toReplace[matched];
            originalText = originalText[toFind[matched].length .. $];
        }
    }
}
