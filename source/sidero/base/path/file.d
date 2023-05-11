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
    FilePath dup(return scope RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull)
            return FilePath.init;

        if (allocator.isNull)
            allocator = globalAllocator();

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        FilePath ret;
        ret.state = allocator.make!FilePathState;

        *ret.state = *state;
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
    bool isAbsolute() scope const {
        auto got = this.relativeTo;
        if (got.isNull)
            return false;
        return got == FilePathRelativeTo.Nothing;
    }

    ///
    Optional!FilePathRelativeTo relativeTo() scope const @trusted {
        if (isNull)
            return typeof(return).init;

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return typeof(return)(state.relativeTo);
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
    bool couldPointToEntry() scope const {
        if (isNull)
            return false;
        else
            return state.couldPointToEntry;
    }

    ///
    String_UTF8 hostname(RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull || state.lengthOfHost == 0)
            return String_UTF8.init;

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

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
    String_UTF8 share(RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull || state.lengthOfShare == 0)
            return String_UTF8.init;

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;
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
    Optional!char drive() scope const @trusted {
        if (isNull || state.lengthOfWindowsDrive == 0)
            return Optional!char.init;

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

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
    DynamicArray!String_UTF8 components(RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull)
            return DynamicArray!String_UTF8.init;

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

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
    ErrorResult makeAbsolute(scope FilePath cwd = FilePath.init, scope FilePath home = FilePath.init) scope {
        import sidero.base.system : homeDirectory, currentWorkingDirectory;

        if (isNull)
            return ErrorResult(NullPointerException);

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        final switch (state.platformRule) {
        case FilePathPlatform.Windows:
            final switch (state.relativeTo) {
            case FilePathRelativeTo.Nothing:
                // ok already done!
                break;
            case FilePathRelativeTo.Home:
                // just need home
                if (home.isNull)
                    home = homeDirectory();
                if (home.isNull || !home.isAbsolute || !home.state.couldPointToEntry)
                    return ErrorResult(UnknownPlatformBehaviorException(
                            "Could not get an absolute home directory, so path could not be made absolute"));
                else if (home.state is this.state)
                    return ErrorResult(MalformedInputException("Home path cannot have the same state as us"));
                home.state.mutex.pureLock;

                // we are in the form of %USERPROFILE%\\path
                // home will be an absolute path that does not end in an separator,
                //  so we won't have to account for that here
                state.storage.remove(0, 13);
                state.storage.prepend(home.state.storage);

                state.lengthOfLeading = home.state.lengthOfLeading;
                state.lengthOfWindowsDrive = home.state.lengthOfWindowsDrive;
                state.lengthOfHost = home.state.lengthOfHost;
                state.lengthOfShare = home.state.lengthOfShare;

                if (state.lengthOfShare > 0) // \\host\share \path
                    state.lengthOfShare++;
                else if (state.lengthOfWindowsDrive == 3 && home.state.storage.length == home.state.offsetOfComponents()) { // C:\ \path
                    // lengths is correct, but there is an extra separator, so we'll remove it if there is storage after it
                    state.storage.remove(state.offsetOfComponents(), 1);
                }

                home.state.mutex.unlock;
                break;
            case FilePathRelativeTo.CurrentWorkingDirectory:
                // just need cwd
                if (cwd.isNull)
                    cwd = currentWorkingDirectory();
                if (cwd.isNull || !cwd.isAbsolute || !home.state.couldPointToEntry)
                    return ErrorResult(UnknownPlatformBehaviorException(
                            "Could not get an absolute current working directory, so path could not be made absolute"));
                else if (cwd.state is this.state)
                    return ErrorResult(MalformedInputException("Current working path cannot have the same state as us"));
                cwd.state.mutex.pureLock;

                // we are in the form of path
                if (!cwd.state.storage.endsWith("\\"))
                    state.storage.prepend("\\");

                state.storage.prepend(cwd.state.storage);
                state.lengthOfLeading = cwd.state.lengthOfLeading;
                state.lengthOfWindowsDrive = cwd.state.lengthOfWindowsDrive;
                state.lengthOfHost = cwd.state.lengthOfHost;
                state.lengthOfShare = cwd.state.lengthOfShare;

                cwd.state.mutex.unlock;
                break;
            case FilePathRelativeTo.DriveAndCWD:
                if (cwd.isNull)
                    cwd = currentWorkingDirectory();
                if (cwd.isNull || !cwd.isAbsolute || !cwd.state.couldPointToEntry || cwd.state.lengthOfHost > 0)
                    return ErrorResult(UnknownPlatformBehaviorException(
                            "Could not get an absolute current working directory, so path could not be made absolute"));
                else if (cwd.state is this.state)
                    return ErrorResult(MalformedInputException("Current working path cannot have the same state as us"));
                cwd.state.mutex.pureLock;

                // we are in the form of C:path

                state.storage.insert(state.offsetOfComponents(), "\\\\"c);
                state.lengthOfWindowsDrive++;
                // ok we are now in c:\\path
                state.storage.insert(state.offsetOfComponents(), cwd.state.storage[cwd.state.offsetOfComponents() .. $]);

                state.storage.prepend("\\\\?\\");
                state.lengthOfLeading = 4;

                cwd.state.mutex.unlock;
                break;
            case FilePathRelativeTo.CurrentDrive:
                if (cwd.isNull)
                    cwd = currentWorkingDirectory();
                if (cwd.isNull || !cwd.isAbsolute || !cwd.state.couldPointToEntry || cwd.state.lengthOfHost > 0)
                    return ErrorResult(UnknownPlatformBehaviorException(
                            "Could not get an absolute current working directory, so path could not be made absolute"));
                else if (cwd.state is this.state)
                    return ErrorResult(MalformedInputException("Current working path cannot have the same state as us"));
                cwd.state.mutex.pureLock;

                // we are in the form of \path
                state.storage.remove(0, 1);
                state.storage.prepend(cwd.state.storage[0 .. cwd.state.offsetOfComponents()]);
                state.lengthOfLeading = cwd.state.lengthOfLeading;
                state.lengthOfWindowsDrive = cwd.state.lengthOfWindowsDrive;

                cwd.state.mutex.unlock;
                break;
            }
            break;
        case FilePathPlatform.Posix:
            final switch (state.relativeTo) {
            case FilePathRelativeTo.Nothing:
                // ok already done!
                break;
            case FilePathRelativeTo.Home:
                // just need home
                if (home.isNull)
                    home = homeDirectory();
                if (home.isNull || !home.isAbsolute || !home.state.couldPointToEntry)
                    return ErrorResult(UnknownPlatformBehaviorException(
                            "Could not get an absolute home directory, so path could not be made absolute"));
                else if (home.state is this.state)
                    return ErrorResult(MalformedInputException("Home path cannot have the same state as us"));
                home.state.mutex.pureLock;

                // home is in form /path
                // we are replacing our ~ with a / so length of leading does not change
                state.storage.remove(0, 1);
                state.storage.prepend(home.state.storage);

                // we did not remove the following / when we removed the ~ and home will not include an ending /
                // so everything is done at this point!

                home.state.mutex.unlock;
                break;
            case FilePathRelativeTo.CurrentWorkingDirectory:
                // just need cwd
                if (cwd.isNull)
                    cwd = currentWorkingDirectory();
                if (cwd.isNull || !cwd.isAbsolute || !home.state.couldPointToEntry)
                    return ErrorResult(UnknownPlatformBehaviorException(
                            "Could not get an absolute current working directory, so path could not be made absolute"));
                else if (cwd.state is this.state)
                    return ErrorResult(MalformedInputException("Current working path cannot have the same state as us"));
                cwd.state.mutex.pureLock;

                // cwd is in the form of /path
                // we are not replacing our leading (but we are adding one)
                assert(state.lengthOfLeading == 0, "Posix CWD path should not have any value for leading");
                state.storage.prepend("/");
                state.lengthOfLeading = 1;
                state.storage.prepend(cwd.state.storage);

                cwd.state.mutex.unlock;
                break;
            case FilePathRelativeTo.DriveAndCWD:
            case FilePathRelativeTo.CurrentDrive:
                assert(0,
                        "Posix paths don't support being relative to current drive and path on another drive");
            }
            break;
        }

        // the above code paths should always result in this if we are here
        state.couldPointToEntry = true;
        state.relativeTo = FilePathRelativeTo.Nothing;


        // make sure to do this step in a different string builder, because we'll need to roll back if it didn't work :(
        {
            ErrorInfo error = this.evaluateRelativeComponents;
            if (error.isSet)
                return typeof(return)(error);
        }

        return ErrorResult.init;
    }

    /// Ditto
    Result!FilePath asAbsolute(scope FilePath cwd = FilePath.init, scope FilePath home = FilePath.init,
            scope return RCAllocator allocator = RCAllocator.init) {
        FilePath ret = this.dup(allocator);
        auto error = ret.makeAbsolute(cwd, home);

        if (error)
            return typeof(return)(ret);
        else
            return typeof(return)(error.getError());
    }

    ///
    @trusted unittest {
        assert(FilePath.from("bin", FilePathPlatform.Posix).assumeOkay.asAbsolute(FilePath.from("/usr",
                FilePathPlatform.Posix).assumeOkay, FilePath.from("/home/sidero", FilePathPlatform.Posix).assumeOkay).assumeOkay ==
                "/usr/bin");
        assert(FilePath.from("~/.bin", FilePathPlatform.Posix).assumeOkay.asAbsolute(FilePath.from("/usr",
                FilePathPlatform.Posix).assumeOkay, FilePath.from("/home/sidero", FilePathPlatform.Posix).assumeOkay).assumeOkay ==
                "/home/sidero/.bin");

        assert(FilePath.from("bin", FilePathPlatform.Windows).assumeOkay.asAbsolute(FilePath.from("C:\\Windows",
                FilePathPlatform.Windows).assumeOkay, FilePath.from("C:\\Users\\Sidero", FilePathPlatform.Windows).assumeOkay).assumeOkay ==
                "\\\\?\\C:\\Windows\\bin");
        assert(FilePath.from("~/.bin", FilePathPlatform.Windows).assumeOkay.asAbsolute(FilePath.from("C:\\Windows",
                FilePathPlatform.Windows).assumeOkay, FilePath.from("C:\\Users\\Sidero", FilePathPlatform.Windows).assumeOkay).assumeOkay ==
                "\\\\?\\C:\\Users\\Sidero\\.bin");
        assert(FilePath.from("D:bin", FilePathPlatform.Windows).assumeOkay.asAbsolute(FilePath.from("C:\\My Program",
                FilePathPlatform.Windows).assumeOkay, FilePath.from("C:\\Users\\Sidero", FilePathPlatform.Windows).assumeOkay).assumeOkay ==
                "\\\\?\\D:\\My Program\\bin");
        assert(FilePath.from("\\bin", FilePathPlatform.Windows).assumeOkay.asAbsolute(FilePath.from("C:\\My Program",
                FilePathPlatform.Windows).assumeOkay, FilePath.from("C:\\Users\\Sidero", FilePathPlatform.Windows).assumeOkay).assumeOkay ==
                "\\\\?\\C:\\bin");

        assert(FilePath.from("../bin", FilePathPlatform.Posix).assumeOkay.asAbsolute(FilePath.from("/usr",
                FilePathPlatform.Posix).assumeOkay, FilePath.from("/home/sidero", FilePathPlatform.Posix).assumeOkay).assumeOkay == "/bin");
        assert(FilePath.from("../bin", FilePathPlatform.Windows).assumeOkay.asAbsolute(FilePath.from("C:\\Windows",
                FilePathPlatform.Windows).assumeOkay, FilePath.from("C:\\Users\\Sidero", FilePathPlatform.Windows).assumeOkay).assumeOkay ==
                "\\\\?\\C:\\bin");
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

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage.asReadOnly(allocator);
    }

    ///
    String_UTF16 toStringUTF16(return scope RCAllocator allocator = RCAllocator.init) scope const @trusted {
        if (isNull)
            return String_UTF16.init;

        FilePathState* state = cast(FilePathState*)this.state;

        state.mutex.pureLock;
        scope (exit)
            state.mutex.unlock;

        return state.storage.byUTF16.asReadOnly(allocator);
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

            assert(FilePath.from("root/some/../path", FilePathPlatform.Windows).assumeOkay == "root\\path");
            assert(FilePath.from("root/some/../path", FilePathPlatform.Posix).assumeOkay == "root/path");
        }
    }

private:

    ErrorInfo evaluateRelativeComponents() scope {
        StringBuilder_UTF8 storage = state.storage.dup(state.allocator);

        final switch (state.platformRule) {
        case FilePathPlatform.Windows:
            StringBuilder_UTF8 allComponents = storage[state.offsetOfComponents() .. $], components = allComponents;

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
                    // we want to remove the prior component, but first we need to figure out where that is!
                    StringBuilder_UTF8 upUntilThis = allComponents[0 .. $ - components.length];
                    // it is in the form of path\..\ or path\..
                    const amountToRemove = components.length > 0 ? 3 : 2;

                    if (upUntilThis.length == amountToRemove) {
                        // not legal if this is an absolute path
                        if (state.relativeTo == FilePathRelativeTo.Nothing)
                            return typeof(return)(MalformedInputException("Found relative parent component in an absolute path"));
                    } else if (upUntilThis.length > 0) {
                        if (components.length > 0) {
                            // there is another component following this, therefore there is a separator so we are in the form of
                            // path\..\
                            upUntilThis.remove(-3, 3);
                            // and now we are path\ muchhhhh better
                        } else {
                            // there is no components following this therefore we are in the form of path\..
                            upUntilThis.remove(-2, 2);
                            // and now we are path\
                        }

                        ptrdiff_t lastSeparatorIndex = upUntilThis[0 .. $ - 1].lastIndexOf("\\");
                        if (lastSeparatorIndex < 0) {
                            upUntilThis.remove(0, upUntilThis.length);
                        } else {
                            upUntilThis.remove(lastSeparatorIndex, upUntilThis.length - (lastSeparatorIndex + 1));
                        }
                    }
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

            // Turn multiple back slahes into one
            storage[state.lengthOfLeading .. $].replace("\\\\", "\\");

            // remove a trailing slash
            if (storage[state.lengthOfLeading .. $].endsWith("\\")) {
                storage.remove(-1, 1);
            }
            break;
        case FilePathPlatform.Posix:
            StringBuilder_UTF8 allComponents = storage[state.offsetOfComponents() .. $], components = allComponents;

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
                    // we want to remove the prior component, but first we need to figure out where that is!
                    StringBuilder_UTF8 upUntilThis = allComponents[0 .. $ - components.length];
                    // it is in the form of path/../ or path/..
                    const amountToRemove = components.length > 0 ? 3 : 2;

                    if (upUntilThis.length == amountToRemove) {
                        // not legal if this is an absolute path
                        if (state.relativeTo == FilePathRelativeTo.Nothing)
                            return typeof(return)(MalformedInputException("Found relative parent component in an absolute path"));
                    } else if (upUntilThis.length > 0) {
                        if (components.length > 0) {
                            // there is another component following this, therefore there is a separator so we are in the form of
                            // path/../
                            upUntilThis.remove(-3, 3);
                            // and now we are path/ muchhhhh better
                        } else {
                            // there is no components following this therefore we are in the form of path/..
                            upUntilThis.remove(-2, 2);
                            // and now we are path/
                        }

                        ptrdiff_t lastSeparatorIndex = upUntilThis[0 .. $ - 1].lastIndexOf("/");
                        if (lastSeparatorIndex < 0) {
                            upUntilThis.remove(0, upUntilThis.length);
                        } else {
                            upUntilThis.remove(lastSeparatorIndex, upUntilThis.length - (lastSeparatorIndex + 1));
                        }
                    }
                } else if (component == ".") {
                    component.remove(-1, 1);
                }
            }

            // Turn multiple back slahes into one
            storage[state.lengthOfLeading .. $].replace("//", "/");

            // remove a trailing slash
            if (storage[state.lengthOfLeading .. $].endsWith("/"))
                storage.remove(-1, 1);
            break;
        }

        state.storage = storage;
        return ErrorInfo.init;
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
    DriveAndCWD,
    ///
    CurrentDrive,
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

    bool couldPointToEntry;

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
            const haveUNChost = isUNCPath && () { Input temp = input[2 .. $]; return temp.length > 0; }();
            const haveUNCshare = haveUNChost && () {
                Input temp = input[2 .. $];
                ptrdiff_t index = temp.indexOf("\\");
                return index > 0 && temp.length > index + 1;
            }();

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
            const isRelativeToPathOnCurrentDrive = !isDevicePath && !isUNCPath && !isDOSPath && !isLegacyDevice &&
                haveDOSDrive && !isDOSPath;

            // - relative to home directory, ~
            const isRelativeToHome = input.startsWith("~");
            const isRelativeToHomeEnv = input.startsWith("%USERPROFILE%");

            // - otherwise they are relative to cwd

            if (isRelativeToPathOnCurrentDrive)
                ret.state.relativeTo = FilePathRelativeTo.DriveAndCWD;
            else if (isRelativeToCurrentDrive)
                ret.state.relativeTo = FilePathRelativeTo.CurrentDrive;
            else if (isRelativeToHome || isRelativeToHomeEnv)
                ret.state.relativeTo = FilePathRelativeTo.Home;
            else if (isDOSPath || isDevicePath)
                ret.state.relativeTo = FilePathRelativeTo.Nothing;
            else if (isUNCPath)
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

            // we want to know if this could point to an entry in the file system
            // this can only be the case iff its a:
            //  - DOS path c:\
            //  - Legacy device \\.\COM1
            //  - Relative to home ~\path or %USERPROFILE%\path
            //  - Is a UNC path
            //  - or just in general relative to cwd
            ret.state.couldPointToEntry = ret.state.relativeTo == FilePathRelativeTo.CurrentWorkingDirectory ||
                isDOSPath || isLegacyDevice || ret.state.relativeTo == FilePathRelativeTo.Home || ((!isDevicePath ||
                        (isUNCPath && haveUNCshare)) && ret.state.relativeTo == FilePathRelativeTo.Nothing);

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
                ErrorInfo error = ret.evaluateRelativeComponents;
                if (error.isSet)
                    return typeof(return)(error);
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
        ret.state.couldPointToEntry = true;

        {
            ErrorInfo error = ret.evaluateRelativeComponents;
            if (error.isSet)
                return typeof(return)(error);
        }

        return typeof(return)(ret);
    }
}
