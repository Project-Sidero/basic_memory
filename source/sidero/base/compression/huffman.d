module sidero.base.compression.huffman;
import sidero.base.errors;

private alias HMT = HuffManTree!300;

///
struct HuffManTree(size_t NumberOfLeafs) {
@safe nothrow @nogc:
    private {
        Node* root;
        Node[NumberOfLeafs + NumberOfLeafs + 1] buffer;
        size_t nextNodeOffset;

        static struct Node {
            Node* left, right;
            size_t value, numberOfBits;
            ushort path;
        }

        Node* allocateNode() scope return @trusted {
            assert(nextNodeOffset + 1 < buffer.length);
            auto ret = &buffer[nextNodeOffset++];

            ret.left = null;
            ret.right = null;
            debug ret.value = 0;

            return ret;
        }

        Node* transverseAddNode(return scope Node* parent, bool bit) scope @trusted {
            if (bit) {
                if (parent.right is null)
                    parent.right = allocateNode();
                return parent.right;
            } else {
                if (parent.left is null)
                    parent.left = allocateNode();
                return parent.left;
            }
        }
    }

export:

    @disable this(this);

    /// Put your last bit at LSB@0 [0 .. 16] MSB@15
    void addLeafMSB(ushort path, size_t numberOfBits, size_t value) scope @trusted {
        const shiftLeftToMax = 16 - numberOfBits;
        uint tempPath = path << shiftLeftToMax;

        if (root is null)
            root = allocateNode();
        Node* parent = root;

        foreach (i; 0 .. numberOfBits) {
            immutable bool bit = (tempPath & 0x8000) > 0;
            tempPath <<= 1;
            parent = transverseAddNode(parent, bit);
        }

        parent.value = value;
        parent.path = path;
        parent.numberOfBits = numberOfBits;
    }

    ///
    void clear() scope {
        nextNodeOffset = 0;
        root = null;
    }

    ///
    bool pathForValue(size_t value, out ushort path, out size_t numberOfBits) scope const {
        foreach(i; 0 .. nextNodeOffset) {
            if (buffer[i].value == value) {
                path = buffer[i].path;
                numberOfBits = buffer[i].numberOfBits;
                return true;
            }
        }

        return false;
    }

    ///
    Result!bool lookupValue(scope Result!bool delegate() @safe nothrow @nogc nextBit, scope bool delegate() @safe nothrow @nogc haveMoreBits,
            out size_t value) scope const @trusted {
        if (root is null)
            return typeof(return)(false);

        const(Node)* parent = root;

        while (haveMoreBits()) {
            auto bit = nextBit();
            if (!bit)
                return typeof(return)(bit.getError());

            if (bit.get)
                parent = parent.right;
            else
                parent = parent.left;

            if (parent is null)
                return typeof(return)(false);
            else if ((cast(size_t)parent.left | cast(size_t)parent.right) == 0) {
                value = parent.value;
                return typeof(return)(true);
            }
        }

        return typeof(return)(false);
    }

    @disable bool opEquals(scope const ref HuffManTree);

    @disable int opCmp(scope const ref HuffManTree);

    string toString() scope const @trusted {
        version (D_BetterC) {
            return null;
        } else {
            debug {
                import std.array : appender;
                import std.format : formattedWrite;

                auto ret = appender!string;
                ret ~= "digraph G {\n";

                foreach (i, ref node; buffer[0 .. nextNodeOffset]) {
                    if ((cast(size_t)node.left | cast(size_t)node.right) == 0)
                        ret.formattedWrite!"    N%X[label=\"%s\"];\n"(cast(size_t)&node, node.value);
                    else if (node.left !is null)
                        ret.formattedWrite!"    N%X -> N%X[label=0];\n"(cast(size_t)&node, cast(size_t)&node.left);
                    else if (node.right !is null)
                        ret.formattedWrite!"    N%X -> N%X[label=1];\n"(cast(size_t)&node, cast(size_t)&node.right);
                }

                ret ~= "}\n";
                return ret[];
            } else
                return null;
        }
    }
}
