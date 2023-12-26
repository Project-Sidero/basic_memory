module sidero.base.console.internal.bindings;
public import core.stdc.stdio : getc, EOF, FILE, fflush, fclose;

version(Windows) {
    public import core.sys.windows.windows : HANDLE, ULONG, WORD, BOOL, UINT, CHAR, COORD, WaitForSingleObject,
        PeekNamedPipe, ReadFile, WCHAR, DWORD, OVERLAPPED, GetStdHandle, GetFileType, FILE_TYPE_UNKNOWN, FILE_TYPE_CHAR,
        FILE_TYPE_PIPE, AllocConsole, CreateEvent, CloseHandle, GetConsoleMode, SetConsoleMode, STD_INPUT_HANDLE,
        STD_OUTPUT_HANDLE, STD_ERROR_HANDLE, ENABLE_LINE_INPUT,
        ENABLE_VIRTUAL_TERMINAL_PROCESSING,
        ENABLE_PROCESSED_OUTPUT, GetConsoleOutputCP, SetConsoleOutputCP, GetConsoleCP, SetConsoleCP, FreeConsole,
        INVALID_HANDLE_VALUE, ReadConsoleA,
        ENABLE_ECHO_INPUT, WaitForMultipleObjects,
        WAIT_OBJECT_0, KEY_EVENT, WriteConsoleA, WAIT_TIMEOUT, ReadConsoleW, INFINITE, WriteConsoleW, HANDLE_FLAG_INHERIT;

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

    extern (Windows) BOOL PeekConsoleInputA(HANDLE, INPUT_RECORD*, DWORD, DWORD*) nothrow @nogc;
    extern (Windows) BOOL PeekConsoleInputW(HANDLE, INPUT_RECORD*, DWORD, DWORD*) nothrow @nogc;
    extern (Windows) BOOL ReadConsoleInputA(HANDLE, INPUT_RECORD*, DWORD, DWORD*) nothrow @nogc;
    extern (Windows) BOOL ReadConsoleInputW(HANDLE, INPUT_RECORD*, DWORD, DWORD*) nothrow @nogc;
    extern (Windows) BOOL GetOverlappedResultEx(HANDLE, OVERLAPPED*, DWORD*, DWORD, BOOL) nothrow @nogc;
    extern (Windows) BOOL SetHandleInformation(HANDLE, DWORD, DWORD) nothrow @nogc;
}
