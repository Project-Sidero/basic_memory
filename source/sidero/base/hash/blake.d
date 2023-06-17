/**
BLAKE hash algorithm ported from C

License: Creative Commons Zero v1.0 Universal
*/
module sidero.hash.blake;
export:

///
ubyte[28] blake224_hash(const(ubyte)[] input, uint[4] salt = [0, 0, 0, 0]) @safe {
    BlakeHash224 s = BlakeHash224(salt);
    s.addData(input);
    return s.calculateHash();
}

///
ubyte[32] blake256_hash(const(ubyte)[] input, uint[4] salt = [0, 0, 0, 0]) @safe {
    BlakeHash256 s = BlakeHash256(salt);
    s.addData(input);
    return s.calculateHash();
}

///
ubyte[48] blake384_hash(const(ubyte)[] input, ulong[4] salt = [0, 0, 0, 0]) @safe {
    BlakeHash384 s = BlakeHash384(salt);
    s.addData(input);
    return s.calculateHash();
}

///
ubyte[64] blake512_hash(const(ubyte)[] input, ulong[4] salt = [0, 0, 0, 0]) @safe {
    BlakeHash512 s = BlakeHash512(salt);
    s.addData(input);
    return s.calculateHash();
}

///
struct BlakeHash224 {
    ///
    this(uint[4] salt) @safe {
        s = salt;
    }

    ///
    void addData(scope const(ubyte)[] data...) @safe {
        size_t left = buflen;
        size_t fill = 64 - left;

        if (left > 0 && data.length >= fill) {
            foreach (i, ref v; buf[left .. left + fill])
                v = data[i];
            //buf[left .. left + fill][] = data[0 .. fill][];
            t[0] += 512;

            if (t[0] == 0)
                t[1]++;

            compress(buf[0 .. 64]);

            data = data[fill .. $];
            left = 0;
        }

        while (data.length >= 64) {
            t[0] += 512;

            if (t[0] == 0)
                t[1]++;

            compress(data[0 .. 64]);

            data = data[64 .. $];
        }

        if (data.length > 0) {
            foreach (i, ref v; buf[left .. left + data.length])
                v = data[i];
            //buf[left .. left + data.length][] = data[];
            buflen = left + data.length;
        } else
            buflen = 0;
    }

    ///
    ubyte[28] calculateHash() @safe {
        ubyte[8] msglen;
        uint lo = t[0] + cast(uint)(buflen << 3), hi = t[1];

        if (lo < buflen << 3)
            hi++;

        msglen[0 .. 4] = nativeToBigEndian(hi)[];
        msglen[4 .. 8] = nativeToBigEndian(lo)[];

        if (buflen == 55) {
            t[0] -= 8;
            addData(0x80);
        } else {
            if (buflen < 55) {
                if (buflen == 0)
                    nullt = true;

                t[0] -= 440 - (buflen << 3);
                addData(padding[0 .. 55 - buflen]);
            } else {
                t[0] -= 512 - (buflen << 3);
                addData(padding[0 .. 64 - buflen]);

                t[0] -= 440;
                addData(padding[1 .. 56]);
                nullt = true;
            }

            addData(0x00);
            t[0] -= 8;
        }

        t[0] -= 64;
        addData(msglen[]);

        ubyte[28] ret;

        static foreach (i; 0 .. 7)
            ret[i * 4 .. (i + 1) * 4] = nativeToBigEndian(h[i]);

        return ret;
    }

    ///
    unittest {
        ubyte[72] input;
        ubyte[28] output;

        ubyte[] test1 = [
            0x45, 0x04, 0xcb, 0x03, 0x14, 0xfb, 0x2a, 0x4f, 0x7a, 0x69, 0x2e, 0x69, 0x6e, 0x48, 0x79, 0x12, 0xfe, 0x3f,
            0x24, 0x68, 0xfe, 0x31, 0x2c, 0x73, 0xa5, 0x27, 0x8e, 0xc5
        ], test2 = [
            0xf5, 0xaa, 0x00, 0xdd, 0x1c, 0xb8, 0x47, 0xe3, 0x14, 0x03, 0x72, 0xaf, 0x7b, 0x5c, 0x46, 0xb4, 0x88, 0x8d,
            0x82, 0xc8, 0xc0, 0xa9, 0x17, 0x91, 0x3c, 0xfb, 0x5d, 0x04
        ];

        output = blake224_hash(input[0 .. 1]);
        assert(output == test1, "test 1 error");

        output = blake224_hash(input);
        assert(output == test2, "test 2 error");
    }

private:

    uint[8] h = [0xc1059ed8, 0x367cd507, 0x3070dd17, 0xf70e5939, 0xffc00b31, 0x68581511, 0x64f98fa7, 0xbefa4fa4];
    uint[4] s;
    uint[2] t;
    size_t buflen;
    ubyte[64] buf;
    bool nullt;

    void compress(scope const(ubyte)[] block) @safe {
        assert(block.length == 64);

        uint[16] v, m;

        static uint ROT(uint x, uint n) @safe {
            return (x << (32 - n)) | (x >> n);
        }

        void G(size_t a, size_t b, size_t c, size_t d, size_t e, size_t i) @safe {
            v[a] += (m[sigma[i][e]] ^ u256[sigma[i][e + 1]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 16);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 12);
            v[a] += (m[sigma[i][e + 1]] ^ u256[sigma[i][e]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 8);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 7);
        }

        static foreach (i; 0 .. 16)
            m[i] = bigEndianToNative!uint(block[i * 4 .. (i + 1) * 4]);
        v[0 .. 8] = h[0 .. 8];

        static foreach (i; 0 .. 4)
            v[8 + i] = s[i] ^ u256[i];
        static foreach (i; 4 .. 8)
            v[8 + i] = u256[i];

        if (!nullt) {
            v[12] ^= t[0];
            v[13] ^= t[0];
            v[14] ^= t[1];
            v[15] ^= t[1];
        }

        foreach (i; 0 .. 14) {
            G(0, 4, 8, 12, 0, i);
            G(1, 5, 9, 13, 2, i);
            G(2, 6, 10, 14, 4, i);
            G(3, 7, 11, 15, 6, i);

            G(0, 5, 10, 15, 8, i);
            G(1, 6, 11, 12, 10, i);
            G(2, 7, 8, 13, 12, i);
            G(3, 4, 9, 14, 14, i);
        }

        static foreach (i; 0 .. 16)
            h[i % 8] ^= v[i];
        static foreach (i; 0 .. 8)
            h[i] ^= s[i % 4];
    }
}

///
struct BlakeHash256 {
    ///
    this(uint[4] salt) @safe {
        s = salt;
    }

    ///
    void addData(scope const(ubyte)[] data...) @safe {
        size_t left = buflen;
        size_t fill = 64 - left;

        if (left > 0 && data.length >= fill) {
            foreach (i, ref v; buf[left .. left + fill])
                v = data[i];
            //buf[left .. left + fill][] = data[0 .. fill][];
            t[0] += 512;

            if (t[0] == 0)
                t[1]++;

            compress(buf[0 .. 64]);

            data = data[fill .. $];
            left = 0;
        }

        while (data.length >= 64) {
            t[0] += 512;

            if (t[0] == 0)
                t[1]++;

            compress(data[0 .. 64]);

            data = data[64 .. $];
        }

        if (data.length > 0) {
            foreach (i, ref v; buf[left .. left + data.length])
                v = data[i];
            //buf[left .. left + data.length][] = data[];
            buflen = left + data.length;
        } else
            buflen = 0;
    }

    ///
    ubyte[32] calculateHash() @safe {
        ubyte[8] msglen;
        uint lo = t[0] + cast(uint)(buflen << 3), hi = t[1];

        if (lo < buflen << 3)
            hi++;

        msglen[0 .. 4] = nativeToBigEndian(hi)[];
        msglen[4 .. 8] = nativeToBigEndian(lo)[];

        if (buflen == 55) {
            t[0] -= 8;
            addData(0x81);
        } else {
            if (buflen < 55) {
                if (buflen == 0)
                    nullt = true;

                t[0] -= 440 - (buflen << 3);
                addData(padding[0 .. 55 - buflen]);
            } else {
                t[0] -= 512 - (buflen << 3);
                addData(padding[0 .. 64 - buflen]);

                t[0] -= 440;
                addData(padding[1 .. 56]);
                nullt = true;
            }

            addData(0x01);
            t[0] -= 8;
        }

        t[0] -= 64;
        addData(msglen[]);

        ubyte[32] ret;

        static foreach (i; 0 .. 8)
            ret[i * 4 .. (i + 1) * 4] = nativeToBigEndian(h[i]);

        return ret;
    }

    ///
    unittest {
        ubyte[72] input;
        ubyte[32] output;

        ubyte[] test1 = [
            0x0c, 0xe8, 0xd4, 0xef, 0x4d, 0xd7, 0xcd, 0x8d, 0x62, 0xdf, 0xde, 0xd9, 0xd4, 0xed, 0xb0, 0xa7, 0x74, 0xae,
            0x6a, 0x41, 0x92, 0x9a, 0x74, 0xda, 0x23, 0x10, 0x9e, 0x8f, 0x11, 0x13, 0x9c, 0x87
        ], test2 = [
            0xd4, 0x19, 0xba, 0xd3, 0x2d, 0x50, 0x4f, 0xb7, 0xd4, 0x4d, 0x46, 0x0c, 0x42, 0xc5, 0x59, 0x3f, 0xe5, 0x44,
            0xfa, 0x4c, 0x13, 0x5d, 0xec, 0x31, 0xe2, 0x1b, 0xd9, 0xab, 0xdc, 0xc2, 0x2d, 0x41
        ];

        output = blake256_hash(input[0 .. 1]);
        assert(output == test1, "test 1 error");

        output = blake256_hash(input);
        assert(output == test2, "test 2 error");
    }

private:

    uint[8] h = [0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19];
    uint[4] s;
    uint[2] t;
    size_t buflen;
    ubyte[64] buf;
    bool nullt;

    void compress(scope const(ubyte)[] block) @safe {
        assert(block.length == 64);

        uint[16] v, m;

        static uint ROT(uint x, uint n) @safe {
            return (x << (32 - n)) | (x >> n);
        }

        void G(size_t a, size_t b, size_t c, size_t d, size_t e, size_t i) @safe {
            v[a] += (m[sigma[i][e]] ^ u256[sigma[i][e + 1]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 16);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 12);
            v[a] += (m[sigma[i][e + 1]] ^ u256[sigma[i][e]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 8);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 7);
        }

        static foreach (i; 0 .. 16)
            m[i] = bigEndianToNative!uint(block[i * 4 .. (i + 1) * 4]);
        v[0 .. 8] = h[0 .. 8];

        static foreach (i; 0 .. 4)
            v[8 + i] = s[i] ^ u256[i];
        static foreach (i; 4 .. 8)
            v[8 + i] = u256[i];

        if (!nullt) {
            v[12] ^= t[0];
            v[13] ^= t[0];
            v[14] ^= t[1];
            v[15] ^= t[1];
        }

        foreach (i; 0 .. 14) {
            G(0, 4, 8, 12, 0, i);
            G(1, 5, 9, 13, 2, i);
            G(2, 6, 10, 14, 4, i);
            G(3, 7, 11, 15, 6, i);

            G(0, 5, 10, 15, 8, i);
            G(1, 6, 11, 12, 10, i);
            G(2, 7, 8, 13, 12, i);
            G(3, 4, 9, 14, 14, i);
        }

        static foreach (i; 0 .. 16)
            h[i % 8] ^= v[i];
        static foreach (i; 0 .. 8)
            h[i] ^= s[i % 4];
    }
}

///
struct BlakeHash384 {
    ///
    this(ulong[4] salt) @safe {
        s = salt;
    }

    ///
    void addData(scope const(ubyte)[] data...) @safe {
        size_t left = buflen;
        size_t fill = 128 - left;

        if (left > 0 && data.length >= fill) {
            foreach (i, ref v; buf[left .. left + fill])
                v = data[i];
            //buf[left .. left + fill][] = data[0 .. fill][];
            t[0] += 1024;

            if (t[0] == 0)
                t[1]++;

            compress(buf[0 .. 128]);

            data = data[fill .. $];
            left = 0;
        }

        while (data.length >= 128) {
            t[0] += 1024;

            if (t[0] == 0)
                t[1]++;

            compress(data[0 .. 128]);

            data = data[128 .. $];
        }

        if (data.length > 0) {
            foreach (i, ref v; buf[left .. left + data.length])
                v = data[i];
            //buf[left .. left + data.length][] = data[];
            buflen = left + data.length;
        } else
            buflen = 0;
    }

    ///
    ubyte[48] calculateHash() @safe {
        ubyte[16] msglen;
        ulong lo = t[0] + cast(ulong)(buflen << 3), hi = t[1];

        if (lo < buflen << 3)
            hi++;

        msglen[0 .. 8] = nativeToBigEndian(hi)[];
        msglen[8 .. 16] = nativeToBigEndian(lo)[];

        if (buflen == 111) {
            t[0] -= 8;
            addData(0x80);
        } else {
            if (buflen < 111) {
                if (buflen == 0)
                    nullt = true;

                t[0] -= 888 - (buflen << 3);
                addData(padding[0 .. 111 - buflen]);
            } else {
                t[0] -= 1024 - (buflen << 3);
                addData(padding[0 .. 128 - buflen]);

                t[0] -= 888;
                addData(padding[1 .. 112]);
                nullt = true;
            }

            addData(0x00);
            t[0] -= 8;
        }

        t[0] -= 128;
        addData(msglen[]);

        ubyte[48] ret;

        static foreach (i; 0 .. 6)
            ret[i * 8 .. (i + 1) * 8] = nativeToBigEndian(h[i]);

        return ret;
    }

    ///
    unittest {
        ubyte[144] input;
        ubyte[48] output;

        ubyte[] test1 = [
            0x10, 0x28, 0x1f, 0x67, 0xe1, 0x35, 0xe9, 0x0a, 0xe8, 0xe8, 0x82, 0x25, 0x1a, 0x35, 0x55, 0x10, 0xa7, 0x19,
            0x36, 0x7a, 0xd7, 0x02, 0x27, 0xb1, 0x37, 0x34, 0x3e, 0x1b, 0xc1, 0x22, 0x01, 0x5c, 0x29, 0x39, 0x1e, 0x85,
            0x45, 0xb5, 0x27, 0x2d, 0x13, 0xa7, 0xc2, 0x87, 0x9d, 0xa3, 0xd8, 0x07
        ], test2 = [
            0x0b, 0x98, 0x45, 0xdd, 0x42, 0x95, 0x66, 0xcd, 0xab, 0x77, 0x2b, 0xa1, 0x95, 0xd2, 0x71, 0xef, 0xfe, 0x2d,
            0x02, 0x11, 0xf1, 0x69, 0x91, 0xd7, 0x66, 0xba, 0x74, 0x94, 0x47, 0xc5, 0xcd, 0xe5, 0x69, 0x78, 0x0b, 0x2d,
            0xaa, 0x66, 0xc4, 0xb2, 0x24, 0xa2, 0xec, 0x2e, 0x5d, 0x09, 0x17, 0x4c
        ];

        output = blake384_hash(input[0 .. 1]);
        assert(output == test1, "test 1 error");

        output = blake384_hash(input);
        assert(output == test2, "test 2 error");
    }

private:

    ulong[8] h = [
        0xcbbb9d5dc1059ed8, 0x629a292a367cd507, 0x9159015a3070dd17, 0x152fecd8f70e5939, 0x67332667ffc00b31,
        0x8eb44a8768581511, 0xdb0c2e0d64f98fa7, 0x47b5481dbefa4fa4
    ];
    ulong[4] s;
    ulong[2] t;
    ubyte[128] buf;
    size_t buflen;

    bool nullt;

    void compress(scope const(ubyte)[] block) @safe {
        assert(block.length == 128);

        ulong[16] v, m;

        static ulong ROT(ulong x, uint n) @safe {
            return (x << (64 - n)) | (x >> n);
        }

        void G(size_t a, size_t b, size_t c, size_t d, size_t e, size_t i) @safe {
            v[a] += (m[sigma[i][e]] ^ u512[sigma[i][e + 1]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 32);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 25);
            v[a] += (m[sigma[i][e + 1]] ^ u512[sigma[i][e]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 16);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 11);
        }

        static foreach (i; 0 .. 16)
            m[i] = bigEndianToNative!ulong(block[i * 8 .. (i + 1) * 8]);
        v[0 .. 8] = h[0 .. 8];

        static foreach (i; 0 .. 4)
            v[8 + i] = s[i] ^ u512[i];
        static foreach (i; 4 .. 8)
            v[8 + i] = u512[i];

        if (!nullt) {
            v[12] ^= t[0];
            v[13] ^= t[0];
            v[14] ^= t[1];
            v[15] ^= t[1];
        }

        foreach (i; 0 .. 16) {
            G(0, 4, 8, 12, 0, i);
            G(1, 5, 9, 13, 2, i);
            G(2, 6, 10, 14, 4, i);
            G(3, 7, 11, 15, 6, i);

            G(0, 5, 10, 15, 8, i);
            G(1, 6, 11, 12, 10, i);
            G(2, 7, 8, 13, 12, i);
            G(3, 4, 9, 14, 14, i);
        }

        static foreach (i; 0 .. 16)
            h[i % 8] ^= v[i];
        static foreach (i; 0 .. 8)
            h[i] ^= s[i % 4];
    }
}

///
struct BlakeHash512 {
    ///
    this(ulong[4] salt) @safe {
        s = salt;
    }

    ///
    void addData(scope const(ubyte)[] data...) @safe {
        size_t left = buflen;
        size_t fill = 128 - left;

        if (left > 0 && data.length >= fill) {
            foreach (i, ref v; buf[left .. left + fill])
                v = data[i];
            //buf[left .. left + fill][] = data[0 .. fill][];

            t[0] += 1024;

            if (t[0] == 0)
                t[1]++;

            compress(buf[0 .. 128]);

            data = data[fill .. $];
            left = 0;
        }

        while (data.length >= 128) {
            t[0] += 1024;

            if (t[0] == 0)
                t[1]++;

            compress(data[0 .. 128]);

            data = data[128 .. $];
        }

        if (data.length > 0) {
            foreach (i, ref v; buf[left .. left + data.length])
                v = data[i];
            //buf[left .. left + data.length][] = data[];

            buflen = left + data.length;
        } else
            buflen = 0;
    }

    ///
    ubyte[64] calculateHash() @safe {
        ubyte[16] msglen;
        ulong lo = t[0] + cast(ulong)(buflen << 3), hi = t[1];

        if (lo < buflen << 3)
            hi++;

        msglen[0 .. 8] = nativeToBigEndian(hi)[];
        msglen[8 .. 16] = nativeToBigEndian(lo)[];

        if (buflen == 111) {
            t[0] -= 8;
            addData(0x81);
        } else {
            if (buflen < 111) {
                if (buflen == 0)
                    nullt = true;

                t[0] -= 888 - (buflen << 3);
                addData(padding[0 .. 111 - buflen]);
            } else {
                t[0] -= 1024 - (buflen << 3);
                addData(padding[0 .. 128 - buflen]);

                t[0] -= 888;
                addData(padding[1 .. 112]);
                nullt = true;
            }

            addData(0x01);
            t[0] -= 8;
        }

        t[0] -= 128;
        addData(msglen[]);

        ubyte[64] ret;

        static foreach (i; 0 .. 8)
            ret[i * 8 .. (i + 1) * 8] = nativeToBigEndian(h[i]);

        return ret;
    }

    ///
    unittest {
        ubyte[144] input;
        ubyte[64] output;

        ubyte[] test1 = [
            0x97, 0x96, 0x15, 0x87, 0xf6, 0xd9, 0x70, 0xfa, 0xba, 0x6d, 0x24, 0x78, 0x04, 0x5d, 0xe6, 0xd1, 0xfa, 0xbd,
            0x09, 0xb6, 0x1a, 0xe5, 0x09, 0x32, 0x05, 0x4d, 0x52, 0xbc, 0x29, 0xd3, 0x1b, 0xe4, 0xff, 0x91, 0x02, 0xb9,
            0xf6, 0x9e, 0x2b, 0xbd, 0xb8, 0x3b, 0xe1, 0x3d, 0x4b, 0x9c, 0x06, 0x09, 0x1e, 0x5f, 0xa0, 0xb4, 0x8b, 0xd0,
            0x81, 0xb6, 0x34, 0x05, 0x8b, 0xe0, 0xec, 0x49, 0xbe, 0xb3
        ], test2 = [
            0x31, 0x37, 0x17, 0xd6, 0x08, 0xe9, 0xcf, 0x75, 0x8d, 0xcb, 0x1e, 0xb0, 0xf0, 0xc3, 0xcf, 0x9f, 0xC1, 0x50,
            0xb2, 0xd5, 0x00, 0xfb, 0x33, 0xf5, 0x1c, 0x52, 0xaf, 0xc9, 0x9d, 0x35, 0x8a, 0x2f, 0x13, 0x74, 0xb8, 0xa3,
            0x8b, 0xba, 0x79, 0x74, 0xe7, 0xf6, 0xef, 0x79, 0xca, 0xb1, 0x6f, 0x22, 0xCE, 0x1e, 0x64, 0x9d, 0x6e, 0x01,
            0xad, 0x95, 0x89, 0xc2, 0x13, 0x04, 0x5d, 0x54, 0x5d, 0xde
        ];

        output = blake512_hash(input[0 .. 1]);
        assert(output == test1, "test 1 error");

        output = blake512_hash(input);
        assert(output == test2, "test 2 error");
    }

private:

    ulong[8] h = [
        0x6a09e667f3bcc908, 0xbb67ae8584caa73b, 0x3c6ef372fe94f82b, 0xa54ff53a5f1d36f1, 0x510e527fade682d1,
        0x9b05688c2b3e6c1f, 0x1f83d9abfb41bd6b, 0x5be0cd19137e2179
    ];
    ulong[4] s;
    ulong[2] t;
    ubyte[128] buf;
    size_t buflen;

    bool nullt;

    void compress(scope const(ubyte)[] block) @safe {
        assert(block.length == 128);

        ulong[16] v, m;

        static ulong ROT(ulong x, uint n) @safe {
            return (x << (64 - n)) | (x >> n);
        }

        void G(size_t a, size_t b, size_t c, size_t d, size_t e, size_t i) @safe {
            v[a] += (m[sigma[i][e]] ^ u512[sigma[i][e + 1]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 32);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 25);
            v[a] += (m[sigma[i][e + 1]] ^ u512[sigma[i][e]]) + v[b];
            v[d] = ROT(v[d] ^ v[a], 16);
            v[c] += v[d];
            v[b] = ROT(v[b] ^ v[c], 11);
        }

        static foreach (i; 0 .. 16)
            m[i] = bigEndianToNative!ulong(block[i * 8 .. (i + 1) * 8]);
        v[0 .. 8] = h[0 .. 8];

        static foreach (i; 0 .. 4)
            v[8 + i] = s[i] ^ u512[i];
        static foreach (i; 4 .. 8)
            v[8 + i] = u512[i];

        if (!nullt) {
            v[12] ^= t[0];
            v[13] ^= t[0];
            v[14] ^= t[1];
            v[15] ^= t[1];
        }

        foreach (i; 0 .. 16) {
            G(0, 4, 8, 12, 0, i);
            G(1, 5, 9, 13, 2, i);
            G(2, 6, 10, 14, 4, i);
            G(3, 7, 11, 15, 6, i);

            G(0, 5, 10, 15, 8, i);
            G(1, 6, 11, 12, 10, i);
            G(2, 7, 8, 13, 12, i);
            G(3, 4, 9, 14, 14, i);
        }

        static foreach (i; 0 .. 16)
            h[i % 8] ^= v[i];
        static foreach (i; 0 .. 8)
            h[i] ^= s[i % 4];
    }
}

private:
import sidero.base.bitmanip : nativeToBigEndian, bigEndianToNative;

static immutable ubyte[][] sigma = [
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
    [11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4], [7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
    [9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13], [2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9],
    [12, 5, 1, 15, 14, 13, 4, 10, 0, 7, 6, 3, 9, 2, 8, 11], [13, 11, 7, 14, 12, 1, 3, 9, 5, 0, 15, 4, 8, 6, 2, 10],
    [6, 15, 14, 9, 11, 3, 0, 8, 12, 2, 13, 7, 1, 4, 10, 5], [10, 2, 8, 4, 7, 6, 1, 5, 15, 11, 9, 14, 3, 12, 13, 0],
    [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], [14, 10, 4, 8, 9, 15, 13, 6, 1, 12, 0, 2, 11, 7, 5, 3],
    [11, 8, 12, 0, 5, 2, 15, 13, 10, 14, 3, 6, 7, 1, 9, 4], [7, 9, 3, 1, 13, 12, 11, 14, 2, 6, 5, 10, 4, 0, 15, 8],
    [9, 0, 5, 7, 2, 4, 10, 15, 14, 1, 11, 12, 6, 8, 3, 13], [2, 12, 6, 10, 0, 11, 8, 3, 4, 13, 7, 5, 15, 14, 1, 9]
];

static immutable uint[16] u256 = [
    0x243f6a88, 0x85a308d3, 0x13198a2e, 0x03707344, 0xa4093822, 0x299f31d0, 0x082efa98, 0xec4e6c89, 0x452821e6,
    0x38d01377, 0xbe5466cf, 0x34e90c6c, 0xc0ac29b7, 0xc97c50dd, 0x3f84d5b5, 0xb5470917
];

static immutable ulong[16] u512 = [
    0x243f6a8885a308d3, 0x13198a2e03707344, 0xa4093822299f31d0, 0x082efa98ec4e6c89, 0x452821e638d01377,
    0xbe5466cf34e90c6c, 0xc0ac29b7c97c50dd, 0x3f84d5b5b5470917, 0x9216d5d98979fb1b,
    0xd1310ba698dfb5ac, 0x2ffd72dbd01adfb7, 0xb8e1afed6a267e96, 0xba7c9045f12c7f99, 0x24a19947b3916cf7,
    0x0801f2e2858efc16, 0x636920d871574e69
];

static immutable ubyte[129] padding = [
    0x80, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
];
