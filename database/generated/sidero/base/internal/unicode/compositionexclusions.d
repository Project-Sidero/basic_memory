module sidero.base.internal.unicode.compositionexclusions;

// Generated do not modify
export extern(C) immutable(bool) sidero_utf_lut_isCompositionExcluded(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x958 && input <= 0x95F)
        return cast(bool)true;
    else if (input >= 0x9DC && input <= 0x9DF)
        return cast(bool)LUT_CE59E73C[cast(size_t)(0 + (input - 0x9DC))];
    else if (input >= 0xA33 && input <= 0xA36)
        return cast(bool)LUT_CE59E73C[cast(size_t)(4 + (input - 0xA33))];
    else if (input >= 0xA59 && input <= 0xA5E)
        return cast(bool)LUT_CE59E73C[cast(size_t)(8 + (input - 0xA59))];
    else if (input >= 0xB5C && input <= 0xB5D)
        return cast(bool)true;
    else if (input == 0xF43)
        return cast(bool)true;
    else if (input >= 0xF4D && input <= 0xF5C)
        return cast(bool)LUT_CE59E73C[cast(size_t)(14 + (input - 0xF4D))];
    else if (input == 0xF69)
        return cast(bool)true;
    else if (input >= 0xF76 && input <= 0xF78)
        return cast(bool)LUT_CE59E73C[cast(size_t)(30 + (input - 0xF76))];
    else if (input == 0xF93)
        return cast(bool)true;
    else if (input >= 0xF9D && input <= 0xFAC)
        return cast(bool)LUT_CE59E73C[cast(size_t)(33 + (input - 0xF9D))];
    else if (input == 0xFB9)
        return cast(bool)true;
    else if (input == 0x2ADC)
        return cast(bool)true;
    else if (input >= 0xFB1D && input <= 0xFB1F)
        return cast(bool)LUT_CE59E73C[cast(size_t)(49 + (input - 0xFB1D))];
    else if (input >= 0xFB2A && input <= 0xFB4E)
        return cast(bool)LUT_CE59E73C[cast(size_t)(52 + (input - 0xFB2A))];
    else if (input >= 0x1D15E && input <= 0x1D164)
        return cast(bool)true;
    else if (input >= 0x1D1BB && input <= 0x1D1C0)
        return cast(bool)true;
    return typeof(return).init;
}
private {
    static immutable LUT_CE59E73C = [true, true, false, true, true, false, false, true, true, true, true, false, false, true, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, true, false, true, true, false, false, false, false, true, false, false, false, false, true, false, false, false, false, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, true, true, true, true, true, false, true, false, true, true, false, true, true, false, true, true, true, true, true, true, true, true, true, ];
}

