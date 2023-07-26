module sidero.base.internal.meta;

// Generates opApply/opApplyReverse combinations and toString for opApply
mixin template OpApplyCombos(string ValueType__, string KeyType__ = "size_t", string[] Attributes = [
    "@safe", "nothrow", "@nogc", "pure"
], string Name = "opApply", string ToCall = Name ~ "Impl", bool isStatic = false) {
    enum Code = () {
        string ret;
        ptrdiff_t safeOffset = -1;

        static if(KeyType__.length > 0) {
            string[] attributes = KeyType__ ~ Attributes;
            ptrdiff_t withKeyOffset = 0;
        } else {
            string[] attributes = Attributes;
            ptrdiff_t withKeyOffset = -1;
        }

        bool[] active;
        active.length = attributes.length;

        foreach(i, ref attribute; attributes) {
            if(attribute == "@safe") {
                safeOffset = i;
                break;
            } else if(attribute == "@system") {
                attribute = "@safe";
                safeOffset = i;
                break;
            }
        }

        void handle(size_t depth) {
            if(depth == attributes.length) {
                ret ~= "int " ~ Name ~ "(";

                ret ~= "scope int delegate(";

                if(withKeyOffset >= 0 && active[withKeyOffset])
                    ret ~= "ref " ~ KeyType__ ~ ", ";

                ret ~= "ref ";
                ret ~= ValueType__ ~ ")";

                foreach(i, attribute; attributes) {
                    if(withKeyOffset == i)
                        continue;
                    else if(active[i])
                        ret ~= " " ~ attribute;
                    else if(i == safeOffset)
                        ret ~= " @system";
                }

                ret ~= " del)";

                if(!isStatic)
                    ret ~= " scope";

                foreach(i, attribute; attributes) {
                    if(withKeyOffset == i)
                        continue;
                    else if(active[i])
                        ret ~= " " ~ attribute;
                    else if(i == safeOffset)
                        ret ~= " @system";
                }

                ret ~= " {\nreturn " ~ ToCall ~ "(del);\n}\n";
            } else {
                active[depth] = false;
                handle(depth + 1);
                active[depth] = true;
                handle(depth + 1);
            }
        }

        handle(0);

        return ret;
    }();

    mixin(Code);
}

// Ditto except without any bodies
mixin template OpApplyComboInterfaces(string ValueType, string KeyType = "size_t", string[] Attributes = [
    "@safe", "nothrow", "@nogc", "pure"
], string Name = "opApply", string ToCall = Name ~ "Impl", bool isStatic = false) {
    enum Code = () {
        string ret;
        ptrdiff_t safeOffset = -1;

        static if(KeyType.length > 0) {
            string[] attributes = KeyType ~ Attributes;
            ptrdiff_t withKeyOffset = 0;
        } else {
            string[] attributes = Attributes;
            ptrdiff_t withKeyOffset = -1;
        }

        bool[] active;
        active.length = attributes.length;

        foreach(i, ref attribute; attributes) {
            if(attribute == "@safe") {
                safeOffset = i;
                break;
            } else if(attribute == "@system") {
                attribute = "@safe";
                safeOffset = i;
                break;
            }
        }

        void handle(size_t depth) {
            if(depth == attributes.length) {
                ret ~= "int " ~ Name ~ "(";

                ret ~= "scope int delegate(";

                if(withKeyOffset >= 0 && active[withKeyOffset])
                    ret ~= "ref " ~ KeyType ~ ", ";

                ret ~= "ref ";
                ret ~= ValueType ~ ")";

                foreach(i, attribute; attributes) {
                    if(withKeyOffset == i)
                        continue;
                    else if(active[i])
                        ret ~= " " ~ attribute;
                    else if(i == safeOffset)
                        ret ~= " @system";
                }

                ret ~= " del)";

                if(!isStatic)
                    ret ~= " scope";

                foreach(i, attribute; attributes) {
                    if(withKeyOffset == i)
                        continue;
                    else if(active[i])
                        ret ~= " " ~ attribute;
                    else if(i == safeOffset)
                        ret ~= " @system";
                }

                ret ~= ";\n";
            } else {
                active[depth] = false;
                handle(depth + 1);
                active[depth] = true;
                handle(depth + 1);
            }
        }

        handle(0);

        return ret;
    }();

    mixin(Code);
}
