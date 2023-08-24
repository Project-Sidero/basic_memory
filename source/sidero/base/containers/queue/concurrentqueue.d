module sidero.base.containers.queue.concurrentqueue;
import sidero.base.allocators;
import sidero.base.synchronization.mutualexclusion;
import sidero.base.errors;

///
alias FiFoConcurrentQueue(Type) = ConcurrentQueue!(Type, true);
///
alias LiFoConcurrentQueue(Type) = ConcurrentQueue!(Type, false);

///
struct ConcurrentQueue(Type, bool FiFo) {
    private {
        import sidero.base.internal.atomic;

        State!Type* state;
    }

export @safe nothrow @nogc:

    ///
    this(RCAllocator allocator) scope @trusted {
        if(allocator.isNull)
            allocator = globalAllocator();

        this.state = allocator.make!(State!Type);
        this.state.allocator = allocator;
    }

    ///
    this(return scope ref ConcurrentQueue other) scope {
        this.state = other.state;

        if(this.state !is null) {
            atomicIncrementAndLoad(state.refCount, 1);
        }
    }

    ///
    ~this() scope @trusted {
        if(this.state !is null && atomicDecrementAndLoad(state.refCount, 1) == 0) {
            RCAllocator allocator = state.allocator;
            state.clear;
            allocator.dispose(state);
        }
    }

    ///
    bool isNull() scope const {
        return state is null;
    }

    ///
    bool empty() scope {
        if(isNull)
            return true;

        state.mutex.pureLock;
        scope(exit)
            state.mutex.unlock;

        return state.head is null;
    }

    ///
    void clear() scope {
        if(isNull)
            return;

        state.mutex.pureLock;
        state.clear;
        state.mutex.unlock;
    }

    ///
    size_t count() scope {
        if(isNull)
            return 0;

        state.mutex.pureLock;
        scope(exit)
            state.mutex.unlock;

        return state.count;
    }

    ///
    void push(scope return Type value) scope @trusted {
        checkInit;

        state.mutex.pureLock;
        state.push(value);
        state.mutex.unlock;
    }

    ///
    Result!Type pop(bool fiFo = FiFo) return scope {
        if(isNull)
            return typeof(return)(NullPointerException);

        state.mutex.pureLock;
        scope(exit)
            state.mutex.unlock;

        if(state.head is null)
            return typeof(return)(RangeException("Nothing to pop off of stack"));

        auto temp = state.pop(fiFo);
        return Result!Type(temp);
    }

    ///
    Result!Type peek(bool fiFo = FiFo) return scope {
        if(isNull)
            return typeof(return)(NullPointerException);

        state.mutex.pureLock;
        scope(exit)
        state.mutex.unlock;

        if(state.head is null)
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
        if(this.state < other.state)
            return -1;
        else if(this.state > other.state)
            return 1;
        else
            return 0;
    }

private:

    void checkInit() scope @trusted {
        if(!isNull)
            return;

        RCAllocator allocator = globalAllocator();
        this.state = allocator.make!(State!Type);
        this.state.allocator = allocator;
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
    shared(ptrdiff_t) refCount = 1;
    RCAllocator allocator;

    TestTestSetLockInline mutex;

    Node* head, tail;
    size_t count;

export @safe nothrow @nogc:

    void clear() scope @trusted {
        while(head !is null) {
            Node* current = head;
            head = current.next;

            allocator.dispose(current);
        }

        tail = null;
    }

    void push(return scope Type value) scope @trusted {
        head = allocator.make!Node(null, head);
        head.value = value;

        if(tail is null)
            tail = head;
        else if(head.next !is null)
            head.next.previous = head;

        count++;
    }

    Type pop(bool fiFo) return scope @trusted {
        Type ret;

        if(fiFo) {
            ret = tail.value;

            Node* toDeallocate = tail;
            tail = tail.previous;

            if(tail !is null)
                tail.next = null;
            else
                head = null;

            allocator.dispose(toDeallocate);
        } else {
            ret = head.value;

            Node* toDeallocate = head;
            head = head.next;

            if(head !is null)
                head.previous = null;
            else
                tail = null;

            allocator.dispose(toDeallocate);
        }

        count--;
        return ret;
    }

    Result!Type peek(bool fiFo) return scope @trusted {
        Type ret;

        if(fiFo) {
            ret = tail.value;
        } else {
            ret = head.value;
        }

        return typeof(return)(ret);
    }

    struct Node {
        Node* previous, next;
        Type value;
    }
}
