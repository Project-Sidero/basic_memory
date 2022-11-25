/**
 */
module sidero.base.text.wordbreak;
export @safe nothrow @nogc:

/// This struct works with a word breaking algorithm i.e. Unicode's TR29, expecting Function to return ptrdiff_t with no args apart from us.
struct WordBreaker(Char, alias Function) {
export:
    @disable this(this);

    ///
    Entry delegate() @safe nothrow @nogc nextDel, peekDel;
    ///
    bool delegate() @safe nothrow @nogc haveValueDel;

    ///
    size_t length, capacity;

@safe @nogc nothrow:

    ///
    ptrdiff_t perform() {
        return Function(this);
    }

    ///
    size_t findDecentSplitWithWordBreaksLast() {
        size_t previous, current;

        while (current < length && current < capacity) {
            previous = current;
            const toBreak = findDecentSplitWithWordBreaks();

            if (toBreak == 0)
                break;

            current += toBreak;
        }

        return previous > 0 ? previous : current;
    }

    ///
    size_t findDecentSplitWithWordBreaks() {
        ptrdiff_t lastBreak, currentBreak;

        while ((currentBreak = perform()) > 0) {
            currentBreak += lastBreak + peekDel().entriesForValue;

            if (currentBreak >= capacity) {
                return lastBreak > 0 ? lastBreak : (length > capacity ? 0 : length);
            }

            lastBreak = currentBreak;
        }

        return currentBreak > 0 ? currentBreak : (lastBreak > 0 ? lastBreak : length);
    }

    ///
    static struct Entry {
        ///
        size_t entriesForValue;
        ///
        Char value = Char.max;

        ///
        bool opEquals(Char value) const @safe nothrow @nogc pure {
            return this.value == value;
        }

        ///
        bool opEquals(const Entry other) const @safe nothrow @nogc pure {
            return this.tupleof == other.tupleof;
        }
    }
}
