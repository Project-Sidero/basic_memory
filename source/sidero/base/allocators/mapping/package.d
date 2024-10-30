/**
Provides memory mapping for a given platform, along with the default to use.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2022-2024 Richard Andrew Cattermole
 */
module sidero.base.allocators.mapping;
///
public import sidero.base.allocators.mapping.vars;

///
public import sidero.base.allocators.mapping.malloc;

version(Windows) {
    ///
    public import sidero.base.allocators.mapping.virtualalloc;

    ///
    alias DefaultMapper = VirtualAllocMapper;
} else version(Posix) {
    ///
    public import sidero.base.allocators.mapping.mmap;

    ///
    alias DefaultMapper = MMap;
} else {
    ///
    alias DefaultMapper = Mallocator;
}
