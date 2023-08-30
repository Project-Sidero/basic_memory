/**
Implementation of cyclic redundancy check class of hash algorithms.

Supports widths of 8bits and above.

Based upon Ross N. Williams wonderful [guide to CRC algorithms](http://www.ross.net/crc/download/crc_v3.txt)
and the definitions are sourced from the project [CRC RevEng](https://reveng.sourceforge.io/crc-catalogue/all.htm).

License: Artistic v2
Authors: Richard (Rikki) Andrew Cattermole
Copyright: 2022 Richard Andrew Cattermole
 */
module sidero.base.hash.crc;

export:

/+
// The contents of this module are generated from the parameters below, using Chrome devtools
// for https://reveng.sourceforge.io/crc-catalogue/all.htm

// FIXME: does not generate FixedUNum types properly (wrt. arg)

var data = $$('p.academic code, p.attested code, p.third-party code, p.confirmed code').map(v => v.innerText).map(function(line) {
    var ret = {};

    line.split(" ").forEach(function(param) {
        var temp = param.split("=");
        ret[temp[0]] = temp[1].replaceAll("\"", "");
    });

    return ret;
});

document.body.innerText = "";

function append(text) {
  document.body.innerText += text;
}

function allEntries() {
    append('Entry[] params = [\n');

    data.forEach(function(entry) {
      if (entry.name == "CRC-82/DARC")
        return;
      append('    CRCSpec("' + entry.name.replace("CRC-", "crc").replace("/", "_").replace("-", "_") + '"');

      append(', ' + entry.width);
      append(', ' + entry.poly);
      append(', ' + entry.init);
      append(', ' + entry.xorout);
      append(', ' + entry.check);
      append(', ' + entry.residue);
      append(', ' + entry.refin);
      append(', ' + entry.refout);

      append("),\n");
    });

    append("];");
}

function generateGlobalEntries() {
    append('///\nimmutable {\n');

    data.forEach(function(entry) {
        if (entry.width < 8)
            return;

        var identifier = entry.name.replaceAll("CRC-", "crc").replaceAll("/", "_").replaceAll("-", "_");
        var typeSuffix = '';

        entry.width = parseInt(entry.width);

        if (entry.width <= 32)
            typeSuffix = '!uint';
        else if (entry.width <= 64)
            typeSuffix = '!ulong';
        else
            typeSuffix = '!(FixedUNum!' + parseInt((entry.width + 8) / 8) + ')';

        append('    /// ' + entry.name + ' hash\n');
        append('    CRC' + typeSuffix);
        append(' ' + identifier);

        append(' = CRC' + typeSuffix + '(CRCSpec' + typeSuffix + '(');

        append(/*', ' + */entry.width);
        append(', ' + entry.poly);
        append(', ' + entry.init);
        append(', ' + entry.xorout);
        append(', ' + entry.check);
        //append(', ' + entry.residue);
        append(', ' + entry.refin);
        append(', ' + entry.refout);

        append('));\n\n');

        append('    ///\n');
        append('    unittest {\n');
        append('        assert(' + identifier + '(cast(ubyte[])"123456789") == ' + identifier + '.specification.check);\n');
        append('    }\n\n');
    });

    append('}\n');
}

generateGlobalEntries();
+/

/// A specification of a CRC as per RockSoft's model
struct CRCSpec(WorkingType) {
    static assert(isValidWorkingTypeCRC!WorkingType, "CRC can only work with unsigned integral types or FixedUNum");

    //string name;

    ///
    int width;
    ///
    WorkingType polynomial, initialValue, xorOutput, check;

    // WorkingType residue;

    ///
    bool reverseBitsIn, reverseBitsOut;
}

/// The internal representation for a CRC
struct CRC(WorkingType) {
    static assert(isValidWorkingTypeCRC!WorkingType, "CRC can only work with unsigned integral types or FixedUNum");

    ///
    const {
        ///
        CRCSpec!WorkingType specification;
        ///
        WorkingType[256] table;
    }

    private bool haveTable;

const @safe nothrow @nogc pure:

    ///
    this(CRCSpec!WorkingType specification) {
        import sidero.base.bitmanip : bitMaskForNumberOfBits, reverseBitsLSB;

        this.specification = specification;

        {
            const topBitMask = WorkingType(1) << (specification.width - 1);
            WorkingType[256] tempTable;

            foreach(i, ref v; tempTable) {
                const inputWT = specification.reverseBitsIn ? WorkingType(reverseBitsLSB!ubyte(cast(ubyte)i, 8)) : WorkingType(cast(ubyte)i);
                WorkingType intermediateValue = inputWT << (specification.width - 8);

                foreach(_; 0 .. 8) {
                    const isTopBitSet = (intermediateValue & topBitMask) != 0;
                    intermediateValue <<= 1;

                    if(isTopBitSet)
                        intermediateValue ^= specification.polynomial;
                }

                if(specification.reverseBitsIn)
                    intermediateValue = reverseBitsLSB(intermediateValue, cast(uint)specification.width);

                v = intermediateValue & bitMaskForNumberOfBits!WorkingType(cast(uint)specification.width);
            }

            this.table = tempTable;
        }

        haveTable = true;
    }

    ///
    alias opCall = calculate;

    ///
    WorkingType calculate(scope const(ubyte)[] array...) {
        auto temp = startMultiRunCalculation();
        addToMultiRunCalculation(temp, array);
        return completeMultiRunCalculation(temp);
    }

    /**
        Calculate a crc hash in a multi-step process with ability to get partial hashes.

        See_Also: addToMultiRunCalculation, completeMultiRunCalculation
    */
    WorkingType startMultiRunCalculation() {
        import sidero.base.bitmanip : reverseBitsLSB;

        WorkingType ret = specification.initialValue;

        if(this.haveTable && specification.reverseBitsIn)
            ret = reverseBitsLSB!WorkingType(ret, cast()specification.width);

        return ret;
    }

    /// Ditto
    void addToMultiRunCalculation(scope ref WorkingType intermediateValue, scope const(ubyte)[] array...) {
        import sidero.base.bitmanip : bitMaskForNumberOfBits, reverseBitsLSB;

        const mask = bitMaskForNumberOfBits!WorkingType(specification.width);

        assert(this.haveTable);
        enum haveTable = true;

        if(haveTable) {
            ubyte firstByteIV() {
                static if(isIntegral!WorkingType)
                    return intermediateValue & 0xFF;
                else
                    return intermediateValue.getFirstByte();
            }

            ubyte shiftFirstByteIV(uint rsh) {
                auto temp = intermediateValue;
                temp >>= rsh;

                static if(isIntegral!WorkingType)
                    return temp & 0xFF;
                else
                    return temp.getFirstByte();
            }

            if(specification.reverseBitsIn) {
                foreach(input; array) {
                    intermediateValue = table[firstByteIV() ^ input] ^ (intermediateValue >> 8);
                    intermediateValue &= mask;
                }
            } else {
                foreach(input; array) {
                    intermediateValue = table[shiftFirstByteIV(specification.width - 8) ^ input] ^ (intermediateValue << 8);
                    intermediateValue &= mask;
                }
            }
        } else {
            // this is the straight forward implementation that does not use the table.
            // we don't need to use this, if we have the table

            const topBitMask = WorkingType(1) << (specification.width - 1);

            foreach(input; array) {
                const inputWT = specification.reverseBitsIn ? WorkingType(reverseBitsLSB!ubyte(input, 8)) : WorkingType(input);
                intermediateValue ^= inputWT << (specification.width - 8);

                foreach(i; 0 .. 8) {
                    const isTopBitSet = (intermediateValue & topBitMask) != 0;
                    intermediateValue <<= 1;

                    if(isTopBitSet)
                        intermediateValue ^= specification.polynomial;

                    intermediateValue &= mask;
                }
            }
        }
    }

    /// Ditto
    WorkingType completeMultiRunCalculation(WorkingType intermediateValue) {
        import sidero.base.bitmanip : reverseBitsLSB;

        assert(this.haveTable);
        enum haveTable = true;

        // For tables you need to check against reverse in as well as reverse out so it is only done once
        // https://stackoverflow.com/questions/28656471/how-to-configure-calculation-of-crc-table/28661073#28661073
        const reflect = (haveTable ? (specification.reverseBitsIn ^ specification.reverseBitsOut) : specification.reverseBitsOut) > 0;

        if(reflect)
            intermediateValue = reverseBitsLSB(cast()intermediateValue, cast()specification.width);

        return intermediateValue ^ specification.xorOutput;
    }
}

private {
    import std.traits : isIntegral, isUnsigned;

    enum isValidWorkingTypeCRC(T) = (isIntegral!T && isUnsigned!T) || is(T == FixedUNum!ByteCount, size_t ByteCount);
}

/// Compatible to CRC32/crc32Of in phobos.
alias crc32 = crc32_ISO_HDLC;
/// Compatible to CRC64ECMA/crc64ECMAOf in phobos.
alias crc64ECMA = crc64_ECMA_182;
/// Compatible to CRC64ISO/crc64ISOOf in phobos.
alias crc64ISOOf = crc64_GO_ISO;

///
immutable {
    /// CRC-8/AUTOSAR hash
    CRC!uint crc8_AUTOSAR = CRC!uint(CRCSpec!uint(8, 0x2f, 0xff, 0xff, 0xdf, false, false));

    ///
    unittest {
        assert(crc8_AUTOSAR(cast(ubyte[])"123456789") == crc8_AUTOSAR.specification.check);
    }

    /// CRC-8/BLUETOOTH hash
    CRC!uint crc8_BLUETOOTH = CRC!uint(CRCSpec!uint(8, 0xa7, 0x00, 0x00, 0x26, true, true));

    ///
    unittest {
        assert(crc8_BLUETOOTH(cast(ubyte[])"123456789") == crc8_BLUETOOTH.specification.check);
    }

    /// CRC-8/CDMA2000 hash
    CRC!uint crc8_CDMA2000 = CRC!uint(CRCSpec!uint(8, 0x9b, 0xff, 0x00, 0xda, false, false));

    ///
    unittest {
        assert(crc8_CDMA2000(cast(ubyte[])"123456789") == crc8_CDMA2000.specification.check);
    }

    /// CRC-8/DARC hash
    CRC!uint crc8_DARC = CRC!uint(CRCSpec!uint(8, 0x39, 0x00, 0x00, 0x15, true, true));

    ///
    unittest {
        assert(crc8_DARC(cast(ubyte[])"123456789") == crc8_DARC.specification.check);
    }

    /// CRC-8/DVB-S2 hash
    CRC!uint crc8_DVB_S2 = CRC!uint(CRCSpec!uint(8, 0xd5, 0x00, 0x00, 0xbc, false, false));

    ///
    unittest {
        assert(crc8_DVB_S2(cast(ubyte[])"123456789") == crc8_DVB_S2.specification.check);
    }

    /// CRC-8/GSM-A hash
    CRC!uint crc8_GSM_A = CRC!uint(CRCSpec!uint(8, 0x1d, 0x00, 0x00, 0x37, false, false));

    ///
    unittest {
        assert(crc8_GSM_A(cast(ubyte[])"123456789") == crc8_GSM_A.specification.check);
    }

    /// CRC-8/GSM-B hash
    CRC!uint crc8_GSM_B = CRC!uint(CRCSpec!uint(8, 0x49, 0x00, 0xff, 0x94, false, false));

    ///
    unittest {
        assert(crc8_GSM_B(cast(ubyte[])"123456789") == crc8_GSM_B.specification.check);
    }

    /// CRC-8/HITAG hash
    CRC!uint crc8_HITAG = CRC!uint(CRCSpec!uint(8, 0x1d, 0xff, 0x00, 0xb4, false, false));

    ///
    unittest {
        assert(crc8_HITAG(cast(ubyte[])"123456789") == crc8_HITAG.specification.check);
    }

    /// CRC-8/I-432-1 hash
    CRC!uint crc8_I_432_1 = CRC!uint(CRCSpec!uint(8, 0x07, 0x00, 0x55, 0xa1, false, false));

    ///
    unittest {
        assert(crc8_I_432_1(cast(ubyte[])"123456789") == crc8_I_432_1.specification.check);
    }

    /// CRC-8/I-CODE hash
    CRC!uint crc8_I_CODE = CRC!uint(CRCSpec!uint(8, 0x1d, 0xfd, 0x00, 0x7e, false, false));

    ///
    unittest {
        assert(crc8_I_CODE(cast(ubyte[])"123456789") == crc8_I_CODE.specification.check);
    }

    /// CRC-8/LTE hash
    CRC!uint crc8_LTE = CRC!uint(CRCSpec!uint(8, 0x9b, 0x00, 0x00, 0xea, false, false));

    ///
    unittest {
        assert(crc8_LTE(cast(ubyte[])"123456789") == crc8_LTE.specification.check);
    }

    /// CRC-8/MAXIM-DOW hash
    CRC!uint crc8_MAXIM_DOW = CRC!uint(CRCSpec!uint(8, 0x31, 0x00, 0x00, 0xa1, true, true));

    ///
    unittest {
        assert(crc8_MAXIM_DOW(cast(ubyte[])"123456789") == crc8_MAXIM_DOW.specification.check);
    }

    /// CRC-8/MIFARE-MAD hash
    CRC!uint crc8_MIFARE_MAD = CRC!uint(CRCSpec!uint(8, 0x1d, 0xc7, 0x00, 0x99, false, false));

    ///
    unittest {
        assert(crc8_MIFARE_MAD(cast(ubyte[])"123456789") == crc8_MIFARE_MAD.specification.check);
    }

    /// CRC-8/NRSC-5 hash
    CRC!uint crc8_NRSC_5 = CRC!uint(CRCSpec!uint(8, 0x31, 0xff, 0x00, 0xf7, false, false));

    ///
    unittest {
        assert(crc8_NRSC_5(cast(ubyte[])"123456789") == crc8_NRSC_5.specification.check);
    }

    /// CRC-8/OPENSAFETY hash
    CRC!uint crc8_OPENSAFETY = CRC!uint(CRCSpec!uint(8, 0x2f, 0x00, 0x00, 0x3e, false, false));

    ///
    unittest {
        assert(crc8_OPENSAFETY(cast(ubyte[])"123456789") == crc8_OPENSAFETY.specification.check);
    }

    /// CRC-8/ROHC hash
    CRC!uint crc8_ROHC = CRC!uint(CRCSpec!uint(8, 0x07, 0xff, 0x00, 0xd0, true, true));

    ///
    unittest {
        assert(crc8_ROHC(cast(ubyte[])"123456789") == crc8_ROHC.specification.check);
    }

    /// CRC-8/SAE-J1850 hash
    CRC!uint crc8_SAE_J1850 = CRC!uint(CRCSpec!uint(8, 0x1d, 0xff, 0xff, 0x4b, false, false));

    ///
    unittest {
        assert(crc8_SAE_J1850(cast(ubyte[])"123456789") == crc8_SAE_J1850.specification.check);
    }

    /// CRC-8/SMBUS hash
    CRC!uint crc8_SMBUS = CRC!uint(CRCSpec!uint(8, 0x07, 0x00, 0x00, 0xf4, false, false));

    ///
    unittest {
        assert(crc8_SMBUS(cast(ubyte[])"123456789") == crc8_SMBUS.specification.check);
    }

    /// CRC-8/TECH-3250 hash
    CRC!uint crc8_TECH_3250 = CRC!uint(CRCSpec!uint(8, 0x1d, 0xff, 0x00, 0x97, true, true));

    ///
    unittest {
        assert(crc8_TECH_3250(cast(ubyte[])"123456789") == crc8_TECH_3250.specification.check);
    }

    /// CRC-8/WCDMA hash
    CRC!uint crc8_WCDMA = CRC!uint(CRCSpec!uint(8, 0x9b, 0x00, 0x00, 0x25, true, true));

    ///
    unittest {
        assert(crc8_WCDMA(cast(ubyte[])"123456789") == crc8_WCDMA.specification.check);
    }

    /// CRC-10/ATM hash
    CRC!uint crc10_ATM = CRC!uint(CRCSpec!uint(10, 0x233, 0x000, 0x000, 0x199, false, false));

    ///
    unittest {
        assert(crc10_ATM(cast(ubyte[])"123456789") == crc10_ATM.specification.check);
    }

    /// CRC-10/CDMA2000 hash
    CRC!uint crc10_CDMA2000 = CRC!uint(CRCSpec!uint(10, 0x3d9, 0x3ff, 0x000, 0x233, false, false));

    ///
    unittest {
        assert(crc10_CDMA2000(cast(ubyte[])"123456789") == crc10_CDMA2000.specification.check);
    }

    /// CRC-10/GSM hash
    CRC!uint crc10_GSM = CRC!uint(CRCSpec!uint(10, 0x175, 0x000, 0x3ff, 0x12a, false, false));

    ///
    unittest {
        assert(crc10_GSM(cast(ubyte[])"123456789") == crc10_GSM.specification.check);
    }

    /// CRC-11/FLEXRAY hash
    CRC!uint crc11_FLEXRAY = CRC!uint(CRCSpec!uint(11, 0x385, 0x01a, 0x000, 0x5a3, false, false));

    ///
    unittest {
        assert(crc11_FLEXRAY(cast(ubyte[])"123456789") == crc11_FLEXRAY.specification.check);
    }

    /// CRC-11/UMTS hash
    CRC!uint crc11_UMTS = CRC!uint(CRCSpec!uint(11, 0x307, 0x000, 0x000, 0x061, false, false));

    ///
    unittest {
        assert(crc11_UMTS(cast(ubyte[])"123456789") == crc11_UMTS.specification.check);
    }

    /// CRC-12/CDMA2000 hash
    CRC!uint crc12_CDMA2000 = CRC!uint(CRCSpec!uint(12, 0xf13, 0xfff, 0x000, 0xd4d, false, false));

    ///
    unittest {
        assert(crc12_CDMA2000(cast(ubyte[])"123456789") == crc12_CDMA2000.specification.check);
    }

    /// CRC-12/DECT hash
    CRC!uint crc12_DECT = CRC!uint(CRCSpec!uint(12, 0x80f, 0x000, 0x000, 0xf5b, false, false));

    ///
    unittest {
        assert(crc12_DECT(cast(ubyte[])"123456789") == crc12_DECT.specification.check);
    }

    /// CRC-12/GSM hash
    CRC!uint crc12_GSM = CRC!uint(CRCSpec!uint(12, 0xd31, 0x000, 0xfff, 0xb34, false, false));

    ///
    unittest {
        assert(crc12_GSM(cast(ubyte[])"123456789") == crc12_GSM.specification.check);
    }

    /// CRC-12/UMTS hash
    CRC!uint crc12_UMTS = CRC!uint(CRCSpec!uint(12, 0x80f, 0x000, 0x000, 0xdaf, false, true));

    ///
    unittest {
        assert(crc12_UMTS(cast(ubyte[])"123456789") == crc12_UMTS.specification.check);
    }

    /// CRC-13/BBC hash
    CRC!uint crc13_BBC = CRC!uint(CRCSpec!uint(13, 0x1cf5, 0x0000, 0x0000, 0x04fa, false, false));

    ///
    unittest {
        assert(crc13_BBC(cast(ubyte[])"123456789") == crc13_BBC.specification.check);
    }

    /// CRC-14/DARC hash
    CRC!uint crc14_DARC = CRC!uint(CRCSpec!uint(14, 0x0805, 0x0000, 0x0000, 0x082d, true, true));

    ///
    unittest {
        assert(crc14_DARC(cast(ubyte[])"123456789") == crc14_DARC.specification.check);
    }

    /// CRC-14/GSM hash
    CRC!uint crc14_GSM = CRC!uint(CRCSpec!uint(14, 0x202d, 0x0000, 0x3fff, 0x30ae, false, false));

    ///
    unittest {
        assert(crc14_GSM(cast(ubyte[])"123456789") == crc14_GSM.specification.check);
    }

    /// CRC-15/CAN hash
    CRC!uint crc15_CAN = CRC!uint(CRCSpec!uint(15, 0x4599, 0x0000, 0x0000, 0x059e, false, false));

    ///
    unittest {
        assert(crc15_CAN(cast(ubyte[])"123456789") == crc15_CAN.specification.check);
    }

    /// CRC-15/MPT1327 hash
    CRC!uint crc15_MPT1327 = CRC!uint(CRCSpec!uint(15, 0x6815, 0x0000, 0x0001, 0x2566, false, false));

    ///
    unittest {
        assert(crc15_MPT1327(cast(ubyte[])"123456789") == crc15_MPT1327.specification.check);
    }

    /// CRC-16/ARC hash
    CRC!uint crc16_ARC = CRC!uint(CRCSpec!uint(16, 0x8005, 0x0000, 0x0000, 0xbb3d, true, true));

    ///
    unittest {
        assert(crc16_ARC(cast(ubyte[])"123456789") == crc16_ARC.specification.check);
    }

    /// CRC-16/CDMA2000 hash
    CRC!uint crc16_CDMA2000 = CRC!uint(CRCSpec!uint(16, 0xc867, 0xffff, 0x0000, 0x4c06, false, false));

    ///
    unittest {
        assert(crc16_CDMA2000(cast(ubyte[])"123456789") == crc16_CDMA2000.specification.check);
    }

    /// CRC-16/CMS hash
    CRC!uint crc16_CMS = CRC!uint(CRCSpec!uint(16, 0x8005, 0xffff, 0x0000, 0xaee7, false, false));

    ///
    unittest {
        assert(crc16_CMS(cast(ubyte[])"123456789") == crc16_CMS.specification.check);
    }

    /// CRC-16/DDS-110 hash
    CRC!uint crc16_DDS_110 = CRC!uint(CRCSpec!uint(16, 0x8005, 0x800d, 0x0000, 0x9ecf, false, false));

    ///
    unittest {
        assert(crc16_DDS_110(cast(ubyte[])"123456789") == crc16_DDS_110.specification.check);
    }

    /// CRC-16/DECT-R hash
    CRC!uint crc16_DECT_R = CRC!uint(CRCSpec!uint(16, 0x0589, 0x0000, 0x0001, 0x007e, false, false));

    ///
    unittest {
        assert(crc16_DECT_R(cast(ubyte[])"123456789") == crc16_DECT_R.specification.check);
    }

    /// CRC-16/DECT-X hash
    CRC!uint crc16_DECT_X = CRC!uint(CRCSpec!uint(16, 0x0589, 0x0000, 0x0000, 0x007f, false, false));

    ///
    unittest {
        assert(crc16_DECT_X(cast(ubyte[])"123456789") == crc16_DECT_X.specification.check);
    }

    /// CRC-16/DNP hash
    CRC!uint crc16_DNP = CRC!uint(CRCSpec!uint(16, 0x3d65, 0x0000, 0xffff, 0xea82, true, true));

    ///
    unittest {
        assert(crc16_DNP(cast(ubyte[])"123456789") == crc16_DNP.specification.check);
    }

    /// CRC-16/EN-13757 hash
    CRC!uint crc16_EN_13757 = CRC!uint(CRCSpec!uint(16, 0x3d65, 0x0000, 0xffff, 0xc2b7, false, false));

    ///
    unittest {
        assert(crc16_EN_13757(cast(ubyte[])"123456789") == crc16_EN_13757.specification.check);
    }

    /// CRC-16/GENIBUS hash
    CRC!uint crc16_GENIBUS = CRC!uint(CRCSpec!uint(16, 0x1021, 0xffff, 0xffff, 0xd64e, false, false));

    ///
    unittest {
        assert(crc16_GENIBUS(cast(ubyte[])"123456789") == crc16_GENIBUS.specification.check);
    }

    /// CRC-16/GSM hash
    CRC!uint crc16_GSM = CRC!uint(CRCSpec!uint(16, 0x1021, 0x0000, 0xffff, 0xce3c, false, false));

    ///
    unittest {
        assert(crc16_GSM(cast(ubyte[])"123456789") == crc16_GSM.specification.check);
    }

    /// CRC-16/IBM-3740 hash
    CRC!uint crc16_IBM_3740 = CRC!uint(CRCSpec!uint(16, 0x1021, 0xffff, 0x0000, 0x29b1, false, false));

    ///
    unittest {
        assert(crc16_IBM_3740(cast(ubyte[])"123456789") == crc16_IBM_3740.specification.check);
    }

    /// CRC-16/IBM-SDLC hash
    CRC!uint crc16_IBM_SDLC = CRC!uint(CRCSpec!uint(16, 0x1021, 0xffff, 0xffff, 0x906e, true, true));

    ///
    unittest {
        assert(crc16_IBM_SDLC(cast(ubyte[])"123456789") == crc16_IBM_SDLC.specification.check);
    }

    /// CRC-16/ISO-IEC-14443-3-A hash
    CRC!uint crc16_ISO_IEC_14443_3_A = CRC!uint(CRCSpec!uint(16, 0x1021, 0xc6c6, 0x0000, 0xbf05, true, true));

    ///
    unittest {
        assert(crc16_ISO_IEC_14443_3_A(cast(ubyte[])"123456789") == crc16_ISO_IEC_14443_3_A.specification.check);
    }

    /// CRC-16/KERMIT hash
    CRC!uint crc16_KERMIT = CRC!uint(CRCSpec!uint(16, 0x1021, 0x0000, 0x0000, 0x2189, true, true));

    ///
    unittest {
        assert(crc16_KERMIT(cast(ubyte[])"123456789") == crc16_KERMIT.specification.check);
    }

    /// CRC-16/LJ1200 hash
    CRC!uint crc16_LJ1200 = CRC!uint(CRCSpec!uint(16, 0x6f63, 0x0000, 0x0000, 0xbdf4, false, false));

    ///
    unittest {
        assert(crc16_LJ1200(cast(ubyte[])"123456789") == crc16_LJ1200.specification.check);
    }

    /// CRC-16/MAXIM-DOW hash
    CRC!uint crc16_MAXIM_DOW = CRC!uint(CRCSpec!uint(16, 0x8005, 0x0000, 0xffff, 0x44c2, true, true));

    ///
    unittest {
        assert(crc16_MAXIM_DOW(cast(ubyte[])"123456789") == crc16_MAXIM_DOW.specification.check);
    }

    /// CRC-16/MCRF4XX hash
    CRC!uint crc16_MCRF4XX = CRC!uint(CRCSpec!uint(16, 0x1021, 0xffff, 0x0000, 0x6f91, true, true));

    ///
    unittest {
        assert(crc16_MCRF4XX(cast(ubyte[])"123456789") == crc16_MCRF4XX.specification.check);
    }

    /// CRC-16/MODBUS hash
    CRC!uint crc16_MODBUS = CRC!uint(CRCSpec!uint(16, 0x8005, 0xffff, 0x0000, 0x4b37, true, true));

    ///
    unittest {
        assert(crc16_MODBUS(cast(ubyte[])"123456789") == crc16_MODBUS.specification.check);
    }

    /// CRC-16/NRSC-5 hash
    CRC!uint crc16_NRSC_5 = CRC!uint(CRCSpec!uint(16, 0x080b, 0xffff, 0x0000, 0xa066, true, true));

    ///
    unittest {
        assert(crc16_NRSC_5(cast(ubyte[])"123456789") == crc16_NRSC_5.specification.check);
    }

    /// CRC-16/OPENSAFETY-A hash
    CRC!uint crc16_OPENSAFETY_A = CRC!uint(CRCSpec!uint(16, 0x5935, 0x0000, 0x0000, 0x5d38, false, false));

    ///
    unittest {
        assert(crc16_OPENSAFETY_A(cast(ubyte[])"123456789") == crc16_OPENSAFETY_A.specification.check);
    }

    /// CRC-16/OPENSAFETY-B hash
    CRC!uint crc16_OPENSAFETY_B = CRC!uint(CRCSpec!uint(16, 0x755b, 0x0000, 0x0000, 0x20fe, false, false));

    ///
    unittest {
        assert(crc16_OPENSAFETY_B(cast(ubyte[])"123456789") == crc16_OPENSAFETY_B.specification.check);
    }

    /// CRC-16/PROFIBUS hash
    CRC!uint crc16_PROFIBUS = CRC!uint(CRCSpec!uint(16, 0x1dcf, 0xffff, 0xffff, 0xa819, false, false));

    ///
    unittest {
        assert(crc16_PROFIBUS(cast(ubyte[])"123456789") == crc16_PROFIBUS.specification.check);
    }

    /// CRC-16/RIELLO hash
    CRC!uint crc16_RIELLO = CRC!uint(CRCSpec!uint(16, 0x1021, 0xb2aa, 0x0000, 0x63d0, true, true));

    ///
    unittest {
        assert(crc16_RIELLO(cast(ubyte[])"123456789") == crc16_RIELLO.specification.check);
    }

    /// CRC-16/SPI-FUJITSU hash
    CRC!uint crc16_SPI_FUJITSU = CRC!uint(CRCSpec!uint(16, 0x1021, 0x1d0f, 0x0000, 0xe5cc, false, false));

    ///
    unittest {
        assert(crc16_SPI_FUJITSU(cast(ubyte[])"123456789") == crc16_SPI_FUJITSU.specification.check);
    }

    /// CRC-16/T10-DIF hash
    CRC!uint crc16_T10_DIF = CRC!uint(CRCSpec!uint(16, 0x8bb7, 0x0000, 0x0000, 0xd0db, false, false));

    ///
    unittest {
        assert(crc16_T10_DIF(cast(ubyte[])"123456789") == crc16_T10_DIF.specification.check);
    }

    /// CRC-16/TELEDISK hash
    CRC!uint crc16_TELEDISK = CRC!uint(CRCSpec!uint(16, 0xa097, 0x0000, 0x0000, 0x0fb3, false, false));

    ///
    unittest {
        assert(crc16_TELEDISK(cast(ubyte[])"123456789") == crc16_TELEDISK.specification.check);
    }

    /// CRC-16/TMS37157 hash
    CRC!uint crc16_TMS37157 = CRC!uint(CRCSpec!uint(16, 0x1021, 0x89ec, 0x0000, 0x26b1, true, true));

    ///
    unittest {
        assert(crc16_TMS37157(cast(ubyte[])"123456789") == crc16_TMS37157.specification.check);
    }

    /// CRC-16/UMTS hash
    CRC!uint crc16_UMTS = CRC!uint(CRCSpec!uint(16, 0x8005, 0x0000, 0x0000, 0xfee8, false, false));

    ///
    unittest {
        assert(crc16_UMTS(cast(ubyte[])"123456789") == crc16_UMTS.specification.check);
    }

    /// CRC-16/USB hash
    CRC!uint crc16_USB = CRC!uint(CRCSpec!uint(16, 0x8005, 0xffff, 0xffff, 0xb4c8, true, true));

    ///
    unittest {
        assert(crc16_USB(cast(ubyte[])"123456789") == crc16_USB.specification.check);
    }

    /// CRC-16/XMODEM hash
    CRC!uint crc16_XMODEM = CRC!uint(CRCSpec!uint(16, 0x1021, 0x0000, 0x0000, 0x31c3, false, false));

    ///
    unittest {
        assert(crc16_XMODEM(cast(ubyte[])"123456789") == crc16_XMODEM.specification.check);
    }

    /// CRC-17/CAN-FD hash
    CRC!uint crc17_CAN_FD = CRC!uint(CRCSpec!uint(17, 0x1685b, 0x00000, 0x00000, 0x04f03, false, false));

    ///
    unittest {
        assert(crc17_CAN_FD(cast(ubyte[])"123456789") == crc17_CAN_FD.specification.check);
    }

    /// CRC-21/CAN-FD hash
    CRC!uint crc21_CAN_FD = CRC!uint(CRCSpec!uint(21, 0x102899, 0x000000, 0x000000, 0x0ed841, false, false));

    ///
    unittest {
        assert(crc21_CAN_FD(cast(ubyte[])"123456789") == crc21_CAN_FD.specification.check);
    }

    /// CRC-24/BLE hash
    CRC!uint crc24_BLE = CRC!uint(CRCSpec!uint(24, 0x00065b, 0x555555, 0x000000, 0xc25a56, true, true));

    ///
    unittest {
        assert(crc24_BLE(cast(ubyte[])"123456789") == crc24_BLE.specification.check);
    }

    /// CRC-24/FLEXRAY-A hash
    CRC!uint crc24_FLEXRAY_A = CRC!uint(CRCSpec!uint(24, 0x5d6dcb, 0xfedcba, 0x000000, 0x7979bd, false, false));

    ///
    unittest {
        assert(crc24_FLEXRAY_A(cast(ubyte[])"123456789") == crc24_FLEXRAY_A.specification.check);
    }

    /// CRC-24/FLEXRAY-B hash
    CRC!uint crc24_FLEXRAY_B = CRC!uint(CRCSpec!uint(24, 0x5d6dcb, 0xabcdef, 0x000000, 0x1f23b8, false, false));

    ///
    unittest {
        assert(crc24_FLEXRAY_B(cast(ubyte[])"123456789") == crc24_FLEXRAY_B.specification.check);
    }

    /// CRC-24/INTERLAKEN hash
    CRC!uint crc24_INTERLAKEN = CRC!uint(CRCSpec!uint(24, 0x328b63, 0xffffff, 0xffffff, 0xb4f3e6, false, false));

    ///
    unittest {
        assert(crc24_INTERLAKEN(cast(ubyte[])"123456789") == crc24_INTERLAKEN.specification.check);
    }

    /// CRC-24/LTE-A hash
    CRC!uint crc24_LTE_A = CRC!uint(CRCSpec!uint(24, 0x864cfb, 0x000000, 0x000000, 0xcde703, false, false));

    ///
    unittest {
        assert(crc24_LTE_A(cast(ubyte[])"123456789") == crc24_LTE_A.specification.check);
    }

    /// CRC-24/LTE-B hash
    CRC!uint crc24_LTE_B = CRC!uint(CRCSpec!uint(24, 0x800063, 0x000000, 0x000000, 0x23ef52, false, false));

    ///
    unittest {
        assert(crc24_LTE_B(cast(ubyte[])"123456789") == crc24_LTE_B.specification.check);
    }

    /// CRC-24/OPENPGP hash
    CRC!uint crc24_OPENPGP = CRC!uint(CRCSpec!uint(24, 0x864cfb, 0xb704ce, 0x000000, 0x21cf02, false, false));

    ///
    unittest {
        assert(crc24_OPENPGP(cast(ubyte[])"123456789") == crc24_OPENPGP.specification.check);
    }

    /// CRC-24/OS-9 hash
    CRC!uint crc24_OS_9 = CRC!uint(CRCSpec!uint(24, 0x800063, 0xffffff, 0xffffff, 0x200fa5, false, false));

    ///
    unittest {
        assert(crc24_OS_9(cast(ubyte[])"123456789") == crc24_OS_9.specification.check);
    }

    /// CRC-30/CDMA hash
    CRC!uint crc30_CDMA = CRC!uint(CRCSpec!uint(30, 0x2030b9c7, 0x3fffffff, 0x3fffffff, 0x04c34abf, false, false));

    ///
    unittest {
        assert(crc30_CDMA(cast(ubyte[])"123456789") == crc30_CDMA.specification.check);
    }

    /// CRC-31/PHILIPS hash
    CRC!uint crc31_PHILIPS = CRC!uint(CRCSpec!uint(31, 0x04c11db7, 0x7fffffff, 0x7fffffff, 0x0ce9e46c, false, false));

    ///
    unittest {
        assert(crc31_PHILIPS(cast(ubyte[])"123456789") == crc31_PHILIPS.specification.check);
    }

    /// CRC-32/AIXM hash
    CRC!uint crc32_AIXM = CRC!uint(CRCSpec!uint(32, 0x814141ab, 0x00000000, 0x00000000, 0x3010bf7f, false, false));

    ///
    unittest {
        assert(crc32_AIXM(cast(ubyte[])"123456789") == crc32_AIXM.specification.check);
    }

    /// CRC-32/AUTOSAR hash
    CRC!uint crc32_AUTOSAR = CRC!uint(CRCSpec!uint(32, 0xf4acfb13, 0xffffffff, 0xffffffff, 0x1697d06a, true, true));

    ///
    unittest {
        assert(crc32_AUTOSAR(cast(ubyte[])"123456789") == crc32_AUTOSAR.specification.check);
    }

    /// CRC-32/BASE91-D hash
    CRC!uint crc32_BASE91_D = CRC!uint(CRCSpec!uint(32, 0xa833982b, 0xffffffff, 0xffffffff, 0x87315576, true, true));

    ///
    unittest {
        assert(crc32_BASE91_D(cast(ubyte[])"123456789") == crc32_BASE91_D.specification.check);
    }

    /// CRC-32/BZIP2 hash
    CRC!uint crc32_BZIP2 = CRC!uint(CRCSpec!uint(32, 0x04c11db7, 0xffffffff, 0xffffffff, 0xfc891918, false, false));

    ///
    unittest {
        assert(crc32_BZIP2(cast(ubyte[])"123456789") == crc32_BZIP2.specification.check);
    }

    /// CRC-32/CD-ROM-EDC hash
    CRC!uint crc32_CD_ROM_EDC = CRC!uint(CRCSpec!uint(32, 0x8001801b, 0x00000000, 0x00000000, 0x6ec2edc4, true, true));

    ///
    unittest {
        assert(crc32_CD_ROM_EDC(cast(ubyte[])"123456789") == crc32_CD_ROM_EDC.specification.check);
    }

    /// CRC-32/CKSUM hash
    CRC!uint crc32_CKSUM = CRC!uint(CRCSpec!uint(32, 0x04c11db7, 0x00000000, 0xffffffff, 0x765e7680, false, false));

    ///
    unittest {
        assert(crc32_CKSUM(cast(ubyte[])"123456789") == crc32_CKSUM.specification.check);
    }

    /// CRC-32/ISCSI hash
    CRC!uint crc32_ISCSI = CRC!uint(CRCSpec!uint(32, 0x1edc6f41, 0xffffffff, 0xffffffff, 0xe3069283, true, true));

    ///
    unittest {
        assert(crc32_ISCSI(cast(ubyte[])"123456789") == crc32_ISCSI.specification.check);
    }

    /// CRC-32/ISO-HDLC hash
    CRC!uint crc32_ISO_HDLC = CRC!uint(CRCSpec!uint(32, 0x04c11db7, 0xffffffff, 0xffffffff, 0xcbf43926, true, true));

    ///
    unittest {
        assert(crc32_ISO_HDLC(cast(ubyte[])"123456789") == crc32_ISO_HDLC.specification.check);

        import std.digest.crc : crc32Of;

        auto temp = crc32Of(cast(ubyte[])"123456789");
        assert(*cast(uint*)(&temp[0]) == crc32_ISO_HDLC.specification.check);
    }

    /// CRC-32/JAMCRC hash
    CRC!uint crc32_JAMCRC = CRC!uint(CRCSpec!uint(32, 0x04c11db7, 0xffffffff, 0x00000000, 0x340bc6d9, true, true));

    ///
    unittest {
        assert(crc32_JAMCRC(cast(ubyte[])"123456789") == crc32_JAMCRC.specification.check);
    }

    /// CRC-32/MEF hash
    CRC!uint crc32_MEF = CRC!uint(CRCSpec!uint(32, 0x741b8cd7, 0xffffffff, 0x00000000, 0xd2c22f51, true, true));

    ///
    unittest {
        assert(crc32_MEF(cast(ubyte[])"123456789") == crc32_MEF.specification.check);
    }

    /// CRC-32/MPEG-2 hash
    CRC!uint crc32_MPEG_2 = CRC!uint(CRCSpec!uint(32, 0x04c11db7, 0xffffffff, 0x00000000, 0x0376e6e7, false, false));

    ///
    unittest {
        assert(crc32_MPEG_2(cast(ubyte[])"123456789") == crc32_MPEG_2.specification.check);
    }

    /// CRC-32/XFER hash
    CRC!uint crc32_XFER = CRC!uint(CRCSpec!uint(32, 0x000000af, 0x00000000, 0x00000000, 0xbd0be338, false, false));

    ///
    unittest {
        assert(crc32_XFER(cast(ubyte[])"123456789") == crc32_XFER.specification.check);
    }

    /// CRC-40/GSM hash
    CRC!ulong crc40_GSM = CRC!ulong(CRCSpec!ulong(40, 0x0004820009, 0x0000000000, 0xffffffffff, 0xd4164fc646, false, false));

    ///
    unittest {
        assert(crc40_GSM(cast(ubyte[])"123456789") == crc40_GSM.specification.check);
    }

    /// CRC-64/ECMA-182 hash
    CRC!ulong crc64_ECMA_182 = CRC!ulong(CRCSpec!ulong(64, 0x42f0e1eba9ea3693, 0x0000000000000000, 0x0000000000000000,
            0x6c40df5f0b497347, false, false));

    ///
    unittest {
        assert(crc64_ECMA_182(cast(ubyte[])"123456789") == crc64_ECMA_182.specification.check);
    }

    /// CRC-64/GO-ISO hash
    CRC!ulong crc64_GO_ISO = CRC!ulong(CRCSpec!ulong(64, 0x000000000000001b, 0xffffffffffffffff, 0xffffffffffffffff,
            0xb90956c775a41001, true, true));

    ///
    unittest {
        assert(crc64_GO_ISO(cast(ubyte[])"123456789") == crc64_GO_ISO.specification.check);
    }

    /// CRC-64/MS hash
    CRC!ulong crc64_MS = CRC!ulong(CRCSpec!ulong(64, 0x259c84cba6426349, 0xffffffffffffffff, 0x0000000000000000,
            0x75d4b74f024eceea, true, true));

    ///
    unittest {
        assert(crc64_MS(cast(ubyte[])"123456789") == crc64_MS.specification.check);
    }

    /// CRC-64/WE hash
    CRC!ulong crc64_WE = CRC!ulong(CRCSpec!ulong(64, 0x42f0e1eba9ea3693, 0xffffffffffffffff, 0xffffffffffffffff,
            0x62ec59e3f1a4f00a, false, false));

    ///
    unittest {
        assert(crc64_WE(cast(ubyte[])"123456789") == crc64_WE.specification.check);
    }

    /// CRC-64/XZ hash
    CRC!ulong crc64_XZ = CRC!ulong(CRCSpec!ulong(64, 0x42f0e1eba9ea3693, 0xffffffffffffffff, 0xffffffffffffffff,
            0x995dc9bbdf1939fa, true, true));

    ///
    unittest {
        assert(crc64_XZ(cast(ubyte[])"123456789") == crc64_XZ.specification.check);
    }

    /+
    /// CRC-82/DARC hash
    CRC!(FixedUNum!11) crc82_DARC = CRC!(FixedUNum!11)(CRCSpec!(FixedUNum!11)(82, 0x0308c0111011401440411,
            0x000000000000000000000, 0x000000000000000000000, 0x09ea83f625023801fd612, true, true));

    ///
    unittest {
        assert(crc82_DARC(cast(ubyte[])"123456789") == crc82_DARC.specification.check);
    }
    +/
}
