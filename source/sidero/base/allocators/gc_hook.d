// License: Boost
module sidero.base.allocators.gc_hook;
import sidero.base.allocators.gc;

version(D_BetterC) {
} else {
    import core.memory : GC;

    pragma(crt_constructor) extern (C) void register_sidero_gc_register() {
        registerGC(&GC.malloc, &GC.enable, &GC.disable, &GC.collect, &GC.minimize, &GC.addRange, &GC.removeRange,
                &GC.runFinalizers, &GC.inFinalizer);
    }

    pragma(crt_destructor) extern (C) void register_sidero_gc_deregister() {
        deregisterGC(&GC.malloc);
    }
}
