module sidero.base.text.regex.internal.strategies.tests;
import sidero.base.text.regex.internal.state;
import sidero.base.text;
import sidero.base.allocators;

mixin template RegexMatchStrategyTests(RegexMatchStrategy strategy) {
    import sidero.base.text.regex.pattern;
    import sidero.base.text.regex.matching;
    import sidero.base.containers.appender;

    Regex regex(string pattern, RegexMode mode = RegexMode()) @trusted {
        ErrorSinkRef_Console errorSink = ErrorSinkRef_Console.make;
        assert(!errorSink.isNull);

        Regex r = Regex.from(cast(ErrorSinkRef)errorSink, String_UTF8(pattern), mode);
        assert(!errorSink.haveError);

        r.state.strategy = strategy;
        return r;
    }

    const(char)[][2] expectMatch(Regex r, string contents, int forTest = __LINE__) @trusted {
        bool outputDebug;

        if(outputDebug) {
            import sidero.base.console;

            writeln("====================== MATCHING ======================");
            writeln("    [[  ", contents, "  ]] for test: ", forTest, " for: [[ ", r.pattern, " ]]");
        }

        Match match = r.matchFirst(String_UTF8(contents));
        size_t[2] pos2 = [match.before.text.length, match.span.text.length];
        const(char)[] before, matched;

        if(pos2[0] > 0)
            before = contents[0 .. pos2[0]];
        matched = contents[pos2[0] .. pos2[0] + pos2[1]];

        if(outputDebug) {
            import sidero.base.console;

            debugWriteln(matched.length > 0 ? "matched: " : "no match: ", before.length, "[[  ", before, "  ]] ",
                    matched.length, "[[  ", matched, "  ]] ", contents.length, "[[  ", contents, "  ]]");
        }

        const(char)[][2] ret = void;

        if(matched.length == 0) {
            ret[0] = null;
            ret[1] = null;
        } else {
            ret[0] = before;
            ret[1] = matched;
        }

        return ret;
    }

    unittest {
        Regex r = regex("a?|b");

        Appender!char appender;
        r.state.head.toDot(appender, "badalt");
        assert(appender.asReadOnly == q{digraph badalt {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N2;

    N2[label="$GROUP$"];
    N2 -> N0[label="group"];
    subgraph SG_N0 {
        N0[label="{0, 1}&nbsp;&nbsp;&nbsp;&nbsp;a"];
        N0 -> N1[label="next2"];
        N1[label="b"];
    }
    End[shape=doublecircle];
    N2 -> End;
}});
    }

    unittest {
        Regex r = regex("hello(boo|mar|heh)?moo[^-{av-zb-]zar+blah*");

        Appender!char appender;
        r.state.head.toDot(appender, "aparse");
        assert(appender.asReadOnly == q{digraph aparse {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="hello"];
    N0 -> N1[label="next1"];
    N1[label="{0, 1}&nbsp;&nbsp;&nbsp;&nbsp;$GROUP$"];
    N1 -> N2[label="group"];
    N4 -> N5[style="dotted", label="success (look back) 1"];
    subgraph SG_N2 {
        N2[label="boo"];
        N2 -> N3[label="next2"];
        N3[label="mar"];
        N3 -> N4[label="next2"];
        N4[label="heh"];
    }
    N1 -> N5[label="next2"];
    N1 -> N5[style="dashed", label="after success"];
    N5[label="moo"];
    N5 -> N6[label="next1"];
    N6[label=".-,.-`|-.c-u"];
    N6 -> N7[label="next1"];
    N7[label="za"];
    N7 -> N8[label="next1"];
    N8[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;r"];
    N8 -> N9[label="next1"];
    N9[label="bla"];
    N9 -> N10[label="next1"];
    N10[label="{0, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;h"];
    N10 -> N11[label="next2"];
    N10 -> N11[style="dashed", label="after success"];
    N11[label="$INFER$"];
    End[shape=doublecircle];
    N11 -> End;
}});
    }

    unittest {
        Regex r = regex("someprefix");

        Appender!char appender;
        r.state.head.toDot(appender, "someprefix");
        assert(appender.asReadOnly == q{digraph someprefix {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="someprefix"];
    End[shape=doublecircle];
    N0 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "some") == ["", ""]);
        assert(expectMatch(r, "prefix") == ["", ""]);
        assert(expectMatch(r, "someprefix") == ["", "someprefix"]);
        assert(expectMatch(r, "bsomeprefixe") == ["b", "someprefix"]);
    }

    unittest {
        Regex r = regex("someprefix|another");

        Appender!char appender;
        r.state.head.toDot(appender, "someprefix2");
        assert(appender.asReadOnly == q{digraph someprefix2 {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N2;

    N2[label="$GROUP$"];
    N2 -> N0[label="group"];
    subgraph SG_N0 {
        N0[label="someprefix"];
        N0 -> N1[label="next2"];
        N1[label="another"];
    }
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "some") == ["", ""]);
        assert(expectMatch(r, "prefix") == ["", ""]);
        assert(expectMatch(r, "an") == ["", ""]);
        assert(expectMatch(r, "someprefix") == ["", "someprefix"]);
        assert(expectMatch(r, "another") == ["", "another"]);
    }

    unittest {
        Regex r = regex("a?b*c+");

        Appender!char appender;
        r.state.head.toDot(appender, "matchmultiplier");
        assert(appender.asReadOnly == q{digraph matchmultiplier {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{0, 1}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    N0 -> N1[label="next2"];
    N0 -> N1[style="dashed", label="after success"];
    N1[label="{0, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;b"];
    N1 -> N2[label="next2"];
    N1 -> N2[style="dashed", label="after success"];
    N2[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;c"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "eek") == ["", ""]);
        assert(expectMatch(r, "bac") == ["b", "ac"]);
        assert(expectMatch(r, "c") == ["", "c"]);
        assert(expectMatch(r, "bc") == ["", "bc"]);
        assert(expectMatch(r, "abc") == ["", "abc"]);
        assert(expectMatch(r, "abbcc") == ["", "abbcc"]);
    }

    unittest {
        // an idea from Dmitry Olshansky in place of (a+)+
        Regex r = regex("a+a+a+a+a+");

        Appender!char appender;
        r.state.head.toDot(appender, "matchbacktrackcatastphic");
        assert(appender.asReadOnly == q{digraph matchbacktrackcatastphic {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    N1 -> N2[label="next1"];
    N2[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    N2 -> N3[label="next1"];
    N3[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    N3 -> N4[label="next1"];
    N4[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    End[shape=doublecircle];
    N4 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaX") == [
            "",
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        ]);
    }

    unittest {
        Regex r = regex("(a+)+");

        Appender!char appender;
        r.state.head.toDot(appender, "matchbacktrackcatastphic2");
        assert(appender.asReadOnly == q{digraph matchbacktrackcatastphic2 {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;$GROUP$"];
    N0 -> N1[label="group"];
    N1 -> N2[style="dotted", label="success (look back) 1"];
    subgraph SG_N1 {
        N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a"];
    }
    N0 -> N2[style="dashed", label="after success"];
    N2[label="$INFER$"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaX") == [
            "",
            "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        ]);
    }

    unittest {
        Regex r = regex("ab+b");

        Appender!char appender;
        r.state.head.toDot(appender, "greedybacktrack");
        assert(appender.asReadOnly == q{digraph greedybacktrack {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="a"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;b"];
    N1 -> N2[label="next1"];
    N2[label="b"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "abb") == ["", "abb"]);
    }

    unittest {
        Regex r = regex("b(n|v|me|m)e");

        Appender!char appender;
        r.state.head.toDot(appender, "backtrack4");
        assert(appender.asReadOnly == q{digraph backtrack4 {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="$GROUP$"];
    N1 -> N2[label="group"];
    N5 -> N6[style="dotted", label="success (look back) 1"];
    subgraph SG_N2 {
        N2[label="n"];
        N2 -> N3[label="next2"];
        N3[label="v"];
        N3 -> N4[label="next2"];
        N4[label="me"];
        N4 -> N5[label="next2"];
        N5[label="m"];
    }
    N1 -> N6[style="dashed", label="after success"];
    N6[label="e"];
    End[shape=doublecircle];
    N6 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "bne") == ["", "bne"]);
        assert(expectMatch(r, "bve") == ["", "bve"]);
        assert(expectMatch(r, "bmee") == ["", "bmee"]);

        static if(strategy == RegexMatchStrategy.Old)
            assert(expectMatch(r, "bme") == ["", ""]);
        else
            assert(expectMatch(r, "bme") == ["", "bme"]);
    }

    unittest {
        Regex r = regex("b.e");

        Appender!char appender;
        r.state.head.toDot(appender, "matchany");
        assert(appender.asReadOnly == q{digraph matchany {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="$ANY$"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bme") == ["", "bme"]);
    }

    unittest {
        Regex r = regex("b.+e");

        Appender!char appender;
        r.state.head.toDot(appender, "matchanybacktrack");
        assert(appender.asReadOnly == q{digraph matchanybacktrack {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;$ANY$"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bme") == ["", "bme"]);
        assert(expectMatch(r, "bmiddlee") == ["", "bmiddlee"]);
    }

    unittest {
        Regex r = regex("b[mi]e");

        Appender!char appender;
        r.state.head.toDot(appender, "range");
        assert(appender.asReadOnly == q{digraph range {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="i-im-m"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bme") == ["", "bme"]);
        assert(expectMatch(r, "bie") == ["", "bie"]);
        assert(expectMatch(r, "bue") == ["", ""]);
    }

    unittest {
        Regex r = regex("b[mie]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "rangebacktrack");
        assert(appender.asReadOnly == q{digraph rangebacktrack {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;e-em-mi-i"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bme") == ["", "bme"]);
        assert(expectMatch(r, "bie") == ["", "bie"]);
        assert(expectMatch(r, "bue") == ["", ""]);
        assert(expectMatch(r, "bmiee") == ["", "bmiee"]);
    }

    unittest {
        Regex r = regex("b[ac||[yz]]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "setopsunion");
        assert(appender.asReadOnly == q{digraph setopsunion {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;a-ay-zc-c"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bace") == ["", "bace"]);
        assert(expectMatch(r, "bzye") == ["", "bzye"]);
        assert(expectMatch(r, "bzcyae") == ["", "bzcyae"]);
    }

    unittest {
        Regex r = regex("b[ac&&[az]]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "setopsintersect");
        assert(appender.asReadOnly == q{digraph setopsintersect {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;c-ca-a"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", "bae"]);
        assert(expectMatch(r, "bacze") == ["", ""]);
    }

    unittest {
        Regex r = regex("b[ac&&[^a]]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "setopsnot");
        assert(appender.asReadOnly == q{digraph setopsnot {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;c-c"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", ""]);
        assert(expectMatch(r, "bce") == ["", "bce"]);
    }

    unittest {
        Regex r = regex("b[ac--a]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "setopsdifference");
        assert(appender.asReadOnly == q{digraph setopsdifference {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;c-c"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", ""]);
        assert(expectMatch(r, "bce") == ["", "bce"]);
    }

    unittest {
        Regex r = regex("b[ac~~ad]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "setopssymdifference");
        assert(appender.asReadOnly == q{digraph setopssymdifference {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;c-d"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", ""]);
        assert(expectMatch(r, "bcde") == ["", "bcde"]);
    }

    unittest {
        Regex r = regex("b\\te");

        Appender!char appender;
        r.state.head.toDot(appender, "escapeprefix");
        assert(appender.asReadOnly == q{digraph escapeprefix {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="."];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", ""]);
        assert(expectMatch(r, "b\te") == ["", "b\te"]);
    }

    unittest {
        Regex r = regex("b[\\t\\$]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "escapecharclass");
        assert(appender.asReadOnly == q{digraph escapecharclass {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;$-$.-."];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", ""]);
        assert(expectMatch(r, "b$\te") == ["", "b$\te"]);
    }

    unittest {
        Regex r = regex("b[\\x20]+e");

        Appender!char appender;
        r.state.head.toDot(appender, "escapechar");
        assert(appender.asReadOnly == q{digraph escapechar {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{1, 2147483647}&nbsp;&nbsp;&nbsp;&nbsp;.-."];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bae") == ["", ""]);
        assert(expectMatch(r, "b e") == ["", "b e"]);
    }

    unittest {
        Regex r = regex("b(?#comment)e");
        Appender!char appender;
        r.state.head.toDot(appender, "comment");
        assert(appender.asReadOnly == q{digraph comment {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="e"];
    End[shape=doublecircle];
    N1 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", "be"]);
        assert(expectMatch(r, "pbe") == ["p", "be"]);
    }

    unittest {
        Regex r = regex("b(?m)\\1e");
        Appender!char appender;
        r.state.head.toDot(appender, "groupslookback");
        assert(appender.asReadOnly == q{digraph groupslookback {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="$GROUP$ 0"];
    N1 -> N2[label="group"];
    N2 -> N3[style="dotted", label="success (look back) 1"];
    subgraph SG_N2 {
        N2[label="m"];
    }
    N1 -> N3[style="dashed", label="after success"];
    N3[label="$LOOKBEHIND$ 0"];
    N3 -> N4[label="next1"];
    N4[label="e"];
    End[shape=doublecircle];
    N4 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bme") == ["", ""]);
        assert(expectMatch(r, "bmme") == ["", "bmme"]);
    }

    unittest {
        Regex r = regex("b.e", RegexMode(true));
        Appender!char appender;
        r.state.head.toDot(appender, "singlematch");
        assert(appender.asReadOnly == q{digraph singlematch {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="$ANY$"];
    N1 -> N2[label="next1"];
    N2[label="e"];
    End[shape=doublecircle];
    N2 -> End;
}});

        assert(expectMatch(r, "") == ["", ""]);
        assert(expectMatch(r, "be") == ["", ""]);
        assert(expectMatch(r, "bme") == ["", "bme"]);
        assert(expectMatch(r, "b\ne") == ["", "b\ne"]);
    }

    unittest {
        Regex r = regex("b(?>m)", RegexMode(true));
        Appender!char appender;
        r.state.head.toDot(appender, "assertforwards");
        assert(appender.asReadOnly == q{digraph assertforwards {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="$ASSERT FORWARD$"];
    N1 -> N2[label="next1"];
    N2 -> N3[style="dotted", label="success (look back) 1"];
    N1 -> N3[style="dashed", label="after success"];
    N2[label="m"];
    N3[label="$INFER$"];
    End[shape=doublecircle];
    N3 -> End;
}});

        static if(strategy == RegexMatchStrategy.Stack) {
            assert(expectMatch(r, "") == ["", ""]);
            assert(expectMatch(r, "be") == ["", ""]);
            assert(expectMatch(r, "bme") == ["", "b"]);
        }
    }

    unittest {
        Regex r = regex("bm?(?>m)", RegexMode(true));
        Appender!char appender;
        r.state.head.toDot(appender, "assertforwardsfail");
        assert(appender.asReadOnly == q{digraph assertforwardsfail {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{0, 1}&nbsp;&nbsp;&nbsp;&nbsp;m"];
    N1 -> N2[label="next2"];
    N1 -> N2[style="dashed", label="after success"];
    N2[label="$ASSERT FORWARD$"];
    N2 -> N3[label="next1"];
    N3 -> N4[style="dotted", label="success (look back) 1"];
    N2 -> N4[style="dashed", label="after success"];
    N3[label="m"];
    N4[label="$INFER$"];
    End[shape=doublecircle];
    N4 -> End;
}});

        static if(strategy == RegexMatchStrategy.Stack) {
            assert(expectMatch(r, "") == ["", ""]);
            assert(expectMatch(r, "be") == ["", ""]);
            assert(expectMatch(r, "bme") == ["", "b"]);
        }
    }

    unittest {
        Regex r = regex("b(?!>m)", RegexMode(true));
        Appender!char appender;
        r.state.head.toDot(appender, "assertnotforwards");
        assert(appender.asReadOnly == q{digraph assertnotforwards {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="$ASSERT NOT FORWARD$"];
    N1 -> N2[label="next1"];
    N2 -> N3[style="dotted", label="success (look back) 1"];
    N1 -> N3[style="dashed", label="after success"];
    N2[label="m"];
    N3[label="$INFER$"];
    End[shape=doublecircle];
    N3 -> End;
}});

        static if(strategy == RegexMatchStrategy.Stack) {
            assert(expectMatch(r, "") == ["", ""]);
            assert(expectMatch(r, "be") == ["", "b"]);
            assert(expectMatch(r, "bme") == ["", ""]);
        }
    }

    unittest {
        Regex r = regex("bm?(?!>m)", RegexMode(true));
        Appender!char appender;
        r.state.head.toDot(appender, "assertnotforwardsfail");
        assert(appender.asReadOnly == q{digraph assertnotforwardsfail {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="b"];
    N0 -> N1[label="next1"];
    N1[label="{0, 1}&nbsp;&nbsp;&nbsp;&nbsp;m"];
    N1 -> N2[label="next2"];
    N1 -> N2[style="dashed", label="after success"];
    N2[label="$ASSERT NOT FORWARD$"];
    N2 -> N3[label="next1"];
    N3 -> N4[style="dotted", label="success (look back) 1"];
    N2 -> N4[style="dashed", label="after success"];
    N3[label="m"];
    N4[label="$INFER$"];
    End[shape=doublecircle];
    N4 -> End;
}});

        static if(strategy == RegexMatchStrategy.Stack) {
            assert(expectMatch(r, "") == ["", ""]);
            assert(expectMatch(r, "be") == ["", "b"]);
            assert(expectMatch(r, "bme") == ["", "bm"]);
        }
    }
}
