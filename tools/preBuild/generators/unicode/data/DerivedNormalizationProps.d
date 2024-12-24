module generators.unicode.data.DerivedNormalizationProps;
import utilities.setops;

__gshared DerivedNormalizationProps_State DerivedNormalizationProps;

enum NormalizeProperty {
    NFD_QC,
    NFC_QC,
    NFKD_QC,
    NFKC_QC
}

struct DerivedNormalizationProps_State {
    QuickCheck[][4] single;
    QuickCheck[][4] range;

    CaseFold[] caseFoldSingle, caseFoldRange;
    ChangesWhenCaseFolded[] changesSingle, changesRange;

    ValueRange[] fullCompositionExclusion;
}

enum YesNoMaybe {
    Yes,
    No,
    Maybe
}

struct QuickCheck {
    ValueRange range;
    YesNoMaybe yesNoMaybe;
}

struct CaseFold {
    ValueRange range;
    dchar[] becomes;
}

struct OptionalReplacement {
    dchar[] becomes;
    bool haveValue;
}

struct ChangesWhenCaseFolded {
    ValueRange range;
}

void processDerivedNormalizationProps(string inputText) {
    import std.algorithm : countUntil, splitter;
    import std.string : strip, lineSplitter;
    import std.conv : parse;

    ValueRange valueRangeFromString(string charRangeStr) {
        ValueRange ret;

        ptrdiff_t offsetOfSeperator = charRangeStr.countUntil("..");
        if(offsetOfSeperator < 0) {
            ret.start = parse!uint(charRangeStr, 16);
            ret.end = ret.start;
        } else {
            string startStr = charRangeStr[0 .. offsetOfSeperator], endStr = charRangeStr[offsetOfSeperator + 2 .. $];
            ret.start = parse!uint(startStr, 16);
            ret.end = parse!uint(endStr, 16);
        }

        return ret;
    }

    void handleLine(ValueRange valueRange, string propertyStr, string yesNoMaybeStr) {
        NormalizeProperty property;
        YesNoMaybe yesNoMaybe;

        switch(propertyStr) {
        case "NFD_QC":
            property = NormalizeProperty.NFD_QC;
            break;
        case "NFC_QC":
            property = NormalizeProperty.NFC_QC;
            break;
        case "NFKD_QC":
            property = NormalizeProperty.NFKD_QC;
            break;
        case "NFKC_QC":
            property = NormalizeProperty.NFKC_QC;
            break;

        default:
            return;
        }

        switch(yesNoMaybeStr) {
        case "Y":
            yesNoMaybe = YesNoMaybe.Yes;
            break;
        case "N":
            yesNoMaybe = YesNoMaybe.No;
            break;
        case "M":
            yesNoMaybe = YesNoMaybe.Maybe;
            break;
        default:
            return;
        }

        if(valueRange.isSingle)
            DerivedNormalizationProps.single[property] ~= QuickCheck(valueRange, yesNoMaybe);
        else
            DerivedNormalizationProps.range[property] ~= QuickCheck(valueRange, yesNoMaybe);
    }

    foreach(line; inputText.lineSplitter) {
        ptrdiff_t offset;

        offset = line.countUntil('#');
        if(offset >= 0)
            line = line[0 .. offset];
        line = line.strip;

        if(line.length < 5) // anything that low can't represent a functional line
            continue;

        offset = line.countUntil(';');
        if(offset < 0) // no char range
            continue;
        string charRangeStr = line[0 .. offset].strip;
        line = line[offset + 1 .. $].strip;

        ValueRange valueRange = valueRangeFromString(charRangeStr);

        offset = line.countUntil(';');
        string propertyStr;

        if(offset > 0) {
            propertyStr = line[0 .. offset].strip;
            line = line[offset + 1 .. $].strip;
        } else
            propertyStr = line.strip;

        if(propertyStr == "Changes_When_NFKC_Casefolded") {
            if(valueRange.isSingle)
                DerivedNormalizationProps.changesSingle ~= ChangesWhenCaseFolded(valueRange);
            else
                DerivedNormalizationProps.changesRange ~= ChangesWhenCaseFolded(valueRange);
        } else if(propertyStr == "Full_Composition_Exclusion") {
            if(DerivedNormalizationProps.fullCompositionExclusion.length == 0)
                DerivedNormalizationProps.fullCompositionExclusion ~= valueRange;
            else {
                if(valueRange.start == DerivedNormalizationProps.fullCompositionExclusion[$ - 1].end + 1)
                    DerivedNormalizationProps.fullCompositionExclusion[$ - 1].end = valueRange.end;
                else
                    DerivedNormalizationProps.fullCompositionExclusion ~= valueRange;
            }
        } else if(propertyStr == "NFKC_CF") {
            dchar[] replacements;
            replacements.reserve(4);

            foreach(replacement; line.splitter(' ')) {
                replacement = replacement.strip;
                if(replacement.length == 0)
                    continue;

                replacements ~= parse!uint(replacement, 16);
            }

            if(valueRange.isSingle)
                DerivedNormalizationProps.caseFoldSingle ~= CaseFold(valueRange, replacements);
            else
                DerivedNormalizationProps.caseFoldRange ~= CaseFold(valueRange, replacements);
        } else {
            if(line.length > 0)
                handleLine(valueRange, propertyStr, line);
        }
    }
}
