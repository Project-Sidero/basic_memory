module sidero.base.errors.stock;
import sidero.base.errors.message;

///
enum {
    ///
    NullPointerException = ErrorMessage("NPE", "Null Pointer Exception"),
    ///
    MalformedInputException = ErrorMessage("MIE",
            "Malformed Input Exception"),
    ///
    RangeException = ErrorMessage("RE", "Range Exception"),
    ///
    FailedToAllocateError = ErrorMessage("FTAE", "Failed To Allocate Memory"),
    ///
    NonMatchingStateToArgumentException = ErrorMessage("NMSTA",
            "Argument provided does not map into state"),
    ///
    TimeOutException = ErrorMessage("TOE", "Timeout exception"),
    ///
    PlatformNotImplementedException = ErrorMessage("PNIE", "Platform is not implemented"),
    ///
    UnknownPlatformBehaviorException = ErrorMessage("UPBE", "Platform behavior is unexpected"),
}
