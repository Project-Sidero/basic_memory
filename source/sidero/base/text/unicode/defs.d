module sidero.base.text.unicode.defs;
import sidero.base.errors.message;

///
struct UnicodeEncoding {
    int codepointSize;

    ///
    enum UTF8 = UnicodeEncoding(8);
    ///
    enum UTF16 = UnicodeEncoding(16);
    ///
    enum UTF32 = UnicodeEncoding(32);

    ///
    enum For(T : char) = UTF8;
    ///
    enum For(T : string) = UTF8;
    ///
    enum For(T : char[]) = UTF8;
    ///
    enum For(T : const(char)[]) = UTF8;

    ///
    enum For(T : wchar) = UTF16;
    ///
    enum For(T : wstring) = UTF16;
    ///
    enum For(T : wchar[]) = UTF16;
    ///
    enum For(T : const(wchar)[]) = UTF16;

    ///
    enum For(T : dchar) = UTF32;
    ///
    enum For(T : dstring) = UTF32;
    ///
    enum For(T : dchar[]) = UTF32;
    ///
    enum For(T : const(dchar)[]) = UTF32;

scope const:

    ///
    auto handle(T, U, V)(scope T utf8Del, scope U utf16Del, scope V utf32Del) {
        assert(utf8Del !is null);
        assert(utf16Del !is null);
        assert(utf32Del !is null);

        if (codepointSize == 8)
            return utf8Del();
        else if (codepointSize == 16)
            return utf16Del();
        else if (codepointSize == 32)
            return utf32Del();
        else static if (!is(typeof(return) == void))
            return typeof(return).init;
    }

    ///
    auto handle(T, U, V, W)(scope T utf8Del, scope U utf16Del, scope V utf32Del, scope W nullDel) {
        assert(utf8Del !is null);
        assert(utf16Del !is null);
        assert(utf32Del !is null);

        if (codepointSize == 8)
            return utf8Del();
        else if (codepointSize == 16)
            return utf16Del();
        else if (codepointSize == 32)
            return utf32Del();
        else
            return nullDel();
    }
}

///
enum {
    ///
    WrongUnicodeEncodingException = ErrorMessage("WUEE", "Wrong Unicode Encoding Exception"),
}
