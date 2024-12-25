module generators.unicode.data;
import constants;
import std.file : readText;

void loadUnicodeData() {
    import generators.unicode.data.UnicodeData;
    import generators.unicode.data.PropList;
    import generators.unicode.data.SpecialCasing;
    import generators.unicode.data.CompositionExclusions;
    import generators.unicode.data.CaseFolding;
    import generators.unicode.data.DerivedCoreProperties;
    import generators.unicode.data.DerivedNormalizationProps;
    import generators.unicode.data.GraphemeBreakProperty;
    import generators.unicode.data.HangulSyllableType;
    import generators.unicode.data.LineBreak;
    import generators.unicode.data.Scripts;
    import generators.unicode.data.WordBreakProperty;
    import generators.unicode.data.EmojiData;

    processUnicodeData(readText(UnicodeDatabaseDirectory ~ "UnicodeData.txt"));
    processPropList(readText(UnicodeDatabaseDirectory ~ "PropList.txt"));
    processSpecialCasing(readText(UnicodeDatabaseDirectory ~ "SpecialCasing.txt"));
    processCompositionExclusions(readText(UnicodeDatabaseDirectory ~ "CompositionExclusions.txt"));
    processCaseFolding(readText(UnicodeDatabaseDirectory ~ "CaseFolding.txt"));
    processDerivedCoreProperties(readText(UnicodeDatabaseDirectory ~ "DerivedCoreProperties.txt"));
    processDerivedNormalizationProps(readText(UnicodeDatabaseDirectory ~ "DerivedNormalizationProps.txt"));
    processGraphemeBreakProperty(readText(UnicodeDatabaseDirectory ~ "GraphemeBreakProperty.txt"));
    processHangulSyllableType(readText(UnicodeDatabaseDirectory ~ "HangulSyllableType.txt"));
    processLineBreak(readText(UnicodeDatabaseDirectory ~ "LineBreak.txt"));
    processScripts(readText(UnicodeDatabaseDirectory ~ "Scripts.txt"));
    processWordBreakProperty(readText(UnicodeDatabaseDirectory ~ "auxiliary/WordBreakProperty.txt"));
    processEmojiData(readText(UnicodeDatabaseDirectory ~ "emoji/emoji-data.txt"));
}
