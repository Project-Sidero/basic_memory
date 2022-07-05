module sidero.base.internal.unicode.derivednormalizationprops;

// Generated do not modify
export extern(C) immutable(bool) sidero_utf_lut_isFullCompositionExcluded(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x340 && input <= 0x387) {
        if (input <= 0x344)
            return cast(bool)LUT_80A25785[0 + (input - 832)];
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
            return cast(bool)LUT_80A25785[5 + (input - 2524)];
        else if (input >= 0xA33 && input <= 0xA36)
            return cast(bool)LUT_80A25785[9 + (input - 2611)];
        else if (input >= 0xA59 && input <= 0xA5E)
            return cast(bool)LUT_80A25785[13 + (input - 2649)];
        else if (input >= 0xB5C && input <= 0xB5D)
            return cast(bool)true;
        else if (input == 0xF43)
            return cast(bool)true;
        else if (input >= 0xF4D && input <= 0xF5C)
            return cast(bool)LUT_80A25785[19 + (input - 3917)];
        else if (input == 0xF69)
            return cast(bool)true;
        else if (input >= 0xF73 && input <= 0xF78)
            return cast(bool)LUT_80A25785[35 + (input - 3955)];
        else if (input == 0xF81)
            return cast(bool)true;
        else if (input == 0xF93)
            return cast(bool)true;
        else if (input >= 0xF9D && input <= 0xFAC)
            return cast(bool)LUT_80A25785[41 + (input - 3997)];
        else if (input == 0xFB9)
            return cast(bool)true;
    } else if (input >= 0x1F71 && input <= 0x232A) {
        if (input <= 0x1F7D)
            return cast(bool)LUT_80A25785[57 + (input - 8049)];
        else if (input >= 0x1FBB && input <= 0x1FBE)
            return cast(bool)LUT_80A25785[70 + (input - 8123)];
        else if (input >= 0x1FC9 && input <= 0x1FCB)
            return cast(bool)LUT_80A25785[74 + (input - 8137)];
        else if (input == 0x1FD3)
            return cast(bool)true;
        else if (input == 0x1FDB)
            return cast(bool)true;
        else if (input == 0x1FE3)
            return cast(bool)true;
        else if (input >= 0x1FEB && input <= 0x1FEF)
            return cast(bool)LUT_80A25785[77 + (input - 8171)];
        else if (input >= 0x1FF9 && input <= 0x2001)
            return cast(bool)LUT_80A25785[82 + (input - 8185)];
        else if (input >= 0x2126 && input <= 0x212B)
            return cast(bool)LUT_80A25785[91 + (input - 8486)];
        else if (input >= 0x2329)
            return cast(bool)true;
    } else if (input == 0x2ADC) {
        return cast(bool)true;
    } else if (input >= 0xF900 && input <= 0xFB4E) {
        return cast(bool)LUT_80A25785[97 + (input - 63744)];
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

