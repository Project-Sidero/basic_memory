module sidero.base.console.internal.writer;
import sidero.base.console.internal.rawwrite;
import sidero.base.console.inbandinfo;
import sidero.base.allocators;
import sidero.base.text;
import sidero.base.traits;

struct Writer {
    uint prettyPrintDepth;
    bool prettyPrintActive, deliminateArguments, setPrettyDelim;
    bool isFirstPrettyPrint;
    bool useErrorStream;

export @safe nothrow @nogc:

    void handle(Args...)(scope Args args) @trusted {
        static if(Args.length == 1) {
            alias ArgType = typeof(args[0]);
            (cast(handleOneWriterPrototype!ArgType)&handleOneWrite!ArgType)(this, 0, args[0]);
        } else {
            size_t gotPrintable, printing;
            bool wasDeliminted;

            foreach(i, ref arg; args) {
                alias ArgType = typeof(arg);

                if(deliminateArguments && !is(ArgType == InBandInfo)) {
                    if(gotPrintable > 0)
                        rawWriteImpl(String_UTF8(", "), useErrorStream);
                    gotPrintable++;
                    wasDeliminted = true;
                } else if(wasDeliminted && !is(ArgType == InBandInfo)) {
                    static if(!(isAnyString!ArgType))
                        rawWriteImpl(String_UTF8(", "), useErrorStream);
                    else {
                        if(arg != "\n")
                            rawWriteImpl(String_UTF8(", "), useErrorStream);
                    }

                    wasDeliminted = false;
                }

                (cast(handleOneWriterPrototype!ArgType)&handleOneWrite!ArgType)(this, printing, arg);

                static if(!is(ArgType == InBandInfo))
                    printing++;

                if(!deliminateArguments && is(ArgType == InBandInfo))
                    gotPrintable = 0;
            }
        }
    }
}

private:

alias handleOneWriterPrototype(Type) = void function(scope ref Writer writer, size_t argumentId, scope ref Type arg) @safe nothrow @nogc;

void handleOneWrite(Type)(scope ref Writer writer, size_t argumentId, scope ref Type arg) {
    static if(isAnyString!Type) {
        if(writer.deliminateArguments)
            rawWriteImpl(String_UTF8(`"`), writer.useErrorStream);

        static if(isReadOnlyString!Type || isBuilderString!Type) {
            rawWriteImpl(arg.byUTF8, writer.useErrorStream);
        } else {
            rawWriteImpl(String_UTF8(arg), writer.useErrorStream);
        }

        if(writer.deliminateArguments)
            rawWriteImpl(String_UTF8(`"`), writer.useErrorStream);
    } else static if(is(Type == InBandInfo)) {
        if(arg.resetDefaults) {
            writer.prettyPrintDepth = 0;
            writer.prettyPrintActive = false;
            writer.deliminateArguments = false;
            writer.setPrettyDelim = false;
            writer.isFirstPrettyPrint = true;
        }

        if(!arg.prettyPrintActive.isNull)
            writer.prettyPrintActive = arg.prettyPrintActive.get;
        if(!arg.deliminateArguments.isNull)
            writer.deliminateArguments = arg.deliminateArguments.get;
        if(!writer.setPrettyDelim && !arg.prettyPrintActive.isNull && arg.deliminateArguments.isNull) {
            writer.deliminateArguments = arg.prettyPrintActive.get;
            writer.setPrettyDelim = true;
        }
        if(!arg.useError.isNull)
            writer.useErrorStream = arg.useError.get;

        rawWriteImpl(arg, writer.useErrorStream);
    } else {
        StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());

        if(writer.prettyPrintActive) {
            PrettyPrint prettyPrint = PrettyPrint.defaults;
            prettyPrint.useQuotes = writer.deliminateArguments;
            prettyPrint.startWithoutPrefix = argumentId == 0 || !writer.deliminateArguments;

            if(!writer.isFirstPrettyPrint)
                builder ~= "\n";
            writer.isFirstPrettyPrint = false;

            prettyPrint.depth = writer.prettyPrintDepth;
            prettyPrint(builder, arg);
        } else {
            builder.formattedWrite("", arg);
        }

        rawWriteImpl(builder, writer.useErrorStream);
    }
}
