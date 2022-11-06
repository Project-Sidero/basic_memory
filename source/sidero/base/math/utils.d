module sidero.base.math.utils;
import std.traits : isFloatingPoint;

@safe nothrow @nogc:

///
enum DefaultMaxRelativeDifference(ForType) = (cast(ForType)10) ^^ -(ForType.dig / 2);

/// Similar to std.math : isClose.
bool isClose(A, B, CommonType = typeof(A.init + B.init))(A a, B b,
        CommonType maxRelativeDifference = DefaultMaxRelativeDifference!CommonType, CommonType maxAbsoluteDifference = 0f)
        if (isFloatingPoint!A && isFloatingPoint!B) {

    import core.stdc.math : fabs, fabsf;

    if (a == A.infinity || a == -A.infinity || b == B.infinity || b == -B.infinity)
        return false;

    static if (is(CommonType == float)) {
        alias abs = fabsf;
    } else static if (is(CommonType == double)) {
        alias abs = fabs;
    } else
        static assert(0, "Unimplemented");

    CommonType absoluteA = abs(a), absoluteB = abs(b), difference = abs(a - b);

    if (a == 0 || b == 0 || (absoluteA + absoluteB < CommonType.min_normal)) {
        // special check to look for when we are close to zero
        return difference < CommonType.epsilon * CommonType.min_normal;
    }

    return difference <= maxRelativeDifference * absoluteA || difference <= maxRelativeDifference * absoluteB ||
        difference <= maxAbsoluteDifference;
}

///
unittest {
    assert(isClose(1.001f, 1.002f));
    assert(!isClose(1.0001f, 1.1f));
}
