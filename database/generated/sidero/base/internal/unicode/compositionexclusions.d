module sidero.base.internal.unicode.compositionexclusions;

// Generated do not modify
export extern(C) immutable(bool) sidero_utf_lut_isCompositionExcluded(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x958 && input <= 0x95F)
        return cast(bool)true;
    else if (input >= 0x9DC && input <= 0x9DF)
        return cast(bool)LUT_CE59E73C[0 + (input - 2524)];
    else if (input >= 0xA33 && input <= 0xA36)
        return cast(bool)LUT_CE59E73C[4 + (input - 2611)];
    else if (input >= 0xA59 && input <= 0xA5E)
        return cast(bool)LUT_CE59E73C[8 + (input - 2649)];
    else if (input >= 0xB5C && input <= 0xB5D)
        return cast(bool)true;
    else if (input == 0xF43)
        return cast(bool)true;
    else if (input >= 0xF4D && input <= 0xF5C)
        return cast(bool)LUT_CE59E73C[14 + (input - 3917)];
    else if (input == 0xF69)
        return cast(bool)true;
    else if (input >= 0xF76 && input <= 0xF78)
        return cast(bool)LUT_CE59E73C[30 + (input - 3958)];
    else if (input == 0xF93)
        return cast(bool)true;
    else if (input >= 0xF9D && input <= 0xFAC)
        return cast(bool)LUT_CE59E73C[33 + (input - 3997)];
    else if (input == 0xFB9)
        return cast(bool)true;
    else if (input == 0x2ADC)
        return cast(bool)true;
    else if (input >= 0xFB1D && input <= 0xFB1F)
        return cast(bool)LUT_CE59E73C[49 + (input - 64285)];
    else if (input >= 0xFB2A && input <= 0xFB4E)
        return cast(bool)LUT_CE59E73C[52 + (input - 64298)];
    else if (input >= 0x1D15E && input <= 0x1D164)
        return cast(bool)true;
    else if (input >= 0x1D1BB && input <= 0x1D1C0)
        return cast(bool)true;
    return typeof(return).init;
}
private {
    static immutable LUT_CE59E73C = [true, true, false, true, true, false, false, true, true, true, true, false, false, true, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, true, false, true, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, true, true, true, true, true, false, true, false, true, true, false, true, true, false, true, true, true, true, true, true, true, true, true, ];
}

