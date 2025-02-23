module sidero.base.text.regex.internal.strategies.old;
import sidero.base.text.regex.internal.strategies.defs;
import sidero.base.text.regex.internal.strategies.tests;
import sidero.base.text.regex.internal.ast;
import sidero.base.text.regex.internal.state;
import sidero.base.text.regex.internal.state_match;
import sidero.base.text.regex.matching;
import sidero.base.text;
import sidero.base.allocators;

@safe nothrow @nogc:

bool attemptMatch(ref MatchInProgressState mips) @trusted {
    import core.stdc.stdio;

    bool debugThis;
    MatchingState oldMS = mips.inProgress;

    if(debugThis)
        printf("=====attempting: [[  %.*s  ]]\n", cast(int)(mips.endPtr - mips.inProgress.currentPtr), mips.inProgress.currentPtr);

    if(attemptMatch2(mips.inProgress, mips.inProgress.matchState.regexState.head)) {
        if(debugThis)
            printf("=====success\n");

        return true;
    }

    if(debugThis)
        printf("=====fail\n");

    mips.inProgress = oldMS;
    return false;
}

bool attemptMatch2(ref MatchingState ms, RegexNFANode* childAsParent) @trusted {
    import core.stdc.stdio;

    RegexNFANode* current = childAsParent;
    RegexNFANode* last;
    int currentMaxIterations;

    bool debugThis;

    if(debugThis)
        printf("======attempting match on %d\n", current.idNumber);

    bool filter2(ref MatchingState ms2) @trusted {
        if(ms2.currentPtr >= ms2.parent.endPtr)
            return false;

        MatchingState ms3 = ms2;

        if(debugThis)
            printf("-- filtering %d %d %.*s\n", current.idNumber, current.type,
                    cast(int)(ms2.parent.endPtr - ms2.currentPtr), ms2.currentPtr);

        final switch(current.type) {
        case RegexNFANode.Type.Prefix:
        case RegexNFANode.Type.Ranges:
        case RegexNFANode.Type.Any:
        case RegexNFANode.Type.Infer:
        case RegexNFANode.Type.LookBehind:
            return filter(current, ms2);

        case RegexNFANode.Type.Group:
            if(attemptMatch2(ms3, current.next1)) {
                // success

                if(current.groupCaptureId >= 0) {
                    auto group = ms.matchState.groups[current.groupCaptureId];
                    assert(group);

                    String_UTF8 temp = ms.matchState.inputForThis[ms2.currentPtr - ms.matchState.inputForThis.ptr .. $];
                    group.text = temp[0 .. ms3.currentPtr - ms2.currentPtr];
                    cast(void)(ms.matchState.groups[current.groupCaptureId] = group);
                }

                if(debugThis)
                    printf("--filtered group successfully: %d [[  %.*s  ]\n", current.idNumber,
                            cast(int)(ms2.parent.endPtr - ms2.currentPtr), ms2.currentPtr);
                break;
            } else {
                if(debugThis)
                    printf("--filtered group unsuccessfully: %d\n", current.idNumber);
                return false;
            }

            auto text = ms2.matchState.groups[current.lookBehindGroupOffset].text;
            if(!ms3.checkForPrefix(text.unsafeGetLiteral))
                return false;
            break;

        case RegexNFANode.Type.AssertForward:
        case RegexNFANode.Type.AssertNotForward:
            assert(0);
        }

        ms2 = ms3;
        return true;
    }

    bool backtrackNext(ref MatchingState ms2, bool next1Allowed) {
        if(debugThis)
            printf("--backtracking: %d %d\n", current.idNumber, current.type);

        if(current.type == RegexNFANode.Type.Group && current.next2 is null) {
            current = current.afterNextSuccess;
            return true;
        }

        MatchingState ms3 = ms2;

        if(next1Allowed) {
            if(current.next1 !is null) {
                if(attemptMatch2(ms3, current.next1)) {
                    if(current.afterNextSuccess !is null) {
                        if(!attemptMatch2(ms3, current.afterNextSuccess))
                            return false;
                    }

                    ms2 = ms3;
                    current = null;
                    return true;
                } else
                    ms3 = ms2;
            } else {
                if(current.afterNextSuccess !is null) {
                    ms2 = ms3;
                    current = current.afterNextSuccess;
                    return true;
                } else {
                    current = null;
                    return true;
                }
            }
        }

        if(current.next2 !is null && attemptMatch2(ms3, current.next2)) {
            ms2 = ms3;
            current = current.afterNextSuccess;
            return true;
        }

        return false;
    }

    CompleteLoop: do {
        if(current is last)
            assert(0);
        last = current;

        if(debugThis)
            printf("-On complete loop: %d\n", current.idNumber);

        currentMaxIterations = current.max;

        BackOffIterationLoop: while(current !is null && currentMaxIterations >= current.min) {
            MatchingState ms2 = ms;
            bool next1Allowed = current.type != RegexNFANode.Type.Group;
            bool requireNext2;

            if(current.type != RegexNFANode.Type.Infer) {
                // skip an infer, it has no filtering on its next1
                int done;

                foreach(i; 0 .. currentMaxIterations) {
                    if(!filter2(ms2)) {
                        if(i < current.min) {
                            next1Allowed = false;
                            requireNext2 = true;
                        }
                        currentMaxIterations = -1;
                        break;
                    }

                    done = i + 1;
                }

                currentMaxIterations = done;
            }

            if(debugThis)
                printf("-after filter for: %d %d %d\n", current.idNumber, requireNext2, next1Allowed);

            if(requireNext2 && current.next2 is null)
                return false;
            else if(next1Allowed && current.next2 is null && current.afterNextSuccess is null && current.min == 1 && current.max == 1) {
                ms = ms2;
                current = current.next1;
                continue CompleteLoop;
            } else if(backtrackNext(ms2, next1Allowed)) {
                ms = ms2;
                continue CompleteLoop;
            } else {
                currentMaxIterations--;
                continue BackOffIterationLoop;
            }
        }

        if(current !is null && currentMaxIterations < current.min) {
            return false;
        }
    }
    while(current !is null);

    if(current is null) {
        return true;
    } else {
        return false;
    }
}

mixin RegexMatchStrategyTests!(RegexMatchStrategy.Old);
