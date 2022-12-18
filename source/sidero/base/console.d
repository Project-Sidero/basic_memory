module sidero.base.console;
import sidero.base.text;
import sidero.base.allocators;
import sidero.base.typecons : Optional;
import sidero.base.attributes : hidden;

export @safe nothrow @nogc:

///
StringBuilder_UTF8 readLine() {
    StringBuilder_UTF8 builder;
    readLine(builder);
    return builder;
}

/// Includes new line terminator
StringBuilder_ASCII readLine(scope return StringBuilder_ASCII builder) @trusted {
    import core.stdc.stdio : getc, EOF;

    mutex.pureLock;

    if (builder.isNull)
        builder = StringBuilder_ASCII(globalAllocator());

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : ReadConsoleA, INVALID_HANDLE_VALUE, CHAR, DWORD, GetLastError;

            allocateWindowsConsole();

            if (hStdin == INVALID_HANDLE_VALUE) {
                initializeForStdioImpl(null, null, false, true);
            } else {
                CONSOLE_READCONSOLE_CONTROL cReadControl;
                cReadControl.nLength = CONSOLE_READCONSOLE_CONTROL.sizeof;

                const originalBuilderLength = builder.length;
                CHAR[128] buffer;
                DWORD readLength;

                for (;;) {
                    if (ReadConsoleA(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength, &cReadControl)) {
                        bool more = readLength == buffer.length && buffer[$ - 1] != '\n';
                        builder ~= buffer[0 .. readLength];

                        if (!more)
                            break;
                    } else if (builder.length == originalBuilderLength) {
                        initializeForStdioImpl(null, null, false, true);
                        goto StdIO;
                    } else {
                        break;
                    }
                }

                mutex.unlock;
                return builder;
            }
        }
    }

StdIO:

    if (useStdio && stdioIn !is null) {
        for (;;) {
            int got = getc(stdioIn);

            if (got == EOF)
                break;

            char[1] buffer = [cast(char)got];
            builder ~= buffer[];

            if (got == '\n')
                break;
        }
    }

    mutex.unlock;
    return builder;
}

/// Includes new line terminator
StringBuilder_UTF8 readLine(scope return StringBuilder_UTF8 builder) @trusted {
    import core.stdc.stdio : getc, EOF;

    mutex.pureLock;

    if (builder.isNull)
        builder = StringBuilder_UTF8(globalAllocator());

    version (Windows) {
        if (useWindows) {
            import core.sys.windows.windows : ReadConsoleW, INVALID_HANDLE_VALUE, WCHAR, DWORD, GetLastError;

            allocateWindowsConsole();

            if (hStdin == INVALID_HANDLE_VALUE) {
                initializeForStdioImpl(null, null, false, true);
            } else {
                CONSOLE_READCONSOLE_CONTROL cReadControl;
                cReadControl.nLength = CONSOLE_READCONSOLE_CONTROL.sizeof;

                const originalBuilderLength = builder.length;
                WCHAR[128] buffer = void;
                DWORD readLength;

                for (;;) {
                    if (ReadConsoleW(hStdin, buffer.ptr, cast(uint)buffer.length, &readLength, &cReadControl)) {
                        bool more = readLength == buffer.length && buffer[$ - 1] != '\n';
                        builder ~= buffer[0 .. readLength];

                        if (!more)
                            break;
                    } else if (builder.length == originalBuilderLength) {
                        initializeForStdioImpl(null, null, false, true);
                        goto StdIO;
                    } else {
                        break;
                    }
                }

                mutex.unlock;
                return builder;
            }
        }
    }

StdIO:

    if (useStdio && stdioIn !is null) {
        for (;;) {
            int got = getc(stdioIn);

            if (got == EOF)
                break;

            char[1] buffer = [cast(char)got];
            builder ~= buffer[];

            if (got == '\n')
                break;
        }
    }

    mutex.unlock;
    return builder;
}

/// Ditto
StringBuilder_UTF16 readLine(scope return StringBuilder_UTF16 builder) {
    if (builder.isNull)
        builder = StringBuilder_UTF16(globalAllocator());

    readLine(builder.byUTF8());
    return builder;
}

/// Ditto
StringBuilder_UTF32 readLine(scope return StringBuilder_UTF32 builder) {
    if (builder.isNull)
        builder = StringBuilder_UTF32(globalAllocator());

    readLine(builder.byUTF8());
    return builder;
}

///
void write(Args...)(scope Args args) @trusted {
    import sidero.base.traits : isAnyString;
    import core.stdc.stdio : fwrite, fflush;

    uint prettyPrintDepth;
    bool prettyPrintActive = false, deliminateArguments = false, setPrettyDelim;
    bool isFirstPrettyPrint = true;

    void doOneWrapper(Type)(scope Type arg) {
        import sidero.base.allocators;

        static if (isAnyString!Type) {
            if (deliminateArguments)
                rawWrite(`"`);

            rawWrite(arg);

            if (deliminateArguments)
                rawWrite(`"`);
        } else static if (is(Type == InBandInfo)) {
            if (!arg.prettyPrintActive.isNull)
                prettyPrintActive = arg.prettyPrintActive.get;
            if (!arg.deliminateArguments.isNull)
                deliminateArguments = arg.deliminateArguments.get;
            if (!setPrettyDelim && !arg.prettyPrintActive.isNull && arg.deliminateArguments.isNull) {
                deliminateArguments = arg.prettyPrintActive.get;
                setPrettyDelim = true;
            }

            rawWrite(arg);
        } else {
            StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());

            if (prettyPrintActive) {
                PrettyPrint!String_UTF8 prettyPrint;
                prettyPrint.useQuotes = deliminateArguments;

                if (!isFirstPrettyPrint)
                    builder ~= "\n";
                isFirstPrettyPrint = false;

                prettyPrint.depth = prettyPrintDepth;
                prettyPrint(builder, arg);
            } else {
                builder.formattedWrite("", arg);
            }

            rawWrite(builder);
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
                    rawWrite(", ");
                gotPrintable++;
                wasDeliminted = true;
            } else if (wasDeliminted && !is(ArgType == InBandInfo)) {
                static if (!(isAnyString!ArgType))
                    rawWrite(", ");
                else if (arg != "\n")
                    rawWrite(", ");

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

export @trusted nothrow @nogc scope:

    this(scope return ref InBandInfo other) {
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

/// Writes string data to console (ASCII/Unicode aware) and immediately flushes.
void rawWrite(scope String_ASCII input) @trusted {
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
            if (WriteConsoleA(hStdout, cast(void*)input.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, false, true);
        }
    }

    if (useStdio) {
        fwrite(input.ptr, char.sizeof, useLength, stdioOut);
        fflush(stdioOut);
    }
}

/// Ditto
void rawWrite(scope StringBuilder_ASCII input) {
    rawWrite(input.asReadOnly());
}

/// Ditto
void rawWrite(scope const(char)[] input...) @trusted {
    rawWrite(String_UTF8(input));
}

/// Ditto
void rawWrite(scope const(wchar)[] input...) @trusted {
    rawWrite(String_UTF16(input));
}

/// Ditto
void rawWrite(scope const(dchar)[] input...) @trusted {
    rawWrite(String_UTF32(input));
}

/// Ditto
void rawWrite(scope String_UTF8 input) @trusted {
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
            if (WriteConsoleW(hStdout, cast(void*)input16.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, false, true);
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

        fwrite(input.ptr, char.sizeof, useLength, stdioOut);
        fflush(stdioOut);
    }
}

/// Ditto
void rawWrite(scope String_UTF16 input) @trusted {
    rawWrite(input.byUTF8());
}

/// Ditto
void rawWrite(scope String_UTF32 input) @trusted {
    rawWrite(input.byUTF8());
}

/// Ditto
void rawWrite(scope StringBuilder_UTF8 input) @trusted {
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
            if (WriteConsoleW(hStdout, cast(void*)input16.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, false, true);
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

        fwrite(input8.ptr, char.sizeof, useLength, stdioOut);
        fflush(stdioOut);
    }
}

/// Ditto
void rawWrite(scope StringBuilder_UTF16 input) {
    rawWrite(input.byUTF8());
}

/// Ditto
void rawWrite(scope StringBuilder_UTF32 input) {
    rawWrite(input.byUTF8());
}

/// Modifies the console settings (colors)
void rawWrite(scope InBandInfo input) @trusted {
    version (Windows) {
        import core.sys.windows.windows;

        if (useWindows) {
            mutex.pureLock;
            allocateWindowsConsole();

            CONSOLE_SCREEN_BUFFER_INFO currentInfo;
            GetConsoleScreenBufferInfo(hStdout, &currentInfo);

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

            SetConsoleTextAttribute(hStdout, attributes);
            mutex.unlock;
            return;
        }
    }

    if (useANSI) {
        if (input.resetDefaults)
            rawWrite(ANSI_Reset);

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
            rawWrite(fg);
        if (bg !is null)
            rawWrite(bg);
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
void initializeForStdio(FILE* useIn = null, FILE* useOut = null, bool autoClose = false, bool keepState = false) @trusted {
    mutex.pureLock;
    initializeForStdioImpl(useIn, useOut, autoClose, keepState);
    mutex.unlock;
}

///
void enableANSI(bool value = true) @trusted {
    useANSI = value;
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

    FILE* stdioIn, stdioOut;

    version (Windows) {
        HANDLE hStdin, hStdout;
        uint originalConsoleOutputCP, originalConsoleCP;
        bool createdConsole;
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
    import core.stdc.stdio : stdin, stdout;
}

version (Windows) {
    import core.sys.windows.windows : HANDLE, ULONG;

    // needed cos Unicode
    struct CONSOLE_READCONSOLE_CONTROL {
        ULONG nLength;
        ULONG nInitialChars;
        ULONG dwCtrlWakeupMask;
        ULONG dwControlKeyState;
    }
}

@trusted {
    version (Windows) {
        void allocateWindowsConsole() {
            import core.sys.windows.windows;

            if (AllocConsole())
                createdConsole = true;

            hStdin = GetStdHandle(STD_INPUT_HANDLE);
            hStdout = GetStdHandle(STD_OUTPUT_HANDLE);

            DWORD mode;
            GetConsoleMode(hStdout, &mode);
            SetConsoleMode(hStdout, mode | ENABLE_VIRTUAL_TERMINAL_PROCESSING | ENABLE_PROCESSED_OUTPUT);

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
            initializeForStdioImpl(null, null, false, false);

            if (!config.endsWith("ansi"))
                enableANSI = false;

            return;
        }

        version (Windows)
            initializeForWindowsImpl;
        else version (Posix)
            initializeForStdioImpl(null, null, false, false);
        else
            static assert(0, "Unimplemented");
    }

    void initializeForStdioImpl(FILE* useIn, FILE* useOut, bool autoClose, bool keepState) {
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

        if (useIn !is null || useOut !is null)
            autoCloseStdio = autoClose;
    }

    void deinitializeConsoleImpl() {
        import core.stdc.stdio : fflush, fclose;

        if (useStdio && autoCloseStdio && (stdioIn !is null || stdioOut !is null) && (stdioIn !is stdin || stdioOut !is stdout)) {
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
        }

        version (Windows) {
            import core.sys.windows.windows : FreeConsole, SetConsoleCP, SetConsoleOutputCP;

            if (originalConsoleCP > 0)
                SetConsoleCP(originalConsoleCP);
            if (originalConsoleOutputCP > 0)
                SetConsoleOutputCP(originalConsoleOutputCP);

            if (createdConsole) {
                FreeConsole();
                createdConsole = false;
            }
        }
    }
}
