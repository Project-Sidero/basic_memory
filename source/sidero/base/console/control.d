module sidero.base.console.control;
import sidero.base.console.internal.mechanism;
import core.stdc.stdio : FILE;

export @safe nothrow @nogc:

/// Initializes defaults automatically, has the environment variable SideroBase_Console to set either Windows, stdio, or stdio_ansi backend.
pragma(crt_constructor) extern (C) void initializeConsoleDefault() {
    protect(() { initializeConsoleDefaultImpl; });
}

private pragma(crt_destructor) extern (C) void deinitializeConsoleAutomatically() {
    // not user callable, however if we tried locking here, bad things happen
    deinitializeConsoleImpl();
}

version (Windows) {
    ///
    void initializeForWindows() {
        protect(() { initializeForWindowsImpl; });
    }
}

///
void initializeForStdio(FILE* useIn = null, FILE* useOut = null, FILE* useError = null, bool autoClose = false) {
    protect(() { initializeForStdioImpl(useIn, useOut, useError, autoClose); });
}

///
void enableANSI(bool value = true) {
    protect(() @trusted { useANSI = value; });
}

/// Enter raw mode, suitable for TUI. Note disables Ctrl+C signal.
bool enableRawMode() {
    bool ret;

    protect(() @trusted {
        // no echo
        // turn off canonical mode so reading byte by byte
        // turn off signals ctrl+c, ctrl+z, ctrl+s, ctrl+q, ctrl+v, ctrl+m
        // turn off output processing of \n to \r\n
        // clean up UTF-8 handling stuff

        version (Windows) {
            import core.sys.windows.windows;

            if (consoleSetup) {
                if (hStdin != INVALID_HANDLE_VALUE && hStdout != INVALID_HANDLE_VALUE) {
                    DWORD inputMode = originalConsoleInputMode, outputMode = originalConsoleOutputMode;
                    inputMode &= ~(ENABLE_LINE_INPUT | ENABLE_PROCESSED_INPUT | ENABLE_ECHO_INPUT);
                    outputMode &= ~(
                        ENABLE_PROCESSED_OUTPUT | ENABLE_WRAP_AT_EOL_OUTPUT | DISABLE_NEWLINE_AUTO_RETURN | ENABLE_LVB_GRID_WORLDWIDE);
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
                import core.sys.posix.stdio : fileno;

                const fnum = fileno(stdioIn);

                termios settings;
                tcgetattr(fnum, &settings);

                // ISTRIP is 8th bit stripped so turns it off, for UTF-8 support
                settings.c_iflag &= ~(BRKINT | ICRNL | ISTRIP | IXON);
                settings.c_oflag &= ~(OPOST);
                settings.c_cflag |= (CS8); // 8bits, UTF-8
                settings.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);

                ret = tcsetattr(fnum, TCSAFLUSH, &settings) == 0;
            }
        }
    });

    return ret;
}

///
void deinitializeConsole() {
    protect(() { deinitializeConsoleImpl(); });
}
