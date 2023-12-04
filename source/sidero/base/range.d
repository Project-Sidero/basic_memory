module sidero.base.range;
import sidero.base.traits;

/// From std.range.primitives, License: Boost
template ElementType(R) {
    static if(is(typeof(R.init.front.init) T))
        alias ElementType = T;
    else
        alias ElementType = void;
}
/// Ditto
template ElementEncodingType(R) {
    static if(is(StringTypeOf!R) && is(R : E[], E))
        alias ElementEncodingType = E;
    else
        alias ElementEncodingType = ElementType!R;
}
/// Ditto
enum bool isInputRange(R) = is(typeof(R.init) == R) && is(typeof((R r) { return r.empty; }(R.init)) == bool) &&
    (is(typeof((return ref R r) => r.front)) || is(typeof(ref(return ref R r) => r.front))) && !is(typeof((R r) {
            return r.front;
        }(R.init)) == void) && is(typeof((R r) => r.popFront));
/// Ditto
enum bool isForwardRange(R) = isInputRange!R && is(typeof((R r) { return r.save; }(R.init)) == R);
/// Ditto
enum bool isBidirectionalRange(R) = isForwardRange!R && is(typeof((R r) => r.popBack)) &&
    (is(typeof((return ref R r) => r.back)) || is(typeof(ref(return ref R r) => r.back))) && is(typeof(R.init.back.init) == ElementType!R);
/// Ditto
enum bool isOutputRange(R, E) = is(typeof(put(lvalueOf!R, lvalueOf!E)));

/// Ditto
template isInfinite(R)
{
    static if (isInputRange!R && __traits(compiles, { enum e = R.empty; }))
        enum bool isInfinite = !R.empty;
    else
        enum bool isInfinite = false;
}

/// Ditto
@property bool empty(T)(auto ref scope T a) if (is(typeof(a.length) : size_t)) {
    return !a.length;
}

/// Ditto
@property inout(T)[] save(T)(return scope inout(T)[] a) @safe pure nothrow @nogc {
    return a;
}

/// Ditto
void popFront(T)(scope ref inout(T)[] a) @safe pure nothrow @nogc if (!isAutodecodableString!(T[]) && !is(T[] == void[])) {
    assert(a.length, "Attempting to popFront() past the end of an array of " ~ T.stringof);
    a = a[1 .. $];
}

/// Ditto
void popFront(C)(scope ref inout(C)[] str) @trusted pure nothrow if (isAutodecodableString!(C[])) {
    import sidero.base.algorithm : min;

    assert(str.length, "Attempting to popFront() past the end of an array of " ~ C.stringof);

    static if(is(immutable C == immutable char)) {
        static immutable ubyte[] charWidthTab = [
            2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3,
            3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 1, 1
        ];

        immutable c = str[0];
        immutable charWidth = c < 192 ? 1 : charWidthTab.ptr[c - 192];
        str = str.ptr[min(str.length, charWidth) .. str.length];
    } else static if(is(immutable C == immutable wchar)) {
        immutable u = str[0];
        immutable seqLen = 1 + (u >= 0xD800 && u <= 0xDBFF);
        str = str.ptr[min(seqLen, str.length) .. str.length];
    } else
        static assert(0, "Bad template constraint.");
}
/// Ditto
void popBack(T)(scope ref inout(T)[] a) @safe pure nothrow @nogc if (!isAutodecodableString!(T[]) && !is(T[] == void[])) {
    assert(a.length);
    a = a[0 .. $ - 1];
}

/// Ditto
void popBack(T)(scope ref inout(T)[] a) @safe pure if (isAutodecodableString!(T[])) {
    import std.utf : strideBack;

    assert(a.length, "Attempting to popBack() past the front of an array of " ~ T.stringof);
    a = a[0 .. $ - strideBack(a, $)];
}

/// Ditto
@property ref inout(T) front(T)(return scope inout(T)[] a) @safe pure nothrow @nogc
        if (!isAutodecodableString!(T[]) && !is(T[] == void[])) {
    assert(a.length, "Attempting to fetch the front of an empty array of " ~ T.stringof);
    return a[0];
}

/// Ditto
@property dchar front(T)(scope const(T)[] a) @safe pure if (isAutodecodableString!(T[])) {
    import sidero.base.encoding.utf : decode;

    assert(a.length, "Attempting to fetch the front of an empty array of " ~ T.stringof);
    dchar ret;
    decode(a, ret);
    return ret;
}

/// Ditto
@property ref inout(T) back(T)(return scope inout(T)[] a) @safe pure nothrow @nogc
        if (!isAutodecodableString!(T[]) && !is(T[] == void[])) {
    assert(a.length, "Attempting to fetch the back of an empty array of " ~ T.stringof);
    return a[$ - 1];
}

/// Ditto
@property dchar back(T)(scope const(T)[] a) @safe pure if (isAutodecodableString!(T[])) {
    import std.utf : decode, strideBack;

    assert(a.length, "Attempting to fetch the back of an empty array of " ~ T.stringof);
    size_t i = a.length - strideBack(a, a.length);
    return decode(a, i);
}

// From std.algorithm. License: Boost
enum SortedRangeOptions
{
    /**
      Assume, that the range is sorted without checking.
   */
    assumeSorted,

    /**
      All elements of the range are checked to be sorted.
      The check is performed in O(n) time.
   */
    checkStrictly,

    /**
      Some elements of the range are checked to be sorted.
      For ranges with random order, this will almost surely
      detect, that it is not sorted. For almost sorted ranges
      it's more likely to fail. The checked elements are choosen
      in a deterministic manner, which makes this check reproducable.
      The check is performed in O(log(n)) time.
   */
    checkRoughly,
}

// From std.algorithm. License: Boost
struct SortedRange(Range, alias pred = "a < b",
SortedRangeOptions opt = SortedRangeOptions.assumeSorted)
if (isInputRange!Range && !isInstanceOf!(SortedRange, Range))
{
    import std.functional : binaryFun;

    private alias predFun = binaryFun!pred;
    private bool geq(L, R)(L lhs, R rhs)
    {
        return !predFun(lhs, rhs);
    }
    private bool gt(L, R)(L lhs, R rhs)
    {
        return predFun(rhs, lhs);
    }
    private Range _input;

    // Undocummented because a clearer way to invoke is by calling
    // assumeSorted.
    this(Range input)
    {
        static if (opt == SortedRangeOptions.checkRoughly)
        {
            roughlyVerifySorted(input);
        }
        static if (opt == SortedRangeOptions.checkStrictly)
        {
            strictlyVerifySorted(input);
        }
        this._input = input;
    }

    // Assertion only.
    static if (opt == SortedRangeOptions.checkRoughly)
        private void roughlyVerifySorted(Range r)
        {
            if (!__ctfe)
            {
                static if (isRandomAccessRange!Range && hasLength!Range)
                {
                    import core.bitop : bsr;
                    import sidero.base.algorithm.sorting : isSorted;
                    import std.exception : enforce;

                    // Check the sortedness of the input
                    if (r.length < 2) return;

                    immutable size_t msb = bsr(r.length) + 1;
                    assert(msb > 0 && msb <= r.length);
                    immutable step = r.length / msb;
                    auto st = stride(r, step);

                    enforce(isSorted!pred(st), "Range is not sorted");
                }
            }
        }

    // Assertion only.
    static if (opt == SortedRangeOptions.checkStrictly)
        private void strictlyVerifySorted(Range r)
        {
            if (!__ctfe)
            {
                static if (isRandomAccessRange!Range && hasLength!Range)
                {
                    import sidero.base.algorithm.sorting : isSorted;
                    import std.exception : enforce;

                    enforce(isSorted!pred(r), "Range is not sorted");
                }
            }
        }

    /// Range primitives.
    @property bool empty()             //const
    {
        return this._input.empty;
    }

    /// Ditto
    static if (isForwardRange!Range)
        @property auto save()
        {
            // Avoid the constructor
            typeof(this) result = this;
            result._input = _input.save;
            return result;
        }

    /// Ditto
    @property auto ref front()
    {
        return _input.front;
    }

    /// Ditto
    void popFront()
    {
        _input.popFront();
    }

    /// Ditto
    static if (isBidirectionalRange!Range)
    {
        @property auto ref back()
        {
            return _input.back;
        }

        /// Ditto
        void popBack()
        {
            _input.popBack();
        }
    }

    /// Ditto
    static if (isRandomAccessRange!Range)
        auto ref opIndex(size_t i)
        {
            return _input[i];
        }

    /// Ditto
    static if (hasSlicing!Range)
        auto opSlice(size_t a, size_t b) return scope
        {
            assert(
                a <= b,
                "Attempting to slice a SortedRange with a larger first argument than the second."
            );
            typeof(this) result = this;
            result._input = _input[a .. b];// skip checking
            return result;
        }

    mixin ImplementLength!_input;

    /**
    Releases the controlled range and returns it.

    This does the opposite of $(LREF assumeSorted): instead of turning a range
    into a `SortedRange`, it extracts the original range back out of the `SortedRange`
    using $(REF, move, std,algorithm,mutation).
*/
    auto release() return scope
    {
        import std.algorithm.mutation : move;
        return move(_input);
    }

    ///
    static if (is(Range : int[]))
        @safe unittest
        {
            import sidero.base.algorithm.sorting : sort;
            int[3] data = [ 1, 2, 3 ];
            auto a = assumeSorted(data[]);
            assert(a == sort!"a < b"(data[]));
            int[] p = a.release();
            assert(p == [ 1, 2, 3 ]);
        }

    // Assuming a predicate "test" that returns 0 for a left portion
    // of the range and then 1 for the rest, returns the index at
    // which the first 1 appears. Used internally by the search routines.
    private size_t getTransitionIndex(SearchPolicy sp, alias test, V)(V v)
    if (sp == SearchPolicy.binarySearch && isRandomAccessRange!Range && hasLength!Range)
    {
        size_t first = 0, count = _input.length;
        while (count > 0)
        {
            immutable step = count / 2, it = first + step;
            if (!test(_input[it], v))
            {
                first = it + 1;
                count -= step + 1;
            }
            else
            {
                count = step;
            }
        }
        return first;
    }

    // Specialization for trot and gallop
    private size_t getTransitionIndex(SearchPolicy sp, alias test, V)(V v)
    if ((sp == SearchPolicy.trot || sp == SearchPolicy.gallop)
    && isRandomAccessRange!Range)
    {
        if (empty || test(front, v)) return 0;
        immutable count = length;
        if (count == 1) return 1;
        size_t below = 0, above = 1, step = 2;
        while (!test(_input[above], v))
        {
            // Still too small, update below and increase gait
            below = above;
            immutable next = above + step;
            if (next >= count)
            {
                // Overshot - the next step took us beyond the end. So
                // now adjust next and simply exit the loop to do the
                // binary search thingie.
                above = count;
                break;
            }
            // Still in business, increase step and continue
            above = next;
            static if (sp == SearchPolicy.trot)
                ++step;
            else
                step <<= 1;
        }
        return below + this[below .. above].getTransitionIndex!(
            SearchPolicy.binarySearch, test, V)(v);
    }

    // Specialization for trotBackwards and gallopBackwards
    private size_t getTransitionIndex(SearchPolicy sp, alias test, V)(V v)
    if ((sp == SearchPolicy.trotBackwards || sp == SearchPolicy.gallopBackwards)
    && isRandomAccessRange!Range)
    {
        immutable count = length;
        if (empty || !test(back, v)) return count;
        if (count == 1) return 0;
        size_t below = count - 2, above = count - 1, step = 2;
        while (test(_input[below], v))
        {
            // Still too large, update above and increase gait
            above = below;
            if (below < step)
            {
                // Overshot - the next step took us beyond the end. So
                // now adjust next and simply fall through to do the
                // binary search thingie.
                below = 0;
                break;
            }
            // Still in business, increase step and continue
            below -= step;
            static if (sp == SearchPolicy.trot)
                ++step;
            else
                step <<= 1;
        }
        return below + this[below .. above].getTransitionIndex!(
            SearchPolicy.binarySearch, test, V)(v);
    }

    // lowerBound
    /**
   This function uses a search with policy `sp` to find the
   largest left subrange on which $(D pred(x, value)) is `true` for
   all `x` (e.g., if `pred` is "less than", returns the portion of
   the range with elements strictly smaller than `value`). The search
   schedule and its complexity are documented in
   $(LREF SearchPolicy).
*/
    auto lowerBound(SearchPolicy sp = SearchPolicy.binarySearch, V)(V value)
    if (isTwoWayCompatible!(predFun, ElementType!Range, V)
    && hasSlicing!Range)
    {
        return this[0 .. getTransitionIndex!(sp, geq)(value)];
    }

    ///
    static if (is(Range : int[]))
        @safe unittest
        {
            import sidero.base.algorithm : equal;
            auto a = assumeSorted([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 ]);
            auto p = a.lowerBound(4);
            assert(equal(p, [ 0, 1, 2, 3 ]));
        }

    // upperBound
    /**
This function searches with policy `sp` to find the largest right
subrange on which $(D pred(value, x)) is `true` for all `x`
(e.g., if `pred` is "less than", returns the portion of the range
with elements strictly greater than `value`). The search schedule
and its complexity are documented in $(LREF SearchPolicy).

For ranges that do not offer random access, `SearchPolicy.linear`
is the only policy allowed (and it must be specified explicitly lest it exposes
user code to unexpected inefficiencies). For random-access searches, all
policies are allowed, and `SearchPolicy.binarySearch` is the default.
*/
    auto upperBound(SearchPolicy sp = SearchPolicy.binarySearch, V)(V value)
    if (isTwoWayCompatible!(predFun, ElementType!Range, V))
    {
        static assert(hasSlicing!Range || sp == SearchPolicy.linear,
        "Specify SearchPolicy.linear explicitly for "
        ~ typeof(this).stringof);
        static if (sp == SearchPolicy.linear)
        {
            for (; !_input.empty && !predFun(value, _input.front);
                _input.popFront())
            {
            }
            return this;
        }
        else
        {
            return this[getTransitionIndex!(sp, gt)(value) .. length];
        }
    }

    ///
    static if (is(Range : int[]))
        @safe unittest
        {
            import sidero.base.algorithm : equal;
            auto a = assumeSorted([ 1, 2, 3, 3, 3, 4, 4, 5, 6 ]);
            auto p = a.upperBound(3);
            assert(equal(p, [4, 4, 5, 6]));
        }


    // equalRange
    /**
   Returns the subrange containing all elements `e` for which both $(D
   pred(e, value)) and $(D pred(value, e)) evaluate to `false` (e.g.,
   if `pred` is "less than", returns the portion of the range with
   elements equal to `value`). Uses a classic binary search with
   interval halving until it finds a value that satisfies the condition,
   then uses `SearchPolicy.gallopBackwards` to find the left boundary
   and `SearchPolicy.gallop` to find the right boundary. These
   policies are justified by the fact that the two boundaries are likely
   to be near the first found value (i.e., equal ranges are relatively
   small). Completes the entire search in $(BIGOH log(n)) time.
*/
    auto equalRange(V)(V value)
    if (isTwoWayCompatible!(predFun, ElementType!Range, V)
    && isRandomAccessRange!Range)
    {
        size_t first = 0, count = _input.length;
        while (count > 0)
        {
            immutable step = count / 2;
            auto it = first + step;
            if (predFun(_input[it], value))
            {
                // Less than value, bump left bound up
                first = it + 1;
                count -= step + 1;
            }
            else if (predFun(value, _input[it]))
            {
                // Greater than value, chop count
                count = step;
            }
            else
            {
                // Equal to value, do binary searches in the
                // leftover portions
                // Gallop towards the left end as it's likely nearby
                immutable left = first
                + this[first .. it]
                .lowerBound!(SearchPolicy.gallopBackwards)(value).length;
                first += count;
                // Gallop towards the right end as it's likely nearby
                immutable right = first
                - this[it + 1 .. first]
                .upperBound!(SearchPolicy.gallop)(value).length;
                return this[left .. right];
            }
        }
        return this.init;
    }

    ///
    static if (is(Range : int[]))
        @safe unittest
        {
            import sidero.base.algorithm : equal;
            auto a = [ 1, 2, 3, 3, 3, 4, 4, 5, 6 ];
            auto r = a.assumeSorted.equalRange(3);
            assert(equal(r, [ 3, 3, 3 ]));
        }

    // trisect
    /**
Returns a tuple `r` such that `r[0]` is the same as the result
of `lowerBound(value)`, `r[1]` is the same as the result of $(D
equalRange(value)), and `r[2]` is the same as the result of $(D
upperBound(value)). The call is faster than computing all three
separately. Uses a search schedule similar to $(D
equalRange). Completes the entire search in $(BIGOH log(n)) time.
*/
    auto trisect(V)(V value)
    if (isTwoWayCompatible!(predFun, ElementType!Range, V)
    && isRandomAccessRange!Range && hasLength!Range)
    {
        import std.typecons : tuple;
        size_t first = 0, count = _input.length;
        while (count > 0)
        {
            immutable step = count / 2;
            auto it = first + step;
            if (predFun(_input[it], value))
            {
                // Less than value, bump left bound up
                first = it + 1;
                count -= step + 1;
            }
            else if (predFun(value, _input[it]))
            {
                // Greater than value, chop count
                count = step;
            }
            else
            {
                // Equal to value, do binary searches in the
                // leftover portions
                // Gallop towards the left end as it's likely nearby
                immutable left = first
                + this[first .. it]
                .lowerBound!(SearchPolicy.gallopBackwards)(value).length;
                first += count;
                // Gallop towards the right end as it's likely nearby
                immutable right = first
                - this[it + 1 .. first]
                .upperBound!(SearchPolicy.gallop)(value).length;
                return tuple(this[0 .. left], this[left .. right],
                this[right .. length]);
            }
        }
        // No equal element was found
        return tuple(this[0 .. first], this.init, this[first .. length]);
    }

    ///
    static if (is(Range : int[]))
        @safe unittest
        {
            import sidero.base.algorithm : equal;
            auto a = [ 1, 2, 3, 3, 3, 4, 4, 5, 6 ];
            auto r = assumeSorted(a).trisect(3);
            assert(equal(r[0], [ 1, 2 ]));
            assert(equal(r[1], [ 3, 3, 3 ]));
            assert(equal(r[2], [ 4, 4, 5, 6 ]));
        }

    // contains
    /**
Returns `true` if and only if `value` can be found in $(D
range), which is assumed to be sorted. Performs $(BIGOH log(r.length))
evaluations of `pred`.
 */

    bool contains(V)(V value)
    if (isRandomAccessRange!Range)
    {
        if (empty) return false;
        immutable i = getTransitionIndex!(SearchPolicy.binarySearch, geq)(value);
        if (i >= length) return false;
        return !predFun(value, _input[i]);
    }

    /**
Like `contains`, but the value is specified before the range.
*/
    bool opBinaryRight(string op, V)(V value)
    if (op == "in" && isRandomAccessRange!Range)
    {
        return contains(value);
    }

    // groupBy
    /**
Returns a range of subranges of elements that are equivalent according to the
sorting relation.
 */
    auto groupBy()()
    {
        import sidero.base.algorithm : chunkBy;
        return _input.chunkBy!((a, b) => !predFun(a, b) && !predFun(b, a));
    }
}

///
template SortedRange(Range, alias pred = "a < b",
SortedRangeOptions opt = SortedRangeOptions.assumeSorted)
if (isInstanceOf!(SortedRange, Range))
{
    // Avoid nesting SortedRange types (see https://issues.dlang.org/show_bug.cgi?id=18933);
    alias SortedRange = SortedRange!(Unqual!(typeof(Range._input)), pred, opt);
}

// From std.algorithm. License: Boost
auto assumeSorted(alias pred = "a < b", R)(R r)
if (isInputRange!(Unqual!R))
{
    // Avoid senseless `SortedRange!(SortedRange!(...), pred)` nesting.
    static if (is(R == SortedRange!(RRange, RPred), RRange, alias RPred))
    {
        static if (isInputRange!R && __traits(isSame, pred, RPred))
        // If the predicate is the same and we don't need to cast away
        // constness for the result to be an input range.
            return r;
        else
            return SortedRange!(Unqual!(typeof(r._input)), pred)(r._input);
    }
    else
    {
        return SortedRange!(Unqual!R, pred)(r);
    }
}
