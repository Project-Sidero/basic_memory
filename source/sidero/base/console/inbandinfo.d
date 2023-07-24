module sidero.base.console.inbandinfo;
import sidero.base.typecons : Optional;

export @safe nothrow @nogc:

///
enum ConsoleColor {
    ///
    Unknown,
    ///
    Black,
    ///
    Red,
    ///
    Green,
    ///
    Yellow,
    ///
    Blue,
    ///
    Magenta,
    ///
    Cyan,
    ///
    White,
}

///
struct InBandInfo {
    /// Does not reset useError
    bool resetDefaults;
    ///
    Optional!bool deliminateArguments;
    ///
    ConsoleColor backgroundColor, foregroundColor;
    ///
    Optional!bool prettyPrintActive;
    ///
    Optional!bool useError;

export @trusted nothrow @nogc scope:

    this(return scope ref InBandInfo other) {
        this.tupleof = other.tupleof;
    }

    ///
    InBandInfo resetDefaultBeforeApplying(bool value = true) {
        InBandInfo ret = this;
        ret.resetDefaults = value;
        return ret;
    }

    ///
    InBandInfo deliminateArgs(bool value = false) {
        InBandInfo ret = this;
        ret.deliminateArguments = value;
        return ret;
    }

    ///
    InBandInfo background(ConsoleColor color) {
        InBandInfo ret = this;
        ret.backgroundColor = color;
        return ret;
    }

    ///
    InBandInfo foreground(ConsoleColor color) {
        InBandInfo ret = this;
        ret.foregroundColor = color;
        return ret;
    }

    ///
    InBandInfo prettyPrintingActive(bool active) {
        InBandInfo ret = this;
        ret.prettyPrintActive = active;
        return ret;
    }

    ///
    InBandInfo useErrorStream(bool useError) {
        InBandInfo ret = this;
        ret.useError = useError;
        return ret;
    }
}

///
InBandInfo resetDefaultBeforeApplying(bool value = true) {
    return InBandInfo().resetDefaultBeforeApplying(value);
}

///
InBandInfo deliminateArgs(bool value = false) {
    return InBandInfo().deliminateArgs(value);
}

///
InBandInfo background(ConsoleColor color) {
    return InBandInfo().background(color);
}

///
InBandInfo foreground(ConsoleColor color) {
    return InBandInfo().foreground(color);
}

///
InBandInfo prettyPrintingActive(bool active) {
    return InBandInfo().prettyPrintingActive(active);
}

///
InBandInfo useErrorStream(bool useError) {
    return InBandInfo().useErrorStream(useError);
}
