module sidero.base.compression.huffman;
import sidero.base.errors;

private alias HMT = HuffManTree!300;

export @safe nothrow @nogc:

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

            // only for when building from data

            float cost;
            Node* nextUnresolved;
            size_t lowestValue, highestValue;
        }

        Node* allocateNode() scope return @trusted {
            pragma(inline, true);

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

    /// Given data create a huffman tree, returns the depth for a given leaf value
    ushort[NumberOfLeafs] buildFromData(MainType)(scope const(MainType)[] input) @trusted {
        return buildFromData!(MainType, MainType)(input);
    }

    /// Ditto
    ushort[NumberOfLeafs] buildFromData(MainType, SecondaryType)(scope const(MainType)[] input, scope const(SecondaryType)[] secondaryInput...) @trusted {
        clear;

        float[NumberOfLeafs] frequencies = void;
        const consumedFromInput = frequencyOfBytes(input, size_t.max, frequencies, secondaryInput);
        if (consumedFromInput == 0)
            return typeof(return).init;

        size_t numberUnresolved;
        Node* firstUnresolved;

        foreach (i, frequency; frequencies) {
            if (frequency < 0)
                continue;
            Node* node = &buffer[nextNodeOffset++];

            node.cost = frequency;
            node.value = i;
            node.lowestValue = i;
            node.highestValue = i;

            node.nextUnresolved = firstUnresolved;
            firstUnresolved = node;
            numberUnresolved++;
        }

        const originalNumberUnresolved = numberUnresolved;

        if (numberUnresolved == 1) {
            numberUnresolved = 0;
            Node* parent = allocateNode();

            parent.left = firstUnresolved;
            firstUnresolved = parent;
        } else {
            while (numberUnresolved > 1) {
                Node** currentPointer = &firstUnresolved;
                Node* lowest1, lowest2;

                while (currentPointer !is null && *currentPointer !is null) {
                    Node* self = *currentPointer, replaces;

                    if (lowest1 is null) {
                        replaces = lowest1;
                        lowest1 = self;
                        goto Consumed;
                    } else if (lowest2 is null) {
                        replaces = lowest2;
                        lowest2 = self;
                        goto Consumed;
                    }

                    if (lowest1.cost > lowest2.cost && lowest1.cost > self.cost) {
                        replaces = lowest1;
                        lowest1 = self;
                        goto Consumed;
                    } else if (lowest2.cost > self.cost) {
                        replaces = lowest2;
                        lowest2 = self;
                        goto Consumed;
                    }

                    NotConsumed:
                    currentPointer = &self.nextUnresolved;
                    continue;

                    Consumed:
                    if (replaces !is null) {
                        replaces.nextUnresolved = self.nextUnresolved;
                        *currentPointer = replaces;
                    } else
                        *currentPointer = self.nextUnresolved;

                    self.nextUnresolved = null;
                    continue;
                }

                assert(lowest1 !is null);
                assert(lowest2 !is null);
                assert(lowest1 !is lowest2);

                numberUnresolved--;
                Node* parent = allocateNode();
                parent.cost = lowest1.cost + lowest2.cost;

                if (lowest2.cost < lowest1.cost) {
                    auto temp = lowest1;
                    lowest1 = lowest2;
                    lowest2 = temp;
                }

                if (lowest1.lowestValue < lowest2.lowestValue) {
                    parent.left = lowest1;
                    parent.right = lowest2;
                    parent.lowestValue = lowest1.lowestValue;
                    parent.highestValue = lowest2.highestValue;
                } else {
                    parent.left = lowest2;
                    parent.right = lowest1;
                    parent.lowestValue = lowest2.lowestValue;
                    parent.highestValue = lowest1.highestValue;
                }

                parent.nextUnresolved = firstUnresolved;
                firstUnresolved = parent;
            }
        }

        assert(nextNodeOffset > 0);
        root = firstUnresolved;

        void resolvePath(scope Node* parent, size_t numberOfBits, ushort path) {
            if (parent is null)
                return;

            if ((cast(size_t)parent.left | cast(size_t)parent.right) == 0) {
                parent.path = path;
                parent.numberOfBits = numberOfBits;
            } else {
                path <<= 1;
                resolvePath(parent.left, numberOfBits + 1, path | 0);
                resolvePath(parent.right, numberOfBits + 1, path | 1);
            }
        }

        resolvePath(root, 0, 0);

        ushort[NumberOfLeafs] ret;
        foreach (ref node; buffer[0 .. originalNumberUnresolved]) {
            ret[node.value] = cast(ushort)node.numberOfBits;
        }
        return ret;
    }

    /// Put your last bit at LSB@0 [0 .. 16] MSB@15
    void addLeafMSB(ushort path, size_t numberOfBits, size_t value) scope @trusted {
        const shiftMSBLeftToMax = 16 - numberOfBits;
        uint tempPath = path << shiftMSBLeftToMax;

        if (root is null)
            root = allocateNode();
        Node* parent = root;

        foreach (i; 0 .. numberOfBits) {
            const bit = (tempPath & 0x8000) > 0;
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
        foreach (i; 0 .. nextNodeOffset) {
            if (buffer[i].value == value) {
                path = buffer[i].path;
                numberOfBits = buffer[i].numberOfBits;
                return true;
            }
        }

        return false;
    }

    /// Get all paths & number of bits for each leaf
    ushort[2][NumberOfLeafs] pathForValues() scope const @trusted {
        ushort[2][NumberOfLeafs] ret = void;

        foreach (ref v; ret)
            v[1] = 0;

        foreach (ref node; buffer[0 .. nextNodeOffset]) {
            if ((cast(size_t)node.left | cast(size_t)node.right) == 0 && ret[node.value][1] == 0)
                ret[node.value] = [cast(ushort)node.path, cast(ushort)node.numberOfBits];
        }

        return ret;
    }

    ///
    Result!bool lookupValue(scope Result!bool delegate() @safe nothrow @nogc nextBit,
            scope bool delegate() @safe nothrow @nogc haveMoreBits, out size_t value) scope const @trusted {
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
                        ret.formattedWrite!"    N%X[label=\"%s | cost=%s | min=%s | max=%s\"];\n"(cast(size_t)&node,
                                node.value, node.cost, node.lowestValue, node.highestValue);
                    else {
                        ret.formattedWrite!"    N%X[label=\"cost=%s | min=%s | max=%s\"];\n"(cast(size_t)&node,
                                node.cost, node.lowestValue, node.highestValue);

                        if (node.left !is null)
                            ret.formattedWrite!"    N%X -> N%X[label=0];\n"(cast(size_t)&node, cast(size_t)node.left);
                        if (node.right !is null)
                            ret.formattedWrite!"    N%X -> N%X[label=1];\n"(cast(size_t)&node, cast(size_t)node.right);
                    }
                }

                ret ~= "}\n";
                return ret[];
            } else
                return null;
        }
    }
}

///
unittest {
    HuffManTree!4 tree;
    auto depths = tree.buildFromData([0, 0, 1, 2, 3, 3], [3]);
    assert(depths == [2, 3, 3, 1]);
}

///
unittest {
    HuffManTree!2 tree;
    auto depths = tree.buildFromData([0, 0, 0], [1]);
    assert(depths == [1, 1]);
}

///
unittest {
    HuffManTree!1 tree;
    auto depths = tree.buildFromData([0, 0, 0], cast(int[])[]);
    assert(depths == [1]);
}

private:

size_t frequencyOfBytes(MainType, SecondaryType, size_t NumberOfPossibleValues)(scope const(MainType)[] input,
        size_t limitUniques, ref float[NumberOfPossibleValues] frequencies, scope const(SecondaryType)[] secondaryInput...) {
    import sidero.base.math.utils : isClose;

    size_t currentUniques, consumed;

    foreach (ref v; frequencies)
        v = 0;

    foreach (v; input) {
        if (frequencies[v] == 0) {
            if (limitUniques == currentUniques)
                break;
            else
                currentUniques++;
        }

        frequencies[v] += 1;
        consumed++;
    }

    foreach (v; secondaryInput) {
        if (frequencies[v] == 0) {
            if (limitUniques == currentUniques)
                break;
            else
                currentUniques++;
        }

        frequencies[v] += 1;
        consumed++;
    }

    {
        float minimum = cast(float)size_t.max;

        foreach (ref v; frequencies) {
            if (isClose(v, 0))
                v = -1;
            else if (v < minimum)
                minimum = v;
        }

        frequencies[] /= minimum;
    }

    return consumed;
}
