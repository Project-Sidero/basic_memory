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
    void push(return scope Type value) scope {
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

        return state.pop(fiFo);
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

    queue.push(1);
    assert(!queue.empty);

    queue.push(2);
    queue.push(3);

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
}

private:

struct State(Type) {
    shared(ptrdiff_t) refCount = 1;
    RCAllocator allocator;

    TestTestSetLockInline mutex;

    Node* head, tail;
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
    }

    Result!Type pop(bool fiFo) return scope @trusted {
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

        return typeof(return)(ret);
    }

    struct Node {
        Node* previous, next;
        Type value;
    }
}
