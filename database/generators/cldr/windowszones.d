module generators.cldr.windowszones;
import generators.constants;
import std.array : appender;

void windowsZones() {
    import std.file : read, write, append;
    import std.zip;
    import std.conv;

    TotalState state;

    auto zip = new ZipArchive(read("cldr-common-42.0.zip"));
    auto member = zip.directory()["common/supplemental/windowsZones.xml"];
    zip.expand(member);
    string fileContents = cast(string)member.expandedData;

    processEachLine(fileContents, state);

    auto internal = appender!string();
    internal ~= "module sidero.base.internal.cldr.windowszones;\n\n";
    internal ~= "// Generated do not modify\n";

    internal ~= q{
private enum {
    FNV_Prime_32 = (2 ^^ 24) + (2 ^^ 8) + 0x93,
    FNV_Offset_Basis_32 = 0x811c9dc5,
}
uint fnv_32_1a(scope const(ubyte)[] data, uint start = FNV_Offset_Basis_32) @safe nothrow @nogc pure {
    uint hash = start;

    foreach (b; data) {
        hash ^= b;
        hash *= FNV_Prime_32;
    }

    return hash;
}
};

    auto api = appender!string();

    {
        internal ~= "export extern(C) string windowsToIANA(scope string windows, scope string territory) @trusted nothrow @nogc pure {\n";
        internal ~= "    uint windowsHash = fnv_32_1a(cast(ubyte[])windows);\n";
        internal ~= "    uint territoryHash = fnv_32_1a(cast(ubyte[])territory);\n";
        internal ~= "    switch(windowsHash) {\n";

        foreach(windows, territory; state.windowsToIANA) {
            uint windowsHash = fnv_32_1a(cast(ubyte[])windows);

            internal ~= "        case " ~ windowsHash.text ~ ":\n";
            internal ~= "            switch(territoryHash) {\n";

            foreach(territoryName, iana; territory.values) {
                uint territoryHash = fnv_32_1a(cast(ubyte[])territoryName);
                internal ~= "                case " ~ territoryHash.text ~ ":\n";
                internal ~= "                    return `" ~ iana ~ "`;\n";
            }

            internal ~= "                default:\n";
            internal ~= "                    return null;\n";
            internal ~= "            }\n";
        }

        internal ~= "        default:\n";
        internal ~= "            return null;\n";
        internal ~= "    }\n";
        internal ~= "}\n";

        api ~= "/// Converts a Windows name for timezone to IANA timezone name.\n";
        api ~= "export extern(C) string windowsToIANA(scope string windows, scope string territory = \"001\") @safe nothrow @nogc pure;\n";
    }

    {
        internal ~= "export extern(C) string ianaToWindows(scope string iana) @trusted nothrow @nogc pure {\n";
        internal ~= "    uint ianaHash = fnv_32_1a(cast(ubyte[])iana);\n";
        internal ~= "    switch(ianaHash) {\n";

        foreach(iana, windows; state.ianaToWindows) {
            uint ianaHash = fnv_32_1a(cast(ubyte[])iana);
            internal ~= "        case " ~ ianaHash.text ~ ":\n";
            internal ~= "            return \"" ~ windows ~ "\";\n";
        }

        internal ~= "        default:\n";
        internal ~= "            return null;\n";
        internal ~= "    }\n";
        internal ~= "}\n";

        api ~= "/// Converts a IANA name for timezone to Windows timezone name.\n";
        api ~= "export extern(C) string ianaToWindows(scope string iana) @safe nothrow @nogc pure;\n";
    }

    append(CLDRAPIFile, api.data);
    write(CLDRDirectory ~ "windowszone.d", internal.data);
}

void processEachLine(string inputText, ref TotalState state) {
    import std.regex;

    enum Per = r"([\w|/|+|-| ]*)";
    enum Full = "other=\"" ~ Per ~ "\" territory=\"" ~ Per ~ "\" type=\"" ~ Per ~ "\"";

    auto r = regex(Full);
    foreach(matches; matchAll(inputText, r)) {
        string windows = matches[1], territory = matches[2], iana = matches[3];

        if(windows !in state.windowsToIANA)
            state.windowsToIANA[windows] = new Territories;

        state.windowsToIANA[windows].values[territory] = iana;
        state.ianaToWindows[iana] = windows;
    }
}

struct TotalState {
    Territories*[string] windowsToIANA;
    string[string] ianaToWindows;
}

struct Territories {
    string[string] values;
}

private enum {
    FNV_Prime_32 = (2 ^^ 24) + (2 ^^ 8) + 0x93,
    FNV_Offset_Basis_32 = 0x811c9dc5,
}
uint fnv_32_1a(const(ubyte)[] data, uint start = FNV_Offset_Basis_32) {
    uint hash = start;

    foreach(b; data) {
        hash ^= b;
        hash *= FNV_Prime_32;
    }

    return hash;
}
