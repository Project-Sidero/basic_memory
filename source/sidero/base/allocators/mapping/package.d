/**
Provides memory mapping for a given platform, along with the default to use.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.memory.allocators.mapping;
///
public import sidero.base.memory.allocators.mapping.vars;

///
public import sidero.base.memory.allocators.mapping.malloc;

version(Windows) {
    ///
    public import sidero.base.memory.allocators.mapping.virtualalloc;
    ///
    alias DefaultMapper = VirtualAllocMapper;
} else version(Posix) {
    ///
    public import sidero.base.memory.allocators.mapping.mmap;
    ///
    alias DefaultMapper = MMap;
} else {
    ///
    alias DefaultMapper = Mallocator;
}
