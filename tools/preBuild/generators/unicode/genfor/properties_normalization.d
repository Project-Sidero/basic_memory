module generators.unicode.genfor.properties_normalization;
import generators.unicode.data.DerivedNormalizationProps;
import generators.unicode.defs;
import utilities.inverselist;
import utilities.intervallist;
import std.array : Appender;

void genForNormalizationProps() {
    implOutput ~= "module sidero.base.internal.unicode.derivednormalizationprops;\n";
    implOutput ~= "// Generated do not modify\n\n";

    apiOutput ~= "\n";
    apiOutput ~= "/// Is character part of full composition execlusions.\n";
    generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isFullCompositionExcluded", DerivedNormalizationProps.fullCompositionExclusion, false);
}
