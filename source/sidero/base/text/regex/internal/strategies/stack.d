module sidero.base.text.regex.internal.strategies.stack;
import sidero.base.text.regex.internal.strategies.defs;
import sidero.base.text.regex.internal.strategies.tests;
import sidero.base.text.regex.internal.ast;
import sidero.base.text.regex.internal.state;
import sidero.base.text.regex.internal.state_match;
import sidero.base.text;
import sidero.base.allocators;

@safe nothrow @nogc:

bool attemptMatch(ref MatchInProgressState mips) @trusted {
    import core.stdc.stdio;

    bool debugThis;

    if(debugThis)
        printf("=================== BACKTRACK STACK ===================\n");

    auto matchState = mips.inProgress.matchState;
    auto regexState = matchState.regexState;

    Stack stack;
    stack.strategyState = cast(StackStrategyState*)mips.strategy;
    stack.strategyState.regexState = regexState;

    StackChoice* currentChoice = stack.create(regexState, null, null, regexState.head, mips.inProgress.currentPtr);

    StackChoice* last;
    const(char)* lastPtr;
    int fail;

    void updateGroup(StackChoice* choice) {
        assert(choice.positions > 0);
        const(char)* start = choice.firstPositionBuffer.item.ptr;

        if(choice.current.groupCaptureId >= 0) {
            auto group = matchState.groups[choice.current.groupCaptureId];
            assert(group);

            String_UTF8 temp = matchState.inputForThis[start - matchState.inputForThis.ptr .. $];
            group.text = temp[0 .. mips.inProgress.currentPtr - start];
            cast(void)(matchState.groups[choice.current.groupCaptureId] = group);

            if(debugThis)
                printf("group text %d [[  %.*s  ]]\n", choice.current.groupCaptureId, cast(int)group.text.length, group.text.ptr);
        }
    }

    void cleanUpEverythingAfter(StackChoice* choice) {
        while(stack.strategyState.tail !is choice) {
            StackChoice* current = stack.strategyState.tail;
            stack.strategyState.tail = current.previous;

            stack.strategyState.done(current);
        }
    }

    Loop: while(currentChoice !is null) {
        if(debugThis)
            printf("loop SC%zX, id=RN%d, last SC%zX [[  %.*s  ]]\n", cast(size_t)currentChoice,
                    currentChoice.current.idNumber, cast(size_t)last,
                    cast(int)(mips.endPtr - mips.inProgress.currentPtr), mips.inProgress.currentPtr);

        if(last is currentChoice && lastPtr is mips.inProgress.currentPtr) {
            fail = __LINE__;
            break;
        }
        last = currentChoice;
        lastPtr = mips.inProgress.currentPtr;

        bool filterWasSuccessfull = true;

        final switch(currentChoice.current.type) {
        case RegexNFANode.Type.Prefix:
        case RegexNFANode.Type.Ranges:
        case RegexNFANode.Type.Any:
        case RegexNFANode.Type.LookBehind: {
                // no choice is related to these

                const(char)* originalPositionPtr = mips.inProgress.currentPtr;
                size_t numberOfPositions = currentChoice.positions;

                foreach(i; 0 .. currentChoice.current.max) {
                    if(i > 0) {
                        if(!currentChoice.push(stack.strategyState, mips.inProgress.currentPtr, null)) {
                            // OOM limit reached?
                            if(debugThis)
                                printf("OOM? push in filter of SC%zX\n", cast(size_t)currentChoice);
                            break;
                        }
                    }

                    if(!filter(currentChoice.current, mips.inProgress)) {
                        if(i > 0)
                            currentChoice.pop(stack.strategyState);
                        break;
                    }
                }

                if(debugThis)
                    printf("Filtering: %zd %d vs %d %d\n", numberOfPositions, currentChoice.positions,
                            currentChoice.current.min, currentChoice.lastPosition.item.ptr is mips.inProgress.currentPtr);

                if(currentChoice.current.min == 1 && currentChoice.lastPosition.item.ptr !is mips.inProgress.currentPtr) {
                } else if(currentChoice.current.min > 0 && currentChoice.positions - numberOfPositions <= currentChoice.current.min) {
                    filterWasSuccessfull = false;

                    foreach(_; numberOfPositions .. currentChoice.positions) {
                        StackChoiceItem item = currentChoice.pop(stack.strategyState);
                        stack.strategyState.done(item.choice);
                    }

                    mips.inProgress.currentPtr = originalPositionPtr;
                }

                if(debugThis)
                    printf("    successfully %zd\n", mips.inProgress.currentPtr - originalPositionPtr);

                break;
            }

        case RegexNFANode.Type.Group:
        case RegexNFANode.Type.AssertForward:
        case RegexNFANode.Type.AssertNotForward: {
                StackChoice* next = stack.create(regexState, currentChoice, currentChoice, currentChoice.current.next1,
                        mips.inProgress.currentPtr);

                if(next is null) {
                    // OOM limit reached?
                    filterWasSuccessfull = false;

                    if(debugThis)
                        printf("OOM? group next1 of SC%zX\n", cast(size_t)currentChoice);
                    break;
                }

                if(!currentChoice.push(stack.strategyState, mips.inProgress.currentPtr, next)) {
                    // OOM limit reached?
                    stack.strategyState.done(next);
                    filterWasSuccessfull = false;

                    if(debugThis)
                        printf("OOM? group push of SC%zX for next SC%zX\n", cast(size_t)currentChoice, cast(size_t)next);
                    break;
                }

                currentChoice = next;
                continue Loop;
            }

        case RegexNFANode.Type.Infer:
            break;
        }

        if(!filterWasSuccessfull) {
            if(currentChoice.current.next2 !is null) {
                StackChoice* next = stack.create(regexState, currentChoice.parent, currentChoice,
                        currentChoice.current.next2, mips.inProgress.currentPtr);

                if(next !is null) {
                    currentChoice = next;
                    continue Loop;
                } else {
                    if(debugThis)
                        printf("OOM? next2 of SC%zX\n", cast(size_t)currentChoice);
                }
            }

        RetryUnsuccessfulFilterBacktrack: {
                StackChoice* previous = currentChoice.preceeding;

                while(previous !is null) {
                    if(previous.current.type == RegexNFANode.Type.AssertForward) {
                        // welp that failed...
                        previous = previous.preceeding;
                        continue;
                    } else if(previous.current.type == RegexNFANode.Type.AssertNotForward) {
                        // this is actually a success case!
                        mips.inProgress.currentPtr = previous.firstPositionBuffer.item.ptr;
                        if(debugThis)
                            printf("asserted not forward SC%zX\n", cast(size_t)previous.current);

                        previous.checkedForFail = true;
                        currentChoice = previous;
                        goto RetryNext;
                    } else if(previous.positions >= 1 && previous.positions - 1 >= previous.current.min) {
                        StackChoiceItem item = previous.pop(stack.strategyState);

                        if(debugThis)
                            printf("going backwards SC%zX %d\n", cast(size_t)previous, previous.positions);

                        cleanUpEverythingAfter(previous);
                        stack.strategyState.done(item.choice);

                        currentChoice = previous;
                        mips.inProgress.currentPtr = item.ptr;
                        goto RetryNext;
                    } else if(previous.positions > 0 && (previous.current.next2 !is null &&
                            previous.current.next2 !is previous.current.afterNextSuccess)) {
                        StackChoiceItem item = previous.pop(stack.strategyState);

                        if(debugThis)
                            printf("going backwards SC%zX via next2 RN%zX %d\n", cast(size_t)previous,
                                    cast(size_t)previous.current.next2, previous.positions);

                        cleanUpEverythingAfter(previous);
                        stack.strategyState.done(item.choice);

                        mips.inProgress.currentPtr = item.ptr;
                        StackChoice* next = stack.create(regexState, previous.parent, previous, previous.current.next2, item.ptr);

                        if(next !is null) {
                            currentChoice = next;
                            continue Loop;
                        } else {
                            if(debugThis)
                                printf("OOM? next2 SC%zX parent of SC%zX\n", cast(size_t)previous, cast(size_t)currentChoice);
                        }
                    }

                    previous = previous.preceeding;
                }
            }

            fail = __LINE__;
            break;
        }

    RetryNext:
        if(debugThis)
            printf("try next\n");

        if(currentChoice.current.type == RegexNFANode.Type.Group)
            updateGroup(currentChoice);

        if(currentChoice.current.next1 !is null && currentChoice.current.afterNextSuccess is null) {
            StackChoice* next = stack.create(regexState, currentChoice.parent, currentChoice,
                    currentChoice.current.next1, mips.inProgress.currentPtr);

            if(next !is null) {
                currentChoice = next;
            } else {
                if(debugThis)
                    printf("OOM? next1 SC%zX\n", cast(size_t)currentChoice);

                goto RetryUnsuccessfulFilterBacktrack;
            }
        } else {
            StackChoice* parent = currentChoice;

            while(parent !is null) {
                if(parent.current.type == RegexNFANode.Type.Group)
                    updateGroup(parent);

                if(parent.current.type == RegexNFANode.Type.AssertForward) {
                    // ok this is what we wanted to see, its success!
                    mips.inProgress.currentPtr = parent.firstPositionBuffer.item.ptr;
                } else if(parent.current.type == RegexNFANode.Type.AssertNotForward && !parent.checkedForFail) {
                    // if we are seeing this here that means we didn't actually succeed :(
                    mips.inProgress.currentPtr = parent.firstPositionBuffer.item.ptr;
                    currentChoice = parent.firstPositionBuffer.item.choice;

                    if(currentChoice is null) {
                        fail = __LINE__;
                        break Loop;
                    }
                    goto RetryUnsuccessfulFilterBacktrack;
                }

                if(parent.current.afterNextSuccess !is null) {
                    StackChoice* next = stack.create(regexState, parent.parent, currentChoice,
                            parent.current.afterNextSuccess, mips.inProgress.currentPtr);

                    if(next !is null) {
                        currentChoice = next;
                    } else {
                        if(debugThis)
                            printf("OOM? after next success create SC%zX\n", cast(size_t)parent);

                        goto RetryUnsuccessfulFilterBacktrack;
                    }

                    if(debugThis)
                        printf("seeing after next success to SC%zX\n", cast(size_t)currentChoice);

                    continue Loop;
                }

                parent = parent.parent;
            }

            if(debugThis)
                printf("done at end of loop\n");
            break;
        }
    }

    if(fail == 0 && mips.inProgress.currentPtr is mips.startPtr) {
        fail = __LINE__;
    }

    if(debugThis) {
        if(fail != 0) {
            printf("FAILED on %d [[  %.*s  ]]\n", fail, cast(int)matchState.inputForThis.length, matchState.inputForThis.ptr);

            if(currentChoice !is null)
                printf("  with node SC%zX\n", cast(size_t)currentChoice);

            stack.debugMe(matchState);
        }

        printf("------------------- BACKTRACK STACK %s -------------------\n", fail == 0 ? "SUCCEDED".ptr : "FAILED".ptr);
    }

    {
        while(stack.strategyState.tail !is null) {
            StackChoice* current = stack.strategyState.tail;
            stack.strategyState.tail = current.previous;

            stack.strategyState.done(current);
        }
    }

    return fail == 0;
}

struct StackStrategyState {
    RegexState* regexState;

    StackChoice* tail;
    StackChoice* freeListChoice;
    StackChoicePosition* freeListPosition;

    size_t numberOfChoices, numberOfPositions;

@safe nothrow @nogc:

    @disable this(ref StackStrategyState);

    ~this() {
        {
            StackChoice* choice = tail;

            while(choice !is null) {
                StackChoice* current = choice;
                choice = choice.previous;

                regexState.allocator.dispose(current);
            }

            choice = freeListChoice;
            while(choice !is null) {
                StackChoice* current = choice;
                choice = choice.previous;

                regexState.allocator.dispose(current);
            }
        }

        {
            StackChoicePosition* pos = freeListPosition;

            while(pos !is null) {
                StackChoicePosition* current = pos;
                pos = pos.previous;

                regexState.allocator.dispose(current);
            }
        }
    }

    void done(int line = __LINE__)(StackChoice* choice) @trusted {
        if(choice is null || choice.positions == -29000)
            return;

        version(none) {
            import core.stdc.stdio;

            debug printf("done with %p at %d\n", choice, line);
        }

        StackChoiceItem item;
        while(choice.lastPosition !is null) {
            item = choice.pop(&this);

            version(none) {
                if(item.choice !is null)
                    debug printf("    seeing %p\n", item.choice);
            }

            done(item.choice);
        }

        version(none) {
            StackChoice* prev2 = choice.previous2;
            *choice = StackChoice.init;
            choice.previous2 = prev2;
        } else {
            *choice = StackChoice.init;
        }

        choice.previous = freeListChoice;
        freeListChoice = choice;

        // due to going backwards over tail, we can see some things multiple times
        choice.positions = -29000;
    }

    void done(StackChoicePosition* pos) {
        if(pos is null || pos.previous is null)
            return;

        pos.item = StackChoiceItem.init;
        pos.previous = freeListPosition;
        freeListPosition = pos;
    }

    void sanityCheck() {
        bool inFreeListC(StackChoice* choice) {
            StackChoice* temp = this.freeListChoice;

            while(temp !is null) {
                if(temp is choice)
                    return true;
                temp = temp.previous;
            }

            return false;
        }

        bool inFreeListP(StackChoicePosition* pos) {
            StackChoicePosition* temp = this.freeListPosition;

            while(temp !is null) {
                if(temp is pos)
                    return true;
                temp = temp.previous;
            }

            return false;
        }

        StackChoice* current = tail;

        while(current !is null) {
            if(inFreeListC(current))
                assert(0);

            StackChoicePosition* pos = current.lastPosition;

            while(pos !is null) {
                if(inFreeListP(pos))
                    assert(0);
                else if(inFreeListC(pos.item.choice))
                    assert(0);
                pos = pos.previous;
            }

            current = current.previous;
        }
    }

    version(none) {
        StackChoice* tail2;

        void sanityCheck(StackChoice* against) {
            bool inFreeListC(StackChoice* choice) {
                StackChoice* temp = this.freeListChoice;

                while(temp !is null) {
                    if(temp is choice)
                        return true;
                    temp = temp.previous;
                }

                return false;
            }

            bool inFreeListP(StackChoicePosition* pos) {
                StackChoicePosition* temp = this.freeListPosition;

                while(temp !is null) {
                    if(temp is pos)
                        return true;
                    temp = temp.previous;
                }

                return false;
            }

            assert(!inFreeListC(against));

            StackChoice* current = tail;
            while(current !is null) {
                if(current is against)
                    assert(0);

                const isFree = inFreeListC(current);
                StackChoicePosition* pos = current.lastPosition;

                while(pos !is null) {
                    assert(!isFree);

                    if(pos.item.choice is against)
                        assert(0);

                    pos = pos.previous;
                }

                current = current.previous;
            }

            current = tail2;
            int count;
            while(current !is null) {
                if(current is against) {
                    count++;
                    assert(count == 1);
                } else {
                    const isFree = inFreeListC(current);
                    StackChoicePosition* pos = current.lastPosition;

                    while(pos !is null) {
                        assert(!isFree);

                        if(pos.item.choice is against)
                            assert(0);

                        pos = pos.previous;
                    }
                }

                current = current.previous2;
            }
        }
    }
}

struct Stack {
    StackChoice* head;
    StackStrategyState* strategyState;

@safe nothrow @nogc:

    StackChoice* create(RegexState* regexState, StackChoice* parent, StackChoice* preceeding, RegexNFANode* current,
            const(char)* currentPtr) {
        if(current is null)
            return null;

        StackChoice* next = strategyState.freeListChoice;
        if(next is null) {
            if(strategyState.numberOfChoices >= strategyState.regexState.limiter.terms) {
                // OOM?
                return null;
            } else {
                strategyState.numberOfChoices++;
                next = regexState.allocator.make!StackChoice;
            }

            version(none) {
                next.previous2 = strategyState.tail2;
                strategyState.tail2 = next;
            }
        } else {
            assert(next.positions == -29000);
            assert(next.lastPosition is null);
            strategyState.freeListChoice = next.previous;
            next.positions = 0;
        }

        next.parent = parent;
        next.current = current;
        next.preceeding = preceeding;

        next.push(strategyState, currentPtr, null);

        next.previous = strategyState.tail;
        strategyState.tail = next;

        if(head is null)
            head = next;
        return next;
    }

    void debugMe(MatchState* matchState) {
        StackChoice* temp = strategyState.tail;

        while(temp !is null && temp !is head) {
            temp.debugMe(matchState, 0);
            temp = temp.previous;
        }
    }
}

struct StackChoice {
    StackChoice* parent, previous, preceeding;
    RegexNFANode* current;
    StackChoicePosition* lastPosition;

    int positions;
    StackChoicePosition firstPositionBuffer;

    int iteration;
    bool checkedForFail;

    version(none) {
        StackChoice* previous2;
    }

@safe nothrow @nogc:
    bool push(StackStrategyState* strategyState, const(char)* ptr, StackChoice* choice) @trusted {
        StackChoicePosition* temp;

        if(lastPosition is null)
            temp = &firstPositionBuffer;
        else {
            temp = strategyState.freeListPosition;

            if(temp is null) {
                if(strategyState.numberOfPositions >= strategyState.regexState.limiter.positions) {
                    // OOM
                    return false;
                } else {
                    strategyState.numberOfPositions++;
                    temp = strategyState.regexState.allocator.make!StackChoicePosition;
                }
            } else
                strategyState.freeListPosition = temp.previous;
        }

        positions++;
        temp.item.ptr = ptr;
        temp.item.choice = choice;

        temp.previous = lastPosition;
        lastPosition = temp;
        return true;
    }

    StackChoiceItem pop(StackStrategyState* strategyState) {
        if(lastPosition is null)
            return StackChoiceItem.init;

        StackChoicePosition* temp = lastPosition;
        StackChoiceItem ret = temp.item;
        lastPosition = temp.previous;

        positions--;
        temp.item = StackChoiceItem.init;
        strategyState.done(temp);
        return ret;
    }

    void debugMe(MatchState* matchState, int prefixCount) @trusted {
        import core.stdc.stdio;

        printf("% *sSC%zX [parent=SC%zX, preceeding=SC%zX, current=RX%zX, id=%d, type=%d]\n", prefixCount, "".ptr,
                cast(size_t)&this, cast(size_t)this.parent, cast(size_t)this.preceeding, cast(size_t)this.current,
                this.current !is null ? this.current.idNumber : -1, this.current !is null ? this.current.type : RegexNFANode.Type.Infer);

        {
            StackChoicePosition* pos = lastPosition;
            prefixCount += 4;

            while(pos !is null) {
                printf("% *s- ", prefixCount, "".ptr);

                if(pos.item.ptr !is null) {
                    printf("byte offset=%zd [[  %.*s  ]]", pos.item.ptr - matchState.inputForThis.ptr,
                            cast(int)(matchState.inputForThis.length - (pos.item.ptr - matchState.inputForThis.ptr)), pos.item.ptr);

                    if(pos.item.choice !is null)
                        printf(", ");
                }

                if(pos.item.choice !is null)
                    printf("choice=SC%zX", cast(size_t)pos.item.choice);

                printf("\n");
                pos = pos.previous;
            }
        }
    }
}

struct StackChoicePosition {
    StackChoicePosition* previous;
    StackChoiceItem item;
}

struct StackChoiceItem {
    const(char)* ptr;
    StackChoice* choice;
}

mixin RegexMatchStrategyTests!(RegexMatchStrategy.Stack);
