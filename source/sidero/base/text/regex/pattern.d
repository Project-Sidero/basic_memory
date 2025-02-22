module sidero.base.text.regex.pattern;
import sidero.base.text.regex.internal.state;
import sidero.base.text.regex.matching;
import sidero.base.text;
import sidero.base.allocators;

///
struct RegexMode {
    /**
    Mode: `s`
    '.' matches new line.
    */
    bool asSingleLine;
    /**
    Mode: `m`
    '^' is after a new line or at start of input.
    '$' is before a new line or end of input.
    */
    bool multiline;
    /**
    Mode: `A`
    Disables `before` value of each match.
    */
    bool anchored;
}

/**
Limits a regex match

The defaults are configured for a multiprocessor environment where you do not want to use an unbounded amount of ram,
 for user provided patterns.
*/
struct RegexLimiter {
    // TODO: Duration

    /// Limit the positions that can be stored, defaults to 1024 which works out at 16kb of ram
    uint positions = 1024;

    /// Limit the instances of terms that can be stored, defaults to 512, which works out at 32kb of ram.
    uint terms = 512;
}

/*
Sequence:
    '^'|opt ItemMinMax* '$'|opt

ItemMinMax:
    Item '?'
    Item '*'
    Item '+'
    Item '{' Number ',' Number '}'
    Item '{' Number ','|opt '}'

Item:
    Group
    CharacterClass
    SourceCharacter
    Escape
    EscapeLookBack
    '.'
    Item '|' Item

Group:
    '(' '?' '#' Sequence ')'
    '(' '?' '>' Sequence ')'
    '(' '?' '<' Sequence ')'
    '(' '?' '!' '>' Sequence ')'
    '(' '?' '!' '<' Sequence ')'
    '(' '?' Sequence ')'
    '(' Sequence ')'

CharacterClass:
    '[' '^'|opt CharacterClassItem* ']'

CharacterClassItem:
    SourceCharacter '-' SourceCharacter
    Escape
    SourceCharacter
    CharacterClassRelation '[' '^'|opt CharacterClassItem* ']'

|| union_                  union: A∪B (explicit operator where desired for clarity)
&& intersect               intersection: A∩B
-- difference              set difference: A∖B
~~ symmetricDifference     symmetric difference: A⊖B = (A∪B)\(A∩B)

CharacterClassRelation:
    "||"
    "&&"
    "--"
    "~~"

Escape strings ala \q{...} are not supported
Escape:
    '\' EscapeERE
    '\' EscapeASCII
    '\' EscapeCodePoint
    '\' EscapeProperty
    '\' EscapeBoundary

EscapeLookBack:
    '\' Number

EscapeERE:
    '^'
    '.'
    '['
    '$'
    '('
    ')'
    '|'
    '*'
    '+'
    '?'
    '{'
    '\'

EscapeASCII:
    ']'
    'n'
    'r'
    't'
    'v'
    'a'
    'b'
    'f'
    '0'
    '\''
    '"'
    '-'

EscapeCodePoint:
    'x' HexDigit HexDigit
    'u' HexDigit HexDigit HexDigit HexDigit
    'U' HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit HexDigit

TODO: EscapeProperty:
    P '{' SourceCharacter+ EscapePropertyValue|opt '}'              not in set
    p '{' SourceCharacter+ EscapePropertyValue|opt '}'              in set

TODO: EscapePropertyValue:
    '=' SourceCharacter+
    "≠" SourceCharacter+
    "!=" SourceCharacter+

TODO: EscapeBoundary:
    'b' '{' 'g' '}'
    'b' '{' 'w' '}'
    'b' '{' 'l' '}'
    'b' '{' 's' '}'
*/

///
struct Regex {
    package(sidero.base.text.regex) {
        RegexState* state;
    }

export @safe nothrow @nogc:

    this(ref Regex other) {
        this.state = other.state;

        if(state !is null)
            state.rc(true);
    }

    ~this() {
        if(state !is null)
            state.rc(false);
    }

    ///
    bool isNull() const {
        return state is null;
    }

    String_UTF8 pattern() {
        if(isNull)
            return String_UTF8.init;
        else
            return state.pattern;
    }

    ///
    Match matchFirst(String_UTF8 against) {
        import sidero.base.text.regex.internal.strategies.defs;
        import sidero.base.text.regex.internal.state_match;

        if(isNull)
            return typeof(return).init;

        MatchState* ms = processNextMatch(state, null, against);
        return Match(ms);
    }

    ///
    static Regex from(String_UTF8 text, RegexMode mode = RegexMode(), RegexLimiter limiter = RegexLimiter()) {
        return Regex.from(ErrorSinkRef.init, text, mode, limiter);
    }

    ///
    static Regex from(ErrorSinkRef errorSink, String_UTF8 text, RegexMode mode = RegexMode(), RegexLimiter limiter = RegexLimiter()) {
        import sidero.base.text.regex.internal.parser;

        if(errorSink.isNull)
            errorSink = ErrorSinkRef.make;
        assert(!errorSink.isNull);

        RCAllocator allocator = globalAllocator();

        Regex ret;
        ret.state = allocator.make!RegexState;
        ret.state.allocator = allocator;
        ret.state.rc(true);

        ret.state.pattern = text;
        ret.state.limiter = limiter;
        ret.state.head = parse(text, ret.state, mode, errorSink);

        if(errorSink.haveError)
            return Regex.init;
        return ret;
    }
}
