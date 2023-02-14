module sidero.base.console;
import sidero.base.text;
import sidero.base.allocators;
import sidero.base.typecons : Optional;
import sidero.base.attributes : hidden;
import sidero.base.errors;
import sidero.base.datetime.duration;

export @safe nothrow @nogc:

/// Read's a single character, default is blocking.
Result!dchar readChar(Duration timeout = Duration.min) @trusted {
    import sidero.base.encoding.utf;
    import core.stdc.stdio : getc, EOF;

    mutex.pureLock;
    const block = timeout < Duration.zero;

    size_t outputBufferCount;
    char[4] outputBuffer = void;

    {
        version (Windows) {
            if (useWindows) {
                allocateWindowsConsole();

                wchar[2] outputBuffer16 = void;
                DWORD readLength;

                if (block) {
                    for (;;) {
                        if (ReadConsoleW(hStdin, &outputBuffer16[outputBufferCount], 1, &readLength, null)) {
                            outputBufferCount++;

                            if (outputBufferCount == 2 || decodeLength(outputBuffer16[0 .. 1]) == 1)
                                break;
                        } else {
                            break;
                        }
                    }
                } else {
                    bool needEcho;
                    {
                        DWORD mode;
                        GetConsoleMode(hStdin, &mode);
                        if ((mode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT) {
                            needEcho = true;
                        }
                    }

                    DWORD dwTimeout = cast(DWORD)timeout.totalMilliSeconds;
                    if (dwTimeout == 0)
                        dwTimeout = 1_000;

                    ReadLoopWindows: for (;;) {
                        DWORD result = WSAWaitForMultipleEvents(1, &hStdin, false, dwTimeout, true);

                        switch (result) {
                        case WSA_WAIT_EVENT_0:
                            INPUT_RECORD[1] buffer = void;

                            if (PeekConsoleInputW(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength)) {
                                foreach (ref value; buffer[0 .. readLength]) {
                                    if (value.EventType == KEY_EVENT && value.KeyEvent.bKeyDown == 1) {
                                        wchar[1] temp = [cast(wchar)value.KeyEvent.UnicodeChar];
                                        outputBuffer16[outputBufferCount] = temp[0];

                                        if (needEcho) {
                                            DWORD did;
                                            WriteConsoleW(hStdout, temp.ptr, 1, &did, null);
                                        }

                                        outputBufferCount++;
                                    }
                                }

                                ReadConsoleInputW(hStdin, buffer.ptr, cast(uint)readLength, &readLength);

                                if (decodeLength(outputBuffer16[0 .. outputBufferCount]) == outputBufferCount || outputBufferCount == 2) {
                                    break ReadLoopWindows;
                                }
                            }

                            break;
                        case WSA_WAIT_TIMEOUT:
                            mutex.unlock;
                            return typeof(return)(TimeOutException);
                        default:
                            break ReadLoopWindows;
                        }
                    }
                }

                if (outputBufferCount > 0) {
                    dchar output;
                    decode(outputBuffer16[0 .. outputBufferCount], output);

                    mutex.unlock;
                    return typeof(return)(output);
                } else {
                    mutex.unlock;
                    return typeof(return)(MalformedInputException("No input to read"));
                }
            }
        }

        if (useStdio && stdioIn !is null) {
            version (Posix) {
                import core.sys.posix.termios;

                termios originalTermios;

                if (!block) {
                    tcgetattr(stdioIn, &originalTermios);

                    termios toSetTermios;
                    toSetTermios.c_cc[VMIN] = 0;
                    toSetTermios.c_cc[VTIME] = cast(ubyte)(timeout.totalMilliSeconds / 100);

                    if (toSetTermios.c_cc[VTIME] == 0)
                        toSetTermios.c_cc[VTIME] = 10;

                    tcsetattr(stdioIn, TCSANOW, &toSetTermios);
                }
            }

            for (;;) {
                int got = getc(stdioIn);

                if (got == EOF)
                    break;

                outputBuffer[outputBufferCount++] = cast(char)got;

                if (decodeLength(outputBuffer[0 .. outputBufferCount]) == outputBufferCount || outputBufferCount == 4)
                    break;
            }

            version (Posix) {
                if (!block)
                    tcsetattr(stdioIn, TCSANOW, &originalTermios);
            }

            if (outputBufferCount > 0) {
                dchar output;
                decode(outputBuffer[0 .. outputBufferCount], output);

                mutex.unlock;
                return typeof(return)(output);
            } else {
                mutex.unlock;
                return typeof(return)(MalformedInputException("No input to read"));
            }
        }
    }

    assert(0);
}

/// Read one line in, default is blocking.
StringBuilder_UTF8 readLine(Duration timeout = Duration.min) {
    StringBuilder_UTF8 builder;
    readLine(builder, timeout);
    return builder;
}

/// Includes new line terminator, default is blocking.
StringBuilder_ASCII readLine(return scope ref StringBuilder_ASCII builder, Duration timeout = Duration.min) @trusted {
    import core.stdc.stdio : getc, EOF;

    mutex.pureLock;

    if (builder.isNull)
        builder = StringBuilder_ASCII(globalAllocator());
    const block = timeout < Duration.zero;

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : ReadConsoleA, INVALID_HANDLE_VALUE, CHAR, DWORD, GetLastError;

            allocateWindowsConsole();
            const originalBuilderLength = builder.length;

            if (hStdin == INVALID_HANDLE_VALUE) {
                initializeForStdioImpl(null, null, null, false, true);
            } else {
                DWORD readLength;

                if (block) {
                    CONSOLE_READCONSOLE_CONTROL cReadControl;
                    cReadControl.nLength = CONSOLE_READCONSOLE_CONTROL.sizeof;
                    cReadControl.dwCtrlWakeupMask = '\n';

                    CHAR[128] buffer = void;

                    for (;;) {
                        if (ReadConsoleA(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength, &cReadControl)) {
                            bool more = readLength == buffer.length && buffer[$ - 1] != '\n';
                            builder ~= buffer[0 .. readLength];

                            if (!more)
                                break;
                        } else if (builder.length == originalBuilderLength) {
                            initializeForStdioImpl(null, null, null, false, true);
                            goto StdIO;
                        } else {
                            break;
                        }
                    }
                } else {
                    bool needEcho;
                    {
                        DWORD mode;
                        GetConsoleMode(hStdin, &mode);
                        if ((mode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT) {
                            needEcho = true;
                        }
                    }

                    DWORD dwTimeout = cast(DWORD)timeout.totalMilliSeconds;
                    if (dwTimeout == 0)
                        dwTimeout = 1_000;

                    ReadLoopWindows: for (;;) {
                        DWORD result = WSAWaitForMultipleEvents(1, &hStdin, false, dwTimeout, true);

                        switch (result) {
                        case WSA_WAIT_EVENT_0:
                            INPUT_RECORD[128] buffer = void;

                            if (PeekConsoleInputA(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength)) {
                                size_t count;
                                bool lastNewLine;

                                foreach (ref value; buffer[0 .. readLength]) {
                                    if (value.EventType == KEY_EVENT && value.KeyEvent.bKeyDown == 1) {
                                        ubyte[1] temp = [cast(ubyte)value.KeyEvent.AsciiChar];
                                        builder ~= temp[];

                                        if (needEcho) {
                                            DWORD did;
                                            WriteConsoleA(hStdout, temp.ptr, 1, &did, null);
                                        }

                                        count++;
                                        if (value.KeyEvent.AsciiChar == '\r') {
                                            temp = [cast(ubyte)'\n'];
                                            builder ~= temp[];

                                            if (needEcho) {
                                                DWORD did;
                                                WriteConsoleA(hStdout, temp.ptr, 1, &did, null);
                                            }

                                            lastNewLine = true;
                                            break;
                                        }
                                    }
                                }

                                ReadConsoleInputA(hStdin, buffer.ptr, cast(uint)readLength, &readLength);
                                if (lastNewLine)
                                    break ReadLoopWindows;
                            }

                            break;
                        case WSA_WAIT_TIMEOUT:
                        default:
                            break ReadLoopWindows;
                        }
                    }
                }

                mutex.unlock;
                return builder;
            }
        }
    }

StdIO:

    if (useStdio && stdioIn !is null) {
        version (Posix) {
            import core.sys.posix.termios;

            termios originalTermios;

            if (!block) {
                tcgetattr(stdioIn, &originalTermios);

                termios toSetTermios;
                toSetTermios.c_cc[VMIN] = 0;
                toSetTermios.c_cc[VTIME] = cast(ubyte)(timeout.totalMilliSeconds / 100);

                if (toSetTermios.c_cc[VTIME] == 0)
                    toSetTermios.c_cc[VTIME] = 10;

                tcsetattr(stdioIn, TCSANOW, &toSetTermios);
            }
        }

        for (;;) {
            int got = getc(stdioIn);

            if (got == EOF)
                break;

            char[1] buffer = [cast(char)got];
            builder ~= buffer[];

            if (got == '\n')
                break;
        }

        version (Posix) {
            if (!block)
                tcsetattr(stdioIn, TCSANOW, &originalTermios);
        }
    }

    mutex.unlock;
    return builder;
}

/// Includes new line terminator, default is blocking.
StringBuilder_UTF8 readLine(return scope ref StringBuilder_UTF8 builder, Duration timeout = Duration.min) @trusted {
    import core.stdc.stdio : getc, EOF;

    mutex.pureLock;

    if (builder.isNull)
        builder = StringBuilder_UTF8(globalAllocator());
    const block = timeout < Duration.zero;

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : ReadConsoleW, INVALID_HANDLE_VALUE, WCHAR, DWORD, GetLastError;

            allocateWindowsConsole();
            const originalBuilderLength = builder.length;

            if (hStdin == INVALID_HANDLE_VALUE) {
                initializeForStdioImpl(null, null, null, false, true);
            } else {
                DWORD readLength;

                if (block) {
                    CONSOLE_READCONSOLE_CONTROL cReadControl;
                    cReadControl.nLength = CONSOLE_READCONSOLE_CONTROL.sizeof;
                    cReadControl.dwCtrlWakeupMask = '\n';

                    WCHAR[128] buffer = void;

                    for (;;) {
                        if (ReadConsoleW(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength, &cReadControl)) {
                            bool more = readLength == buffer.length && buffer[$ - 1] != '\n';
                            builder ~= buffer[0 .. readLength];

                            if (!more)
                                break;
                        } else if (builder.length == originalBuilderLength) {
                            initializeForStdioImpl(null, null, null, false, true);
                            goto StdIO;
                        } else {
                            break;
                        }
                    }
                } else {
                    bool needEcho;
                    {
                        DWORD mode;
                        GetConsoleMode(hStdin, &mode);
                        if ((mode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT) {
                            needEcho = true;
                        }
                    }

                    DWORD dwTimeout = cast(DWORD)timeout.totalMilliSeconds;
                    if (dwTimeout == 0)
                        dwTimeout = 1_000;

                    ReadLoopWindows: for (;;) {
                        DWORD result = WSAWaitForMultipleEvents(1, &hStdin, false, dwTimeout, true);

                        switch (result) {
                        case WSA_WAIT_EVENT_0:
                            INPUT_RECORD[128] buffer = void;

                            if (PeekConsoleInputW(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength)) {
                                size_t count;
                                bool lastNewLine;

                                foreach (ref value; buffer[0 .. readLength]) {
                                    if (value.EventType == KEY_EVENT && value.KeyEvent.bKeyDown == 1) {
                                        wchar[1] temp = [value.KeyEvent.UnicodeChar];
                                        builder ~= temp[];

                                        if (needEcho) {
                                            DWORD did;
                                            WriteConsoleW(hStdout, temp.ptr, 1, &did, null);
                                        }

                                        count++;
                                        if (value.KeyEvent.UnicodeChar == '\r') {
                                            temp = [cast(wchar)'\n'];
                                            builder ~= temp[];

                                            if (needEcho) {
                                                DWORD did;
                                                WriteConsoleW(hStdout, temp.ptr, 1, &did, null);
                                            }

                                            lastNewLine = true;
                                            break;
                                        }
                                    }
                                }

                                ReadConsoleInputW(hStdin, buffer.ptr, cast(uint)readLength, &readLength);
                                if (lastNewLine)
                                    break ReadLoopWindows;
                            }

                            break;
                        case WSA_WAIT_TIMEOUT:
                        default:
                            break ReadLoopWindows;
                        }
                    }
                }

                mutex.unlock;
                return builder;
            }
        }
    }

StdIO:

    if (useStdio && stdioIn !is null) {
        version (Posix) {
            import core.sys.posix.termios;

            termios originalTermios;

            if (!block) {
                tcgetattr(stdioIn, &originalTermios);

                termios toSetTermios;
                toSetTermios.c_cc[VMIN] = 0;
                toSetTermios.c_cc[VTIME] = cast(ubyte)(timeout.totalMilliSeconds / 100);

                if (toSetTermios.c_cc[VTIME] == 0)
                    toSetTermios.c_cc[VTIME] = 10;

                tcsetattr(stdioIn, TCSANOW, &toSetTermios);
            }
        }

        for (;;) {
            int got = getc(stdioIn);

            if (got == EOF)
                break;

            char[1] buffer = [cast(char)got];
            builder ~= buffer[];

            if (got == '\n')
                break;
        }

        version (Posix) {
            if (!block)
                tcsetattr(stdioIn, TCSANOW, &originalTermios);
        }
    }

    mutex.unlock;
    return builder;
}

/// Ditto
StringBuilder_UTF16 readLine(return scope ref StringBuilder_UTF16 builder, Duration timeout = Duration.min) {
    if (builder.isNull)
        builder = StringBuilder_UTF16(globalAllocator());

    auto temp = builder.byUTF8();
    readLine(temp, timeout);
    return builder;
}

/// Ditto
StringBuilder_UTF32 readLine(return scope ref StringBuilder_UTF32 builder, Duration timeout = Duration.min) {
    if (builder.isNull)
        builder = StringBuilder_UTF32(globalAllocator());

    auto temp = builder.byUTF8();
    readLine(temp, timeout);
    return builder;
}

///
void write(Args...)(scope Args args) @trusted {
    import sidero.base.traits : isAnyString;
    import core.stdc.stdio : fwrite, fflush;

    uint prettyPrintDepth;
    bool prettyPrintActive = false, deliminateArguments = false, setPrettyDelim;
    bool isFirstPrettyPrint = true;
    bool useErrorStream;

    void doOneWrapper(Type)(scope Type arg) {
        import sidero.base.allocators;

        static if (isAnyString!Type) {
            if (deliminateArguments) {
                rawWrite(`"`, useErrorStream);
                rawWrite(format(String_ASCII.init, arg), useErrorStream);
                rawWrite(`"`, useErrorStream);
            } else
                rawWrite(arg, useErrorStream);
        } else static if (is(Type == InBandInfo)) {
            if (!arg.prettyPrintActive.isNull)
                prettyPrintActive = arg.prettyPrintActive.get;
            if (!arg.deliminateArguments.isNull)
                deliminateArguments = arg.deliminateArguments.get;
            if (!setPrettyDelim && !arg.prettyPrintActive.isNull && arg.deliminateArguments.isNull) {
                deliminateArguments = arg.prettyPrintActive.get;
                setPrettyDelim = true;
            }
            if (!arg.useError.isNull)
                useErrorStream = arg.useError.get;

            rawWrite(arg);
        } else {
            StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());

            if (prettyPrintActive) {
                PrettyPrint!String_UTF8 prettyPrint;
                prettyPrint.useQuotes = deliminateArguments;
                prettyPrint.startWithoutPrefix = true;

                if (!isFirstPrettyPrint)
                    builder ~= "\n";
                isFirstPrettyPrint = false;

                prettyPrint.depth = prettyPrintDepth;
                prettyPrint(builder, arg);
            } else {
                builder.formattedWrite("", arg);
            }

            rawWrite(builder, useErrorStream);
        }
    }

    static if (Args.length == 1) {
        alias ArgType = typeof(args[0]);
        scope doOneWrapper2 = &doOneWrapper!ArgType;
        (cast(void delegate(scope ArgType)@nogc nothrow @safe pure)doOneWrapper2)(args[0]);
    } else {
        size_t gotPrintable;
        bool wasDeliminted;

        foreach (i, ref arg; args) {
            alias ArgType = typeof(arg);

            if (deliminateArguments && !is(ArgType == InBandInfo)) {
                if (gotPrintable > 0)
                    rawWrite(", ", useErrorStream);
                gotPrintable++;
                wasDeliminted = true;
            } else if (wasDeliminted && !is(ArgType == InBandInfo)) {
                static if (!(isAnyString!ArgType))
                    rawWrite(", ", useErrorStream);
                else if (arg != "\n")
                    rawWrite(", ", useErrorStream);

                wasDeliminted = false;
            }

            scope doOneWrapper2 = &doOneWrapper!ArgType;
            (cast(void delegate(scope ArgType)@nogc nothrow @safe pure)doOneWrapper2)(arg);

            if (!deliminateArguments && is(ArgType == InBandInfo))
                gotPrintable = 0;
        }
    }
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

///
enum ConsoleColor {
    ///
    Unknown,
    ///
    Black,
    ///
    Red,
    ///
    Green,
    ///
    Yellow,
    ///
    Blue,
    ///
    Magenta,
    ///
    Cyan,
    ///
    White,
}

///
struct InBandInfo {
    ///
    bool resetDefaults;
    ///
    Optional!bool deliminateArguments;
    ///
    ConsoleColor backgroundColor, foregroundColor;
    ///
    Optional!bool prettyPrintActive;
    ///
    Optional!bool useError;

export @trusted nothrow @nogc scope:

    this(return scope ref InBandInfo other) {
        this.tupleof = other.tupleof;
    }

    ///
    InBandInfo resetDefaultBeforeApplying(bool value = true) {
        InBandInfo ret = this;
        ret.resetDefaults = value;
        return ret;
    }

    ///
    InBandInfo deliminateArgs(bool value = false) {
        InBandInfo ret = this;
        ret.deliminateArguments = value;
        return ret;
    }

    ///
    InBandInfo background(ConsoleColor color) {
        InBandInfo ret = this;
        ret.backgroundColor = color;
        return ret;
    }

    ///
    InBandInfo foreground(ConsoleColor color) {
        InBandInfo ret = this;
        ret.foregroundColor = color;
        return ret;
    }

    ///
    InBandInfo prettyPrintingActive(bool active) {
        InBandInfo ret = this;
        ret.prettyPrintActive = active;
        return ret;
    }

    ///
    InBandInfo useErrorStream(bool useError) {
        InBandInfo ret = this;
        ret.useError = useError;
        return ret;
    }
}

///
InBandInfo resetDefaultBeforeApplying(bool value = true) {
    return InBandInfo().resetDefaultBeforeApplying(value);
}

///
InBandInfo deliminateArgs(bool value = false) {
    return InBandInfo().deliminateArgs(value);
}

///
InBandInfo background(ConsoleColor color) {
    return InBandInfo().background(color);
}

///
InBandInfo foreground(ConsoleColor color) {
    return InBandInfo().foreground(color);
}

///
InBandInfo prettyPrintingActive(bool active) {
    return InBandInfo().prettyPrintingActive(active);
}

///
InBandInfo useErrorStream(bool useError) {
    return InBandInfo().useErrorStream(useError);
}

/// Writes string data to console (ASCII/Unicode aware) and immediately flushes.
void rawWrite(scope String_ASCII input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    mutex.pureLock;
    scope (exit)
        mutex.unlock;

    if (!input.isPtrNullTerminated())
        input = input.dup;
    input.stripZeroTerminator;

    uint useLength = cast(uint)input.length;
    if (input.length == 0)
        return;

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : WriteConsoleA;

            allocateWindowsConsole();
            if (WriteConsoleA(useError ? hStdError : hStdout, cast(void*)input.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if (useStdio) {
        fwrite(input.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}

/// Ditto
void rawWrite(scope StringBuilder_ASCII input, bool useError = false) {
    rawWrite(input.asReadOnly(), useError);
}

/// Ditto
void rawWrite(scope const(char)[] input, bool useError = false) @trusted {
    rawWrite(String_UTF8(input), useError);
}

/// Ditto
void rawWrite(scope const(wchar)[] input, bool useError = false) @trusted {
    rawWrite(String_UTF16(input), useError);
}

/// Ditto
void rawWrite(scope const(dchar)[] input, bool useError = false) @trusted {
    rawWrite(String_UTF32(input), useError);
}

/// Ditto
void rawWrite(scope String_UTF8 input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    mutex.pureLock;
    scope (exit)
        mutex.unlock;

    uint useLength;

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : WriteConsoleW;

            String_UTF16 input16 = input.byUTF16();

            {
                if (!input16.isPtrNullTerminated())
                    input16 = input16.dup;

                input16.stripZeroTerminator;

                useLength = cast(uint)input16.length;
                if (input16.length == 0)
                    return;
            }

            allocateWindowsConsole();
            if (WriteConsoleW(useError ? hStdError : hStdout, cast(void*)input16.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if (useStdio) {
        {
            if (!input.isPtrNullTerminated())
                input = input.dup;

            input.stripZeroTerminator;

            useLength = cast(uint)input.length;
            if (input.length == 0)
                return;
        }

        fwrite(input.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}

/// Ditto
void rawWrite(scope String_UTF16 input, bool useError = false) @trusted {
    rawWrite(input.byUTF8(), useError);
}

/// Ditto
void rawWrite(scope String_UTF32 input, bool useError = false) @trusted {
    rawWrite(input.byUTF8(), useError);
}

/// Ditto
void rawWrite(scope StringBuilder_UTF8 input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    mutex.pureLock;
    scope (exit)
        mutex.unlock;

    uint useLength;

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : WriteConsoleW;

            String_UTF16 input16 = input.byUTF16().asReadOnly();

            {
                input16.stripZeroTerminator;

                useLength = cast(uint)input16.length;
                if (input16.length == 0)
                    return;
            }

            allocateWindowsConsole();
            if (WriteConsoleW(useError ? hStdError : hStdout, cast(void*)input16.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if (useStdio) {
        String_UTF8 input8 = input.asReadOnly();

        {
            input8.stripZeroTerminator;

            useLength = cast(uint)input8.length;
            if (input8.length == 0)
                return;
        }

        fwrite(input8.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}

/// Ditto
void rawWrite(scope StringBuilder_UTF16 input, bool useError = false) {
    rawWrite(input.byUTF8(), useError);
}

/// Ditto
void rawWrite(scope StringBuilder_UTF32 input, bool useError = false) {
    rawWrite(input.byUTF8(), useError);
}

/// Modifies the console settings (colors)
void rawWrite(scope InBandInfo input, bool useError = false) @trusted {
    version (Windows) {
        import core.sys.windows.windows;

        if (useWindows) {
            mutex.pureLock;
            allocateWindowsConsole();

            HANDLE hOut = useError ? hStdError : hStdout;

            CONSOLE_SCREEN_BUFFER_INFO currentInfo;
            GetConsoleScreenBufferInfo(hOut, &currentInfo);

            WORD attributes;

            final switch (input.foregroundColor) {
            case ConsoleColor.Black:
                break;
            case ConsoleColor.Red:
                attributes |= FOREGROUND_RED;
                break;
            case ConsoleColor.Green:
                attributes |= FOREGROUND_GREEN;
                break;
            case ConsoleColor.Yellow:
                attributes |= FOREGROUND_RED;
                attributes |= FOREGROUND_GREEN;
                break;
            case ConsoleColor.Blue:
                attributes |= FOREGROUND_BLUE;
                break;
            case ConsoleColor.Magenta:
                attributes |= FOREGROUND_RED;
                attributes |= FOREGROUND_BLUE;
                break;
            case ConsoleColor.Cyan:
                attributes |= FOREGROUND_BLUE;
                attributes |= FOREGROUND_GREEN;
                break;
            case ConsoleColor.White:
                attributes |= FOREGROUND_RED;
                attributes |= FOREGROUND_GREEN;
                attributes |= FOREGROUND_BLUE;
                break;
            case ConsoleColor.Unknown:
                enum FRGB = FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE;

                if (input.resetDefaults)
                    attributes |= FRGB;
                else
                    attributes |= currentInfo.wAttributes & FRGB;
                break;
            }

            final switch (input.backgroundColor) {
            case ConsoleColor.Black:
                break;
            case ConsoleColor.Red:
                attributes |= BACKGROUND_RED;
                break;
            case ConsoleColor.Green:
                attributes |= BACKGROUND_GREEN;
                break;
            case ConsoleColor.Yellow:
                attributes |= BACKGROUND_RED;
                attributes |= BACKGROUND_GREEN;
                break;
            case ConsoleColor.Blue:
                attributes |= BACKGROUND_BLUE;
                break;
            case ConsoleColor.Magenta:
                attributes |= BACKGROUND_RED;
                attributes |= BACKGROUND_BLUE;
                break;
            case ConsoleColor.Cyan:
                attributes |= BACKGROUND_BLUE;
                attributes |= BACKGROUND_GREEN;
                break;
            case ConsoleColor.White:
                attributes |= BACKGROUND_RED;
                attributes |= BACKGROUND_GREEN;
                attributes |= BACKGROUND_BLUE;
                break;
            case ConsoleColor.Unknown:
                enum BRGB = BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE;
                if (!input.resetDefaults)
                    attributes |= currentInfo.wAttributes & BRGB;
                break;
            }

            SetConsoleTextAttribute(hOut, attributes);
            mutex.unlock;
            return;
        }
    }

    if (useANSI) {
        if (input.resetDefaults)
            rawWrite(String_UTF8(ANSI_Reset), useError);

        string fg, bg;

        final switch (input.foregroundColor) {
        case ConsoleColor.Black:
            fg = ANSI_ESC ~ "30m";
            break;
        case ConsoleColor.Red:
            fg = ANSI_ESC ~ "31m";
            break;
        case ConsoleColor.Green:
            fg = ANSI_ESC ~ "32m";
            break;
        case ConsoleColor.Yellow:
            fg = ANSI_ESC ~ "33m";
            break;
        case ConsoleColor.Blue:
            fg = ANSI_ESC ~ "34m";
            break;
        case ConsoleColor.Magenta:
            fg = ANSI_ESC ~ "35m";
            break;
        case ConsoleColor.Cyan:
            fg = ANSI_ESC ~ "36m";
            break;
        case ConsoleColor.White:
            fg = ANSI_ESC ~ "37m";
            break;
        case ConsoleColor.Unknown:
            break;
        }

        final switch (input.backgroundColor) {
        case ConsoleColor.Black:
            bg = ANSI_ESC ~ "40m";
            break;
        case ConsoleColor.Red:
            bg = ANSI_ESC ~ "41m";
            break;
        case ConsoleColor.Green:
            bg = ANSI_ESC ~ "42m";
            break;
        case ConsoleColor.Yellow:
            bg = ANSI_ESC ~ "43m";
            break;
        case ConsoleColor.Blue:
            bg = ANSI_ESC ~ "44m";
            break;
        case ConsoleColor.Magenta:
            bg = ANSI_ESC ~ "45m";
            break;
        case ConsoleColor.Cyan:
            bg = ANSI_ESC ~ "46m";
            break;
        case ConsoleColor.White:
            bg = ANSI_ESC ~ "47m";
            break;
        case ConsoleColor.Unknown:
            break;
        }

        if (fg !is null)
            rawWrite(String_UTF8(fg), useError);
        if (bg !is null)
            rawWrite(String_UTF8(bg), useError);
    }
}

/// Initializes defaults automatically, has the environment variable SideroBase_Console to set either Windows, stdio, or stdio_ansi backend.
pragma(crt_constructor) extern (C) void initializeConsoleDefault() @trusted {
    mutex.pureLock;
    initializeConsoleDefaultImpl;
    mutex.unlock;
}

version (Windows) {
    ///
    void initializeForWindows() @trusted {
        mutex.pureLock;
        initializeForWindowsImpl;
        mutex.unlock;
    }
}

///
void initializeForStdio(FILE* useIn = null, FILE* useOut = null, FILE* useError = null, bool autoClose = false, bool keepState = false) @trusted {
    mutex.pureLock;
    initializeForStdioImpl(useIn, useOut, useError, autoClose, keepState);
    mutex.unlock;
}

///
void enableANSI(bool value = true) @trusted {
    useANSI = value;
}

/// Enter raw mode, suitable for TUI. Note disables Ctrl+C signal.
bool enableRawMode() @trusted {
    mutex.pureLock;
    bool ret;

    // no echo
    // turn off canonical mode so reading byte by byte
    // turn off signals ctrl+c, ctrl+z, ctrl+s, ctrl+q, ctrl+v, ctrl+m
    // turn off output processing of \n to \r\n
    // clean up UTF-8 handling stuff

    version (Windows) {
        import core.sys.windows.windows;

        if (useWindows) {
            allocateWindowsConsole();

            if (hStdin == INVALID_HANDLE_VALUE || hStdout == INVALID_HANDLE_VALUE) {
                initializeForStdioImpl(null, null, null, false, true);
            } else {
                DWORD inputMode = originalConsoleInputMode, outputMode = originalConsoleOutputMode;
                inputMode &= ~(ENABLE_LINE_INPUT | ENABLE_PROCESSED_INPUT | ENABLE_ECHO_INPUT);
                outputMode &= ~(ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT | DISABLE_NEWLINE_AUTO_RETURN |
                        ENABLE_LVB_GRID_WORLDWIDE);
                outputMode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;

                ret = SetConsoleMode(hStdin, inputMode) != 0 && SetConsoleMode(hStdout, outputMode) != 0;
                if (!ret) {
                    SetConsoleMode(hStdin, originalConsoleInputMode);
                    SetConsoleMode(hStdout, originalConsoleOutputMode);
                }
            }
        }
    }

    if (useStdio && stdioIn !is null) {
        version (Posix) {
            import core.sys.posix.termios;

            termios settings;
            tcgetattr(stdioIn, &settings);

            // ISTRIP is 8th bit stripped so turns it off, for UTF-8 support
            settings.c_iflag &= ~(BRKINT | ICRNL | ISTRIP | IXON);
            settings.c_oflag &= ~(OPOST);
            settings.c_cflag |= (CS8); // 8bits, UTF-8
            settings.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);

            ret = tcsetattr(stdioIn, TCSAFLUSH, &settings) == 0;
        }
    }

    mutex.unlock;
    return ret;
}

///
pragma(crt_destructor) extern (C) void deinitializeConsole() @trusted {
    mutex.pureLock;
    deinitializeConsoleImpl();
    mutex.unlock;
}

private @hidden:
import sidero.base.parallelism.mutualexclusion;
import core.stdc.stdio : FILE;

__gshared {
    TestTestSetLockInline mutex;
    bool useANSI, useWindows, useStdio, autoCloseStdio;

    FILE* stdioIn, stdioOut, stdioError;

    version (Windows) {
        HANDLE hStdin, hStdout, hStdError;
        DWORD originalConsoleInputMode, originalConsoleOutputMode, originalConsoleErrorMode;
        uint originalConsoleOutputCP, originalConsoleCP;
        bool createdConsole;
    } else version (Posix) {
        import core.sys.posix.termios : termios;

        termios originalTermiosSettings;
        bool resetOriginalTermios;
    }
}

enum {
    ANSI_ESC = "^[",
    ANSI_Reset = ANSI_ESC ~ "0m",
}

version (CRuntime_Microsoft) {
    // from druntime bug fix

    extern (C) FILE* __acrt_iob_func(int hnd) nothrow @nogc;
    FILE* stdin()() @trusted nothrow @nogc {
        return __acrt_iob_func(0);
    }

    FILE* stdout()() @trusted nothrow @nogc {
        return __acrt_iob_func(1);
    }

    FILE* stderr()() @trusted nothrow @nogc {
        return __acrt_iob_func(2);
    }
} else {
    import core.stdc.stdio : stdin, stdout, stderr;
}

version (Windows) {
    import core.sys.windows.windows : HANDLE, CHAR, WCHAR, ULONG, BOOL, DWORD, WORD, UINT, COORD, WAIT_TIMEOUT,
        WAIT_OBJECT_0, PeekConsoleInputA, ReadConsoleInputA, PeekConsoleInputW, ReadConsoleInputW, KEY_EVENT,
        GetConsoleMode, ENABLE_ECHO_INPUT, WriteConsoleA, WriteConsoleW, ReadConsoleW;

    alias WSAEVENT = HANDLE;

    enum {
        WSA_WAIT_TIMEOUT = WAIT_TIMEOUT,
        WSA_WAIT_EVENT_0 = WAIT_OBJECT_0
    }

    // needed cos Unicode
    struct CONSOLE_READCONSOLE_CONTROL {
        ULONG nLength;
        ULONG nInitialChars;
        ULONG dwCtrlWakeupMask;
        ULONG dwControlKeyState;
    }

    struct INPUT_RECORD {
        WORD EventType;

        union {
            KEY_EVENT_RECORD KeyEvent;
            MOUSE_EVENT_RECORD MouseEvent;
            WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
            MENU_EVENT_RECORD MenuEvent;
            FOCUS_EVENT_RECORD FocusEvent;
        }
    }

    struct FOCUS_EVENT_RECORD {
        BOOL bSetFocus;
    }

    struct MENU_EVENT_RECORD {
        UINT dwCommandId;
    }

    struct MOUSE_EVENT_RECORD {
        COORD dwMousePosition;
        DWORD dwButtonState;
        DWORD dwControlKeyState;
        DWORD dwEventFlags;
    }

    struct WINDOW_BUFFER_SIZE_RECORD {
        COORD dwSize;
    }

    struct KEY_EVENT_RECORD {
        BOOL bKeyDown;
        WORD wRepeatCount;
        WORD wVirtualKeyCode;
        WORD wVirtualScanCode;
        union {
            WCHAR UnicodeChar;
            CHAR AsciiChar;
        }

        DWORD dwControlKeyState;
    }

    extern (Windows) DWORD WSAWaitForMultipleEvents(DWORD, const WSAEVENT*, BOOL, DWORD, BOOL);
    extern (Windows) BOOL PeekConsoleInputA(HANDLE, INPUT_RECORD*, DWORD, DWORD*);
    extern (Windows) BOOL PeekConsoleInputW(HANDLE, INPUT_RECORD*, DWORD, DWORD*);
    extern (Windows) BOOL ReadConsoleInputA(HANDLE, INPUT_RECORD*, DWORD, DWORD*);
    extern (Windows) BOOL ReadConsoleInputW(HANDLE, INPUT_RECORD*, DWORD, DWORD*);
}

@trusted {
    version (Windows) {
        void allocateWindowsConsole() {
            import core.sys.windows.windows;

            if (AllocConsole())
                createdConsole = true;

            hStdin = GetStdHandle(STD_INPUT_HANDLE);
            hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
            hStdError = GetStdHandle(STD_ERROR_HANDLE);

            GetConsoleMode(hStdin, &originalConsoleInputMode);
            GetConsoleMode(hStdout, &originalConsoleOutputMode);
            GetConsoleMode(hStdError, &originalConsoleErrorMode);
            SetConsoleMode(hStdout, originalConsoleOutputMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING | ENABLE_PROCESSED_OUTPUT);
            SetConsoleMode(hStdError, originalConsoleErrorMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING | ENABLE_PROCESSED_OUTPUT);

            originalConsoleOutputCP = GetConsoleOutputCP();
            if (!SetConsoleOutputCP(65001))
                originalConsoleOutputCP = 0;

            originalConsoleCP = GetConsoleCP();
            if (!SetConsoleCP(65001))
                originalConsoleCP = 0;
        }
    }

    void initializeForWindowsImpl() {
        useWindows = true;
        useANSI = false;
        useStdio = false;
        autoCloseStdio = false;

        deinitializeConsoleImpl();
    }

    void initializeConsoleDefaultImpl() {
        import sidero.base.system : EnvironmentVariables;

        String_ASCII config = EnvironmentVariables[String_ASCII("SideroBase_Console")];

        version (Windows) {
            if (config == "Windows") {
                initializeForWindowsImpl;
                return;
            }
        }

        if (config.startsWith("stdio")) {
            initializeForStdioImpl(null, null, null, false, false);

            if (!config.endsWith("ansi"))
                enableANSI = false;

            return;
        }

        version (Windows)
            initializeForWindowsImpl;
        else version (Posix)
            initializeForStdioImpl(null, null, null, false, false);
        else
            static assert(0, "Unimplemented");
    }

    void initializeForStdioImpl(FILE* useIn, FILE* useOut, FILE* useError, bool autoClose, bool keepState) {
        import sidero.base.system : EnvironmentVariables;

        useStdio = true;

        if (useWindows && keepState) {
            useANSI = EnvironmentVariables[String_ASCII("ConEmuANSI")] == "ON";
        } else {
            useANSI = true;
            useWindows = false;
        }

        deinitializeConsoleImpl;

        if (useIn !is null)
            stdioIn = useIn;
        else
            stdioIn = stdin;
        if (useOut !is null)
            stdioOut = useOut;
        else
            stdioOut = stdout;
        if (useError !is null)
            stdioError = useError;
        else
            stdioError = stderr;

        if (useIn !is null || useOut !is null)
            autoCloseStdio = autoClose;

        version (Posix) {
            import core.sys.posix.termios;

            if (useIn is null) {
                resetOriginalTermios = tcgetattr(stdioIn, &originalTermiosSettings) == 0;
            }
        }
    }

    void deinitializeConsoleImpl() {
        import core.stdc.stdio : fflush, fclose;

        if (useStdio && autoCloseStdio && (stdioIn !is null || stdioOut !is null || stdioError !is null) && (stdioIn !is stdin ||
                stdioOut !is stdout || stdioError !is stderr)) {
            if (stdioIn !is null) {
                fflush(stdioIn);
                if (stdioIn !is stdin)
                    fclose(stdioIn);
            }

            if (stdioOut !is null) {
                fflush(stdioOut);
                if (stdioOut !is stdout)
                    fclose(stdioOut);
            }

            if (stdioError !is null) {
                fflush(stdioError);
                if (stdioError !is stdout)
                    fclose(stdioError);
            }
        }

        version (Windows) {
            import core.sys.windows.windows : FreeConsole, SetConsoleCP, SetConsoleOutputCP, SetConsoleMode;

            if (originalConsoleCP > 0)
                SetConsoleCP(originalConsoleCP);
            if (originalConsoleOutputCP > 0)
                SetConsoleOutputCP(originalConsoleOutputCP);

            SetConsoleMode(hStdin, originalConsoleInputMode);
            SetConsoleMode(hStdout, originalConsoleOutputMode);
            SetConsoleMode(hStdError, originalConsoleErrorMode);

            if (createdConsole) {
                FreeConsole();
                createdConsole = false;
            }
        } else version (Posix) {
            import core.sys.posix.termios;

            if (resetOriginalTermios) {
                tcsetattr(stdioIn, TCSAFLUSH, &originalTermiosSettings);
            }
        }
    }
}
