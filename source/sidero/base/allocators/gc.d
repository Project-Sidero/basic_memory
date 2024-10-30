/*
Garbage collector instance registration and control.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.gc;
export:

///
alias EnableFunction = extern (C) void function() nothrow pure;
///
alias DisableFunction = extern (C) void function() nothrow pure;
///
alias CollectFunction = extern (C) void function() nothrow pure;
///
alias MinimizeFunction = extern (C) void function() nothrow pure;
///
alias AddRangeFunction = extern (C) void function(const void*, size_t, const TypeInfo ti = null) @nogc nothrow pure;
///
alias RemoveRangeFunction = extern (C) void function(const void*) nothrow @nogc pure;
///
alias RunFinalizersFunction = extern (C) void function(const scope void[]);
///
alias InFinalizerFunction = extern (C) bool function() nothrow @nogc @safe;

///
void enable() @trusted nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    GCInfo* current = gcInfoLL;
    while (current !is null) {
        if (current.enable !is null)
            current.enable();
        current = current.next;
    }
}

///
void disable() @trusted nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    GCInfo* current = gcInfoLL;
    while (current !is null) {
        if (current.disable !is null)
            current.disable();
        current = current.next;
    }
}

///
void addRange(scope void[] block, TypeInfo ti = null) pure @nogc nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    addRangeImpl(block, ti);
}

///
void removeRange(scope void[] block) pure @nogc nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    removeRangeImpl(block);
}

///
void collect() nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    GCInfo* current = gcInfoLL;
    while (current !is null) {
        if (current.collect !is null)
            current.collect();
        current = current.next;
    }
}

///
void minimize() nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    GCInfo* current = gcInfoLL;
    while (current !is null) {
        if (current.minimize !is null)
            current.minimize();
        current = current.next;
    }
}

///
void runFinalizers(const scope void[] block) {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    GCInfo* current = gcInfoLL;
    while (current !is null) {
        if (current.runFinalizers !is null)
            current.runFinalizers(block);
        current = current.next;
    }
}

///
bool inFinalizer() pure @nogc nothrow {
    readLockImpl;
    scope (exit)
        readUnlockImpl;

    static bool handle() @trusted {
        GCInfo* current = gcInfoLL;
        while (current !is null) {
            if (current.inFinalizer !is null && current.inFinalizer())
                return true;
            current = current.next;
        }

        return false;
    }

    return (cast(bool function()@trusted pure nothrow @nogc)&handle)();
}

///
void registerGC(scope void* key, EnableFunction enable, DisableFunction disable, CollectFunction collect, MinimizeFunction minimize,
        AddRangeFunction addRange, RemoveRangeFunction removeRange, RunFinalizersFunction runFinalizers, InFinalizerFunction inFinalizer) nothrow {

    rwlock.writeLock;
    scope (exit)
        rwlock.pureWriteUnlock;

    GCInfo* current = gcInfoLL;
    GCInfo** parent = &gcInfoLL;

    while (current !is null && cast(size_t)current.key < cast(size_t)key) {
        parent = &current.next;
        current = current.next;
    }

    if (current is null || cast(size_t)current.key != cast(size_t)key) {
        void[] block = gcInfoAllocator.allocate(GCInfo.sizeof);
        assert(block.length == GCInfo.sizeof);
        GCInfo* newNode = cast(GCInfo*)block.ptr;

        newNode.next = current;
        newNode.key = key;
        newNode.count = 0;

        current = newNode;
        *parent = current;
    }

    current.count++;

    if (current.enable is null)
        current.enable = enable;
    if (current.disable is null)
        current.disable = disable;
    if (current.collect is null)
        current.collect = collect;
    if (current.minimize is null)
        current.minimize = minimize;
    if (current.addRange is null)
        current.addRange = addRange;
    if (current.removeRange is null)
        current.removeRange = removeRange;
    if (current.runFinalizers is null)
        current.runFinalizers = runFinalizers;
    if (current.inFinalizer is null)
        current.inFinalizer = inFinalizer;
}

///
void deregisterGC(scope void* key) nothrow {
    rwlock.writeLock;
    scope (exit)
        rwlock.pureWriteUnlock;

    GCInfo* current = gcInfoLL;
    GCInfo** parent = &gcInfoLL;

    while (current !is null && cast(size_t)current.key < cast(size_t)key) {
        parent = &current.next;
        current = current.next;
    }

    if (current !is null && cast(size_t)current.key == cast(size_t)key) {
        current.count--;

        if (current.count == 0) {
            *parent = current.next;
            gcInfoAllocator.deallocate((cast(void*)current)[0 .. GCInfo.sizeof]);
        }
    }
}

package(sidero.base.allocators) {
    void readLockImpl() @trusted pure @nogc nothrow {
        static void handle() @trusted {
            rwlock.readLock;
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void readUnlockImpl() @trusted pure @nogc nothrow {
        static void handle() @trusted {
            rwlock.pureReadUnlock;
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void writeLockImpl() @trusted pure @nogc nothrow {
        static void handle() @trusted {
            rwlock.writeLock;
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void writeUnlockImpl() @trusted pure @nogc nothrow {
        static void handle() @trusted {
            rwlock.pureWriteUnlock;
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void enableImpl() @trusted pure @nogc nothrow {
        static void handle() {
            GCInfo* current = gcInfoLL;
            while (current !is null) {
                if (current.enable !is null)
                    current.enable();
                current = current.next;
            }
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void disableImpl() @trusted pure @nogc nothrow {
        static void handle() {
            GCInfo* current = gcInfoLL;
            while (current !is null) {
                if (current.disable !is null)
                    current.disable();
                current = current.next;
            }
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void addRangeImpl(scope void[] block, scope TypeInfo ti = null) @trusted pure @nogc nothrow {
        import core.stdc.stdio;
        assert(block.ptr !is null);
        assert(block.length > 0);

        static void handle(scope void[] block, scope TypeInfo ti = null) @trusted {
            //printf("add %p %iL\n", block.ptr, block.length);

            GCInfo* current = gcInfoLL;
            while (current !is null) {
                //printf("adding %p[[", current.key);
                //fflush(stdout);

                if (current.addRange !is null)
                    current.addRange(block.ptr, block.length, ti);
                current = current.next;

                //printf("]]\n");
                //fflush(stdout);
            }
        }

        (cast(void function(scope void[] block, scope TypeInfo ti = null)@trusted pure nothrow @nogc)&handle)(block, ti);
    }

    void removeRangeImpl(scope void[] block) @trusted pure @nogc nothrow {
        import core.stdc.stdio;
        assert(block.ptr !is null);

        static void handle(scope void[] block) @trusted {
            //printf("remove %p %iL\n", block.ptr, block.length);

            GCInfo* current = gcInfoLL;
            while (current !is null) {
                //printf("removeing %p[[", current.key);
                //fflush(stdout);

                if (current.removeRange !is null)
                    current.removeRange(block.ptr);
                current = current.next;

                //printf("]]\n");
                //fflush(stdout);
            }
        }

        (cast(void function(scope void[] block)@trusted pure nothrow @nogc)&handle)(block);
    }
}

private:
import sidero.base.allocators.predefined;
import sidero.base.synchronization.system.rwmutex;

__gshared {
    SystemReaderWriterLock rwlock;
    GCInfo* gcInfoLL;
    HouseKeepingAllocator!() gcInfoAllocator;
}

struct GCInfo {
    GCInfo* next;
    void* key;
    ptrdiff_t count;

    EnableFunction enable;
    DisableFunction disable;
    CollectFunction collect;
    MinimizeFunction minimize;
    AddRangeFunction addRange;
    RemoveRangeFunction removeRange;
    RunFinalizersFunction runFinalizers;
    InFinalizerFunction inFinalizer;
}
