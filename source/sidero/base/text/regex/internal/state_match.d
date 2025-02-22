module sidero.base.text.regex.internal.state_match;
import sidero.base.text.regex.internal.state;
import sidero.base.text.regex.matching;
import sidero.base.allocators;
import sidero.base.containers.dynamicarray;
import sidero.base.text;

static MatchState failedToMatchState;

struct MatchState {
    shared(ptrdiff_t) refCount;
    RegexState* regexState;
    MatchState* next;

    String_UTF8 inputForThis;

    MatchValue all;
    MatchValue before, span, after;
    DynamicArray!MatchValue groups;

export @safe nothrow @nogc:

    this(RegexState* regexState) {
        this.regexState = regexState;
        this.refCount = 1;
    }

    void rc(bool addRef) @trusted {
        import sidero.base.internal.atomic;

        if(addRef)
            atomicIncrementAndLoad(refCount, 1);
        else if(atomicDecrementAndLoad(refCount, 1) == 0) {
            RCAllocator allocator = regexState.allocator;
            regexState.rc(false);

            if(next !is null)
                next.rc(false);

            allocator.dispose(&this);
        }
    }
}
