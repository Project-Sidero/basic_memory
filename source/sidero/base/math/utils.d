module sidero.base.math.utils;
import std.traits : isFloatingPoint, isNumeric, Unqual;

export @safe nothrow @nogc:

///
template DefaultMaxRelativeDifference(ForType) {
    static if (isFloatingPoint!ForType) {
        enum DefaultMaxRelativeDifference = (cast(ForType)10) ^^ -(ForType.dig / 2);
    } else {
        enum DefaultMaxRelativeDifference = 0;
    }
}

/// Similar to std.math : isClose.
bool isClose(A, B, CommonType = Unqual!(typeof(A.init + B.init)))(A a, B b,
        CommonType maxRelativeDifference = DefaultMaxRelativeDifference!CommonType, CommonType maxAbsoluteDifference = 0)
        if (isNumeric!A && isNumeric!B) {

    static if (isFloatingPoint!A && isFloatingPoint!B) {
        if (a == A.infinity || a == -A.infinity || b == B.infinity || b == -B.infinity)
            return false;

        CommonType abs(CommonType input) {
            return input >= 0 ? input : -input;
        }

        CommonType absoluteA = abs(a), absoluteB = abs(b), difference = abs(a - b);

        if (a == 0 || b == 0 || (absoluteA + absoluteB < CommonType.min_normal)) {
            // special check to look for when we are close to zero
            return difference < CommonType.epsilon * CommonType.min_normal;
        }

        return difference <= maxRelativeDifference * absoluteA || difference <= maxRelativeDifference * absoluteB ||
            difference <= maxAbsoluteDifference;
    } else {
        return isClose(cast(double)a, cast(double)b, cast(double)maxRelativeDifference, cast(double)maxAbsoluteDifference);
    }
}

///
unittest {
    assert(isClose(1.001f, 1.002f));
    assert(!isClose(1.0001f, 1.1f));
}

///
float floor(float input) {
    import core.stdc.math : floorl;

    return cast(float)floorl(input);
}

///
double floor(double input) {
    import core.stdc.math : floorl;

    return floorl(input);
}
