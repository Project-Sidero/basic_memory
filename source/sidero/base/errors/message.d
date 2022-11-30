module sidero.base.errors.message;
export:

///
struct ErrorMessage {
    ///
    string id;
    ///
    string message;

export @safe nothrow @nogc pure:

    ///
    this(string id, string message) scope {
        this.id = id;
        this.message = message;
    }

    ///
    ErrorMessage opCall(string message) {
        return ErrorMessage(id, message);
    }

    ///
    bool opEquals(scope const ErrorMessage other) const scope {
        return this.id == other.id;
    }

    ///
    size_t toHash() const scope @trusted {
        import sidero.base.hash.fnv;

        uint ret = fnv_32_1a(cast(ubyte[])id);
        return fnv_32_1a(cast(ubyte[])message, ret);
    }
}

///
struct ErrorInfo {
    ///
    ErrorMessage info;

    ///
    string moduleName;
    ///
    int line;
    package(sidero.base.errors) bool checked;

export scope @safe nothrow @nogc:

    ///
    this(ErrorMessage errorMessage, string moduleName = __MODULE__, int line = __LINE__) {
        this.info = errorMessage;
        this.moduleName = moduleName;
        this.line = line;
    }

    ///
    bool isSet() const {
        return info.id.length > 0;
    }

    ///
    auto toString() const {
        import sidero.base.text;

        StringBuilder_UTF8 ret;
        this.toString(ret);
        return ret.asReadOnly();
    }

    ///
    void toString(S)(scope ref S sink) const {
        import sidero.base.text.format;

        sink.formattedWrite!"Error at %s:%d %s:%s"(this.moduleName, this.line, this.info.id, this.info.message);
    }

pure:

    ///
    bool opEquals(scope const ErrorMessage other) const {
        return this.info == other;
    }

    ///
    size_t toHash() const scope @trusted {
        import sidero.base.hash.fnv;

        return fnv_32_1a(cast(ubyte[])moduleName, cast(uint)info.toHash());
    }
}
