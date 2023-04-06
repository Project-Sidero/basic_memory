module sidero.base.internal.unicode.derivednormalizationprops;

// Generated do not modify
export extern(C) immutable(bool) sidero_utf_lut_isFullCompositionExcluded(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x340 && input <= 0x387) {
        if (input <= 0x344)
            return cast(bool)LUT_80A25785[cast(size_t)(0 + (input - 0x340))];
        else if (input == 0x374)
            return cast(bool)true;
        else if (input == 0x37E)
            return cast(bool)true;
        else if (input == 0x387)
            return cast(bool)true;
    } else if (input >= 0x958 && input <= 0xFB9) {
        if (input <= 0x95F)
            return cast(bool)true;
        else if (input >= 0x9DC && input <= 0x9DF)
            return cast(bool)LUT_80A25785[cast(size_t)(5 + (input - 0x9DC))];
        else if (input >= 0xA33 && input <= 0xA36)
            return cast(bool)LUT_80A25785[cast(size_t)(9 + (input - 0xA33))];
        else if (input >= 0xA59 && input <= 0xA5E)
            return cast(bool)LUT_80A25785[cast(size_t)(13 + (input - 0xA59))];
        else if (input >= 0xB5C && input <= 0xB5D)
            return cast(bool)true;
        else if (input == 0xF43)
            return cast(bool)true;
        else if (input >= 0xF4D && input <= 0xF5C)
            return cast(bool)LUT_80A25785[cast(size_t)(19 + (input - 0xF4D))];
        else if (input == 0xF69)
            return cast(bool)true;
        else if (input >= 0xF73 && input <= 0xF78)
            return cast(bool)LUT_80A25785[cast(size_t)(35 + (input - 0xF73))];
        else if (input == 0xF81)
            return cast(bool)true;
        else if (input == 0xF93)
            return cast(bool)true;
        else if (input >= 0xF9D && input <= 0xFAC)
            return cast(bool)LUT_80A25785[cast(size_t)(41 + (input - 0xF9D))];
        else if (input == 0xFB9)
            return cast(bool)true;
    } else if (input >= 0x1F71 && input <= 0x232A) {
        if (input <= 0x1F7D)
            return cast(bool)LUT_80A25785[cast(size_t)(57 + (input - 0x1F71))];
        else if (input >= 0x1FBB && input <= 0x1FBE)
            return cast(bool)LUT_80A25785[cast(size_t)(70 + (input - 0x1FBB))];
        else if (input >= 0x1FC9 && input <= 0x1FCB)
            return cast(bool)LUT_80A25785[cast(size_t)(74 + (input - 0x1FC9))];
        else if (input == 0x1FD3)
            return cast(bool)true;
        else if (input == 0x1FDB)
            return cast(bool)true;
        else if (input == 0x1FE3)
            return cast(bool)true;
        else if (input >= 0x1FEB && input <= 0x1FEF)
            return cast(bool)LUT_80A25785[cast(size_t)(77 + (input - 0x1FEB))];
        else if (input >= 0x1FF9 && input <= 0x2001)
            return cast(bool)LUT_80A25785[cast(size_t)(82 + (input - 0x1FF9))];
        else if (input >= 0x2126 && input <= 0x212B)
            return cast(bool)LUT_80A25785[cast(size_t)(91 + (input - 0x2126))];
        else if (input >= 0x2329)
            return cast(bool)true;
    } else if (input == 0x2ADC) {
        return cast(bool)true;
    } else if (input >= 0xF900 && input <= 0xFB4E) {
        return cast(bool)LUT_80A25785[cast(size_t)(97 + (input - 0xF900))];
    } else if (input >= 0x1D15E && input <= 0x1D1C0) {
        if (input <= 0x1D164)
            return cast(bool)true;
        else if (input >= 0x1D1BB)
            return cast(bool)true;
    } else if (input >= 0x2F800 && input <= 0x2FA1D) {
        return cast(bool)true;
    }
    return typeof(return).init;
}
private {
    static immutable LUT_80A25785 = [true, true, false, true, true, true, true, false, true, true, false, false, true, true, true, true, false, false, true, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, true, false, true, true, false, true, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, true, false, true, false, true, false, true, false, true, false, true, false, true, true, false, false, true, true, false, true, true, false, false, true, true, true, false, true, false, true, false, false, true, true, true, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, true, false, true, false, false, true, true, true, true, true, true, true, true, true, true, false, true, false, true, false, false, true, true, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, true, false, false, false, false, false, false, false, false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, false, true, true, true, true, true, false, true, false, true, true, false, true, true, false, true, true, true, true, true, true, true, true, true, ];
}

