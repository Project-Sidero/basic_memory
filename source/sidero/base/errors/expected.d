module sidero.base.errors.expected;
import sidero.base.attributes;

/// A kind of error handling that requires a specific number of something to be handled for complete success.
@mustuse struct Expected(size_t Wanted) if (Wanted > 0) {
    private @hidden {
        size_t acquired;
    }

export @safe nothrow @nogc:

    ///
    this(size_t amount) scope {
        this.acquired = amount;
    }

    ///
    this(scope ref Expected other) scope {
        this.acquired = other.acquired;
    }

    ///
    bool opCast(T : bool)() scope const {
        return this.acquired == Wanted;
    }

    ///
    size_t get() scope const {
        return this.acquired;
    }
}
