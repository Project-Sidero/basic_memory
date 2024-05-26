module sidero.base.console.read;
import sidero.base.console.internal.mechanism;
import sidero.base.console.internal.bindings;
import sidero.base.datetime.duration;
import sidero.base.text;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.attributes;

export @safe nothrow @nogc:

/// Read's a single character, default is blocking.
Result!dchar readChar(Duration timeout = Duration.min) @trusted {
    import sidero.base.encoding.utf;

    const block = timeout < Duration.zero;

    size_t outputBufferCount;
    char[4] outputBuffer = void;
    Result!dchar ret;

    protectReadAction(() @trusted {
        FILE* cstdioIn = stdioIn;

        version(Windows) {
            if(useWindows) {
                ret = handleWindowsReadChar(timeout);
                return;
            }
        } else version(Posix) {
            import core.sys.posix.stdio : fileno;

            const fnum = fileno(cstdioIn);
        }

        if(useStdio && cstdioIn !is null) {
            version(Posix) {
                import core.sys.posix.termios;

                termios originalTermios;

                if(!block) {
                    tcgetattr(fnum, &originalTermios);

                    termios toSetTermios = originalTermios;
                    toSetTermios.c_cc[VMIN] = 0;
                    toSetTermios.c_cc[VTIME] = cast(ubyte)(timeout.totalMilliSeconds / 100);

                    if(toSetTermios.c_cc[VTIME] == 0)
                        toSetTermios.c_cc[VTIME] = 10;

                    tcsetattr(fnum, TCSANOW, &toSetTermios);
                }
            }

            for(;;) {
                const got = getc(cstdioIn);

                if(got == EOF)
                    break;

                outputBuffer[outputBufferCount++] = cast(char)got;

                if(decodeLength(outputBuffer[0]) == outputBufferCount || outputBufferCount == 4)
                    break;
            }

            version(Posix) {
                if(!block)
                    tcsetattr(fnum, TCSANOW, &originalTermios);
            }

            if(outputBufferCount > 0) {
                dchar output;
                decode(outputBuffer[0 .. outputBufferCount], output);
                ret = typeof(ret)(output);
                return;
            } else {
                ret = typeof(ret)(MalformedInputException("No input to read"));
                return;
            }
        }
    });

    return ret;
}

/// Includes new line terminator, default is blocking.
Result!StringBuilder_ASCII readLine(return scope ref StringBuilder_ASCII builder, Duration timeout = Duration.min) @trusted {
    if(builder.isNull)
        builder = StringBuilder_ASCII(globalAllocator());
    const block = timeout < Duration.zero;

    typeof(return) ret;

    protectReadAction(() @trusted {
        FILE* cstdioIn = stdioIn;

        version(Windows) {
            if(useWindows) {
                ret = handleWindowsReadLine(builder, timeout);
                return;
            }
        } else version(Posix) {
            import core.sys.posix.stdio : fileno;

            const fnum = fileno(cstdioIn);
        }

        if(useStdio && cstdioIn !is null) {
            version(Posix) {
                import core.sys.posix.termios;

                termios originalTermios;

                if(!block) {
                    tcgetattr(fnum, &originalTermios);

                    termios toSetTermios = originalTermios;
                    toSetTermios.c_cc[VMIN] = 0;
                    toSetTermios.c_cc[VTIME] = cast(ubyte)(timeout.totalMilliSeconds / 100);

                    if(toSetTermios.c_cc[VTIME] == 0)
                        toSetTermios.c_cc[VTIME] = 10;

                    tcsetattr(fnum, TCSANOW, &toSetTermios);
                }
            }

            for(;;) {
                int got = getc(cstdioIn);

                if(got == EOF)
                    break;

                char[1] buffer = [cast(char)got];
                builder ~= buffer[];

                if(got == '\n')
                    break;
            }

            version(Posix) {
                if(!block)
                    tcsetattr(fnum, TCSANOW, &originalTermios);
            }

            ret = typeof(ret)(builder);
            return;
        }
    });

    return builder;
}

/// Includes new line terminator, default is blocking.
Result!StringBuilder_UTF8 readLine(Duration timeout = Duration.min) {
    StringBuilder_UTF8 ret;
    return readLine(ret, timeout);
}

/// Ditto
Result!StringBuilder_UTF8 readLine(return scope ref StringBuilder_UTF8 builder, Duration timeout = Duration.min) @trusted {
    import core.stdc.stdio : getc, EOF;

    if(builder.isNull)
        builder = StringBuilder_UTF8(globalAllocator());
    const block = timeout < Duration.zero;

    typeof(return) ret;

    protectReadAction(() @trusted {
        FILE* cstdioIn = stdioIn;

        version(Windows) {
            if(useWindows) {
                ret = handleWindowsReadLine(builder, timeout);
                return;
            }
        } else version(Posix) {
            import core.sys.posix.stdio : fileno;

            const fnum = fileno(cstdioIn);
        }

        if(useStdio && cstdioIn !is null) {
            version(Posix) {
                import core.sys.posix.termios;

                termios originalTermios;

                if(!block) {
                    tcgetattr(fnum, &originalTermios);

                    termios toSetTermios = originalTermios;
                    toSetTermios.c_cc[VMIN] = 0;
                    toSetTermios.c_cc[VTIME] = cast(ubyte)(timeout.totalMilliSeconds / 100);

                    if(toSetTermios.c_cc[VTIME] == 0)
                        toSetTermios.c_cc[VTIME] = 10;

                    tcsetattr(fnum, TCSANOW, &toSetTermios);
                }
            }

            for(;;) {
                int got = getc(cstdioIn);

                if(got == EOF)
                    break;

                char[1] buffer = [cast(char)got];
                builder ~= buffer[];

                if(got == '\n')
                    break;
            }

            version(Posix) {
                if(!block)
                    tcsetattr(fnum, TCSANOW, &originalTermios);
            }

            ret = typeof(ret)(builder);
            return;
        }
    });

    return ret;
}

/// Ditto
Result!StringBuilder_UTF16 readLine(return scope ref StringBuilder_UTF16 builder, Duration timeout = Duration.min) {
    if(builder.isNull)
        builder = StringBuilder_UTF16(globalAllocator());

    auto temp = builder.byUTF8();
    auto got = readLine(temp, timeout);
    if(got)
        return builder;
    else
        return typeof(return)(got.getError());
}

/// Ditto
Result!StringBuilder_UTF32 readLine(return scope ref StringBuilder_UTF32 builder, Duration timeout = Duration.min) {
    if(builder.isNull)
        builder = StringBuilder_UTF32(globalAllocator());

    auto temp = builder.byUTF8();
    auto got = readLine(temp, timeout);
    if(got)
        return builder;
    else
        return typeof(return)(got.getError());
}

private @hidden:

Result!dchar handleWindowsReadChar(Duration timeout) @trusted {
    version(Windows) {
        import sidero.base.encoding.utf;

        const block = timeout < Duration.zero;
        size_t outputBufferCount;
        char[4] outputBuffer = void;
        DWORD dwTimeout, readLength;
        HANDLE whStdin = hStdin;

        if(block) {
            dwTimeout = INFINITE;
        } else {
            dwTimeout = cast(DWORD)timeout.totalMilliSeconds;
        }

        if(isStdinConsole) {
            // ok use UTF-16 API's with console specific behavior

            wchar[2] outputBuffer16 = void;
            bool needEcho;

            {
                DWORD mode;
                GetConsoleMode(whStdin, &mode);
                if(setStdinMode && (mode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT) {
                    needEcho = true;
                }
            }

            ReadLoopConsole: for(;;) {
                DWORD result = WaitForMultipleObjects(1, &whStdin, false, dwTimeout);

                switch(result) {
                case WAIT_OBJECT_0:
                    if(ReadConsoleW(whStdin, &outputBuffer16[outputBufferCount], 1, &readLength, null)) {
                        outputBufferCount++;

                        if(decodeLength(outputBuffer16[0]) == outputBufferCount || outputBufferCount == 2) {
                            break ReadLoopConsole;
                        }
                    }
                    break;
                case WAIT_TIMEOUT:
                    return typeof(return)(TimeOutException);
                default:
                    break ReadLoopConsole;
                }
            }

            if(outputBufferCount > 0) {
                dchar output;
                decode(outputBuffer16[0 .. outputBufferCount], output);

                // on Windows the console API will use \r instead on \n for a new line.
                if(output == '\r')
                    output = '\n';

                return typeof(return)(output);
            } else {
                return typeof(return)(MalformedInputException("No input to read"));
            }
        } else if(isStdinPipe && !block) {
            // this is a pipe of some kind, we'll assume its UTF-8
            char[4] outputBuffer8;
            DWORD timeCounter;
            bool success;

            while(timeCounter < dwTimeout) {
            TryPipeAgain:
                if(PeekNamedPipe(whStdin, null, 0, null, &readLength, null) && readLength > 0) {
                    ReadFile(whStdin, &outputBuffer8[outputBufferCount], 1, &readLength, null);
                    outputBufferCount++;

                    if(decodeLength(outputBuffer8[0]) == outputBufferCount || outputBufferCount == 4) {
                        success = true;
                        break;
                    } else
                        goto TryPipeAgain;
                }

                WaitForSingleObject(hStdinPipeEvent, 20);
                timeCounter += 20;
            }

            if(timeCounter >= dwTimeout && !success)
                return typeof(return)(TimeOutException);

            if(outputBufferCount > 0) {
                dchar output;
                decode(outputBuffer8[0 .. outputBufferCount], output);
                return typeof(return)(output);
            } else {
                return typeof(return)(MalformedInputException("No input to read"));
            }
        } else {
            // some other kind of file type, use UTF-8 via ReadFile API
            char[4] outputBuffer8;

            // unfortunately for non-consoles like pipes we kinda just have to block :(
            for(;;) {
                if(ReadFile(whStdin, &outputBuffer8[outputBufferCount], 1, &readLength, null)) {
                    outputBufferCount++;

                    if(decodeLength(outputBuffer8[0]) == outputBufferCount || outputBufferCount == 4) {
                        break;
                    }
                }
            }

            if(outputBufferCount > 0) {
                dchar output;
                decode(outputBuffer8[0 .. outputBufferCount], output);
                return typeof(return)(output);
            } else {
                return typeof(return)(MalformedInputException("No input to read"));
            }
        }
    } else
        assert(0);
}

Result!StringBuilder_ASCII handleWindowsReadLine(scope ref StringBuilder_ASCII builder, Duration timeout) @trusted {
    version(Windows) {
        const block = timeout < Duration.zero;
        DWORD dwTimeout, oldMode, readLength;
        HANDLE whStdin = hStdin;

        if(block) {
            dwTimeout = INFINITE;
        } else {
            dwTimeout = cast(DWORD)timeout.totalMilliSeconds;
        }

        GetConsoleMode(whStdin, &oldMode);

        if(isStdinConsole) {
            INPUT_RECORD[128] buffer = void;
            const needEcho = (oldMode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT;

            ReadLoopConsole: for(;;) {
                const result = WaitForMultipleObjects(1, &whStdin, false, dwTimeout);

                switch(result) {
                case WAIT_OBJECT_0:
                    uint amountBeforeNewLine;

                    if(PeekConsoleInputA(whStdin, buffer.ptr, cast(uint)buffer.length, &readLength)) {
                        size_t count;
                        bool lastNewLine;

                        foreach(ref value; buffer[0 .. readLength]) {
                            if(value.EventType == KEY_EVENT && value.KeyEvent.bKeyDown == 1) {
                                amountBeforeNewLine++;

                                if(value.KeyEvent.dwControlKeyState != 0 && value.KeyEvent.AsciiChar == 0) {
                                    // do nothing, this is something like shift key
                                } else {
                                    char[1] temp = [value.KeyEvent.AsciiChar];
                                    builder ~= temp[];

                                    if(needEcho) {
                                        DWORD did;
                                        WriteConsoleA(hStdout, temp.ptr, 1, &did, null);
                                    }

                                    count++;

                                    if(value.KeyEvent.AsciiChar == '\r') {
                                        builder ~= "\n";

                                        if(needEcho) {
                                            DWORD did;
                                            WriteConsoleA(hStdout, "\n".ptr, 1, &did, null);
                                        }

                                        lastNewLine = true;
                                        break;
                                    }
                                }
                            }
                        }

                        ReadConsoleInputA(whStdin, buffer.ptr, amountBeforeNewLine, &readLength);
                        if(lastNewLine)
                            return typeof(return)(builder);
                    }
                    break;
                case WAIT_TIMEOUT:
                    return typeof(return)(TimeOutException);
                default:
                    return typeof(return)(MalformedInputException("No input to read"));
                }
            }

            assert(0);
        } else if(isStdinPipe && !block) {
            // this is a pipe of some kind
            char outputBuffer8;
            DWORD timeCounter;

            for(;;) {
                size_t outputBufferCount;
                bool success;

                while(timeCounter < dwTimeout) {
                    if(PeekNamedPipe(whStdin, null, 0, null, &readLength, null) && readLength > 0) {
                        ReadFile(whStdin, &outputBuffer8, 1, &readLength, null);
                        outputBufferCount++;
                    }

                    WaitForSingleObject(hStdinPipeEvent, 20);
                    timeCounter += 20;
                }

                if(timeCounter >= dwTimeout && !success)
                    return typeof(return)(TimeOutException);

                if(outputBufferCount > 0) {
                    builder ~= [outputBuffer8];

                    if(outputBuffer8 == '\n') {
                        return typeof(return)(builder);
                    }
                } else {
                    return typeof(return)(MalformedInputException("No input to read"));
                }
            }
            assert(0);
        } else {
            // some other kind of file type
            char outputBuffer8;

            for(;;) {
                // unfortunately for non-consoles like pipes we kinda just have to block :(
                if(ReadFile(whStdin, &outputBuffer8, 1, &readLength, null) == 0) {
                    continue;
                }

                builder ~= [outputBuffer8];

                if(outputBuffer8 == '\n') {
                    return typeof(return)(builder);
                }
            }

            assert(0);
        }
    } else
        assert(0);
}

Result!StringBuilder_UTF8 handleWindowsReadLine(scope ref StringBuilder_UTF8 builder, Duration timeout) @trusted {
    version(Windows) {
        import sidero.base.encoding.utf;

        const block = timeout < Duration.zero;
        DWORD dwTimeout, oldMode, readLength;
        HANDLE whStdin = hStdin;

        if(block) {
            dwTimeout = INFINITE;
        } else {
            dwTimeout = cast(DWORD)timeout.totalMilliSeconds;
        }

        GetConsoleMode(whStdin, &oldMode);

        if(isStdinConsole) {
            // ok use UTF-16 API's with console specific behavior
            INPUT_RECORD[128] buffer = void;
            const needEcho = (oldMode & ENABLE_ECHO_INPUT) == ENABLE_ECHO_INPUT;

            ReadLoopConsole: for(;;) {
                const result = WaitForMultipleObjects(1, &whStdin, false, dwTimeout);

                switch(result) {
                case WAIT_OBJECT_0:
                    uint amountBeforeNewLine;

                    if(PeekConsoleInputW(whStdin, buffer.ptr, cast(uint)buffer.length, &readLength)) {
                        size_t count;
                        bool lastNewLine;

                        foreach(ref value; buffer[0 .. readLength]) {
                            if(value.EventType == KEY_EVENT && value.KeyEvent.bKeyDown == 1) {
                                amountBeforeNewLine++;

                                if(value.KeyEvent.dwControlKeyState != 0 && value.KeyEvent.UnicodeChar == 0) {
                                    // do nothing, this is something like shift key
                                } else {
                                    wchar[1] temp = [value.KeyEvent.UnicodeChar];
                                    builder ~= temp[];

                                    if(needEcho) {
                                        DWORD did;
                                        WriteConsoleW(hStdout, temp.ptr, 1, &did, null);
                                    }

                                    count++;

                                    if(value.KeyEvent.UnicodeChar == '\r') {
                                        builder ~= "\n"w;

                                        if(needEcho) {
                                            DWORD did;
                                            WriteConsoleW(hStdout, "\n"w.ptr, 1, &did, null);
                                        }

                                        lastNewLine = true;
                                        break;
                                    }
                                }
                            }
                        }

                        ReadConsoleInputW(whStdin, buffer.ptr, amountBeforeNewLine, &readLength);
                        if(lastNewLine)
                            return typeof(return)(builder);
                    }
                    break;
                case WAIT_TIMEOUT:
                    return typeof(return)(TimeOutException);
                default:
                    return typeof(return)(MalformedInputException("No input to read"));
                }
            }

            assert(0);
        } else if(isStdinPipe && !block) {
            // this is a pipe of some kind, we'll assume its UTF-8
            char[4] outputBuffer8;
            DWORD timeCounter;

            for(;;) {
                size_t outputBufferCount;
                bool success;

                while(timeCounter < dwTimeout) {
                TryPipeAgain:
                    if(PeekNamedPipe(whStdin, null, 0, null, &readLength, null) && readLength > 0) {
                        ReadFile(whStdin, &outputBuffer8[outputBufferCount], 1, &readLength, null);
                        outputBufferCount++;

                        if(decodeLength(outputBuffer8[0]) == outputBufferCount || outputBufferCount == 4) {
                            success = true;
                            break;
                        } else
                            goto TryPipeAgain;
                    }

                    WaitForSingleObject(hStdinPipeEvent, 20);
                    timeCounter += 20;
                }

                if(timeCounter >= dwTimeout && !success)
                    return typeof(return)(TimeOutException);

                if(outputBufferCount > 0) {
                    dchar output;
                    decode(outputBuffer8[0 .. outputBufferCount], output);
                    builder ~= [output];

                    if(output == '\n') {
                        return typeof(return)(builder);
                    }
                } else {
                    return typeof(return)(MalformedInputException("No input to read"));
                }
            }
            assert(0);
        } else {
            // some other kind of file type, use UTF-8 via ReadFile API
            char[4] outputBuffer8;

            for(;;) {
                size_t outputBufferCount;

                // unfortunately for non-consoles like pipes we kinda just have to block :(
                for(;;) {
                    if(ReadFile(whStdin, &outputBuffer8[outputBufferCount], 1, &readLength, null)) {
                        outputBufferCount++;

                        if(decodeLength(outputBuffer8[0]) == outputBufferCount || outputBufferCount == 4) {
                            break;
                        }
                    }
                }

                if(outputBufferCount > 0) {
                    dchar output;
                    decode(outputBuffer8[0 .. outputBufferCount], output);
                    builder ~= [output];

                    if(output == '\n') {
                        return typeof(return)(builder);
                    }
                } else {
                    return typeof(return)(MalformedInputException("No input to read"));
                }
            }

            assert(0);
        }
    } else
        assert(0);
}
