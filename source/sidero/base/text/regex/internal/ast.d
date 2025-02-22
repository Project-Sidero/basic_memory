module sidero.base.text.regex.internal.ast;
import sidero.base.containers.set.interval;
import sidero.base.math.interval;
import sidero.base.containers.appender;
import sidero.base.text;

@safe nothrow:

struct RegexNFANode {
    enum Type {
        Infer,
        Prefix,
        Ranges,
        Group,
        Any,
        LookBehind,
        AssertForward,
        AssertNotForward,
    }

    Type type;

    int idNumber, depth;
    RegexNFANode* next1, next2;

    // if next2 and afterNextSuccess is same value, next1 is optional
    RegexNFANode* afterNextSuccess;

    // intrusive LL for cleaning up
    RegexNFANode* needsCleanupLL;

    // guards traversing next1
    int min;
    int max;

    String_UTF8 prefix;
    ubyte prefixCharacterLastLength;

    IntervalSet!dchar ranges;

    int groupCaptureId;

    uint lookBehindGroupOffset;

@safe nothrow @nogc:

    this(return scope ref RegexNFANode other) scope @trusted {
        this.type = other.type;
        this.idNumber = other.idNumber;
        this.depth = other.depth;
        this.next1 = other.next1;
        this.next2 = other.next2;
        this.afterNextSuccess = other.afterNextSuccess;

        this.min = other.min;
        this.max = other.max;

        final switch(this.type) {
        case Type.Infer:
            break;
        case Type.Prefix:
            this.prefix = other.prefix;
            this.prefixCharacterLastLength = other.prefixCharacterLastLength;
            break;
        case Type.Ranges:
            this.ranges = other.ranges;
            break;
        case Type.Group:
            this.groupCaptureId = other.groupCaptureId;
            break;
        case Type.Any:
            break;
        case Type.LookBehind:
            this.lookBehindGroupOffset = other.lookBehindGroupOffset;
            break;
        case Type.AssertForward:
        case Type.AssertNotForward:
            break;
        }
    }

    ~this() @trusted {
    }

    void toDot(ref Appender!char appender, string graphName = "G") @trusted {
        StringBuilder_UTF8 id = text("N", this.idNumber);

        appender ~= "digraph ";
        appender ~= graphName;
        appender ~= " {\n";
        appender ~= "    rankdir=LR;\n";
        appender ~= "\n";

        appender ~= "    Start[shape=doublecircle];\n";
        appender ~= "    Start -> ";
        appender ~= id;
        appender ~= ";\n";
        appender ~= "\n";

        this.toDot(appender, 1);

        RegexNFANode* temp = findLogicalEnd(&this);

        if(temp !is null) {
            StringBuilder_UTF8 idA = text("N", temp.idNumber);

            appender ~= "    End[shape=doublecircle];\n";
            appender ~= "    ";
            appender ~= idA;
            appender ~= " -> End;\n";
        }

        appender ~= "}";
    }

    void toDot(ref Appender!char appender, int prefix) @trusted {
        StringBuilder_UTF8 id = text("N", this.idNumber);
        StringBuilder_UTF8 id1 = next1 !is null ? text("N", next1.idNumber) : StringBuilder_UTF8();
        StringBuilder_UTF8 id2 = next2 !is null ? text("N", next2.idNumber) : StringBuilder_UTF8();
        StringBuilder_UTF8 idA = afterNextSuccess !is null ? text("N", afterNextSuccess.idNumber) : StringBuilder_UTF8();

        void addPrefix() {
            foreach(_; 0 .. prefix) {
                appender ~= "    ";
            }
        }

        void printDebugCharacter(dchar c) {
            if(c >= '!' && c <= '~')
                appender ~= c;
            else
                appender ~= '.';
        }

        void printDebugString(const(char)[] str) {
            foreach(char c; str) {
                printDebugCharacter(c);
            }
        }

        {
            addPrefix;
            appender ~= id;
            appender ~= "[label=\"";

            if(this.min != 1 || this.max != 1) {
                appender ~= text("{", this.min, ", ", this.max, "}");
                appender ~= "&nbsp;&nbsp;&nbsp;&nbsp;";
            }

            final switch(this.type) {
            case Type.Infer:
                appender ~= "$INFER$";
                break;

            case Type.Group:
                appender ~= "$GROUP$";
                if(this.groupCaptureId >= 0)
                    appender ~= text(' ', this.groupCaptureId);
                break;

            case Type.Prefix:
                foreach(c; this.prefix.byUTF32) {
                    printDebugCharacter(c);
                }
                break;

            case Type.Ranges:
                foreach(Interval!dchar r; this.ranges) {
                    printDebugCharacter(r.start);
                    appender ~= '-';
                    printDebugCharacter(r.end);
                }

                break;

            case Type.Any:
                appender ~= "$ANY$";
                break;

            case Type.LookBehind:
                appender ~= "$LOOKBEHIND$ ";
                appender ~= text(this.lookBehindGroupOffset);
                break;

            case Type.AssertForward:
                appender ~= "$ASSERT FORWARD$";
                break;

            case Type.AssertNotForward:
                appender ~= "$ASSERT NOT FORWARD$";
                break;
            }

            appender ~= "\"];\n";
        }

        if(this.type == Type.Group && next1 !is null) {
            StringBuilder_UTF8 idG = text("N", this.next1.idNumber);

            addPrefix;
            appender ~= id;
            appender ~= " -> ";
            appender ~= idG;
            appender ~= "[label=\"group\"];\n";

            if(afterNextSuccess !is null) {
                assert(next1 !is afterNextSuccess);

                RegexNFANode* end = findLogicalEnd(this.next1);
                StringBuilder_UTF8 idE = text("N", end.idNumber);

                addPrefix;
                appender ~= idE;
                appender ~= " -> ";
                appender ~= idA;
                appender ~= "[style=\"dotted\", label=\"success (look back) 1\"];\n";
            }

            addPrefix;
            appender ~= "subgraph SG_";
            appender ~= idG;
            appender ~= " {\n";

            next1.toDot(appender, prefix + 1);

            addPrefix;
            appender ~= "}\n";
        }

        if(type != Type.Group && next1 !is null) {
            addPrefix;
            appender ~= id;
            appender ~= " -> ";
            appender ~= id1;
            appender ~= "[label=\"next1\"];\n";

            if(afterNextSuccess !is null) {
                assert(next1 !is afterNextSuccess);

                RegexNFANode* end = findLogicalEnd(this.next1);
                StringBuilder_UTF8 idE = text("N", end.idNumber);

                addPrefix;
                appender ~= idE;
                appender ~= " -> ";
                appender ~= idA;
                appender ~= "[style=\"dotted\", label=\"success (look back) 1\"];\n";
            }
        }

        if(next2 !is null) {
            addPrefix;
            appender ~= id;
            appender ~= " -> ";
            appender ~= id2;
            appender ~= "[label=\"next2\"];\n";

            if(afterNextSuccess !is null && next2 !is afterNextSuccess) {
                RegexNFANode* end = findLogicalEnd(this.next2);
                StringBuilder_UTF8 idE = text("N", end.idNumber);

                addPrefix;
                appender ~= idE;
                appender ~= " -> ";
                appender ~= idA;
                appender ~= "[style=\"dotted\", label=\"success (look back) 2\"];\n";
            }
        }

        if(afterNextSuccess !is null) {
            addPrefix;
            appender ~= id;
            appender ~= " -> ";
            appender ~= idA;
            appender ~= "[style=\"dashed\", label=\"after success\"];\n";
        }

        if(type != Type.Group && next1 !is null && next2 !is null) {
            // this is a split, always add a sub graph

            if(next1.depth > this.depth || (next1.depth == this.depth && next1.idNumber > this.idNumber)) {
                addPrefix;
                appender ~= "subgraph SG_";
                appender ~= id1;
                appender ~= " {\n";

                next1.toDot(appender, prefix + 1);

                addPrefix;
                appender ~= "}\n";
            }

            if(next1 !is next2 && (next2.depth > this.depth || (next2.depth == this.depth && next2.idNumber > this.idNumber))) {
                addPrefix;
                appender ~= "subgraph SG_";
                appender ~= id2;
                appender ~= " {\n";

                next2.toDot(appender, prefix + 1);

                addPrefix;
                appender ~= "}\n";
            }
        } else if(type != Type.Group && next1 !is null) {
            if(next1.depth > this.depth || (next1.depth == this.depth && next1.idNumber > this.idNumber))
                next1.toDot(appender, prefix);
        } else if(next2 !is null) {
            if(next2.depth > this.depth || (next2.depth == this.depth && next2.idNumber > this.idNumber))
                next2.toDot(appender, prefix);
        }

        if(afterNextSuccess !is null && next1 !is afterNextSuccess && next2 !is afterNextSuccess)
            afterNextSuccess.toDot(appender, prefix);
    }
}

unittest {
    RegexNFANode* s = new RegexNFANode(RegexNFANode.Type.Infer, 0, 0), m1 = new RegexNFANode(RegexNFANode.Type.Infer, 1,
            1), m2 = new RegexNFANode(RegexNFANode.Type.Infer, 2, 1), e = new RegexNFANode(RegexNFANode.Type.Infer, 3, 2);

    s.next1 = m1;
    s.next2 = m2;
    s.afterNextSuccess = e;

    Appender!char appender;
    s.toDot(appender, "Split");
    assert(appender.asReadOnly == q{digraph Split {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N0 -> N1[label="next1"];
    N1 -> N3[style="dotted", label="success (look back) 1"];
    N0 -> N2[label="next2"];
    N2 -> N3[style="dotted", label="success (look back) 2"];
    N0 -> N3[style="dashed", label="after success"];
    subgraph SG_N1 {
        N1[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    }
    subgraph SG_N2 {
        N2[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    }
    N3[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    End[shape=doublecircle];
    N3 -> End;
}});
}

unittest {
    RegexNFANode* n1 = new RegexNFANode(RegexNFANode.Type.Infer, 0, 0), n2 = new RegexNFANode(RegexNFANode.Type.Infer, 1, 1);
    n1.next1 = n2;

    Appender!char appender;
    n1.toDot(appender, "Concat");
    assert(appender.asReadOnly == q{digraph Concat {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N0 -> N1[label="next1"];
    N1[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    End[shape=doublecircle];
    N1 -> End;
}});
}

unittest {
    RegexNFANode* s = new RegexNFANode(RegexNFANode.Type.Infer, 0, 0), m = new RegexNFANode(RegexNFANode.Type.Infer, 1,
            1), e = new RegexNFANode(RegexNFANode.Type.Infer, 2, 2);

    s.next1 = m;
    s.next2 = e;
    s.afterNextSuccess = e;

    Appender!char appender;
    s.toDot(appender, "Optional");
    assert(appender.asReadOnly == q{digraph Optional {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N0 -> N1[label="next1"];
    N1 -> N2[style="dotted", label="success (look back) 1"];
    N0 -> N2[label="next2"];
    N0 -> N2[style="dashed", label="after success"];
    subgraph SG_N1 {
        N1[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    }
    subgraph SG_N2 {
        N2[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    }
    End[shape=doublecircle];
    N2 -> End;
}});
}

unittest {
    RegexNFANode* s = new RegexNFANode(RegexNFANode.Type.Infer, 0, 0), m = new RegexNFANode(RegexNFANode.Type.Infer, 1,
            1), e = new RegexNFANode(RegexNFANode.Type.Infer, 2, 2);

    s.next1 = m;
    m.next1 = s;

    s.next2 = e;
    s.afterNextSuccess = e;

    Appender!char appender;
    s.toDot(appender, "ZeroOrMore");
    assert(appender.asReadOnly == q{digraph ZeroOrMore {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N0 -> N1[label="next1"];
    N1 -> N2[style="dotted", label="success (look back) 1"];
    N0 -> N2[label="next2"];
    N0 -> N2[style="dashed", label="after success"];
    subgraph SG_N1 {
        N1[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
        N1 -> N0[label="next1"];
    }
    subgraph SG_N2 {
        N2[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    }
    End[shape=doublecircle];
    N2 -> End;
}});
}

unittest {
    RegexNFANode* s = new RegexNFANode(RegexNFANode.Type.Infer, 0, 0), m = new RegexNFANode(RegexNFANode.Type.Infer, 1,
            1), n = new RegexNFANode(RegexNFANode.Type.Infer, 2, 2), o = new RegexNFANode(RegexNFANode.Type.Infer, 3, 2),
        e = new RegexNFANode(RegexNFANode.Type.Infer, 4, 3);

    s.next1 = m;
    m.next1 = n;
    m.afterNextSuccess = o;
    o.next1 = m;
    o.next2 = e;

    Appender!char appender;
    s.toDot(appender, "OneOrMore");
    assert(appender.asReadOnly == q{digraph OneOrMore {
    rankdir=LR;

    Start[shape=doublecircle];
    Start -> N0;

    N0[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N0 -> N1[label="next1"];
    N1[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N1 -> N2[label="next1"];
    N2 -> N3[style="dotted", label="success (look back) 1"];
    N1 -> N3[style="dashed", label="after success"];
    N2[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N3[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    N3 -> N1[label="next1"];
    N3 -> N4[label="next2"];
    subgraph SG_N4 {
        N4[label="{0, 0}&nbsp;&nbsp;&nbsp;&nbsp;$INFER$"];
    }
    End[shape=doublecircle];
    N3 -> End;
}});
}

private:

RegexNFANode* findLogicalEnd(RegexNFANode* parent) @nogc {
    RegexNFANode* ret = parent;

    for(;;) {
        if(ret.afterNextSuccess !is null)
            ret = ret.afterNextSuccess;
        else if(ret.next1 is null && ret.next2 !is null && ret.next2.depth >= ret.depth)
            ret = ret.next2;
        else if(ret.type != RegexNFANode.Type.Group && ret.next1 !is null && ret.next1.depth >= ret.depth)
            ret = ret.next1;
        else
            break;
    }

    return ret;
}
