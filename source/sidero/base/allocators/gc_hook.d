/*
Registration of hooks for garbage collection.

License: Boost
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.gc_hook;
import sidero.base.allocators.gc;

version(D_BetterC) {
} else {
    import core.memory : GC;
    import core.runtime : rt_init, rt_term;

    version(Windows) {
        // We handles Windows support as part of DllMain
    } else {
        version(InitAfterDruntimeSideroBase) {
            // Unfortunately there are some cases where we need druntime to initialize before us
            //  for example if are building for unittesting.

            shared static this() {
                // adding this extra lock, guarantees we control when the druntime goes away
                rt_init;

                registerGC(&GC.malloc, &GC.enable, &GC.disable, &GC.collect, &GC.minimize, &GC.addRange,
                &GC.removeRange, &GC.runFinalizers, &GC.inFinalizer);
            }
        } else {
            pragma(crt_constructor) extern (C) void register_sidero_gc_register() {
                // adding this extra lock, guarantees we control when the druntime goes away
                rt_init;

                registerGC(&GC.malloc, &GC.enable, &GC.disable, &GC.collect, &GC.minimize, &GC.addRange,
                &GC.removeRange, &GC.runFinalizers, &GC.inFinalizer);
            }
        }

        pragma(crt_destructor) extern (C) void register_sidero_gc_deregister() {
            // we really really want our stuff to deregister before druntime does
            deregisterGC(&GC.malloc);
            rt_term;
        }
    }
}
