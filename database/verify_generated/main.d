module verify_generated.main;
import std.stdio;

void main() {
    {
        import verify_generated.normalizationtests;
        import verify_generated.wordbreaktest;

        normalizationTests;
        wordBreakTests;
    }

    writeln("Success!");
}
