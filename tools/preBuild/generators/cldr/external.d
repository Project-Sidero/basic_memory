module generators.cldr.external;
import constants;

void createAPIfile() {
    import std.array : appender;
    import std.file : write;

    auto api = appender!string();
    api ~= "/**\n";
    api ~= " CLDR database access routines\n";
    api ~= " License: Artistic-v2\n";
    api ~= "*/\n";
    api ~= "module sidero.base.datetime.cldr;\n";
    api ~= "// Generated do not modify\n";
    api ~= "\n";

    write(CLDRAPIFile, api.data);
}
