module generators.unicode.data;
import constants;
import std.file : readText;

void loadUnicodeData() {
    import generators.unicode.data.UnicodeData;
    processUnicodeData(readText(UnicodeDatabaseDirectory ~ "UnicodeData.txt"));

    import generators.unicode.data.PropList;
    processPropList(readText(UnicodeDatabaseDirectory ~ "PropList.txt"));

    import generators.unicode.data.SpecialCasing;
    processSpecialCasing(readText(UnicodeDatabaseDirectory ~ "SpecialCasing.txt"));

    import generators.unicode.data.CompositionExclusions;
    processCompositionExclusions(readText(UnicodeDatabaseDirectory ~ "CompositionExclusions.txt"));
}
