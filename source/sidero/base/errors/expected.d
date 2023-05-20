module sidero.base.errors.expected;
import sidero.base.attributes;

/// A kind of error handling that requires a specific number of something to be handled for complete success.
@mustuse struct Expected(size_t Wanted) {
    private @hidden {
        size_t acquired;
    }

    export @safe nothrow @nogc const:

    ///
    this(size_t amount) {
        this.acquired = amount;
    }

    ///
    this(scope ref Expected!Wanted other) {
        this.acquired = other;
    }

    ///
    bool opCast(T:bool)() {
        return this.acquired == Wanted;
    }

    ///
    size_t got() {
        return this.acquired;
    }
}
