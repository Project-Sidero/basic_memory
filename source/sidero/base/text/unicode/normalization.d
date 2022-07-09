module sidero.base.text.unicode.normalization;
import sidero.base.text.unicode.characters.hangul;
import sidero.base.text.unicode.casefold;
import sidero.base.text.unicode.composing;
import sidero.base.text.unicode.database;
import sidero.base.encoding.utf;
import sidero.base.allocators.api;

@safe nothrow @nogc:

///
dstring toNFD(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool turkic = false) {
    return normalize(input, allocator, turkic, false, false);
}

///
dstring toNFD(scope dstring input, RCAllocator allocator, bool turkic = false) @trusted {
    scope arg = foreachOverUTF(input);
    return normalize(&arg.opApply, allocator, turkic, false, false);
}

///
dstring toNFC(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool turkic = false) {
    return normalize(input, allocator, turkic, false, true);
}

///
dstring toNFC(scope dstring input, RCAllocator allocator, bool turkic = false) @trusted {
    scope arg = foreachOverUTF(input);
    return normalize(&arg.opApply, allocator, turkic, false, true);
}

///
dstring toNFKD(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool turkic = false) {
    return normalize(input, allocator, turkic, true, false);
}

///
dstring toNFKD(scope dstring input, RCAllocator allocator, bool turkic = false) @trusted {
    scope arg = foreachOverUTF(input);
    return normalize(&arg.opApply, allocator, turkic, true, false);
}

///
dstring toNFKC(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool turkic = false) {
    return normalize(input, allocator, turkic, true, true);
}

///
dstring toNFKC(scope dstring input, RCAllocator allocator, bool turkic = false) @trusted {
    scope arg = foreachOverUTF(input);
    return normalize(&arg.opApply, allocator, turkic, true, true);
}

///
dstring normalize(scope ForeachOverUTF32Delegate input, RCAllocator allocator, bool turkic = false,
        bool compatibility = false, bool composition = false) @trusted {
    const inputDlength = decomposeLength(input, compatibility);

    dchar[] ret = allocator.makeArray!dchar(inputDlength);
    decompose(ret, input, compatibility);

    Rotate rotate = Rotate(allocator);
    rotate(ret);

    size_t trueSize = ret.length;

    if (composition)
        trueSize = compose_(ret, allocator);

    return cast(dstring)ret;
}

package(sidero.base.text.unicode):

size_t compose_(scope ref dchar[] array, scope RCAllocator allocator) @trusted {
    size_t lastStarterOffset, soFarInInput;

    dchar[] replacement, replacementBuffer;

    void checkLength(size_t amount) {
        if (replacement.length + amount > replacementBuffer.length) {
            dchar[] old = replacementBuffer;

            replacementBuffer = allocator.makeArray!dchar(replacementBuffer.length + 64 + amount);
            foreach (i, v; old)
                replacementBuffer[i] = v;

            if (old.length > 0)
                allocator.dispose(old);
        }
    }

    void add(dchar c) {
        checkLength(1);

        replacementBuffer[replacement.length] = c;
        replacement = replacementBuffer[0 .. replacement.length + 1];
    }

    void goBeforeLastStarter() {
        replacement = replacement[0 .. lastStarterOffset];
        soFarInInput = lastStarterOffset + 1;
    }

    void add1() {
        add(array[soFarInInput]);
        soFarInInput++;
    }

    foreach (dchar c; array) {
        add1;
        if (sidero_utf_lut_getCCC(c) == 0)
            break;
        lastStarterOffset++;
    }

    // <L, ..., C> -> <P, ...>
    while (soFarInInput < array.length) {
        if (lastStarterOffset == replacement.length)
            add1;

        dchar starter = replacement[lastStarterOffset];
        assert(sidero_utf_lut_getCCC(starter) == 0);

        size_t offsetInReplace = lastStarterOffset + 1;

        while (offsetInReplace < replacement.length || soFarInInput < array.length) {
            if (offsetInReplace == replacement.length) {
                assert(soFarInInput < array.length);
                add1;
            }

            dchar L = starter, C = replacement[offsetInReplace];
            ubyte currentCCC = sidero_utf_lut_getCCC(C);

            // check to see if L, B..., C is blocked for L and C
            {
                bool isBlocked;
                foreach (priorC; replacement[lastStarterOffset + 1 .. offsetInReplace]) {
                    ubyte priorCCC = sidero_utf_lut_getCCC(priorC);
                    if (priorCCC >= currentCCC) {
                        isBlocked = true;
                        break;
                    }
                }

                if (isBlocked) {
                    if (currentCCC == 0) {
                        lastStarterOffset = offsetInReplace;
                        break;
                    } else {
                        offsetInReplace++;
                        continue;
                    }
                }
            }

            {
                // compute a potential composable character given L, C and for hangul look in source of replace for T
                dchar composedCharacter;
                size_t amountComposed = 1, consumeInput;
                // Will only consume input for hangul if the replacement buffer doesn't contain something after our current character

                {
                    composedCharacter = sidero_utf_lut_getCompositionCanonical(L, C);

                    if (composedCharacter == dchar.init) {
                        dchar TPart;

                        if (offsetInReplace + 1 < replacement.length)
                            TPart = replacement[offsetInReplace + 1];
                        else if (soFarInInput < array.length) {
                            TPart = array[soFarInInput];
                            consumeInput = 1;
                        }

                        if (composeHangulSyllable(L, C, TPart, composedCharacter) == 3)
                            amountComposed = 2 - consumeInput;
                        else
                            consumeInput = 0;
                    }
                }

                if (composedCharacter == dchar.init) {
                    if (currentCCC == 0) {
                        lastStarterOffset = offsetInReplace;
                        break;
                    }
                } else {
                    // L, I1, I2, C, A1, A2 -> P

                    // I1, I2, C, A1, A2
                    size_t amountAfterL = replacement.length - (lastStarterOffset + 1);
                    // A1, A2
                    size_t amountAfterC = replacement.length - (offsetInReplace + amountComposed);

                    // ~~C~~, <<A1, <<A2
                    foreach (i; offsetInReplace .. offsetInReplace + amountAfterC) {
                        replacement[i] = replacement[i + 1];
                    }

                    // remove C
                    replacement = replacement[0 .. $ - amountComposed];
                    replacement[lastStarterOffset] = composedCharacter;
                    soFarInInput += consumeInput;
                    break;
                }
            }

            offsetInReplace++;
        }
    }

    if (replacementBuffer.length - replacement.length > 0)
        allocator.shrinkArray(replacementBuffer, replacementBuffer.length - replacement.length);
    allocator.dispose(array);

    array = replacementBuffer;
    return replacement.length;
}

alias RotatePartialHandlerDelegate = bool delegate(dchar) @safe nothrow @nogc;

struct Rotate {
@safe nothrow @nogc:
    @disable this(this);

    this(scope RCAllocator allocator) scope @trusted {
        this.allocator = allocator;
    }

    ~this() scope {
        if (rotateBuffer.length > rotateInlineBuffer.length)
            allocator.dispose(rotateBuffer);
    }

    private {
        ToRotate[64] rotateInlineBuffer;
        ToRotate[] rotateBuffer;
        RCAllocator allocator;
        size_t rotateBufferUsed;

        static struct ToRotate {
            size_t index;
            dchar character;
            ubyte ccc;

        @safe nothrow @nogc:

            void opAssign(ubyte v) {
                this.ccc = v;
            }

            int opCmp(const ToRotate other) const {
                if (this.ccc < other.ccc)
                    return -1;
                else if (this.ccc > other.ccc)
                    return 1;
                else if (this.index < other.index)
                    return -1;
                else if (this.index > other.index)
                    return 1;
                else
                    return 0;
            }
        }

        void addToRotateBuffer(ubyte b, dchar character = dchar.init) scope {
            if (rotateBufferUsed == rotateInlineBuffer.length) {
                ToRotate[] temp = allocator.makeArray!ToRotate(rotateBuffer.length + 64);
                assert(temp !is null);

                foreach (i, v; rotateBuffer)
                    temp[i] = v;

                if (rotateBuffer.length > rotateInlineBuffer.length)
                    allocator.dispose(rotateBuffer);

                rotateBuffer = temp;
            }

            rotateBuffer[rotateBufferUsed] = b;
            rotateBuffer[rotateBufferUsed].character = character;
            rotateBufferUsed++;
        }
    }

    void opCall(scope dchar[] array) @trusted scope {
        import std.algorithm : sort;

        if (rotateBuffer.length == 0)
            rotateBuffer = rotateInlineBuffer[];

        while (array.length > 0) {
            rotateBufferUsed = 0;

            size_t ccc0Count, nonCCC0count;
            foreach (dchar c; array) {
                ubyte ccc = sidero_utf_lut_getCCC(c);

                if (ccc == 0)
                    ccc0Count++;
                else
                    break;
            }

            array = array[ccc0Count .. $];

            foreach (dchar c; array) {
                ubyte ccc = sidero_utf_lut_getCCC(c);

                if (ccc == 0)
                    break;
                else {
                    addToRotateBuffer(ccc);
                    nonCCC0count++;
                }
            }

            dchar[] todo = array[0 .. nonCCC0count];
            array = array[nonCCC0count .. $];

            auto rb = rotateBuffer[0 .. rotateBufferUsed];

            foreach (i, ref rbv; rb) {
                rbv.character = todo[i];
                rbv.index = i;
            }

            rb.sort;

            foreach (i, ref rbv; rb)
                todo[i] = rbv.character;
        }
    }

    void partialReset() scope {
        rotateBufferUsed = 0;
    }

    bool partialFinish(scope RotatePartialHandlerDelegate handler) scope @trusted {
        import std.algorithm : sort;

        auto rb = rotateBuffer[0 .. rotateBufferUsed];
        rb.sort!((a, b) => a < b);

        foreach (v; rb) {
            if (handler(v.character))
                return true;
        }

        rotateBufferUsed = 0;
        return false;
    }

    bool partial(scope RotatePartialHandlerDelegate handler, scope const(dchar)[] array...) scope @trusted {
        if (rotateBuffer.length == 0)
            rotateBuffer = rotateInlineBuffer[];

        while (array.length > 0) {
            rotateBufferUsed = 0;

            size_t ccc0Count, nonCCC0count;
            foreach (dchar c; array) {
                ubyte ccc = sidero_utf_lut_getCCC(c);

                if (ccc == 0) {
                    if (ccc0Count == 0) {
                        if (partialFinish(handler))
                            return true;
                    }

                    if (handler(c))
                        return true;

                    ccc0Count++;
                } else
                    break;
            }

            array = array[ccc0Count .. $];

            foreach (dchar c; array) {
                ubyte ccc = sidero_utf_lut_getCCC(c);

                if (ccc == 0)
                    break;
                else {
                    addToRotateBuffer(ccc, c);
                    nonCCC0count++;
                }
            }

            array = array[nonCCC0count .. $];

            if (array.length > 0) {
                // we got a CCC==0
                if (partialFinish(handler))
                    return true;
            }
        }

        return false;
    }
}
