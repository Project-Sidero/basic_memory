module sidero.base.console.internal.writer;
import sidero.base.console.internal.rawwrite;
import sidero.base.console.inbandinfo;
import sidero.base.allocators;
import sidero.base.text;
import sidero.base.traits;

struct Writer {
    uint prettyPrintDepth;
    bool prettyPrintActive, deliminateArguments;
    bool haveSetDeliminateArguments;
    bool isFirstPrettyPrint;
    bool useErrorStream;

    bool wasDeliminted;
    bool gotPrintable;

export @safe nothrow @nogc:

    void handle(Args...)(scope Args args) @trusted {
        static if (Args.length == 1) {
            alias ArgType = typeof(args[0]);
            handleOneWrite!ArgType(this, args[0]);
        } else {
            static foreach (i; 0 .. Args.length) {
                {
                    alias ArgType = typeof(args[i]);

                    static if (!is(ArgType == InBandInfo)) {
                        if (deliminateArguments) {
                            if (gotPrintable)
                                rawWriteImpl(String_UTF8(", "), useErrorStream);
                            gotPrintable = true;
                            wasDeliminted = true;
                        } else if (wasDeliminted) {
                            static if (!(isAnyString!ArgType)) {
                                rawWriteImpl(String_UTF8(", "), useErrorStream);
                            } else {
                                if (args[i] != "\n")
                                    rawWriteImpl(String_UTF8(", "), useErrorStream);
                            }

                            wasDeliminted = false;
                        }
                    }

                    handleOneWrite!ArgType(this, args[i]);

                    if (!deliminateArguments && is(ArgType == InBandInfo))
                        gotPrintable = false;
                }
            }
        }

        rawWriteImpl(String_UTF8(""), useErrorStream);
    }
}

private:

void handleOneWrite(Type)(scope ref Writer writer, scope ref Type arg) {
    static void perform(scope ref Writer writer, scope ref Type arg) {
        static if (isAnyString!Type) {
            if (writer.deliminateArguments) {
                StringBuilder_UTF8 builder;

                builder ~= arg;
                builder.escape('"');

                builder.prepend(`"`);
                builder.append(`"`);

                rawWriteImpl(builder, writer.useErrorStream);
            } else {
                static if (isASCII!Type) {
                    rawWriteImpl(arg, writer.useErrorStream);
                } else static if (isReadOnlyString!Type || isBuilderString!Type) {
                    auto temp = arg.byUTF8;
                    rawWriteImpl(temp, writer.useErrorStream);
                } else {
                    rawWriteImpl(String_UTF8(arg), writer.useErrorStream);
                }
            }
        } else static if (is(Type == InBandInfo)) {
            if (arg.resetDefaults) {
                writer.prettyPrintDepth = 0;
                writer.prettyPrintActive = false;
                writer.deliminateArguments = false;
                writer.isFirstPrettyPrint = true;
                writer.haveSetDeliminateArguments = false;

                writer.wasDeliminted = false;
            }

            if (!arg.prettyPrintActive.isNull)
                writer.prettyPrintActive = arg.prettyPrintActive.get;
            if (!arg.deliminateArguments.isNull) {
                writer.deliminateArguments = arg.deliminateArguments.get;
                writer.haveSetDeliminateArguments = true;
            }
            if (!arg.useError.isNull)
                writer.useErrorStream = arg.useError.get;

            if (!writer.haveSetDeliminateArguments && !arg.prettyPrintActive.isNull && arg.deliminateArguments.isNull)
                writer.deliminateArguments = writer.prettyPrintActive;

            rawWriteImpl(arg, writer.useErrorStream);
        } else {
            StringBuilder_UTF8 builder = StringBuilder_UTF8(globalAllocator());

            if (writer.prettyPrintActive) {
                PrettyPrint prettyPrint = PrettyPrint.defaults;
                prettyPrint.startWithoutPrefix = !writer.deliminateArguments;

                if (!writer.isFirstPrettyPrint)
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

    (cast(void function(scope ref Writer, scope ref Type)@safe nothrow @nogc)&perform)(writer, arg);
}
