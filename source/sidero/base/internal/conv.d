module sidero.base.internal.conv;
@safe nothrow:

wstring stringToWstring(string input)() {
    import sidero.base.encoding.utf : reEncode;

    assert(__ctfe);

    enum ret = () {
        wstring ret;
        reEncode(input, (wchar c) { ret ~= c; });
        return ret;
    }();

    return ret;
}

wstring intToWString(int input)() {
    assert(__ctfe);
    return stringToWstring!(intToString!(input));
}

string intToString(int inputV)() {
    assert(__ctfe);

    enum result = () {
        int input = inputV;
        string ret;
        bool negate;

        if(input < 0) {
            input *= -1;
            negate = true;
        }

        while(input != 0) {
            int next = input / 10;

            auto v = input - (next * 10);
            auto c = cast(char)(v + '0');
            ret = c ~ ret;

            input = next;
        }

        if(negate)
            ret = "-" ~ ret;
        return ret;
    }();
    return result;
}
