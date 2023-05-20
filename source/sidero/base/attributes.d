///
module sidero.base.attributes;
export:

version (LDC) {
    public import core.attribute : hidden;
} else {
    enum hidden;
}

public import core.attribute : mustuse;

/// Disables printing of field except for pretty printing.
struct PrintIgnore {
}

/// Disables printing of field for formattedWrite only.
struct PrettyPrintIgnore {
}
