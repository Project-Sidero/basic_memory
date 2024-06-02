/**
 CLDR database access routines
 License: Artistic-v2
*/
module sidero.base.datetime.cldr;
// Generated do not modify

/// Converts a Windows name for timezone to IANA timezone name.
export extern(C) string windowsToIANA(scope string windows, scope string territory = "001") @safe nothrow @nogc pure;
/// Converts a IANA name for timezone to Windows timezone name.
export extern(C) string ianaToWindows(scope string iana) @safe nothrow @nogc pure;
