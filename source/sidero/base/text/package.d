///
module sidero.base.text;
public import sidero.base.text.ascii.readonly;
public import sidero.base.text.ascii.builder;
public import sidero.base.text.unicode.readonly_utf8;
public import sidero.base.text.unicode.readonly_utf16;
public import sidero.base.text.unicode.readonly_utf32;
public import sidero.base.text.unicode.builder_utf8;
public import sidero.base.text.unicode.builder_utf16;
public import sidero.base.text.unicode.builder_utf32;
public import sidero.base.text.format;
public import sidero.base.text.processing;

///
alias String_UTF(Char : char) = String_UTF8;
///
alias String_UTF(Char : wchar) = String_UTF16;
///
alias String_UTF(Char : dchar) = String_UTF32;
///
alias StringBuilder_UTF(Char : char) = StringBuilder_UTF8;
///
alias StringBuilder_UTF(Char : wchar) = StringBuilder_UTF16;
///
alias StringBuilder_UTF(Char : dchar) = StringBuilder_UTF32;
