module sidero.base.console.internal.rawwrite;
import sidero.base.console.internal.mechanism;
import sidero.base.console.inbandinfo;
import sidero.base.text;

export @safe nothrow @nogc:

void rawWriteImpl(scope InBandInfo input, bool useError = false) @trusted {
    version(Windows) {
        import core.sys.windows.windows;

        if(useWindows) {
            HANDLE hOut = useError ? hStdError : hStdout;

            CONSOLE_SCREEN_BUFFER_INFO currentInfo;
            GetConsoleScreenBufferInfo(hOut, &currentInfo);

            WORD attributes;

            final switch(input.foregroundColor) {
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

                if(input.resetDefaults)
                    attributes |= FRGB;
                else
                    attributes |= currentInfo.wAttributes & FRGB;
                break;
            }

            final switch(input.backgroundColor) {
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
                if(!input.resetDefaults)
                    attributes |= currentInfo.wAttributes & BRGB;
                break;
            }

            SetConsoleTextAttribute(hOut, attributes);
            return;
        }
    }

    if(useANSI) {
        if(input.resetDefaults)
            rawWriteImpl(String_UTF8(ANSI_Reset), useError);

        string fg, bg;

        final switch(input.foregroundColor) {
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

        final switch(input.backgroundColor) {
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

        if(fg !is null)
            rawWriteImpl(String_UTF8(fg), useError);
        if(bg !is null)
            rawWriteImpl(String_UTF8(bg), useError);
    }
}

void rawWriteImpl(scope String_ASCII input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    if(!input.isPtrNullTerminated())
        input = input.dup;
    input.stripZeroTerminator;

    uint useLength = cast(uint)input.length;
    if(input.length == 0)
        return;

    version(Windows) {
        if(useWindows) {
            import core.sys.windows.windows : WriteConsoleA;

            if(WriteConsoleA(useError ? hStdError : hStdout, cast(void*)input.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if(useStdio) {
        fwrite(input.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}

void rawWriteImpl(scope StringBuilder_ASCII input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    String_ASCII inputA = input.asReadOnly();
    inputA.stripZeroTerminator;

    uint useLength = cast(uint)inputA.length;
    if(inputA.length == 0)
        return;

    version(Windows) {
        if(useWindows) {
            import core.sys.windows.windows : WriteConsoleA;

            if(WriteConsoleA(useError ? hStdError : hStdout, cast(void*)inputA.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if(useStdio) {
        fwrite(inputA.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}

void rawWriteImpl(scope String_UTF8 input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    uint useLength;

    version(Windows) {
        if(useWindows) {
            import core.sys.windows.windows : WriteConsoleW;

            String_UTF16 input16 = input.byUTF16();

            {
                if(!input16.isPtrNullTerminated() || input16.isEncodingChanged)
                    input16 = input16.dup;

                input16.stripZeroTerminator;

                useLength = cast(uint)input16.length;
                if(input16.length == 0)
                    return;
            }

            if(WriteConsoleW(useError ? hStdError : hStdout, cast(void*)input16.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if(useStdio) {
        {
            if(!input.isPtrNullTerminated() || input.isEncodingChanged)
                input = input.dup;

            input.stripZeroTerminator;

            useLength = cast(uint)input.length;
            if(input.length == 0)
                return;
        }

        assert(input.length > 0);
        assert(input.ptr !is null);

        fwrite(input.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}

void rawWriteImpl(scope StringBuilder_UTF8 input, bool useError = false) @trusted {
    import core.stdc.stdio : fwrite, fflush;

    uint useLength;

    version(Windows) {
        if(useWindows) {
            import core.sys.windows.windows : WriteConsoleW;

            String_UTF16 input16 = input.byUTF16().asReadOnly();

            {
                input16.stripZeroTerminator;

                useLength = cast(uint)input16.length;
                if(input16.length == 0)
                    return;
            }

            if(WriteConsoleW(useError ? hStdError : hStdout, cast(void*)input16.ptr, useLength, null, null))
                return;

            initializeForStdioImpl(null, null, null, false, true);
        }
    }

    if(useStdio) {
        String_UTF8 input8 = input.asReadOnly();

        {
            input8.stripZeroTerminator;

            useLength = cast(uint)input8.length;
            if(input8.length == 0)
                return;
        }

        fwrite(input8.ptr, char.sizeof, useLength, useError ? stdioError : stdioOut);
        fflush(useError ? stdioError : stdioOut);
    }
}
