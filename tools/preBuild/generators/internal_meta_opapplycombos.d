module generators.internal_meta_opapplycombos;
import constants;
import std.array : appender, Appender;
import std.format;
import std.file : write;

void generateInternalMetaOpApplyCombos() {
    output ~= "// generated by tools/internal_meta do not modify\n";
    output ~= "module sidero.base.internal.meta;\n\n";

    State state;
    state.withSafe;
    write(InternalMetaFile, output.data);
}

private:

Appender!string output;
bool[State] seenState;

struct State {
    bool hasSafe, hasNothrow, hasNogc, hasPure, hasKey, hasReverse, hasStatic;
}

void withSafe(State input) {
    withNothrow(input);
    input.hasSafe = true;
    withNothrow(input);
}

void withNothrow(State input) {
    withNogc(input);
    input.hasNothrow = true;
    withNogc(input);
}

void withNogc(State input) {
    withPure(input);
    input.hasNogc = true;
    withPure(input);
}

void withPure(State input) {
    withKey(input);
    input.hasPure = true;
    withKey(input);
}

void withKey(State input) {
    withReverse(input);
    input.hasKey = true;
    withReverse(input);
}

void withReverse(State input) {
    withStatic(input);
    input.hasReverse = true;
    withStatic(input);
}

void withStatic(State input) {
    emit(input);
    input.hasStatic = true;
    emit(input);
}

void emit(State input) {
    if(input in seenState)
        return;
    seenState[input] = true;

    output.formattedWrite!"mixin template OpApplyCombos(ValueType, KeyType%s, string Name:\"%s\", bool UseSafe:%s, bool UseNothrow:%s, bool UseNogc:%s, bool UsePure:%s, bool UseStatic:%s) {\n"(
            input.hasKey ? "" : ":void", input.hasReverse ? "opApplyReverse" : "opApply", input.hasSafe, input.hasNothrow,
            input.hasNogc, input.hasPure, input.hasStatic);

    ptrdiff_t safeOffset = -1;
    ptrdiff_t withKeyOffset = -1;
    string[] attributes;

    if(input.hasKey) {
        attributes = ["KeyType"];
        withKeyOffset = 0;
    }

    if(input.hasSafe)
        attributes ~= "@safe";
    if(input.hasNothrow)
        attributes ~= "nothrow";
    if(input.hasNogc)
        attributes ~= "@nogc";
    if(input.hasPure)
        attributes ~= "pure";

    bool[] active;
    active.length = attributes.length;

    foreach(i, ref attribute; attributes) {
        if(attribute == "@safe") {
            safeOffset = i;
            break;
        } else if(attribute == "@system") {
            attribute = "@safe";
            safeOffset = i;
            break;
        }
    }

    void handle(size_t depth) {
        if(depth == attributes.length) {
            output.formattedWrite!"    int opApply%s(scope int delegate("(input.hasReverse ? "Reverse" : "");
            if(withKeyOffset >= 0 && active[withKeyOffset])
                output ~= "ref KeyType, ";

            output ~= "ref ValueType)";

            foreach(i, attribute; attributes) {
                if(withKeyOffset == i)
                    continue;
                else if(active[i])
                    output ~= " " ~ attribute;
                else if(i == safeOffset)
                    output ~= " @system";
            }

            output ~= " del)";

            if(!input.hasStatic)
                output ~= " scope";

            foreach(i, attribute; attributes) {
                if(withKeyOffset == i)
                    continue;
                else if(active[i])
                    output ~= " " ~ attribute;
                else if(i == safeOffset)
                    output ~= " @system";
            }

            output.formattedWrite!" => opApply%sImpl(del);\n"(input.hasReverse ? "Reverse" : "");
        } else {
            active[depth] = false;
            handle(depth + 1);
            active[depth] = true;
            handle(depth + 1);
        }
    }

    handle(0);
    output ~= "}\n\n";
}