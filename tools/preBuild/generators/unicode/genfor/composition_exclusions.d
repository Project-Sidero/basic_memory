module generators.unicode.genfor.composition_exclusions;
import generators.unicode.data.CompositionExclusions;
import generators.unicode.defs;
import utilities.intervallist;

void genForCompositionExclusions() {
    implOutput ~= "module sidero.base.internal.unicode.compositionexclusions;\n";
    implOutput ~= "// Generated do not modify\n\n";

    {
        apiOutput ~= "\n";
        apiOutput ~= "/// Is excluded from composition.\n";
        apiOutput ~= "/// Returns: false if not set.\n";

        generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isCompositionExcluded", CompositionExclusions, false);
    }
}
