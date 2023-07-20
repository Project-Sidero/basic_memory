module sidero.base.errors.expected;
import sidero.base.attributes;

/// A kind of error handling that requires a specific number of something to be handled for complete success.
@mustuse struct Expected {
    private @hidden {
        size_t acquired, wanted_;
    }

export @safe nothrow @nogc:

    ///
    this(size_t wanted, size_t amount) scope {
        this.acquired = amount;
        this.wanted_ = wanted;
    }

    ///
    this(scope ref Expected other) scope {
        this.acquired = other.acquired;
    }

    size_t wanted() scope const {
        return wanted_;
    }

    ///
    bool opCast(T : bool)() scope const {
        return this.acquired == wanted_;
    }

    ///
    size_t get() scope const {
        return this.acquired;
    }
}
