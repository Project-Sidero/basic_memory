module sidero.base.containers.queue.concurrentqueue;
import sidero.base.allocators;
import sidero.base.synchronization.system.lock;
import sidero.base.errors;

///
alias FiFoConcurrentQueue(Type) = ConcurrentQueue!(Type, true);
///
alias LiFoConcurrentQueue(Type) = ConcurrentQueue!(Type, false);

///
struct ConcurrentQueue(Type, bool FiFo) {
    private {
        import sidero.base.internal.atomic;
        import sidero.base.internal.logassert;

        State!Type* state;
    }

export @safe nothrow @nogc:

    ///
    this(RCAllocator allocator) scope @trusted {
        if (allocator.isNull)
            allocator = globalAllocator();

        this.state = allocator.make!(State!Type)(1);
        this.state.allocator = allocator;
    }

    ///
    this(return scope ref ConcurrentQueue other) scope {
        this.state = other.state;

        if (this.state !is null)
            atomicIncrementAndLoad(state.refCount, 1);
    }

    ///
    ~this() scope @trusted {
        if (this.state !is null && atomicDecrementAndLoad(state.refCount, 1) == 0) {
            RCAllocator allocator = state.allocator;
            state.clear;
            allocator.dispose(state);
        }
    }

    void opAssign(return scope ConcurrentQueue other) scope {
        this.destroy;
        this.__ctor(other);
    }

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    bool empty() scope {
        if (isNull)
            return true;

        auto err = state.mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            state.mutex.unlock;

        return state.head is null;
    }

    ///
    void clear() scope {
        if (isNull)
            return;

        auto err = state.mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        state.clear;
        state.mutex.unlock;
    }

    ///
    size_t count() scope {
        if (isNull)
            return 0;

        auto err = state.mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            state.mutex.unlock;

        return state.count;
    }

    ///
    void push(scope return Type value, bool fiFo = FiFo) scope @trusted {
        checkInit;

        auto err = state.mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        state.push(fiFo, value);
        state.mutex.unlock;
    }

    ///
    Result!Type pop(bool fiFo = FiFo) return scope {
        if (isNull)
            return typeof(return)(NullPointerException);

        auto err = state.mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            state.mutex.unlock;

        if (state.head is null)
            return typeof(return)(RangeException("Nothing to pop off of stack"));

        auto temp = state.pop(fiFo);
        auto ret = Result!Type(temp);
        return ret;
    }

    ///
    Result!Type peek(bool fiFo = FiFo) return scope {
        if (isNull)
            return typeof(return)(NullPointerException);

        auto err = state.mutex.lock;
        logAssert(cast(bool)err, "Failed to lock", err.getError());
        scope (exit)
            state.mutex.unlock;

        if (state.head is null)
            return typeof(return)(RangeException("Nothing to pop off of stack"));

        auto temp = state.peek(fiFo);
        return temp;
    }

    @disable auto opCast(T)();

    ///
    ulong toHash() scope const @trusted {
        return cast(ulong)this.state;
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope ConcurrentQueue other) scope const {
        return this.opCmp(other) == 0;
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope ConcurrentQueue other) scope const @trusted {
        if (this.state < other.state)
            return -1;
        else if (this.state > other.state)
            return 1;
        else
            return 0;
    }

    version (none) {
        void debugMe() scope {
            import sidero.base.console;

            if (isNull)
                writeln("Queue is null");
            else
                this.state.debugMe();
        }
    }

private:

    void checkInit() scope @trusted {
        if (!isNull)
            return;

        RCAllocator allocator = globalAllocator();
        this.state = allocator.make!(State!Type)(1);
        this.state.allocator = allocator;
        atomicStore(this.state.refCount, 1);
    }
}

///
unittest {
    FiFoConcurrentQueue!int queue;
    assert(queue.isNull);
    assert(queue.empty);
    assert(queue.count == 0);

    queue.push(1);
    assert(!queue.empty);
    assert(queue.count == 1);

    queue.push(2);
    queue.push(3);
    assert(queue.count == 3);

    auto value = queue.pop;
    assert(value);
    assert(value == 1);

    value = queue.pop(false);
    assert(value);
    assert(value == 3);

    value = queue.pop;
    assert(value);
    assert(value == 2);

    value = queue.pop;
    assert(!value);

    assert(queue.empty);
    assert(queue.count == 0);
}

private:

struct State(Type) {
    shared(ptrdiff_t) refCount;
    RCAllocator allocator;

    SystemLock mutex;

    Node* head, tail;
    size_t count;

export @safe nothrow @nogc:

    void debugMe() {
        import sidero.base.console;

        Node* node = head;

        writeln("\\/");

        while (node !is null) {

            debugWriteln(node.value);

            node = node.next;
        }

        writeln("/\\");
    }

    void clear() scope @trusted {
        while (head !is null) {
            Node* current = head;
            head = current.next;

            allocator.dispose(current);
        }

        tail = null;
    }

    void push(bool fiFo, return scope Type value) scope @trusted {
        Node* node;

        if (fiFo) {
            node = allocator.make!Node(null, head, value);
            head = node;

            if (tail is null)
                tail = head;
            else if (head.next !is null)
                head.next.previous = head;
        } else {
            node = allocator.make!Node(tail, null, value);
            tail = node;

            if (head is null)
                head = tail;
            else if (tail.previous !is null)
                tail.previous.next = tail;
        }

        count++;
    }

    Type pop(bool fiFo) return scope @trusted {
        Type ret;

        if (fiFo) {
            ret = tail.value;

            Node* toDeallocate = tail;
            tail = tail.previous;

            if (tail !is null)
                tail.next = null;
            else
                head = null;

            allocator.dispose(toDeallocate);
        } else {
            ret = head.value;

            Node* toDeallocate = head;
            head = head.next;

            if (head !is null)
                head.previous = null;
            else
                tail = null;

            allocator.dispose(toDeallocate);
        }

        count--;
        return ret;
    }

    Result!Type peek(bool fiFo) return scope @trusted {
        Type res;

        if (fiFo) {
            res = tail.value;
        } else {
            res = head.value;
        }

        auto ret = typeof(return)(res);
        return ret;
    }

    struct Node {
        Node* previous, next;
        Type value;
    }
}
