module sidero.base.text.unicode.casing;

/**

isCased
isCaseIgnorable
sidero_utf_lut_isMemberOfSoft_Dotted
sidero_utf_lut_getCCC
sidero_utf_lut_getSpecialCasing(language)

Final_Sigma: [+] [-]
(isCased isCaseIgnorable*) C !(isCaseIgnorable* isCased)
    C is preceded by a sequence consisting of a cased letter and then zero or more case-ignorable characters, and
    C is not followed by a sequence consisting of zero or more case-ignorable characters and then a cased letter.

After_Soft_Dotted: [+]
(sidero_utf_lut_isMemberOfSoft_Dotted !(sidero_utf_lut_getCCC >=230 || == 0)*) C
    There is a Soft_Dotted character before C, with no intervening character of combining class 0 or 230 (Above).

More_Above: [+]
C !(sidero_utf_lut_getCCC == 0)* (sidero_utf_lut_getCCC == 230)
    C is followed by a character of combining class 230 (Above) with no intervening character of combining class 0 or 230 (Above).

Before_Dot: [-]
C !(sidero_utf_lut_getCCC == 0 || == 230) (== \u0307)
    C is followed by combining dot above (U+0307).
    Any sequence of characters with a combining class that is neither 0 nor 230 may intervene between the current character and the combining dot above.

After_I: [+]
'I' !(sidero_utf_lut_getCCC >=230 || == 0)* C
    There is an uppercase I before C, and there is no intervening combining character class 230 (Above) or 0.

*/
