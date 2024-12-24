module generators.unicode.genfor.casing_folding;
import generators.unicode.data.CaseFolding;
import generators.unicode.defs;
import utilities.inverselist;
import std.algorithm : sort;

void genForCaseFolding() {
    implOutput ~= "module sidero.base.internal.unicode.casefolding;\n";
    implOutput ~= "// Generated do not modify\n\n";

    dchar[] codepoints, replacedBysDchar;
    dstring[] replacedBys;
    uint[] replacedByUints;

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup Casefolding for character.\n";
        apiOutput ~= "/// Returns: null if unchanged.\n";

        joinEntries(codepoints, replacedBys, CaseFolding.common, CaseFolding.full);
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getCaseFolding", codepoints, replacedBys);
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup Casefolding for character.\n";
        apiOutput ~= "/// Returns: null if unchanged.\n";

        joinEntries(codepoints, replacedBys, CaseFolding.turkic);
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getCaseFoldingTurkic", codepoints, replacedBys);
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup Casefolding (simple) for character.\n";
        apiOutput ~= "/// Returns: The casefolded character.\n";

        joinEntries(codepoints, replacedBysDchar, CaseFolding.common, CaseFolding.simple);
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_getCaseFoldingFast", codepoints, replacedBysDchar);
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup Casefolding length for character.\n";
        apiOutput ~= "/// Returns: 0 if unchanged.\n";

        joinEntriesLength(codepoints, replacedByUints, CaseFolding.common, CaseFolding.full);
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_lengthOfCaseFolding", codepoints, replacedByUints);
    }

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Lookup Casefolding length for character.\n";
        apiOutput ~= "/// Returns: 0 if unchanged.\n";

        joinEntriesLength(codepoints, replacedByUints, CaseFolding.turkic);
        generateReturn(apiOutput, implOutput, "sidero_utf_lut_lengthOfCaseFoldingTurkic", codepoints, replacedByUints);
    }
}

private:

void joinEntries(out dchar[] codepoints, out dstring[] replacedBys, CaseFolding_Entry[][] entries...) {
    CaseFolding_Entry[] total;

    foreach(entry; entries) {
        total ~= entry;
    }

    sort!"a.codepoint < b.codepoint"(total);

    codepoints.reserve(total.length);
    replacedBys.reserve(total.length);

    dchar lastCodepoint;

    foreach(v; total) {
        assert(lastCodepoint != v.codepoint);

        codepoints ~= v.codepoint;
        replacedBys ~= v.replacedBy;
        lastCodepoint = v.codepoint;
    }
}

void joinEntries(out dchar[] codepoints, out dchar[] replacedBys, CaseFolding_Entry[][] entries...) {
    CaseFolding_Entry[] total;

    foreach(entry; entries) {
        total ~= entry;
    }

    sort!"a.codepoint < b.codepoint"(total);

    codepoints.reserve(total.length);
    replacedBys.reserve(total.length);

    dchar lastCodepoint;

    foreach(v; total) {
        assert(lastCodepoint != v.codepoint);

        codepoints ~= v.codepoint;
        replacedBys ~= v.replacedBy[0];
        lastCodepoint = v.codepoint;
    }
}

void joinEntriesLength(out dchar[] codepoints, out uint[] replacedBys, CaseFolding_Entry[][] entries...) {
    CaseFolding_Entry[] total;

    foreach(entry; entries) {
        total ~= entry;
    }

    sort!"a.codepoint < b.codepoint"(total);

    codepoints.reserve(total.length);
    replacedBys.reserve(total.length);

    dchar lastCodepoint;

    foreach(v; total) {
        assert(lastCodepoint != v.codepoint);

        codepoints ~= v.codepoint;
        replacedBys ~= cast(uint)v.replacedBy.length;
        lastCodepoint = v.codepoint;
    }
}
