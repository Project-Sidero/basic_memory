///
module sidero.base.text;
public import sidero.base.text.ascii.readonly;
public import sidero.base.text.ascii.builder;
public import sidero.base.text.unicode.readonly;
public import sidero.base.text.unicode.builder;
public import sidero.base.text.format;

///
alias String_UTF8 = String_UTF!char;
///
alias String_UTF16 = String_UTF!wchar;
///
alias String_UTF32 = String_UTF!dchar;

///
alias StringBuilder_UTF8 = StringBuilder_UTF!char;
///
alias StringBuilder_UTF16 = StringBuilder_UTF!wchar;
///
alias StringBuilder_UTF32 = StringBuilder_UTF!dchar;
