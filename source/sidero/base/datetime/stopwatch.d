module sidero.base.datetime.stopwatch;
import sidero.base.datetime.duration;
import sidero.base.datetime.time.clock;

///
struct StopWatch {
    private {
        long startSample;
        long endSample;
    }

export @safe nothrow @nogc:

    ///
    void start() {
        this.startSample = accuratePointInTime;
        this.endSample = 0;
    }

    ///
    Duration stop() {
        this.endSample = accuratePointInTime();

        return (this.endSample - this.startSample).nanoSeconds;
    }

    ///
    Duration peek() {
        return (accuratePointInTime() - this.startSample).nanoSeconds;
    }

    ///
    Duration result() {
        return (this.endSample - this.startSample).nanoSeconds;
    }
}

///
unittest {
    StopWatch sw;
    sw.start;
    sw.stop;

    assert(sw.startSample != 0);
    assert(sw.endSample != 0);
}

/// The amount of time the process has spent executing in user mode during a period of time.
struct ProcessUserStopWatch {
    private {
        long startSample;
        long endSample;
    }

    export @safe nothrow @nogc:

    ///
    void start() {
        this.startSample = amountOfProcessUserTime;
        this.endSample = 0;
    }

    ///
    Duration stop() {
        this.endSample = amountOfProcessUserTime();

        return (this.endSample - this.startSample).microSeconds;
    }

    ///
    Duration peek() {
        return (amountOfProcessUserTime() - this.startSample).microSeconds;
    }

    ///
    Duration result() {
        return (this.endSample - this.startSample).microSeconds;
    }
}

///
unittest {
    ProcessUserStopWatch sw;
    sw.start;
    sw.stop;

    assert(sw.startSample != 0);
    assert(sw.endSample != 0);
}
