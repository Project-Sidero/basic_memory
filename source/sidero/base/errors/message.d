module sidero.base.errors.message;

///
struct ErrorMessage {
    ///
    string id;
    ///
    string message;

@safe nothrow @nogc pure:

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

@safe nothrow @nogc pure:

    // TODO once we have a string builder and formatting.
    version (none) {
        ///
        RCStringZ toString() const {
            RCStringZ ret;
            this.toString(ret);
            return ret;
        }

        ///
        void toString(S)(scope ref S sink) const {
            import bc.string.format;

            sink.nogcFormatTo!"Error at %s:%d %s:%s"(this.moduleName, this.line, this.info.id, this.info.message);
        }
    }

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
