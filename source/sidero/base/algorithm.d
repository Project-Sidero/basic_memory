module sidero.base.algorithm;
import std.range : isInputRange, isBidirectionalRange;
import std.traits : isDynamicArray;

@safe nothrow @nogc:

///
bool startsWith(Input1, Input2)(scope Input1 input1, scope Input2 input2)
        if ((isInputRange!Input1 || isDynamicArray!Input1) && (isInputRange!Input2 || isDynamicArray!Input2)) {
    for(;;) {
        static if (isDynamicArray!Input1) {
            if (input1.length == 0)
                return false;

            auto value1 = input1[0];
        } else {
            if (input1.empty)
                return false;

            auto value1 = input1.front;
        }

        static if (isDynamicArray!Input2) {
            if (input2.length == 0)
                return true;

            auto value2 = input2[0];
        } else {
            if (input2.empty)
                return true;

            auto value2 = input2.front;
        }

        if (value1 != value2)
            return false;

        static if (isDynamicArray!Input1) {
            input1 = input1[1 .. $];
        } else {
            input1.popFront;
        }

        static if (isDynamicArray!Input2) {
            input2 = input2[1 .. $];
        } else {
            input2.popFront;
        }
    }
}

///
unittest {
    static Input1 = "hello world", Input2 = "hello";
    assert(Input1.startsWith(Input2));
}

///
bool endsWith(Input1, Input2)(scope Input1 input1, scope Input2 input2)
if ((isBidirectionalRange!Input1 || isDynamicArray!Input1) && (isBidirectionalRange!Input2 || isDynamicArray!Input2)) {
    for(;;) {
        static if (isDynamicArray!Input1) {
            if (input1.length == 0)
                return false;

            auto value1 = input1[$-1];
        } else {
            if (input1.empty)
                return false;

            auto value1 = input1.back;
        }

        static if (isDynamicArray!Input2) {
            if (input2.length == 0)
                return true;

            auto value2 = input2[$-1];
        } else {
            if (input2.empty)
                return true;

            auto value2 = input2.back;
        }

        if (value1 != value2)
            return false;

        static if (isDynamicArray!Input1) {
            input1 = input1[0 .. $-1];
        } else {
            input1.popBack;
        }

        static if (isDynamicArray!Input2) {
            input2 = input2[0 .. $-1];
        } else {
            input2.popBack;
        }
    }
}

///
unittest {
    static Input1 = "hello world", Input2 = "world";
    assert(Input1.endsWith(Input2));
}
