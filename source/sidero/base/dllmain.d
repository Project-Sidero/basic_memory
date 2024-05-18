module sidero.base.dllmain;
export:

version(DynamicSideroBase) {
    version(Windows) {
        import core.sys.windows.windef : HINSTANCE, BOOL, DWORD, LPVOID, DLL_PROCESS_ATTACH, DLL_PROCESS_DETACH;

        version(D_BetterC) {
            extern (Windows) BOOL DllMain(HINSTANCE hInstance, DWORD ulReason, LPVOID reserved) {
                return true;
            }
        } else {
            import sidero.base.allocators.gc;
            import core.memory : GC;
            import core.runtime : rt_init, rt_term;

            extern (Windows) BOOL DllMain(HINSTANCE hInstance, DWORD ulReason, LPVOID reserved) {
                // NOTE: The GC registration has to take place here instead of sidero.base.allocators.gc_hook
                //        due to the crt constructor running before the GC registration taking place.

                switch(ulReason) {
                    case DLL_PROCESS_ATTACH:
                        // adding this extra lock, guarantees we control when the druntime goes away
                        rt_init;

                        registerGC(&GC.malloc, &GC.enable, &GC.disable, &GC.collect, &GC.minimize, &GC.addRange,
                        &GC.removeRange, &GC.runFinalizers, &GC.inFinalizer);
                        break;

                    case DLL_PROCESS_DETACH:
                        // we really really want our stuff to deregister before druntime does
                        deregisterGC(&GC.malloc);
                        rt_term;
                        break;

                    default:
                        break;
                }

                return true;
            }
        }
    }
}
