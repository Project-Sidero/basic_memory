module sidero.base.internal.unicode.compositionexclusions;

// Generated do not modify

export extern(C) bool sidero_utf_lut_isCompositionExcluded(dchar against) @trusted nothrow @nogc pure {
    static immutable dchar[] Table_sidero_utf_lut_isCompositionExcluded = cast(dchar[])x"0000095800000960000009DC000009DE000009DF000009E000000A3300000A3400000A3600000A3700000A5900000A5C00000A5E00000A5F00000B5C00000B5E00000F4300000F4400000F4D00000F4E00000F5200000F5300000F5700000F5800000F5C00000F5D00000F6900000F6A00000F7600000F7700000F7800000F7900000F9300000F9400000F9D00000F9E00000FA200000FA300000FA700000FA800000FAC00000FAD00000FB900000FBA00002ADC00002ADD0000FB1D0000FB1E0000FB1F0000FB200000FB2A0000FB370000FB380000FB3D0000FB3E0000FB3F0000FB400000FB420000FB430000FB450000FB460000FB4F0001D15E0001D1650001D1BB0001D1C1";
    ptrdiff_t low, high = Table_sidero_utf_lut_isCompositionExcluded.length;

    while(low < high) {
        const mid = low + ((high - low) / 2);

        if (against >= Table_sidero_utf_lut_isCompositionExcluded[mid])
            low = mid + 1;
        else if (against < Table_sidero_utf_lut_isCompositionExcluded[mid])
            high = mid;
    }

    const pos = high - 1;
    return (pos & 1) == 0;
}
