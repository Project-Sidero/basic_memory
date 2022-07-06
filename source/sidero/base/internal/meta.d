module sidero.base.internal.meta;

// Generates opApply/opApplyReverse combinations and toString for opApply
mixin template OpApplyCombos(string ValueType, string KeyType = "size_t", string[] Attributes = [
    "@safe", "nothrow", "@nogc", "pure"
], string Name = "opApply", string ToCall = Name ~ "Impl") {
    mixin(() {
        string ret;
        ptrdiff_t safeOffset = -1;

        static if (KeyType.length > 0) {
            string[] attributes = KeyType ~ Attributes;
            ptrdiff_t withKeyOffset = 0;
        } else {
            string[] attributes = Attributes;
            ptrdiff_t withKeyOffset = -1;
        }

        bool[] active;
        active.length = attributes.length;

        foreach (i, ref attribute; attributes) {
            if (attribute == "@safe") {
                safeOffset = i;
                break;
            } else if (attribute == "@system") {
                attribute = "@safe";
                safeOffset = i;
                break;
            }
        }

        void handle(size_t depth) {
            if (depth == attributes.length) {
                ret ~= "int " ~ Name ~ "(";

                ret ~= "scope int delegate(";

                if (withKeyOffset >= 0 && active[withKeyOffset])
                    ret ~= KeyType ~ ", ";
                ret ~= ValueType ~ ")";

                foreach (i, attribute; attributes) {
                    if (withKeyOffset == i)
                        continue;
                    else if (active[i])
                        ret ~= " " ~ attribute;
                    else if (i == safeOffset)
                            ret ~= " @system";
                }

                ret ~= " del) scope";

                foreach (i, attribute; attributes) {
                    if (withKeyOffset == i)
                        continue;
                    else if (active[i])
                        ret ~= " " ~ attribute;
                    else if (i == safeOffset)
                            ret ~= " @system";
                }

                ret ~= " {\nreturn " ~ ToCall ~ "(del);\n}\n";

                if (Name == "opApply" && (withKeyOffset < 0 || active[withKeyOffset] == false)) {
                    ret ~= "void toString(scope void delegate(";
                    ret ~= ValueType ~ ")";

                    foreach (i, attribute; attributes) {
                        if (withKeyOffset == i)
                            continue;
                        else if (active[i])
                            ret ~= " " ~ attribute;
                        else if (i == safeOffset)
                                ret ~= " @system";
                    }

                    ret ~= " sink)";

                    foreach (i, attribute; attributes) {
                        if (withKeyOffset == i)
                            continue;
                        else if (active[i])
                            ret ~= " " ~ attribute;
                        else if (i == safeOffset)
                                ret ~= " @system";
                    }

                    ret ~= " {\nforeach(v; this) sink(v);\n}\n";
                }
            } else {
                active[depth] = false;
                handle(depth + 1);
                active[depth] = true;
                handle(depth + 1);
            }
        }

        handle(0);

        return ret;
    }());
}
