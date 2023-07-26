module sidero.base.console.internal.mechanism;
import sidero.base.console.internal.bindings;
import sidero.base.internal.logassert : stderr, stdout, stdin;
import sidero.base.synchronization.mutualexclusion;
import sidero.base.synchronization.rwmutex;
import sidero.base.text;

export @safe nothrow @nogc:

__gshared {
    ReaderWriterLockInline rwlock;
    TestTestSetLockInline readingLock, writingLock;
    bool useANSI, useWindows, useStdio, autoCloseStdio, consoleSetup;

    FILE* stdioIn, stdioOut, stdioError;

    version(Windows) {
        HANDLE hStdin, hStdout, hStdError, hStdinPipeEvent;
        DWORD originalConsoleInputMode, originalConsoleOutputMode, originalConsoleErrorMode;
        uint originalConsoleOutputCP, originalConsoleCP;
        bool createdConsole, isStdinConsole, setStdinMode, setStdoutMode, setStderrMode, isStdinPipe;
    } else version(Posix) {
        import core.sys.posix.termios : termios;

        termios originalTermiosSettings;
        bool resetOriginalTermios;
    }
}

enum {
    ANSI_ESC = "^[",
    ANSI_Reset = ANSI_ESC ~ "0m",
}

void protect(scope void delegate() @safe nothrow @nogc del) @trusted {
    rwlock.pureWriteLock;
    del();
    rwlock.pureWriteUnlock;
}

void protectReadAction(scope void delegate() @safe nothrow @nogc del) @trusted {
    rwlock.pureReadLock;
    readingLock.pureLock;
    del();
    readingLock.unlock;
    rwlock.pureReadUnlock;
}

void protectWriteAction(scope void delegate() @safe nothrow @nogc del) @trusted {
    rwlock.pureReadLock;
    writingLock.pureLock;
    del();
    writingLock.unlock;
    rwlock.pureReadUnlock;
}

void initializeConsoleDefaultImpl() @trusted {
    import sidero.base.system : EnvironmentVariables;

    String_ASCII config = EnvironmentVariables[String_ASCII("SideroBase_Console")];

    version(Windows) {
        if(config == "Windows") {
            initializeForWindowsImpl;
            return;
        }
    }

    if(config.startsWith("stdio")) {
        initializeForStdioImpl(null, null, null, false, false);

        if(!config.endsWith("ansi"))
            useANSI = false;

        return;
    }

    version(Windows)
        initializeForWindowsImpl;
    else version(Posix)
        initializeForStdioImpl(null, null, null, false, false);
    else
        static assert(0, "Unimplemented");
}

void allocateWindowsConsole() @trusted {
    version(Windows) {
        if(!consoleSetup) {
            hStdin = GetStdHandle(STD_INPUT_HANDLE);
            hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
            hStdError = GetStdHandle(STD_ERROR_HANDLE);

            const stdinType = GetFileType(hStdin);
            const stdoutType = GetFileType(hStdout);
            const stderrType = GetFileType(hStdError);
            const allNull = hStdin is null && hStdout is null && hStdError is null;
            const allUnknown = stdinType == FILE_TYPE_UNKNOWN && stdoutType == FILE_TYPE_UNKNOWN && stderrType == FILE_TYPE_UNKNOWN;

            if((allNull || allUnknown) && AllocConsole()) {
                createdConsole = true;

                hStdin = GetStdHandle(STD_INPUT_HANDLE);
                hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
                hStdError = GetStdHandle(STD_ERROR_HANDLE);
            }

            hStdinPipeEvent = CreateEvent(null, false, false, null);

            const stdinType2 = GetFileType(hStdin);
            isStdinConsole = stdinType2 == FILE_TYPE_CHAR;
            isStdinPipe = stdinType2 == FILE_TYPE_PIPE;

            if(GetConsoleMode(hStdin, &originalConsoleInputMode)) {
                setStdinMode = true;
                SetConsoleMode(hStdin, originalConsoleInputMode & ~(ENABLE_LINE_INPUT));
            }

            if(GetConsoleMode(hStdout, &originalConsoleOutputMode)) {
                setStdoutMode = true;
                SetConsoleMode(hStdout, originalConsoleOutputMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING | ENABLE_PROCESSED_OUTPUT);
            }

            if(GetConsoleMode(hStdError, &originalConsoleErrorMode)) {
                setStderrMode = true;
                SetConsoleMode(hStdError, originalConsoleErrorMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING | ENABLE_PROCESSED_OUTPUT);
            }

            originalConsoleOutputCP = GetConsoleOutputCP();
            if(!SetConsoleOutputCP(65001))
                originalConsoleOutputCP = 0;

            originalConsoleCP = GetConsoleCP();
            if(!SetConsoleCP(65001))
                originalConsoleCP = 0;

            consoleSetup = true;
        }
    }
}

void initializeForWindowsImpl() @trusted {
    deinitializeConsoleImpl();

    version(Windows) {
        allocateWindowsConsole;

        if(consoleSetup) {
            useWindows = true;
        } else {
            initializeForStdioImpl(null, null, null, false, false);
        }
    }
}

void initializeForStdioImpl(FILE* useIn = null, FILE* useOut = null, FILE* useError = null, bool autoClose = false, bool keepState = false) @trusted {
    import sidero.base.system : EnvironmentVariables;

    if(useStdio)
        return;

    if(!keepState) {
        deinitializeConsoleImpl;
    }

    allocateWindowsConsole;
    useStdio = true;

    if(useIn !is null)
        stdioIn = useIn;
    else
        stdioIn = stdin;
    if(useOut !is null)
        stdioOut = useOut;
    else
        stdioOut = stdout;
    if(useError !is null)
        stdioError = useError;
    else
        stdioError = stderr;

    if(useIn !is null || useOut !is null)
        autoCloseStdio = autoClose;

    version(Posix) {
        import core.sys.posix.termios;

        if(useIn is null) {
            resetOriginalTermios = tcgetattr(stdioIn, &originalTermiosSettings) == 0;
        }
    }

    version(Windows) {
        useANSI = EnvironmentVariables[String_ASCII("ConEmuANSI")] == "ON";
    }
}

void deinitializeConsoleImpl() @trusted {
    if(useStdio && autoCloseStdio && (stdioIn !is null || stdioOut !is null || stdioError !is null) && (stdioIn !is stdin ||
            stdioOut !is stdout || stdioError !is stderr)) {
        if(stdioIn !is null) {
            fflush(stdioIn);
            if(stdioIn !is stdin)
                fclose(stdioIn);
        }

        if(stdioOut !is null) {
            fflush(stdioOut);
            if(stdioOut !is stdout)
                fclose(stdioOut);
        }

        if(stdioError !is null) {
            fflush(stdioError);
            if(stdioError !is stdout)
                fclose(stdioError);
        }

        useStdio = false;
    }

    if(consoleSetup) {
        version(Windows) {
            if(originalConsoleCP > 0)
                SetConsoleCP(originalConsoleCP);
            if(originalConsoleOutputCP > 0)
                SetConsoleOutputCP(originalConsoleOutputCP);

            if(setStdinMode)
                SetConsoleMode(hStdin, originalConsoleInputMode);
            if(setStdoutMode)
                SetConsoleMode(hStdout, originalConsoleOutputMode);
            if(setStderrMode)
                SetConsoleMode(hStdError, originalConsoleErrorMode);

            setStdinMode = false;
            setStdoutMode = false;
            setStderrMode = false;

            CloseHandle(hStdinPipeEvent);

            if(createdConsole) {
                FreeConsole();
                createdConsole = false;
            }
        } else version(Posix) {
            import core.sys.posix.termios;

            if(resetOriginalTermios) {
                tcsetattr(stdioIn, TCSAFLUSH, &originalTermiosSettings);
            }
        }

        consoleSetup = false;
    }

    useWindows = false;
    useANSI = false;
    autoCloseStdio = false;
}
