module sidero.base.text.unicode.composing;
import sidero.base.text.unicode.characters.hangul;
import sidero.base.text.unicode.database;
import sidero.base.encoding.utf;
import sidero.base.allocators.api;

export @safe nothrow @nogc:

///
size_t decomposeLength(scope dstring input, bool compatibility = false) @trusted {
    scope arg = foreachOverUTF(input);
    return decomposeLength(&arg.opApply, compatibility);
}

///
size_t decomposeLength(scope ForeachOverUTF32Delegate input, bool compatibility = false) @trusted {
    size_t len;
    dchar[3] hangulMap = void;

    foreach (dchar c; input) {
        auto decmap = sidero_utf_lut_getDecompositionMap(c);
        dstring got2;
        size_t len2;

        if (compatibility && decmap.fullyDecomposedCompatibility.length > 0)
            got2 = decmap.fullyDecomposedCompatibility;
        else if (decmap.fullyDecomposed.length > 0 && (compatibility || decmap.tag == CompatibilityFormattingTag.None))
            got2 = decmap.fullyDecomposed;
        else if ((len2 = decomposeHangulSyllable(c, hangulMap)) > 0)
            got2 = cast(dstring)hangulMap[0 .. len2];

        if (got2.length > 0)
            len += got2.length;
        else
            len++;
    }

    return len;
}

///
bool isDecomposed(scope dstring input, bool compatibility = false) @trusted {
    scope arg = foreachOverUTF(input);
    return isDecomposed(&arg.opApply, compatibility);
}

///
bool isDecomposed(scope ForeachOverUTF32Delegate input, bool compatibility = false,) @trusted {
    dchar[3] hangulMap = void;

    foreach (dchar c; input) {
        auto decmap = sidero_utf_lut_getDecompositionMap(c);
        dstring got;
        size_t len2;

        if (compatibility && decmap.fullyDecomposedCompatibility.length > 0)
            got = decmap.fullyDecomposedCompatibility;
        else if (decmap.fullyDecomposed.length > 0 && (compatibility || decmap.tag == CompatibilityFormattingTag.None))
            got = decmap.fullyDecomposed;
        else if ((len2 = decomposeHangulSyllable(c, hangulMap)) > 0)
            got = cast(dstring)hangulMap[0 .. len2];

        if (got.length > 0)
            return false;
    }

    return true;
}

///
dstring toDecompose(scope dstring input, RCAllocator allocator, bool compatibility = false) @trusted {
    scope arg = foreachOverUTF(input);
    return toDecompose(&arg.opApply, allocator, compatibility);
}

///
dstring toDecompose(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool compatibility = false) @trusted {
    size_t length = decomposeLength(input, compatibility);
    dchar[] ret = allocator.makeArray!dchar(length);

    decompose(ret, input, compatibility);
    return cast(dstring)ret;
}

///
void decompose(scope dchar[] array, scope ForeachOverUTF32Delegate input, bool compatibility) @trusted {
    size_t soFar;
    dchar[3] hangulMap = void;

    foreach (dchar c; input) {
        auto decmap = sidero_utf_lut_getDecompositionMap(c);
        dstring got;
        size_t len;

        if (compatibility && decmap.fullyDecomposedCompatibility.length > 0)
            got = decmap.fullyDecomposedCompatibility;
        else if (decmap.fullyDecomposed.length > 0 && (compatibility || decmap.tag == CompatibilityFormattingTag.None))
            got = decmap.fullyDecomposed;
        else if ((len = decomposeHangulSyllable(c, hangulMap)) > 0)
            got = cast(dstring)hangulMap[0 .. len];

        if (got.length > 0) {
            foreach(i, v; got)
                array[soFar + i] = v;
            soFar += got.length;
        } else {
            array[soFar] = c;
            soFar++;
        }
    }
}
