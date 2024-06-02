module verify_generated.main;
import std.stdio;

void main() {
    writeln("Running all verification of generated logic");

    {
        import unicode.normalizationtests;
        import unicode.wordbreaktest;

        writeln("Running normalization tests");
        normalizationTests;

        writeln("Running word break tests");
        wordBreakTests;
    }

    writeln("Success!");
}
