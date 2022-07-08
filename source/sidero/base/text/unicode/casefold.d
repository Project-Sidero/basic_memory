module sidero.base.text.unicode.casefold;
import sidero.base.text.unicode.characters.hangul;
import sidero.base.text.unicode.database;
import sidero.base.encoding.utf;
import sidero.base.allocators.api;

@safe nothrow @nogc:

///
size_t caseFoldLength(scope dstring input, bool turkic = false, bool compatibility = false, bool decompose = false) @trusted {
    scope arg = foreachOverUTF(input);
    return caseFoldLength(&arg.opApply, turkic, compatibility, decompose);
}

/// Gets length of Case_Folding with support for turkic rules, hangul and compatibility
size_t caseFoldLength(scope ForeachOverUTF32Delegate input, bool turkic = false, bool compatibility = false, bool decompose = false) @trusted {
    dchar[3] hangulMap;
    size_t ret;

    /*
    3.13 The full case mappings for Unicode characters are obtained by using the mappings from
SpecialCasing.txt plus the mappings from UnicodeData.txt, excluding any of the latter
mappings that would conflict. Any character that does not have a mapping in these files is
considered to map to itself
    */

    bool handleDecompose(dchar c) {
        auto decmap = sidero_utf_lut_getDecompositionMap(c);
        dstring got2;
        size_t len;

        if (compatibility && decmap.fullyDecomposedCompatibility.length > 0)
            got2 = decmap.fullyDecomposedCompatibility;
        else if (decmap.fullyDecomposed.length > 0 && (compatibility || decmap.tag == CompatibilityFormattingTag.None))
            got2 = decmap.fullyDecomposed;
        else if ((len = decomposeHangulSyllable(c, hangulMap)) > 0)
            got2 = cast(dstring)hangulMap[0 .. len];

        ret += got2.length;
        return got2.length > 0;
    }

    foreach (dchar c; input) {
        dstring got;

        if (turkic)
            got = sidero_utf_lut_getCaseFoldingTurkic(c);
        if (got.length == 0)
            got = sidero_utf_lut_getCaseFolding(c);

        if (got.length > 0) {
            // we support decomposing here to prevent extra memory allocations or work elsewhere when normalizing.
            if (decompose) {
                foreach (dchar c2; got) {
                    if (handleDecompose(c2))
                        return ret;
                    else
                        ret++;
                }
            } else
                ret++;
        } else if (decompose) {
            if (handleDecompose(c))
                return ret;
            else
                ret++;
        } else
            ret++;
    }

    return ret;
}

///
bool isCasefolded(scope dstring input, bool turkic = false, bool compatibility = false, bool decompose = false) @trusted {
    scope arg = foreachOverUTF(input);
    return isCasefolded(&arg.opApply, turkic, compatibility, decompose);
}

///
bool isCasefolded(scope ForeachOverUTF32Delegate input, bool turkic = false, bool compatibility = false, bool decompose = false) @trusted {
    dchar[3] hangulMap;

    bool handleDecompose(dchar c) {
        auto decmap = sidero_utf_lut_getDecompositionMap(c);
        dstring got2;
        size_t len;

        if (compatibility && decmap.fullyDecomposedCompatibility.length > 0)
            got2 = decmap.fullyDecomposedCompatibility;
        else if (decmap.fullyDecomposed.length > 0 && (compatibility || decmap.tag == CompatibilityFormattingTag.None))
            got2 = decmap.fullyDecomposed;
        else if ((len = decomposeHangulSyllable(c, hangulMap)) > 0)
            got2 = cast(dstring)hangulMap[0 .. len];

        if (got2.length > 0)
            return true;

        return false;
    }

    foreach (dchar c; input) {
        dstring got;

        if (turkic)
            got = sidero_utf_lut_getCaseFoldingTurkic(c);
        if (got.length == 0)
            got = sidero_utf_lut_getCaseFolding(c);

        if (got.length > 0) {
            // we support decomposing here to prevent extra memory allocations or work elsewhere when normalizing.
            if (decompose) {
                foreach (dchar c2; got) {
                    if (handleDecompose(c2))
                        return false;
                }
            }
        } else if (decompose) {
            if (handleDecompose(c))
                return false;
        }
    }

    return true;
}

///
dstring toCasefold(scope dstring input, RCAllocator allocator, bool turkic = false, bool compatibility = false, bool decompose = false) @trusted {
    scope arg = foreachOverUTF(input);
    return toCasefold(&arg.opApply, allocator, turkic, compatibility, decompose);
}

///
dstring toCasefold(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool turkic = false,
        bool compatibility = false, bool decompose = false) @trusted {
    size_t length = caseFoldLength(input, turkic, compatibility);

    dchar[] ret = allocator.makeArray!dchar(length);

    size_t soFar;
    caseFold((scope const(dchar)[] got...) { ret[soFar .. soFar + got.length] = got[]; soFar += got.length; return false; },
            input, turkic, compatibility, decompose);

    return cast(dstring)ret;
}

///
alias CaseFoldHandlerDelegate = bool delegate(scope const(dchar)[] got...) @safe nothrow @nogc;

///
void caseFold(scope CaseFoldHandlerDelegate handle, scope ForeachOverUTF32Delegate input, bool turkic, bool compatibility, bool decompose) @trusted {
    dchar[3] hangulMap;

    /*
    3.13 The full case mappings for Unicode characters are obtained by using the mappings from
SpecialCasing.txt plus the mappings from UnicodeData.txt, excluding any of the latter
mappings that would conflict. Any character that does not have a mapping in these files is
considered to map to itself
    */

    bool handleDecompose(dchar c) {
        auto decmap = sidero_utf_lut_getDecompositionMap(c);
        dstring got2;
        size_t len;

        if (compatibility && decmap.fullyDecomposedCompatibility.length > 0)
            got2 = decmap.fullyDecomposedCompatibility;
        else if (decmap.fullyDecomposed.length > 0 && (compatibility || decmap.tag == CompatibilityFormattingTag.None))
            got2 = decmap.fullyDecomposed;
        else if ((len = decomposeHangulSyllable(c, hangulMap)) > 0)
            got2 = cast(dstring)hangulMap[0 .. len];

        if ((got2.length == 0 && handle(c)) || (got2.length > 0 && handle(got2)))
            return true;

        return false;
    }

    foreach (dchar c; input) {
        dstring got;

        if (turkic)
            got = sidero_utf_lut_getCaseFoldingTurkic(c);
        if (got.length == 0)
            got = sidero_utf_lut_getCaseFolding(c);

        if (got.length > 0) {
            // we support decomposing here to prevent extra memory allocations or work elsewhere when normalizing.
            if (decompose) {
                foreach (dchar c2; got) {
                    if (handleDecompose(c2))
                        return;
                }
            } else if (handle(got))
                return;
        } else if (decompose) {
            if (handleDecompose(c))
                return;
        } else if (handle(c))
            return;
    }
}
