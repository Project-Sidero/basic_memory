module sidero.base.text.unicode.casing;
import sidero.base.encoding.utf;
import sidero.base.text.unicode.characters.database;
import sidero.base.errors;

export @safe nothrow @nogc:

///
alias CasingRemoveThisDelegate = void delegate() @safe nothrow @nogc;
///
alias CasingInsertThisDelegate = void delegate(scope dstring) @safe nothrow @nogc;

/// Insertion should move the primary cursor forwards by that amount, removal shouldn't move forward.
ErrorResult toUnicodeLowerCase(scope ForeachOverUTF32Delegate primaryForwards, scope ForeachOverUTF32Delegate secondaryForwards,
        scope ForeachOverUTF32Delegate secondaryBackwards,
        scope CasingRemoveThisDelegate removeThis, scope CasingInsertThisDelegate insertThis, UnicodeLanguage language) {

    if (removeThis is null)
        return ErrorResult(NullPointerException("Remove from here delegate must not be null"));
    else if (insertThis is null)
        return ErrorResult(NullPointerException("Insert from here delegate must not be null"));

    return caseImpl(primaryForwards, secondaryForwards, secondaryBackwards, (dchar c, SpecialCasing casing) {
        dstring as = casing.lower;
        if (as.length > 1 || (as.length == 1 && as[0] != c)) {
            insertThis(as);
            removeThis();
        }
    }, language);
}

/// Ditto
ErrorResult toUnicodeUpperCase(scope ForeachOverUTF32Delegate primaryForwards, scope ForeachOverUTF32Delegate secondaryForwards,
        scope ForeachOverUTF32Delegate secondaryBackwards,
        scope CasingRemoveThisDelegate removeThis, scope CasingInsertThisDelegate insertThis, UnicodeLanguage language) {

    if (removeThis is null)
        return ErrorResult(NullPointerException("Remove from here delegate must not be null"));
    else if (insertThis is null)
        return ErrorResult(NullPointerException("Insert from here delegate must not be null"));

    return caseImpl(primaryForwards, secondaryForwards, secondaryBackwards, (dchar c, SpecialCasing casing) {
        dstring as = casing.upper;
        if (as.length > 1 || (as.length == 1 && as[0] != c)) {
            insertThis(as);
            removeThis();
        }
    }, language);
}

/// Ditto
ErrorResult toUnicodeTitleCase(scope ForeachOverUTF32Delegate primaryForwards, scope ForeachOverUTF32Delegate secondaryForwards,
        scope ForeachOverUTF32Delegate secondaryBackwards,
        scope CasingRemoveThisDelegate removeThis, scope CasingInsertThisDelegate insertThis, UnicodeLanguage language) {

    if (removeThis is null)
        return ErrorResult(NullPointerException("Remove from here delegate must not be null"));
    else if (insertThis is null)
        return ErrorResult(NullPointerException("Insert from here delegate must not be null"));

    return caseImpl(primaryForwards, secondaryForwards, secondaryBackwards, (dchar c, SpecialCasing casing) {
        dstring as;
        dchar lastChar;
        bool haveLastChar;

        foreach (secondary; secondaryBackwards) {
            lastChar = secondary;
            haveLastChar = true;
            break;
        }

        if (!haveLastChar || !isAlpha(lastChar))
            as = casing.title;
        else
            as = casing.lower;

        if (as.length > 1 || (as.length == 1 && as[0] != c)) {
            insertThis(as);
            removeThis();
        }
    }, language);
}

private:
import sidero.base.text.unicode.database : SpecialCasing, SpecialCasingCondition, sidero_utf_lut_getSpecialCasing,
    sidero_utf_lut_isMemberOfSoft_Dotted, sidero_utf_lut_getCCC;

ErrorResult caseImpl(scope ForeachOverUTF32Delegate primaryForwards, scope ForeachOverUTF32Delegate secondaryForwards,
        scope ForeachOverUTF32Delegate secondaryBackwards,
        scope void delegate(dchar, SpecialCasing) @safe nothrow @nogc handle, UnicodeLanguage language) {

    if (primaryForwards is null)
        return ErrorResult(NullPointerException("Primary forwards delegate must not be null"));
    else if (secondaryForwards is null)
        return ErrorResult(NullPointerException("Secondary forwards delegate must not be null"));
    else if (secondaryBackwards is null)
        return ErrorResult(NullPointerException("Secondary backwards delegate must not be null"));

    PrimaryLoop: foreach (primaryCharacter; primaryForwards) {
        immutable(SpecialCasing) casing = sidero_utf_lut_getSpecialCasing(primaryCharacter, language);

        final switch (casing.condition) {
        case SpecialCasingCondition.None:
            break;
        case SpecialCasingCondition.Final_Sigma:
            /*
            Final_Sigma: [+] [-]
            (isCased isCaseIgnorable*) C !(isCaseIgnorable* isCased)
            C is preceded by a sequence consisting of a cased letter and then zero or more case-ignorable characters, and
            C is not followed by a sequence consisting of zero or more case-ignorable characters and then a cased letter.
            */

            foreach (secondary; secondaryBackwards) {
                if (isCaseIgnorable(secondary))
                    continue;
                else if (isCased(secondary))
                    break;
                else
                    continue PrimaryLoop;
            }

            foreach (secondary; secondaryForwards) {
                if (isCaseIgnorable(secondary))
                    continue;
                else if (isCased(secondary))
                    continue PrimaryLoop;
                else
                    break;
            }
            break;
        case SpecialCasingCondition.Not_Final_Sigma:
            foreach (secondary; secondaryBackwards) {
                if (isCaseIgnorable(secondary))
                    continue;
                else if (isCased(secondary))
                    continue PrimaryLoop;
                else
                    break;
            }

            foreach (secondary; secondaryForwards) {
                if (isCaseIgnorable(secondary))
                    continue;
                else if (isCased(secondary))
                    break;
                else
                    continue PrimaryLoop;
            }
            break;
        case SpecialCasingCondition.After_Soft_Dotted:
            /*
            After_Soft_Dotted: [+]
            (sidero_utf_lut_isMemberOfSoft_Dotted !(sidero_utf_lut_getCCC >=230 || == 0)*) C
            There is a Soft_Dotted character before C, with no intervening character of combining class 0 or 230 (Above).
             */

            foreach (secondary; secondaryBackwards) {
                if (sidero_utf_lut_isMemberOfSoft_Dotted(secondary))
                    break;

                auto ccc = sidero_utf_lut_getCCC(secondary);
                if (secondary >= 230 || secondary == 0)
                    continue PrimaryLoop;
            }
            break;
        case SpecialCasingCondition.More_Above:
            /*
            More_Above: [+]
            C !(sidero_utf_lut_getCCC == 0)* (sidero_utf_lut_getCCC == 230)
            C is followed by a character of combining class 230 (Above) with no intervening character of combining class 0 or 230 (Above).
            */

            foreach (secondary; secondaryForwards) {
                auto ccc = sidero_utf_lut_getCCC(secondary);

                if (ccc == 0)
                    continue PrimaryLoop;
                else if (ccc == 230)
                    break;
            }
            break;
        case SpecialCasingCondition.After_I:
            /*
            After_I: [+]
            'I' !(sidero_utf_lut_getCCC >=230 || == 0)* C
            There is an uppercase I before C, and there is no intervening combining character class 230 (Above) or 0.
            */

            foreach (secondary; secondaryBackwards) {
                if (secondary == 'I')
                    break;

                auto ccc = sidero_utf_lut_getCCC(secondary);
                if (ccc >= 230 || ccc == 0)
                    continue PrimaryLoop;
            }
            break;
        case SpecialCasingCondition.Not_Before_Dot:
            /*
            Before_Dot: [-]
            C !(sidero_utf_lut_getCCC == 0 || == 230) (== \u0307)
            C is followed by combining dot above (U+0307).
            Any sequence of characters with a combining class that is neither 0 nor 230 may intervene between the current character and the combining dot above.
            */

            foreach (secondary; secondaryForwards) {
                auto ccc = sidero_utf_lut_getCCC(secondary);

                if (ccc == 0 || ccc == 230 || secondary != '\u0307')
                    continue PrimaryLoop;
                break;
            }
            break;
        }

        handle(primaryCharacter, casing);
    }

    return ErrorResult.init;
}
