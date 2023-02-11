module sidero.base.logger;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.allocators;
import sidero.base.errors;
import sidero.base.console;

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
    /// Outputs everything
    Trace,
    /// Default, will only output info/warning/error/critical/fatal
    Info,
    /// Will only output warning/error/critical/fatal
    Warning,
    /// Will only output error/critical/fatal
    Error,
    /// Will only output critical/fatal
    Critical,
    /// Will only output fatal; this should (but won't) end the program
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
alias CustomTargetMessage = void delegate(LogLevel level, GDateTime dateTime, String_UTF8[2] moduleLine,
        String_UTF8 tags, String_UTF8 levelText, String_UTF8 composite) @safe nothrow @nogc;
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

        ubyte[TestTestSetLockInline.sizeof] mutexStorage;
        LogLevel logLevel;
        uint targets;

        String_UTF8 dateTimeFormat;
        String_UTF8 tags;

        ConsoleTarget consoleTarget;
        FileTarget fileTarget;
        DynamicArray!CustomTarget customTargets;

        ref TestTestSetLockInline mutex() scope return nothrow @nogc {
            return *cast(TestTestSetLockInline*)mutexStorage.ptr;
        }

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

    ///
    String_UTF8 name() scope const @trusted {
        return (cast(Logger)this).name_;
    }

    ///
    void setLevel(LogLevel level) scope {
        mutex.pureLock;
        logLevel = level;
        mutex.unlock;
    }

    /// See_Also: LoggingTargets
    void setTargets(uint targets = LoggingTargets.None) scope {
        mutex.pureLock;
        this.targets = targets;
        mutex.unlock;
    }

    ///
    void setTags(scope return String_UTF8 tags) scope {
        mutex.pureLock;
        this.tags = tags;
        mutex.unlock;
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
        mutex.pureLock;
        this.consoleTarget.useErrorStream = ConsoleTarget.DefaultErrorStream;
        mutex.unlock;
    }

    /// Will console stream be stderr instead of stdout?
    void setConsoleStream(bool useError) scope {
        mutex.pureLock;
        foreach (ref v; this.consoleTarget.useErrorStream)
            v = useError;
        mutex.unlock;
    }

    ///
    void setToDefaultConsoleColors() scope {
        mutex.pureLock;
        consoleTarget.colors = ConsoleTarget.DefaultConsoleColors;
        mutex.unlock;
    }

    ///
    void setConsoleColor(LogLevel level, ConsoleColor foreground = ConsoleColor.Unknown, ConsoleColor background = ConsoleColor.Unknown) {
        mutex.pureLock;
        consoleTarget.colors[level] = [foreground, background];
        mutex.unlock;
    }

    /// Prefix (Separator DateTime)? . Extension
    void setLogFile(String_UTF8 rootLogDirectory, String_UTF8 filePrefix, String_UTF8 filePrefixSeparator,
            String_UTF8 fileExtension, LogRotateFrequency rotateFrequency = LogRotateFrequency.OnStart) {
        mutex.pureLock;
        fileTarget.rootLogDirectory = rootLogDirectory;
        fileTarget.filePrefix = filePrefix;
        fileTarget.filePrefixSeparator = filePrefixSeparator;
        fileTarget.fileExtension = fileExtension;
        fileTarget.logRotateFrequency = rotateFrequency;
        mutex.unlock;
    }

    ///
    void addCustomTarget(CustomTargetMessage messageDel, CustomTargetOnRemove onRemoveDel = null) @trusted {
        if (messageDel is null && onRemoveDel is null)
            return;

        mutex.pureLock;
        customTargets ~= CustomTarget();
        customTargets.unsafeGetLiteral[$ - 1] = CustomTarget(messageDel, onRemoveDel);
        mutex.unlock;
    }

    ///
    void clearCustomTargets() {
        mutex.pureLock;
        customTargets = typeof(customTargets)();
        mutex.unlock;
    }

    ///
    String_UTF8 toString() scope const {
        return this.name;
    }

    ///
    static LoggerReference forName(return scope String_UTF8 name, return scope RCAllocator allocator = RCAllocator.init) @trusted {
        if (name.length == 0)
            return typeof(return)(MalformedInputException("Name must not be empty"));

        mutexForCreation.pureLock;

        LoggerReference ret = loggers[name];
        if (ret) {
            mutexForCreation.unlock;
            return ret;
        }

        if (allocator.isNull)
            allocator = globalAllocator();

        if (loggers.isNull) {
            loggers = ConcurrentHashMap!(String_UTF8, Logger)(globalAllocator());
            loggers.cleanupUnreferencedNodes;
        }

        loggers[name] = Logger.init;
        ret = loggers[name];
        assert(ret);
        ret.allocator = allocator;
        ret.name_ = name;
        ret.dateTimeFormat = GDateTime.ISO8601Format;
        ret.logLevel = LogLevel.Info;

        ret.fileTarget.filePrefix = String_UTF8("log");
        ret.fileTarget.filePrefixSeparator = String_UTF8("_");
        ret.fileTarget.fileExtension = String_UTF8("log");
        ret.fileTarget.logRotateFrequency = LogRotateFrequency.OnStart;

        if (name == "global")
            globalLogger = ret;

        mutexForCreation.unlock;
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

        mutex.pureLock;
        message!(moduleName, line)(LogLevel.Trace, args);
        mutex.unlock;
    }

    ///
    void info(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Warning)
            return;

        mutex.pureLock;
        message!(moduleName, line)(LogLevel.Info, args);
        mutex.unlock;
    }

    ///
    void warning(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Warning)
            return;

        mutex.pureLock;
        message!(moduleName, line)(LogLevel.Warning, args);
        mutex.unlock;
    }

    ///
    void error(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Error)
            return;

        mutex.pureLock;
        message!(moduleName, line)(LogLevel.Error, args);
        mutex.unlock;
    }

    ///
    void critical(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        if (logLevel > LogLevel.Critical)
            return;

        mutex.pureLock;
        message!(moduleName, line)(LogLevel.Critical, args);
        mutex.unlock;
    }

    ///
    void fatal(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) scope {
        mutex.pureLock;
        message!(moduleName, line)(LogLevel.Fatal, args);
        mutex.unlock;
    }

private:
    void message(string moduleName, int line, Args...)(LogLevel level, Args args) scope {
        import sidero.base.datetime.time.clock;
        import std.conv : text, wtext;

        enum ModuleLine2 = moduleName.wtext ~ ":"w ~ line.wtext;
        enum ModuleLine = " `" ~ moduleName ~ ":" ~ line.text ~ "` ";

        GDateTime currentDateTime = accurateDateTime();
        StringBuilder_UTF8 dateTimeText = currentDateTime.format(this.dateTimeFormat);
        StringBuilder_UTF8 contentBuilder;
        String_UTF8 contentUTF8;

        static immutable LevelTag = [
            "TRACE", "INFO", "WARNING", "ERROR", "CRITICAL", "FATAL", " TRACE", " INFO", " WARNING", " ERROR", " CRITICAL",
            " FATAL"
        ];

        void handleConsole() {
            import sidero.base.console;

            auto fg = consoleTarget.colors[level][0], bg = consoleTarget.colors[level][1];

            writeln(resetDefaultBeforeApplying().deliminateArgs(false).prettyPrintingActive(true).foreground(fg)
                    .background(bg).useErrorStream(consoleTarget.useErrorStream[level]), dateTimeText, ModuleLine,
                    tags, LevelTag[level + (tags.isNull ? 0 : 6)], resetDefaultBeforeApplying(), ": ", args, resetDefaultBeforeApplying());
        }

        void syslog() @trusted {
            version (Posix) {
                import core.sys.posix.syslog : syslog, openlog, closelog, LOG_PID, LOG_CONS, LOG_USER;

                mutexForCreation.pureLock;
                if (!haveSysLog) {
                    openlog("ProjectSidero dependent program".ptr, LOG_PID | LOG_CONS, LOG_USER);
                    haveSysLog = true;
                }

                syslog(PrioritySyslogForLevels[level], contentUTF8.ptr);
                mutexForCreation.unlock;
            }
        }

        void windowsEvents() @trusted {
            version (Windows) {
                import core.sys.windows.windows : ReportEventW, RegisterEventSourceW, WORD, DWORD,
                    EVENTLOG_INFORMATION_TYPE, EVENTLOG_WARNING_TYPE, EVENTLOG_ERROR_TYPE;

                mutexForCreation.pureLock;
                if (windowsEventHandle is null) {
                    windowsEventHandle = RegisterEventSourceW(null, cast(wchar*)"ProjectSidero dependent program"w.ptr);
                }

                static WORD[] WTypes = [
                    EVENTLOG_INFORMATION_TYPE, EVENTLOG_INFORMATION_TYPE, EVENTLOG_WARNING_TYPE, EVENTLOG_ERROR_TYPE,
                    EVENTLOG_ERROR_TYPE, EVENTLOG_ERROR_TYPE
                ];

                String_UTF16 text = contentBuilder[dateTimeText.length + ModuleLine.length .. $].byUTF16.asReadOnly;

                static WORD[] dwEventID = [0, 1, 2, 3, 4, 5];
                const(wchar)*[2] messages = [ModuleLine2.ptr, text.ptr];

                ReportEventW(windowsEventHandle, WTypes[level], dwEventID[level], 0, cast(void*)null, 2, 0,
                        &messages[0], cast(void*)null);
                mutexForCreation.unlock;
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

                StringBuilder_UTF8 filename;
                filename ~= fileTarget.rootLogDirectory;

                if (filename.length > 0 && !(filename.endsWith("/") || filename.endsWith("\\")))
                    filename ~= "/"c;

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
                fileTarget.logStream = FileAppender(filename.asReadOnly);
            }

            fileTarget.logStream.append(contentBuilder);
            fileTarget.logStream.append(String_UTF8("\n"));
        }

        void custom() @trusted {
            foreach (ref ct; customTargets.unsafeGetLiteral()) {
                ct.message(level, currentDateTime, [String_ASCII(ModuleLine), String_ASCII(ModuleLine2)], tags,
                        Text[level + (tags.isNull ? 0 : 6)], contentUTF8);
            }
        }

        if (targets & LoggingTargets.Console)
            handleConsole;
        if (targets & LoggingTargets.File || targets & LoggingTargets.Syslog || targets & LoggingTargets.Windows ||
                targets & LoggingTargets.Custom) {
            {
                contentBuilder ~= dateTimeText;
                contentBuilder ~= ModuleLine;
                contentBuilder ~= tags;
                contentBuilder ~= LevelTag[level + (tags.isNull ? 0 : 6)];
                contentBuilder ~= ": ";

                PrettyPrint!String_UTF8 prettyPrinter;
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
        mutexForCreation.pureLock;

        processName = String_UTF8.init;

        mutexForCreation.unlock;
        return;
    }

    if (name.isPtrNullTerminated)
        processName = name;
    else
        processName = name.dup;

    version (Posix) {
        import core.sys.posix.syslog : openlog, closelog, LOG_PID, LOG_CONS, LOG_USER;

        mutexForCreation.pureLock;

        if (haveSysLog)
            closelog();
        haveSysLog = true;

        openlog(processName.ptr, LOG_PID | LOG_CONS, LOG_USER);

        mutexForCreation.unlock;
    } else version (Windows) {
        import core.sys.windows.windows : RegisterEventSourceW, DeregisterEventSource;

        mutexForCreation.pureLock;

        if (windowsEventHandle !is null) {
            DeregisterEventSource(windowsEventHandle);
        }

        String_UTF16 processName16 = name.byUTF16.dup;
        windowsEventHandle = RegisterEventSourceW(null, cast(wchar*)processName16.ptr);

        mutexForCreation.unlock;
    }
}

///
void trace(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.trace!(moduleName, line)(args);
}

///
void info(string moduleName = __MODULE__, int line = __LINE__, Args...)(Args args) @trusted {
    Logger.global.assumeOkay.info!(moduleName, line)(args);
}

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

private:
import sidero.base.containers.map.concurrenthashmap;
import sidero.base.parallelism.mutualexclusion : TestTestSetLockInline;
import sidero.base.internal.filesystem;
import sidero.base.datetime;

__gshared {
    TestTestSetLockInline mutexForCreation;
    ConcurrentHashMap!(String_UTF8, Logger) loggers;
    LoggerReference globalLogger;
    String_UTF8 processName;
    bool haveSysLog;
}

struct ConsoleTarget {
    static immutable DefaultErrorStream = [false, false, false, true, true, true];
    static immutable ConsoleColor[2][6] DefaultConsoleColors = [
        [ConsoleColor.Yellow, ConsoleColor.Unknown], [ConsoleColor.Green, ConsoleColor.Unknown],
        [ConsoleColor.Magenta, ConsoleColor.Unknown], [ConsoleColor.Red, ConsoleColor.Yellow],
        [ConsoleColor.Red, ConsoleColor.Cyan], [ConsoleColor.Red, ConsoleColor.Blue],
    ];

    ConsoleColor[2][6] colors = DefaultConsoleColors;
    bool[6] useErrorStream = DefaultErrorStream;
}

struct FileTarget {
    String_UTF8 rootLogDirectory, filePrefix, filePrefixSeparator, fileExtension;

    GDateTime logRotateLastDateTime;
    LogRotateFrequency logRotateFrequency;

    FileAppender logStream;

@safe nothrow @nogc:

    this(return scope ref FileTarget other) scope {
    }
}

struct CustomTarget {
    CustomTargetMessage messageDel;
    CustomTargetOnRemove onRemoveDel;

@safe nothrow @nogc:

     ~this() scope {
        if (onRemoveDel !is null)
            onRemoveDel();
    }
}

version (Windows) {
    import core.sys.windows.windows : HANDLE;

    __gshared HANDLE windowsEventHandle;
} else version (Posix) {
    import core.sys.posix.syslog : LOG_DEBUG, LOG_INFO, LOG_NOTICE, LOG_WARNING, LOG_ERR;

    static PrioritySyslogForLevels = [LOG_DEBUG, LOG_INFO, LOG_NOTICE, LOG_WARNING, LOG_ERR, LOG_ERR];
}
