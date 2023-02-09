module sidero.base.math.linear_algebra.matrix;
import sidero.base.math.linear_algebra.vector;
import sidero.base.math.utils;
import sidero.base.errors;
import std.traits : isNumeric;

export @safe nothrow @nogc:

///
alias Mat3x3f = Matrix!(float, 3, 3);
///
alias Mat3x3d = Matrix!(double, 3, 3);

///
struct AllRowColumn {
    private int _;
}
///
enum allRowColumns = AllRowColumn.init;

// RxC
struct Matrix(Type, size_t Rows, size_t Columns) {
    static assert(Rows > 0, "Rows must be above zero");
    static assert(Columns > 0, "Columns must be above zero");

    ///
    Type[Rows * Columns] data;

@safe nothrow @nogc:

    static {
        ///
        Matrix zero() {
            Matrix ret;

            foreach (ref v; ret.data)
                v = 0;

            return ret;
        }

        ///
        Matrix one() {
            Matrix ret;

            foreach (ref v; ret.data)
                v = 1;

            return ret;
        }

        ///
        Matrix identity() {
            Matrix ret;
            .identity(ret.data[], Columns);
            return ret;
        }
    }

    ///
    this(scope Type[] data...) scope {
        assert(data.length == this.data.length);

        foreach (i, v; data)
            this.data[i] = v;
    }

    ///
    Type opIndex(size_t x, size_t y) scope const {
        return this.data[(y * Columns) + x];
    }

    ///
    unittest {
        auto mat = Matrix!(Type, 2, 2)(1, 2, 3, 4);
        assert(mat[0, 1].isClose(3));
    }

    ///
    void opIndexAssign(Type value, size_t x, size_t y) scope {
        this.data[(y * Columns) + x] = value;
    }

    ///
    unittest {
        auto mat = Matrix!(Type, 2, 2)(1, 2, 3, 4);
        assert(mat[1, 0].isClose(2));
        mat[1, 0] = 9;
        assert(mat[1, 0].isClose(9));
    }

    ///
    void opIndexOpAssign(string op, Scalar)(Scalar input, size_t x, size_t y) scope if (isNumeric!Scalar) {
        static if (op == "^^") {
            import core.stdc.math : pow;

            this.data[(y * Columns) + x] = pow(this.data[(y * Columns) + x], input);
        } else
            mixin("this.data[(y * Columns) + x] " ~ op ~ "= input;");
    }

    ///
    unittest {
        Matrix mat = Matrix.one;
        mat[0, 0] *= 2;
        assert(mat[0, 0].isClose(2));
    }

    /// By row apply op
    void opIndexOpAssign(string op, Scalar)(Scalar input, size_t x, AllRowColumn _) scope {
        foreach(y; 0 .. Columns) {
            static if (op == "^^") {
                import core.stdc.math : pow;

                this.data[(y * Columns) + x] = pow(this.data[(y * Columns) + x], input);
            } else
                mixin("this.data[(y * Columns) + x] " ~ op ~ "= input;");
        }
    }

    ///
    unittest {
        Matrix ret = Matrix.one;
        ret[0, allRowColumns] *= 1f;
    }

    /// By row apply op
    void opIndexOpAssign(string op)(Vector!(Type, Columns) input, size_t x, AllRowColumn _) scope {
        foreach(y; 0 .. Columns) {
            static if (op == "^^") {
                import core.stdc.math : pow;

                this.data[(y * Columns) + x] = pow(this.data[(y * Columns) + x], input);
            } else
                mixin("this.data[(y * Columns) + x] " ~ op ~ "= input[y];");
        }
    }

    ///
    unittest {
        Matrix ret = Matrix.one;
        ret[0, allRowColumns] *= Vector!(Type, Columns).zero;
    }

    /// By column apply op
    void opIndexOpAssign(string op, Scalar)(Scalar input, AllRowColumn _, size_t y) scope {
        foreach(x; 0 .. Rows) {
            static if (op == "^^") {
                import core.stdc.math : pow;

                this.data[(y * Columns) + x] = pow(this.data[(y * Columns) + x], input);
            } else
                mixin("this.data[(y * Columns) + x] " ~ op ~ "= input;");
        }
    }

    ///
    unittest {
        Matrix ret = Matrix.one;
        ret[allRowColumns, 0] *= Vector!(Type, Rows).zero;
    }

    /// By column apply op
    void opIndexOpAssign(string op)(Vector!(Type, Rows) input, AllRowColumn _, size_t y) scope {
        foreach(x; 0 .. Rows) {
            static if (op == "^^") {
                import core.stdc.math : pow;

                this.data[(y * Columns) + x] = pow(this.data[(y * Columns) + x], input);
            } else
                mixin("this.data[(y * Columns) + x] " ~ op ~ "= input[x];");
        }
    }

    ///
    unittest {
        Matrix ret = Matrix.one;
        ret[allRowColumns, 0] *= Vector!(Type, Rows).zero;
    }

    /// Element wise
    Matrix opBinary(string op)(scope const Matrix other) scope const {
        Matrix ret = this;
        ret.opOpAssign!op(other);
        return ret;
    }

    ///
    unittest {
        assert(Matrix.one + (Matrix.one * -1) == Matrix.zero);
    }

    /// Element wise
    Matrix opBinary(string op, Scalar)(Scalar input) scope if (isNumeric!Scalar) {
        Matrix ret = this;
        ret.opOpAssign!op(input);
        return ret;
    }

    ///
    unittest {
        assert(Matrix.one * -1 < Matrix.zero);
    }

    /// Element wise
    void opOpAssign(string op)(scope const Matrix other) scope {
        foreach (i, ref v; this.data) {
            static if (op == "^^") {
                import core.stdc.math : pow;

                v = pow(v, other.data[i]);
            } else
                mixin("v " ~ op ~ "= other.data[i];");
        }
    }

    ///
    unittest {
        Matrix mat = Matrix.one;
        mat += -Matrix.one;
        assert(mat == Matrix.zero);
    }

    /// Element wise
    void opOpAssign(string op, Scalar)(Scalar input) scope if (isNumeric!Scalar) {
        foreach (ref v; this.data) {
            static if (op == "^^") {
                import core.stdc.math : pow;
                v = pow(v, input);
            } else
                mixin("v " ~ op ~ "= input;");
        }
    }

    ///
    unittest {
        Matrix mat = Matrix.one;
        mat *= -1;
        assert(mat < Matrix.zero);
    }

    ///
    Matrix opUnary(string op : "-")() scope const {
        Matrix ret;

        foreach (i; 0 .. this.data.length)
            ret.data[i] = -this.data[i];

        return ret;
    }

    ///
    unittest {
        assert(-Matrix.one < Matrix.zero);
    }

    ///
    Matrix!(CommonType, Rows, OtherColumns) dotProduct(TypeOther, size_t OtherRows, size_t OtherColumns,
            CommonType = typeof(Type.init + TypeOther.init))(const Matrix!(TypeOther, OtherRows, OtherColumns) other) scope const {

        typeof(return) ret;

        auto got = .dotProduct(ret.data[], this.data[], Columns, other.data[], OtherColumns);
        assert(got);

        return ret;
    }

    ///
    Vector!(CommonType, Rows) dotProduct(TypeOther, size_t OtherRows, CommonType = typeof(Type.init + TypeOther.init))(
            const Vector!(TypeOther, OtherRows) other) scope const {

        typeof(return) ret;

        auto got = .dotProduct(ret.data[], this.data[], Columns, other.data[], 1);
        assert(got);

        return ret;
    }

    ///
    Type sum() scope const {
        import std.algorithm.iteration : sum;

        return sum(this.data[]);
    }

    ///
    Matrix transpose() scope const {
        Matrix ret;

        auto got = .transpose(ret.data[], this.data[], Columns);
        assert(got);

        return ret;
    }

    ///
    bool isDiagonal() scope const {
        return .isDiagonal(this.data[], Columns);
    }

    ///
    bool isTriangular() scope const {
        return .isTriangular(this.data[], Columns);
    }

    ///
    bool isTriangularUpper() scope const {
        return .isTriangularUpper(this.data[], Columns);
    }

    ///
    bool isTriangularLower() scope const {
        return .isTriangularLower(this.data[], Columns);
    }

    static {
        ///
        bool isSquare() {
            return Rows == Columns;
        }

        ///
        bool isTall() {
            return Rows > Columns;
        }

        ///
        bool isWide() {
            return Columns > Rows;
        }

        ///
        bool isScalar() {
            return Columns == 1 && Rows == 1;
        }

        ///
        bool isVector() {
            return (Columns == 1 && Rows > 1) || (Columns > 1 && Rows == 1);
        }
    }

    ///
    bool isInverseOf(const Matrix other) scope const {
        Matrix buffer;

        auto got = .isInverseOf(buffer.data[], this.data[], other.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    bool isPermutation() scope const {
        auto got = .isPermutation(this.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    bool isSymmetric() scope const {
        auto got = .isSymmetric(this.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    bool isRowEchelonForm(bool leadingCoefficientIsOne = false) scope const {
        auto got = .isRowEchelonForm(this.data[], Columns, leadingCoefficientIsOne);
        assert(got);

        return got.get;
    }

    ///
    bool isReducedRowEchelonForm() scope const {
        auto got = .isReducedRowEchelonForm(this.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    bool isRowEchelonFormReducible() scope const {
        Matrix temp;

        auto got = .isRowEchelonFormReducible(temp.data[], this.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    size_t rank() scope const {
        Matrix temp;

        auto got = .rank(temp.data[], this.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    Matrix rowEchelonForm(bool leadingCoefficientIsOne = false) scope const {
        Matrix ret;

        auto got = .rowEchelonForm(ret.data[], this.data[], Columns, leadingCoefficientIsOne);
        assert(got);

        return ret;
    }

    ///
    Matrix inverse() scope const {
        Matrix ret, buffer;

        auto got = .inverse(ret.data[], buffer.data[], this.data[], Columns);
        assert(got);

        return ret;
    }

    ///
    Type determinant() scope const {
        Matrix buffer;

        auto got = .determinant(buffer.data[], this.data[], Columns);
        assert(got);

        return got.get;
    }

    ///
    ulong toHash() scope const {
        return hashOf(this.data[]);
    }

    ///
    alias equals = opEquals;

    ///
    bool opEquals(scope const Matrix other) scope const {
        foreach (i; 0 .. this.data.length) {
            if (!this.data[i].isClose(other.data[i]))
                return false;
        }

        return true;
    }

    ///
    bool equals(scope const Matrix other, Type maxRelativeDifference, Type maxAbsoluteDifference = 0) scope const {
        foreach (i; 0 .. this.data.length) {
            if (!this.data[i].isClose(other.data[i], maxRelativeDifference, maxAbsoluteDifference))
                return false;
        }

        return true;
    }

    ///
    alias compare = opCmp;

    ///
    int opCmp(scope const Matrix other) scope const {
        foreach (i; 0 .. this.data.length) {
            if (this.data[i] < other.data[i])
                return -1;
            else if (this.data[i] > other.data[i])
                return 1;
        }

        return 0;
    }
}

///
ErrorResult identity(Type)(scope Type[] data, size_t columns) {
    if (data.length % columns != 0)
        return ErrorResult(RangeException("Data length must be a multiple of columns"));

    size_t row;

    while (data.length > 0 && row < columns) {
        foreach (i; 0 .. columns)
            data[i] = 0;
        data[row] = 1;

        data = data[columns .. $];
        row++;
    }

    foreach (ref v; data)
        v = 0;

    return ErrorResult();
}

///
unittest {
    static Expected = [1f, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0];
    float[12] buffer;

    ErrorResult result = identity(buffer[], 3);
    assert(result);

    foreach (i, v; buffer) {
        assert(v.isClose(Expected[i]));
    }
}

///
ErrorResult transpose(Type)(scope Type[] output, scope const(Type)[] input, size_t columns) {
    if (output.length != input.length)
        return ErrorResult(RangeException("Input length must match output"));
    else if (output.length % columns != 0)
        return ErrorResult(RangeException("Data length must be a multiple of columns"));

    const rows = input.length / columns;
    size_t x, y;

    while (input.length > 0) {
        output[(x * rows) + y] = input[0];

        x++;
        if (x == columns) {
            x = 0;
            y++;
        }

        input = input[1 .. $];
    }

    return ErrorResult();
}

///
unittest {
    static float[][] Values = [[1, 2, 3, 4], [1, 2, 3, 4, 5, 6, 7, 8, 9], [1, 2, 3, 4, 5, 6]];
    static float[][] Expecteds = [[1, 3, 2, 4], [1, 4, 7, 2, 5, 8, 3, 6, 9], [1, 4, 2, 5, 3, 6]];
    static Columns = [2, 3, 3];

    float[9] buffer;

    foreach (i, Column; Columns) {
        float[] input = Values[i];
        float[] expected = Expecteds[i];
        scope output = buffer[0 .. expected.length];

        ErrorResult result = transpose(output, input, Column);
        assert(result);

        foreach (j, v; output) {
            assert(v.isClose(expected[j]));
        }
    }
}

///
bool isDiagonal(Type)(scope const(Type)[] input, size_t columns) {
    const rows = input.length / columns;
    if (rows != columns || input.length != rows * columns)
        return false;

    // 0's everywhere except on the diagonal
    size_t y;

    while (input.length > 0) {
        foreach (x; 0 .. y) {
            if (!input[x].isClose(0))
                return false;
        }

        foreach (x; y + 1 .. columns) {
            if (!input[x].isClose(0))
                return false;
        }

        y++;
        input = input[columns .. $];
    }

    return true;
}

///
unittest {
    static Values1 = [1f, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16], Values2 = [1f, 0, 0, 0, 2, 0, 0, 0, 3];

    assert(!Values1.isDiagonal(4));
    assert(Values2.isDiagonal(3));
}

///
bool isTriangular(Type)(scope const(Type)[] input, size_t columns) {
    return isTriangularUpper(input, columns) || isTriangularLower(input, columns);
}

///
bool isTriangularUpper(Type)(scope const(Type)[] input, size_t columns) {
    const rows = input.length / columns;
    if (rows != columns || input.length != rows * columns)
        return false;

    // 0's everywhere except on the diagonal
    size_t y;

    while (input.length > 0) {
        foreach (x; 0 .. y) {
            if (!input[x].isClose(0))
                return false;
        }

        y++;
        input = input[columns .. $];
    }

    return true;
}

///
unittest {
    static Values1 = [1f, 0, 0, 4, 5, 0, 7, 8, 9], Values2 = [1f, 2, 3, 0, 5, 6, 0, 0, 9];
    assert(!isTriangularUpper(Values1, 3));
    assert(isTriangularUpper(Values2, 3));
}

///
bool isTriangularLower(Type)(scope const(Type)[] input, size_t columns) {
    const rows = input.length / columns;
    if (rows != columns || input.length != rows * columns)
        return false;

    // 0's everywhere except on the diagonal
    size_t y;

    while (input.length > 0) {
        foreach (x; y + 1 .. columns) {
            if (!input[x].isClose(0))
                return false;
        }

        y++;
        input = input[columns .. $];
    }

    return true;
}

///
unittest {
    static Values1 = [1f, 0, 0, 4, 5, 0, 7, 8, 9], Values2 = [1f, 2, 3, 0, 5, 6, 0, 0, 9];
    assert(isTriangularLower(Values1, 3));
    assert(!isTriangularLower(Values2, 3));
}

/// [Rows, Columns]
size_t[2] dotProductOutputSizes(size_t rows1, size_t columns1, size_t rows2, size_t columns2) {
    const outputRows = rows1;
    const outputColumns = columns2;

    return [outputRows, outputColumns];
}

///
unittest {
    assert(dotProductOutputSizes(2, 2, 2, 2) == [2, 2]);
    assert(dotProductOutputSizes(2, 2, 2, 3) == [2, 3]);
}

/// The nominal method of multiplicating two matrices together
ErrorResult dotProduct(TypeOut, TypeIn1, TypeIn2)(scope TypeOut[] output, scope const TypeIn1[] input1, size_t columns1,
        scope const TypeIn2[] input2, size_t columns2) {
    const rows1 = input1.length / columns1, rows2 = input2.length / columns2;

    size_t outputRows, outputColumns;

    if (input1.length % columns1 != 0)
        return typeof(return)(RangeException("Input 1 length must be a multiple of columns"));
    else if (input2.length % columns2 != 0)
        return typeof(return)(RangeException("Input 2 length must be a multiple of columns"));

    {
        auto got = dotProductOutputSizes(rows1, columns1, rows2, columns2);
        outputRows = got[0];
        outputColumns = got[1];
    }

    if (output.length != outputRows * outputColumns)
        return ErrorResult(RangeException("Output length must match calculated size"));

    const Length = columns1;

    foreach (outputRow; 0 .. rows1) {
        foreach (outputColumn; 0 .. columns2) {
            TypeOut temp = 0;

            foreach (offset; 0 .. Length) {
                temp += input1[(outputRow * columns1) + offset] * input2[(offset * columns2) + outputColumn];
            }

            output[0] = temp;
            output = output[1 .. $];
        }
    }

    return typeof(return)();
}

///
unittest {
    static float[][] Input1 = [[3, 2, 6, 4], [1, 2, 3, 4]];
    static float[][] Input2 = [[4, -2, -6, 3], [5, 7, 9, 6, 8, 10]];
    static float[][] Expecteds = [[0, 0, 0, 0], [17, 23, 29, 39, 53, 67]];
    // row/column
    static size_t[6][] Sizes = [[2, 2, 2, 2, 2, 2], [2, 2, 2, 3, 2, 3]];

    float[6] buffers;

    foreach (i, Size3; Sizes) {
        auto input1 = Input1[i];
        auto input2 = Input2[i];
        auto expected = Expecteds[i];
        auto output = buffers[0 .. Size3[4] * Size3[5]];

        auto got = dotProduct(output, input1, Size3[1], input2, Size3[3]);
        assert(got);

        foreach (j, v; output) {
            assert(v.isClose(expected[j]));
        }
    }
}

///
Result!bool isInverseOf(Type)(scope Type[] buffer, scope const Type[] input1, scope const Type[] input2, size_t columns) {
    if (input1.length % columns != 0)
        return Result!bool(RangeException("Input lengths must be a multiple of columns"));
    else if (input1.length != input2.length || input1.length != buffer.length)
        return Result!bool(RangeException("Input and output lengths must match"));

    const rows = buffer.length / columns;

    if (rows != columns)
        return typeof(return)(false);

    auto result = dotProduct(buffer, input1, columns, input2, columns);
    if (!result)
        return typeof(return)(result.getError);

    size_t y;

    while (buffer.length > 0) {
        foreach (x; 0 .. y) {
            if (!buffer[x].isClose(0))
                return typeof(return)(false);
        }

        if (!buffer[y].isClose(1))
            return typeof(return)(false);

        foreach (x; y + 1 .. columns) {
            if (!buffer[x].isClose(0))
                return typeof(return)(false);
        }

        y++;
        buffer = buffer[columns .. $];
    }

    return typeof(return)(true);
}

///
unittest {
    static Values1 = [[7f, -2, -3, 1], [1f, 2, 3, 7]];
    static float[][] Values2 = [[0.75, .5, 0.25, 0.5, 1, 0.5, 0.25, 0.5, 0.75], [2, -1, 0, -1, 2, -1, 0, -1, 2]];

    float[9] buffer;
    Result!bool ret;

    ret = isInverseOf(buffer[0 .. 4], Values1[0], Values1[1], 2);
    assert(ret);
    assert(ret.get);

    ret = isInverseOf(buffer[0 .. 9], Values2[0], Values2[1], 3);
    assert(ret);
    assert(ret.get);
}

///
Result!bool isPermutation(Type)(scope const(Type)[] input, size_t columns) {
    if (input.length % columns != 0)
        return Result!bool(RangeException("Input lengths must be a multiple of columns"));
    const rows = input.length / columns;

    auto tempRow = input;
    while (tempRow.length > 0) {
        uint numberOfOnes;

        foreach (v; tempRow[0 .. columns]) {
            if (v.isClose(1))
                numberOfOnes++;
            else if (!v.isClose(0))
                return typeof(return)(false);
        }

        if (numberOfOnes != 1)
            return typeof(return)(false);

        tempRow = tempRow[columns .. $];
    }

    foreach (x; 0 .. columns) {
        uint numberOfOnes;

        foreach (y; 0 .. rows) {
            Type v = input[(y * columns) + x];

            if (v.isClose(1))
                numberOfOnes++;
            else if (!v.isClose(0))
                return typeof(return)(false);
        }

        if (numberOfOnes != 1)
            return typeof(return)(false);
    }

    return typeof(return)(true);
}

///
unittest {
    static Values1 = [1f, 0, 0, 0, 1, 0, 0, 0, 1], Values2 = [1f, 0, 0, 0, 3f, 0, 0, 0, 1];

    Result!bool got;

    got = isPermutation(Values1, 3);
    assert(got);
    assert(got.get);

    got = isPermutation(Values2, 3);
    assert(got);
    assert(!got.get);
}

///
Result!bool isSymmetric(Type)(scope const(Type)[] input, size_t columns) {
    if (input.length % columns != 0)
        return typeof(return)(RangeException("Data length must be a multiple of columns"));

    const rows = input.length / columns;
    size_t x, y;

    auto tempInput = input;

    while (tempInput.length > 0) {
        if (!input[(x * rows) + y].isClose(tempInput[0]))
            return typeof(return)(false);

        x++;
        if (x == columns) {
            x = 0;
            y++;
        }

        tempInput = tempInput[1 .. $];
    }

    return typeof(return)(true);
}

///
unittest {
    static Values1 = [1, 2, 2, 1], Values2 = [1, 2, 0, 1];

    Result!bool got;

    got = isSymmetric(Values1, 2);
    assert(got);
    assert(got.get);

    got = isSymmetric(Values2, 2);
    assert(got);
    assert(!got.get);
}

///
Result!bool isRowEchelonForm(Type)(scope const(Type)[] input, size_t columns, bool leadingCoefficientIsOne = true) {
    if (input.length % columns != 0)
        return Result!bool(RangeException("Data length must be a multiple of columns"));

    const rows = input.length / columns;
    ptrdiff_t lastColumnNonZero = -1;
    bool haveAllZero;

    auto temp = input;

    foreach (y; 0 .. rows) {
        if (isZeroVector(temp[0 .. columns])) {
            haveAllZero = true;
            temp = temp[columns .. $];
            continue;
        } else if (haveAllZero) {
            return typeof(return)(false);
        }

        // leading zeros
        foreach (x; 0 .. lastColumnNonZero) {
            if (!temp[x].isClose(0)) {
                return typeof(return)(false);
            }
        }

        foreach (x; lastColumnNonZero > -1 ? lastColumnNonZero : 0 .. columns) {
            Type value = temp[x];

            if (value.isClose(0)) {
                // ok
            } else if (!leadingCoefficientIsOne || value.isClose(1)) {
                lastColumnNonZero = x;

                // zeros below
                foreach (y2; 1 .. rows - y) {
                    if (!temp[(y2 * columns) + x].isClose(0)) {
                        return typeof(return)(false);
                    }
                }

                break;
            } else {
                return typeof(return)(false);
            }
        }

        temp = temp[columns .. $];
    }

    return typeof(return)(true);
}

///
unittest {
    // matrix 4x4
    static Values1 = [1, 3, 4, 5, 0, 1, 6, 7, 0, 0, 1, 8, 0, 0, 0, 0], Values2 = [
        1, 3, 4, 5, 0, 1, 6, 7, 0, 0, 0, 0, 0, 0, 1, 8
    ];

    Result!bool got;

    got = Values1.isRowEchelonForm(4);
    assert(got);
    assert(got.get);

    got = Values2.isRowEchelonForm(4);
    assert(got);
    assert(!got.get);
}

unittest {
    static allArrays = [
        [1f, 0, 0, 3], [1f, 0, 0, 0, 1, 0], [0f, 1, 1, 0], [0f, 0, 0, 0, 0, 0], [1f, 0, 0, 0, 0, 0, 0, 1, 0],
        [0f, 1, 0, 3, 0, 0, 1, 2, 0, 0, 0, 0], [1f, -2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    ];
    static columns = [2, 3, 2, 3, 3, 4, 4];
    static expecteds = [[true, true, false, true, false, true, true], [false, true, false, true, false, true, true]];

    foreach (expectedI, expected; expecteds) {
        bool isLeadingOne = expectedI == 1;

        foreach (arrayI, column; columns) {
            auto data = allArrays[arrayI];

            Result!bool got = isRowEchelonForm(data, column, isLeadingOne);
            assert(got);

            assert(got.get == expected[arrayI]);
        }
    }
}

///
Result!bool isReducedRowEchelonForm(Type)(scope const(Type)[] input, size_t columns) {
    if (input.length % columns != 0)
        return Result!bool(RangeException("Data length must be a multiple of columns"));

    const rows = input.length / columns;
    ptrdiff_t lastColumnNonZero = -1;
    bool haveAllZero;

    auto temp = input;

    foreach (y; 0 .. rows) {
        if (isZeroVector(temp[0 .. columns])) {
            haveAllZero = true;
            temp = temp[columns .. $];
            continue;
        } else if (haveAllZero) {
            return typeof(return)(false);
        }

        // leading zeros
        foreach (x; 0 .. lastColumnNonZero) {
            if (!temp[x].isClose(0)) {
                return typeof(return)(false);
            }
        }

        foreach (x; lastColumnNonZero > -1 ? lastColumnNonZero : 0 .. columns) {
            Type value = temp[x];

            if (value.isClose(0)) {
                // ok
            } else if (value.isClose(1)) {
                lastColumnNonZero = x;

                // zeros above
                foreach (y2; 0 .. y) {
                    if (!input[(y2 * columns) + x].isClose(0))
                        return typeof(return)(false);
                }

                // zeros below
                foreach (y2; 1 .. rows - y) {
                    if (!temp[(y2 * columns) + x].isClose(0)) {
                        return typeof(return)(false);
                    }
                }

                break;
            } else {
                return typeof(return)(false);
            }
        }

        temp = temp[columns .. $];
    }

    return typeof(return)(true);
}

///
unittest {
    static allArrays = [
        [1f, 0, 0, 3], [1f, 0, 0, 0, 1, 0], [0f, 1, 1, 0], [0f, 0, 0, 0, 0, 0], [1f, 0, 0, 0, 0, 0, 0, 1, 0],
        [0f, 1, 0, 3, 0, 0, 1, 2, 0, 0, 0, 0], [1f, -2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    ];
    static columns = [2, 3, 2, 3, 3, 4, 4];
    static expected = [false, true, false, true, false, true, true];

    foreach (arrayI, column; columns) {
        auto data = allArrays[arrayI];

        Result!bool got = isReducedRowEchelonForm(data, column);
        assert(got);

        assert(got.get == expected[arrayI]);
    }
}

///
Result!bool isRowEchelonFormReducible(Type)(scope Type[] buffer, scope const Type[] input, size_t columns) {
    auto got = reduceViaRowEchelonForm(buffer, input, columns, true, true);
    if (!got)
        return typeof(return)(got.getError);

    return isReducedRowEchelonForm(buffer, columns);
}

///
unittest {
    static Values = [1f, 2, 0, 4, 0, 0, 1, 0, 0, 0, 0, 0];
    float[12] buffer;

    auto got = isRowEchelonFormReducible(buffer[], Values, 4);
    assert(got);
    assert(got.get);
}

/// Reduce matrix using gaussian elimination into row echelon form
ErrorResult rowEchelonForm(Type)(scope Type[] output, scope const Type[] input, size_t columns, bool leadingCoefficientIsOne = false) {
    return reduceViaRowEchelonForm(output, input, columns, leadingCoefficientIsOne, false);
}

///
unittest {
    // matrix 4x4
    static Values1 = [1f, 3, 5, 9, 1, 3, 1, 7, 4, 3, 9, 7, 5, 2, 0, 9], Values2 = [
        1f, 3, 5, 9, 0, 1, 1.222, 3.222, 0, 0, 1, 0.5, 0, 0, 0, 1
    ];
    scope float[16] buffer;

    Result!bool checkResult;

    checkResult = Values1.isRowEchelonForm(4);
    assert(checkResult);
    assert(!checkResult.get);

    checkResult = Values2.isRowEchelonForm(4);
    assert(checkResult);
    assert(checkResult.get);

    ErrorResult errorResult = rowEchelonForm(buffer[], Values1, 4, true);
    assert(errorResult);

    foreach (i, v; buffer) {
        assert(v.isClose(Values2[i], 0.001));
    }
}

/// The number of non-zero rows in a row echelon form of this matrix
Result!size_t rank(Type)(scope Type[] buffer, scope const Type[] input, size_t columns) {
    auto got = reduceViaRowEchelonForm(buffer, input, columns, true, true);
    if (!got)
        return typeof(return)(got.getError);

    size_t ret;

    while (buffer.length > 0) {
        scope row = buffer[0 .. columns];

        if (!isZeroVector(row))
            ret++;

        buffer = buffer[columns .. $];
    }

    return typeof(return)(ret);
}

///
unittest {
    static Values = [1f, 2, 3, 0, 2, 2, 1, 4, 5];
    float[9] buffer;

    auto got = rank(buffer[], Values, 3);
    assert(got);
    assert(got.get == 2);
}

///
ErrorResult inverse(Type)(scope Type[] output, scope Type[] buffer, scope const Type[] input, size_t columns) {
    const rows = input.length / columns;

    if (rows != columns) {
        return typeof(return)(MalformedInputException("Matrix inverses are only defined when the number of columns is equal to rows"));
    }

    ErrorResult ret = identity(output, columns);
    if (!ret)
        return ret;

    ret = reduceViaRowEchelonForm!Type(buffer, input, columns, true, true, (first, second) {
        Type[] row1 = output[first * columns .. (first + 1) * columns], row2 = output[second * columns .. (second + 1) * columns];

        foreach (x; 0 .. columns) {
            auto temp = row1[x];
            row1[x] = row2[x];
            row2[x] = temp;
        }
    }, (target, constant) {
        Type[] row = output[target * columns .. (target + 1) * columns];

        foreach (ref v; row) {
            v *= constant;
        }
    }, (target, from, constant) {
        Type[] source = output[from * columns .. (from + 1) * columns], destination = output[target * columns .. (target + 1) * columns];

        while (source.length > 0) {
            Type multiplied = source[0] * constant;

            // *sigh* even MORE FLOATING POINT BUGS
            if (multiplied.isClose(destination[0]))
                multiplied = destination[0];

            destination[0] -= multiplied;

            source = source[1 .. $];
            destination = destination[1 .. $];
        }
    });

    return ret;
}

///
unittest {
    static Values = [[1f, 2, 3, 7], [2f, -1, 0, -1, 2, -1, 0, -1, 2]];
    static float[][] Expected = [[7f, -2, -3, 1], [0.75f, .5, 0.25, 0.5, 1, 0.5, 0.25, 0.5, 0.75]];
    static Columns = [2, 3];

    float[9] buffer, output;

    foreach (i, Column; Columns) {
        auto input = Values[i], expected = Expected[i];
        float[] buf = buffer[0 .. Column * Column], data = output[0 .. Column * Column];

        auto got = inverse(data, buf, input, Column);
        assert(got);

        foreach (j, v; data) {
            assert(v.isClose(expected[j]));
        }
    }
}

///
Result!Type determinant(Type)(scope Type[] buffer, scope const Type[] input, size_t columns) {
    const rows = input.length / columns;

    if (rows != columns) {
        return typeof(return)(MalformedInputException("Matrix determinants are only defined when the number of columns is equal to rows"));
    }

    size_t swapCount;
    Type ret = 1;

    auto got = reduceViaRowEchelonForm!Type(buffer, input, columns, false, false, (first, second) { swapCount++; }, (target, constant) {
        ret *= constant;
    });

    if (!got)
        return typeof(return)(got.getError);

    size_t row;

    while (buffer.length > 0 && row < columns) {
        ret *= buffer[row];

        buffer = buffer[columns .. $];
        row++;
    }

    if (swapCount & 1)
        ret *= -1;

    return typeof(return)(ret);
}

///
unittest {
    static float[] Values1 = [1f, 3, 2, -4, 5, 5.2, -4, 6.5, 45.1], Values2 = [1f, 3, 1, 1, 1, -1, 3, 11, 5];
    float[9] buffer;

    Result!float got;

    got = determinant(buffer[], Values1, 3);
    assert(got);
    assert(got.get.isClose(658.5, 0.1));

    got = determinant(buffer[], Values2, 3);
    assert(got);
    assert(got.get.isClose(0));
}

private:

export Result!size_t moveAllZeroVectorsToBottom(Type)(scope Type[] data, size_t columns) {
    if (data.length % columns != 0)
        return Result!size_t(RangeException("Data length must be a multiple of columns"));

    size_t trueHeight;
    Type[] toGo = data;

    while (toGo.length > 0) {
        Type[] row = toGo[0 .. columns];

        if (isZeroVector(row)) {
            Type[] toGo2 = toGo[columns .. $];

            while (toGo2.length > 0) {
                Type[] row2 = toGo2[0 .. columns];

                if (!isZeroVector(row2)) {
                    foreach (i, ref v; row)
                        v = row2[i];
                    foreach (ref v; row2)
                        v = 0;

                    trueHeight++;
                    break;
                }

                toGo2 = toGo2[columns .. $];
            }
        } else {
            trueHeight++;
        }

        toGo = toGo[columns .. $];
    }

    return Result!size_t(trueHeight);
}

unittest {
    static Input = [1f, 2, 3, 0, 0, 0, 4, 5, 6], Expected = [1f, 2, 3, 4, 5, 6, 0, 0, 0];

    scope float[9] data;
    foreach (i, ref v; data)
        v = Input[i];

    auto got = moveAllZeroVectorsToBottom(data[], 3);
    assert(got);
    assert(got == 2);

    foreach (i, v; data)
        assert(v.isClose(Expected[i]));
}

alias OnSwapDel = void delegate(size_t first, size_t second) @safe nothrow @nogc;
alias OnMultiplyDel(Type) = void delegate(size_t target, Type constant) @safe nothrow @nogc;
alias OnSubMultiplyDel(Type) = void delegate(size_t target, size_t from, Type constant) @safe nothrow @nogc;

export ErrorResult reduceViaRowEchelonForm(Type)(scope Type[] output, scope const Type[] input, size_t columns,
        bool makeOne = true, bool reducedForm = true, scope OnSwapDel onSwap = null,
        scope OnMultiplyDel!Type onMultiply = null, scope OnSubMultiplyDel!Type onSubMultiply = null) {
    if (output.length != input.length)
        return ErrorResult(RangeException("Input length must match output"));
    else if (output.length % columns != 0)
        return ErrorResult(RangeException("Data length must be a multiple of columns"));

    const rows = input.length / columns;

    {
        foreach (i; 0 .. input.length)
            output[i] = input[i];

        auto result = moveAllZeroVectorsToBottom(output, columns);
        assert(result);
    }

    void swapRows(size_t first, size_t second) {
        assert(first < rows);
        assert(second < rows);

        Type[] row1 = output[first * columns .. (first * columns) + columns], row2 = output[(second * columns) .. (second * columns) +
            columns];

        while (row1.length > 0) {
            auto temp = row1[0];
            row1[0] = row2[0];
            row2[0] = temp;

            row1 = row1[1 .. $];
            row2 = row2[1 .. $];
        }

        if (onSwap !is null)
            onSwap(first, second);
    }

    void fixZeros(size_t target) {
        import std.traits : isFloatingPoint;
        import std.math : isNaN;

        assert(target < rows);

        Type[] row = output[target * columns .. (target + 1) * columns];

        foreach (ref v; row) {
            if (v.isClose(0))
                v = 0;
            else static if (isFloatingPoint!Type) {
                if (v.isNaN)
                    v = 0;
            }
        }
    }

    void multiply(size_t target, Type constant) {
        import std.math : isInfinity;

        assert(target < rows);

        Type[] row = output[target * columns .. (target + 1) * columns];

        foreach (ref v; row)
            v *= constant;

        fixZeros(target);

        if (onMultiply !is null)
            onMultiply(target, constant);
    }

    void subMultiply(size_t target, size_t from, Type constant) {
        assert(target < rows);
        assert(from < rows);

        Type[] source = output[from * columns .. (from + 1) * columns], destination = output[target * columns .. (target + 1) * columns];

        while (source.length > 0) {
            Type multiplied = source[0] * constant;

            if (multiplied.isClose(destination[0]))
                multiplied = destination[0];

            destination[0] -= multiplied;

            source = source[1 .. $];
            destination = destination[1 .. $];
        }

        fixZeros(target);

        if (onSubMultiply !is null)
            onSubMultiply(target, from, constant);
    }

    size_t xPivet;
    foreach (y1; 0 .. rows) {
        if (y1 + 1 < rows) {
            // find left most row
            size_t lowestX = size_t.max, lowestXY = size_t.max;

            foreach (y2; y1 .. rows) {
                Type[] row = output[(y2 * columns) + xPivet .. (y2 + 1) * columns];
                size_t x = xPivet;

                while (row.length > 0) {
                    if (!row[0].isClose(0)) {
                        if (lowestX > x) {
                            lowestX = x;
                            lowestXY = y2;
                        }

                        break;
                    }

                    x++;
                    row = row[1 .. $];
                }
            }

            if (lowestXY != y1)
                swapRows(y1, lowestXY);
        }

        {
            Type[] row = output[y1 * columns .. (y1 + 1) * columns];
            size_t xPivet2 = xPivet;

            // find the first pivet in row based upon known pivet point
            foreach (x; xPivet2 .. columns) {
                if (!row[x].isClose(0)) {
                    xPivet2 = x;
                    break;
                }
            }

            Type make1Constant = row[xPivet2];
            const bool undoMake1 = !make1Constant.isClose(0) && !make1Constant.isClose(1);

            if (undoMake1) {
                // make into 1
                double constant = 1;
                constant /= make1Constant;

                multiply(y1, cast(Type)constant);
            }

            foreach (y2; y1 + 1 .. rows) {
                // make all zeros below our pivet point

                const byAmount = output[(y2 * columns) + xPivet2];

                if (!byAmount.isClose(0))
                    subMultiply(y2, y1, byAmount);
            }

            if (!makeOne && undoMake1) {
                multiply(y1, make1Constant);
            }

            xPivet = xPivet2;
        }
    }

    if (reducedForm) {
        xPivet = columns;

        foreach_reverse (y1; 0 .. rows) {
            Type[] row = output[y1 * columns .. (y1 + 1) * columns];
            size_t xPivet2;

            while (xPivet2 < xPivet && row[xPivet2].isClose(0)) {
                xPivet2++;
            }

            if (xPivet2 < columns) {
                foreach (y2; 0 .. y1) {
                    Type constant = output[(y2 * columns) + xPivet2];

                    if (!constant.isClose(0))
                        subMultiply(y2, y1, constant);
                }
            }

            xPivet = xPivet2;
        }
    }

    return ErrorResult();
}
