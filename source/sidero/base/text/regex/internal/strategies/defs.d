module sidero.base.text.regex.internal.strategies.defs;
import sidero.base.text.regex.internal.ast;
import sidero.base.text.regex.internal.state;
import sidero.base.text.regex.internal.state_match;
import sidero.base.text.regex.matching;
import sidero.base.text.processing;
import sidero.base.text;
import sidero.base.allocators;
import sidero.base.encoding.utf : decodeLength, decode;
import sidero.base.datetime;

@safe nothrow @nogc:

MatchState* processNextMatch(RegexState* regexState, MatchState* previousMatchState, String_UTF8 input = String_UTF8.init) @trusted {
    static import sidero.base.text.regex.internal.strategies.stack;
    static import sidero.base.text.regex.internal.strategies.old;

    if(!((previousMatchState !is null && previousMatchState.after.text.length != 0) || (previousMatchState is null && input.length != 0))) {
        return null;
    }

    MatchState* matchState = regexState.allocator.make!MatchState;
    matchState.rc(true);
    matchState.regexState = regexState;
    matchState.regexState.rc(true);

    if(previousMatchState !is null) {
        matchState.inputForThis = previousMatchState.after.text;
        matchState.all = previousMatchState.all;
    } else {
        matchState.inputForThis = input;
        matchState.all.text = input;
    }

    if(regexState.groupsCount > 0)
        matchState.groups.length = regexState.groupsCount;

    MatchInProgressState mips = MatchInProgressState(matchState.inputForThis.ptr, matchState.inputForThis.ptr,
            matchState.inputForThis.ptr + matchState.inputForThis.length);
    mips.inProgress.parent = &mips;
    mips.inProgress.currentPtr = matchState.inputForThis.ptr;
    mips.inProgress.matchState = matchState;
    mips.sw.start;

    sidero.base.text.regex.internal.strategies.stack.StackStrategyState strategy_stack;
    bool function(ref MatchInProgressState) @safe nothrow @nogc attemptMatch;

    final switch(regexState.strategy) {
    case RegexMatchStrategy.Stack:
        mips.strategy = cast(void*)&strategy_stack;
        attemptMatch = &sidero.base.text.regex.internal.strategies.stack.attemptMatch;
        break;

    case RegexMatchStrategy.Old:
        attemptMatch = &sidero.base.text.regex.internal.strategies.old.attemptMatch;
        break;
    }

    void processedBefore() {
        matchState.before.text = matchState.inputForThis[0 .. mips.inProgress.currentPtr - matchState.inputForThis.ptr];

        foreach(ref group; matchState.groups) {
            group.text = String_UTF8.init;
        }
    }

    void processAfter() {
        String_UTF8 temp = matchState.inputForThis[mips.startPtr - matchState.inputForThis.ptr .. $];
        matchState.span.text = temp[0 .. mips.inProgress.currentPtr - mips.startPtr];
    }

    bool handleEndAnchor() {
        if(mips.inProgress.currentPtr >= mips.endPtr) {
            // $ is handled if it was set (everything consumed)
            return true;
        } else if(regexState.require_end_before_newline) {
            return mips.inProgress.matchNewLineForwards() > 0;
        } else if(regexState.require_end_at_end) {
            return false;
        }

        return true;
    }

    bool success = true;

    if(regexState.try_start_after_each_newline) {
        // ^ matches after each new line that is seen (or at very start)

        if(regexState.require_start_at_newline) {
            while(mips.sw.peek < regexState.limiter.time) {
                mips.inProgress.consumeNewLine();
                processedBefore;

                if(!mips.isCurrentlyAfterNewLine) {
                    success = false;
                    goto Complete;
                }

                if(attemptMatch(mips) && handleEndAnchor()) {
                    processAfter;
                    goto Complete;
                }
            }
        } else
            goto Stride;
    } else if(regexState.try_start_after_stride) {
        // ^ matches anywhere this strides to
        goto Stride;
    } else {
        assert(0);
    }

Stride: {
        if(regexState.require_start_at_newline && !mips.isCurrentlyAfterNewLine) {
            success = false;
            goto Complete;
        }

        size_t len;

        while(mips.startPtr < mips.endPtr && mips.sw.peek < regexState.limiter.time) {
            processedBefore;
            const a = attemptMatch(mips), b = handleEndAnchor();

            if(a && b) {
                processAfter;
                goto Complete;
            }

            len = decodeLength(*mips.startPtr);
            mips.startPtr += len;
            mips.inProgress.currentPtr = mips.startPtr;
        }

        success = false;
        goto Complete;
    }

Complete: {
        if(!success) {
            matchState.rc(false);
            if(previousMatchState !is null)
                previousMatchState.next = &failedToMatchState;
            return null;
        }

        {
            String_UTF8 temp = matchState.inputForThis[mips.inProgress.currentPtr - matchState.inputForThis.ptr .. $];
            matchState.after.text = temp[0 .. mips.endPtr - mips.inProgress.currentPtr];
        }

        if(previousMatchState !is null) {
            previousMatchState.next = matchState;
            matchState.rc(true);
        }

        {
            if(matchState.before.text.length > 0)
                matchState.before.byteOffsetFromStartOfInput = matchState.before.text.ptr - matchState.all.text.ptr;
            if(matchState.span.text.length > 0)
                matchState.span.byteOffsetFromStartOfInput = matchState.span.text.ptr - matchState.all.text.ptr;
            if(matchState.after.text.length > 0)
                matchState.after.byteOffsetFromStartOfInput = matchState.after.text.ptr - matchState.all.text.ptr;

            foreach(ref group; matchState.groups) {
                if(group.text.length > 0)
                    group.byteOffsetFromStartOfInput = group.text.ptr - matchState.all.text.ptr;
            }
        }

        matchState.inputForThis = typeof(matchState.inputForThis).init;
        return matchState;
    }
}

struct MatchInProgressState {
    const(char)* realStartPtr;
    const(char)* startPtr;
    const(char)* endPtr;
    MatchingState inProgress;

    StopWatch sw;
    void* strategy;

@safe nothrow @nogc:

    this(ref MatchInProgressState other) {
        this.tupleof = other.tupleof;
    }

    bool isCurrentlyAfterNewLine() @trusted {
        if(inProgress.currentPtr >= endPtr) {
            return false;
        } else {
            size_t[2] matchedNewLine = inProgress.matchNewLinePrior();

            if(matchedNewLine[0] == 0) {
                return false;
            }

            inProgress.currentPtr += matchedNewLine[1];
        }

        return true;
    }
}

struct MatchingState {
    MatchInProgressState* parent;
    const(char)* currentPtr;
    MatchState* matchState;

@safe nothrow @nogc:

    this(ref MatchingState other) {
        this.tupleof = other.tupleof;
    }

    bool checkForPrefix(const(char)[] prefix) @trusted {
        size_t i;

        while(i < prefix.length) {
            const isNewLine = this.matchNewLineForwards;
            const len = decodeLength(*this.currentPtr);

            foreach(j; 0 .. len) {
                if(*this.currentPtr != prefix[i + j]) {
                    return false;
                }

                this.currentPtr++;
            }

            i += len;
        }

        return true;
    }

    void consumeNewLine() @trusted {
        size_t len;

        while((len = matchNewLineForwards()) == 0 && currentPtr < parent.endPtr) {
            len = decodeLength(*currentPtr);
            currentPtr += len;
        }

        if((len = matchNewLineForwards()) > 0) {
            currentPtr += len;
        }
    }

    size_t matchNewLineForwards() @trusted {
        char asciiChar = *currentPtr;

        if(asciiChar == '\0')
            return 0;
        else if(asciiChar == '\n')
            return 1;
        else if(asciiChar == '\r' && *(currentPtr + 1) == '\n')
            return 2;
        else if(asciiChar == '\r')
            return 1;
        else if(asciiChar == 0xC2 && *(currentPtr + 1) == 0x85) // NEL
            return 2;
        else if(asciiChar == 0xE2 && *(currentPtr + 1) == 0x80 && (*(currentPtr + 2) == 0xA8 || *(currentPtr + 2) == 0xA9)) // 2028/2029
            return 3;
        else
            return 0;
    }

    size_t[2] matchNewLinePrior() @trusted {
        if(currentPtr is parent.startPtr)
            return [0, 0];

        char prior = *(currentPtr - 1), current = *currentPtr;

        if(prior == '\r')
            return [1, current == '\n' ? 1 : 0];
        else if(prior == 0xC2 && current == 0x85) // NEL
            return [1, 1];

        if(currentPtr > parent.startPtr + 1) {
            char priorPrior = *(currentPtr - 2);

            if(prior == '\n')
                return [priorPrior == '\r' ? 2 : 1, 0];
            else if(priorPrior == 0xC2 && prior == 0x85) // NEL
                return [2, 0];
            else if(priorPrior == 0xE2 && prior == 0x80 && (current == 0xA8 || current == 0xA9)) // 2028/2029
                return [2, 1];
        } else {
            if(prior == '\n')
                return [1, 0];
        }

        if(currentPtr > parent.startPtr + 2) {
            char priorPriorPrior = *(currentPtr - 3), priorPrior = *(currentPtr - 2);

            if(priorPriorPrior == 0xE2 && priorPrior == 0x80 && (prior == 0xA8 || prior == 0xA9)) // 2028/2029
                return [3, 0];
        }

        if(currentPtr + 1 < parent.endPtr) {
            char next = *(currentPtr + 1);

            if(prior == 0xE2 && current == 0x80 && (next == 0xA8 || next == 0xA9)) // 2028/2029
                return [1, 2];
        }

        return [0, 0];
    }
}

bool filter(RegexNFANode* current, ref MatchingState ms) @trusted {
    if(ms.currentPtr >= ms.parent.endPtr)
        return false;

    MatchingState ms2 = ms;

    final switch(current.type) {
    case RegexNFANode.Type.Prefix:
        if(!ms2.checkForPrefix(current.prefix.unsafeGetLiteral)) {
            return false;
        }
        break;

    case RegexNFANode.Type.Ranges:
        const len = decodeLength(*ms2.currentPtr);

        if(ms2.currentPtr + len > ms2.parent.endPtr)
            return false;

        dchar got;
        decode(ms2.currentPtr[0 .. len], got);

        if(got !in current.ranges)
            return false;

        ms2.currentPtr += len;
        break;

    case RegexNFANode.Type.Group:
    case RegexNFANode.Type.AssertForward:
    case RegexNFANode.Type.AssertNotForward:
        return true;

    case RegexNFANode.Type.Any:
        if(!ms2.matchState.regexState.any_supports_newline) {
            const matched = ms2.matchNewLineForwards;

            if(matched != 0)
                return false;
        }

        ms2.currentPtr += decodeLength(*ms2.currentPtr);
        break;

    case RegexNFANode.Type.LookBehind:
        auto group = ms.matchState.groups[current.lookBehindGroupOffset];
        assert(group);

        if(!ms2.checkForPrefix(group.text.unsafeGetLiteral))
            return false;
        break;

    case RegexNFANode.Type.Infer:
        return true;
    }

    ms = ms2;
    return true;
}
