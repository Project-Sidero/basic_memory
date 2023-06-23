module sidero.base.console.write;
import sidero.base.console.inbandinfo;
import sidero.base.console.internal.rawwrite;
import sidero.base.console.internal.mechanism;
import sidero.base.text;

export @safe nothrow @nogc:

/// Writes text out to stdout or stderr
void write(Args...)(scope Args args) {
    import sidero.base.console.internal.writer;

    Writer writer;
    assert(!writer.prettyPrintActive);
    assert(!writer.deliminateArguments);
    writer.isFirstPrettyPrint = true;

    writer.handle(args);
}

/// Adds newline at end
void writeln(Args...)(scope Args args) {
    write(args, deliminateArgs(false), "\n");
}

/// Turns on pretty printing and delimination of args by default.
void debugWrite(Args...)(scope Args args) {
    write(prettyPrintingActive(true), args);
}

///  Adds newline at end and turns on pretty printing and delimination of args by default.
void debugWriteln(Args...)(scope Args args) {
    debugWrite(args, deliminateArgs(false), "\n");
}

/// Writes string data to console (ASCII/Unicode aware) and immediately flushes.
void rawWrite(scope String_ASCII input, bool useError = false) @trusted {
    protectWriteAction(() {
        rawWriteImpl(input, useError);
    });
}

/// Ditto
void rawWrite(scope StringBuilder_ASCII input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input, useError);
    });
}

/// Ditto
void rawWrite(scope const(char)[] input, bool useError = false) {
    protectWriteAction(() @trusted {
        rawWriteImpl(String_UTF8(input), useError);
    });
}

/// Ditto
void rawWrite(scope const(wchar)[] input, bool useError = false) {
    protectWriteAction(() @trusted {
        rawWriteImpl(String_UTF8(input), useError);
    });
}

/// Ditto
void rawWrite(scope const(dchar)[] input, bool useError = false) {
    protectWriteAction(() @trusted {
        rawWriteImpl(String_UTF8(input), useError);
    });
}

/// Ditto
void rawWrite(scope String_UTF8 input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input, useError);
    });
}

/// Ditto
void rawWrite(scope String_UTF16 input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input.byUTF8(), useError);
    });
}

/// Ditto
void rawWrite(scope String_UTF32 input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input.byUTF8(), useError);
    });
}

/// Ditto
void rawWrite(scope StringBuilder_UTF8 input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input, useError);
    });
}

/// Ditto
void rawWrite(scope StringBuilder_UTF16 input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input.byUTF8(), useError);
    });
}

/// Ditto
void rawWrite(scope StringBuilder_UTF32 input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input.byUTF8(), useError);
    });
}

/// Modifies the console settings (colors)
void rawWrite(scope InBandInfo input, bool useError = false) {
    protectWriteAction(() {
        rawWriteImpl(input, useError);
    });
}
