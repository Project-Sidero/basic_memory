module sidero.base.text.regex.matching;
import sidero.base.text.regex.internal.state_match;
import sidero.base.text.regex.pattern;
import sidero.base.text;
import sidero.base.containers.dynamicarray;

///
struct MatchValue {
    /// Warning: that the full input is in normal form D not C, it may not be where you expect!
    size_t byteOffsetFromStartOfInput;
    ///
    String_UTF8 text;

export @safe nothrow @nogc:
    this(return scope ref MatchValue other) scope {
        this.tupleof = other.tupleof;
    }

    ~this() scope {
    }

    void opAssign(return scope MatchValue other) scope {
        this.__ctor(other);
    }
}

///
struct Match {
    package(sidero.base.text.regex) {
        MatchState* matchState;
    }

export @safe nothrow @nogc:

    ///
    bool isNull() {
        return matchState is null;
    }

    ///
    bool opCast(T : bool)() {
        return matchState !is null && matchState.span.text.length > 0;
    }

    ///
    Regex regex() {
        if(isNull)
            return Regex.init;

        Regex ret;
        ret.state = matchState.regexState;
        ret.state.rc(true);
        return ret;
    }

    ///
    MatchValue inputForMatches() {
        if(isNull)
            return MatchValue.init;
        else
            return matchState.all;
    }

    ///
    MatchValue before() {
        if(isNull)
            return MatchValue.init;
        else
            return matchState.before;
    }

    ///
    MatchValue span() {
        if(isNull)
            return MatchValue.init;
        else
            return matchState.span;
    }

    ///
    MatchValue after() {
        if(isNull)
            return MatchValue.init;
        else
            return matchState.after;
    }

    ///
    DynamicArray!MatchValue groups() {
        if(isNull)
            return DynamicArray!MatchValue.init;
        else
            return matchState.groups;
    }

    ///
    Match next() {
        import sidero.base.text.regex.internal.strategies.defs;

        if(isNull)
            return Match.init;

        if(matchState.next is null)
            matchState.next = processNextMatch(matchState.regexState, matchState, String_UTF8.init);

        if(matchState.next is &failedToMatchState)
            return Match.init;

        Match match;
        match.matchState = matchState.next;
        match.matchState.rc(true);
        return match;
    }
}
