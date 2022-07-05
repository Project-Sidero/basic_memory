module sidero.base.text.unicode.characters.hangul;

@safe nothrow @nogc pure:

private enum {
    SBase = 0xAC00,
    LBase = 0x1100,
    VBase = 0x1161,
    TBase = 0x11A7,

    LCount = 19,
    VCount = 21,
    TCount = 28,
    NCount = 588,
    SCount = 11172,
}

///
size_t decomposeHangulSyllable(dchar input, scope ref dchar[3] output) {
    if (input < SBase || input >= SBase + SCount)
        return 0;

    uint SIndex = input - SBase;
    uint LIndex = SIndex / NCount, LPart = LBase + LIndex;
    uint VIndex = (SIndex % NCount) / TCount, VPart = VBase + VIndex;
    uint TIndex = SIndex % TCount, TPart = TBase + TIndex;

    output[0] = LPart;
    output[1] = VPart;
    output[2] = TPart;
    return TIndex > 0 ? 3 : 2;
}

///
size_t composeHangulSyllable(dchar LPart, dchar VPart, out dchar output) {
    if (LBase <= LPart && LPart < LBase + LCount && VBase <= VPart && VPart < VBase + VCount) {
        uint LIndex = LPart - LBase;
        uint VIndex = VPart - VBase;
        uint LVIndex = (LIndex * NCount) + (VIndex * TCount);
        output = SBase + LVIndex;
        return 2;
    }

    return 0;
}

///
size_t composeHangulSyllable(dchar LPart, dchar VPart, dchar TPart, out dchar output) {
    if (LBase <= LPart && LPart < LBase + LCount && VBase <= VPart && VPart < VBase + VCount) {
        uint LIndex = LPart - LBase, VIndex = VPart - VBase, LVIndex = (LIndex * NCount) + (VIndex * TCount), TIndex;

        if (TBase <= TPart && TPart < TBase + TCount)
            TIndex = TPart - TBase;

        output = SBase + LVIndex + TIndex;
        return TIndex > 0 ? 3 : 2;
    }

    return 0;
}
