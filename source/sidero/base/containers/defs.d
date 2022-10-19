module sidero.base.containers.defs;

///
alias HashFunction(KeyType) = ulong function(KeyType) @safe nothrow @nogc;
