module sidero.base.moduleinfostubs;

version(DynamicSideroBase)
    version = NeedStubs;
else version(D_BetterC)
    version = NeedStubs;

version(NeedStubs) {
    static foreach(ModuleName; [
        "sidero.base.allocators.gc", "sidero.base.allocators", "sidero.base.allocators.api",
        "sidero.base.console", "sidero.base.traits",
        "sidero.base.text.format", "sidero.base.errors", "sidero.base.containers.readonlyslice",
        "sidero.base.math.linear_algebra", "sidero.base.errors.result", "sidero.base.hash.utils", "sidero.base.hash.fnv",
        "sidero.base.algorithm", "sidero.base.text", "sidero.base.containers.map.concurrenthashmap",
        "sidero.base.containers.dynamicarray", "sidero.base.allocators.predefined",
        "sidero.base.parallelism.rwmutex", "sidero.base.datetime.duration", "sidero.base.containers.map.hashmap",
        "sidero.base.synchronization.mutualexclusion", "sidero.base.datetime", "sidero.base.system",
        "sidero.base.logger", "sidero.base.datetime.time.clock",
    ]) {
        mixin(() {
            string mangleName = "_D";

            {
                void emitLength(size_t amount) {
                    string ret;

                    while(amount > 0) {
                        size_t num = amount - ((amount / 10) * 10);

                        ret = "" ~ (cast(char)(num + '0')) ~ ret;

                        amount /= 10;
                    }

                    mangleName ~= ret;
                }

                string temp = ModuleName;

                GetNextMP: while(temp.length > 0) {
                    foreach(i, c; temp) {
                        if(c == '.') {
                            emitLength(i);
                            mangleName ~= temp[0 .. i];
                            temp = temp[i + 1 .. $];
                            continue GetNextMP;
                        }
                    }

                    emitLength(temp.length);
                    mangleName ~= temp;
                    break;
                }

                mangleName ~= "12__ModuleInfoZ";
            }

            string ret = "export extern(C) void " ~ mangleName ~ "() { asm { naked; ";

            void add(ubyte b) {
                ret ~= "db 0x";

                ubyte temp = b & 0xF;
                if(temp > 9)
                    ret ~= 'A' + (temp - 10);
                else
                    ret ~= '0' + temp;

                temp = (b >> 4) & 0xF;
                if(temp > 9)
                    ret ~= 'A' + (temp - 10);
                else
                    ret ~= '0' + temp;

                ret ~= ";";
            }

            add(MIname & 0xFF);
            add((MIname >> 8) & 0xFF);
            add(0);
            add(0);

            add(0);
            add(0);
            add(0);
            add(0);

            foreach(c; ModuleName) {
                add(c);
            }
            add(0);

            return ret ~ "}\n}\n";
        }());
    }
}
