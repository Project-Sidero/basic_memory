module sidero.base.logger;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.console;
import sidero.base.path.file;
import sidero.base.internal.logassert;

export @safe nothrow @nogc:

///
enum LoggingTargets : uint {
    /// Default
    None = 0,
    ///
    Console = 1,
    ///
    File = 1 << 1,
    /// Posix, requires some sort of syslog
    Syslog = 1 << 2,
    /// Windows events
    Windows = 1 << 3,
    ///
    Custom = 1 << 4,

    ///
    All = Console | File | Syslog | Windows | Custom,
}

///
enum LogLevel {
    /**
    The trace log level, will only output if trace.

    Tracing debug events should only be included in library code for the purposes of understanding failures either in production or during debugging.
    It may take the place of console writing during the debugging process but it should never reach consumers once debugging in complete.
    */
    Trace,

    /**
    The debug log level, will only output for trace to debug inclusive.

    This should be used by library authors to log any action that could fail.
    It may contain any information required to identify the actions being performed as well as any reason a code path may be failing.
    */
    Debug,

    /**
    A information log level, will only output for trace to info inclusive.

    Use this to inform about commonly desired information.
    This includes information such as a system handle has been created with its given value, but only if that system handle is commonly accessed externally.
    You should not be using this to output information that will be exclusively be needed during debugging.
    */
    Info,

    /**
    A notice log level, will only output for trace to notice inclusive.
    It is the default.

    Use this to inform about standard logic within a program.
    This is stuff like a socket connection has been made to a given network address.
    It should not include the system handle for the socket.
    */
    Notice,

    /**
    The warning log level, will only output for trace to warning inclusive.

    Use this to document a potentially indicative behavior to a problem.
    What it is indicative of may not be known at this stage.
    It is used after the ending of a program to help diagnose a problem that has occured.
    */
    Warning,

    /**
    The error log level, will only output for trace to error inclusive.
    This will be printed to standard error not standard output.

    For library authors the purpose of this is for recoverable situations but only if the API is be designed for error checking.
    It allows documenting the cause of a recoverable situation that ends a given library logic.
    */
    Error,

    /**
    A critical log level, will only output for trace to critical inclusive.
    This will be printed to standard error not standard output.

    For library authors the purpose of this is for unrecoverable situations and the API is designed for error checking.
    It allows for documenting the cause of a unrecoverable situation that ends a given programs logic.
    */
    Critical,

    /**
    Fatal log level, will always be printed.
    This will be printed to standard error not standard output.

    For use with any erroneous situation that will immediately ends a program life.
    Use sparingly.

    TODO: this should immediately exit the program
    */
    Fatal,
}

///
enum LogRotateFrequency {
    ///
    None,
    ///
    OnStart,
    ///
    Hourly,
    ///
    Daily,
}

///
alias CustomTargetMessage = void delegate(LogLevel level, GDateTime dateTime, String_UTF8 moduleLineUTF8,
        String_UTF16 moduleLineUTF16, String_UTF8 tags, String_UTF8 levelText, String_UTF8 composite) @safe nothrow @nogc;
///
alias CustomTargetOnRemove = void delegate() @safe nothrow @nogc;

///
alias LoggerReference = ResultReference!Logger;

///
struct Logger {
    private @PrettyPrintIgnore {
        import sidero.base.containers.dynamicarray;
        import sidero.base.internal.meta;

        RCAllocator allocator;
        String_UTF8 name_;

        SystemLock mutex;
        LogLevel logLevel;
        uint targets;

        String_UTF8 dateTimeFormat;
        String_UTF8 tags;

        ConsoleTarget consoleTarget;
        FileTarget fileTarget;
        DynamicArray!CustomTarget customTargets;

        static int opApplyImpl(Del)(scope Del del) @trusted {
            int result;

            auto getLoggers() @trusted nothrow @nogc {
                return loggers;
            }

            static if (__traits(compiles, { LoggerReference lr; del(lr); })) {
                result = getLoggers.opApply(del);
            } else {
                int handle()(ref ResultReference!String_UTF8 k, ref LoggerReference v) {
                    assert(k);
                    String_UTF8 tempKey = k;

                    return del(tempKey, v);
                }

                result = getLoggers.opApply(&handle!());
            }

            return result;
        }
    }

export:

    static {
        ///
        mixin OpApplyCombos!("LoggerReference", "String_UTF8", ["@safe", "nothrow", "@nogc"], "opApply", "opApplyImpl", true);
    }

@safe nothrow @nogc:

    this(return scope ref Logger other) scope {
        this.tupleof = other.tupleof;
        assert(this.name_.isNull, "Don't copy the Logger around directly, use it only by the LoggerReference");
    }

    ~this() scope {
    }

    ///
    bool isNull() scope const {
        return name.isNull;
    }

    ///
    String_UTF8 name() scope const @trusted {
        return (cast(Logger)this).name_;
    }

    ///
    void setLevel(LogLevel level) scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        logLevel = level;
    }

    /// See_Also: LoggingTargets
    void setTargets(uint targets = LoggingTargets.None) scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        this.targets = targets;
    }

    ///
    void setTags(scope return String_UTF8 tags) scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        this.tags = tags;
    }

    ///
    void setTags(scope return String_UTF16 tags) scope {
        this.setTags(tags.byUTF8);
    }

    ///
    void setTags(scope return String_UTF32 tags) scope {
        this.setTags(tags.byUTF8);
    }

    /// Set console stream back to the default
    void setToDefaultConsoleStream() scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        foreach (i, ref v; this.consoleTarget.useErrorStream)
            v = ConsoleTarget.DefaultErrorStream[i];
    }

    /// Will console stream be stderr instead of stdout?
    void setConsoleStream(bool useError) scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        foreach (ref v; this.consoleTarget.useErrorStream)
            v = useError;
    }

    ///
    void setToDefaultConsoleColors() scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        consoleTarget.colors = ConsoleTarget.DefaultConsoleColors;
    }

    ///
    void setConsoleColor(LogLevel level, ConsoleColor foreground = ConsoleColor.Unknown, ConsoleColor background = ConsoleColor.Unknown) {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        consoleTarget.colors[level] = [foreground, background];
    }

    /// Prefix (Separator DateTime)? . Extension
    ErrorResult setLogFile(FilePath rootLogDirectory, String_UTF8 filePrefix, String_UTF8 filePrefixSeparator,
            String_UTF8 fileExtension, LogRotateFrequency rotateFrequency = LogRotateFrequency.OnStart) {
        if (rootLogDirectory.couldPointToEntry) {
            if (!rootLogDirectory.asAbsolute())
                rootLogDirectory = rootLogDirectory.asAbsolute();
        } else
            return ErrorResult(MalformedInputException("Expected a log directory path that could be made absolute"));

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        fileTarget.rootLogDirectory = rootLogDirectory;
        fileTarget.filePrefix = filePrefix;
        fileTarget.filePrefixSeparator = filePrefixSeparator;
        fileTarget.fileExtension = fileExtension;
        fileTarget.logRotateFrequency = rotateFrequency;

        return ErrorResult.init;
    }

    ///
    void addCustomTarget(CustomTargetMessage messageDel, CustomTargetOnRemove onRemoveDel = null) @trusted {
        if (messageDel is null && onRemoveDel is null)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        customTargets ~= CustomTarget();
        customTargets.unsafeGetLiteral[$ - 1] = CustomTarget(messageDel, onRemoveDel);
    }

    ///
    void clearCustomTargets() {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        customTargets = typeof(customTargets)();
    }

    ///
    String_UTF8 toString() scope const {
        return this.name;
    }

    ///
    static LoggerReference forName(return scope String_UTF8 name, return scope RCAllocator allocator = RCAllocator.init) {
        if (name.length == 0)
            return typeof(return)(MalformedInputException("Name must not be empty"));

        LoggerReference ret;

        guardForCreation(() @trusted {
            ret = loggers[name];

            if (ret && !ret.isNull)
                return;

            if (allocator.isNull)
                allocator = globalAllocator();

            if (loggers.isNull) {
                loggers = ConcurrentHashMap!(String_UTF8, Logger)(globalAllocator());
                loggers.cleanupUnreferencedNodes;
            }

            loggers[name] = Logger();
            ret = loggers[name];
            assert(ret);
            ret.allocator = allocator;
            ret.name_ = name;
            ret.dateTimeFormat = GDateTime.ISO8601Format;
            ret.targets = LoggingTargets.Console;

            ret.fileTarget.filePrefix = String_UTF8("log");
            ret.fileTarget.filePrefixSeparator = String_UTF8("_");
            ret.fileTarget.fileExtension = String_UTF8("log");
            ret.fileTarget.logRotateFrequency = LogRotateFrequency.OnStart;

            if (name == "global") {
                globalLogger = ret;
            }

            ret.logLevel = LogLevel.Notice;
        });

        return ret;
    }

    /// Global logger "global"
    static LoggerReference global() {
        return Logger.forName(String_UTF8("global"));
    }

    ///
    void trace(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Trace)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Trace, args);
    }

    ///
    void debug_(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Debug)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Debug, args);
    }

    ///
    alias info = information;

    ///
    void information(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Info)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Info, args);
    }

    ///
    void notice(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Notice)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Notice, args);
    }

    ///
    alias warn = warning;

    ///
    void warning(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Warning)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Warning, args);
    }

    ///
    void error(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Error)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Error, args);
    }

    ///
    void critical(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Critical)
            return;

        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Critical, args);
    }

    ///
    void fatal(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        auto err = mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            mutex.unlock;

        message!(moduleName, line)(LogLevel.Fatal, args);
    }

    ///
    bool opEquals(Logger other) const {
        return this.name_ == other.name_;
    }

    ///
    int opCmp(Logger other) const {
        return this.name_.opCmp(other.name_);
    }

    ///
    ulong toHash() const {
        return this.name_.toHash();
    }

    /*private:*/
    void message(string moduleName, int line, Args...)(LogLevel level, Args args) scope {
        import sidero.base.datetime.time.clock;
        import sidero.base.internal.conv;

        enum ModuleLine2 = stringToWstring!moduleName ~ ":"w ~ intToWString!line;
        enum ModuleLine = " `" ~ moduleName ~ ":" ~ intToString!line ~ "` ";

        GDateTime currentDateTime = accurateDateTime();
        StringBuilder_UTF8 dateTimeText = currentDateTime.format(this.dateTimeFormat);
        StringBuilder_UTF8 contentBuilder;
        String_UTF8 contentUTF8;

        static immutable LevelTag = [
            "TRACE", "DEBUG", "INFO", "NOTICE", "WARNING", "ERROR", "CRITICAL", "FATAL", " TRACE", " DEBUG", " INFO",
            " NOTICE", " WARNING", " ERROR", " CRITICAL", " FATAL"
        ];

        void syslog() {
            version (Posix) {
                import core.sys.posix.syslog : syslog, openlog, closelog, LOG_PID, LOG_CONS, LOG_USER;

                guardForCreation(() @trusted {
                    if (!haveSysLog) {
                        openlog("ProjectSidero dependent program".ptr, LOG_PID | LOG_CONS, LOG_USER);
                        haveSysLog = true;
                    }

                    syslog(PrioritySyslogForLevels[level], contentUTF8.ptr);
                });
            }
        }

        void windowsEvents() @trusted {
            version (Windows) {
                import core.sys.windows.windows : ReportEventW, WORD, DWORD, EVENTLOG_INFORMATION_TYPE,
                    EVENTLOG_WARNING_TYPE, EVENTLOG_ERROR_TYPE;

                guardForCreation(() @trusted {
                    static WORD[] WTypes = [
                        EVENTLOG_INFORMATION_TYPE, EVENTLOG_INFORMATION_TYPE, EVENTLOG_WARNING_TYPE,
                        EVENTLOG_ERROR_TYPE, EVENTLOG_ERROR_TYPE, EVENTLOG_ERROR_TYPE
                    ];

                    String_UTF16 text = contentBuilder[dateTimeText.length + ModuleLine.length .. $].byUTF16.asReadOnly;

                    static WORD[] dwEventID = [0, 1, 2, 3, 4, 5];
                    const(wchar)*[2] messages = [ModuleLine2.ptr, text.ptr];

                    ReportEventW(needWindowsEventHandle(), WTypes[level], dwEventID[level], 0, cast(void*)null, 2,
                        0, &messages[0], cast(void*)null);
                });
            }
        }

        void file() @trusted {
            bool triggered = fileTarget.logStream.isNull;

            if (!triggered) {
                // check based upon last date/time

                final switch (fileTarget.logRotateFrequency) {
                case LogRotateFrequency.None:
                case LogRotateFrequency.OnStart:
                    break;
                case LogRotateFrequency.Hourly:
                    triggered = currentDateTime.hour != fileTarget.logRotateLastDateTime.hour;
                    break;
                case LogRotateFrequency.Daily:
                    triggered = currentDateTime.day != fileTarget.logRotateLastDateTime.day;
                    break;
                }
            }

            if (triggered) {
                // recreate!
                FilePath fp = fileTarget.rootLogDirectory.dup;

                StringBuilder_UTF8 filename;
                filename ~= fileTarget.filePrefix;

                if (fileTarget.logRotateFrequency == LogRotateFrequency.None) {
                    // does not include date/time
                } else {
                    filename ~= fileTarget.filePrefixSeparator;
                    filename ~= currentDateTime.format(GDateTime.LogFileName);
                }

                if (fileTarget.fileExtension.length > 0 && !fileTarget.fileExtension.startsWith("."))
                    filename ~= "."c;
                filename ~= fileTarget.fileExtension;

                cast(void)(fp ~= filename);

                auto filePath = FilePath.from(filename);
                if (filePath)
                    fileTarget.logStream = FileAppender(filePath.get);
            }

            fileTarget.logStream.append(contentBuilder);
            fileTarget.logStream.append(String_UTF8("\n"));
        }

        void custom() @trusted {
            foreach (ref ct; customTargets.unsafeGetLiteral()) {
                ct.messageDel(level, currentDateTime, String_UTF8(ModuleLine), String_UTF16(ModuleLine2), tags,
                        String_UTF8(LevelTag[level + (tags.isNull ? 0 : 6)]), contentUTF8);
            }
        }

        if (targets & LoggingTargets.Console) {
            import sidero.base.console;

            auto fg = consoleTarget.colors[level][0], bg = consoleTarget.colors[level][1];
            auto formatArg = resetDefaultBeforeApplying().deliminateArgs(false).prettyPrintingActive(true)
                .foreground(fg).background(bg).useErrorStream(consoleTarget.useErrorStream[level]);

            writeln(formatArg, dateTimeText, ModuleLine, tags, LevelTag[level + (tags.isNull ? 0 : 6)],
                    resetDefaultBeforeApplying(), ": ", args, resetDefaultBeforeApplying());
        }

        if (targets & LoggingTargets.File || targets & LoggingTargets.Syslog || targets & LoggingTargets.Windows ||
                targets & LoggingTargets.Custom) {
            {
                contentBuilder ~= dateTimeText;
                contentBuilder ~= ModuleLine;
                contentBuilder ~= tags;
                contentBuilder ~= LevelTag[level + (tags.isNull ? 0 : 6)];
                contentBuilder ~= ": ";

                PrettyPrint prettyPrinter = PrettyPrint.defaults;
                prettyPrinter(contentBuilder, args);
            }

            if (targets & LoggingTargets.Windows)
                windowsEvents;
            if (targets & LoggingTargets.Syslog || targets & LoggingTargets.Custom)
                contentUTF8 = contentBuilder.asReadOnly;
            if (targets & LoggingTargets.File)
                file;
            if (targets & LoggingTargets.Syslog)
                syslog;
            if (targets & LoggingTargets.Custom)
                custom;
        }
    }
}

///
void setLogProcessName(String_UTF8 name) @trusted {
    if (name.length == 0) {
        guardForCreation(() @trusted { processName = String_UTF8.init; });
        return;
    }

    if (name.isPtrNullTerminated && !name.isEncodingChanged)
        processName = name;
    else
        processName = name.dup;

    version (Posix) {
        import core.sys.posix.syslog : openlog, closelog, LOG_PID, LOG_CONS, LOG_USER;

        guardForCreation(() @trusted {
            if (haveSysLog)
                closelog();
            haveSysLog = true;

            openlog(processName.ptr, LOG_PID | LOG_CONS, LOG_USER);
        });
    } else version (Windows) {
        import core.sys.windows.windows : RegisterEventSourceW, DeregisterEventSource;

        guardForCreation(() @trusted {
            if (windowsEventHandle !is null) {
                DeregisterEventSource(windowsEventHandle);
            }

            String_UTF16 processName16 = name.byUTF16.dup;
            windowsEventHandle = RegisterEventSourceW(null, cast(wchar*)processName16.ptr);
        });
    }
}

///
void trace(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.trace!(moduleName, line)(args);
}

///
void debug_(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.debug_!(moduleName, line)(args);
}

///
alias info = information;

///
void information(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.info!(moduleName, line)(args);
}

///
void notice(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.notice!(moduleName, line)(args);
}

///
alias warn = warning;

///
void warning(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.warning!(moduleName, line)(args);
}

///
void error(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.error!(moduleName, line)(args);
}

///
void critical(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.critical!(moduleName, line)(args);
}

///
void fatal(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.fatal!(moduleName, line)(args);
}

pragma(crt_destructor) extern (C) void deinitializeLogging() @trusted {
    version (Posix) {
        import core.sys.posix.syslog : closelog;

        if (haveSysLog) {
            closelog;
            haveSysLog = false;
        }
    } else version (Windows) {
        import core.sys.windows.windows : DeregisterEventSource;

        if (windowsEventHandle !is null) {
            DeregisterEventSource(windowsEventHandle);
            windowsEventHandle = null;
        }
    }
}

export void guardForCreation(scope void delegate() @safe nothrow @nogc del) @trusted {
    auto err = mutexForCreation.lock;
    logAssert(cast(bool)err, "Failed to lock", err.getError());
    scope (exit)
        mutexForCreation.unlock;

    del();
}

version (Windows) {
    export HANDLE needWindowsEventHandle() @trusted {
        import core.sys.windows.windows : RegisterEventSourceW;

        if (windowsEventHandle is null)
            windowsEventHandle = RegisterEventSourceW(null, cast(wchar*)"ProjectSidero dependent program"w.ptr);

        return windowsEventHandle;
    }
}

private:
import sidero.base.containers.map.concurrenthashmap;
import sidero.base.synchronization.system.lock;
import sidero.base.internal.filesystem;
import sidero.base.datetime : GDateTime;

__gshared {
    SystemLock mutexForCreation;
    ConcurrentHashMap!(String_UTF8, Logger) loggers;
    LoggerReference globalLogger;
    String_UTF8 processName;
    bool haveSysLog;
}

struct ConsoleTarget {
    static immutable DefaultErrorStream = [false, false, false, false, false, true, true, true];
    static immutable ConsoleColor[2][8] DefaultConsoleColors = [
        [ConsoleColor.Yellow, ConsoleColor.Unknown], [ConsoleColor.Blue, ConsoleColor.Unknown],
        [ConsoleColor.Green, ConsoleColor.Unknown], [ConsoleColor.Unknown, ConsoleColor.Unknown],
        [ConsoleColor.Magenta, ConsoleColor.Unknown], [ConsoleColor.Red, ConsoleColor.Yellow],
        [ConsoleColor.Red, ConsoleColor.Cyan], [ConsoleColor.Red, ConsoleColor.Blue],
    ];

    ConsoleColor[2][8] colors = DefaultConsoleColors;
    bool[8] useErrorStream = DefaultErrorStream;

export @safe nothrow @nogc:

     ~this() {
    }
}

struct FileTarget {
    FilePath rootLogDirectory;
    String_UTF8 filePrefix, filePrefixSeparator, fileExtension;

    GDateTime logRotateLastDateTime;
    LogRotateFrequency logRotateFrequency;

    FileAppender logStream;

@safe nothrow @nogc:

    this(return scope ref FileTarget other) scope {
    }

    auto toHash() scope const @trusted {
        import sidero.base.hash.utils;

        ulong ret = hashOf();

        static foreach (I; 0 .. this.tupleof.length) {
            ret = hashOf((*cast(FileTarget*)&this).tupleof[I], ret);
        }

        return ret;
    }
}

struct CustomTarget {
    CustomTargetMessage messageDel;
    CustomTargetOnRemove onRemoveDel;

export @safe nothrow @nogc:

     ~this() scope {
        if (onRemoveDel !is null)
            onRemoveDel();
    }
}

version (Windows) {
    import core.sys.windows.windows : HANDLE;

    __gshared HANDLE windowsEventHandle;
} else version (Posix) {
    import core.sys.posix.syslog : LOG_DEBUG, LOG_INFO, LOG_NOTICE, LOG_WARNING, LOG_ERR, LOG_CRIT;

    static PrioritySyslogForLevels = [
        LOG_DEBUG, LOG_DEBUG, LOG_INFO, LOG_NOTICE, LOG_WARNING, LOG_ERR, LOG_ERR, LOG_CRIT
    ];
}
