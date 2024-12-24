module generators.unicode.genfor.emoji_data;
import generators.unicode.data.EmojiData;
import generators.unicode.defs;
import utilities.intervallist;

void genForEmojiData() {
    implOutput ~= "module sidero.base.internal.unicode.emoji_data;\n";
    implOutput ~= "import sidero.base.containers.set.interval;\n";
    implOutput ~= "// Generated do not modify\n\n";

    static foreach(Em; __traits(allMembers, EmojiClass)) {
            apiOutput ~= "\n";
            apiOutput ~= "/// Is member of " ~ Em ~ " class?\n";
            generateIsCheck(apiOutput, implOutput, "sidero_utf_lut_isMemberOf" ~ Em, EmojiData.values[__traits(getMember, EmojiClass, Em)], true);
    }
}
