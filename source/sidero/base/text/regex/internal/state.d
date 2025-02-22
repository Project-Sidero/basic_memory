module sidero.base.text.regex.internal.state;
import sidero.base.text.regex.internal.ast;
import sidero.base.text.regex.pattern;
import sidero.base.allocators;
import sidero.base.text;

struct RegexState {
    shared(ptrdiff_t) refCount;
    RCAllocator allocator;

    RegexNFANode* head;
    RegexNFANode* needsCleanupLL;

    RegexLimiter limiter;
    RegexMatchStrategy strategy;

    // how is `before` slice acquired?
    bool try_start_after_each_newline, try_start_after_stride;
    // '^', '$', and '$' if mode 'm'
    bool require_start_at_newline, require_end_at_end, require_end_before_newline;
    // '.' matches new line
    bool any_supports_newline;

    size_t groupsCount;

    String_UTF8 pattern;

export @safe nothrow @nogc:

    void rc(bool addRef) @trusted {
        import sidero.base.internal.atomic;

        if(addRef)
            atomicIncrementAndLoad(refCount, 1);
        else if(atomicDecrementAndLoad(refCount, 1) == 0) {
            RCAllocator allocator = this.allocator;

            while(needsCleanupLL !is null) {
                RegexNFANode* next = needsCleanupLL.needsCleanupLL;

                allocator.dispose(needsCleanupLL);
                needsCleanupLL = next;
            }

            allocator.dispose(&this);
        }
    }

    RegexNFANode* createNode(ref int countNodes, RegexNFANode.Type type, int depth, RegexNFANode* previousSibling) @trusted {
        RegexNFANode* ret = allocator.make!RegexNFANode(type, countNodes++, depth);
        ret.needsCleanupLL = needsCleanupLL;
        needsCleanupLL = ret;

        if(previousSibling !is null)
            previousSibling.next1 = ret;

        ret.min = 1;
        ret.max = 1;
        return ret;
    }
}

enum RegexMatchStrategy {
    Stack,
    Old,
}
