module sidero.base.text.ascii.characters;
@safe nothrow @nogc pure:

///
ubyte toUpper(ubyte input) {
    enum aToA = 'a' - 'A';
    if (input >= 'a' && input <= 'z')
        return cast(ubyte)(input - aToA);
    return input;
}

///
unittest {
    assert('w'.toUpper == 'W');
    assert('0'.toUpper == '0');
}

///
ubyte toLower(ubyte input) {
    enum aToA = 'a' - 'A';
    if (input >= 'A' && input <= 'Z')
        return cast(ubyte)(input + aToA);
    return input;
}

///
unittest {
    assert('W'.toLower == 'w');
    assert('0'.toLower == '0');
}

///
bool isAlpha(ubyte input) {
    return (input >= 'A' && input <= 'Z') || (input >= 'a' && input <= 'z');
}

///
bool isUpper(ubyte input) {
    return input >= 'A' && input <= 'Z';
}

///
bool isLower(ubyte input) {
    return input >= 'a' && input <= 'z';
}

///
bool isNumeric(ubyte input) {
    return input >= '0' && input <= '9';
}

///
bool isAlphaNumeric(ubyte input) {
    return input.isAlpha || input.isNumeric;
}

///
bool isControl(ubyte input) {
    return input < ' ' || input == 0x7F;
}

///
bool isGraphical(ubyte input) {
    return !input.isControl || input > 127;
}

///
bool isWhiteSpace(ubyte input) {
    return (input >= '\t' && input <= '\r') || input == ' ';
}

///
unittest {
    assert(' '.isWhiteSpace);
    assert('\t'.isWhiteSpace);
    assert('\n'.isWhiteSpace);
    assert('\r'.isWhiteSpace);
    assert('\f'.isWhiteSpace);
    assert('\v'.isWhiteSpace);

    assert(!'a'.isWhiteSpace);
    assert(!'!'.isWhiteSpace);
    assert(!'\0'.isWhiteSpace);
}
