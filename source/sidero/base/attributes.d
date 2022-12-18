///
module sidero.base.attributes;
export:

version (LDC) {
    public import core.attribute;
} else {
    enum hidden;
}

/// Disables printing of field
struct PrintIgnore {
}

/// Disables pretty printing of field
struct PrettyPrintIgnore {
}
