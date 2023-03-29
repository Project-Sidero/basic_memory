module sidero.base.compression.internal.hashchain;
import sidero.base.allocators;
import sidero.base.allocators.predefined;

struct HashChain {
    size_t modulas, maxLayers, maxInLayer, minMatchSize, maxMatchSize;
    Layer* headLayer;
    size_t numberOfLayers;

    static struct Layer {
        Layer* next;
        Node*[] chains;
        MemoryRegionsAllocator!() allocator;
        size_t numberOfNodes;
    }

    static struct Node {
        Node* next;
        const(ubyte)[] data;
        size_t offset;
    }

    @disable this(this);

@safe nothrow @nogc scope:

    this(size_t modulas, size_t maxLayers, size_t maxInLayer, size_t minMatchSize, size_t maxMatchSize, RCAllocator allocator) {
        if (modulas == 0)
            modulas = 64;
        if (maxLayers == 0)
            maxLayers = 1;
        if (maxInLayer == 0)
            maxInLayer = size_t.max;

        this.modulas = modulas;
        this.maxLayers = maxLayers;
        this.maxInLayer = maxInLayer;
        this.minMatchSize = minMatchSize;
        this.maxMatchSize = maxMatchSize;
    }

    ~this() {
        if (headLayer !is null)
            clear;
    }

    void addLayer() @trusted {
        MemoryRegionsAllocator!() allocator;

        Layer* layer = allocator.make!Layer;
        layer.chains = allocator.makeArray!(Node*)(this.modulas);
        layer.allocator = allocator;

        layer.next = headLayer;
        headLayer = layer;

        numberOfLayers++;
        if (numberOfLayers >= maxLayers)
            clearOutLayers;
    }

    void addMatch(size_t offset, return scope const(ubyte)[] data) @trusted {
        if (data.length < this.minMatchSize)
            return;
        if (headLayer is null || headLayer.numberOfNodes == maxInLayer)
            addLayer;
        if (data.length > this.maxMatchSize)
            data = data[0 .. this.maxMatchSize];

        const keyHash = hashOf(cast(ubyte[3])data[0 .. 3]);
        Node** chain = &headLayer.chains[keyHash];

        Node* node = headLayer.allocator.make!Node;
        node.next = *chain;
        node.offset = offset;
        node.data = data;

        headLayer.numberOfNodes++;
        *chain = node;
    }

    bool findLongestMatch(scope const(ubyte)[] data, out size_t offset, out size_t length) @trusted {
        if (data.length < this.minMatchSize)
            return false;

        const keyHash = hashOf(cast(ubyte[3])data[0 .. 3]);

        if (data.length > this.maxMatchSize)
            data = data[0 .. this.maxMatchSize];

        ptrdiff_t longestOffset = -1;
        size_t longestMatch;

        Layer* currentLayer = headLayer;
        while(currentLayer !is null) {
            Node* currentNode = currentLayer.chains[keyHash];

            while(currentNode !is null) {
                const canDo = currentNode.data.length > data.length ? data.length : currentNode.data.length;
                size_t matched;

                foreach(i; 0 .. canDo) {
                    const b1 = data[i];
                    const b2 = currentNode.data[i];
                    if (b1 != b2)
                        break;
                    matched++;
                }

                if (matched > longestMatch) {
                    longestMatch = matched;
                    longestOffset = currentNode.offset;
                }

                currentNode = currentNode.next;
            }

            currentLayer = currentLayer.next;
        }

        offset = longestOffset;
        length = longestMatch;
        return longestOffset >= 0 && longestMatch >= this.minMatchSize;
    }

private:
    uint hashOf(ubyte[3] input) {
        return ((cast(uint)input[2] << 16) | (cast(uint)input[1] << 8) | (cast(uint)input[0])) % this.modulas;
    }

    void clear() @trusted {
        Layer* current = headLayer;

        while(current !is null) {
            Layer* next = current.next;

            auto allocator = current.allocator;
            allocator.deallocateAll;

            current = next;
        }

        headLayer = null;
        numberOfLayers = 0;
    }

    void clearOutLayers() @trusted {
        Layer** current = &headLayer;
        size_t layerId;

        while(*current !is null) {
            if (layerId++ >= this.maxLayers) {
                Layer* next = (*current).next;

                auto allocator = (*current).allocator;
                allocator.deallocateAll;
                numberOfLayers--;

                *current = next;
            } else {
                current = &(*current).next;
            }
        }
    }
}
