module sidero.base.implOutput.unicode.uax31;
import sidero.base.containers.set.interval;
// Generated do not modify


static immutable dchar[] Table_sidero_utf_lut_isUAX31_C_Start = cast(dchar[])x"0000005F0000005F";

export extern(C) bool sidero_utf_lut_isUAX31_C_Start(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isUAX31_C_Start.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isUAX31_C_Start[mid << 1], end = Table_sidero_utf_lut_isUAX31_C_Start[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_C_Start_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isUAX31_C_Start);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isUAX31_C_Continue = cast(dchar[])x"";

export extern(C) bool sidero_utf_lut_isUAX31_C_Continue(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isUAX31_C_Continue.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isUAX31_C_Continue[mid << 1], end = Table_sidero_utf_lut_isUAX31_C_Continue[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_C_Continue_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isUAX31_C_Continue);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isUAX31_JS_Start = cast(dchar[])x"00000024000000240000005F0000005F";

export extern(C) bool sidero_utf_lut_isUAX31_JS_Start(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isUAX31_JS_Start.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isUAX31_JS_Start[mid << 1], end = Table_sidero_utf_lut_isUAX31_JS_Start[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_JS_Start_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isUAX31_JS_Start);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isUAX31_JS_Continue = cast(dchar[])x"0000002400000024";

export extern(C) bool sidero_utf_lut_isUAX31_JS_Continue(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isUAX31_JS_Continue.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isUAX31_JS_Continue[mid << 1], end = Table_sidero_utf_lut_isUAX31_JS_Continue[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isUAX31_JS_Continue_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isUAX31_JS_Continue);
    return cast(IntervalSet!dchar)Set;
}
