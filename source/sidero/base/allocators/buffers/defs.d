/**
Definitions used by multiple allocator buffers.

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole <firstname@lastname.co.nz>
Copyright: 2022-2024 Richard Andrew Cattermole
*/
module sidero.base.allocators.buffers.defs;

///
enum FitsStrategy {
    ///
    FirstFit,
    ///
    NextFit,
    ///
    BestFit,
    ///
    WorstFit,
}
