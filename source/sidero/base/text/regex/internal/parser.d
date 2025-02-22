module sidero.base.text.regex.internal.parser;
import sidero.base.text.regex.internal.state;
import sidero.base.text.regex.internal.ast;
import sidero.base.text.regex.pattern;
import sidero.base.text;
import sidero.base.containers.set.interval;
import sidero.base.containers.dynamicarray;
import sidero.base.math.interval;

@safe nothrow @nogc:

RegexNFANode* parse(String_UTF8 contents, RegexState* regexState, RegexMode mode, ErrorSinkRef errorSink) @trusted {
    assert(!errorSink.isNull);

    if(!contents.isPtrNullTerminated)
        contents = contents.dup;
    regexState.pattern = contents;

    Parser parser = Parser(contents, regexState, errorSink);

    {
        if(mode.asSingleLine)
            regexState.any_supports_newline = true;
        if(mode.multiline)
            regexState.try_start_after_each_newline = true;
        else
            regexState.try_start_after_stride = !mode.anchored;
    }

    {
        if(contents.length > 0 && contents[$ - 1] == "$") {
            uint countBackslash;
            foreach_reverse(c; contents[0 .. $ - 1]) {
                if(c != '\\')
                    break;
                countBackslash++;
            }

            if((countBackslash % 2) == 0) {
                contents = contents[0 .. $ - 1];

                if(mode.multiline)
                    regexState.require_end_before_newline = true;
                else
                    regexState.require_end_at_end = true;
            }
        }

        if(contents.length > 0 && contents[0] == "^") {
            contents = contents[1 .. $];
            parser.locPos.lineOffset++;
            regexState.require_start_at_newline = true;
        }
    }

    uint alternativeGroups;
    RegexNFANode* parsed = parser.parseChild(alternativeGroups);
    if(errorSink.haveError) {
        return null;
    }

    regexState.groupsCount = parser.captureIdCount;
    RegexNFANode* ret = parsed;

    if(alternativeGroups > 1) {
        ret = regexState.createNode(parser.countNodes, RegexNFANode.Type.Group, 0, null);
        ret.next1 = parsed;
        ret.groupCaptureId = -1;
    }

    // Detect if we can go cheaper?
    regexState.strategy = RegexMatchStrategy.Stack;
    return ret;
}

struct Parser {
    import sidero.base.encoding.utf : decodeLength, decode;

    Loc locPos;
    RegexState* regexState;
    ErrorSinkRef errorSink;

    const(char)* startOfFile, currentCharacter, endOfFile;
    bool hitError;

    bool ignoreWhiteSpaceInPattern;
    int countNodes;
    int captureIdCount;
    int maxAlternatives, maxDepth;

@safe nothrow @nogc:

    this(String_UTF8 contents, RegexState* regexState, ErrorSinkRef errorSink) @trusted {
        if(contents.length == 0)
            return;

        startOfFile = contents.ptr;
        this.regexState = regexState;
        currentCharacter = startOfFile;
        endOfFile = contents.ptr + contents.length;

        this.errorSink = errorSink;
        assert(!this.errorSink.isNull);
    }

    RegexNFANode* parseChild(out uint alternativeGroups, int depth = 0, bool breakOnEndBracket = false) @trusted {
        alternativeGroups = 1;
        RegexNFANode* headNode = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, null);
        depth++;

        RegexNFANode** lastInSequenceOr = &headNode;
        RegexNFANode* lastSibling = headNode;

        scope(exit) {
            if(this.maxAlternatives < alternativeGroups)
                this.maxAlternatives = alternativeGroups;
            if(this.maxDepth < depth)
                this.maxDepth = depth;
        }

        bool split1PrefixChar() {
            if(lastSibling.next1 is null && lastSibling.type == RegexNFANode.Type.Prefix &&
                    lastSibling.prefixCharacterLastLength > 0 && lastSibling.prefixCharacterLastLength < lastSibling.prefix.length) {
                RegexNFANode* next = regexState.createNode(countNodes, RegexNFANode.Type.Prefix, depth, lastSibling);

                next.prefix = lastSibling.prefix[$ - lastSibling.prefixCharacterLastLength .. $];
                lastSibling.prefix = lastSibling.prefix[0 .. $ - lastSibling.prefixCharacterLastLength];
                lastSibling.prefixCharacterLastLength = 0;

                lastSibling = next;
                return true;
            } else
                return false;
        }

        void handleZeroOrMultiplier(int max) {
            assert(lastSibling.next1 !is null || lastSibling.type == RegexNFANode.Type.Prefix);
            assert(lastSibling.next2 is null);
            split1PrefixChar();

            lastSibling.min = 0;
            lastSibling.max = max;

            /*
                                     lastSibling
                {next1 ->             \/
                {                     -->
                {next2 ->             /\
                after next success

                or

                                     lastSibling
                {next1
                {                     -->
                {next2 ->             /\
                after next success -> /\
            */

            lastSibling.afterNextSuccess = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, null);
            lastSibling.next2 = lastSibling.afterNextSuccess;
            lastSibling = lastSibling.next2;
        }

        Loop: while(currentCharacter < endOfFile) {
            char asciiChar = *currentCharacter;

            currentCharacter++;
            this.locPos.lineOffset++;

            switch(asciiChar) {
            case 0:
                break Loop;

            case '?': {
                    handleZeroOrMultiplier(1);
                    break;
                }

            case '*': {
                    handleZeroOrMultiplier(int.max);
                    break;
                }

            case '+': {
                    split1PrefixChar();

                    lastSibling.min = 1;
                    lastSibling.max = int.max;

                    if(lastSibling.type == RegexNFANode.Type.Group) {
                        lastSibling.afterNextSuccess = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, null);
                        lastSibling = lastSibling.afterNextSuccess;
                    }

                    assert(lastSibling.next1 is null);
                    break;
                }

            case '.': {
                    if(lastSibling.type != RegexNFANode.Type.Infer)
                        lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Any, depth, lastSibling);
                    lastSibling.type = RegexNFANode.Type.Any;
                    break;
                }

            case '{': {
                    int newmin = 1, newmax = 1;

                    lexDecimalNumber(newmin);

                    // ,
                    if(*currentCharacter == ',') {
                        currentCharacter++;
                        locPos.lineOffset++;

                        if(*currentCharacter != '}') {
                            lexDecimalNumber(newmax);
                        } else
                            newmax = newmin;
                    } else
                        newmax = newmin;

                    if(newmin > newmax) {
                        errorSink.error(this.locPos, String_UTF8("Max must be greater than min"));
                        return null;
                    }

                    if(newmax == 0) {
                        errorSink.error(this.locPos, String_UTF8("Min/Max max must be greater than zero"));
                        return null;
                    }

                    if(newmin == 0)
                        handleZeroOrMultiplier(newmax);
                    else {
                        lastSibling.min = newmin;
                        lastSibling.max = newmax;

                        if(lastSibling.type == RegexNFANode.Type.Group) {
                            lastSibling.afterNextSuccess = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, null);
                            lastSibling = lastSibling.afterNextSuccess;
                        }
                    }

                    assert(lastSibling.next1 is null);
                    break;
                }

                // will sibling+child
            case '(': {
                    assert(lastSibling.next1 is null);
                    bool capture, assertForwards, assertNotForwards;

                    if(*currentCharacter == '?') {
                        // capture

                        if(*(currentCharacter + 1) == '#') {
                            // comment, ignore this group
                            currentCharacter += 2;
                            this.locPos.lineOffset += 2;

                            int countOpenBracket = 1;

                            while(countOpenBracket > 0 && currentCharacter < endOfFile) {
                                if(*currentCharacter == '\\' && *(currentCharacter + 1) == '(') {
                                    currentCharacter += 2;
                                    this.locPos.lineOffset += 2;
                                } else if(*currentCharacter == '(') {
                                    countOpenBracket++;
                                    currentCharacter++;
                                    this.locPos.lineOffset++;
                                } else if(*currentCharacter == ')') {
                                    countOpenBracket--;
                                    currentCharacter++;
                                    this.locPos.lineOffset++;
                                } else {
                                    const(char)[] str;
                                    currentCharacter++;

                                    grabOrSliceString(*currentCharacter, str);
                                    if(errorSink.haveError)
                                        return null;
                                }
                            }

                            if(countOpenBracket > 0) {
                                errorSink.error(this.locPos, String_UTF8("Unmatched `()` brackets in comment group"));
                                return null;
                            }

                            if(lastSibling.type != RegexNFANode.Type.Infer)
                                lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, lastSibling);
                            continue Loop;
                        } else if(*(currentCharacter + 1) == '>') {
                            currentCharacter += 2;
                            this.locPos.lineOffset += 2;
                            assertForwards = true;
                        } else if(*(currentCharacter + 1) == '<') {
                            errorSink.error(this.locPos, String_UTF8("Assert backwards is currently not supported"));
                            return null;
                        } else if(*(currentCharacter + 1) == '!' && *(currentCharacter + 2) == '>') {
                            currentCharacter += 3;
                            this.locPos.lineOffset += 3;
                            assertNotForwards = true;
                        } else if(*(currentCharacter + 1) == '!' && *(currentCharacter + 2) == '<') {
                            errorSink.error(this.locPos, String_UTF8("Assert not backwards is currently not supported"));
                            return null;
                        } else {
                            currentCharacter++;
                            this.locPos.lineOffset++;
                            capture = true;
                        }
                    }

                    if(lastSibling.type != RegexNFANode.Type.Infer)
                        lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, lastSibling);

                    uint alternativeGroups2;
                    lastSibling.next1 = parseChild(alternativeGroups2, depth, true);
                    if(errorSink.haveError)
                        return null;

                    lastSibling.groupCaptureId = capture ? this.captureIdCount++ : -1;

                    if(assertNotForwards)
                        lastSibling.type = RegexNFANode.Type.AssertNotForward;
                    else if(assertForwards)
                        lastSibling.type = RegexNFANode.Type.AssertForward;
                    else
                        lastSibling.type = RegexNFANode.Type.Group;

                    if(currentCharacter < endOfFile) {
                        if(*currentCharacter == ')') {
                            // all is ok
                            currentCharacter++;
                            this.locPos.lineOffset++;
                        } else {
                            errorSink.error(this.locPos, String_UTF8("Unmatched `()` brackets in group found EOL instead"));
                            return null;
                        }
                    }

                    asciiChar = *currentCharacter;

                    if(asciiChar == '?') {
                        currentCharacter++;
                        this.locPos.lineOffset++;
                        goto case '?';
                    } else if(asciiChar == '*') {
                        currentCharacter++;
                        this.locPos.lineOffset++;
                        goto case '*';
                    } else if(asciiChar == '+') {
                        currentCharacter++;
                        this.locPos.lineOffset++;
                        goto case '+';
                    } else if(asciiChar == '{') {
                        currentCharacter++;
                        this.locPos.lineOffset++;
                        goto case '{';
                    }

                    lastSibling.afterNextSuccess = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, null);
                    lastSibling = lastSibling.afterNextSuccess;
                    break;
                }

            case ')': {
                    if(breakOnEndBracket) {
                        currentCharacter--;
                        this.locPos.lineOffset--;
                        break Loop;
                    } else if(currentCharacter >= endOfFile) {
                        break Loop;
                    } else {
                        errorSink.error(this.locPos, String_UTF8("Unexpected end bracket `)`"));
                        errorSink.errorSupplemental(String_UTF8("Did you intend to escape it? `\\)`"));
                        return null;
                    }
                }

                // will sibling
            case '|': {
                    alternativeGroups++;
                    depth++;

                    RegexNFANode* nextNext2;

                    if((*lastInSequenceOr).next2 !is null && (*lastInSequenceOr).next2.type == RegexNFANode.Type.Infer) {
                        nextNext2 = (*lastInSequenceOr).next2;
                        (*lastInSequenceOr).next2 = null;

                        if((*lastInSequenceOr).afterNextSuccess is nextNext2)
                            (*lastInSequenceOr).afterNextSuccess = null;
                        if((*lastInSequenceOr).next1 is nextNext2)
                            (*lastInSequenceOr).next1 = null;

                        nextNext2.depth = depth;
                    } else
                        nextNext2 = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, null);

                    if((*lastInSequenceOr).next2 is null) {
                        (*lastInSequenceOr).next2 = nextNext2;
                        lastSibling = (*lastInSequenceOr).next2;
                        lastInSequenceOr = &(*lastInSequenceOr).next2;
                    } else {
                        nextNext2.depth = depth;

                        RegexNFANode* replacementOr = regexState.createNode(countNodes, RegexNFANode.Type.Group, depth - 1, null);
                        depth++;

                        replacementOr.next1 = *lastInSequenceOr;
                        replacementOr.next2 = nextNext2;
                        replacementOr.groupCaptureId = -1;

                        *lastInSequenceOr = replacementOr;
                        lastSibling = nextNext2;
                    }

                    break;
                }

                // will sibling
            case '[': {
                    if(lastSibling.type != RegexNFANode.Type.Infer)
                        lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Ranges, depth, lastSibling);
                    lastSibling.type = RegexNFANode.Type.Ranges;

                    static void addRange(ref IntervalSet!dchar current, dchar start, dchar end) {
                        current.insert(start, end);
                    }

                    static void addSingles(ref IntervalSet!dchar current, const(char)[] options) nothrow {
                        while(options.length > 0) {
                            dchar got;
                            const len = decode(options, got);
                            options = options[len .. $];

                            addRange(current, got, got);
                        }
                    }

                    /*
                    || union_       union: A∪B (explicit operator where desired for clarity)
                    && intersect    intersection: A∩B
                    -- difference   set difference: A∖B
                    ~~              symmetric difference: A⊖B = (A∪B)\(A∩B)
                    */

                    // [ ^ ...
                    // Relation [ ^ ... ]
                    // Relation ...
                    // ]

                    IntervalSet!dchar collect(bool consumeEnd) nothrow {
                        IntervalSet!dchar ret;
                        bool invert;

                        void handleSet(IntervalSet!dchar set) {
                            foreach(Interval!dchar r; set) {
                                ret.insert(r);
                            }
                        }

                        void handleRange(dchar start, dchar end) {
                            addRange(ret, start, end);
                        }

                        void handleSingle(dchar c) {
                            addRange(ret, c, c);
                        }

                        const(char)[] lastGot, lastGotRange, soFar;

                        if(*currentCharacter == '^') {
                            currentCharacter++;
                            this.locPos.lineOffset++;
                            invert = true;
                        }

            CCLoop: while(currentCharacter < endOfFile && *currentCharacter != ']') {
                            asciiChar = *currentCharacter;
                            currentCharacter++;
                            this.locPos.lineOffset++;

                            switch(asciiChar) {
                            case '\\':
                                parseEscape(&handleSingle, &handleRange, &handleSet);
                                if(errorSink.haveError)
                                    return IntervalSet!dchar.init;
                                break;

                            case '|':
                            case '&':
                            case '~':
                            SetOps:
                                if(*currentCharacter == asciiChar) {
                                    char op = asciiChar;

                                    const willNeedEnd = *(currentCharacter + 1) == '[';

                                    if(willNeedEnd) {
                                        currentCharacter += 2;
                                        this.locPos.lineOffset += 2;
                                    } else {
                                        currentCharacter++;
                                        this.locPos.lineOffset++;
                                    }

                                    if(lastGot !is null)
                                        reSliceString(soFar, lastGot);

                                    addSingles(ret, soFar);
                                    soFar = null;

                                    IntervalSet!dchar second = collect(willNeedEnd);

                                    switch(op) {
                                    case '|':
                                        ret = ret.union_(second);
                                        break CCLoop;
                                    case '&':
                                        ret = ret.intersect(second);
                                        break CCLoop;
                                    case '-':
                                        ret = ret.difference(second);
                                        break CCLoop;
                                    case '~':
                                        ret = ret.symmetricDifference(second);
                                        break CCLoop;

                                    default:
                                        assert(0);
                                    }
                                } else
                                    goto default;

                            case '-':
                                if(*currentCharacter == '-')
                                    goto SetOps;

                                if((lastGot is null && lastGotRange is null) || currentCharacter >= endOfFile || *currentCharacter == ']') {
                                    // prefix covers: ac- and -ac
                                    // https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap09.html#tag_09_03_05
                                    goto default;
                                }

                                if(lastGot !is null) {
                                    const(char)[] nextGot;

                                    asciiChar = *currentCharacter;
                                    currentCharacter++;
                                    this.locPos.lineOffset++;

                                    if(asciiChar == ']')
                                        break CCLoop;
                                    grabOrSliceString(asciiChar, nextGot);
                                    if(errorSink.haveError)
                                        return IntervalSet!dchar.init;

                                    dchar lhs, rhs;
                                    decode(lastGot, lhs);
                                    decode(nextGot, rhs);

                                    addRange(ret, lhs, rhs);

                                    lastGot = null;
                                    lastGotRange = nextGot;

                                    reSliceString(soFar, lastGot);
                                    addSingles(ret, soFar);
                                    soFar = null;
                                } else if(lastGotRange !is null) {
                                    const(char)[] nextGot;

                                    asciiChar = *currentCharacter;
                                    currentCharacter++;
                                    this.locPos.lineOffset++;

                                    if(asciiChar == ']')
                                        break CCLoop;
                                    grabOrSliceString(asciiChar, nextGot);
                                    if(errorSink.haveError)
                                        return IntervalSet!dchar.init;

                                    dchar lhs, rhs;
                                    decode(lastGotRange, lhs);
                                    decode(nextGot, rhs);

                                    lastGotRange = nextGot;

                                    reSliceString(soFar, lastGot);
                                    addSingles(ret, soFar);
                                    soFar = null;
                                } else {
                                    asciiChar = *currentCharacter;
                                    currentCharacter++;
                                    this.locPos.lineOffset++;

                                    if(asciiChar == ']')
                                        break CCLoop;
                                    grabOrSliceString(asciiChar, soFar);
                                    if(errorSink.haveError)
                                        return IntervalSet!dchar.init;
                                }
                                break;

                            default:
                                if(lastGot !is null) {
                                    reSliceString(soFar, lastGot);
                                    lastGot = null;
                                }

                                grabOrSliceString(asciiChar, lastGot);
                                if(errorSink.haveError)
                                    return IntervalSet!dchar.init;
                                break;
                            }
                        }

                        if(lastGot !is null)
                            reSliceString(soFar, lastGot);

                        addSingles(ret, soFar);
                        soFar = null;

                        if(consumeEnd) {
                            if(*currentCharacter == ']') {
                                currentCharacter++;
                                this.locPos.lineOffset++;
                            } else {
                                errorSink.error(this.locPos, String_UTF8("Missing square brace"));
                                return IntervalSet!dchar.init;
                            }
                        }

                        if(invert)
                            return ret.invert();
                        else
                            return ret;
                    }

                    lastSibling.ranges = collect(true);
                    if(errorSink.haveError)
                        return null;
                    break;
                }

                // might child, will sibling
            case '\\': {
                    switch(*currentCharacter) {
                    case '1': .. case '9': {
                            int dec;
                            if(!lexDecimalNumber(dec)) {
                                errorSink.error(this.locPos,
                                        String_UTF8("Did not successfully parse a decimal number for look back [0-9]+"));
                                return null;
                            } else if(dec < 1) {
                                errorSink.error(this.locPos,
                                        String_UTF8("Did not successfully parse a decimal number for look back [0-9]+"));
                                return null;
                            } else if(dec > this.captureIdCount) {
                                errorSink.error(this.locPos,
                                        String_UTF8("The decimal number parsed was greater than the currently captured group count"));
                                return null;
                            }

                            if(lastSibling.type != RegexNFANode.Type.Infer)
                                lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.LookBehind, depth, lastSibling);

                            lastSibling.type = RegexNFANode.Type.LookBehind;
                            lastSibling.lookBehindGroupOffset = dec - 1;
                            continue Loop;
                        }

                    default: {
                            DynamicArray!char singles;
                            IntervalSet!dchar ranges;

                            void completeRange() @trusted nothrow @nogc {
                                if(ranges.length == 0)
                                    return;

                                if(lastSibling.type != RegexNFANode.Type.Infer)
                                    lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Ranges, depth, lastSibling);

                                lastSibling.type = RegexNFANode.Type.Ranges;
                                lastSibling.ranges = ranges;
                                ranges = IntervalSet!dchar.init;
                            }

                            void completeSingle() @trusted nothrow @nogc {
                                if(singles.length == 0)
                                    return;

                                if(lastSibling.type != RegexNFANode.Type.Infer)
                                    lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Prefix, depth, lastSibling);

                                lastSibling.type = RegexNFANode.Type.Prefix;
                                lastSibling.prefix = singles.asUTF;
                                singles = DynamicArray!char.init;

                                lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Infer, depth, lastSibling);
                            }

                            void handleRange(dchar start, dchar end) @safe nothrow @nogc {
                                completeSingle;
                                ranges.insert(start, end);
                            }

                            void handleRanges(IntervalSet!dchar ranges2) @safe nothrow @nogc {
                                completeSingle;

                                foreach(Interval!dchar r; ranges2) {
                                    ranges.insert(r);
                                }
                            }

                            void handleSingle(dchar c) @safe nothrow @nogc {
                                completeRange;
                                singles ~= c;
                            }

                            parseEscape(&handleSingle, &handleRange, &handleRanges);
                            if(errorSink.haveError)
                                return null;

                            completeRange;
                            completeSingle;
                            continue Loop;
                        }
                    }
                }

            default: {
                    if(!((lastSibling.type == RegexNFANode.Type.Prefix && lastSibling.max == 1) ||
                            lastSibling.type == RegexNFANode.Type.Infer))
                        lastSibling = regexState.createNode(countNodes, RegexNFANode.Type.Prefix, depth, lastSibling);

                    lastSibling.type = RegexNFANode.Type.Prefix;

                    const(char)[] str = lastSibling.prefix.unsafeGetLiteral;
                    lastSibling.prefixCharacterLastLength = grabOrSliceString(asciiChar, str);
                    if(errorSink.haveError)
                        return null;
                    lastSibling.prefix = String_UTF8(str);
                    break;
                }
            }
        }

        return headNode;
    }

    ubyte grabOrSliceString(char asciiChar, ref const(char)[] str) @trusted {
        const len = cast(ubyte)decodeLength(asciiChar);

        if(currentCharacter + len - 1 > this.endOfFile) {
            errorSink.error(this.locPos, String_UTF8("Trying to grab current character slice beyond end of file"));
            return 0;
        }

        const(char)[] theSlice = (currentCharacter - 1)[0 .. len];

        // https://www.unicode.org/reports/tr18/#Line_Boundaries
        if(theSlice.length == 1 && theSlice[0] == '\n') {
            if(str.length > 0 && str[$ - 1] == '\r' && theSlice[0] == '\n') {
                this.locPos.lineOffset--;
            } else {
                this.locPos.lineOffset = 0;
                this.locPos.lineNumber++;
            }
        } else if((theSlice.length == 1 && theSlice[0] == '\r') || theSlice == "\xC2\x85" || (theSlice.length == 3 &&
                (theSlice[0] == 0xE2 && theSlice[1] == 0x80 && (theSlice[2] == 0xA8 || theSlice[2] == 0xA9)))) {
            this.locPos.lineOffset = 0;
            this.locPos.lineNumber++;
        }

        if(str !is null)
            str = str.ptr[0 .. str.length + len];
        else
            str = theSlice;

        currentCharacter += len - 1;
        this.locPos.lineOffset++;
        return len;
    }

    void reSliceString(ref const(char)[] output, const(char)[] input) @trusted {
        if(output !is null)
            output = output.ptr[0 .. output.length + input.length];
        else
            output = input;
    }

    bool lexDecimalNumber(ref int value) @trusted {
        import core.stdc.math : pow;

        const(char)* startOfToken = currentCharacter;

        while(*currentCharacter == '_' || *currentCharacter >= '0' && *currentCharacter <= '9') {
            if(*currentCharacter != '_') {
                value *= 10;
                value += (*currentCharacter) - '0';
            }

            currentCharacter++;
            this.locPos.lineOffset++;
        }

        return startOfToken !is currentCharacter;
    }

    void parseEscape(scope void delegate(dchar) @safe nothrow @nogc single, scope void delegate(dchar start,
            dchar end) @safe nothrow @nogc range, scope void delegate(IntervalSet!dchar) @safe nothrow @nogc ranges) @trusted {
        void gotSingle(dchar c) @trusted {
            currentCharacter++;
            this.locPos.lineOffset++;
            single(c);
        }

        bool parseHex(ref dchar temp) @trusted {
            char c = *currentCharacter;
            uint next;

            switch(c) {
            case 'a': .. case 'f':
                next = (c - 'a') + 10;
                break;
            case 'A': .. case 'F':
                next = (c - 'A') + 10;
                break;

            case '0': .. case '9':
                next = c - '0';
                break;

            default:
                return false;
            }

            currentCharacter++;
            this.locPos.lineOffset++;

            temp <<= 4;
            temp |= next;
            return true;
        }

        char asciiChar = *currentCharacter;

        switch(asciiChar) {
        case '"':
        case '$':
        case '\'': .. case '+':
        case '-':
        case '.':
        case '?':
        case '[': .. case '^':
        case '{':
        case '|':
            return gotSingle(asciiChar);

        case 'n':
            return gotSingle('\n');
        case 'r':
            return gotSingle('\r');
        case 't':
            return gotSingle('\t');
        case 'v':
            return gotSingle('\v');
        case 'a':
            return gotSingle('\a');
        case 'b':
            return gotSingle('\b');
        case 'f':
            return gotSingle('\f');
        case '0':
            return gotSingle('\0');

        case 'x':
        case 'u':
        case 'U': {
                currentCharacter++;
                uint todo = asciiChar == 'x' ? 2 : (asciiChar == 'u' ? 4 : 8);
                dchar temp = 0;

                foreach(_; 0 .. todo) {
                    if(!parseHex(temp)) {
                        errorSink.error(this.locPos,
                                String_UTF8("A hex escape are pairs of [0-9a-fA-F], with \\x being one, \\u two, and \\U four"));
                        return;
                    }
                }

                currentCharacter--;
                return gotSingle(temp);
            }

        default:
            errorSink.error(this.locPos, String_UTF8("Unrecognized escape"));
            return;
        }
    }
}
