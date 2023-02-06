module sidero.base.logger;
import sidero.base.text;
import sidero.base.attributes;
import sidero.base.allocators;
import sidero.base.errors;

export @safe nothrow @nogc:

///
alias LoggerReference = ResultReference!Logger;

///
struct Logger {
    private @PrettyPrintIgnore {
        import sidero.base.internal.meta;

        RCAllocator allocator;
        String_UTF8 name_;

        static int opApplyImpl(Del)(scope Del del) @trusted {
            int result;

            auto getLoggers() @trusted nothrow @nogc {
                return loggers;
            }

            static if (__traits(compiles, {LoggerReference lr; del(lr);})) {
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
    String_UTF8 name() {
        return this.name_;
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

        mutexForCreation.unlock;
        return ret;
    }
}

private:
import sidero.base.containers.map.concurrenthashmap;
import sidero.base.parallelism.mutualexclusion : TestTestSetLockInline;

__gshared {
    TestTestSetLockInline mutexForCreation;
    ConcurrentHashMap!(String_UTF8, Logger) loggers;
}
