// License: Boost
module sidero.base.allocators.gc_hook;
import sidero.base.allocators.gc;

version (D_BetterC) {
} else {
    import core.memory : GC;

    private __gshared int globalGCKey;

    pragma(crt_constructor) extern (C) void register_sidero_gc_register() {
        registerGC(&globalGCKey, &GC.enable, &GC.disable, &GC.collect, &GC.minimize, &GC.addRange,
                &GC.removeRange, &GC.runFinalizers, &GC.inFinalizer);
    }

    pragma(crt_destructor) extern (C) void register_sidero_gc_deregister() {
        deregisterGC(&globalGCKey);
    }
}
