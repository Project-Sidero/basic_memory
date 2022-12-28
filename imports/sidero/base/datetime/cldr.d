/**
 CLDR database access routines
 License: Artistic-v2
*/
module sidero.base.datetime.cldr;
// Generated do not modify

/// Converts a Windows name for timezone to IANA timezone name.
export extern(C) string windowsToIANA(scope string windows, scope string territory) @safe nothrow @nogc pure;
/// Ditto
export string windowsToIANA(scope string windows) @safe nothrow @nogc pure {
    return windowsToIANA(windows, "001");
}
/// Converts a IANA name for timezone to Windows timezone name.
export extern(C) string ianaToWindows(scope string iana) @safe nothrow @nogc pure;
