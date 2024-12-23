module generators.unicode.genfor.properties;
import generators.unicode.data.PropList;
import generators.unicode.defs;
import utilities.intervallist;

void genForProperties() {
    implOutput ~= "module sidero.base.internal.unicode.proplist;\n";
    implOutput ~= "import sidero.base.containers.set.interval;\n";
    implOutput ~= "// Generated do not modify\n\n";

    foreach(i, property; __traits(allMembers, Property)) {
        {
            implOutput ~= "\n";

            apiOutput ~= "\n";
            apiOutput ~= "/// Is character member of property.\n";

            generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isMemberOf" ~ property, PropList.ranges[i], true);
        }
    }

    apiOutput ~= q{
/// Is character whitespace?
alias isUnicodeWhiteSpace = sidero_utf_lut_isMemberOfWhite_Space;
};
}
