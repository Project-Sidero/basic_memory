/*
Garbage collector instance registration and control.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
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

    rwlock.pureWriteLock;
    scope (exit)
        rwlock.pureWriteUnlock;

    GCInfo* current = gcInfoLL;
    GCInfo** parent = &gcInfoLL;

    while (current !is null && cast(size_t)current.key < cast(size_t)key) {
        parent = &current.next;
        current = current.next;
    }

    if (current !is null && cast(size_t)current.key == cast(size_t)key) {
        // update, why? idk
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
    } else {
        void[] block = gcInfoAllocator.allocate(GCInfo.sizeof);
        assert(block.length == GCInfo.sizeof);
        GCInfo* newNode = cast(GCInfo*)block.ptr;

        newNode.next = current;
        newNode.key = key;
        newNode.enable = enable;
        newNode.disable = disable;
        newNode.collect = collect;
        newNode.minimize = minimize;
        newNode.addRange = addRange;
        newNode.removeRange = removeRange;
        newNode.runFinalizers = runFinalizers;
        newNode.inFinalizer = inFinalizer;

        *parent = newNode;
    }
}

///
void deregisterGC(scope void* key) nothrow {
    rwlock.pureWriteLock;
    scope (exit)
        rwlock.pureWriteUnlock;

    GCInfo* current = gcInfoLL;
    GCInfo** parent = &gcInfoLL;

    while (current !is null && cast(size_t)current.key < cast(size_t)key) {
        parent = &current.next;
        current = current.next;
    }

    if (current !is null && cast(size_t)current.key == cast(size_t)key) {
        *parent = current.next;
        gcInfoAllocator.deallocate((cast(void*)current)[0 .. GCInfo.sizeof]);
    }
}

package(sidero.base.allocators) {
    void readLockImpl() @trusted pure @nogc nothrow {
        static void handle() @trusted {
            rwlock.pureReadLock;
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
            rwlock.pureWriteLock;
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void writeUnlockImpl() @trusted pure @nogc nothrow {
        static void handle() @trusted {
            rwlock.pureWriteUnlock;
        }

        (cast(void function()@trusted pure nothrow @nogc)&handle)();
    }

    void addRangeImpl(scope void[] block, scope TypeInfo ti = null) @trusted pure @nogc nothrow {
        static void handle(scope void[] block, scope TypeInfo ti = null) @trusted {
            GCInfo* current = gcInfoLL;
            while (current !is null) {
                if (current.addRange !is null)
                    current.addRange(block.ptr, block.length, ti);
                current = current.next;
            }
        }

        (cast(void function(scope void[] block, scope TypeInfo ti = null)@trusted pure nothrow @nogc)&handle)(block, ti);
    }

    void removeRangeImpl(scope void[] block) @trusted pure @nogc nothrow {
        assert(block.ptr !is null);

        static void handle(scope void[] block) @trusted {
            GCInfo* current = gcInfoLL;
            while (current !is null) {
                if (current.removeRange !is null)
                    current.removeRange(block.ptr);
                current = current.next;
            }
        }

        (cast(void function(scope void[] block)@trusted pure nothrow @nogc)&handle)(block);
    }
}

private:
import sidero.base.allocators.predefined;
import sidero.base.synchronization.rwmutex;

__gshared {
    ReaderWriterLockInline rwlock;
    GCInfo* gcInfoLL;
    HouseKeepingAllocator!() gcInfoAllocator;
}

struct GCInfo {
    GCInfo* next;
    void* key;

    EnableFunction enable;
    DisableFunction disable;
    CollectFunction collect;
    MinimizeFunction minimize;
    AddRangeFunction addRange;
    RemoveRangeFunction removeRange;
    RunFinalizersFunction runFinalizers;
    InFinalizerFunction inFinalizer;
}
