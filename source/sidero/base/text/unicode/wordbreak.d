module sidero.base.text.unicode.wordbreak;
import sidero.base.text.wordbreak;
import sidero.base.text.unicode.characters.database : isAlpha;
import sidero.base.text.unicode.database;

export:

/**
This function is based upon Unicode's word break algorithm as defined in [TR29](https://unicode.org/reports/tr29/#Word_Boundary_Rules).

Returns:
    Start of next segment offset or -1.
*/
ptrdiff_t findNextWordBreakUnicode(alias Us)(scope ref WordBreaker!(dchar, Us) wordBreaker) @nogc {
    enum sot = typeof(wordBreaker).Entry(0), eot = typeof(wordBreaker).Entry(size_t.max);

    typeof(wordBreaker).Entry lastLeft = sot, left = sot, right = sot, lookahead = sot;
    size_t offsetLengthLeft, consecutiveRI, amountSkipped1, amountSkipped2;

    void advanceLookAhead() {
        if(lookahead.entriesForValue < size_t.max) {
            amountSkipped2 += lookahead.entriesForValue;
        }

        if(wordBreaker.haveValueDel()) {
            lookahead = wordBreaker.nextDel();
        } else {
            lookahead = eot;
        }
    }

    void advance() {
        if(right.entriesForValue < size_t.max) {
            offsetLengthLeft += right.entriesForValue;
        }

        offsetLengthLeft += amountSkipped1;
        amountSkipped1 = amountSkipped2;
        amountSkipped2 = 0;

        right = lookahead;

        if(wordBreaker.haveValueDel()) {
            lookahead = wordBreaker.nextDel();
        } else {
            lookahead = eot;
        }
    }

    void advanceAndMoveLeft() {
        lastLeft = left;
        left = right;

        advance();
    }

    advance();
    advance();

    Loop: for(;;) {
        version(none) {
            debugWritefln!"lastLeft: %d %X, left: %d %X, right: %d %X, lookahead: %d %X, amountSkipped: %s %s"(lastLeft.entriesForValue,
                    lastLeft.value, left.entriesForValue,
                    left.value, right.entriesForValue, right.value, lookahead.entriesForValue, lookahead.value,
                    amountSkipped1, amountSkipped2);
        }

        if(left == sot) {
            // WB1, but we ignore this as no-op

            version(none) {
                debugWriteln("WB1");
            }

            advanceAndMoveLeft();
            continue;
        } else if(right == eot) {
            // WB2, and we are done
            version(none) {
                debugWriteln("WB2");
            }

            return offsetLengthLeft + amountSkipped1 + amountSkipped2;
        }

        if(left == '\r' && right == '\n') {
            // WB3
            version(none) {
                debugWriteln("WB3");
            }

            advanceAndMoveLeft();
            continue;
        } else if(left == '\r' || left == '\n' || isNewLine(left.value)) {
            // WB3a
            version(none) {
                debugWriteln("WB3a");
            }

            return offsetLengthLeft;
        } else if(right == '\r' || right == '\n' || isNewLine(right.value)) {
            // WB3b
            version(none) {
                debugWriteln("WB3b");
            }

            return offsetLengthLeft;
        } else if(left == 0x200D && sidero_utf_lut_isMemberOfExtended_Pictographic(right.value)) {
            // WB3c
            version(none) {
                debugWriteln("WB3c");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isWSegSpace(left.value) && isWSegSpace(right.value)) {
            // WB3d
            version(none) {
                debugWriteln("WB3d");
            }

            advanceAndMoveLeft();
            continue;
        }

        version(none) {
            debugWritefln!"\tlastLeft: %d %X, left: %d %X, right: %d %X, lookahead: %d %X, amountSkipped: %s %s"(lastLeft.entriesForValue,
                    lastLeft.value, left.entriesForValue,
                    left.value, right.entriesForValue, right.value, lookahead.entriesForValue, lookahead.value,
                    amountSkipped1, amountSkipped2);
        }

        for(;;) {
            if(right == eot) {
                // WB2
                version(none) {
                    debugWriteln("WB2");
                }

                return offsetLengthLeft + amountSkipped1 + amountSkipped2;
            } else if(!(isNewLine(left.value) || left == '\r' || left == '\n') && (right == 0x200D ||
                    isExtend(right.value) || isFormat(right.value))) {
                // WB4

                if(right == 0x200D && sidero_utf_lut_isMemberOfExtended_Pictographic(lookahead.value)) {
                    version(none) {
                        debugWriteln("WB4-1 -> WB3c");
                    }

                    advanceAndMoveLeft();
                    continue Loop;
                }

                version(none) {
                    debugWriteln("WB4-1");
                }

                advance();
            } else
                break;
        }

        version(none) {
            debugWritefln!"\tlastLeft: %d %X, left: %d %X, right: %d %X, lookahead: %d %X, amountSkipped: %s %s"(lastLeft.entriesForValue,
                    lastLeft.value, left.entriesForValue,
                    left.value, right.entriesForValue, right.value, lookahead.entriesForValue, lookahead.value,
                    amountSkipped1, amountSkipped2);
        }

        for(;;) {
            if(lookahead == 0x200D || isExtend(lookahead.value) || isFormat(lookahead.value)) {
                // WB4
                version(none) {
                    debugWriteln("WB4-2");
                }

                advanceLookAhead();
            } else
                break;
        }

        version(none) {
            debugWritefln!"\tlastLeft: %d %X, left: %d %X, right: %d %X, lookahead: %d %X, amountSkipped: %s %s"(lastLeft.entriesForValue,
                    lastLeft.value, left.entriesForValue,
                    left.value, right.entriesForValue, right.value, lookahead.entriesForValue, lookahead.value,
                    amountSkipped1, amountSkipped2);
        }

        if(isAHLetter(left.value) && isAHLetter(right.value)) {
            // WB5
            version(none) {
                debugWriteln("WB5");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isAHLetter(left.value) && (isMidLetter(right.value) || isMidNumLetQ(right.value)) && isAHLetter(lookahead.value)) {
            // WB6
            version(none) {
                debugWriteln("WB6");
            }

            advance();
            advanceAndMoveLeft();
            continue;
        } else if(isAHLetter(lastLeft.value) && (isMidLetter(left.value) || isMidNumLetQ(left.value)) && isAHLetter(right.value)) {
            // WB7
            version(none) {
                debugWriteln("WB7");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isHebrewLetter(left.value) && right == 0x27) {
            // WB7a
            version(none) {
                debugWriteln("WB7a");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isHebrewLetter(left.value) && right == 0x22 && isHebrewLetter(lookahead.value)) {
            // WB7b
            version(none) {
                debugWriteln("WB7b");
            }

            advance();
            advanceAndMoveLeft();
            continue;
        } else if(isHebrewLetter(lastLeft.value) && left == 0x22 && isHebrewLetter(right.value)) {
            // WB7c
            version(none) {
                debugWriteln("WB7c");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isNumeric(left.value) && isNumeric(right.value)) {
            // WB8
            version(none) {
                debugWriteln("WB8");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isAHLetter(left.value) && isNumeric(right.value)) {
            // WB9
            version(none) {
                debugWriteln("WB9");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isNumeric(left.value) && isAHLetter(right.value)) {
            // WB10
            version(none) {
                debugWriteln("WB10");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isNumeric(lastLeft.value) && (isMidNum(left.value) || isMidNumLetQ(left.value)) && isNumeric(right.value)) {
            // WB11
            version(none) {
                debugWriteln("WB11");
            }

            advanceAndMoveLeft();
            continue;
        } else if(isNumeric(left.value) && (isMidNum(right.value) || isMidNumLetQ(right.value)) && isNumeric(lookahead.value)) {
            // WB12
            version(none) {
                debugWriteln("WB12");
            }

            advance();
            advanceAndMoveLeft();
            continue;
        } else if(isKatakana(left.value) && isKatakana(right.value)) {
            // WB13
            version(none) {
                debugWriteln("WB13");
            }

            advanceAndMoveLeft();
            continue;
        } else if((isAHLetter(left.value) || isNumeric(left.value) || isKatakana(left.value) || isExtendNumLet(left.value)) &&
                isExtendNumLet(right.value)) {
            // WB13a
            version(none) {
                debugWriteln("WB13a");
            }

            advanceAndMoveLeft;
            continue;
        } else if(isExtendNumLet(left.value) && (isAHLetter(right.value) || isNumeric(right.value) || isKatakana(right.value))) {
            // WB13b
            version(none) {
                debugWriteln("WB13b");
            }

            advanceAndMoveLeft;
            continue;
        } else if(sidero_utf_lut_isMemberOfRegional_Indicator(left.value) && sidero_utf_lut_isMemberOfRegional_Indicator(right.value)) {
            // WB15 WB16
            version(none) {
                debugWriteln("WB15 W16");
            }

            consecutiveRI++;
            advanceAndMoveLeft();

            if(offsetLengthLeft > 0) {
                return offsetLengthLeft + amountSkipped1 + amountSkipped2;
            } else if((consecutiveRI & 1) > 0) {
                continue;
            } else {
                return offsetLengthLeft;
            }
        } else {
            // WB999
            version(none) {
                debugWriteln("WB999");
                debugWritefln!"lastLeft: %d %X, left: %d %X, right: %d %X, lookahead: %d %X, amountSkipped: %s %s"(
                        lastLeft.entriesForValue, lastLeft.value,
                        left.entriesForValue, left.value, right.entriesForValue, right.value,
                        lookahead.entriesForValue, lookahead.value, amountSkipped1, amountSkipped2);
            }

            if(left == sot)
                advanceAndMoveLeft();

            return offsetLengthLeft;
        }
    }

    assert(0);
}

@safe nothrow @nogc pure:

version(none) {
    void debugWritefln(string fmt, Args...)(scope Args args, int line = __LINE__) {
        try {
            import std.stdio;

            debug write("#", line, ": ");
            debug writefln!fmt(args);
        } catch(Exception) {
        }
    }

    void debugWriteln(Args...)(scope Args args, int line = __LINE__) {
        try {
            import std.stdio;

            debug writeln("#", line, ": ", args);
        } catch(Exception) {
        }
    }
}

///
bool isWSegSpace(dchar input) {
    return sidero_utf_lut_getGeneralCategory(input) == GeneralCategory.Zs && sidero_utf_lut_getLineBreakClass(input) != LineBreakClass.GL;
}

///
bool isALetter(dchar input) {
    switch(input) {
    case 0x02C2: .. case 0x02C5:
    case 0x02D2: .. case 0x02D7:
    case 0x02DE:
    case 0x02DF:
    case 0x02E5: .. case 0x02EB:
    case 0x02ED:
    case 0x02EF: ..
    case 0x02FF:
    case 0x055A:
    case 0x055B:
    case 0x055C:
    case 0x055E:
    case 0x058A:
    case 0x05F3:
    case 0xA708: .. case 0xA716:
    case 0xA720:
    case 0xA721:
    case 0xA789:
    case 0xA78A:
    case 0xAB5B:
        return true;

    default:
        if(!input.isAlpha)
            return false;

        auto wbp = sidero_utf_lut_getWordBreakProperty(input);
        return !(sidero_utf_lut_isMemberOfIdeographic(input) || wbp == WordBreakProperty.Katakana || wbp == WordBreakProperty.Extend ||
                wbp == WordBreakProperty.Hebrew_Letter || sidero_utf_lut_getLineBreakClass(input) == LineBreakClass.SA ||
                sidero_utf_lut_isScriptHiragana(input));
    }
}

///
bool isHebrewLetter(dchar input) {
    return sidero_utf_lut_isScriptHebrew(input) && sidero_utf_lut_getGeneralCategory(input) == GeneralCategory.Lo;
}

///
bool isAHLetter(dchar input) {
    return isALetter(input) || isHebrewLetter(input);
}

///
bool isMidLetter(dchar input) {
    switch(input) {
    case 0x3A:
    case 0xB7:
    case 0x0387:
    case 0x055F:
    case 0x05F4:
    case 0x2027:
    case 0xFE13:
    case 0xFE55:
    case 0xFF1A:
        return true;
    default:
        return false;
    }
}

///
bool isMidNumLet(dchar input) {
    switch(input) {
    case 0x2E:
    case 0x2018:
    case 0x2019:
    case 0x2024:
    case 0xFE52:
    case 0xFF07:
    case 0xFF0E:
        return true;
    default:
        return false;
    }
}

///
bool isMidNumLetQ(dchar input) {
    return isMidNumLet(input) || input == 0x27;
}

///
bool isMidNum(dchar input) {
    switch(input) {
    case 0x066C:
    case 0xFE50:
    case 0xFE54:
    case 0xFF0C:
    case 0xFF1B:
        return true;
    case 0x3A:
    case 0xFE13:
    case 0x2E:
        return false;
    default:
        return sidero_utf_lut_getLineBreakClass(input) == LineBreakClass.IS;
    }
}

///
bool isKatakana(dchar input) {
    switch(input) {
    case 0x3031:
    case 0x3032:
    case 0x3033:
    case 0x3034:
    case 0x3035:
    case 0x309B:
    case 0x309C:
    case 0x30A0:
    case 0x30FC:
    case 0xFF70:
        return true;

    default:
        return sidero_utf_lut_isScriptKatakana(input);
    }
}

///
bool isExtendNumLet(dchar input) {
    return input == 0x202F || sidero_utf_lut_getGeneralCategory(input) == GeneralCategory.Pc;
}

///
bool isNumeric(dchar input) {
    switch(input) {
    case 0xFF10: .. case 0xFF19:
        return true;
    case 0x066C:
        return false;
    default:
        return sidero_utf_lut_getWordBreakProperty(input) == WordBreakProperty.Numeric;
    }
}

///
bool isExtend(dchar input) {
    if(input == 0x200D)
        return false;
    return isUnicodeGraphemeExtend(input) || sidero_utf_lut_getGeneralCategory(input) == GeneralCategory.Mc ||
        sidero_utf_lut_isMemberOfEmoji_Modifier(input);
}

///
bool isFormat(dchar input) {
    switch(input) {
    case 0x200B:
    case 0x200C:
    case 0x200D:
        return false;
    default:
        return sidero_utf_lut_getGeneralCategory(input) == GeneralCategory.Cf;
    }
}

///
bool isNewLine(dchar input) {
    switch(input) {
    case 0xB:
    case 0xC:
    case 0x85:
    case 0x2028:
    case 0x2029:
        return true;
    default:
        return false;
    }
}
