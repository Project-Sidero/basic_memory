module sidero.base.path.file;
import sidero.base.errors;
import sidero.base.allocators;
import sidero.base.attributes;
import sidero.base.text;
import sidero.base.containers.dynamicarray;
import sidero.base.typecons : Optional;

export @safe nothrow @nogc:

version (Posix) {
    ///
    enum PathSeparator = '/';
    ///
    enum DefaultPlatfromRule = FilePathPlatform.Posix;
} else version (Windows) {
    ///
    enum PathSeparator = '\\';
    ///
    enum DefaultPlatfromRule = FilePathPlatform.Windows;
} else
    static assert(0, "Unimplemented");

/+
https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file
https://learn.microsoft.com/en-us/dotnet/standard/io/file-path-formats

Directory + file names must not end in . or space

Relative does not start with:
- \\
- D:\
- \
C:\Documents\Newsletters\Summer2018.pdf
C:\Projects\apilibrary\apilibrary.sln

Relative to drive (take directory components from cwd)
- D:appendComponents
C:Projects\apilibrary\apilibrary.sln

Relative to current drive (take drive from cwd)
- \path
\Program Files\Custom Utilities\StringFinder.exe

Relative paths (based upon cwd)
..\Publications\TravelBrochure.pdf
2018\January.xlsx

Only prepend \\?\ for absolute paths

Device path:
- \\.\Device\path
- \\?\Device\path

UNC paths
- \\server
- \\server\share
- \\server\share\path
\\system07\C$\
\\Server2\Share\Test\Foo.txt
+/

///
struct FilePath {
    private {
        FilePathState* state;
    }

export @safe nothrow @nogc:

    ///
    this(scope ref FilePath other) scope @trusted {
        import core.atomic : atomicOp;

        this.state = other.state;

        if (this.state !is null)
            atomicOp!"+="(this.state.refCount, 1);
    }

    ///
    ~this() scope @trusted {
        import core.atomic : atomicOp;

        if (this.state !is null && atomicOp!"-="(this.state.refCount, 1) == 0) {
            RCAllocator allocator = state.allocator;
            allocator.dispose(state);
        }
    }

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    FilePath dup(return scope RCAllocator allocator = RCAllocator.init) scope {
        if (isNull)
            return FilePath.init;

        if (allocator.isNull)
            allocator = globalAllocator();

        FilePath ret;
        ret.state = allocator.make!FilePathState;

        *ret.state = *this.state;
        ret.state.allocator = allocator;
        return ret;
    }

    ///
    Result!FilePathPlatform activePlatformRule() scope const {
        if (isNull)
            return typeof(return)(NullPointerException);
        return typeof(return)(state.platformRule);
    }

    ///
    Result!string platformSeparator() scope const {
        if (isNull)
            return typeof(return)(NullPointerException);

        final switch (state.platformRule) {
        case FilePathPlatform.Windows:
            return typeof(return)("\\");
        case FilePathPlatform.Posix:
            return typeof(return)("/");
        }
    }

    ///
    String_UTF8 hostname(RCAllocator allocator = RCAllocator.init) {
        if (isNull || state.lengthOfHost == 0)
            return String_UTF8.init;

        auto part = state.storage[state.lengthOfLeading .. state.lengthOfLeading + state.lengthOfHost];

        final switch (state.platformRule) {
        case FilePathPlatform.Windows:
            if (part.endsWith("\\"))
                part = part[0 .. $ - 1];
            break;
        case FilePathPlatform.Posix:
            if (part.endsWith("/"))
                part = part[0 .. $ - 1];
            break;
        }

        return part.asReadOnly(allocator);
    }

    ///
    @trusted unittest {
        assert(FilePath.from("path", FilePathPlatform.Windows).assumeOkay.hostname.isNull);
        assert(FilePath.from("\\\\myhostname", FilePathPlatform.Windows).assumeOkay.hostname == "myhostname");
        assert(FilePath.from("\\\\myhostname\\share", FilePathPlatform.Windows).assumeOkay.hostname == "myhostname");
        assert(FilePath.from("\\\\myhostname\\share\\path", FilePathPlatform.Windows).assumeOkay.hostname == "myhostname");
    }

    ///
    String_UTF8 share(RCAllocator allocator = RCAllocator.init) {
        if (isNull || state.lengthOfShare == 0)
            return String_UTF8.init;

        auto part = state
            .storage[state.lengthOfLeading + state.lengthOfHost .. state.lengthOfLeading + state.lengthOfHost + state.lengthOfShare];

        final switch (state.platformRule) {
        case FilePathPlatform.Windows:
            if (part.endsWith("\\"))
                part = part[0 .. $ - 1];
            break;
        case FilePathPlatform.Posix:
            if (part.endsWith("/"))
                part = part[0 .. $ - 1];
            break;
        }

        return part.asReadOnly(allocator);
    }

    ///
    @trusted unittest {
        assert(FilePath.from("path", FilePathPlatform.Windows).assumeOkay.share.isNull);
        assert(FilePath.from("\\\\myhostname", FilePathPlatform.Windows).assumeOkay.share.isNull);
        assert(FilePath.from("\\\\myhostname\\share", FilePathPlatform.Windows).assumeOkay.share == "share");
        assert(FilePath.from("\\\\myhostname\\share\\path", FilePathPlatform.Windows).assumeOkay.share == "share");
    }

    ///
    Optional!char drive() {
        if (isNull || state.lengthOfWindowsDrive == 0)
            return Optional!char.init;

        auto part = state.storage[state.lengthOfLeading .. state.lengthOfLeading + state.lengthOfWindowsDrive];
        return Optional!char(part.front);
    }

    ///
    @trusted unittest {
        assert(FilePath.from("path", FilePathPlatform.Windows).assumeOkay.drive.isNull);
        assert(FilePath.from("\\\\myhostname", FilePathPlatform.Windows).assumeOkay.drive.isNull);
        assert(FilePath.from("\\\\.\\Q:", FilePathPlatform.Windows).assumeOkay.drive == 'Q');
        assert(FilePath.from("\\\\.\\Q:\\path", FilePathPlatform.Windows).assumeOkay.drive == 'Q');
        assert(FilePath.from("\\\\?\\Q:", FilePathPlatform.Windows).assumeOkay.drive == 'Q');
        assert(FilePath.from("\\\\?\\Q:\\path", FilePathPlatform.Windows).assumeOkay.drive == 'Q');
        assert(FilePath.from("Q:path", FilePathPlatform.Windows).assumeOkay.drive == 'Q');
    }

    ///
    DynamicArray!String_UTF8 components(RCAllocator allocator = RCAllocator.init) {
        if (isNull)
            return DynamicArray!String_UTF8.init;

        const offset = state.offsetOfComponents();
        const lengthOfComponents = state.storage.length - offset;
        String_UTF8 parts = state.storage[offset .. offset + lengthOfComponents].asReadOnly(allocator);

        auto sep = this.platformSeparator();
        assert(sep);

        DynamicArray!String_UTF8 ret = DynamicArray!String_UTF8(0, allocator);
        ret.reserve(parts.count(sep) + 1);

        while (parts.length > 0) {
            ptrdiff_t index = parts.indexOf(sep);

            if (index < 0) {
                ret ~= parts;
                parts = String_UTF8.init;
            } else {
                ret ~= parts[0 .. index];
                parts = parts[index + 1 .. $];
            }
        }

        return ret;
    }

    ///
    @trusted unittest {
        assert(FilePath.from("D:\\path\\goes\\here", FilePathPlatform.Windows)
                .assumeOkay.components == [String_UTF8("path"), String_UTF8("goes"), String_UTF8("here")]);
        assert(FilePath.from("\\\\hostname\\share\\path\\goes\\here", FilePathPlatform.Windows)
                .assumeOkay.components == [String_UTF8("path"), String_UTF8("goes"), String_UTF8("here")]);

        assert(FilePath.from("~/path/goes/here", FilePathPlatform.Posix).assumeOkay.components == [
            String_UTF8("path"), String_UTF8("goes"), String_UTF8("here")
        ]);
        assert(FilePath.from("/path/goes/here", FilePathPlatform.Posix).assumeOkay.components == [
            String_UTF8("path"), String_UTF8("goes"), String_UTF8("here")
        ]);
        assert(FilePath.from("path/goes/here", FilePathPlatform.Posix).assumeOkay.components == [
            String_UTF8("path"), String_UTF8("goes"), String_UTF8("here")
        ]);
    }

    ///
    bool opEquals(scope String_UTF8.LiteralType other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope String_UTF16.LiteralType other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope String_UTF32.LiteralType other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope String_ASCII other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope StringBuilder_ASCII other) scope const {
        return this.toString().equals(other);
    }

    ///
    bool opEquals(scope String_UTF8 other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope String_UTF16 other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope String_UTF32 other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope StringBuilder_UTF8 other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope StringBuilder_UTF16 other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope StringBuilder_UTF32 other) scope const {
        return this.toString() == other;
    }

    ///
    bool opEquals(scope FilePath other) scope const {
        return this.toString() == other.toString();
    }

    ///
    String_UTF8 toString(return scope RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull)
            return String_UTF8.init;

        FilePathState* state = cast(FilePathState*)this.state;
        return state.storage.asReadOnly(allocator);
    }

    static {
        /// Consturct a file path given a platform rule set (default is host platform)
        Result!FilePath from(scope String_ASCII input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope StringBuilder_ASCII input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope String_UTF8.LiteralType input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return FilePath.from(String_UTF32(input), platformRule, allocator);
        }

        /// Ditto
        Result!FilePath from(scope String_UTF16.LiteralType input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return FilePath.from(String_UTF32(input), platformRule, allocator);
        }

        /// Ditto
        Result!FilePath from(scope String_UTF32.LiteralType input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) @trusted {
            return FilePath.from(String_UTF32(input), platformRule, allocator);
        }

        /// Ditto
        Result!FilePath from(scope String_UTF8 input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input.byUTF32, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope String_UTF16 input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input.byUTF32, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope String_UTF32 input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope StringBuilder_UTF8 input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input.byUTF32, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope StringBuilder_UTF16 input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input.byUTF32, allocator, platformRule);
        }

        /// Ditto
        Result!FilePath from(scope StringBuilder_UTF32 input, FilePathPlatform platformRule = DefaultPlatfromRule,
                scope return RCAllocator allocator = RCAllocator.init) {
            return parseFilePathFromString(input, allocator, platformRule);
        }

        ///
        @trusted unittest {
            import sidero.base.console;

            //debugWriteln(FilePath.from("C:\\some/./path/", FilePathPlatform.Windows).assumeOkay.toString());
            assert(FilePath.from("some/path", FilePathPlatform.Windows).assumeOkay == "some\\path");
            assert(FilePath.from("some/path", FilePathPlatform.Posix).assumeOkay == "some/path");
            assert(FilePath.from("some\\path", FilePathPlatform.Posix).assumeOkay == "some\\path");

            assert(FilePath.from("some/path/", FilePathPlatform.Windows).assumeOkay == "some\\path");
            assert(FilePath.from("some/path/", FilePathPlatform.Posix).assumeOkay == "some/path");

            assert(FilePath.from("\\\\hostname", FilePathPlatform.Windows).assumeOkay == "\\\\hostname");
            assert(FilePath.from("\\\\hostname\\", FilePathPlatform.Windows).assumeOkay == "\\\\hostname");
            assert(FilePath.from("\\\\hostname\\share", FilePathPlatform.Windows).assumeOkay == "\\\\hostname\\share");
            assert(FilePath.from("\\\\hostname\\share", FilePathPlatform.Windows).assumeOkay == "\\\\hostname\\share");
            assert(FilePath.from("\\\\hostname\\share\\path", FilePathPlatform.Windows).assumeOkay == "\\\\hostname\\share\\path");

            assert(FilePath.from("~/path/", FilePathPlatform.Windows).assumeOkay == "%USERPROFILE%\\path");
            assert(FilePath.from("~/path/", FilePathPlatform.Posix).assumeOkay == "~/path");

            assert(FilePath.from("COM5", FilePathPlatform.Windows).assumeOkay == "\\\\.\\COM5");
            assert(FilePath.from("\\\\.\\COM5", FilePathPlatform.Windows).assumeOkay == "\\\\.\\COM5");

            assert(FilePath.from("C:\\Windows", FilePathPlatform.Windows).assumeOkay == "\\\\?\\C:\\Windows");

            assert(FilePath.from("some/./path/", FilePathPlatform.Windows).assumeOkay == "some\\path");
            assert(FilePath.from("some/./path/", FilePathPlatform.Posix).assumeOkay == "some/path");
            assert(FilePath.from("C:\\some/./path/", FilePathPlatform.Windows).assumeOkay == "\\\\?\\C:\\some\\path");
            assert(FilePath.from("/some/./path/", FilePathPlatform.Posix).assumeOkay == "/some/path");
        }
    }
}

///
enum FilePathPlatform {
    ///
    Posix,
    ///
    Windows
}

///
enum FilePathRelativeTo {
    ///
    Nothing,
    ///
    Home,
    ///
    CurrentWorkingDirectory,
    ///
    CurrentDrive,
    ///
    PathOnAnotherDrive,
}

private @hidden:
import sidero.base.synchronization.mutualexclusion : TestTestSetLockInline;

static immutable LegacyWindowsDevices = [
    "CON", "PRN", "AUX", "NUL", "COM0", "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9", "LPT0",
    "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
];

// there are others not supported, like number ranges but its not worth solving
bool isValidWindowsComponentCharacter(dchar c) {
    switch (c) {
    case '<':
    case '>':
    case ':':
    case '"':
    case '/':
    case '\\':
    case '|':
    case '?':
    case '*':
    case '\0':
        return false;
    default:
        return true;
    }
}

bool isLegacyWindowsDevice(Input)(scope Input input) {
    foreach (lwd; LegacyWindowsDevices) {
        if (input == lwd)
            return true;
    }

    return false;
}

struct FilePathState {
    shared(ptrdiff_t) refCount = 1;
    RCAllocator allocator;
    TestTestSetLockInline mutex;

    FilePathPlatform platformRule;
    StringBuilder_UTF8 storage;

    FilePathRelativeTo relativeTo;

    size_t lengthOfLeading;
    size_t lengthOfWindowsDrive;
    size_t lengthOfHost;
    size_t lengthOfShare;

@safe nothrow @nogc:

    void opAssign(ref FilePathState other) scope {
        static foreach (i; 3 .. this.tupleof.length) {
            this.tupleof[i] = other.tupleof[i];
        }
    }

    size_t offsetOfComponents() scope {
        return lengthOfLeading + lengthOfWindowsDrive + lengthOfHost + lengthOfShare;
    }
}

Result!FilePath parseFilePathFromString(Input)(scope Input input, scope return RCAllocator allocator, FilePathPlatform platformRule) @trusted {
    import sidero.base.text.ascii.characters : isAlpha;

    if (allocator.isNull)
        allocator = globalAllocator();

    static if (__traits(hasMember, Input, "stripZeroTerminator")) {
        input.stripZeroTerminator;
    }

    if (input.length == 0)
        return typeof(return).init;

    FilePath ret;
    ret.state = allocator.make!FilePathState;
    ret.state.allocator = allocator;
    ret.state.platformRule = platformRule;
    ret.state.storage = StringBuilder_UTF8(allocator);

    final switch (platformRule) {
    case FilePathPlatform.Windows:
        ret.state.storage ~= input;
        ret.state.storage.replace("/", "\\");

        {
            // 1. identify path

            // - is device path, begins with \\? or \\.
            const noProcessDevicePath = input.startsWith("\\\\?");
            const isAbsoluteDevicePath = !noProcessDevicePath && input.startsWith("\\\\.");
            const isDevicePath = noProcessDevicePath || isAbsoluteDevicePath;

            Input deviceLessInput = input;

            if (isDevicePath) {
                if (input.startsWith("\\\\?\\") || input.startsWith("\\\\.\\")) {
                    deviceLessInput = input[4 .. $];
                } else if (input.length > 3) {
                    return typeof(return)(MalformedInputException(
                            "Error Windows device path must have separator after the leading device specifier"));
                }
            }

            // - is UNC \\
            const isUNCPath = !isDevicePath && !noProcessDevicePath && !isAbsoluteDevicePath && input.startsWith("\\\\");

            // - is fully qualified DOS path, L:\
            const isSecondColon = !isUNCPath && deviceLessInput[1 .. $].startsWith(":");
            const firstChar = deviceLessInput.front;
            const haveDOSDrive = !isUNCPath && firstChar < ubyte.max && isAlpha(cast(ubyte)firstChar) && isSecondColon;
            const isDOSPath = haveDOSDrive && deviceLessInput[2 .. $].startsWith("\\");

            // - is legacy device isLegacyWindowsDevice
            const isLegacyDevice = !isUNCPath && !isDOSPath && isLegacyWindowsDevice(deviceLessInput);

            // - relative to root of current drive, \
            const isRelativeToCurrentDrive = !isDevicePath && !isUNCPath && !isDOSPath && !isLegacyDevice && input.startsWith("\\");

            // - relative to the current directory on another drive, D:path
            const isRelativeToPathOnAnotherDrive = !isDevicePath && !isUNCPath && !isDOSPath && !isLegacyDevice &&
                haveDOSDrive && !isDOSPath;

            // - relative to home directory, ~
            const isRelativeToHome = input.startsWith("~");
            const isRelativeToHomeEnv = input.startsWith("%USERPROFILE%");

            // - otherwise they are relative to cwd

            if (isRelativeToCurrentDrive)
                ret.state.relativeTo = FilePathRelativeTo.CurrentDrive;
            else if (isRelativeToPathOnAnotherDrive)
                ret.state.relativeTo = FilePathRelativeTo.PathOnAnotherDrive;
            else if (isRelativeToHome || isRelativeToHomeEnv)
                ret.state.relativeTo = FilePathRelativeTo.Home;
            else if (isDOSPath || isDevicePath)
                ret.state.relativeTo = FilePathRelativeTo.Nothing;
            else if (isLegacyDevice) {
                ret.state.storage.prepend("\\\\.\\");
                ret.state.relativeTo = FilePathRelativeTo.Nothing;
            } else
                ret.state.relativeTo = FilePathRelativeTo.CurrentWorkingDirectory;

            if ((isDevicePath && input.length > 3) || isLegacyDevice)
                ret.state.lengthOfLeading = 4;
            else if (isDevicePath)
                ret.state.lengthOfLeading = 3;
            else if (isUNCPath || (isRelativeToHome && input.startsWith("~\\")))
                ret.state.lengthOfLeading = 2;
            else if (isRelativeToHome) {
                ret.state.storage.remove(0, 1);
                ret.state.storage.prepend("%USERPROFILE%");
                ret.state.lengthOfLeading = 13;
            } else if (isRelativeToHomeEnv)
                ret.state.lengthOfLeading = 13;

            // Turn multiple back slahes into one
            ret.state.storage[ret.state.lengthOfLeading .. $].replace("\\\\", "\\");

            if (isDOSPath)
                ret.state.lengthOfWindowsDrive = 3;
            else if (haveDOSDrive)
                ret.state.lengthOfWindowsDrive = 2;

            if (isUNCPath) {
                // for UNC paths we are in particularly interested in length of the host/ip
                // but we also want to know about the share

                // \\host\share\path
                auto storage = ret.state.storage[2 .. $];
                ptrdiff_t index = storage.indexOf("\\");

                if (index > 0) {
                    ret.state.lengthOfHost = index + 1;
                } else if (index < 0) {
                    ret.state.lengthOfHost = storage.length;
                } else if (index == 0)
                    return typeof(return)(MalformedInputException("Expected UNC host, got separator instead"));

                if (index >= 0) {
                    storage = storage[index + 1 .. $];
                    index = storage.indexOf("\\");

                    if (index > 0) {
                        ret.state.lengthOfShare = index + 1;
                    } else if (index < 0) {
                        ret.state.lengthOfShare = storage.length;
                    } else if (index == 0)
                        return typeof(return)(MalformedInputException("Expected UNC share, got separator instead"));
                }
            } else if (isDOSPath && !isDevicePath) {
                ret.state.lengthOfLeading += 4;
                ret.state.storage.prepend("\\\\?\\");
            }

            {
                StringBuilder_UTF8 components = ret.state.storage[ret.state.offsetOfComponents() .. $];

                while (components.length > 0) {
                    StringBuilder_UTF8 component;
                    const indexOfSeparator = components.indexOf("\\");

                    if (indexOfSeparator < 0) {
                        component = components;
                        components = StringBuilder_UTF8.init;
                    } else {
                        component = components[0 .. indexOfSeparator];
                        components = components[indexOfSeparator + 1 .. $];
                    }

                    if (component == "..") {
                        // not legal if this is an absolute path
                        if (ret.state.relativeTo == FilePathRelativeTo.Nothing)
                            return typeof(return)(MalformedInputException("Found relative parent component in an absolute path"));
                    } else if (components.isNull) {
                        ptrdiff_t amountToRemove;

                        foreach_reverse (c; component) {
                            if (c == ' ' || c == '.')
                                amountToRemove++;
                            else
                                break;
                        }

                        if (amountToRemove > 0)
                            component.remove(-amountToRemove, amountToRemove);
                    } else {
                        if (component.endsWith("."))
                            component.remove(-1, 1);
                    }
                }
            }

            // Turn multiple back slahes into one
            ret.state.storage[ret.state.lengthOfLeading .. $].replace("\\\\", "\\");

            // remove a trailing slash
            if (ret.state.storage[ret.state.lengthOfLeading .. $].endsWith("\\")) {
                ret.state.storage.remove(-1, 1);
            }
        }

        // 2. if path is relative apply cwd

        // 3. replace all / with \

        // 4. In the component section (after root), if there is multiple \\, replace with single \

        // 5. evaluate relative components
        // - . components are removed
        // - .. current and parent component are removed but do not remove root parts
        //  - for drives, the drive
        //  - for UNC it is \\host\share
        //  - for device paths it is \\?\ or \\.\

        // 6. If a component ends in a single . trim

        // 7. If a component does not have another component follow it (including at end have separator), remove all spaces and .
        return typeof(return)(ret);
    case FilePathPlatform.Posix:
        if (input.contains(String_ASCII("\0\0"))) {
            // pretty much the ONLY THING THAT IS INVALID!
            return typeof(return)(MalformedInputException("Posix path strings cannot contain null terminators"));
        }

        if (input.startsWith("~")) {
            ret.state.relativeTo = FilePathRelativeTo.Home;
            ret.state.lengthOfLeading = input.startsWith("~/") ? 2 : 1;
        } else if (!input.startsWith("/"))
            ret.state.relativeTo = FilePathRelativeTo.CurrentWorkingDirectory;
        else {
            ret.state.lengthOfLeading = input.length > 0;
            ret.state.relativeTo = FilePathRelativeTo.Nothing;
        }

        ret.state.storage ~= input;

        {
            {
                StringBuilder_UTF8 components = ret.state.storage[ret.state.offsetOfComponents() .. $];

                while (components.length > 0) {
                    StringBuilder_UTF8 component;
                    const indexOfSeparator = components.indexOf("/");

                    if (indexOfSeparator < 0) {
                        component = components;
                        components = StringBuilder_UTF8.init;
                    } else {
                        component = components[0 .. indexOfSeparator];
                        components = components[indexOfSeparator + 1 .. $];
                    }

                    if (component == "..") {
                        if (ret.state.relativeTo == FilePathRelativeTo.Nothing) {
                            // not legal if this is an absolute path
                            return typeof(return)(MalformedInputException("Found relative parent component in an absolute path"));
                        }
                    } else if (component == ".") {
                        component.remove(-1, 1);
                    }
                }
            }
        }

        // Turn multiple back slahes into one
        ret.state.storage[ret.state.lengthOfLeading .. $].replace("//", "/");

        // remove a trailing slash
        if (ret.state.storage[ret.state.lengthOfLeading .. $].endsWith("/")) {
            ret.state.storage.remove(-1, 1);
        }
        return typeof(return)(ret);
    }
}
