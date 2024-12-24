module generators.unicode.genfor.properties_graphemebreak;
import generators.unicode.data.GraphemeBreakProperty;
import generators.unicode.defs;
import utilities.intervallist;

void genForGraphemeBreakProperty() {
    implOutput ~= "module sidero.base.internal.unicode.graphemebreakproperty;\n";
    implOutput ~= "import sidero.base.containers.set.interval;\n";
    implOutput ~= "// Generated do not modify\n\n";

    foreach(i, property; __traits(allMembers, Property)) {
        {
            apiOutput ~= "\n";
            apiOutput ~= "/// Is character member of grapheme break property.\n";

            generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isMemberOfGrapheme" ~ property, GraphemeBreakProperty.ranges[i], true);
        }
    }
}
