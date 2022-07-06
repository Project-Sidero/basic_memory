module sidero.base.text.unicode.comparison;
import sidero.base.text.unicode.characters.hangul;
import sidero.base.text.unicode.casefold;
import sidero.base.text.unicode.composing;
import sidero.base.text.unicode.normalization;
import sidero.base.text.unicode.database;
import sidero.base.encoding.utf;
import sidero.base.allocators.api;

@safe nothrow @nogc:

///
int icmpUTF32_NFD(scope ForeachOverUTF32Delegate input1, scope ForeachOverUTF32Delegate input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) {
    return icmpUTF32_(input1, input2, allocator, turkic, false, false);
}

///
unittest {
    assert(icmpUTF32_NFD("a\u035C\u035Fb"d, ""d) == 1);
    assert(icmpUTF32_NFD(""d, "a\u035C\u035Fb"d) == -1);
    assert(icmpUTF32_NFD("a\u035C\u035Fb"d, "a\u035C\u035Fb"d) == 0);
    assert(icmpUTF32_NFD("a\u035C\u035Fb"d, "a\u035C\u035Cb"d) == 1);
    assert(icmpUTF32_NFD("a\u035C\u035Cb"d, "a\u035C\u035Fb"d) == -1);
    assert(icmpUTF32_NFD("a\u035C\u035Fb"d, "a\u035C\u035Fb"d) == 0);
    assert(icmpUTF32_NFD("hello "d, "hello world"d) == -1);
    assert(icmpUTF32_NFD("hello world"d, "hello "d) == 1);
}

///
int icmpUTF32_NFD(scope dstring input1, scope dstring input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) @trusted {
    scope arg1 = foreachOverUTF(input1), arg2 = foreachOverUTF(input2);
    return icmpUTF32_(&arg1.opApply, &arg2.opApply, allocator, turkic, false, false);
}

///
int icmpUTF32_NFC(scope ForeachOverUTF32Delegate input1, scope ForeachOverUTF32Delegate input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) {
    return icmpUTF32_(input1, input2, allocator, turkic, false, true);
}

///
int icmpUTF32_NFC(scope dstring input1, scope dstring input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) @trusted {
    scope arg1 = foreachOverUTF(input1), arg2 = foreachOverUTF(input2);
    return icmpUTF32_(&arg1.opApply, &arg2.opApply, allocator, turkic, false, true);
}

///
int icmpUTF32_NFKD(scope ForeachOverUTF32Delegate input1, scope ForeachOverUTF32Delegate input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) {
    return icmpUTF32_(input1, input2, allocator, turkic, true, false);
}

///
int icmpUTF32_NFKD(scope dstring input1, scope dstring input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) @trusted {
    scope arg1 = foreachOverUTF(input1), arg2 = foreachOverUTF(input2);
    return icmpUTF32_(&arg1.opApply, &arg2.opApply, allocator, turkic, true, false);
}

///
int icmpUTF32_NFKC(scope ForeachOverUTF32Delegate input1, scope ForeachOverUTF32Delegate input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) {
    return icmpUTF32_(input1, input2, allocator, turkic, true, true);
}

///
int icmpUTF32_NFKC(scope dstring input1, scope dstring input2, scope RCAllocator allocator = globalAllocator(), bool turkic = false) @trusted {
    scope arg1 = foreachOverUTF(input1), arg2 = foreachOverUTF(input2);
    return icmpUTF32_(&arg1.opApply, &arg2.opApply, allocator, turkic, true, true);
}

///
struct CaseAwareComparison {
    private {
        RCAllocator allocator;
        Rotate rotate;

        bool isTurkic, isCaseSensitive;

        dchar[64] againstInlineBuffer;
        dchar[] againstBuffer;
        dchar[] against;
    }

    ///
    this(RCAllocator allocator, bool isTurkic) return @trusted {
        this.allocator = allocator;
        this.isTurkic = isTurkic;

        this.rotate = Rotate(allocator);
        againstBuffer = againstInlineBuffer[];
    }

    ~this() {
        if (againstBuffer.length > againstInlineBuffer.length)
            allocator.dispose(againstBuffer);
    }

    @disable this(this);

    ///
    void setAgainst(scope ForeachOverUTF32Delegate input, bool isCaseSensitive = true, size_t lengthHint = 0) {
        this.isCaseSensitive = isCaseSensitive;

        void allocateAgainst(size_t length) {
            if (againstBuffer.length < length) {
                dchar[] temp = allocator.makeArray!dchar(length);
                temp[0 .. againstBuffer.length][] = againstBuffer[];

                if (againstBuffer.length > againstInlineBuffer.length)
                    allocator.dispose(againstBuffer);

                againstBuffer = temp;
            }

            against = againstBuffer[0 .. length];
        }

        if (isCaseSensitive) {
            size_t inputLength = lengthHint;

            if (inputLength == 0) {
                foreach (c; input)
                    inputLength++;
            }

            allocateAgainst(inputLength);

            size_t soFar;
            foreach (v; input)
                against[soFar++] = v;
        } else {
            const inputLength = caseFoldLength(input, isTurkic, false, true);
            allocateAgainst(inputLength);

            {
                size_t soFar;
                caseFold((scope const(dchar)[] got...) {
                    against[soFar .. soFar + got.length] = got[];
                    soFar += got.length;
                    return false;
                }, input, isTurkic, false, true);
            }
        }

        rotate(against);
    }

    /// If you want to know how much of input was consumed to do the match make your input delegate support getting it (ForeachOverUTF does).
    int compare(scope ForeachOverUTF32Delegate input) {
        // to make this as cheap as possible, we MUST NOT CALL caseFoldLength.
        // yes we have to call to get the CCC a lot (potentially)

        size_t received, processed;
        int ret;

        rotate.partialReset;

        bool handleRotated(dchar value) @nogc {
            if (against[processed] < value) {
                ret = 1;
                processed++;
                return true;
            } else if (against[processed] > value) {
                ret = -1;
                processed++;
                return true;
            } else {
                processed++;
                return false;
            }
        }

        if (isCaseSensitive) {
            foreach (c; input) {
                rotate.partial(&handleRotated, c);
                if (ret != 0)
                    break;
            }
        } else {
            caseFold((scope const(dchar)[] got...) {
                received += got.length;

                if (received > against.length) {
                    // we are longer
                    ret = 1;
                    return true;
                }

                rotate.partial(&handleRotated, got);
                return ret != 0;
            }, input, isTurkic, false, true);
        }

        if (ret == 0)
            rotate.partialFinish(&handleRotated);

        // we are shorter
        if (ret == 0 && received < against.length)
            ret = -1;

        return ret;
    }
}

package(sidero.base.text.unicode):

int icmpUTF32_(scope ForeachOverUTF32Delegate input1, scope ForeachOverUTF32Delegate input2, scope RCAllocator allocator,
        bool turkic = false, bool compatibility = false, bool composition = false) {
    const input1Dlength = caseFoldLength(input1, turkic, compatibility, true), input2Dlength = caseFoldLength(input2,
            turkic, compatibility, true);

    // if we compose the lengths after case folding it won't have direct equivalence to the output
    if (!composition) {
        if (input1Dlength < input2Dlength)
            return -1;
        else if (input2Dlength < input1Dlength)
            return 1;
    }

    dchar[] array1 = allocator.makeArray!dchar(input1Dlength), array2 = allocator.makeArray!dchar(input2Dlength);

    {
        size_t soFarCaseFolded;
        caseFold((scope const(dchar)[] got...) {
            array1[soFarCaseFolded .. soFarCaseFolded + got.length] = got[];
            soFarCaseFolded += got.length;
            return false;
        }, input1, turkic, compatibility, true);

        soFarCaseFolded = 0;
        caseFold((scope const(dchar)[] got...) {
            array2[soFarCaseFolded .. soFarCaseFolded + got.length] = got[];
            soFarCaseFolded += got.length;
            return false;
        }, input2, turkic, compatibility, true);
    }

    //

    Rotate rotate = Rotate(allocator);
    rotate(array1);
    rotate(array2);
    assert(array1.length == array2.length);

    size_t trueSize1 = array1.length, trueSize2 = array2.length;

    if (composition) {
        trueSize1 = compose_(array1, allocator);
        trueSize2 = compose_(array2, allocator);
    }

    //

    scope (exit) {
        allocator.dispose(array1);
        allocator.dispose(array2);
    }

    if (trueSize1 < trueSize2)
        return -1;
    else if (trueSize2 < trueSize1)
        return 1;

    foreach (i; 0 .. trueSize1) {
        if (array1[i] < array2[i])
            return -1;
        else if (array2[i] < array1[i])
            return 1;
    }

    return 0;
}
