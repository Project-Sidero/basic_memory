module sidero.base.encoding.base64;
import sidero.base.text;
import sidero.base.allocators.api;
import sidero.base.errors;
import sidero.base.containers.dynamicarray;

export @safe nothrow @nogc:

///
struct Base64(string Alphabet, ptrdiff_t maxLength = -1, string eolSeperator = null, bool ignoreUnknownData = false,
        bool rejectUnknownData = true) {
    static assert(Alphabet.length == 64 || Alphabet.length == 65);
    static assert(maxLength < 0 || maxLength > 0);
    static assert(eolSeperator !is null || maxLength < 0);

export @safe nothrow @nogc static:

    ///
    StringBuilder_ASCII encode(scope const(ubyte[]) input...) @trusted {
        import sidero.base.allocators.api;

        StringBuilder_ASCII ret = StringBuilder_ASCII(globalAllocator());
        encode(ret, input);
        return ret;
    }

    ///
    void encode(scope StringBuilder_ASCII builder, scope const(ubyte[]) input...) @trusted {
        const secondarySize = input.length % 3, initialSize = input.length - (secondarySize);

        static if(maxLength > 0) {
            size_t soFar;
        }

        void handleChar(char c) {
            static if(maxLength > 0) {
                if(soFar == maxLength) {
                    soFar = 1;
                    builder ~= eolSeperator;
                } else
                    soFar++;
            }

            ubyte[1] temp = [c];
            builder ~= temp[];
        }

        const(ubyte)* bytePtr = input.ptr, bytePtrEnd = bytePtr + initialSize;
        if(secondarySize > 0 || initialSize >= 3) {
            if(secondarySize == 0) {
                bytePtrEnd -= 3;
            }

            while(bytePtr !is bytePtrEnd) {
                uint temp = *(cast(uint*)bytePtr);

                handleChar(Alphabet[(temp >> 2) & 0x3F]);
                handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
                handleChar(Alphabet[((temp & 0xF00) >> 6) | ((temp & 0xC00000) >> 22)]);
                handleChar(Alphabet[(temp >> 16) & 0x3F]);

                bytePtr += 3;
            }
        }

        if(secondarySize == 0 && initialSize >= 3) {
            uint temp;
            temp = *bytePtr;
            temp |= (cast(uint)*(bytePtr + 1)) << 8;
            temp |= (cast(uint)*(bytePtr + 2)) << 16;

            handleChar(Alphabet[(temp >> 2) & 0x3F]);
            handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
            handleChar(Alphabet[((temp & 0xF00) >> 6) | ((temp & 0xC00000) >> 22)]);
            handleChar(Alphabet[(temp >> 16) & 0x3F]);
        } else if(secondarySize == 2) {
            ushort temp = *(cast(ushort*)bytePtr);

            handleChar(Alphabet[(temp >> 2) & 0x3F]);
            handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
            handleChar(Alphabet[(temp & 0xF00) >> 6]);

            static if(Alphabet.length == 65) {
                handleChar(Alphabet[64]);
            }
        } else if(secondarySize == 1) {
            ubyte temp = *bytePtr;

            handleChar(Alphabet[(temp >> 2) & 0x3F]);
            handleChar(Alphabet[(temp & 0x3) << 4]);

            static if(Alphabet.length == 65) {
                handleChar(Alphabet[64]);
                handleChar(Alphabet[64]);
            }
        }
    }

    ///
    void encode(scope StringBuilder_UTF8 builder, scope const(ubyte[]) input...) @trusted {
        encode(builder.byUTF32, input);
    }

    ///
    void encode(scope StringBuilder_UTF16 builder, scope const(ubyte[]) input...) @trusted {
        encode(builder.byUTF32, input);
    }

    ///
    void encode(scope StringBuilder_UTF32 builder, scope const(ubyte[]) input...) @trusted {
        const secondarySize = input.length % 3, initialSize = input.length - (secondarySize);

        static if(maxLength > 0) {
            size_t soFar;
        }

        void handleChar(char c) {
            static if(maxLength > 0) {
                if(soFar == maxLength) {
                    soFar = 1;
                    builder ~= eolSeperator;
                } else
                    soFar++;
            }

            dchar[1] temp = [c];
            builder ~= temp[];
        }

        const(ubyte)* bytePtr = input.ptr, bytePtrEnd = bytePtr + initialSize;
        if(secondarySize > 0 || initialSize >= 3) {
            if(secondarySize == 0) {
                bytePtrEnd -= 3;
            }

            while(bytePtr !is bytePtrEnd) {
                uint temp = *(cast(uint*)bytePtr);

                handleChar(Alphabet[(temp >> 2) & 0x3F]);
                handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
                handleChar(Alphabet[((temp & 0xF00) >> 6) | ((temp & 0xC00000) >> 22)]);
                handleChar(Alphabet[(temp >> 16) & 0x3F]);

                bytePtr += 3;
            }
        }

        if(secondarySize == 0 && initialSize >= 3) {
            uint temp;
            temp = *bytePtr;
            temp |= (cast(uint)*(bytePtr + 1)) << 8;
            temp |= (cast(uint)*(bytePtr + 2)) << 16;

            handleChar(Alphabet[(temp >> 2) & 0x3F]);
            handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
            handleChar(Alphabet[((temp & 0xF00) >> 6) | ((temp & 0xC00000) >> 22)]);
            handleChar(Alphabet[(temp >> 16) & 0x3F]);
        } else if(secondarySize == 2) {
            ushort temp = *(cast(ushort*)bytePtr);

            handleChar(Alphabet[(temp >> 2) & 0x3F]);
            handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
            handleChar(Alphabet[(temp & 0xF00) >> 6]);

            static if(Alphabet.length == 65) {
                handleChar(Alphabet[64]);
            }
        } else if(secondarySize == 1) {
            ubyte temp = *bytePtr;

            handleChar(Alphabet[(temp >> 2) & 0x3F]);
            handleChar(Alphabet[(temp & 0x3) << 4]);

            static if(Alphabet.length == 65) {
                handleChar(Alphabet[64]);
                handleChar(Alphabet[64]);
            }
        }
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope const(char)[] input, RCAllocator allocator = globalAllocator()) @trusted {
        return decode_(String_UTF8(input), allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope const(wchar)[] input, RCAllocator allocator = globalAllocator()) @trusted {
        return decode_(String_UTF16(input), allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope const(dchar)[] input, RCAllocator allocator = globalAllocator()) @trusted {
        return decode_(String_UTF32(input), allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope String_ASCII input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope StringBuilder_ASCII input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope String_UTF8 input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope String_UTF16 input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope String_UTF32 input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope StringBuilder_UTF8 input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope StringBuilder_UTF16 input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

    ///
    Result!(DynamicArray!ubyte) decode(scope StringBuilder_UTF32 input, RCAllocator allocator = globalAllocator()) {
        return decode_(input, allocator);
    }

private:

    Result!(DynamicArray!ubyte) decode_(T)(scope T input, RCAllocator allocator) @trusted {
        enum MinimumInOffset = () {
            char lowestValue = char.max;

            foreach(v; Alphabet) {
                if(v < lowestValue)
                    lowestValue = v;
            }

            return lowestValue;
        }();
        enum MaximumInOffset = () {
            char highestValue = 0;

            foreach(v; Alphabet) {
                if(v > highestValue)
                    highestValue = v;
            }

            return highestValue;
        }();
        enum HaveFiller = Alphabet.length == 65;
        static DecodingAlphabet = () {
            size_t[(MaximumInOffset + 1) - MinimumInOffset] ret;
            ret[] = size_t.max;

            foreach(i, v; Alphabet) {
                ret[v - MinimumInOffset] = i;
            }

            return cast(immutable)ret;
        }();

        DynamicArray!ubyte storage = DynamicArray!ubyte(allocator);
        storage.reserve(cast(size_t)((input.length + 2) / 0.75));
        Result!(DynamicArray!ubyte) ret = Result!(DynamicArray!ubyte)(storage);

        size_t lastFillerSeq;

        uint[4] samples;
        size_t count;

        size_t lastSamplesStored;
        uint lastSample;

        void outputDecodedSoFar() @safe nothrow @nogc {
            if(lastSamplesStored >= 1)
                storage ~= cast(ubyte)(lastSample & 0xFF);
            if(lastSamplesStored >= 2)
                storage ~= cast(ubyte)((lastSample >> 8) & 0xFF);
            if(lastSamplesStored >= 3)
                storage ~= cast(ubyte)((lastSample >> 16) & 0xFF);
            if(lastSamplesStored == 4)
                storage ~= cast(ubyte)((lastSample >> 24) & 0xFF);

            lastSamplesStored = 0;
        }

        void processDecoded(uint decodedValue) @safe nothrow @nogc {
            assert(decodedValue <= 64);

            if(lastSamplesStored == 0) {
                // handleChar(Alphabet[(temp >> 2) & 0x3F]);
                lastSample = (decodedValue & 0x3F) << 2;

                lastSamplesStored = 1;
            } else if(lastSamplesStored == 1) {
                // handleChar(Alphabet[((temp & 0x3) << 4) | ((temp & 0xF000) >> 12)]);
                lastSample |= (decodedValue >> 4) & 0x3;
                lastSample |= (decodedValue << 12) & 0xF000;

                lastSamplesStored = 2;
            } else if(lastSamplesStored == 2) {
                // handleChar(Alphabet[((temp & 0xF00) >> 6) | ((temp & 0xC00000) >> 22)]);
                lastSample |= (decodedValue << 6) & 0xF00;
                lastSample |= (decodedValue << 22) & 0xC00000;

                lastSamplesStored = 3;
            } else {
                // handleChar(Alphabet[(temp >> 16) & 0x3F]);
                lastSample |= (decodedValue & 0x3F) << 16;

                storage ~= cast(ubyte)(lastSample & 0xFF);
                storage ~= cast(ubyte)((lastSample >> 8) & 0xFF);
                storage ~= cast(ubyte)((lastSample >> 16) & 0xFF);

                lastSamplesStored = 0;
            }
        }

        void handle() @safe nothrow @nogc {
            if(count == 0) {
                if(lastSamplesStored == 2 && (!HaveFiller || lastFillerSeq == 2)) {
                    // for 1 byte you need 2 samples + 2 filler
                    storage ~= cast(ubyte)(lastSample & 0xFF);
                } else if(lastSamplesStored == 3 && (!HaveFiller || lastFillerSeq == 1)) {
                    // for 2 bytes you need 3 samples + 1 filler
                    storage ~= cast(ubyte)(lastSample & 0xFF);
                    storage ~= cast(ubyte)((lastSample >> 8) & 0xFF);
                } else if(lastSamplesStored == 4) {
                    // for 3 bytes you need 4 samples
                    storage ~= cast(ubyte)(lastSample & 0xFF);
                    storage ~= cast(ubyte)((lastSample >> 8) & 0xFF);
                    storage ~= cast(ubyte)((lastSample >> 16) & 0xFF);
                }

                lastSamplesStored = 0;
                return;
            }

            foreach(v; samples) {
                if(!(Alphabet.length == 65 && v == Alphabet[$ - 1]) && rejectUnknownData && (v < MinimumInOffset || v > MaximumInOffset)) {
                    ret = MalformedInputException("Input not part of base64 alphabet");
                    return;
                }
            }

            foreach(i, v; samples) {
                size_t decoded;

                if(v < MinimumInOffset || v > MaximumInOffset || (decoded = DecodingAlphabet[v - MinimumInOffset]) == size_t.max) {
                    // raw
                    outputDecodedSoFar();
                    storage ~= cast(ubyte)v;

                    static if(HaveFiller)
                        lastFillerSeq = 0;
                } else {
                    static if(HaveFiller) {
                        if(v == Alphabet[$ - 1]) {
                            lastFillerSeq++;
                            continue;
                        } else {
                            lastFillerSeq = 0;
                        }
                    }

                    processDecoded(cast(uint)decoded);
                }
            }
        }

        while(input.length > 0) {
            T inputToUse = input;

            static if(eolSeperator !is null) {
                ptrdiff_t offset = input.indexOf(eolSeperator);

                if(offset == 0) {
                    input = input[eolSeperator.length .. $];
                    continue;
                } else if(offset > 0) {
                    inputToUse = input[0 .. offset];
                    input = input[offset + eolSeperator.length .. $];
                } else
                    input = T.init;
            } else
                input = T.init;

            foreach(sample; inputToUse) {
                samples[count] = cast(uint)sample;
                count++;

                if(count == 4) {
                    handle();
                    if(!ret)
                        return ret;
                    count = 0;
                }
            }
        }

        handle();
        return ret;
    }
}

///
alias base64 = rfc4648Standard;

///
immutable {
    ///
    Base64!("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=") rfc4648Standard;

    ///
    @trusted unittest {
        assert(rfc4648Standard.encode(cast(ubyte[])"f") == "Zg==");
        assert(rfc4648Standard.encode(cast(ubyte[])"fo") == "Zm8=");
        assert(rfc4648Standard.encode(cast(ubyte[])"foo") == "Zm9v");
        assert(rfc4648Standard.encode(cast(ubyte[])"foob") == "Zm9vYg==");
        assert(rfc4648Standard.encode(cast(ubyte[])"fooba") == "Zm9vYmE=");
        assert(rfc4648Standard.encode(cast(ubyte[])"foobar") == "Zm9vYmFy");

        assert(rfc4648Standard.decode("Zg==").assumeOkay == cast(ubyte[])"f");
        assert(rfc4648Standard.decode("Zm8=").assumeOkay == cast(ubyte[])"fo");
        assert(rfc4648Standard.decode("Zm9v").assumeOkay == cast(ubyte[])"foo");
        assert(rfc4648Standard.decode("Zm9vYg==").assumeOkay == cast(ubyte[])"foob");
        assert(rfc4648Standard.decode("Zm9vYmE=").assumeOkay == cast(ubyte[])"fooba");
        assert(rfc4648Standard.decode("Zm9vYmFy").assumeOkay == cast(ubyte[])"foobar");
    }

    ///
    Base64!("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=") rfc4648URL;

    ///
    @trusted unittest {
        assert(rfc4648URL.encode(cast(ubyte[])"f") == "Zg==");
        assert(rfc4648URL.encode(cast(ubyte[])"fo") == "Zm8=");
        assert(rfc4648URL.encode(cast(ubyte[])"foo") == "Zm9v");
        assert(rfc4648URL.encode(cast(ubyte[])"foob") == "Zm9vYg==");
        assert(rfc4648URL.encode(cast(ubyte[])"fooba") == "Zm9vYmE=");
        assert(rfc4648URL.encode(cast(ubyte[])"foobar") == "Zm9vYmFy");

        assert(rfc4648URL.decode("Zg==").assumeOkay == cast(ubyte[])"f");
        assert(rfc4648URL.decode("Zm8=").assumeOkay == cast(ubyte[])"fo");
        assert(rfc4648URL.decode("Zm9v").assumeOkay == cast(ubyte[])"foo");
        assert(rfc4648URL.decode("Zm9vYg==").assumeOkay == cast(ubyte[])"foob");
        assert(rfc4648URL.decode("Zm9vYmE=").assumeOkay == cast(ubyte[])"fooba");
        assert(rfc4648URL.decode("Zm9vYmFy").assumeOkay == cast(ubyte[])"foobar");
    }

    ///
    Base64!("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", 64, "\r\n") rfc1421;
    ///
    Base64!("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", 76, "\r\n", true) rfc2045;
    ///
    Base64!("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=", 76, "\r\n") rfc4880;
    ///
    Base64!("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+,") rfc3501;
}
