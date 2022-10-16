module sidero.base.console;
import sidero.base.text;

@safe nothrow @nogc:

///
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

            initializeForStdio(null, null, false, true);
        }
    }

    if (useStdio) {
        fwrite(input.ptr, char.sizeof, useLength, stdioOut);
        fflush(stdioOut);
    }
}

///
void rawWrite(scope StringBuilder_ASCII input) {
    rawWrite(input.asReadOnly());
}

///
void rawWrite(scope const(char)[] input...) @trusted {
    rawWrite(String_UTF8(input));
}

///
void rawWrite(scope const(wchar)[] input...) @trusted {
    rawWrite(String_UTF16(input));
}

///
void rawWrite(scope const(dchar)[] input...) @trusted {
    rawWrite(String_UTF32(input));
}

///
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

            initializeForStdio(null, null, false, true);
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

///
void rawWrite(scope String_UTF16 input) {
    rawWrite(input.byUTF8());
}

///
void rawWrite(scope String_UTF32 input) {
    rawWrite(input.byUTF8());
}

///
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

            initializeForStdio(null, null, false, true);
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

///
void rawWrite(scope StringBuilder_UTF16 input) {
    rawWrite(input.byUTF8());
}

///
void rawWrite(scope StringBuilder_UTF32 input) {
    rawWrite(input.byUTF8());
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

private:
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
            initializeForStdioImpl;
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

        deinitializeConsole;

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
