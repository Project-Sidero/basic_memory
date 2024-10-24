module generators.unicode.derivednormalizationprops;
import constants;

void derivedNormalizationProps() {
    import std.file : readText, write, append;

    TotalState state;

    processEachLine(readText(UnicodeDatabaseDirectory ~ "DerivedNormalizationProps.txt"), state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.unicode.derivednormalizationprops;\n\n";
    internal ~= "// Generated do not modify\n";

    auto api = appender!string();

    api ~= "\n";
    api ~= "/// Is character part of full composition execlusions.\n";
    generateIsCheck(api, internal, "sidero_utf_lut_isFullCompositionExcluded", state.fullCompositionExclusion);

    append(UnicodeAPIFile, api.data);
    write(UnicodeLUTDirectory ~ "derivednormalizationprops.d", internal.data);
}

private:
import std.array : appender, Appender;
import utilities.setops;
import utilities.inverselist;

void processEachLine(string inputText, ref TotalState state) {
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
            state.single[property] ~= QuickCheck(valueRange, yesNoMaybe);
        else
            state.range[property] ~= QuickCheck(valueRange, yesNoMaybe);
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
                state.changesSingle ~= ChangesWhenCaseFolded(valueRange);
            else
                state.changesRange ~= ChangesWhenCaseFolded(valueRange);
        } else if(propertyStr == "Full_Composition_Exclusion") {
            if(state.fullCompositionExclusion.length == 0)
                state.fullCompositionExclusion ~= valueRange;
            else {
                if(valueRange.start == state.fullCompositionExclusion[$ - 1].end + 1)
                    state.fullCompositionExclusion[$ - 1].end = valueRange.end;
                else
                    state.fullCompositionExclusion ~= valueRange;
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
                state.caseFoldSingle ~= CaseFold(valueRange, replacements);
            else
                state.caseFoldRange ~= CaseFold(valueRange, replacements);
        } else {
            if(line.length > 0)
                handleLine(valueRange, propertyStr, line);
        }
    }
}

static string[] PropertyText = ["NFD_QC", "NFC_QC", "NFKD_QC", "NFKC_QC", "NFx"];
enum NormalizeProperty {
    NFD_QC,
    NFC_QC,
    NFKD_QC,
    NFKC_QC
}

struct TotalState {
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

void ymn(ref Appender!string output, YesNoMaybe yesNoMaybe) {
    if(yesNoMaybe == YesNoMaybe.Yes)
        output ~= "Y";
    else if(yesNoMaybe == YesNoMaybe.No)
        output ~= "N";
    else if(yesNoMaybe == YesNoMaybe.Maybe)
        output ~= "M";
}
