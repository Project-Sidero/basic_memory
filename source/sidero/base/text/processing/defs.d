module sidero.base.text.processing.defs;
import sidero.base.text;

///
struct Loc {
    ///
    String_UTF8 fileName;
    ///
    uint lineNumber;
    ///
    uint lineOffset;

export @safe nothrow @nogc:

    this(return scope ref Loc other) scope {
        this.tupleof = other.tupleof;
    }

    ~this() scope {
    }

    void opAssign(return scope Loc other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    ulong toHash() scope const {
        import sidero.base.hash.utils : hashOf;

        ulong ret = hashOf();
        ret = hashOf(fileName, ret);
        ret = hashOf(lineNumber, ret);
        ret = hashOf(lineOffset, ret);

        return ret;
    }

    ///
    bool opEquals(scope ref Loc other) scope {
        return this.opCmp(other) == 0;
    }

    ///
    int opCmp(scope ref Loc other) scope {
        import sidero.base.containers.utils;
        return genericCompare(this, other);
    }
}
