/**
License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.memory.allocators.buffers.defs;

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
