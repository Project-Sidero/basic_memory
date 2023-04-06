module sidero.base.internal.unicode.casefolding;

// Generated do not modify
export extern(C) immutable(dstring) sidero_utf_lut_getCaseFolding(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x41 && input <= 0xFF3A) {
        if (input <= 0x2CF2) {
            if (input <= 0x5A)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(0 + (input - 0x41))];
            else if (input == 0xB5)
                return cast(dstring)LUT_9E8CB5FE_DString[0 .. 1];
            else if (input >= 0xC0 && input <= 0xDF)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(26 + (input - 0xC0))];
            else if (input == 0x100)
                return cast(dstring)LUT_9E8CB5FE_DString[1 .. 2];
            else if (input == 0x102)
                return cast(dstring)LUT_9E8CB5FE_DString[2 .. 3];
            else if (input == 0x104)
                return cast(dstring)LUT_9E8CB5FE_DString[3 .. 4];
            else if (input == 0x106)
                return cast(dstring)LUT_9E8CB5FE_DString[4 .. 5];
            else if (input == 0x108)
                return cast(dstring)LUT_9E8CB5FE_DString[5 .. 6];
            else if (input == 0x10A)
                return cast(dstring)LUT_9E8CB5FE_DString[6 .. 7];
            else if (input == 0x10C)
                return cast(dstring)LUT_9E8CB5FE_DString[7 .. 8];
            else if (input == 0x10E)
                return cast(dstring)LUT_9E8CB5FE_DString[8 .. 9];
            else if (input == 0x110)
                return cast(dstring)LUT_9E8CB5FE_DString[9 .. 10];
            else if (input == 0x112)
                return cast(dstring)LUT_9E8CB5FE_DString[10 .. 11];
            else if (input == 0x114)
                return cast(dstring)LUT_9E8CB5FE_DString[11 .. 12];
            else if (input == 0x116)
                return cast(dstring)LUT_9E8CB5FE_DString[12 .. 13];
            else if (input == 0x118)
                return cast(dstring)LUT_9E8CB5FE_DString[13 .. 14];
            else if (input == 0x11A)
                return cast(dstring)LUT_9E8CB5FE_DString[14 .. 15];
            else if (input == 0x11C)
                return cast(dstring)LUT_9E8CB5FE_DString[15 .. 16];
            else if (input == 0x11E)
                return cast(dstring)LUT_9E8CB5FE_DString[16 .. 17];
            else if (input == 0x120)
                return cast(dstring)LUT_9E8CB5FE_DString[17 .. 18];
            else if (input == 0x122)
                return cast(dstring)LUT_9E8CB5FE_DString[18 .. 19];
            else if (input == 0x124)
                return cast(dstring)LUT_9E8CB5FE_DString[19 .. 20];
            else if (input == 0x126)
                return cast(dstring)LUT_9E8CB5FE_DString[20 .. 21];
            else if (input == 0x128)
                return cast(dstring)LUT_9E8CB5FE_DString[21 .. 22];
            else if (input == 0x12A)
                return cast(dstring)LUT_9E8CB5FE_DString[22 .. 23];
            else if (input == 0x12C)
                return cast(dstring)LUT_9E8CB5FE_DString[23 .. 24];
            else if (input == 0x12E)
                return cast(dstring)LUT_9E8CB5FE_DString[24 .. 25];
            else if (input == 0x130)
                return cast(dstring)LUT_9E8CB5FE_DString[25 .. 27];
            else if (input == 0x132)
                return cast(dstring)LUT_9E8CB5FE_DString[27 .. 28];
            else if (input == 0x134)
                return cast(dstring)LUT_9E8CB5FE_DString[28 .. 29];
            else if (input == 0x136)
                return cast(dstring)LUT_9E8CB5FE_DString[29 .. 30];
            else if (input == 0x139)
                return cast(dstring)LUT_9E8CB5FE_DString[30 .. 31];
            else if (input == 0x13B)
                return cast(dstring)LUT_9E8CB5FE_DString[31 .. 32];
            else if (input == 0x13D)
                return cast(dstring)LUT_9E8CB5FE_DString[32 .. 33];
            else if (input == 0x13F)
                return cast(dstring)LUT_9E8CB5FE_DString[33 .. 34];
            else if (input == 0x141)
                return cast(dstring)LUT_9E8CB5FE_DString[34 .. 35];
            else if (input == 0x143)
                return cast(dstring)LUT_9E8CB5FE_DString[35 .. 36];
            else if (input == 0x145)
                return cast(dstring)LUT_9E8CB5FE_DString[36 .. 37];
            else if (input == 0x147)
                return cast(dstring)LUT_9E8CB5FE_DString[37 .. 38];
            else if (input == 0x149)
                return cast(dstring)LUT_9E8CB5FE_DString[38 .. 40];
            else if (input == 0x14A)
                return cast(dstring)LUT_9E8CB5FE_DString[40 .. 41];
            else if (input == 0x14C)
                return cast(dstring)LUT_9E8CB5FE_DString[41 .. 42];
            else if (input == 0x14E)
                return cast(dstring)LUT_9E8CB5FE_DString[42 .. 43];
            else if (input == 0x150)
                return cast(dstring)LUT_9E8CB5FE_DString[43 .. 44];
            else if (input == 0x152)
                return cast(dstring)LUT_9E8CB5FE_DString[44 .. 45];
            else if (input == 0x154)
                return cast(dstring)LUT_9E8CB5FE_DString[45 .. 46];
            else if (input == 0x156)
                return cast(dstring)LUT_9E8CB5FE_DString[46 .. 47];
            else if (input == 0x158)
                return cast(dstring)LUT_9E8CB5FE_DString[47 .. 48];
            else if (input == 0x15A)
                return cast(dstring)LUT_9E8CB5FE_DString[48 .. 49];
            else if (input == 0x15C)
                return cast(dstring)LUT_9E8CB5FE_DString[49 .. 50];
            else if (input == 0x15E)
                return cast(dstring)LUT_9E8CB5FE_DString[50 .. 51];
            else if (input == 0x160)
                return cast(dstring)LUT_9E8CB5FE_DString[51 .. 52];
            else if (input == 0x162)
                return cast(dstring)LUT_9E8CB5FE_DString[52 .. 53];
            else if (input == 0x164)
                return cast(dstring)LUT_9E8CB5FE_DString[53 .. 54];
            else if (input == 0x166)
                return cast(dstring)LUT_9E8CB5FE_DString[54 .. 55];
            else if (input == 0x168)
                return cast(dstring)LUT_9E8CB5FE_DString[55 .. 56];
            else if (input == 0x16A)
                return cast(dstring)LUT_9E8CB5FE_DString[56 .. 57];
            else if (input == 0x16C)
                return cast(dstring)LUT_9E8CB5FE_DString[57 .. 58];
            else if (input == 0x16E)
                return cast(dstring)LUT_9E8CB5FE_DString[58 .. 59];
            else if (input == 0x170)
                return cast(dstring)LUT_9E8CB5FE_DString[59 .. 60];
            else if (input == 0x172)
                return cast(dstring)LUT_9E8CB5FE_DString[60 .. 61];
            else if (input == 0x174)
                return cast(dstring)LUT_9E8CB5FE_DString[61 .. 62];
            else if (input == 0x176)
                return cast(dstring)LUT_9E8CB5FE_DString[62 .. 63];
            else if (input >= 0x178 && input <= 0x179)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(58 + (input - 0x178))];
            else if (input == 0x17B)
                return cast(dstring)LUT_9E8CB5FE_DString[63 .. 64];
            else if (input == 0x17D)
                return cast(dstring)LUT_9E8CB5FE_DString[64 .. 65];
            else if (input == 0x17F)
                return cast(dstring)LUT_9E8CB5FE_DString[65 .. 66];
            else if (input >= 0x181 && input <= 0x182)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(60 + (input - 0x181))];
            else if (input == 0x184)
                return cast(dstring)LUT_9E8CB5FE_DString[66 .. 67];
            else if (input >= 0x186 && input <= 0x1A0)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(62 + (input - 0x186))];
            else if (input == 0x1A2)
                return cast(dstring)LUT_9E8CB5FE_DString[67 .. 68];
            else if (input == 0x1A4)
                return cast(dstring)LUT_9E8CB5FE_DString[68 .. 69];
            else if (input >= 0x1A6 && input <= 0x1A7)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(89 + (input - 0x1A6))];
            else if (input == 0x1A9)
                return cast(dstring)LUT_9E8CB5FE_DString[69 .. 70];
            else if (input == 0x1AC)
                return cast(dstring)LUT_9E8CB5FE_DString[70 .. 71];
            else if (input >= 0x1AE && input <= 0x1B3)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(91 + (input - 0x1AE))];
            else if (input == 0x1B5)
                return cast(dstring)LUT_9E8CB5FE_DString[71 .. 72];
            else if (input >= 0x1B7 && input <= 0x1B8)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(97 + (input - 0x1B7))];
            else if (input == 0x1BC)
                return cast(dstring)LUT_9E8CB5FE_DString[72 .. 73];
            else if (input >= 0x1C4 && input <= 0x1C5)
                return cast(dstring)LUT_9E8CB5FE_DString[73 .. 74];
            else if (input >= 0x1C7 && input <= 0x1C8)
                return cast(dstring)LUT_9E8CB5FE_DString[74 .. 75];
            else if (input >= 0x1CA && input <= 0x1CB)
                return cast(dstring)LUT_9E8CB5FE_DString[75 .. 76];
            else if (input == 0x1CD)
                return cast(dstring)LUT_9E8CB5FE_DString[76 .. 77];
            else if (input == 0x1CF)
                return cast(dstring)LUT_9E8CB5FE_DString[77 .. 78];
            else if (input == 0x1D1)
                return cast(dstring)LUT_9E8CB5FE_DString[78 .. 79];
            else if (input == 0x1D3)
                return cast(dstring)LUT_9E8CB5FE_DString[79 .. 80];
            else if (input == 0x1D5)
                return cast(dstring)LUT_9E8CB5FE_DString[80 .. 81];
            else if (input == 0x1D7)
                return cast(dstring)LUT_9E8CB5FE_DString[81 .. 82];
            else if (input == 0x1D9)
                return cast(dstring)LUT_9E8CB5FE_DString[82 .. 83];
            else if (input == 0x1DB)
                return cast(dstring)LUT_9E8CB5FE_DString[83 .. 84];
            else if (input == 0x1DE)
                return cast(dstring)LUT_9E8CB5FE_DString[84 .. 85];
            else if (input == 0x1E0)
                return cast(dstring)LUT_9E8CB5FE_DString[85 .. 86];
            else if (input == 0x1E2)
                return cast(dstring)LUT_9E8CB5FE_DString[86 .. 87];
            else if (input == 0x1E4)
                return cast(dstring)LUT_9E8CB5FE_DString[87 .. 88];
            else if (input == 0x1E6)
                return cast(dstring)LUT_9E8CB5FE_DString[88 .. 89];
            else if (input == 0x1E8)
                return cast(dstring)LUT_9E8CB5FE_DString[89 .. 90];
            else if (input == 0x1EA)
                return cast(dstring)LUT_9E8CB5FE_DString[90 .. 91];
            else if (input == 0x1EC)
                return cast(dstring)LUT_9E8CB5FE_DString[91 .. 92];
            else if (input == 0x1EE)
                return cast(dstring)LUT_9E8CB5FE_DString[92 .. 93];
            else if (input == 0x1F0)
                return cast(dstring)LUT_9E8CB5FE_DString[93 .. 95];
            else if (input >= 0x1F1 && input <= 0x1F2)
                return cast(dstring)LUT_9E8CB5FE_DString[95 .. 96];
            else if (input == 0x1F4)
                return cast(dstring)LUT_9E8CB5FE_DString[96 .. 97];
            else if (input >= 0x1F6 && input <= 0x1F8)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(99 + (input - 0x1F6))];
            else if (input == 0x1FA)
                return cast(dstring)LUT_9E8CB5FE_DString[97 .. 98];
            else if (input == 0x1FC)
                return cast(dstring)LUT_9E8CB5FE_DString[98 .. 99];
            else if (input == 0x1FE)
                return cast(dstring)LUT_9E8CB5FE_DString[99 .. 100];
            else if (input == 0x200)
                return cast(dstring)LUT_9E8CB5FE_DString[100 .. 101];
            else if (input == 0x202)
                return cast(dstring)LUT_9E8CB5FE_DString[101 .. 102];
            else if (input == 0x204)
                return cast(dstring)LUT_9E8CB5FE_DString[102 .. 103];
            else if (input == 0x206)
                return cast(dstring)LUT_9E8CB5FE_DString[103 .. 104];
            else if (input == 0x208)
                return cast(dstring)LUT_9E8CB5FE_DString[104 .. 105];
            else if (input == 0x20A)
                return cast(dstring)LUT_9E8CB5FE_DString[105 .. 106];
            else if (input == 0x20C)
                return cast(dstring)LUT_9E8CB5FE_DString[106 .. 107];
            else if (input == 0x20E)
                return cast(dstring)LUT_9E8CB5FE_DString[107 .. 108];
            else if (input == 0x210)
                return cast(dstring)LUT_9E8CB5FE_DString[108 .. 109];
            else if (input == 0x212)
                return cast(dstring)LUT_9E8CB5FE_DString[109 .. 110];
            else if (input == 0x214)
                return cast(dstring)LUT_9E8CB5FE_DString[110 .. 111];
            else if (input == 0x216)
                return cast(dstring)LUT_9E8CB5FE_DString[111 .. 112];
            else if (input == 0x218)
                return cast(dstring)LUT_9E8CB5FE_DString[112 .. 113];
            else if (input == 0x21A)
                return cast(dstring)LUT_9E8CB5FE_DString[113 .. 114];
            else if (input == 0x21C)
                return cast(dstring)LUT_9E8CB5FE_DString[114 .. 115];
            else if (input == 0x21E)
                return cast(dstring)LUT_9E8CB5FE_DString[115 .. 116];
            else if (input == 0x220)
                return cast(dstring)LUT_9E8CB5FE_DString[116 .. 117];
            else if (input == 0x222)
                return cast(dstring)LUT_9E8CB5FE_DString[117 .. 118];
            else if (input == 0x224)
                return cast(dstring)LUT_9E8CB5FE_DString[118 .. 119];
            else if (input == 0x226)
                return cast(dstring)LUT_9E8CB5FE_DString[119 .. 120];
            else if (input == 0x228)
                return cast(dstring)LUT_9E8CB5FE_DString[120 .. 121];
            else if (input == 0x22A)
                return cast(dstring)LUT_9E8CB5FE_DString[121 .. 122];
            else if (input == 0x22C)
                return cast(dstring)LUT_9E8CB5FE_DString[122 .. 123];
            else if (input == 0x22E)
                return cast(dstring)LUT_9E8CB5FE_DString[123 .. 124];
            else if (input == 0x230)
                return cast(dstring)LUT_9E8CB5FE_DString[124 .. 125];
            else if (input == 0x232)
                return cast(dstring)LUT_9E8CB5FE_DString[125 .. 126];
            else if (input >= 0x23A && input <= 0x23E)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(102 + (input - 0x23A))];
            else if (input == 0x241)
                return cast(dstring)LUT_9E8CB5FE_DString[126 .. 127];
            else if (input >= 0x243 && input <= 0x246)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(107 + (input - 0x243))];
            else if (input == 0x248)
                return cast(dstring)LUT_9E8CB5FE_DString[127 .. 128];
            else if (input == 0x24A)
                return cast(dstring)LUT_9E8CB5FE_DString[128 .. 129];
            else if (input == 0x24C)
                return cast(dstring)LUT_9E8CB5FE_DString[129 .. 130];
            else if (input == 0x24E)
                return cast(dstring)LUT_9E8CB5FE_DString[130 .. 131];
            else if (input == 0x345)
                return cast(dstring)LUT_9E8CB5FE_DString[131 .. 132];
            else if (input == 0x370)
                return cast(dstring)LUT_9E8CB5FE_DString[132 .. 133];
            else if (input == 0x372)
                return cast(dstring)LUT_9E8CB5FE_DString[133 .. 134];
            else if (input == 0x376)
                return cast(dstring)LUT_9E8CB5FE_DString[134 .. 135];
            else if (input == 0x37F)
                return cast(dstring)LUT_9E8CB5FE_DString[135 .. 136];
            else if (input == 0x386)
                return cast(dstring)LUT_9E8CB5FE_DString[136 .. 137];
            else if (input >= 0x388 && input <= 0x38A)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(111 + (input - 0x388))];
            else if (input == 0x38C)
                return cast(dstring)LUT_9E8CB5FE_DString[137 .. 138];
            else if (input >= 0x38E && input <= 0x3AB)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(114 + (input - 0x38E))];
            else if (input == 0x3B0)
                return cast(dstring)LUT_9E8CB5FE_DString[138 .. 141];
            else if (input == 0x3C2)
                return cast(dstring)LUT_9E8CB5FE_DString[141 .. 142];
            else if (input >= 0x3CF && input <= 0x3D6)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(144 + (input - 0x3CF))];
            else if (input == 0x3D8)
                return cast(dstring)LUT_9E8CB5FE_DString[142 .. 143];
            else if (input == 0x3DA)
                return cast(dstring)LUT_9E8CB5FE_DString[143 .. 144];
            else if (input == 0x3DC)
                return cast(dstring)LUT_9E8CB5FE_DString[144 .. 145];
            else if (input == 0x3DE)
                return cast(dstring)LUT_9E8CB5FE_DString[145 .. 146];
            else if (input == 0x3E0)
                return cast(dstring)LUT_9E8CB5FE_DString[146 .. 147];
            else if (input == 0x3E2)
                return cast(dstring)LUT_9E8CB5FE_DString[147 .. 148];
            else if (input == 0x3E4)
                return cast(dstring)LUT_9E8CB5FE_DString[148 .. 149];
            else if (input == 0x3E6)
                return cast(dstring)LUT_9E8CB5FE_DString[149 .. 150];
            else if (input == 0x3E8)
                return cast(dstring)LUT_9E8CB5FE_DString[150 .. 151];
            else if (input == 0x3EA)
                return cast(dstring)LUT_9E8CB5FE_DString[151 .. 152];
            else if (input == 0x3EC)
                return cast(dstring)LUT_9E8CB5FE_DString[152 .. 153];
            else if (input == 0x3EE)
                return cast(dstring)LUT_9E8CB5FE_DString[153 .. 154];
            else if (input >= 0x3F0 && input <= 0x3F5)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(152 + (input - 0x3F0))];
            else if (input == 0x3F7)
                return cast(dstring)LUT_9E8CB5FE_DString[154 .. 155];
            else if (input >= 0x3F9 && input <= 0x42F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(158 + (input - 0x3F9))];
            else if (input == 0x460)
                return cast(dstring)LUT_9E8CB5FE_DString[155 .. 156];
            else if (input == 0x462)
                return cast(dstring)LUT_9E8CB5FE_DString[156 .. 157];
            else if (input == 0x464)
                return cast(dstring)LUT_9E8CB5FE_DString[157 .. 158];
            else if (input == 0x466)
                return cast(dstring)LUT_9E8CB5FE_DString[158 .. 159];
            else if (input == 0x468)
                return cast(dstring)LUT_9E8CB5FE_DString[159 .. 160];
            else if (input == 0x46A)
                return cast(dstring)LUT_9E8CB5FE_DString[160 .. 161];
            else if (input == 0x46C)
                return cast(dstring)LUT_9E8CB5FE_DString[161 .. 162];
            else if (input == 0x46E)
                return cast(dstring)LUT_9E8CB5FE_DString[162 .. 163];
            else if (input == 0x470)
                return cast(dstring)LUT_9E8CB5FE_DString[163 .. 164];
            else if (input == 0x472)
                return cast(dstring)LUT_9E8CB5FE_DString[164 .. 165];
            else if (input == 0x474)
                return cast(dstring)LUT_9E8CB5FE_DString[165 .. 166];
            else if (input == 0x476)
                return cast(dstring)LUT_9E8CB5FE_DString[166 .. 167];
            else if (input == 0x478)
                return cast(dstring)LUT_9E8CB5FE_DString[167 .. 168];
            else if (input == 0x47A)
                return cast(dstring)LUT_9E8CB5FE_DString[168 .. 169];
            else if (input == 0x47C)
                return cast(dstring)LUT_9E8CB5FE_DString[169 .. 170];
            else if (input == 0x47E)
                return cast(dstring)LUT_9E8CB5FE_DString[170 .. 171];
            else if (input == 0x480)
                return cast(dstring)LUT_9E8CB5FE_DString[171 .. 172];
            else if (input == 0x48A)
                return cast(dstring)LUT_9E8CB5FE_DString[172 .. 173];
            else if (input == 0x48C)
                return cast(dstring)LUT_9E8CB5FE_DString[173 .. 174];
            else if (input == 0x48E)
                return cast(dstring)LUT_9E8CB5FE_DString[174 .. 175];
            else if (input == 0x490)
                return cast(dstring)LUT_9E8CB5FE_DString[175 .. 176];
            else if (input == 0x492)
                return cast(dstring)LUT_9E8CB5FE_DString[176 .. 177];
            else if (input == 0x494)
                return cast(dstring)LUT_9E8CB5FE_DString[177 .. 178];
            else if (input == 0x496)
                return cast(dstring)LUT_9E8CB5FE_DString[178 .. 179];
            else if (input == 0x498)
                return cast(dstring)LUT_9E8CB5FE_DString[179 .. 180];
            else if (input == 0x49A)
                return cast(dstring)LUT_9E8CB5FE_DString[180 .. 181];
            else if (input == 0x49C)
                return cast(dstring)LUT_9E8CB5FE_DString[181 .. 182];
            else if (input == 0x49E)
                return cast(dstring)LUT_9E8CB5FE_DString[182 .. 183];
            else if (input == 0x4A0)
                return cast(dstring)LUT_9E8CB5FE_DString[183 .. 184];
            else if (input == 0x4A2)
                return cast(dstring)LUT_9E8CB5FE_DString[184 .. 185];
            else if (input == 0x4A4)
                return cast(dstring)LUT_9E8CB5FE_DString[185 .. 186];
            else if (input == 0x4A6)
                return cast(dstring)LUT_9E8CB5FE_DString[186 .. 187];
            else if (input == 0x4A8)
                return cast(dstring)LUT_9E8CB5FE_DString[187 .. 188];
            else if (input == 0x4AA)
                return cast(dstring)LUT_9E8CB5FE_DString[188 .. 189];
            else if (input == 0x4AC)
                return cast(dstring)LUT_9E8CB5FE_DString[189 .. 190];
            else if (input == 0x4AE)
                return cast(dstring)LUT_9E8CB5FE_DString[190 .. 191];
            else if (input == 0x4B0)
                return cast(dstring)LUT_9E8CB5FE_DString[191 .. 192];
            else if (input == 0x4B2)
                return cast(dstring)LUT_9E8CB5FE_DString[192 .. 193];
            else if (input == 0x4B4)
                return cast(dstring)LUT_9E8CB5FE_DString[193 .. 194];
            else if (input == 0x4B6)
                return cast(dstring)LUT_9E8CB5FE_DString[194 .. 195];
            else if (input == 0x4B8)
                return cast(dstring)LUT_9E8CB5FE_DString[195 .. 196];
            else if (input == 0x4BA)
                return cast(dstring)LUT_9E8CB5FE_DString[196 .. 197];
            else if (input == 0x4BC)
                return cast(dstring)LUT_9E8CB5FE_DString[197 .. 198];
            else if (input == 0x4BE)
                return cast(dstring)LUT_9E8CB5FE_DString[198 .. 199];
            else if (input >= 0x4C0 && input <= 0x4C1)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(213 + (input - 0x4C0))];
            else if (input == 0x4C3)
                return cast(dstring)LUT_9E8CB5FE_DString[199 .. 200];
            else if (input == 0x4C5)
                return cast(dstring)LUT_9E8CB5FE_DString[200 .. 201];
            else if (input == 0x4C7)
                return cast(dstring)LUT_9E8CB5FE_DString[201 .. 202];
            else if (input == 0x4C9)
                return cast(dstring)LUT_9E8CB5FE_DString[202 .. 203];
            else if (input == 0x4CB)
                return cast(dstring)LUT_9E8CB5FE_DString[203 .. 204];
            else if (input == 0x4CD)
                return cast(dstring)LUT_9E8CB5FE_DString[204 .. 205];
            else if (input == 0x4D0)
                return cast(dstring)LUT_9E8CB5FE_DString[205 .. 206];
            else if (input == 0x4D2)
                return cast(dstring)LUT_9E8CB5FE_DString[206 .. 207];
            else if (input == 0x4D4)
                return cast(dstring)LUT_9E8CB5FE_DString[207 .. 208];
            else if (input == 0x4D6)
                return cast(dstring)LUT_9E8CB5FE_DString[208 .. 209];
            else if (input == 0x4D8)
                return cast(dstring)LUT_9E8CB5FE_DString[209 .. 210];
            else if (input == 0x4DA)
                return cast(dstring)LUT_9E8CB5FE_DString[210 .. 211];
            else if (input == 0x4DC)
                return cast(dstring)LUT_9E8CB5FE_DString[211 .. 212];
            else if (input == 0x4DE)
                return cast(dstring)LUT_9E8CB5FE_DString[212 .. 213];
            else if (input == 0x4E0)
                return cast(dstring)LUT_9E8CB5FE_DString[213 .. 214];
            else if (input == 0x4E2)
                return cast(dstring)LUT_9E8CB5FE_DString[214 .. 215];
            else if (input == 0x4E4)
                return cast(dstring)LUT_9E8CB5FE_DString[215 .. 216];
            else if (input == 0x4E6)
                return cast(dstring)LUT_9E8CB5FE_DString[216 .. 217];
            else if (input == 0x4E8)
                return cast(dstring)LUT_9E8CB5FE_DString[217 .. 218];
            else if (input == 0x4EA)
                return cast(dstring)LUT_9E8CB5FE_DString[218 .. 219];
            else if (input == 0x4EC)
                return cast(dstring)LUT_9E8CB5FE_DString[219 .. 220];
            else if (input == 0x4EE)
                return cast(dstring)LUT_9E8CB5FE_DString[220 .. 221];
            else if (input == 0x4F0)
                return cast(dstring)LUT_9E8CB5FE_DString[221 .. 222];
            else if (input == 0x4F2)
                return cast(dstring)LUT_9E8CB5FE_DString[222 .. 223];
            else if (input == 0x4F4)
                return cast(dstring)LUT_9E8CB5FE_DString[223 .. 224];
            else if (input == 0x4F6)
                return cast(dstring)LUT_9E8CB5FE_DString[224 .. 225];
            else if (input == 0x4F8)
                return cast(dstring)LUT_9E8CB5FE_DString[225 .. 226];
            else if (input == 0x4FA)
                return cast(dstring)LUT_9E8CB5FE_DString[226 .. 227];
            else if (input == 0x4FC)
                return cast(dstring)LUT_9E8CB5FE_DString[227 .. 228];
            else if (input == 0x4FE)
                return cast(dstring)LUT_9E8CB5FE_DString[228 .. 229];
            else if (input == 0x500)
                return cast(dstring)LUT_9E8CB5FE_DString[229 .. 230];
            else if (input == 0x502)
                return cast(dstring)LUT_9E8CB5FE_DString[230 .. 231];
            else if (input == 0x504)
                return cast(dstring)LUT_9E8CB5FE_DString[231 .. 232];
            else if (input == 0x506)
                return cast(dstring)LUT_9E8CB5FE_DString[232 .. 233];
            else if (input == 0x508)
                return cast(dstring)LUT_9E8CB5FE_DString[233 .. 234];
            else if (input == 0x50A)
                return cast(dstring)LUT_9E8CB5FE_DString[234 .. 235];
            else if (input == 0x50C)
                return cast(dstring)LUT_9E8CB5FE_DString[235 .. 236];
            else if (input == 0x50E)
                return cast(dstring)LUT_9E8CB5FE_DString[236 .. 237];
            else if (input == 0x510)
                return cast(dstring)LUT_9E8CB5FE_DString[237 .. 238];
            else if (input == 0x512)
                return cast(dstring)LUT_9E8CB5FE_DString[238 .. 239];
            else if (input == 0x514)
                return cast(dstring)LUT_9E8CB5FE_DString[239 .. 240];
            else if (input == 0x516)
                return cast(dstring)LUT_9E8CB5FE_DString[240 .. 241];
            else if (input == 0x518)
                return cast(dstring)LUT_9E8CB5FE_DString[241 .. 242];
            else if (input == 0x51A)
                return cast(dstring)LUT_9E8CB5FE_DString[242 .. 243];
            else if (input == 0x51C)
                return cast(dstring)LUT_9E8CB5FE_DString[243 .. 244];
            else if (input == 0x51E)
                return cast(dstring)LUT_9E8CB5FE_DString[244 .. 245];
            else if (input == 0x520)
                return cast(dstring)LUT_9E8CB5FE_DString[245 .. 246];
            else if (input == 0x522)
                return cast(dstring)LUT_9E8CB5FE_DString[246 .. 247];
            else if (input == 0x524)
                return cast(dstring)LUT_9E8CB5FE_DString[247 .. 248];
            else if (input == 0x526)
                return cast(dstring)LUT_9E8CB5FE_DString[248 .. 249];
            else if (input == 0x528)
                return cast(dstring)LUT_9E8CB5FE_DString[249 .. 250];
            else if (input == 0x52A)
                return cast(dstring)LUT_9E8CB5FE_DString[250 .. 251];
            else if (input == 0x52C)
                return cast(dstring)LUT_9E8CB5FE_DString[251 .. 252];
            else if (input == 0x52E)
                return cast(dstring)LUT_9E8CB5FE_DString[252 .. 253];
            else if (input >= 0x531 && input <= 0x556)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(215 + (input - 0x531))];
            else if (input == 0x587)
                return cast(dstring)LUT_9E8CB5FE_DString[253 .. 255];
            else if (input >= 0x10A0 && input <= 0x10C5)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(253 + (input - 0x10A0))];
            else if (input == 0x10C7)
                return cast(dstring)LUT_9E8CB5FE_DString[255 .. 256];
            else if (input == 0x10CD)
                return cast(dstring)LUT_9E8CB5FE_DString[256 .. 257];
            else if (input >= 0x13F8 && input <= 0x13FD)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(291 + (input - 0x13F8))];
            else if (input >= 0x1C80 && input <= 0x1C88)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(297 + (input - 0x1C80))];
            else if (input >= 0x1C90 && input <= 0x1CBF)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(306 + (input - 0x1C90))];
            else if (input == 0x1E00)
                return cast(dstring)LUT_9E8CB5FE_DString[257 .. 258];
            else if (input == 0x1E02)
                return cast(dstring)LUT_9E8CB5FE_DString[258 .. 259];
            else if (input == 0x1E04)
                return cast(dstring)LUT_9E8CB5FE_DString[259 .. 260];
            else if (input == 0x1E06)
                return cast(dstring)LUT_9E8CB5FE_DString[260 .. 261];
            else if (input == 0x1E08)
                return cast(dstring)LUT_9E8CB5FE_DString[261 .. 262];
            else if (input == 0x1E0A)
                return cast(dstring)LUT_9E8CB5FE_DString[262 .. 263];
            else if (input == 0x1E0C)
                return cast(dstring)LUT_9E8CB5FE_DString[263 .. 264];
            else if (input == 0x1E0E)
                return cast(dstring)LUT_9E8CB5FE_DString[264 .. 265];
            else if (input == 0x1E10)
                return cast(dstring)LUT_9E8CB5FE_DString[265 .. 266];
            else if (input == 0x1E12)
                return cast(dstring)LUT_9E8CB5FE_DString[266 .. 267];
            else if (input == 0x1E14)
                return cast(dstring)LUT_9E8CB5FE_DString[267 .. 268];
            else if (input == 0x1E16)
                return cast(dstring)LUT_9E8CB5FE_DString[268 .. 269];
            else if (input == 0x1E18)
                return cast(dstring)LUT_9E8CB5FE_DString[269 .. 270];
            else if (input == 0x1E1A)
                return cast(dstring)LUT_9E8CB5FE_DString[270 .. 271];
            else if (input == 0x1E1C)
                return cast(dstring)LUT_9E8CB5FE_DString[271 .. 272];
            else if (input == 0x1E1E)
                return cast(dstring)LUT_9E8CB5FE_DString[272 .. 273];
            else if (input == 0x1E20)
                return cast(dstring)LUT_9E8CB5FE_DString[273 .. 274];
            else if (input == 0x1E22)
                return cast(dstring)LUT_9E8CB5FE_DString[274 .. 275];
            else if (input == 0x1E24)
                return cast(dstring)LUT_9E8CB5FE_DString[275 .. 276];
            else if (input == 0x1E26)
                return cast(dstring)LUT_9E8CB5FE_DString[276 .. 277];
            else if (input == 0x1E28)
                return cast(dstring)LUT_9E8CB5FE_DString[277 .. 278];
            else if (input == 0x1E2A)
                return cast(dstring)LUT_9E8CB5FE_DString[278 .. 279];
            else if (input == 0x1E2C)
                return cast(dstring)LUT_9E8CB5FE_DString[279 .. 280];
            else if (input == 0x1E2E)
                return cast(dstring)LUT_9E8CB5FE_DString[280 .. 281];
            else if (input == 0x1E30)
                return cast(dstring)LUT_9E8CB5FE_DString[281 .. 282];
            else if (input == 0x1E32)
                return cast(dstring)LUT_9E8CB5FE_DString[282 .. 283];
            else if (input == 0x1E34)
                return cast(dstring)LUT_9E8CB5FE_DString[283 .. 284];
            else if (input == 0x1E36)
                return cast(dstring)LUT_9E8CB5FE_DString[284 .. 285];
            else if (input == 0x1E38)
                return cast(dstring)LUT_9E8CB5FE_DString[285 .. 286];
            else if (input == 0x1E3A)
                return cast(dstring)LUT_9E8CB5FE_DString[286 .. 287];
            else if (input == 0x1E3C)
                return cast(dstring)LUT_9E8CB5FE_DString[287 .. 288];
            else if (input == 0x1E3E)
                return cast(dstring)LUT_9E8CB5FE_DString[288 .. 289];
            else if (input == 0x1E40)
                return cast(dstring)LUT_9E8CB5FE_DString[289 .. 290];
            else if (input == 0x1E42)
                return cast(dstring)LUT_9E8CB5FE_DString[290 .. 291];
            else if (input == 0x1E44)
                return cast(dstring)LUT_9E8CB5FE_DString[291 .. 292];
            else if (input == 0x1E46)
                return cast(dstring)LUT_9E8CB5FE_DString[292 .. 293];
            else if (input == 0x1E48)
                return cast(dstring)LUT_9E8CB5FE_DString[293 .. 294];
            else if (input == 0x1E4A)
                return cast(dstring)LUT_9E8CB5FE_DString[294 .. 295];
            else if (input == 0x1E4C)
                return cast(dstring)LUT_9E8CB5FE_DString[295 .. 296];
            else if (input == 0x1E4E)
                return cast(dstring)LUT_9E8CB5FE_DString[296 .. 297];
            else if (input == 0x1E50)
                return cast(dstring)LUT_9E8CB5FE_DString[297 .. 298];
            else if (input == 0x1E52)
                return cast(dstring)LUT_9E8CB5FE_DString[298 .. 299];
            else if (input == 0x1E54)
                return cast(dstring)LUT_9E8CB5FE_DString[299 .. 300];
            else if (input == 0x1E56)
                return cast(dstring)LUT_9E8CB5FE_DString[300 .. 301];
            else if (input == 0x1E58)
                return cast(dstring)LUT_9E8CB5FE_DString[301 .. 302];
            else if (input == 0x1E5A)
                return cast(dstring)LUT_9E8CB5FE_DString[302 .. 303];
            else if (input == 0x1E5C)
                return cast(dstring)LUT_9E8CB5FE_DString[303 .. 304];
            else if (input == 0x1E5E)
                return cast(dstring)LUT_9E8CB5FE_DString[304 .. 305];
            else if (input == 0x1E60)
                return cast(dstring)LUT_9E8CB5FE_DString[305 .. 306];
            else if (input == 0x1E62)
                return cast(dstring)LUT_9E8CB5FE_DString[306 .. 307];
            else if (input == 0x1E64)
                return cast(dstring)LUT_9E8CB5FE_DString[307 .. 308];
            else if (input == 0x1E66)
                return cast(dstring)LUT_9E8CB5FE_DString[308 .. 309];
            else if (input == 0x1E68)
                return cast(dstring)LUT_9E8CB5FE_DString[309 .. 310];
            else if (input == 0x1E6A)
                return cast(dstring)LUT_9E8CB5FE_DString[310 .. 311];
            else if (input == 0x1E6C)
                return cast(dstring)LUT_9E8CB5FE_DString[311 .. 312];
            else if (input == 0x1E6E)
                return cast(dstring)LUT_9E8CB5FE_DString[312 .. 313];
            else if (input == 0x1E70)
                return cast(dstring)LUT_9E8CB5FE_DString[313 .. 314];
            else if (input == 0x1E72)
                return cast(dstring)LUT_9E8CB5FE_DString[314 .. 315];
            else if (input == 0x1E74)
                return cast(dstring)LUT_9E8CB5FE_DString[315 .. 316];
            else if (input == 0x1E76)
                return cast(dstring)LUT_9E8CB5FE_DString[316 .. 317];
            else if (input == 0x1E78)
                return cast(dstring)LUT_9E8CB5FE_DString[317 .. 318];
            else if (input == 0x1E7A)
                return cast(dstring)LUT_9E8CB5FE_DString[318 .. 319];
            else if (input == 0x1E7C)
                return cast(dstring)LUT_9E8CB5FE_DString[319 .. 320];
            else if (input == 0x1E7E)
                return cast(dstring)LUT_9E8CB5FE_DString[320 .. 321];
            else if (input == 0x1E80)
                return cast(dstring)LUT_9E8CB5FE_DString[321 .. 322];
            else if (input == 0x1E82)
                return cast(dstring)LUT_9E8CB5FE_DString[322 .. 323];
            else if (input == 0x1E84)
                return cast(dstring)LUT_9E8CB5FE_DString[323 .. 324];
            else if (input == 0x1E86)
                return cast(dstring)LUT_9E8CB5FE_DString[324 .. 325];
            else if (input == 0x1E88)
                return cast(dstring)LUT_9E8CB5FE_DString[325 .. 326];
            else if (input == 0x1E8A)
                return cast(dstring)LUT_9E8CB5FE_DString[326 .. 327];
            else if (input == 0x1E8C)
                return cast(dstring)LUT_9E8CB5FE_DString[327 .. 328];
            else if (input == 0x1E8E)
                return cast(dstring)LUT_9E8CB5FE_DString[328 .. 329];
            else if (input == 0x1E90)
                return cast(dstring)LUT_9E8CB5FE_DString[329 .. 330];
            else if (input == 0x1E92)
                return cast(dstring)LUT_9E8CB5FE_DString[330 .. 331];
            else if (input == 0x1E94)
                return cast(dstring)LUT_9E8CB5FE_DString[331 .. 332];
            else if (input >= 0x1E96 && input <= 0x1E9A)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(354 + (input - 0x1E96))];
            else if (input == 0x1E9B)
                return cast(dstring)LUT_9E8CB5FE_DString[305 .. 306];
            else if (input == 0x1E9E)
                return cast(dstring)LUT_9E8CB5FE_DString[332 .. 334];
            else if (input == 0x1EA0)
                return cast(dstring)LUT_9E8CB5FE_DString[334 .. 335];
            else if (input == 0x1EA2)
                return cast(dstring)LUT_9E8CB5FE_DString[335 .. 336];
            else if (input == 0x1EA4)
                return cast(dstring)LUT_9E8CB5FE_DString[336 .. 337];
            else if (input == 0x1EA6)
                return cast(dstring)LUT_9E8CB5FE_DString[337 .. 338];
            else if (input == 0x1EA8)
                return cast(dstring)LUT_9E8CB5FE_DString[338 .. 339];
            else if (input == 0x1EAA)
                return cast(dstring)LUT_9E8CB5FE_DString[339 .. 340];
            else if (input == 0x1EAC)
                return cast(dstring)LUT_9E8CB5FE_DString[340 .. 341];
            else if (input == 0x1EAE)
                return cast(dstring)LUT_9E8CB5FE_DString[341 .. 342];
            else if (input == 0x1EB0)
                return cast(dstring)LUT_9E8CB5FE_DString[342 .. 343];
            else if (input == 0x1EB2)
                return cast(dstring)LUT_9E8CB5FE_DString[343 .. 344];
            else if (input == 0x1EB4)
                return cast(dstring)LUT_9E8CB5FE_DString[344 .. 345];
            else if (input == 0x1EB6)
                return cast(dstring)LUT_9E8CB5FE_DString[345 .. 346];
            else if (input == 0x1EB8)
                return cast(dstring)LUT_9E8CB5FE_DString[346 .. 347];
            else if (input == 0x1EBA)
                return cast(dstring)LUT_9E8CB5FE_DString[347 .. 348];
            else if (input == 0x1EBC)
                return cast(dstring)LUT_9E8CB5FE_DString[348 .. 349];
            else if (input == 0x1EBE)
                return cast(dstring)LUT_9E8CB5FE_DString[349 .. 350];
            else if (input == 0x1EC0)
                return cast(dstring)LUT_9E8CB5FE_DString[350 .. 351];
            else if (input == 0x1EC2)
                return cast(dstring)LUT_9E8CB5FE_DString[351 .. 352];
            else if (input == 0x1EC4)
                return cast(dstring)LUT_9E8CB5FE_DString[352 .. 353];
            else if (input == 0x1EC6)
                return cast(dstring)LUT_9E8CB5FE_DString[353 .. 354];
            else if (input == 0x1EC8)
                return cast(dstring)LUT_9E8CB5FE_DString[354 .. 355];
            else if (input == 0x1ECA)
                return cast(dstring)LUT_9E8CB5FE_DString[355 .. 356];
            else if (input == 0x1ECC)
                return cast(dstring)LUT_9E8CB5FE_DString[356 .. 357];
            else if (input == 0x1ECE)
                return cast(dstring)LUT_9E8CB5FE_DString[357 .. 358];
            else if (input == 0x1ED0)
                return cast(dstring)LUT_9E8CB5FE_DString[358 .. 359];
            else if (input == 0x1ED2)
                return cast(dstring)LUT_9E8CB5FE_DString[359 .. 360];
            else if (input == 0x1ED4)
                return cast(dstring)LUT_9E8CB5FE_DString[360 .. 361];
            else if (input == 0x1ED6)
                return cast(dstring)LUT_9E8CB5FE_DString[361 .. 362];
            else if (input == 0x1ED8)
                return cast(dstring)LUT_9E8CB5FE_DString[362 .. 363];
            else if (input == 0x1EDA)
                return cast(dstring)LUT_9E8CB5FE_DString[363 .. 364];
            else if (input == 0x1EDC)
                return cast(dstring)LUT_9E8CB5FE_DString[364 .. 365];
            else if (input == 0x1EDE)
                return cast(dstring)LUT_9E8CB5FE_DString[365 .. 366];
            else if (input == 0x1EE0)
                return cast(dstring)LUT_9E8CB5FE_DString[366 .. 367];
            else if (input == 0x1EE2)
                return cast(dstring)LUT_9E8CB5FE_DString[367 .. 368];
            else if (input == 0x1EE4)
                return cast(dstring)LUT_9E8CB5FE_DString[368 .. 369];
            else if (input == 0x1EE6)
                return cast(dstring)LUT_9E8CB5FE_DString[369 .. 370];
            else if (input == 0x1EE8)
                return cast(dstring)LUT_9E8CB5FE_DString[370 .. 371];
            else if (input == 0x1EEA)
                return cast(dstring)LUT_9E8CB5FE_DString[371 .. 372];
            else if (input == 0x1EEC)
                return cast(dstring)LUT_9E8CB5FE_DString[372 .. 373];
            else if (input == 0x1EEE)
                return cast(dstring)LUT_9E8CB5FE_DString[373 .. 374];
            else if (input == 0x1EF0)
                return cast(dstring)LUT_9E8CB5FE_DString[374 .. 375];
            else if (input == 0x1EF2)
                return cast(dstring)LUT_9E8CB5FE_DString[375 .. 376];
            else if (input == 0x1EF4)
                return cast(dstring)LUT_9E8CB5FE_DString[376 .. 377];
            else if (input == 0x1EF6)
                return cast(dstring)LUT_9E8CB5FE_DString[377 .. 378];
            else if (input == 0x1EF8)
                return cast(dstring)LUT_9E8CB5FE_DString[378 .. 379];
            else if (input == 0x1EFA)
                return cast(dstring)LUT_9E8CB5FE_DString[379 .. 380];
            else if (input == 0x1EFC)
                return cast(dstring)LUT_9E8CB5FE_DString[380 .. 381];
            else if (input == 0x1EFE)
                return cast(dstring)LUT_9E8CB5FE_DString[381 .. 382];
            else if (input >= 0x1F08 && input <= 0x1F0F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(359 + (input - 0x1F08))];
            else if (input >= 0x1F18 && input <= 0x1F1D)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(367 + (input - 0x1F18))];
            else if (input >= 0x1F28 && input <= 0x1F2F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(373 + (input - 0x1F28))];
            else if (input >= 0x1F38 && input <= 0x1F3F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(381 + (input - 0x1F38))];
            else if (input >= 0x1F48 && input <= 0x1F4D)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(389 + (input - 0x1F48))];
            else if (input == 0x1F50)
                return cast(dstring)LUT_9E8CB5FE_DString[382 .. 384];
            else if (input == 0x1F52)
                return cast(dstring)LUT_9E8CB5FE_DString[384 .. 387];
            else if (input == 0x1F54)
                return cast(dstring)LUT_9E8CB5FE_DString[387 .. 390];
            else if (input == 0x1F56)
                return cast(dstring)LUT_9E8CB5FE_DString[390 .. 393];
            else if (input == 0x1F59)
                return cast(dstring)LUT_9E8CB5FE_DString[393 .. 394];
            else if (input == 0x1F5B)
                return cast(dstring)LUT_9E8CB5FE_DString[394 .. 395];
            else if (input == 0x1F5D)
                return cast(dstring)LUT_9E8CB5FE_DString[395 .. 396];
            else if (input == 0x1F5F)
                return cast(dstring)LUT_9E8CB5FE_DString[396 .. 397];
            else if (input >= 0x1F68 && input <= 0x1F6F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(395 + (input - 0x1F68))];
            else if (input >= 0x1F80 && input <= 0x1FBC)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(403 + (input - 0x1F80))];
            else if (input == 0x1FBE)
                return cast(dstring)LUT_9E8CB5FE_DString[131 .. 132];
            else if (input >= 0x1FC2 && input <= 0x1FCC)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(464 + (input - 0x1FC2))];
            else if (input >= 0x1FD2 && input <= 0x1FDB)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(475 + (input - 0x1FD2))];
            else if (input >= 0x1FE2 && input <= 0x1FEC)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(485 + (input - 0x1FE2))];
            else if (input >= 0x1FF2 && input <= 0x1FFC)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(496 + (input - 0x1FF2))];
            else if (input == 0x2126)
                return cast(dstring)LUT_9E8CB5FE_DString[397 .. 398];
            else if (input >= 0x212A && input <= 0x212B)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(507 + (input - 0x212A))];
            else if (input == 0x2132)
                return cast(dstring)LUT_9E8CB5FE_DString[398 .. 399];
            else if (input >= 0x2160 && input <= 0x216F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(509 + (input - 0x2160))];
            else if (input == 0x2183)
                return cast(dstring)LUT_9E8CB5FE_DString[399 .. 400];
            else if (input >= 0x24B6 && input <= 0x24CF)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(525 + (input - 0x24B6))];
            else if (input >= 0x2C00 && input <= 0x2C2F)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(551 + (input - 0x2C00))];
            else if (input == 0x2C60)
                return cast(dstring)LUT_9E8CB5FE_DString[400 .. 401];
            else if (input >= 0x2C62 && input <= 0x2C64)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(599 + (input - 0x2C62))];
            else if (input == 0x2C67)
                return cast(dstring)LUT_9E8CB5FE_DString[401 .. 402];
            else if (input == 0x2C69)
                return cast(dstring)LUT_9E8CB5FE_DString[402 .. 403];
            else if (input == 0x2C6B)
                return cast(dstring)LUT_9E8CB5FE_DString[403 .. 404];
            else if (input >= 0x2C6D && input <= 0x2C70)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(602 + (input - 0x2C6D))];
            else if (input == 0x2C72)
                return cast(dstring)LUT_9E8CB5FE_DString[404 .. 405];
            else if (input == 0x2C75)
                return cast(dstring)LUT_9E8CB5FE_DString[405 .. 406];
            else if (input >= 0x2C7E && input <= 0x2C80)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(606 + (input - 0x2C7E))];
            else if (input == 0x2C82)
                return cast(dstring)LUT_9E8CB5FE_DString[406 .. 407];
            else if (input == 0x2C84)
                return cast(dstring)LUT_9E8CB5FE_DString[407 .. 408];
            else if (input == 0x2C86)
                return cast(dstring)LUT_9E8CB5FE_DString[408 .. 409];
            else if (input == 0x2C88)
                return cast(dstring)LUT_9E8CB5FE_DString[409 .. 410];
            else if (input == 0x2C8A)
                return cast(dstring)LUT_9E8CB5FE_DString[410 .. 411];
            else if (input == 0x2C8C)
                return cast(dstring)LUT_9E8CB5FE_DString[411 .. 412];
            else if (input == 0x2C8E)
                return cast(dstring)LUT_9E8CB5FE_DString[412 .. 413];
            else if (input == 0x2C90)
                return cast(dstring)LUT_9E8CB5FE_DString[413 .. 414];
            else if (input == 0x2C92)
                return cast(dstring)LUT_9E8CB5FE_DString[414 .. 415];
            else if (input == 0x2C94)
                return cast(dstring)LUT_9E8CB5FE_DString[415 .. 416];
            else if (input == 0x2C96)
                return cast(dstring)LUT_9E8CB5FE_DString[416 .. 417];
            else if (input == 0x2C98)
                return cast(dstring)LUT_9E8CB5FE_DString[417 .. 418];
            else if (input == 0x2C9A)
                return cast(dstring)LUT_9E8CB5FE_DString[418 .. 419];
            else if (input == 0x2C9C)
                return cast(dstring)LUT_9E8CB5FE_DString[419 .. 420];
            else if (input == 0x2C9E)
                return cast(dstring)LUT_9E8CB5FE_DString[420 .. 421];
            else if (input == 0x2CA0)
                return cast(dstring)LUT_9E8CB5FE_DString[421 .. 422];
            else if (input == 0x2CA2)
                return cast(dstring)LUT_9E8CB5FE_DString[422 .. 423];
            else if (input == 0x2CA4)
                return cast(dstring)LUT_9E8CB5FE_DString[423 .. 424];
            else if (input == 0x2CA6)
                return cast(dstring)LUT_9E8CB5FE_DString[424 .. 425];
            else if (input == 0x2CA8)
                return cast(dstring)LUT_9E8CB5FE_DString[425 .. 426];
            else if (input == 0x2CAA)
                return cast(dstring)LUT_9E8CB5FE_DString[426 .. 427];
            else if (input == 0x2CAC)
                return cast(dstring)LUT_9E8CB5FE_DString[427 .. 428];
            else if (input == 0x2CAE)
                return cast(dstring)LUT_9E8CB5FE_DString[428 .. 429];
            else if (input == 0x2CB0)
                return cast(dstring)LUT_9E8CB5FE_DString[429 .. 430];
            else if (input == 0x2CB2)
                return cast(dstring)LUT_9E8CB5FE_DString[430 .. 431];
            else if (input == 0x2CB4)
                return cast(dstring)LUT_9E8CB5FE_DString[431 .. 432];
            else if (input == 0x2CB6)
                return cast(dstring)LUT_9E8CB5FE_DString[432 .. 433];
            else if (input == 0x2CB8)
                return cast(dstring)LUT_9E8CB5FE_DString[433 .. 434];
            else if (input == 0x2CBA)
                return cast(dstring)LUT_9E8CB5FE_DString[434 .. 435];
            else if (input == 0x2CBC)
                return cast(dstring)LUT_9E8CB5FE_DString[435 .. 436];
            else if (input == 0x2CBE)
                return cast(dstring)LUT_9E8CB5FE_DString[436 .. 437];
            else if (input == 0x2CC0)
                return cast(dstring)LUT_9E8CB5FE_DString[437 .. 438];
            else if (input == 0x2CC2)
                return cast(dstring)LUT_9E8CB5FE_DString[438 .. 439];
            else if (input == 0x2CC4)
                return cast(dstring)LUT_9E8CB5FE_DString[439 .. 440];
            else if (input == 0x2CC6)
                return cast(dstring)LUT_9E8CB5FE_DString[440 .. 441];
            else if (input == 0x2CC8)
                return cast(dstring)LUT_9E8CB5FE_DString[441 .. 442];
            else if (input == 0x2CCA)
                return cast(dstring)LUT_9E8CB5FE_DString[442 .. 443];
            else if (input == 0x2CCC)
                return cast(dstring)LUT_9E8CB5FE_DString[443 .. 444];
            else if (input == 0x2CCE)
                return cast(dstring)LUT_9E8CB5FE_DString[444 .. 445];
            else if (input == 0x2CD0)
                return cast(dstring)LUT_9E8CB5FE_DString[445 .. 446];
            else if (input == 0x2CD2)
                return cast(dstring)LUT_9E8CB5FE_DString[446 .. 447];
            else if (input == 0x2CD4)
                return cast(dstring)LUT_9E8CB5FE_DString[447 .. 448];
            else if (input == 0x2CD6)
                return cast(dstring)LUT_9E8CB5FE_DString[448 .. 449];
            else if (input == 0x2CD8)
                return cast(dstring)LUT_9E8CB5FE_DString[449 .. 450];
            else if (input == 0x2CDA)
                return cast(dstring)LUT_9E8CB5FE_DString[450 .. 451];
            else if (input == 0x2CDC)
                return cast(dstring)LUT_9E8CB5FE_DString[451 .. 452];
            else if (input == 0x2CDE)
                return cast(dstring)LUT_9E8CB5FE_DString[452 .. 453];
            else if (input == 0x2CE0)
                return cast(dstring)LUT_9E8CB5FE_DString[453 .. 454];
            else if (input == 0x2CE2)
                return cast(dstring)LUT_9E8CB5FE_DString[454 .. 455];
            else if (input == 0x2CEB)
                return cast(dstring)LUT_9E8CB5FE_DString[455 .. 456];
            else if (input == 0x2CED)
                return cast(dstring)LUT_9E8CB5FE_DString[456 .. 457];
            else if (input == 0x2CF2)
                return cast(dstring)LUT_9E8CB5FE_DString[457 .. 458];
        } else if (input >= 0xA640) {
            if (input == 0xA640)
                return cast(dstring)LUT_9E8CB5FE_DString[458 .. 459];
            else if (input == 0xA642)
                return cast(dstring)LUT_9E8CB5FE_DString[459 .. 460];
            else if (input == 0xA644)
                return cast(dstring)LUT_9E8CB5FE_DString[460 .. 461];
            else if (input == 0xA646)
                return cast(dstring)LUT_9E8CB5FE_DString[461 .. 462];
            else if (input == 0xA648)
                return cast(dstring)LUT_9E8CB5FE_DString[462 .. 463];
            else if (input == 0xA64A)
                return cast(dstring)LUT_9E8CB5FE_DString[463 .. 464];
            else if (input == 0xA64C)
                return cast(dstring)LUT_9E8CB5FE_DString[464 .. 465];
            else if (input == 0xA64E)
                return cast(dstring)LUT_9E8CB5FE_DString[465 .. 466];
            else if (input == 0xA650)
                return cast(dstring)LUT_9E8CB5FE_DString[466 .. 467];
            else if (input == 0xA652)
                return cast(dstring)LUT_9E8CB5FE_DString[467 .. 468];
            else if (input == 0xA654)
                return cast(dstring)LUT_9E8CB5FE_DString[468 .. 469];
            else if (input == 0xA656)
                return cast(dstring)LUT_9E8CB5FE_DString[469 .. 470];
            else if (input == 0xA658)
                return cast(dstring)LUT_9E8CB5FE_DString[470 .. 471];
            else if (input == 0xA65A)
                return cast(dstring)LUT_9E8CB5FE_DString[471 .. 472];
            else if (input == 0xA65C)
                return cast(dstring)LUT_9E8CB5FE_DString[472 .. 473];
            else if (input == 0xA65E)
                return cast(dstring)LUT_9E8CB5FE_DString[473 .. 474];
            else if (input == 0xA660)
                return cast(dstring)LUT_9E8CB5FE_DString[474 .. 475];
            else if (input == 0xA662)
                return cast(dstring)LUT_9E8CB5FE_DString[475 .. 476];
            else if (input == 0xA664)
                return cast(dstring)LUT_9E8CB5FE_DString[476 .. 477];
            else if (input == 0xA666)
                return cast(dstring)LUT_9E8CB5FE_DString[477 .. 478];
            else if (input == 0xA668)
                return cast(dstring)LUT_9E8CB5FE_DString[478 .. 479];
            else if (input == 0xA66A)
                return cast(dstring)LUT_9E8CB5FE_DString[479 .. 480];
            else if (input == 0xA66C)
                return cast(dstring)LUT_9E8CB5FE_DString[480 .. 481];
            else if (input == 0xA680)
                return cast(dstring)LUT_9E8CB5FE_DString[481 .. 482];
            else if (input == 0xA682)
                return cast(dstring)LUT_9E8CB5FE_DString[482 .. 483];
            else if (input == 0xA684)
                return cast(dstring)LUT_9E8CB5FE_DString[483 .. 484];
            else if (input == 0xA686)
                return cast(dstring)LUT_9E8CB5FE_DString[484 .. 485];
            else if (input == 0xA688)
                return cast(dstring)LUT_9E8CB5FE_DString[485 .. 486];
            else if (input == 0xA68A)
                return cast(dstring)LUT_9E8CB5FE_DString[486 .. 487];
            else if (input == 0xA68C)
                return cast(dstring)LUT_9E8CB5FE_DString[487 .. 488];
            else if (input == 0xA68E)
                return cast(dstring)LUT_9E8CB5FE_DString[488 .. 489];
            else if (input == 0xA690)
                return cast(dstring)LUT_9E8CB5FE_DString[489 .. 490];
            else if (input == 0xA692)
                return cast(dstring)LUT_9E8CB5FE_DString[490 .. 491];
            else if (input == 0xA694)
                return cast(dstring)LUT_9E8CB5FE_DString[491 .. 492];
            else if (input == 0xA696)
                return cast(dstring)LUT_9E8CB5FE_DString[492 .. 493];
            else if (input == 0xA698)
                return cast(dstring)LUT_9E8CB5FE_DString[493 .. 494];
            else if (input == 0xA69A)
                return cast(dstring)LUT_9E8CB5FE_DString[494 .. 495];
            else if (input == 0xA722)
                return cast(dstring)LUT_9E8CB5FE_DString[495 .. 496];
            else if (input == 0xA724)
                return cast(dstring)LUT_9E8CB5FE_DString[496 .. 497];
            else if (input == 0xA726)
                return cast(dstring)LUT_9E8CB5FE_DString[497 .. 498];
            else if (input == 0xA728)
                return cast(dstring)LUT_9E8CB5FE_DString[498 .. 499];
            else if (input == 0xA72A)
                return cast(dstring)LUT_9E8CB5FE_DString[499 .. 500];
            else if (input == 0xA72C)
                return cast(dstring)LUT_9E8CB5FE_DString[500 .. 501];
            else if (input == 0xA72E)
                return cast(dstring)LUT_9E8CB5FE_DString[501 .. 502];
            else if (input == 0xA732)
                return cast(dstring)LUT_9E8CB5FE_DString[502 .. 503];
            else if (input == 0xA734)
                return cast(dstring)LUT_9E8CB5FE_DString[503 .. 504];
            else if (input == 0xA736)
                return cast(dstring)LUT_9E8CB5FE_DString[504 .. 505];
            else if (input == 0xA738)
                return cast(dstring)LUT_9E8CB5FE_DString[505 .. 506];
            else if (input == 0xA73A)
                return cast(dstring)LUT_9E8CB5FE_DString[506 .. 507];
            else if (input == 0xA73C)
                return cast(dstring)LUT_9E8CB5FE_DString[507 .. 508];
            else if (input == 0xA73E)
                return cast(dstring)LUT_9E8CB5FE_DString[508 .. 509];
            else if (input == 0xA740)
                return cast(dstring)LUT_9E8CB5FE_DString[509 .. 510];
            else if (input == 0xA742)
                return cast(dstring)LUT_9E8CB5FE_DString[510 .. 511];
            else if (input == 0xA744)
                return cast(dstring)LUT_9E8CB5FE_DString[511 .. 512];
            else if (input == 0xA746)
                return cast(dstring)LUT_9E8CB5FE_DString[512 .. 513];
            else if (input == 0xA748)
                return cast(dstring)LUT_9E8CB5FE_DString[513 .. 514];
            else if (input == 0xA74A)
                return cast(dstring)LUT_9E8CB5FE_DString[514 .. 515];
            else if (input == 0xA74C)
                return cast(dstring)LUT_9E8CB5FE_DString[515 .. 516];
            else if (input == 0xA74E)
                return cast(dstring)LUT_9E8CB5FE_DString[516 .. 517];
            else if (input == 0xA750)
                return cast(dstring)LUT_9E8CB5FE_DString[517 .. 518];
            else if (input == 0xA752)
                return cast(dstring)LUT_9E8CB5FE_DString[518 .. 519];
            else if (input == 0xA754)
                return cast(dstring)LUT_9E8CB5FE_DString[519 .. 520];
            else if (input == 0xA756)
                return cast(dstring)LUT_9E8CB5FE_DString[520 .. 521];
            else if (input == 0xA758)
                return cast(dstring)LUT_9E8CB5FE_DString[521 .. 522];
            else if (input == 0xA75A)
                return cast(dstring)LUT_9E8CB5FE_DString[522 .. 523];
            else if (input == 0xA75C)
                return cast(dstring)LUT_9E8CB5FE_DString[523 .. 524];
            else if (input == 0xA75E)
                return cast(dstring)LUT_9E8CB5FE_DString[524 .. 525];
            else if (input == 0xA760)
                return cast(dstring)LUT_9E8CB5FE_DString[525 .. 526];
            else if (input == 0xA762)
                return cast(dstring)LUT_9E8CB5FE_DString[526 .. 527];
            else if (input == 0xA764)
                return cast(dstring)LUT_9E8CB5FE_DString[527 .. 528];
            else if (input == 0xA766)
                return cast(dstring)LUT_9E8CB5FE_DString[528 .. 529];
            else if (input == 0xA768)
                return cast(dstring)LUT_9E8CB5FE_DString[529 .. 530];
            else if (input == 0xA76A)
                return cast(dstring)LUT_9E8CB5FE_DString[530 .. 531];
            else if (input == 0xA76C)
                return cast(dstring)LUT_9E8CB5FE_DString[531 .. 532];
            else if (input == 0xA76E)
                return cast(dstring)LUT_9E8CB5FE_DString[532 .. 533];
            else if (input == 0xA779)
                return cast(dstring)LUT_9E8CB5FE_DString[533 .. 534];
            else if (input == 0xA77B)
                return cast(dstring)LUT_9E8CB5FE_DString[534 .. 535];
            else if (input >= 0xA77D && input <= 0xA77E)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(609 + (input - 0xA77D))];
            else if (input == 0xA780)
                return cast(dstring)LUT_9E8CB5FE_DString[535 .. 536];
            else if (input == 0xA782)
                return cast(dstring)LUT_9E8CB5FE_DString[536 .. 537];
            else if (input == 0xA784)
                return cast(dstring)LUT_9E8CB5FE_DString[537 .. 538];
            else if (input == 0xA786)
                return cast(dstring)LUT_9E8CB5FE_DString[538 .. 539];
            else if (input == 0xA78B)
                return cast(dstring)LUT_9E8CB5FE_DString[539 .. 540];
            else if (input == 0xA78D)
                return cast(dstring)LUT_9E8CB5FE_DString[540 .. 541];
            else if (input == 0xA790)
                return cast(dstring)LUT_9E8CB5FE_DString[541 .. 542];
            else if (input == 0xA792)
                return cast(dstring)LUT_9E8CB5FE_DString[542 .. 543];
            else if (input == 0xA796)
                return cast(dstring)LUT_9E8CB5FE_DString[543 .. 544];
            else if (input == 0xA798)
                return cast(dstring)LUT_9E8CB5FE_DString[544 .. 545];
            else if (input == 0xA79A)
                return cast(dstring)LUT_9E8CB5FE_DString[545 .. 546];
            else if (input == 0xA79C)
                return cast(dstring)LUT_9E8CB5FE_DString[546 .. 547];
            else if (input == 0xA79E)
                return cast(dstring)LUT_9E8CB5FE_DString[547 .. 548];
            else if (input == 0xA7A0)
                return cast(dstring)LUT_9E8CB5FE_DString[548 .. 549];
            else if (input == 0xA7A2)
                return cast(dstring)LUT_9E8CB5FE_DString[549 .. 550];
            else if (input == 0xA7A4)
                return cast(dstring)LUT_9E8CB5FE_DString[550 .. 551];
            else if (input == 0xA7A6)
                return cast(dstring)LUT_9E8CB5FE_DString[551 .. 552];
            else if (input == 0xA7A8)
                return cast(dstring)LUT_9E8CB5FE_DString[552 .. 553];
            else if (input >= 0xA7AA && input <= 0xA7B4)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(611 + (input - 0xA7AA))];
            else if (input == 0xA7B6)
                return cast(dstring)LUT_9E8CB5FE_DString[553 .. 554];
            else if (input == 0xA7B8)
                return cast(dstring)LUT_9E8CB5FE_DString[554 .. 555];
            else if (input == 0xA7BA)
                return cast(dstring)LUT_9E8CB5FE_DString[555 .. 556];
            else if (input == 0xA7BC)
                return cast(dstring)LUT_9E8CB5FE_DString[556 .. 557];
            else if (input == 0xA7BE)
                return cast(dstring)LUT_9E8CB5FE_DString[557 .. 558];
            else if (input == 0xA7C0)
                return cast(dstring)LUT_9E8CB5FE_DString[558 .. 559];
            else if (input == 0xA7C2)
                return cast(dstring)LUT_9E8CB5FE_DString[559 .. 560];
            else if (input >= 0xA7C4 && input <= 0xA7C7)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(622 + (input - 0xA7C4))];
            else if (input == 0xA7C9)
                return cast(dstring)LUT_9E8CB5FE_DString[560 .. 561];
            else if (input == 0xA7D0)
                return cast(dstring)LUT_9E8CB5FE_DString[561 .. 562];
            else if (input == 0xA7D6)
                return cast(dstring)LUT_9E8CB5FE_DString[562 .. 563];
            else if (input == 0xA7D8)
                return cast(dstring)LUT_9E8CB5FE_DString[563 .. 564];
            else if (input == 0xA7F5)
                return cast(dstring)LUT_9E8CB5FE_DString[564 .. 565];
            else if (input >= 0xAB70 && input <= 0xABBF)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(626 + (input - 0xAB70))];
            else if (input >= 0xFB00 && input <= 0xFB06)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(706 + (input - 0xFB00))];
            else if (input >= 0xFB13 && input <= 0xFB17)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(713 + (input - 0xFB13))];
            else if (input >= 0xFF21)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(718 + (input - 0xFF21))];
        }
    } else if (input >= 0x10400 && input <= 0x1E921) {
        if (input <= 0x16E5F) {
            if (input <= 0x10427)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(744 + (input - 0x10400))];
            else if (input >= 0x104B0 && input <= 0x104D3)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(784 + (input - 0x104B0))];
            else if (input >= 0x10570 && input <= 0x10595)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(820 + (input - 0x10570))];
            else if (input >= 0x10C80 && input <= 0x10CB2)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(858 + (input - 0x10C80))];
            else if (input >= 0x118A0 && input <= 0x118BF)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(909 + (input - 0x118A0))];
            else if (input >= 0x16E40)
                return cast(dstring)LUT_9E8CB5FE[cast(size_t)(941 + (input - 0x16E40))];
        } else if (input >= 0x1E900) {
            return cast(dstring)LUT_9E8CB5FE[cast(size_t)(973 + (input - 0x1E900))];
        }
    }
    return null;
}
private {
    static immutable LUT_9E8CB5FE = [LUT_9E8CB5FE_DString[565 .. 566], LUT_9E8CB5FE_DString[566 .. 567], LUT_9E8CB5FE_DString[567 .. 568], LUT_9E8CB5FE_DString[568 .. 569], LUT_9E8CB5FE_DString[569 .. 570], LUT_9E8CB5FE_DString[570 .. 571], LUT_9E8CB5FE_DString[571 .. 572], LUT_9E8CB5FE_DString[572 .. 573], LUT_9E8CB5FE_DString[573 .. 574], LUT_9E8CB5FE_DString[574 .. 575], LUT_9E8CB5FE_DString[575 .. 576], LUT_9E8CB5FE_DString[576 .. 577], LUT_9E8CB5FE_DString[577 .. 578], LUT_9E8CB5FE_DString[578 .. 579], LUT_9E8CB5FE_DString[579 .. 580], LUT_9E8CB5FE_DString[580 .. 581], LUT_9E8CB5FE_DString[581 .. 582], LUT_9E8CB5FE_DString[582 .. 583], LUT_9E8CB5FE_DString[65 .. 66], LUT_9E8CB5FE_DString[583 .. 584], LUT_9E8CB5FE_DString[584 .. 585], LUT_9E8CB5FE_DString[585 .. 586], LUT_9E8CB5FE_DString[586 .. 587], LUT_9E8CB5FE_DString[587 .. 588], LUT_9E8CB5FE_DString[588 .. 589], LUT_9E8CB5FE_DString[589 .. 590], LUT_9E8CB5FE_DString[590 .. 591], LUT_9E8CB5FE_DString[591 .. 592], LUT_9E8CB5FE_DString[592 .. 593], LUT_9E8CB5FE_DString[593 .. 594], LUT_9E8CB5FE_DString[594 .. 595], LUT_9E8CB5FE_DString[595 .. 596], LUT_9E8CB5FE_DString[596 .. 597], LUT_9E8CB5FE_DString[597 .. 598], LUT_9E8CB5FE_DString[598 .. 599], LUT_9E8CB5FE_DString[599 .. 600], LUT_9E8CB5FE_DString[600 .. 601], LUT_9E8CB5FE_DString[601 .. 602], LUT_9E8CB5FE_DString[602 .. 603], LUT_9E8CB5FE_DString[603 .. 604], LUT_9E8CB5FE_DString[604 .. 605], LUT_9E8CB5FE_DString[605 .. 606], LUT_9E8CB5FE_DString[606 .. 607], LUT_9E8CB5FE_DString[607 .. 608], LUT_9E8CB5FE_DString[608 .. 609], LUT_9E8CB5FE_DString[609 .. 610], LUT_9E8CB5FE_DString[610 .. 611], LUT_9E8CB5FE_DString[611 .. 612], LUT_9E8CB5FE_DString[612 .. 613], LUT_9E8CB5FE_DString[613 .. 614], LUT_9E8CB5FE_DString[614 .. 615], LUT_9E8CB5FE_DString[615 .. 616], LUT_9E8CB5FE_DString[616 .. 617], LUT_9E8CB5FE_DString[617 .. 618], LUT_9E8CB5FE_DString[618 .. 619], LUT_9E8CB5FE_DString[619 .. 620], LUT_9E8CB5FE_DString[620 .. 621], LUT_9E8CB5FE_DString[332 .. 334], LUT_9E8CB5FE_DString[621 .. 622], LUT_9E8CB5FE_DString[622 .. 623], LUT_9E8CB5FE_DString[623 .. 624], LUT_9E8CB5FE_DString[624 .. 625], LUT_9E8CB5FE_DString[625 .. 626], LUT_9E8CB5FE_DString[626 .. 627], LUT_9E8CB5FE_DString[626 .. 627], LUT_9E8CB5FE_DString[627 .. 628], LUT_9E8CB5FE_DString[628 .. 629], LUT_9E8CB5FE_DString[629 .. 630], LUT_9E8CB5FE_DString[629 .. 630], LUT_9E8CB5FE_DString[630 .. 631], LUT_9E8CB5FE_DString[631 .. 632], LUT_9E8CB5FE_DString[632 .. 633], LUT_9E8CB5FE_DString[633 .. 634], LUT_9E8CB5FE_DString[634 .. 635], LUT_9E8CB5FE_DString[634 .. 635], LUT_9E8CB5FE_DString[635 .. 636], LUT_9E8CB5FE_DString[636 .. 637], LUT_9E8CB5FE_DString[637 .. 638], LUT_9E8CB5FE_DString[638 .. 639], LUT_9E8CB5FE_DString[639 .. 640], LUT_9E8CB5FE_DString[640 .. 641], LUT_9E8CB5FE_DString[640 .. 641], LUT_9E8CB5FE_DString[641 .. 642], LUT_9E8CB5FE_DString[642 .. 643], LUT_9E8CB5FE_DString[643 .. 644], LUT_9E8CB5FE_DString[644 .. 645], LUT_9E8CB5FE_DString[116 .. 117], LUT_9E8CB5FE_DString[645 .. 646], LUT_9E8CB5FE_DString[646 .. 647], LUT_9E8CB5FE_DString[647 .. 648], LUT_9E8CB5FE_DString[648 .. 649], LUT_9E8CB5FE_DString[649 .. 650], LUT_9E8CB5FE_DString[650 .. 651], LUT_9E8CB5FE_DString[650 .. 651], LUT_9E8CB5FE_DString[651 .. 652], LUT_9E8CB5FE_DString[652 .. 653], LUT_9E8CB5FE_DString[653 .. 654], LUT_9E8CB5FE_DString[654 .. 655], LUT_9E8CB5FE_DString[655 .. 656], LUT_9E8CB5FE_DString[637 .. 638], LUT_9E8CB5FE_DString[656 .. 657], LUT_9E8CB5FE_DString[657 .. 658], LUT_9E8CB5FE_DString[658 .. 659], LUT_9E8CB5FE_DString[659 .. 660], LUT_9E8CB5FE_DString[659 .. 660], LUT_9E8CB5FE_DString[641 .. 642], LUT_9E8CB5FE_DString[660 .. 661], LUT_9E8CB5FE_DString[661 .. 662], LUT_9E8CB5FE_DString[662 .. 663], LUT_9E8CB5FE_DString[663 .. 664], LUT_9E8CB5FE_DString[664 .. 665], LUT_9E8CB5FE_DString[665 .. 666], LUT_9E8CB5FE_DString[666 .. 667], LUT_9E8CB5FE_DString[667 .. 668], LUT_9E8CB5FE_DString[668 .. 669], LUT_9E8CB5FE_DString[669 .. 670], LUT_9E8CB5FE_DString[670 .. 673], LUT_9E8CB5FE_DString[673 .. 674], LUT_9E8CB5FE_DString[674 .. 675], LUT_9E8CB5FE_DString[675 .. 676], LUT_9E8CB5FE_DString[676 .. 677], LUT_9E8CB5FE_DString[677 .. 678], LUT_9E8CB5FE_DString[678 .. 679], LUT_9E8CB5FE_DString[679 .. 680], LUT_9E8CB5FE_DString[680 .. 681], LUT_9E8CB5FE_DString[131 .. 132], LUT_9E8CB5FE_DString[681 .. 682], LUT_9E8CB5FE_DString[682 .. 683], LUT_9E8CB5FE_DString[0 .. 1], LUT_9E8CB5FE_DString[683 .. 684], LUT_9E8CB5FE_DString[684 .. 685], LUT_9E8CB5FE_DString[685 .. 686], LUT_9E8CB5FE_DString[686 .. 687], LUT_9E8CB5FE_DString[687 .. 688], LUT_9E8CB5FE_DString[688 .. 689], LUT_9E8CB5FE_DString[141 .. 142], LUT_9E8CB5FE_DString[689 .. 690], LUT_9E8CB5FE_DString[690 .. 691], LUT_9E8CB5FE_DString[691 .. 692], LUT_9E8CB5FE_DString[692 .. 693], LUT_9E8CB5FE_DString[693 .. 694], LUT_9E8CB5FE_DString[397 .. 398], LUT_9E8CB5FE_DString[694 .. 695], LUT_9E8CB5FE_DString[695 .. 696], LUT_9E8CB5FE_DString[696 .. 697], LUT_9E8CB5FE_DString[674 .. 675], LUT_9E8CB5FE_DString[680 .. 681], LUT_9E8CB5FE_DString[697 .. 698], LUT_9E8CB5FE_DString[698 .. 699], LUT_9E8CB5FE_DString[699 .. 700], LUT_9E8CB5FE_DString[691 .. 692], LUT_9E8CB5FE_DString[686 .. 687], LUT_9E8CB5FE_DString[681 .. 682], LUT_9E8CB5FE_DString[687 .. 688], LUT_9E8CB5FE_DString[700 .. 701], LUT_9E8CB5FE_DString[135 .. 136], LUT_9E8CB5FE_DString[680 .. 681], LUT_9E8CB5FE_DString[677 .. 678], LUT_9E8CB5FE_DString[700 .. 701], LUT_9E8CB5FE_DString[701 .. 702], LUT_9E8CB5FE_DString[701 .. 702], LUT_9E8CB5FE_DString[702 .. 703], LUT_9E8CB5FE_DString[703 .. 704], LUT_9E8CB5FE_DString[704 .. 705], LUT_9E8CB5FE_DString[705 .. 706], LUT_9E8CB5FE_DString[706 .. 707], LUT_9E8CB5FE_DString[707 .. 708], LUT_9E8CB5FE_DString[708 .. 709], LUT_9E8CB5FE_DString[709 .. 710], LUT_9E8CB5FE_DString[710 .. 711], LUT_9E8CB5FE_DString[711 .. 712], LUT_9E8CB5FE_DString[712 .. 713], LUT_9E8CB5FE_DString[713 .. 714], LUT_9E8CB5FE_DString[714 .. 715], LUT_9E8CB5FE_DString[715 .. 716], LUT_9E8CB5FE_DString[716 .. 717], LUT_9E8CB5FE_DString[717 .. 718], LUT_9E8CB5FE_DString[718 .. 719], LUT_9E8CB5FE_DString[719 .. 720], LUT_9E8CB5FE_DString[720 .. 721], LUT_9E8CB5FE_DString[721 .. 722], LUT_9E8CB5FE_DString[722 .. 723], LUT_9E8CB5FE_DString[723 .. 724], LUT_9E8CB5FE_DString[724 .. 725], LUT_9E8CB5FE_DString[725 .. 726], LUT_9E8CB5FE_DString[726 .. 727], LUT_9E8CB5FE_DString[727 .. 728], LUT_9E8CB5FE_DString[728 .. 729], LUT_9E8CB5FE_DString[729 .. 730], LUT_9E8CB5FE_DString[730 .. 731], LUT_9E8CB5FE_DString[731 .. 732], LUT_9E8CB5FE_DString[732 .. 733], LUT_9E8CB5FE_DString[733 .. 734], LUT_9E8CB5FE_DString[734 .. 735], LUT_9E8CB5FE_DString[735 .. 736], LUT_9E8CB5FE_DString[736 .. 737], LUT_9E8CB5FE_DString[737 .. 738], LUT_9E8CB5FE_DString[738 .. 739], LUT_9E8CB5FE_DString[739 .. 740], LUT_9E8CB5FE_DString[740 .. 741], LUT_9E8CB5FE_DString[741 .. 742], LUT_9E8CB5FE_DString[742 .. 743], LUT_9E8CB5FE_DString[743 .. 744], LUT_9E8CB5FE_DString[744 .. 745], LUT_9E8CB5FE_DString[745 .. 746], LUT_9E8CB5FE_DString[746 .. 747], LUT_9E8CB5FE_DString[747 .. 748], LUT_9E8CB5FE_DString[748 .. 749], LUT_9E8CB5FE_DString[749 .. 750], LUT_9E8CB5FE_DString[750 .. 751], LUT_9E8CB5FE_DString[751 .. 752], LUT_9E8CB5FE_DString[752 .. 753], LUT_9E8CB5FE_DString[753 .. 754], LUT_9E8CB5FE_DString[754 .. 755], LUT_9E8CB5FE_DString[755 .. 756], LUT_9E8CB5FE_DString[756 .. 757], LUT_9E8CB5FE_DString[757 .. 758], LUT_9E8CB5FE_DString[758 .. 759], LUT_9E8CB5FE_DString[759 .. 760], LUT_9E8CB5FE_DString[760 .. 761], LUT_9E8CB5FE_DString[761 .. 762], LUT_9E8CB5FE_DString[762 .. 763], LUT_9E8CB5FE_DString[763 .. 764], LUT_9E8CB5FE_DString[764 .. 765], LUT_9E8CB5FE_DString[765 .. 766], LUT_9E8CB5FE_DString[766 .. 767], LUT_9E8CB5FE_DString[767 .. 768], LUT_9E8CB5FE_DString[768 .. 769], LUT_9E8CB5FE_DString[769 .. 770], LUT_9E8CB5FE_DString[770 .. 771], LUT_9E8CB5FE_DString[771 .. 772], LUT_9E8CB5FE_DString[772 .. 773], LUT_9E8CB5FE_DString[773 .. 774], LUT_9E8CB5FE_DString[774 .. 775], LUT_9E8CB5FE_DString[775 .. 776], LUT_9E8CB5FE_DString[776 .. 777], LUT_9E8CB5FE_DString[777 .. 778], LUT_9E8CB5FE_DString[778 .. 779], LUT_9E8CB5FE_DString[779 .. 780], LUT_9E8CB5FE_DString[780 .. 781], LUT_9E8CB5FE_DString[781 .. 782], LUT_9E8CB5FE_DString[782 .. 783], LUT_9E8CB5FE_DString[783 .. 784], LUT_9E8CB5FE_DString[784 .. 785], LUT_9E8CB5FE_DString[785 .. 786], LUT_9E8CB5FE_DString[786 .. 787], LUT_9E8CB5FE_DString[787 .. 788], LUT_9E8CB5FE_DString[788 .. 789], LUT_9E8CB5FE_DString[789 .. 790], LUT_9E8CB5FE_DString[790 .. 791], LUT_9E8CB5FE_DString[791 .. 792], LUT_9E8CB5FE_DString[792 .. 793], LUT_9E8CB5FE_DString[793 .. 794], LUT_9E8CB5FE_DString[794 .. 795], LUT_9E8CB5FE_DString[795 .. 796], LUT_9E8CB5FE_DString[796 .. 797], LUT_9E8CB5FE_DString[797 .. 798], LUT_9E8CB5FE_DString[798 .. 799], LUT_9E8CB5FE_DString[799 .. 800], LUT_9E8CB5FE_DString[800 .. 801], LUT_9E8CB5FE_DString[801 .. 802], LUT_9E8CB5FE_DString[802 .. 803], LUT_9E8CB5FE_DString[803 .. 804], LUT_9E8CB5FE_DString[804 .. 805], LUT_9E8CB5FE_DString[805 .. 806], LUT_9E8CB5FE_DString[806 .. 807], LUT_9E8CB5FE_DString[807 .. 808], LUT_9E8CB5FE_DString[808 .. 809], LUT_9E8CB5FE_DString[809 .. 810], LUT_9E8CB5FE_DString[810 .. 811], LUT_9E8CB5FE_DString[811 .. 812], LUT_9E8CB5FE_DString[812 .. 813], LUT_9E8CB5FE_DString[813 .. 814], LUT_9E8CB5FE_DString[814 .. 815], LUT_9E8CB5FE_DString[815 .. 816], LUT_9E8CB5FE_DString[816 .. 817], LUT_9E8CB5FE_DString[817 .. 818], LUT_9E8CB5FE_DString[818 .. 819], LUT_9E8CB5FE_DString[819 .. 820], LUT_9E8CB5FE_DString[820 .. 821], LUT_9E8CB5FE_DString[821 .. 822], LUT_9E8CB5FE_DString[822 .. 823], LUT_9E8CB5FE_DString[823 .. 824], LUT_9E8CB5FE_DString[824 .. 825], LUT_9E8CB5FE_DString[825 .. 826], LUT_9E8CB5FE_DString[826 .. 827], LUT_9E8CB5FE_DString[827 .. 828], LUT_9E8CB5FE_DString[828 .. 829], LUT_9E8CB5FE_DString[829 .. 830], LUT_9E8CB5FE_DString[830 .. 831], LUT_9E8CB5FE_DString[831 .. 832], LUT_9E8CB5FE_DString[832 .. 833], LUT_9E8CB5FE_DString[833 .. 834], LUT_9E8CB5FE_DString[834 .. 835], LUT_9E8CB5FE_DString[835 .. 836], LUT_9E8CB5FE_DString[836 .. 837], LUT_9E8CB5FE_DString[837 .. 838], LUT_9E8CB5FE_DString[724 .. 725], LUT_9E8CB5FE_DString[726 .. 727], LUT_9E8CB5FE_DString[736 .. 737], LUT_9E8CB5FE_DString[739 .. 740], LUT_9E8CB5FE_DString[740 .. 741], LUT_9E8CB5FE_DString[740 .. 741], LUT_9E8CB5FE_DString[748 .. 749], LUT_9E8CB5FE_DString[156 .. 157], LUT_9E8CB5FE_DString[463 .. 464], LUT_9E8CB5FE_DString[838 .. 839], LUT_9E8CB5FE_DString[839 .. 840], LUT_9E8CB5FE_DString[840 .. 841], LUT_9E8CB5FE_DString[841 .. 842], LUT_9E8CB5FE_DString[842 .. 843], LUT_9E8CB5FE_DString[843 .. 844], LUT_9E8CB5FE_DString[844 .. 845], LUT_9E8CB5FE_DString[845 .. 846], LUT_9E8CB5FE_DString[846 .. 847], LUT_9E8CB5FE_DString[847 .. 848], LUT_9E8CB5FE_DString[848 .. 849], LUT_9E8CB5FE_DString[849 .. 850], LUT_9E8CB5FE_DString[850 .. 851], LUT_9E8CB5FE_DString[851 .. 852], LUT_9E8CB5FE_DString[852 .. 853], LUT_9E8CB5FE_DString[853 .. 854], LUT_9E8CB5FE_DString[854 .. 855], LUT_9E8CB5FE_DString[855 .. 856], LUT_9E8CB5FE_DString[856 .. 857], LUT_9E8CB5FE_DString[857 .. 858], LUT_9E8CB5FE_DString[858 .. 859], LUT_9E8CB5FE_DString[859 .. 860], LUT_9E8CB5FE_DString[860 .. 861], LUT_9E8CB5FE_DString[861 .. 862], LUT_9E8CB5FE_DString[862 .. 863], LUT_9E8CB5FE_DString[863 .. 864], LUT_9E8CB5FE_DString[864 .. 865], LUT_9E8CB5FE_DString[865 .. 866], LUT_9E8CB5FE_DString[866 .. 867], LUT_9E8CB5FE_DString[867 .. 868], LUT_9E8CB5FE_DString[868 .. 869], LUT_9E8CB5FE_DString[869 .. 870], LUT_9E8CB5FE_DString[870 .. 871], LUT_9E8CB5FE_DString[871 .. 872], LUT_9E8CB5FE_DString[872 .. 873], LUT_9E8CB5FE_DString[873 .. 874], LUT_9E8CB5FE_DString[874 .. 875], LUT_9E8CB5FE_DString[875 .. 876], LUT_9E8CB5FE_DString[876 .. 877], LUT_9E8CB5FE_DString[877 .. 878], LUT_9E8CB5FE_DString[878 .. 879], LUT_9E8CB5FE_DString[879 .. 880], LUT_9E8CB5FE_DString[880 .. 881], LUT_9E8CB5FE_DString[881 .. 882], LUT_9E8CB5FE_DString[882 .. 883], LUT_9E8CB5FE_DString[883 .. 884], LUT_9E8CB5FE_DString[884 .. 885], LUT_9E8CB5FE_DString[885 .. 886], LUT_9E8CB5FE_DString[886 .. 888], LUT_9E8CB5FE_DString[888 .. 890], LUT_9E8CB5FE_DString[890 .. 892], LUT_9E8CB5FE_DString[892 .. 894], LUT_9E8CB5FE_DString[894 .. 896], LUT_9E8CB5FE_DString[896 .. 897], LUT_9E8CB5FE_DString[897 .. 898], LUT_9E8CB5FE_DString[898 .. 899], LUT_9E8CB5FE_DString[899 .. 900], LUT_9E8CB5FE_DString[900 .. 901], LUT_9E8CB5FE_DString[901 .. 902], LUT_9E8CB5FE_DString[902 .. 903], LUT_9E8CB5FE_DString[903 .. 904], LUT_9E8CB5FE_DString[904 .. 905], LUT_9E8CB5FE_DString[905 .. 906], LUT_9E8CB5FE_DString[906 .. 907], LUT_9E8CB5FE_DString[907 .. 908], LUT_9E8CB5FE_DString[908 .. 909], LUT_9E8CB5FE_DString[909 .. 910], LUT_9E8CB5FE_DString[910 .. 911], LUT_9E8CB5FE_DString[911 .. 912], LUT_9E8CB5FE_DString[912 .. 913], LUT_9E8CB5FE_DString[913 .. 914], LUT_9E8CB5FE_DString[914 .. 915], LUT_9E8CB5FE_DString[915 .. 916], LUT_9E8CB5FE_DString[916 .. 917], LUT_9E8CB5FE_DString[917 .. 918], LUT_9E8CB5FE_DString[918 .. 919], LUT_9E8CB5FE_DString[919 .. 920], LUT_9E8CB5FE_DString[920 .. 921], LUT_9E8CB5FE_DString[921 .. 922], LUT_9E8CB5FE_DString[922 .. 923], LUT_9E8CB5FE_DString[923 .. 924], LUT_9E8CB5FE_DString[924 .. 925], LUT_9E8CB5FE_DString[925 .. 926], LUT_9E8CB5FE_DString[926 .. 927], LUT_9E8CB5FE_DString[927 .. 928], LUT_9E8CB5FE_DString[928 .. 929], LUT_9E8CB5FE_DString[929 .. 930], LUT_9E8CB5FE_DString[930 .. 931], LUT_9E8CB5FE_DString[931 .. 932], LUT_9E8CB5FE_DString[932 .. 933], LUT_9E8CB5FE_DString[933 .. 934], LUT_9E8CB5FE_DString[934 .. 935], LUT_9E8CB5FE_DString[935 .. 936], LUT_9E8CB5FE_DString[936 .. 937], LUT_9E8CB5FE_DString[937 .. 938], LUT_9E8CB5FE_DString[938 .. 939], LUT_9E8CB5FE_DString[939 .. 940], LUT_9E8CB5FE_DString[940 .. 942], LUT_9E8CB5FE_DString[942 .. 944], LUT_9E8CB5FE_DString[944 .. 946], LUT_9E8CB5FE_DString[946 .. 948], LUT_9E8CB5FE_DString[948 .. 950], LUT_9E8CB5FE_DString[950 .. 952], LUT_9E8CB5FE_DString[952 .. 954], LUT_9E8CB5FE_DString[954 .. 956], LUT_9E8CB5FE_DString[940 .. 942], LUT_9E8CB5FE_DString[942 .. 944], LUT_9E8CB5FE_DString[944 .. 946], LUT_9E8CB5FE_DString[946 .. 948], LUT_9E8CB5FE_DString[948 .. 950], LUT_9E8CB5FE_DString[950 .. 952], LUT_9E8CB5FE_DString[952 .. 954], LUT_9E8CB5FE_DString[954 .. 956], LUT_9E8CB5FE_DString[956 .. 958], LUT_9E8CB5FE_DString[958 .. 960], LUT_9E8CB5FE_DString[960 .. 962], LUT_9E8CB5FE_DString[962 .. 964], LUT_9E8CB5FE_DString[964 .. 966], LUT_9E8CB5FE_DString[966 .. 968], LUT_9E8CB5FE_DString[968 .. 970], LUT_9E8CB5FE_DString[970 .. 972], LUT_9E8CB5FE_DString[956 .. 958], LUT_9E8CB5FE_DString[958 .. 960], LUT_9E8CB5FE_DString[960 .. 962], LUT_9E8CB5FE_DString[962 .. 964], LUT_9E8CB5FE_DString[964 .. 966], LUT_9E8CB5FE_DString[966 .. 968], LUT_9E8CB5FE_DString[968 .. 970], LUT_9E8CB5FE_DString[970 .. 972], LUT_9E8CB5FE_DString[972 .. 974], LUT_9E8CB5FE_DString[974 .. 976], LUT_9E8CB5FE_DString[976 .. 978], LUT_9E8CB5FE_DString[978 .. 980], LUT_9E8CB5FE_DString[980 .. 982], LUT_9E8CB5FE_DString[982 .. 984], LUT_9E8CB5FE_DString[984 .. 986], LUT_9E8CB5FE_DString[986 .. 988], LUT_9E8CB5FE_DString[972 .. 974], LUT_9E8CB5FE_DString[974 .. 976], LUT_9E8CB5FE_DString[976 .. 978], LUT_9E8CB5FE_DString[978 .. 980], LUT_9E8CB5FE_DString[980 .. 982], LUT_9E8CB5FE_DString[982 .. 984], LUT_9E8CB5FE_DString[984 .. 986], LUT_9E8CB5FE_DString[986 .. 988], LUT_9E8CB5FE_DString[988 .. 989], LUT_9E8CB5FE_DString[989 .. 990], LUT_9E8CB5FE_DString[990 .. 992], LUT_9E8CB5FE_DString[992 .. 994], LUT_9E8CB5FE_DString[994 .. 996], LUT_9E8CB5FE_DString[996 .. 997], LUT_9E8CB5FE_DString[997 .. 999], LUT_9E8CB5FE_DString[999 .. 1002], LUT_9E8CB5FE_DString[988 .. 989], LUT_9E8CB5FE_DString[989 .. 990], LUT_9E8CB5FE_DString[1002 .. 1003], LUT_9E8CB5FE_DString[1003 .. 1004], LUT_9E8CB5FE_DString[992 .. 994], LUT_9E8CB5FE_DString[1004 .. 1006], LUT_9E8CB5FE_DString[1006 .. 1008], LUT_9E8CB5FE_DString[1008 .. 1010], LUT_9E8CB5FE_DString[1010 .. 1011], LUT_9E8CB5FE_DString[1011 .. 1013], LUT_9E8CB5FE_DString[1013 .. 1016], LUT_9E8CB5FE_DString[1016 .. 1017], LUT_9E8CB5FE_DString[1017 .. 1018], LUT_9E8CB5FE_DString[1018 .. 1019], LUT_9E8CB5FE_DString[1019 .. 1020], LUT_9E8CB5FE_DString[1006 .. 1008], LUT_9E8CB5FE_DString[1020 .. 1023], LUT_9E8CB5FE_DString[670 .. 673], LUT_9E8CB5FE_DString[1023 .. 1024], LUT_9E8CB5FE_DString[1024 .. 1025], LUT_9E8CB5FE_DString[1025 .. 1027], LUT_9E8CB5FE_DString[1027 .. 1030], LUT_9E8CB5FE_DString[1030 .. 1031], LUT_9E8CB5FE_DString[1031 .. 1032], LUT_9E8CB5FE_DString[1032 .. 1033], LUT_9E8CB5FE_DString[1033 .. 1034], LUT_9E8CB5FE_DString[1034 .. 1037], LUT_9E8CB5FE_DString[138 .. 141], LUT_9E8CB5FE_DString[1037 .. 1039], LUT_9E8CB5FE_DString[1039 .. 1040], LUT_9E8CB5FE_DString[1040 .. 1042], LUT_9E8CB5FE_DString[1042 .. 1045], LUT_9E8CB5FE_DString[1045 .. 1046], LUT_9E8CB5FE_DString[1046 .. 1047], LUT_9E8CB5FE_DString[1047 .. 1048], LUT_9E8CB5FE_DString[1048 .. 1049], LUT_9E8CB5FE_DString[1039 .. 1040], LUT_9E8CB5FE_DString[1049 .. 1051], LUT_9E8CB5FE_DString[1051 .. 1053], LUT_9E8CB5FE_DString[1053 .. 1055], LUT_9E8CB5FE_DString[1055 .. 1056], LUT_9E8CB5FE_DString[1056 .. 1058], LUT_9E8CB5FE_DString[1058 .. 1061], LUT_9E8CB5FE_DString[1061 .. 1062], LUT_9E8CB5FE_DString[1062 .. 1063], LUT_9E8CB5FE_DString[1063 .. 1064], LUT_9E8CB5FE_DString[1064 .. 1065], LUT_9E8CB5FE_DString[1051 .. 1053], LUT_9E8CB5FE_DString[575 .. 576], LUT_9E8CB5FE_DString[595 .. 596], LUT_9E8CB5FE_DString[1065 .. 1066], LUT_9E8CB5FE_DString[1066 .. 1067], LUT_9E8CB5FE_DString[1067 .. 1068], LUT_9E8CB5FE_DString[1068 .. 1069], LUT_9E8CB5FE_DString[1069 .. 1070], LUT_9E8CB5FE_DString[1070 .. 1071], LUT_9E8CB5FE_DString[1071 .. 1072], LUT_9E8CB5FE_DString[1072 .. 1073], LUT_9E8CB5FE_DString[1073 .. 1074], LUT_9E8CB5FE_DString[1074 .. 1075], LUT_9E8CB5FE_DString[1075 .. 1076], LUT_9E8CB5FE_DString[1076 .. 1077], LUT_9E8CB5FE_DString[1077 .. 1078], LUT_9E8CB5FE_DString[1078 .. 1079], LUT_9E8CB5FE_DString[1079 .. 1080], LUT_9E8CB5FE_DString[1080 .. 1081], LUT_9E8CB5FE_DString[1081 .. 1082], LUT_9E8CB5FE_DString[1082 .. 1083], LUT_9E8CB5FE_DString[1083 .. 1084], LUT_9E8CB5FE_DString[1084 .. 1085], LUT_9E8CB5FE_DString[1085 .. 1086], LUT_9E8CB5FE_DString[1086 .. 1087], LUT_9E8CB5FE_DString[1087 .. 1088], LUT_9E8CB5FE_DString[1088 .. 1089], LUT_9E8CB5FE_DString[1089 .. 1090], LUT_9E8CB5FE_DString[1090 .. 1091], LUT_9E8CB5FE_DString[1091 .. 1092], LUT_9E8CB5FE_DString[1092 .. 1093], LUT_9E8CB5FE_DString[1093 .. 1094], LUT_9E8CB5FE_DString[1094 .. 1095], LUT_9E8CB5FE_DString[1095 .. 1096], LUT_9E8CB5FE_DString[1096 .. 1097], LUT_9E8CB5FE_DString[1097 .. 1098], LUT_9E8CB5FE_DString[1098 .. 1099], LUT_9E8CB5FE_DString[1099 .. 1100], LUT_9E8CB5FE_DString[1100 .. 1101], LUT_9E8CB5FE_DString[1101 .. 1102], LUT_9E8CB5FE_DString[1102 .. 1103], LUT_9E8CB5FE_DString[1103 .. 1104], LUT_9E8CB5FE_DString[1104 .. 1105], LUT_9E8CB5FE_DString[1105 .. 1106], LUT_9E8CB5FE_DString[1106 .. 1107], LUT_9E8CB5FE_DString[1107 .. 1108], LUT_9E8CB5FE_DString[1108 .. 1109], LUT_9E8CB5FE_DString[1109 .. 1110], LUT_9E8CB5FE_DString[1110 .. 1111], LUT_9E8CB5FE_DString[1111 .. 1112], LUT_9E8CB5FE_DString[1112 .. 1113], LUT_9E8CB5FE_DString[1113 .. 1114], LUT_9E8CB5FE_DString[1114 .. 1115], LUT_9E8CB5FE_DString[1115 .. 1116], LUT_9E8CB5FE_DString[1116 .. 1117], LUT_9E8CB5FE_DString[1117 .. 1118], LUT_9E8CB5FE_DString[1118 .. 1119], LUT_9E8CB5FE_DString[1119 .. 1120], LUT_9E8CB5FE_DString[1120 .. 1121], LUT_9E8CB5FE_DString[1121 .. 1122], LUT_9E8CB5FE_DString[1122 .. 1123], LUT_9E8CB5FE_DString[1123 .. 1124], LUT_9E8CB5FE_DString[1124 .. 1125], LUT_9E8CB5FE_DString[1125 .. 1126], LUT_9E8CB5FE_DString[1126 .. 1127], LUT_9E8CB5FE_DString[1127 .. 1128], LUT_9E8CB5FE_DString[1128 .. 1129], LUT_9E8CB5FE_DString[1129 .. 1130], LUT_9E8CB5FE_DString[1130 .. 1131], LUT_9E8CB5FE_DString[1131 .. 1132], LUT_9E8CB5FE_DString[1132 .. 1133], LUT_9E8CB5FE_DString[1133 .. 1134], LUT_9E8CB5FE_DString[1134 .. 1135], LUT_9E8CB5FE_DString[1135 .. 1136], LUT_9E8CB5FE_DString[1136 .. 1137], LUT_9E8CB5FE_DString[1137 .. 1138], LUT_9E8CB5FE_DString[1138 .. 1139], LUT_9E8CB5FE_DString[1139 .. 1140], LUT_9E8CB5FE_DString[1140 .. 1141], LUT_9E8CB5FE_DString[1141 .. 1142], LUT_9E8CB5FE_DString[1142 .. 1143], LUT_9E8CB5FE_DString[1143 .. 1144], LUT_9E8CB5FE_DString[1144 .. 1145], LUT_9E8CB5FE_DString[1145 .. 1146], LUT_9E8CB5FE_DString[1146 .. 1147], LUT_9E8CB5FE_DString[1147 .. 1148], LUT_9E8CB5FE_DString[1148 .. 1149], LUT_9E8CB5FE_DString[1149 .. 1150], LUT_9E8CB5FE_DString[1150 .. 1151], LUT_9E8CB5FE_DString[1151 .. 1152], LUT_9E8CB5FE_DString[1152 .. 1153], LUT_9E8CB5FE_DString[1153 .. 1154], LUT_9E8CB5FE_DString[1154 .. 1155], LUT_9E8CB5FE_DString[1155 .. 1156], LUT_9E8CB5FE_DString[1156 .. 1157], LUT_9E8CB5FE_DString[1157 .. 1158], LUT_9E8CB5FE_DString[1158 .. 1159], LUT_9E8CB5FE_DString[1159 .. 1160], LUT_9E8CB5FE_DString[1160 .. 1161], LUT_9E8CB5FE_DString[1161 .. 1162], LUT_9E8CB5FE_DString[1162 .. 1163], LUT_9E8CB5FE_DString[1163 .. 1164], LUT_9E8CB5FE_DString[1164 .. 1165], LUT_9E8CB5FE_DString[1165 .. 1166], LUT_9E8CB5FE_DString[1166 .. 1167], LUT_9E8CB5FE_DString[1167 .. 1168], LUT_9E8CB5FE_DString[1168 .. 1169], LUT_9E8CB5FE_DString[1169 .. 1170], LUT_9E8CB5FE_DString[1170 .. 1171], LUT_9E8CB5FE_DString[1171 .. 1172], LUT_9E8CB5FE_DString[1172 .. 1173], LUT_9E8CB5FE_DString[1173 .. 1174], LUT_9E8CB5FE_DString[1174 .. 1175], LUT_9E8CB5FE_DString[1175 .. 1176], LUT_9E8CB5FE_DString[1176 .. 1177], LUT_9E8CB5FE_DString[1177 .. 1178], LUT_9E8CB5FE_DString[1178 .. 1179], LUT_9E8CB5FE_DString[1179 .. 1180], LUT_9E8CB5FE_DString[1180 .. 1181], LUT_9E8CB5FE_DString[1181 .. 1182], LUT_9E8CB5FE_DString[1182 .. 1183], LUT_9E8CB5FE_DString[1183 .. 1184], LUT_9E8CB5FE_DString[1184 .. 1185], LUT_9E8CB5FE_DString[1185 .. 1186], LUT_9E8CB5FE_DString[1186 .. 1187], LUT_9E8CB5FE_DString[1187 .. 1188], LUT_9E8CB5FE_DString[1188 .. 1189], LUT_9E8CB5FE_DString[1189 .. 1190], LUT_9E8CB5FE_DString[1190 .. 1191], LUT_9E8CB5FE_DString[1191 .. 1192], LUT_9E8CB5FE_DString[1192 .. 1193], LUT_9E8CB5FE_DString[1193 .. 1194], LUT_9E8CB5FE_DString[1194 .. 1195], LUT_9E8CB5FE_DString[1195 .. 1196], LUT_9E8CB5FE_DString[1196 .. 1197], LUT_9E8CB5FE_DString[1197 .. 1198], LUT_9E8CB5FE_DString[1198 .. 1199], LUT_9E8CB5FE_DString[1199 .. 1200], LUT_9E8CB5FE_DString[1200 .. 1201], LUT_9E8CB5FE_DString[1201 .. 1202], LUT_9E8CB5FE_DString[1202 .. 1203], LUT_9E8CB5FE_DString[1203 .. 1204], LUT_9E8CB5FE_DString[1204 .. 1205], LUT_9E8CB5FE_DString[1205 .. 1206], LUT_9E8CB5FE_DString[1206 .. 1207], LUT_9E8CB5FE_DString[1207 .. 1208], LUT_9E8CB5FE_DString[1208 .. 1209], LUT_9E8CB5FE_DString[1209 .. 1210], LUT_9E8CB5FE_DString[1210 .. 1211], LUT_9E8CB5FE_DString[1211 .. 1212], LUT_9E8CB5FE_DString[1212 .. 1213], LUT_9E8CB5FE_DString[1213 .. 1214], LUT_9E8CB5FE_DString[1214 .. 1215], LUT_9E8CB5FE_DString[1215 .. 1216], LUT_9E8CB5FE_DString[1216 .. 1217], LUT_9E8CB5FE_DString[1217 .. 1218], LUT_9E8CB5FE_DString[1218 .. 1219], LUT_9E8CB5FE_DString[1219 .. 1220], LUT_9E8CB5FE_DString[1220 .. 1221], LUT_9E8CB5FE_DString[1221 .. 1222], LUT_9E8CB5FE_DString[1222 .. 1223], LUT_9E8CB5FE_DString[1223 .. 1224], LUT_9E8CB5FE_DString[1224 .. 1225], LUT_9E8CB5FE_DString[1225 .. 1226], LUT_9E8CB5FE_DString[1226 .. 1227], LUT_9E8CB5FE_DString[1227 .. 1228], LUT_9E8CB5FE_DString[1228 .. 1229], LUT_9E8CB5FE_DString[1229 .. 1230], LUT_9E8CB5FE_DString[1230 .. 1231], LUT_9E8CB5FE_DString[1231 .. 1232], LUT_9E8CB5FE_DString[1232 .. 1233], LUT_9E8CB5FE_DString[1233 .. 1234], LUT_9E8CB5FE_DString[1234 .. 1235], LUT_9E8CB5FE_DString[1235 .. 1236], LUT_9E8CB5FE_DString[1236 .. 1237], LUT_9E8CB5FE_DString[1237 .. 1238], LUT_9E8CB5FE_DString[1238 .. 1239], LUT_9E8CB5FE_DString[1239 .. 1240], LUT_9E8CB5FE_DString[1240 .. 1241], LUT_9E8CB5FE_DString[1241 .. 1242], LUT_9E8CB5FE_DString[1242 .. 1243], LUT_9E8CB5FE_DString[1243 .. 1244], LUT_9E8CB5FE_DString[1244 .. 1245], LUT_9E8CB5FE_DString[1245 .. 1246], LUT_9E8CB5FE_DString[1246 .. 1247], LUT_9E8CB5FE_DString[1247 .. 1248], LUT_9E8CB5FE_DString[1248 .. 1249], LUT_9E8CB5FE_DString[1249 .. 1250], LUT_9E8CB5FE_DString[1250 .. 1251], LUT_9E8CB5FE_DString[1251 .. 1252], LUT_9E8CB5FE_DString[1252 .. 1253], LUT_9E8CB5FE_DString[1253 .. 1254], LUT_9E8CB5FE_DString[1254 .. 1255], LUT_9E8CB5FE_DString[1255 .. 1256], LUT_9E8CB5FE_DString[1256 .. 1257], LUT_9E8CB5FE_DString[1257 .. 1258], LUT_9E8CB5FE_DString[1258 .. 1259], LUT_9E8CB5FE_DString[1259 .. 1260], LUT_9E8CB5FE_DString[1260 .. 1261], LUT_9E8CB5FE_DString[1261 .. 1262], LUT_9E8CB5FE_DString[1262 .. 1264], LUT_9E8CB5FE_DString[1264 .. 1266], LUT_9E8CB5FE_DString[1266 .. 1268], LUT_9E8CB5FE_DString[1268 .. 1271], LUT_9E8CB5FE_DString[1271 .. 1274], LUT_9E8CB5FE_DString[1274 .. 1276], LUT_9E8CB5FE_DString[1274 .. 1276], LUT_9E8CB5FE_DString[1276 .. 1278], LUT_9E8CB5FE_DString[1278 .. 1280], LUT_9E8CB5FE_DString[1280 .. 1282], LUT_9E8CB5FE_DString[1282 .. 1284], LUT_9E8CB5FE_DString[1284 .. 1286], LUT_9E8CB5FE_DString[1286 .. 1287], LUT_9E8CB5FE_DString[1287 .. 1288], LUT_9E8CB5FE_DString[1288 .. 1289], LUT_9E8CB5FE_DString[1289 .. 1290], LUT_9E8CB5FE_DString[1290 .. 1291], LUT_9E8CB5FE_DString[1291 .. 1292], LUT_9E8CB5FE_DString[1292 .. 1293], LUT_9E8CB5FE_DString[1293 .. 1294], LUT_9E8CB5FE_DString[1294 .. 1295], LUT_9E8CB5FE_DString[1295 .. 1296], LUT_9E8CB5FE_DString[1296 .. 1297], LUT_9E8CB5FE_DString[1297 .. 1298], LUT_9E8CB5FE_DString[1298 .. 1299], LUT_9E8CB5FE_DString[1299 .. 1300], LUT_9E8CB5FE_DString[1300 .. 1301], LUT_9E8CB5FE_DString[1301 .. 1302], LUT_9E8CB5FE_DString[1302 .. 1303], LUT_9E8CB5FE_DString[1303 .. 1304], LUT_9E8CB5FE_DString[1304 .. 1305], LUT_9E8CB5FE_DString[1305 .. 1306], LUT_9E8CB5FE_DString[1306 .. 1307], LUT_9E8CB5FE_DString[1307 .. 1308], LUT_9E8CB5FE_DString[1308 .. 1309], LUT_9E8CB5FE_DString[1309 .. 1310], LUT_9E8CB5FE_DString[1310 .. 1311], LUT_9E8CB5FE_DString[1311 .. 1312], LUT_9E8CB5FE_DString[1312 .. 1313], LUT_9E8CB5FE_DString[1313 .. 1314], LUT_9E8CB5FE_DString[1314 .. 1315], LUT_9E8CB5FE_DString[1315 .. 1316], LUT_9E8CB5FE_DString[1316 .. 1317], LUT_9E8CB5FE_DString[1317 .. 1318], LUT_9E8CB5FE_DString[1318 .. 1319], LUT_9E8CB5FE_DString[1319 .. 1320], LUT_9E8CB5FE_DString[1320 .. 1321], LUT_9E8CB5FE_DString[1321 .. 1322], LUT_9E8CB5FE_DString[1322 .. 1323], LUT_9E8CB5FE_DString[1323 .. 1324], LUT_9E8CB5FE_DString[1324 .. 1325], LUT_9E8CB5FE_DString[1325 .. 1326], LUT_9E8CB5FE_DString[1326 .. 1327], LUT_9E8CB5FE_DString[1327 .. 1328], LUT_9E8CB5FE_DString[1328 .. 1329], LUT_9E8CB5FE_DString[1329 .. 1330], LUT_9E8CB5FE_DString[1330 .. 1331], LUT_9E8CB5FE_DString[1331 .. 1332], LUT_9E8CB5FE_DString[1332 .. 1333], LUT_9E8CB5FE_DString[1333 .. 1334], LUT_9E8CB5FE_DString[1334 .. 1335], LUT_9E8CB5FE_DString[1335 .. 1336], LUT_9E8CB5FE_DString[1336 .. 1337], LUT_9E8CB5FE_DString[1337 .. 1338], LUT_9E8CB5FE_DString[1338 .. 1339], LUT_9E8CB5FE_DString[1339 .. 1340], LUT_9E8CB5FE_DString[1340 .. 1341], LUT_9E8CB5FE_DString[1341 .. 1342], LUT_9E8CB5FE_DString[1342 .. 1343], LUT_9E8CB5FE_DString[1343 .. 1344], LUT_9E8CB5FE_DString[1344 .. 1345], LUT_9E8CB5FE_DString[1345 .. 1346], LUT_9E8CB5FE_DString[1346 .. 1347], LUT_9E8CB5FE_DString[1347 .. 1348], LUT_9E8CB5FE_DString[1348 .. 1349], LUT_9E8CB5FE_DString[1349 .. 1350], LUT_9E8CB5FE_DString[1350 .. 1351], LUT_9E8CB5FE_DString[1351 .. 1352], LUT_9E8CB5FE_DString[1352 .. 1353], LUT_9E8CB5FE_DString[1353 .. 1354], LUT_9E8CB5FE_DString[1354 .. 1355], LUT_9E8CB5FE_DString[1355 .. 1356], LUT_9E8CB5FE_DString[1356 .. 1357], LUT_9E8CB5FE_DString[1357 .. 1358], LUT_9E8CB5FE_DString[1358 .. 1359], LUT_9E8CB5FE_DString[1359 .. 1360], LUT_9E8CB5FE_DString[1360 .. 1361], LUT_9E8CB5FE_DString[1361 .. 1362], LUT_9E8CB5FE_DString[1362 .. 1363], LUT_9E8CB5FE_DString[1363 .. 1364], LUT_9E8CB5FE_DString[1364 .. 1365], LUT_9E8CB5FE_DString[1365 .. 1366], LUT_9E8CB5FE_DString[1366 .. 1367], LUT_9E8CB5FE_DString[1367 .. 1368], LUT_9E8CB5FE_DString[1368 .. 1369], LUT_9E8CB5FE_DString[1369 .. 1370], LUT_9E8CB5FE_DString[1370 .. 1371], LUT_9E8CB5FE_DString[1371 .. 1372], LUT_9E8CB5FE_DString[1372 .. 1373], LUT_9E8CB5FE_DString[1373 .. 1374], LUT_9E8CB5FE_DString[1374 .. 1375], LUT_9E8CB5FE_DString[1375 .. 1376], LUT_9E8CB5FE_DString[1376 .. 1377], LUT_9E8CB5FE_DString[1377 .. 1378], LUT_9E8CB5FE_DString[1378 .. 1379], LUT_9E8CB5FE_DString[1379 .. 1380], LUT_9E8CB5FE_DString[1380 .. 1381], LUT_9E8CB5FE_DString[1381 .. 1382], LUT_9E8CB5FE_DString[1382 .. 1383], LUT_9E8CB5FE_DString[1383 .. 1384], LUT_9E8CB5FE_DString[1384 .. 1385], LUT_9E8CB5FE_DString[1385 .. 1386], LUT_9E8CB5FE_DString[1386 .. 1387], LUT_9E8CB5FE_DString[1387 .. 1388], LUT_9E8CB5FE_DString[1388 .. 1389], LUT_9E8CB5FE_DString[1389 .. 1390], LUT_9E8CB5FE_DString[1390 .. 1391], LUT_9E8CB5FE_DString[1391 .. 1392], LUT_9E8CB5FE_DString[1392 .. 1393], LUT_9E8CB5FE_DString[1393 .. 1394], LUT_9E8CB5FE_DString[1394 .. 1395], LUT_9E8CB5FE_DString[1395 .. 1396], LUT_9E8CB5FE_DString[1396 .. 1397], LUT_9E8CB5FE_DString[1397 .. 1398], LUT_9E8CB5FE_DString[1398 .. 1399], LUT_9E8CB5FE_DString[1399 .. 1400], LUT_9E8CB5FE_DString[1400 .. 1401], LUT_9E8CB5FE_DString[1401 .. 1402], LUT_9E8CB5FE_DString[1402 .. 1403], LUT_9E8CB5FE_DString[1403 .. 1404], LUT_9E8CB5FE_DString[1404 .. 1405], LUT_9E8CB5FE_DString[1405 .. 1406], LUT_9E8CB5FE_DString[1406 .. 1407], LUT_9E8CB5FE_DString[1407 .. 1408], LUT_9E8CB5FE_DString[1408 .. 1409], LUT_9E8CB5FE_DString[1409 .. 1410], LUT_9E8CB5FE_DString[1410 .. 1411], LUT_9E8CB5FE_DString[1411 .. 1412], LUT_9E8CB5FE_DString[1412 .. 1413], LUT_9E8CB5FE_DString[1413 .. 1414], LUT_9E8CB5FE_DString[1414 .. 1415], LUT_9E8CB5FE_DString[1415 .. 1416], LUT_9E8CB5FE_DString[1416 .. 1417], LUT_9E8CB5FE_DString[1417 .. 1418], LUT_9E8CB5FE_DString[1418 .. 1419], LUT_9E8CB5FE_DString[1419 .. 1420], LUT_9E8CB5FE_DString[1420 .. 1421], LUT_9E8CB5FE_DString[1421 .. 1422], LUT_9E8CB5FE_DString[1422 .. 1423], LUT_9E8CB5FE_DString[1423 .. 1424], LUT_9E8CB5FE_DString[1424 .. 1425], LUT_9E8CB5FE_DString[1425 .. 1426], LUT_9E8CB5FE_DString[1426 .. 1427], LUT_9E8CB5FE_DString[1427 .. 1428], LUT_9E8CB5FE_DString[1428 .. 1429], LUT_9E8CB5FE_DString[1429 .. 1430], LUT_9E8CB5FE_DString[1430 .. 1431], LUT_9E8CB5FE_DString[1431 .. 1432], LUT_9E8CB5FE_DString[1432 .. 1433], LUT_9E8CB5FE_DString[1433 .. 1434], LUT_9E8CB5FE_DString[1434 .. 1435], LUT_9E8CB5FE_DString[1435 .. 1436], LUT_9E8CB5FE_DString[1436 .. 1437], LUT_9E8CB5FE_DString[1437 .. 1438], LUT_9E8CB5FE_DString[1438 .. 1439], LUT_9E8CB5FE_DString[1439 .. 1440], LUT_9E8CB5FE_DString[1440 .. 1441], LUT_9E8CB5FE_DString[1441 .. 1442], LUT_9E8CB5FE_DString[1442 .. 1443], LUT_9E8CB5FE_DString[1443 .. 1444], LUT_9E8CB5FE_DString[1444 .. 1445], LUT_9E8CB5FE_DString[1445 .. 1446], LUT_9E8CB5FE_DString[1446 .. 1447], LUT_9E8CB5FE_DString[1447 .. 1448], LUT_9E8CB5FE_DString[1448 .. 1449], LUT_9E8CB5FE_DString[1449 .. 1450], LUT_9E8CB5FE_DString[1450 .. 1451], LUT_9E8CB5FE_DString[1451 .. 1452], LUT_9E8CB5FE_DString[1452 .. 1453], LUT_9E8CB5FE_DString[1453 .. 1454], LUT_9E8CB5FE_DString[1454 .. 1455], LUT_9E8CB5FE_DString[1455 .. 1456], LUT_9E8CB5FE_DString[1456 .. 1457], LUT_9E8CB5FE_DString[1457 .. 1458], LUT_9E8CB5FE_DString[1458 .. 1459], LUT_9E8CB5FE_DString[1459 .. 1460], LUT_9E8CB5FE_DString[1460 .. 1461], LUT_9E8CB5FE_DString[1461 .. 1462], LUT_9E8CB5FE_DString[1462 .. 1463], LUT_9E8CB5FE_DString[1463 .. 1464], LUT_9E8CB5FE_DString[1464 .. 1465], LUT_9E8CB5FE_DString[1465 .. 1466], LUT_9E8CB5FE_DString[1466 .. 1467], LUT_9E8CB5FE_DString[1467 .. 1468], LUT_9E8CB5FE_DString[1468 .. 1469], LUT_9E8CB5FE_DString[1469 .. 1470], LUT_9E8CB5FE_DString[1470 .. 1471], LUT_9E8CB5FE_DString[1471 .. 1472], LUT_9E8CB5FE_DString[1472 .. 1473], LUT_9E8CB5FE_DString[1473 .. 1474], LUT_9E8CB5FE_DString[1474 .. 1475], LUT_9E8CB5FE_DString[1475 .. 1476], LUT_9E8CB5FE_DString[1476 .. 1477], LUT_9E8CB5FE_DString[1477 .. 1478], LUT_9E8CB5FE_DString[1478 .. 1479], LUT_9E8CB5FE_DString[1479 .. 1480], LUT_9E8CB5FE_DString[1480 .. 1481], LUT_9E8CB5FE_DString[1481 .. 1482], LUT_9E8CB5FE_DString[1482 .. 1483], LUT_9E8CB5FE_DString[1483 .. 1484], LUT_9E8CB5FE_DString[1484 .. 1485], LUT_9E8CB5FE_DString[1485 .. 1486], LUT_9E8CB5FE_DString[1486 .. 1487], LUT_9E8CB5FE_DString[1487 .. 1488], LUT_9E8CB5FE_DString[1488 .. 1489], LUT_9E8CB5FE_DString[1489 .. 1490], LUT_9E8CB5FE_DString[1490 .. 1491], LUT_9E8CB5FE_DString[1491 .. 1492], LUT_9E8CB5FE_DString[1492 .. 1493], LUT_9E8CB5FE_DString[1493 .. 1494], LUT_9E8CB5FE_DString[1494 .. 1495], LUT_9E8CB5FE_DString[1495 .. 1496], LUT_9E8CB5FE_DString[1496 .. 1497], LUT_9E8CB5FE_DString[1497 .. 1498], LUT_9E8CB5FE_DString[1498 .. 1499], LUT_9E8CB5FE_DString[1499 .. 1500], LUT_9E8CB5FE_DString[1500 .. 1501], LUT_9E8CB5FE_DString[1501 .. 1502], LUT_9E8CB5FE_DString[1502 .. 1503], LUT_9E8CB5FE_DString[1503 .. 1504], LUT_9E8CB5FE_DString[1504 .. 1505], LUT_9E8CB5FE_DString[1505 .. 1506], LUT_9E8CB5FE_DString[1506 .. 1507], LUT_9E8CB5FE_DString[1507 .. 1508], LUT_9E8CB5FE_DString[1508 .. 1509], LUT_9E8CB5FE_DString[1509 .. 1510], LUT_9E8CB5FE_DString[1510 .. 1511], LUT_9E8CB5FE_DString[1511 .. 1512], LUT_9E8CB5FE_DString[1512 .. 1513], LUT_9E8CB5FE_DString[1513 .. 1514], LUT_9E8CB5FE_DString[1514 .. 1515], LUT_9E8CB5FE_DString[1515 .. 1516], LUT_9E8CB5FE_DString[1516 .. 1517], LUT_9E8CB5FE_DString[1517 .. 1518], LUT_9E8CB5FE_DString[1518 .. 1519], LUT_9E8CB5FE_DString[1519 .. 1520], LUT_9E8CB5FE_DString[1520 .. 1521], LUT_9E8CB5FE_DString[1521 .. 1522], LUT_9E8CB5FE_DString[1522 .. 1523], LUT_9E8CB5FE_DString[1523 .. 1524], LUT_9E8CB5FE_DString[1524 .. 1525], LUT_9E8CB5FE_DString[1525 .. 1526], LUT_9E8CB5FE_DString[1526 .. 1527], LUT_9E8CB5FE_DString[1527 .. 1528], LUT_9E8CB5FE_DString[1528 .. 1529], LUT_9E8CB5FE_DString[1529 .. 1530], LUT_9E8CB5FE_DString[1530 .. 1531], LUT_9E8CB5FE_DString[1531 .. 1532], LUT_9E8CB5FE_DString[1532 .. 1533], LUT_9E8CB5FE_DString[1533 .. 1534], LUT_9E8CB5FE_DString[1534 .. 1535], LUT_9E8CB5FE_DString[1535 .. 1536], LUT_9E8CB5FE_DString[1536 .. 1537], LUT_9E8CB5FE_DString[1537 .. 1538], LUT_9E8CB5FE_DString[1538 .. 1539], LUT_9E8CB5FE_DString[1539 .. 1540], LUT_9E8CB5FE_DString[1540 .. 1541], LUT_9E8CB5FE_DString[1541 .. 1542], LUT_9E8CB5FE_DString[1542 .. 1543], LUT_9E8CB5FE_DString[1543 .. 1544], LUT_9E8CB5FE_DString[1544 .. 1545], LUT_9E8CB5FE_DString[1545 .. 1546], LUT_9E8CB5FE_DString[1546 .. 1547], LUT_9E8CB5FE_DString[1547 .. 1548], LUT_9E8CB5FE_DString[1548 .. 1549], LUT_9E8CB5FE_DString[1549 .. 1550], LUT_9E8CB5FE_DString[1550 .. 1551], LUT_9E8CB5FE_DString[1551 .. 1552], LUT_9E8CB5FE_DString[1552 .. 1553], LUT_9E8CB5FE_DString[1553 .. 1554], LUT_9E8CB5FE_DString[1554 .. 1555], LUT_9E8CB5FE_DString[1555 .. 1556], LUT_9E8CB5FE_DString[1556 .. 1557], LUT_9E8CB5FE_DString[1557 .. 1558], LUT_9E8CB5FE_DString[1558 .. 1559], LUT_9E8CB5FE_DString[1559 .. 1560], LUT_9E8CB5FE_DString[1560 .. 1561], LUT_9E8CB5FE_DString[1561 .. 1562], LUT_9E8CB5FE_DString[1562 .. 1563], LUT_9E8CB5FE_DString[1563 .. 1564], LUT_9E8CB5FE_DString[1564 .. 1565], LUT_9E8CB5FE_DString[1565 .. 1566], LUT_9E8CB5FE_DString[1566 .. 1567], LUT_9E8CB5FE_DString[1567 .. 1568], LUT_9E8CB5FE_DString[1568 .. 1569], LUT_9E8CB5FE_DString[1569 .. 1570], LUT_9E8CB5FE_DString[1570 .. 1571], LUT_9E8CB5FE_DString[1571 .. 1572], LUT_9E8CB5FE_DString[1572 .. 1573], LUT_9E8CB5FE_DString[1573 .. 1574], LUT_9E8CB5FE_DString[1574 .. 1575], ];
    static immutable dstring LUT_9E8CB5FE_DString = cast(dstring)[cast(uint)0x03BC, 0x0101, 0x0103, 0x0105, 0x0107, 0x0109, 0x010B, 0x010D, 0x010F, 0x0111, 0x0113, 0x0115, 0x0117, 0x0119, 0x011B, 0x011D, 0x011F, 0x0121, 0x0123, 0x0125, 0x0127, 0x0129, 0x012B, 0x012D, 0x012F, 0x69, 0x0307, 0x0133, 0x0135, 0x0137, 0x013A, 0x013C, 0x013E, 0x0140, 0x0142, 0x0144, 0x0146, 0x0148, 0x02BC, 0x6E, 0x014B, 0x014D, 0x014F, 0x0151, 0x0153, 0x0155, 0x0157, 0x0159, 0x015B, 0x015D, 0x015F, 0x0161, 0x0163, 0x0165, 0x0167, 0x0169, 0x016B, 0x016D, 0x016F, 0x0171, 0x0173, 0x0175, 0x0177, 0x017C, 0x017E, 0x73, 0x0185, 0x01A3, 0x01A5, 0x0283, 0x01AD, 0x01B6, 0x01BD, 0x01C6, 0x01C9, 0x01CC, 0x01CE, 0x01D0, 0x01D2, 0x01D4, 0x01D6, 0x01D8, 0x01DA, 0x01DC, 0x01DF, 0x01E1, 0x01E3, 0x01E5, 0x01E7, 0x01E9, 0x01EB, 0x01ED, 0x01EF, 0x6A, 0x030C, 0x01F3, 0x01F5, 0x01FB, 0x01FD, 0x01FF, 0x0201, 0x0203, 0x0205, 0x0207, 0x0209, 0x020B, 0x020D, 0x020F, 0x0211, 0x0213, 0x0215, 0x0217, 0x0219, 0x021B, 0x021D, 0x021F, 0x019E, 0x0223, 0x0225, 0x0227, 0x0229, 0x022B, 0x022D, 0x022F, 0x0231, 0x0233, 0x0242, 0x0249, 0x024B, 0x024D, 0x024F, 0x03B9, 0x0371, 0x0373, 0x0377, 0x03F3, 0x03AC, 0x03CC, 0x03C5, 0x0308, 0x0301, 0x03C3, 0x03D9, 0x03DB, 0x03DD, 0x03DF, 0x03E1, 0x03E3, 0x03E5, 0x03E7, 0x03E9, 0x03EB, 0x03ED, 0x03EF, 0x03F8, 0x0461, 0x0463, 0x0465, 0x0467, 0x0469, 0x046B, 0x046D, 0x046F, 0x0471, 0x0473, 0x0475, 0x0477, 0x0479, 0x047B, 0x047D, 0x047F, 0x0481, 0x048B, 0x048D, 0x048F, 0x0491, 0x0493, 0x0495, 0x0497, 0x0499, 0x049B, 0x049D, 0x049F, 0x04A1, 0x04A3, 0x04A5, 0x04A7, 0x04A9, 0x04AB, 0x04AD, 0x04AF, 0x04B1, 0x04B3, 0x04B5, 0x04B7, 0x04B9, 0x04BB, 0x04BD, 0x04BF, 0x04C4, 0x04C6, 0x04C8, 0x04CA, 0x04CC, 0x04CE, 0x04D1, 0x04D3, 0x04D5, 0x04D7, 0x04D9, 0x04DB, 0x04DD, 0x04DF, 0x04E1, 0x04E3, 0x04E5, 0x04E7, 0x04E9, 0x04EB, 0x04ED, 0x04EF, 0x04F1, 0x04F3, 0x04F5, 0x04F7, 0x04F9, 0x04FB, 0x04FD, 0x04FF, 0x0501, 0x0503, 0x0505, 0x0507, 0x0509, 0x050B, 0x050D, 0x050F, 0x0511, 0x0513, 0x0515, 0x0517, 0x0519, 0x051B, 0x051D, 0x051F, 0x0521, 0x0523, 0x0525, 0x0527, 0x0529, 0x052B, 0x052D, 0x052F, 0x0565, 0x0582, 0x2D27, 0x2D2D, 0x1E01, 0x1E03, 0x1E05, 0x1E07, 0x1E09, 0x1E0B, 0x1E0D, 0x1E0F, 0x1E11, 0x1E13, 0x1E15, 0x1E17, 0x1E19, 0x1E1B, 0x1E1D, 0x1E1F, 0x1E21, 0x1E23, 0x1E25, 0x1E27, 0x1E29, 0x1E2B, 0x1E2D, 0x1E2F, 0x1E31, 0x1E33, 0x1E35, 0x1E37, 0x1E39, 0x1E3B, 0x1E3D, 0x1E3F, 0x1E41, 0x1E43, 0x1E45, 0x1E47, 0x1E49, 0x1E4B, 0x1E4D, 0x1E4F, 0x1E51, 0x1E53, 0x1E55, 0x1E57, 0x1E59, 0x1E5B, 0x1E5D, 0x1E5F, 0x1E61, 0x1E63, 0x1E65, 0x1E67, 0x1E69, 0x1E6B, 0x1E6D, 0x1E6F, 0x1E71, 0x1E73, 0x1E75, 0x1E77, 0x1E79, 0x1E7B, 0x1E7D, 0x1E7F, 0x1E81, 0x1E83, 0x1E85, 0x1E87, 0x1E89, 0x1E8B, 0x1E8D, 0x1E8F, 0x1E91, 0x1E93, 0x1E95, 0x73, 0x73, 0x1EA1, 0x1EA3, 0x1EA5, 0x1EA7, 0x1EA9, 0x1EAB, 0x1EAD, 0x1EAF, 0x1EB1, 0x1EB3, 0x1EB5, 0x1EB7, 0x1EB9, 0x1EBB, 0x1EBD, 0x1EBF, 0x1EC1, 0x1EC3, 0x1EC5, 0x1EC7, 0x1EC9, 0x1ECB, 0x1ECD, 0x1ECF, 0x1ED1, 0x1ED3, 0x1ED5, 0x1ED7, 0x1ED9, 0x1EDB, 0x1EDD, 0x1EDF, 0x1EE1, 0x1EE3, 0x1EE5, 0x1EE7, 0x1EE9, 0x1EEB, 0x1EED, 0x1EEF, 0x1EF1, 0x1EF3, 0x1EF5, 0x1EF7, 0x1EF9, 0x1EFB, 0x1EFD, 0x1EFF, 0x03C5, 0x0313, 0x03C5, 0x0313, 0x0300, 0x03C5, 0x0313, 0x0301, 0x03C5, 0x0313, 0x0342, 0x1F51, 0x1F53, 0x1F55, 0x1F57, 0x03C9, 0x214E, 0x2184, 0x2C61, 0x2C68, 0x2C6A, 0x2C6C, 0x2C73, 0x2C76, 0x2C83, 0x2C85, 0x2C87, 0x2C89, 0x2C8B, 0x2C8D, 0x2C8F, 0x2C91, 0x2C93, 0x2C95, 0x2C97, 0x2C99, 0x2C9B, 0x2C9D, 0x2C9F, 0x2CA1, 0x2CA3, 0x2CA5, 0x2CA7, 0x2CA9, 0x2CAB, 0x2CAD, 0x2CAF, 0x2CB1, 0x2CB3, 0x2CB5, 0x2CB7, 0x2CB9, 0x2CBB, 0x2CBD, 0x2CBF, 0x2CC1, 0x2CC3, 0x2CC5, 0x2CC7, 0x2CC9, 0x2CCB, 0x2CCD, 0x2CCF, 0x2CD1, 0x2CD3, 0x2CD5, 0x2CD7, 0x2CD9, 0x2CDB, 0x2CDD, 0x2CDF, 0x2CE1, 0x2CE3, 0x2CEC, 0x2CEE, 0x2CF3, 0xA641, 0xA643, 0xA645, 0xA647, 0xA649, 0xA64B, 0xA64D, 0xA64F, 0xA651, 0xA653, 0xA655, 0xA657, 0xA659, 0xA65B, 0xA65D, 0xA65F, 0xA661, 0xA663, 0xA665, 0xA667, 0xA669, 0xA66B, 0xA66D, 0xA681, 0xA683, 0xA685, 0xA687, 0xA689, 0xA68B, 0xA68D, 0xA68F, 0xA691, 0xA693, 0xA695, 0xA697, 0xA699, 0xA69B, 0xA723, 0xA725, 0xA727, 0xA729, 0xA72B, 0xA72D, 0xA72F, 0xA733, 0xA735, 0xA737, 0xA739, 0xA73B, 0xA73D, 0xA73F, 0xA741, 0xA743, 0xA745, 0xA747, 0xA749, 0xA74B, 0xA74D, 0xA74F, 0xA751, 0xA753, 0xA755, 0xA757, 0xA759, 0xA75B, 0xA75D, 0xA75F, 0xA761, 0xA763, 0xA765, 0xA767, 0xA769, 0xA76B, 0xA76D, 0xA76F, 0xA77A, 0xA77C, 0xA781, 0xA783, 0xA785, 0xA787, 0xA78C, 0x0265, 0xA791, 0xA793, 0xA797, 0xA799, 0xA79B, 0xA79D, 0xA79F, 0xA7A1, 0xA7A3, 0xA7A5, 0xA7A7, 0xA7A9, 0xA7B7, 0xA7B9, 0xA7BB, 0xA7BD, 0xA7BF, 0xA7C1, 0xA7C3, 0xA7CA, 0xA7D1, 0xA7D7, 0xA7D9, 0xA7F6, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xD7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF, 0x017A, 0x0253, 0x0183, 0x0254, 0x0188, 0x0256, 0x0257, 0x018C, 0x018D, 0x01DD, 0x0259, 0x025B, 0x0192, 0x0260, 0x0263, 0x0195, 0x0269, 0x0268, 0x0199, 0x019A, 0x019B, 0x026F, 0x0272, 0x0275, 0x01A1, 0x0280, 0x01A8, 0x0288, 0x01B0, 0x028A, 0x028B, 0x01B4, 0x0292, 0x01B9, 0x01BF, 0x01F9, 0x2C65, 0x023C, 0x2C66, 0x0180, 0x0289, 0x028C, 0x0247, 0x03AD, 0x03AE, 0x03AF, 0x03CD, 0x03CE, 0x03B9, 0x0308, 0x0301, 0x03B1, 0x03B2, 0x03B3, 0x03B4, 0x03B5, 0x03B6, 0x03B7, 0x03B8, 0x03BA, 0x03BB, 0x03BD, 0x03BE, 0x03BF, 0x03C0, 0x03C1, 0x03A2, 0x03C4, 0x03C5, 0x03C6, 0x03C7, 0x03C8, 0x03CA, 0x03CB, 0x03D7, 0x03D2, 0x03D3, 0x03D4, 0x03F2, 0x03FB, 0x03FC, 0x037B, 0x037C, 0x037D, 0x0450, 0x0451, 0x0452, 0x0453, 0x0454, 0x0455, 0x0456, 0x0457, 0x0458, 0x0459, 0x045A, 0x045B, 0x045C, 0x045D, 0x045E, 0x045F, 0x0430, 0x0431, 0x0432, 0x0433, 0x0434, 0x0435, 0x0436, 0x0437, 0x0438, 0x0439, 0x043A, 0x043B, 0x043C, 0x043D, 0x043E, 0x043F, 0x0440, 0x0441, 0x0442, 0x0443, 0x0444, 0x0445, 0x0446, 0x0447, 0x0448, 0x0449, 0x044A, 0x044B, 0x044C, 0x044D, 0x044E, 0x044F, 0x04CF, 0x04C2, 0x0561, 0x0562, 0x0563, 0x0564, 0x0565, 0x0566, 0x0567, 0x0568, 0x0569, 0x056A, 0x056B, 0x056C, 0x056D, 0x056E, 0x056F, 0x0570, 0x0571, 0x0572, 0x0573, 0x0574, 0x0575, 0x0576, 0x0577, 0x0578, 0x0579, 0x057A, 0x057B, 0x057C, 0x057D, 0x057E, 0x057F, 0x0580, 0x0581, 0x0582, 0x0583, 0x0584, 0x0585, 0x0586, 0x2D00, 0x2D01, 0x2D02, 0x2D03, 0x2D04, 0x2D05, 0x2D06, 0x2D07, 0x2D08, 0x2D09, 0x2D0A, 0x2D0B, 0x2D0C, 0x2D0D, 0x2D0E, 0x2D0F, 0x2D10, 0x2D11, 0x2D12, 0x2D13, 0x2D14, 0x2D15, 0x2D16, 0x2D17, 0x2D18, 0x2D19, 0x2D1A, 0x2D1B, 0x2D1C, 0x2D1D, 0x2D1E, 0x2D1F, 0x2D20, 0x2D21, 0x2D22, 0x2D23, 0x2D24, 0x2D25, 0x13F0, 0x13F1, 0x13F2, 0x13F3, 0x13F4, 0x13F5, 0x10D0, 0x10D1, 0x10D2, 0x10D3, 0x10D4, 0x10D5, 0x10D6, 0x10D7, 0x10D8, 0x10D9, 0x10DA, 0x10DB, 0x10DC, 0x10DD, 0x10DE, 0x10DF, 0x10E0, 0x10E1, 0x10E2, 0x10E3, 0x10E4, 0x10E5, 0x10E6, 0x10E7, 0x10E8, 0x10E9, 0x10EA, 0x10EB, 0x10EC, 0x10ED, 0x10EE, 0x10EF, 0x10F0, 0x10F1, 0x10F2, 0x10F3, 0x10F4, 0x10F5, 0x10F6, 0x10F7, 0x10F8, 0x10F9, 0x10FA, 0x1CBB, 0x1CBC, 0x10FD, 0x10FE, 0x10FF, 0x68, 0x0331, 0x74, 0x0308, 0x77, 0x030A, 0x79, 0x030A, 0x61, 0x02BE, 0x1F00, 0x1F01, 0x1F02, 0x1F03, 0x1F04, 0x1F05, 0x1F06, 0x1F07, 0x1F10, 0x1F11, 0x1F12, 0x1F13, 0x1F14, 0x1F15, 0x1F20, 0x1F21, 0x1F22, 0x1F23, 0x1F24, 0x1F25, 0x1F26, 0x1F27, 0x1F30, 0x1F31, 0x1F32, 0x1F33, 0x1F34, 0x1F35, 0x1F36, 0x1F37, 0x1F40, 0x1F41, 0x1F42, 0x1F43, 0x1F44, 0x1F45, 0x1F60, 0x1F61, 0x1F62, 0x1F63, 0x1F64, 0x1F65, 0x1F66, 0x1F67, 0x1F00, 0x03B9, 0x1F01, 0x03B9, 0x1F02, 0x03B9, 0x1F03, 0x03B9, 0x1F04, 0x03B9, 0x1F05, 0x03B9, 0x1F06, 0x03B9, 0x1F07, 0x03B9, 0x1F20, 0x03B9, 0x1F21, 0x03B9, 0x1F22, 0x03B9, 0x1F23, 0x03B9, 0x1F24, 0x03B9, 0x1F25, 0x03B9, 0x1F26, 0x03B9, 0x1F27, 0x03B9, 0x1F60, 0x03B9, 0x1F61, 0x03B9, 0x1F62, 0x03B9, 0x1F63, 0x03B9, 0x1F64, 0x03B9, 0x1F65, 0x03B9, 0x1F66, 0x03B9, 0x1F67, 0x03B9, 0x1FB0, 0x1FB1, 0x1F70, 0x03B9, 0x03B1, 0x03B9, 0x03AC, 0x03B9, 0x1FB5, 0x03B1, 0x0342, 0x03B1, 0x0342, 0x03B9, 0x1F70, 0x1F71, 0x1F74, 0x03B9, 0x03B7, 0x03B9, 0x03AE, 0x03B9, 0x1FC5, 0x03B7, 0x0342, 0x03B7, 0x0342, 0x03B9, 0x1F72, 0x1F73, 0x1F74, 0x1F75, 0x03B9, 0x0308, 0x0300, 0x1FD4, 0x1FD5, 0x03B9, 0x0342, 0x03B9, 0x0308, 0x0342, 0x1FD0, 0x1FD1, 0x1F76, 0x1F77, 0x03C5, 0x0308, 0x0300, 0x03C1, 0x0313, 0x1FE5, 0x03C5, 0x0342, 0x03C5, 0x0308, 0x0342, 0x1FE0, 0x1FE1, 0x1F7A, 0x1F7B, 0x1F7C, 0x03B9, 0x03C9, 0x03B9, 0x03CE, 0x03B9, 0x1FF5, 0x03C9, 0x0342, 0x03C9, 0x0342, 0x03B9, 0x1F78, 0x1F79, 0x1F7C, 0x1F7D, 0x2170, 0x2171, 0x2172, 0x2173, 0x2174, 0x2175, 0x2176, 0x2177, 0x2178, 0x2179, 0x217A, 0x217B, 0x217C, 0x217D, 0x217E, 0x217F, 0x24D0, 0x24D1, 0x24D2, 0x24D3, 0x24D4, 0x24D5, 0x24D6, 0x24D7, 0x24D8, 0x24D9, 0x24DA, 0x24DB, 0x24DC, 0x24DD, 0x24DE, 0x24DF, 0x24E0, 0x24E1, 0x24E2, 0x24E3, 0x24E4, 0x24E5, 0x24E6, 0x24E7, 0x24E8, 0x24E9, 0x2C30, 0x2C31, 0x2C32, 0x2C33, 0x2C34, 0x2C35, 0x2C36, 0x2C37, 0x2C38, 0x2C39, 0x2C3A, 0x2C3B, 0x2C3C, 0x2C3D, 0x2C3E, 0x2C3F, 0x2C40, 0x2C41, 0x2C42, 0x2C43, 0x2C44, 0x2C45, 0x2C46, 0x2C47, 0x2C48, 0x2C49, 0x2C4A, 0x2C4B, 0x2C4C, 0x2C4D, 0x2C4E, 0x2C4F, 0x2C50, 0x2C51, 0x2C52, 0x2C53, 0x2C54, 0x2C55, 0x2C56, 0x2C57, 0x2C58, 0x2C59, 0x2C5A, 0x2C5B, 0x2C5C, 0x2C5D, 0x2C5E, 0x2C5F, 0x026B, 0x1D7D, 0x027D, 0x0251, 0x0271, 0x0250, 0x0252, 0x023F, 0x0240, 0x2C81, 0x1D79, 0xA77F, 0x0266, 0x025C, 0x0261, 0x026C, 0x026A, 0xA7AF, 0x029E, 0x0287, 0x029D, 0xAB53, 0xA7B5, 0xA794, 0x0282, 0x1D8E, 0xA7C8, 0x13A0, 0x13A1, 0x13A2, 0x13A3, 0x13A4, 0x13A5, 0x13A6, 0x13A7, 0x13A8, 0x13A9, 0x13AA, 0x13AB, 0x13AC, 0x13AD, 0x13AE, 0x13AF, 0x13B0, 0x13B1, 0x13B2, 0x13B3, 0x13B4, 0x13B5, 0x13B6, 0x13B7, 0x13B8, 0x13B9, 0x13BA, 0x13BB, 0x13BC, 0x13BD, 0x13BE, 0x13BF, 0x13C0, 0x13C1, 0x13C2, 0x13C3, 0x13C4, 0x13C5, 0x13C6, 0x13C7, 0x13C8, 0x13C9, 0x13CA, 0x13CB, 0x13CC, 0x13CD, 0x13CE, 0x13CF, 0x13D0, 0x13D1, 0x13D2, 0x13D3, 0x13D4, 0x13D5, 0x13D6, 0x13D7, 0x13D8, 0x13D9, 0x13DA, 0x13DB, 0x13DC, 0x13DD, 0x13DE, 0x13DF, 0x13E0, 0x13E1, 0x13E2, 0x13E3, 0x13E4, 0x13E5, 0x13E6, 0x13E7, 0x13E8, 0x13E9, 0x13EA, 0x13EB, 0x13EC, 0x13ED, 0x13EE, 0x13EF, 0x66, 0x66, 0x66, 0x69, 0x66, 0x6C, 0x66, 0x66, 0x69, 0x66, 0x66, 0x6C, 0x73, 0x74, 0x0574, 0x0576, 0x0574, 0x0565, 0x0574, 0x056B, 0x057E, 0x0576, 0x0574, 0x056D, 0xFF41, 0xFF42, 0xFF43, 0xFF44, 0xFF45, 0xFF46, 0xFF47, 0xFF48, 0xFF49, 0xFF4A, 0xFF4B, 0xFF4C, 0xFF4D, 0xFF4E, 0xFF4F, 0xFF50, 0xFF51, 0xFF52, 0xFF53, 0xFF54, 0xFF55, 0xFF56, 0xFF57, 0xFF58, 0xFF59, 0xFF5A, 0x00010428, 0x00010429, 0x0001042A, 0x0001042B, 0x0001042C, 0x0001042D, 0x0001042E, 0x0001042F, 0x00010430, 0x00010431, 0x00010432, 0x00010433, 0x00010434, 0x00010435, 0x00010436, 0x00010437, 0x00010438, 0x00010439, 0x0001043A, 0x0001043B, 0x0001043C, 0x0001043D, 0x0001043E, 0x0001043F, 0x00010440, 0x00010441, 0x00010442, 0x00010443, 0x00010444, 0x00010445, 0x00010446, 0x00010447, 0x00010448, 0x00010449, 0x0001044A, 0x0001044B, 0x0001044C, 0x0001044D, 0x0001044E, 0x0001044F, 0x000104D8, 0x000104D9, 0x000104DA, 0x000104DB, 0x000104DC, 0x000104DD, 0x000104DE, 0x000104DF, 0x000104E0, 0x000104E1, 0x000104E2, 0x000104E3, 0x000104E4, 0x000104E5, 0x000104E6, 0x000104E7, 0x000104E8, 0x000104E9, 0x000104EA, 0x000104EB, 0x000104EC, 0x000104ED, 0x000104EE, 0x000104EF, 0x000104F0, 0x000104F1, 0x000104F2, 0x000104F3, 0x000104F4, 0x000104F5, 0x000104F6, 0x000104F7, 0x000104F8, 0x000104F9, 0x000104FA, 0x000104FB, 0x00010597, 0x00010598, 0x00010599, 0x0001059A, 0x0001059B, 0x0001059C, 0x0001059D, 0x0001059E, 0x0001059F, 0x000105A0, 0x000105A1, 0x0001057B, 0x000105A3, 0x000105A4, 0x000105A5, 0x000105A6, 0x000105A7, 0x000105A8, 0x000105A9, 0x000105AA, 0x000105AB, 0x000105AC, 0x000105AD, 0x000105AE, 0x000105AF, 0x000105B0, 0x000105B1, 0x0001058B, 0x000105B3, 0x000105B4, 0x000105B5, 0x000105B6, 0x000105B7, 0x000105B8, 0x000105B9, 0x00010593, 0x000105BB, 0x000105BC, 0x00010CC0, 0x00010CC1, 0x00010CC2, 0x00010CC3, 0x00010CC4, 0x00010CC5, 0x00010CC6, 0x00010CC7, 0x00010CC8, 0x00010CC9, 0x00010CCA, 0x00010CCB, 0x00010CCC, 0x00010CCD, 0x00010CCE, 0x00010CCF, 0x00010CD0, 0x00010CD1, 0x00010CD2, 0x00010CD3, 0x00010CD4, 0x00010CD5, 0x00010CD6, 0x00010CD7, 0x00010CD8, 0x00010CD9, 0x00010CDA, 0x00010CDB, 0x00010CDC, 0x00010CDD, 0x00010CDE, 0x00010CDF, 0x00010CE0, 0x00010CE1, 0x00010CE2, 0x00010CE3, 0x00010CE4, 0x00010CE5, 0x00010CE6, 0x00010CE7, 0x00010CE8, 0x00010CE9, 0x00010CEA, 0x00010CEB, 0x00010CEC, 0x00010CED, 0x00010CEE, 0x00010CEF, 0x00010CF0, 0x00010CF1, 0x00010CF2, 0x000118C0, 0x000118C1, 0x000118C2, 0x000118C3, 0x000118C4, 0x000118C5, 0x000118C6, 0x000118C7, 0x000118C8, 0x000118C9, 0x000118CA, 0x000118CB, 0x000118CC, 0x000118CD, 0x000118CE, 0x000118CF, 0x000118D0, 0x000118D1, 0x000118D2, 0x000118D3, 0x000118D4, 0x000118D5, 0x000118D6, 0x000118D7, 0x000118D8, 0x000118D9, 0x000118DA, 0x000118DB, 0x000118DC, 0x000118DD, 0x000118DE, 0x000118DF, 0x00016E60, 0x00016E61, 0x00016E62, 0x00016E63, 0x00016E64, 0x00016E65, 0x00016E66, 0x00016E67, 0x00016E68, 0x00016E69, 0x00016E6A, 0x00016E6B, 0x00016E6C, 0x00016E6D, 0x00016E6E, 0x00016E6F, 0x00016E70, 0x00016E71, 0x00016E72, 0x00016E73, 0x00016E74, 0x00016E75, 0x00016E76, 0x00016E77, 0x00016E78, 0x00016E79, 0x00016E7A, 0x00016E7B, 0x00016E7C, 0x00016E7D, 0x00016E7E, 0x00016E7F, 0x0001E922, 0x0001E923, 0x0001E924, 0x0001E925, 0x0001E926, 0x0001E927, 0x0001E928, 0x0001E929, 0x0001E92A, 0x0001E92B, 0x0001E92C, 0x0001E92D, 0x0001E92E, 0x0001E92F, 0x0001E930, 0x0001E931, 0x0001E932, 0x0001E933, 0x0001E934, 0x0001E935, 0x0001E936, 0x0001E937, 0x0001E938, 0x0001E939, 0x0001E93A, 0x0001E93B, 0x0001E93C, 0x0001E93D, 0x0001E93E, 0x0001E93F, 0x0001E940, 0x0001E941, 0x0001E942, 0x0001E943, ];
}

export extern(C) immutable(dstring) sidero_utf_lut_getCaseFoldingTurkic(dchar input) @trusted nothrow @nogc pure {
    if (input == 0x49)
        return cast(dstring)LUT_275E17A6_DString[0 .. 1];
    else if (input == 0x130)
        return cast(dstring)LUT_275E17A6_DString[1 .. 2];
    return null;
}
private {
    static immutable dstring LUT_275E17A6_DString = cast(dstring)[cast(uint)0x0131, 0x69, ];
}

export extern(C) immutable(dchar) sidero_utf_lut_getCaseFoldingFast(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x41 && input <= 0xFF3A) {
        if (input <= 0x2CF2) {
            if (input <= 0x5A)
                return cast(dchar)LUT_25074147[cast(size_t)(0 + (input - 0x41))];
            else if (input == 0xB5)
                return cast(dchar)0x3BC;
            else if (input >= 0xC0 && input <= 0xDE)
                return cast(dchar)LUT_25074147[cast(size_t)(26 + (input - 0xC0))];
            else if (input == 0x100)
                return cast(dchar)0x101;
            else if (input == 0x102)
                return cast(dchar)0x103;
            else if (input == 0x104)
                return cast(dchar)0x105;
            else if (input == 0x106)
                return cast(dchar)0x107;
            else if (input == 0x108)
                return cast(dchar)0x109;
            else if (input == 0x10A)
                return cast(dchar)0x10B;
            else if (input == 0x10C)
                return cast(dchar)0x10D;
            else if (input == 0x10E)
                return cast(dchar)0x10F;
            else if (input == 0x110)
                return cast(dchar)0x111;
            else if (input == 0x112)
                return cast(dchar)0x113;
            else if (input == 0x114)
                return cast(dchar)0x115;
            else if (input == 0x116)
                return cast(dchar)0x117;
            else if (input == 0x118)
                return cast(dchar)0x119;
            else if (input == 0x11A)
                return cast(dchar)0x11B;
            else if (input == 0x11C)
                return cast(dchar)0x11D;
            else if (input == 0x11E)
                return cast(dchar)0x11F;
            else if (input == 0x120)
                return cast(dchar)0x121;
            else if (input == 0x122)
                return cast(dchar)0x123;
            else if (input == 0x124)
                return cast(dchar)0x125;
            else if (input == 0x126)
                return cast(dchar)0x127;
            else if (input == 0x128)
                return cast(dchar)0x129;
            else if (input == 0x12A)
                return cast(dchar)0x12B;
            else if (input == 0x12C)
                return cast(dchar)0x12D;
            else if (input == 0x12E)
                return cast(dchar)0x12F;
            else if (input == 0x132)
                return cast(dchar)0x133;
            else if (input == 0x134)
                return cast(dchar)0x135;
            else if (input == 0x136)
                return cast(dchar)0x137;
            else if (input == 0x139)
                return cast(dchar)0x13A;
            else if (input == 0x13B)
                return cast(dchar)0x13C;
            else if (input == 0x13D)
                return cast(dchar)0x13E;
            else if (input == 0x13F)
                return cast(dchar)0x140;
            else if (input == 0x141)
                return cast(dchar)0x142;
            else if (input == 0x143)
                return cast(dchar)0x144;
            else if (input == 0x145)
                return cast(dchar)0x146;
            else if (input == 0x147)
                return cast(dchar)0x148;
            else if (input == 0x14A)
                return cast(dchar)0x14B;
            else if (input == 0x14C)
                return cast(dchar)0x14D;
            else if (input == 0x14E)
                return cast(dchar)0x14F;
            else if (input == 0x150)
                return cast(dchar)0x151;
            else if (input == 0x152)
                return cast(dchar)0x153;
            else if (input == 0x154)
                return cast(dchar)0x155;
            else if (input == 0x156)
                return cast(dchar)0x157;
            else if (input == 0x158)
                return cast(dchar)0x159;
            else if (input == 0x15A)
                return cast(dchar)0x15B;
            else if (input == 0x15C)
                return cast(dchar)0x15D;
            else if (input == 0x15E)
                return cast(dchar)0x15F;
            else if (input == 0x160)
                return cast(dchar)0x161;
            else if (input == 0x162)
                return cast(dchar)0x163;
            else if (input == 0x164)
                return cast(dchar)0x165;
            else if (input == 0x166)
                return cast(dchar)0x167;
            else if (input == 0x168)
                return cast(dchar)0x169;
            else if (input == 0x16A)
                return cast(dchar)0x16B;
            else if (input == 0x16C)
                return cast(dchar)0x16D;
            else if (input == 0x16E)
                return cast(dchar)0x16F;
            else if (input == 0x170)
                return cast(dchar)0x171;
            else if (input == 0x172)
                return cast(dchar)0x173;
            else if (input == 0x174)
                return cast(dchar)0x175;
            else if (input == 0x176)
                return cast(dchar)0x177;
            else if (input >= 0x178 && input <= 0x179)
                return cast(dchar)LUT_25074147[cast(size_t)(57 + (input - 0x178))];
            else if (input == 0x17B)
                return cast(dchar)0x17C;
            else if (input == 0x17D)
                return cast(dchar)0x17E;
            else if (input == 0x17F)
                return cast(dchar)0x73;
            else if (input >= 0x181 && input <= 0x182)
                return cast(dchar)LUT_25074147[cast(size_t)(59 + (input - 0x181))];
            else if (input == 0x184)
                return cast(dchar)0x185;
            else if (input >= 0x186 && input <= 0x1A0)
                return cast(dchar)LUT_25074147[cast(size_t)(61 + (input - 0x186))];
            else if (input == 0x1A2)
                return cast(dchar)0x1A3;
            else if (input == 0x1A4)
                return cast(dchar)0x1A5;
            else if (input >= 0x1A6 && input <= 0x1A7)
                return cast(dchar)LUT_25074147[cast(size_t)(88 + (input - 0x1A6))];
            else if (input == 0x1A9)
                return cast(dchar)0x283;
            else if (input == 0x1AC)
                return cast(dchar)0x1AD;
            else if (input >= 0x1AE && input <= 0x1B3)
                return cast(dchar)LUT_25074147[cast(size_t)(90 + (input - 0x1AE))];
            else if (input == 0x1B5)
                return cast(dchar)0x1B6;
            else if (input >= 0x1B7 && input <= 0x1B8)
                return cast(dchar)LUT_25074147[cast(size_t)(96 + (input - 0x1B7))];
            else if (input == 0x1BC)
                return cast(dchar)0x1BD;
            else if (input >= 0x1C4 && input <= 0x1C5)
                return cast(dchar)0x1C6;
            else if (input >= 0x1C7 && input <= 0x1C8)
                return cast(dchar)0x1C9;
            else if (input >= 0x1CA && input <= 0x1CB)
                return cast(dchar)0x1CC;
            else if (input == 0x1CD)
                return cast(dchar)0x1CE;
            else if (input == 0x1CF)
                return cast(dchar)0x1D0;
            else if (input == 0x1D1)
                return cast(dchar)0x1D2;
            else if (input == 0x1D3)
                return cast(dchar)0x1D4;
            else if (input == 0x1D5)
                return cast(dchar)0x1D6;
            else if (input == 0x1D7)
                return cast(dchar)0x1D8;
            else if (input == 0x1D9)
                return cast(dchar)0x1DA;
            else if (input == 0x1DB)
                return cast(dchar)0x1DC;
            else if (input == 0x1DE)
                return cast(dchar)0x1DF;
            else if (input == 0x1E0)
                return cast(dchar)0x1E1;
            else if (input == 0x1E2)
                return cast(dchar)0x1E3;
            else if (input == 0x1E4)
                return cast(dchar)0x1E5;
            else if (input == 0x1E6)
                return cast(dchar)0x1E7;
            else if (input == 0x1E8)
                return cast(dchar)0x1E9;
            else if (input == 0x1EA)
                return cast(dchar)0x1EB;
            else if (input == 0x1EC)
                return cast(dchar)0x1ED;
            else if (input == 0x1EE)
                return cast(dchar)0x1EF;
            else if (input >= 0x1F1 && input <= 0x1F2)
                return cast(dchar)0x1F3;
            else if (input == 0x1F4)
                return cast(dchar)0x1F5;
            else if (input >= 0x1F6 && input <= 0x1F8)
                return cast(dchar)LUT_25074147[cast(size_t)(98 + (input - 0x1F6))];
            else if (input == 0x1FA)
                return cast(dchar)0x1FB;
            else if (input == 0x1FC)
                return cast(dchar)0x1FD;
            else if (input == 0x1FE)
                return cast(dchar)0x1FF;
            else if (input == 0x200)
                return cast(dchar)0x201;
            else if (input == 0x202)
                return cast(dchar)0x203;
            else if (input == 0x204)
                return cast(dchar)0x205;
            else if (input == 0x206)
                return cast(dchar)0x207;
            else if (input == 0x208)
                return cast(dchar)0x209;
            else if (input == 0x20A)
                return cast(dchar)0x20B;
            else if (input == 0x20C)
                return cast(dchar)0x20D;
            else if (input == 0x20E)
                return cast(dchar)0x20F;
            else if (input == 0x210)
                return cast(dchar)0x211;
            else if (input == 0x212)
                return cast(dchar)0x213;
            else if (input == 0x214)
                return cast(dchar)0x215;
            else if (input == 0x216)
                return cast(dchar)0x217;
            else if (input == 0x218)
                return cast(dchar)0x219;
            else if (input == 0x21A)
                return cast(dchar)0x21B;
            else if (input == 0x21C)
                return cast(dchar)0x21D;
            else if (input == 0x21E)
                return cast(dchar)0x21F;
            else if (input == 0x220)
                return cast(dchar)0x19E;
            else if (input == 0x222)
                return cast(dchar)0x223;
            else if (input == 0x224)
                return cast(dchar)0x225;
            else if (input == 0x226)
                return cast(dchar)0x227;
            else if (input == 0x228)
                return cast(dchar)0x229;
            else if (input == 0x22A)
                return cast(dchar)0x22B;
            else if (input == 0x22C)
                return cast(dchar)0x22D;
            else if (input == 0x22E)
                return cast(dchar)0x22F;
            else if (input == 0x230)
                return cast(dchar)0x231;
            else if (input == 0x232)
                return cast(dchar)0x233;
            else if (input >= 0x23A && input <= 0x23E)
                return cast(dchar)LUT_25074147[cast(size_t)(101 + (input - 0x23A))];
            else if (input == 0x241)
                return cast(dchar)0x242;
            else if (input >= 0x243 && input <= 0x246)
                return cast(dchar)LUT_25074147[cast(size_t)(106 + (input - 0x243))];
            else if (input == 0x248)
                return cast(dchar)0x249;
            else if (input == 0x24A)
                return cast(dchar)0x24B;
            else if (input == 0x24C)
                return cast(dchar)0x24D;
            else if (input == 0x24E)
                return cast(dchar)0x24F;
            else if (input == 0x345)
                return cast(dchar)0x3B9;
            else if (input == 0x370)
                return cast(dchar)0x371;
            else if (input == 0x372)
                return cast(dchar)0x373;
            else if (input == 0x376)
                return cast(dchar)0x377;
            else if (input == 0x37F)
                return cast(dchar)0x3F3;
            else if (input == 0x386)
                return cast(dchar)0x3AC;
            else if (input >= 0x388 && input <= 0x38A)
                return cast(dchar)LUT_25074147[cast(size_t)(110 + (input - 0x388))];
            else if (input == 0x38C)
                return cast(dchar)0x3CC;
            else if (input >= 0x38E && input <= 0x3AB)
                return cast(dchar)LUT_25074147[cast(size_t)(113 + (input - 0x38E))];
            else if (input == 0x3C2)
                return cast(dchar)0x3C3;
            else if (input >= 0x3CF && input <= 0x3D6)
                return cast(dchar)LUT_25074147[cast(size_t)(143 + (input - 0x3CF))];
            else if (input == 0x3D8)
                return cast(dchar)0x3D9;
            else if (input == 0x3DA)
                return cast(dchar)0x3DB;
            else if (input == 0x3DC)
                return cast(dchar)0x3DD;
            else if (input == 0x3DE)
                return cast(dchar)0x3DF;
            else if (input == 0x3E0)
                return cast(dchar)0x3E1;
            else if (input == 0x3E2)
                return cast(dchar)0x3E3;
            else if (input == 0x3E4)
                return cast(dchar)0x3E5;
            else if (input == 0x3E6)
                return cast(dchar)0x3E7;
            else if (input == 0x3E8)
                return cast(dchar)0x3E9;
            else if (input == 0x3EA)
                return cast(dchar)0x3EB;
            else if (input == 0x3EC)
                return cast(dchar)0x3ED;
            else if (input == 0x3EE)
                return cast(dchar)0x3EF;
            else if (input >= 0x3F0 && input <= 0x3F5)
                return cast(dchar)LUT_25074147[cast(size_t)(151 + (input - 0x3F0))];
            else if (input == 0x3F7)
                return cast(dchar)0x3F8;
            else if (input >= 0x3F9 && input <= 0x42F)
                return cast(dchar)LUT_25074147[cast(size_t)(157 + (input - 0x3F9))];
            else if (input == 0x460)
                return cast(dchar)0x461;
            else if (input == 0x462)
                return cast(dchar)0x463;
            else if (input == 0x464)
                return cast(dchar)0x465;
            else if (input == 0x466)
                return cast(dchar)0x467;
            else if (input == 0x468)
                return cast(dchar)0x469;
            else if (input == 0x46A)
                return cast(dchar)0x46B;
            else if (input == 0x46C)
                return cast(dchar)0x46D;
            else if (input == 0x46E)
                return cast(dchar)0x46F;
            else if (input == 0x470)
                return cast(dchar)0x471;
            else if (input == 0x472)
                return cast(dchar)0x473;
            else if (input == 0x474)
                return cast(dchar)0x475;
            else if (input == 0x476)
                return cast(dchar)0x477;
            else if (input == 0x478)
                return cast(dchar)0x479;
            else if (input == 0x47A)
                return cast(dchar)0x47B;
            else if (input == 0x47C)
                return cast(dchar)0x47D;
            else if (input == 0x47E)
                return cast(dchar)0x47F;
            else if (input == 0x480)
                return cast(dchar)0x481;
            else if (input == 0x48A)
                return cast(dchar)0x48B;
            else if (input == 0x48C)
                return cast(dchar)0x48D;
            else if (input == 0x48E)
                return cast(dchar)0x48F;
            else if (input == 0x490)
                return cast(dchar)0x491;
            else if (input == 0x492)
                return cast(dchar)0x493;
            else if (input == 0x494)
                return cast(dchar)0x495;
            else if (input == 0x496)
                return cast(dchar)0x497;
            else if (input == 0x498)
                return cast(dchar)0x499;
            else if (input == 0x49A)
                return cast(dchar)0x49B;
            else if (input == 0x49C)
                return cast(dchar)0x49D;
            else if (input == 0x49E)
                return cast(dchar)0x49F;
            else if (input == 0x4A0)
                return cast(dchar)0x4A1;
            else if (input == 0x4A2)
                return cast(dchar)0x4A3;
            else if (input == 0x4A4)
                return cast(dchar)0x4A5;
            else if (input == 0x4A6)
                return cast(dchar)0x4A7;
            else if (input == 0x4A8)
                return cast(dchar)0x4A9;
            else if (input == 0x4AA)
                return cast(dchar)0x4AB;
            else if (input == 0x4AC)
                return cast(dchar)0x4AD;
            else if (input == 0x4AE)
                return cast(dchar)0x4AF;
            else if (input == 0x4B0)
                return cast(dchar)0x4B1;
            else if (input == 0x4B2)
                return cast(dchar)0x4B3;
            else if (input == 0x4B4)
                return cast(dchar)0x4B5;
            else if (input == 0x4B6)
                return cast(dchar)0x4B7;
            else if (input == 0x4B8)
                return cast(dchar)0x4B9;
            else if (input == 0x4BA)
                return cast(dchar)0x4BB;
            else if (input == 0x4BC)
                return cast(dchar)0x4BD;
            else if (input == 0x4BE)
                return cast(dchar)0x4BF;
            else if (input >= 0x4C0 && input <= 0x4C1)
                return cast(dchar)LUT_25074147[cast(size_t)(212 + (input - 0x4C0))];
            else if (input == 0x4C3)
                return cast(dchar)0x4C4;
            else if (input == 0x4C5)
                return cast(dchar)0x4C6;
            else if (input == 0x4C7)
                return cast(dchar)0x4C8;
            else if (input == 0x4C9)
                return cast(dchar)0x4CA;
            else if (input == 0x4CB)
                return cast(dchar)0x4CC;
            else if (input == 0x4CD)
                return cast(dchar)0x4CE;
            else if (input == 0x4D0)
                return cast(dchar)0x4D1;
            else if (input == 0x4D2)
                return cast(dchar)0x4D3;
            else if (input == 0x4D4)
                return cast(dchar)0x4D5;
            else if (input == 0x4D6)
                return cast(dchar)0x4D7;
            else if (input == 0x4D8)
                return cast(dchar)0x4D9;
            else if (input == 0x4DA)
                return cast(dchar)0x4DB;
            else if (input == 0x4DC)
                return cast(dchar)0x4DD;
            else if (input == 0x4DE)
                return cast(dchar)0x4DF;
            else if (input == 0x4E0)
                return cast(dchar)0x4E1;
            else if (input == 0x4E2)
                return cast(dchar)0x4E3;
            else if (input == 0x4E4)
                return cast(dchar)0x4E5;
            else if (input == 0x4E6)
                return cast(dchar)0x4E7;
            else if (input == 0x4E8)
                return cast(dchar)0x4E9;
            else if (input == 0x4EA)
                return cast(dchar)0x4EB;
            else if (input == 0x4EC)
                return cast(dchar)0x4ED;
            else if (input == 0x4EE)
                return cast(dchar)0x4EF;
            else if (input == 0x4F0)
                return cast(dchar)0x4F1;
            else if (input == 0x4F2)
                return cast(dchar)0x4F3;
            else if (input == 0x4F4)
                return cast(dchar)0x4F5;
            else if (input == 0x4F6)
                return cast(dchar)0x4F7;
            else if (input == 0x4F8)
                return cast(dchar)0x4F9;
            else if (input == 0x4FA)
                return cast(dchar)0x4FB;
            else if (input == 0x4FC)
                return cast(dchar)0x4FD;
            else if (input == 0x4FE)
                return cast(dchar)0x4FF;
            else if (input == 0x500)
                return cast(dchar)0x501;
            else if (input == 0x502)
                return cast(dchar)0x503;
            else if (input == 0x504)
                return cast(dchar)0x505;
            else if (input == 0x506)
                return cast(dchar)0x507;
            else if (input == 0x508)
                return cast(dchar)0x509;
            else if (input == 0x50A)
                return cast(dchar)0x50B;
            else if (input == 0x50C)
                return cast(dchar)0x50D;
            else if (input == 0x50E)
                return cast(dchar)0x50F;
            else if (input == 0x510)
                return cast(dchar)0x511;
            else if (input == 0x512)
                return cast(dchar)0x513;
            else if (input == 0x514)
                return cast(dchar)0x515;
            else if (input == 0x516)
                return cast(dchar)0x517;
            else if (input == 0x518)
                return cast(dchar)0x519;
            else if (input == 0x51A)
                return cast(dchar)0x51B;
            else if (input == 0x51C)
                return cast(dchar)0x51D;
            else if (input == 0x51E)
                return cast(dchar)0x51F;
            else if (input == 0x520)
                return cast(dchar)0x521;
            else if (input == 0x522)
                return cast(dchar)0x523;
            else if (input == 0x524)
                return cast(dchar)0x525;
            else if (input == 0x526)
                return cast(dchar)0x527;
            else if (input == 0x528)
                return cast(dchar)0x529;
            else if (input == 0x52A)
                return cast(dchar)0x52B;
            else if (input == 0x52C)
                return cast(dchar)0x52D;
            else if (input == 0x52E)
                return cast(dchar)0x52F;
            else if (input >= 0x531 && input <= 0x556)
                return cast(dchar)LUT_25074147[cast(size_t)(214 + (input - 0x531))];
            else if (input >= 0x10A0 && input <= 0x10C5)
                return cast(dchar)LUT_25074147[cast(size_t)(252 + (input - 0x10A0))];
            else if (input == 0x10C7)
                return cast(dchar)0x2D27;
            else if (input == 0x10CD)
                return cast(dchar)0x2D2D;
            else if (input >= 0x13F8 && input <= 0x13FD)
                return cast(dchar)LUT_25074147[cast(size_t)(290 + (input - 0x13F8))];
            else if (input >= 0x1C80 && input <= 0x1C88)
                return cast(dchar)LUT_25074147[cast(size_t)(296 + (input - 0x1C80))];
            else if (input >= 0x1C90 && input <= 0x1CBF)
                return cast(dchar)LUT_25074147[cast(size_t)(305 + (input - 0x1C90))];
            else if (input == 0x1E00)
                return cast(dchar)0x1E01;
            else if (input == 0x1E02)
                return cast(dchar)0x1E03;
            else if (input == 0x1E04)
                return cast(dchar)0x1E05;
            else if (input == 0x1E06)
                return cast(dchar)0x1E07;
            else if (input == 0x1E08)
                return cast(dchar)0x1E09;
            else if (input == 0x1E0A)
                return cast(dchar)0x1E0B;
            else if (input == 0x1E0C)
                return cast(dchar)0x1E0D;
            else if (input == 0x1E0E)
                return cast(dchar)0x1E0F;
            else if (input == 0x1E10)
                return cast(dchar)0x1E11;
            else if (input == 0x1E12)
                return cast(dchar)0x1E13;
            else if (input == 0x1E14)
                return cast(dchar)0x1E15;
            else if (input == 0x1E16)
                return cast(dchar)0x1E17;
            else if (input == 0x1E18)
                return cast(dchar)0x1E19;
            else if (input == 0x1E1A)
                return cast(dchar)0x1E1B;
            else if (input == 0x1E1C)
                return cast(dchar)0x1E1D;
            else if (input == 0x1E1E)
                return cast(dchar)0x1E1F;
            else if (input == 0x1E20)
                return cast(dchar)0x1E21;
            else if (input == 0x1E22)
                return cast(dchar)0x1E23;
            else if (input == 0x1E24)
                return cast(dchar)0x1E25;
            else if (input == 0x1E26)
                return cast(dchar)0x1E27;
            else if (input == 0x1E28)
                return cast(dchar)0x1E29;
            else if (input == 0x1E2A)
                return cast(dchar)0x1E2B;
            else if (input == 0x1E2C)
                return cast(dchar)0x1E2D;
            else if (input == 0x1E2E)
                return cast(dchar)0x1E2F;
            else if (input == 0x1E30)
                return cast(dchar)0x1E31;
            else if (input == 0x1E32)
                return cast(dchar)0x1E33;
            else if (input == 0x1E34)
                return cast(dchar)0x1E35;
            else if (input == 0x1E36)
                return cast(dchar)0x1E37;
            else if (input == 0x1E38)
                return cast(dchar)0x1E39;
            else if (input == 0x1E3A)
                return cast(dchar)0x1E3B;
            else if (input == 0x1E3C)
                return cast(dchar)0x1E3D;
            else if (input == 0x1E3E)
                return cast(dchar)0x1E3F;
            else if (input == 0x1E40)
                return cast(dchar)0x1E41;
            else if (input == 0x1E42)
                return cast(dchar)0x1E43;
            else if (input == 0x1E44)
                return cast(dchar)0x1E45;
            else if (input == 0x1E46)
                return cast(dchar)0x1E47;
            else if (input == 0x1E48)
                return cast(dchar)0x1E49;
            else if (input == 0x1E4A)
                return cast(dchar)0x1E4B;
            else if (input == 0x1E4C)
                return cast(dchar)0x1E4D;
            else if (input == 0x1E4E)
                return cast(dchar)0x1E4F;
            else if (input == 0x1E50)
                return cast(dchar)0x1E51;
            else if (input == 0x1E52)
                return cast(dchar)0x1E53;
            else if (input == 0x1E54)
                return cast(dchar)0x1E55;
            else if (input == 0x1E56)
                return cast(dchar)0x1E57;
            else if (input == 0x1E58)
                return cast(dchar)0x1E59;
            else if (input == 0x1E5A)
                return cast(dchar)0x1E5B;
            else if (input == 0x1E5C)
                return cast(dchar)0x1E5D;
            else if (input == 0x1E5E)
                return cast(dchar)0x1E5F;
            else if (input == 0x1E60)
                return cast(dchar)0x1E61;
            else if (input == 0x1E62)
                return cast(dchar)0x1E63;
            else if (input == 0x1E64)
                return cast(dchar)0x1E65;
            else if (input == 0x1E66)
                return cast(dchar)0x1E67;
            else if (input == 0x1E68)
                return cast(dchar)0x1E69;
            else if (input == 0x1E6A)
                return cast(dchar)0x1E6B;
            else if (input == 0x1E6C)
                return cast(dchar)0x1E6D;
            else if (input == 0x1E6E)
                return cast(dchar)0x1E6F;
            else if (input == 0x1E70)
                return cast(dchar)0x1E71;
            else if (input == 0x1E72)
                return cast(dchar)0x1E73;
            else if (input == 0x1E74)
                return cast(dchar)0x1E75;
            else if (input == 0x1E76)
                return cast(dchar)0x1E77;
            else if (input == 0x1E78)
                return cast(dchar)0x1E79;
            else if (input == 0x1E7A)
                return cast(dchar)0x1E7B;
            else if (input == 0x1E7C)
                return cast(dchar)0x1E7D;
            else if (input == 0x1E7E)
                return cast(dchar)0x1E7F;
            else if (input == 0x1E80)
                return cast(dchar)0x1E81;
            else if (input == 0x1E82)
                return cast(dchar)0x1E83;
            else if (input == 0x1E84)
                return cast(dchar)0x1E85;
            else if (input == 0x1E86)
                return cast(dchar)0x1E87;
            else if (input == 0x1E88)
                return cast(dchar)0x1E89;
            else if (input == 0x1E8A)
                return cast(dchar)0x1E8B;
            else if (input == 0x1E8C)
                return cast(dchar)0x1E8D;
            else if (input == 0x1E8E)
                return cast(dchar)0x1E8F;
            else if (input == 0x1E90)
                return cast(dchar)0x1E91;
            else if (input == 0x1E92)
                return cast(dchar)0x1E93;
            else if (input == 0x1E94)
                return cast(dchar)0x1E95;
            else if (input == 0x1E9B)
                return cast(dchar)0x1E61;
            else if (input == 0x1E9E)
                return cast(dchar)0xDF;
            else if (input == 0x1EA0)
                return cast(dchar)0x1EA1;
            else if (input == 0x1EA2)
                return cast(dchar)0x1EA3;
            else if (input == 0x1EA4)
                return cast(dchar)0x1EA5;
            else if (input == 0x1EA6)
                return cast(dchar)0x1EA7;
            else if (input == 0x1EA8)
                return cast(dchar)0x1EA9;
            else if (input == 0x1EAA)
                return cast(dchar)0x1EAB;
            else if (input == 0x1EAC)
                return cast(dchar)0x1EAD;
            else if (input == 0x1EAE)
                return cast(dchar)0x1EAF;
            else if (input == 0x1EB0)
                return cast(dchar)0x1EB1;
            else if (input == 0x1EB2)
                return cast(dchar)0x1EB3;
            else if (input == 0x1EB4)
                return cast(dchar)0x1EB5;
            else if (input == 0x1EB6)
                return cast(dchar)0x1EB7;
            else if (input == 0x1EB8)
                return cast(dchar)0x1EB9;
            else if (input == 0x1EBA)
                return cast(dchar)0x1EBB;
            else if (input == 0x1EBC)
                return cast(dchar)0x1EBD;
            else if (input == 0x1EBE)
                return cast(dchar)0x1EBF;
            else if (input == 0x1EC0)
                return cast(dchar)0x1EC1;
            else if (input == 0x1EC2)
                return cast(dchar)0x1EC3;
            else if (input == 0x1EC4)
                return cast(dchar)0x1EC5;
            else if (input == 0x1EC6)
                return cast(dchar)0x1EC7;
            else if (input == 0x1EC8)
                return cast(dchar)0x1EC9;
            else if (input == 0x1ECA)
                return cast(dchar)0x1ECB;
            else if (input == 0x1ECC)
                return cast(dchar)0x1ECD;
            else if (input == 0x1ECE)
                return cast(dchar)0x1ECF;
            else if (input == 0x1ED0)
                return cast(dchar)0x1ED1;
            else if (input == 0x1ED2)
                return cast(dchar)0x1ED3;
            else if (input == 0x1ED4)
                return cast(dchar)0x1ED5;
            else if (input == 0x1ED6)
                return cast(dchar)0x1ED7;
            else if (input == 0x1ED8)
                return cast(dchar)0x1ED9;
            else if (input == 0x1EDA)
                return cast(dchar)0x1EDB;
            else if (input == 0x1EDC)
                return cast(dchar)0x1EDD;
            else if (input == 0x1EDE)
                return cast(dchar)0x1EDF;
            else if (input == 0x1EE0)
                return cast(dchar)0x1EE1;
            else if (input == 0x1EE2)
                return cast(dchar)0x1EE3;
            else if (input == 0x1EE4)
                return cast(dchar)0x1EE5;
            else if (input == 0x1EE6)
                return cast(dchar)0x1EE7;
            else if (input == 0x1EE8)
                return cast(dchar)0x1EE9;
            else if (input == 0x1EEA)
                return cast(dchar)0x1EEB;
            else if (input == 0x1EEC)
                return cast(dchar)0x1EED;
            else if (input == 0x1EEE)
                return cast(dchar)0x1EEF;
            else if (input == 0x1EF0)
                return cast(dchar)0x1EF1;
            else if (input == 0x1EF2)
                return cast(dchar)0x1EF3;
            else if (input == 0x1EF4)
                return cast(dchar)0x1EF5;
            else if (input == 0x1EF6)
                return cast(dchar)0x1EF7;
            else if (input == 0x1EF8)
                return cast(dchar)0x1EF9;
            else if (input == 0x1EFA)
                return cast(dchar)0x1EFB;
            else if (input == 0x1EFC)
                return cast(dchar)0x1EFD;
            else if (input == 0x1EFE)
                return cast(dchar)0x1EFF;
            else if (input >= 0x1F08 && input <= 0x1F0F)
                return cast(dchar)LUT_25074147[cast(size_t)(353 + (input - 0x1F08))];
            else if (input >= 0x1F18 && input <= 0x1F1D)
                return cast(dchar)LUT_25074147[cast(size_t)(361 + (input - 0x1F18))];
            else if (input >= 0x1F28 && input <= 0x1F2F)
                return cast(dchar)LUT_25074147[cast(size_t)(367 + (input - 0x1F28))];
            else if (input >= 0x1F38 && input <= 0x1F3F)
                return cast(dchar)LUT_25074147[cast(size_t)(375 + (input - 0x1F38))];
            else if (input >= 0x1F48 && input <= 0x1F4D)
                return cast(dchar)LUT_25074147[cast(size_t)(383 + (input - 0x1F48))];
            else if (input == 0x1F59)
                return cast(dchar)0x1F51;
            else if (input == 0x1F5B)
                return cast(dchar)0x1F53;
            else if (input == 0x1F5D)
                return cast(dchar)0x1F55;
            else if (input == 0x1F5F)
                return cast(dchar)0x1F57;
            else if (input >= 0x1F68 && input <= 0x1F6F)
                return cast(dchar)LUT_25074147[cast(size_t)(389 + (input - 0x1F68))];
            else if (input >= 0x1F88 && input <= 0x1F8F)
                return cast(dchar)LUT_25074147[cast(size_t)(397 + (input - 0x1F88))];
            else if (input >= 0x1F98 && input <= 0x1F9F)
                return cast(dchar)LUT_25074147[cast(size_t)(405 + (input - 0x1F98))];
            else if (input >= 0x1FA8 && input <= 0x1FAF)
                return cast(dchar)LUT_25074147[cast(size_t)(413 + (input - 0x1FA8))];
            else if (input >= 0x1FB8 && input <= 0x1FBC)
                return cast(dchar)LUT_25074147[cast(size_t)(421 + (input - 0x1FB8))];
            else if (input == 0x1FBE)
                return cast(dchar)0x3B9;
            else if (input >= 0x1FC8 && input <= 0x1FCC)
                return cast(dchar)LUT_25074147[cast(size_t)(426 + (input - 0x1FC8))];
            else if (input >= 0x1FD8 && input <= 0x1FDB)
                return cast(dchar)LUT_25074147[cast(size_t)(431 + (input - 0x1FD8))];
            else if (input >= 0x1FE8 && input <= 0x1FEC)
                return cast(dchar)LUT_25074147[cast(size_t)(435 + (input - 0x1FE8))];
            else if (input >= 0x1FF8 && input <= 0x1FFC)
                return cast(dchar)LUT_25074147[cast(size_t)(440 + (input - 0x1FF8))];
            else if (input == 0x2126)
                return cast(dchar)0x3C9;
            else if (input >= 0x212A && input <= 0x212B)
                return cast(dchar)LUT_25074147[cast(size_t)(445 + (input - 0x212A))];
            else if (input == 0x2132)
                return cast(dchar)0x214E;
            else if (input >= 0x2160 && input <= 0x216F)
                return cast(dchar)LUT_25074147[cast(size_t)(447 + (input - 0x2160))];
            else if (input == 0x2183)
                return cast(dchar)0x2184;
            else if (input >= 0x24B6 && input <= 0x24CF)
                return cast(dchar)LUT_25074147[cast(size_t)(463 + (input - 0x24B6))];
            else if (input >= 0x2C00 && input <= 0x2C2F)
                return cast(dchar)LUT_25074147[cast(size_t)(489 + (input - 0x2C00))];
            else if (input == 0x2C60)
                return cast(dchar)0x2C61;
            else if (input >= 0x2C62 && input <= 0x2C64)
                return cast(dchar)LUT_25074147[cast(size_t)(537 + (input - 0x2C62))];
            else if (input == 0x2C67)
                return cast(dchar)0x2C68;
            else if (input == 0x2C69)
                return cast(dchar)0x2C6A;
            else if (input == 0x2C6B)
                return cast(dchar)0x2C6C;
            else if (input >= 0x2C6D && input <= 0x2C70)
                return cast(dchar)LUT_25074147[cast(size_t)(540 + (input - 0x2C6D))];
            else if (input == 0x2C72)
                return cast(dchar)0x2C73;
            else if (input == 0x2C75)
                return cast(dchar)0x2C76;
            else if (input >= 0x2C7E && input <= 0x2C80)
                return cast(dchar)LUT_25074147[cast(size_t)(544 + (input - 0x2C7E))];
            else if (input == 0x2C82)
                return cast(dchar)0x2C83;
            else if (input == 0x2C84)
                return cast(dchar)0x2C85;
            else if (input == 0x2C86)
                return cast(dchar)0x2C87;
            else if (input == 0x2C88)
                return cast(dchar)0x2C89;
            else if (input == 0x2C8A)
                return cast(dchar)0x2C8B;
            else if (input == 0x2C8C)
                return cast(dchar)0x2C8D;
            else if (input == 0x2C8E)
                return cast(dchar)0x2C8F;
            else if (input == 0x2C90)
                return cast(dchar)0x2C91;
            else if (input == 0x2C92)
                return cast(dchar)0x2C93;
            else if (input == 0x2C94)
                return cast(dchar)0x2C95;
            else if (input == 0x2C96)
                return cast(dchar)0x2C97;
            else if (input == 0x2C98)
                return cast(dchar)0x2C99;
            else if (input == 0x2C9A)
                return cast(dchar)0x2C9B;
            else if (input == 0x2C9C)
                return cast(dchar)0x2C9D;
            else if (input == 0x2C9E)
                return cast(dchar)0x2C9F;
            else if (input == 0x2CA0)
                return cast(dchar)0x2CA1;
            else if (input == 0x2CA2)
                return cast(dchar)0x2CA3;
            else if (input == 0x2CA4)
                return cast(dchar)0x2CA5;
            else if (input == 0x2CA6)
                return cast(dchar)0x2CA7;
            else if (input == 0x2CA8)
                return cast(dchar)0x2CA9;
            else if (input == 0x2CAA)
                return cast(dchar)0x2CAB;
            else if (input == 0x2CAC)
                return cast(dchar)0x2CAD;
            else if (input == 0x2CAE)
                return cast(dchar)0x2CAF;
            else if (input == 0x2CB0)
                return cast(dchar)0x2CB1;
            else if (input == 0x2CB2)
                return cast(dchar)0x2CB3;
            else if (input == 0x2CB4)
                return cast(dchar)0x2CB5;
            else if (input == 0x2CB6)
                return cast(dchar)0x2CB7;
            else if (input == 0x2CB8)
                return cast(dchar)0x2CB9;
            else if (input == 0x2CBA)
                return cast(dchar)0x2CBB;
            else if (input == 0x2CBC)
                return cast(dchar)0x2CBD;
            else if (input == 0x2CBE)
                return cast(dchar)0x2CBF;
            else if (input == 0x2CC0)
                return cast(dchar)0x2CC1;
            else if (input == 0x2CC2)
                return cast(dchar)0x2CC3;
            else if (input == 0x2CC4)
                return cast(dchar)0x2CC5;
            else if (input == 0x2CC6)
                return cast(dchar)0x2CC7;
            else if (input == 0x2CC8)
                return cast(dchar)0x2CC9;
            else if (input == 0x2CCA)
                return cast(dchar)0x2CCB;
            else if (input == 0x2CCC)
                return cast(dchar)0x2CCD;
            else if (input == 0x2CCE)
                return cast(dchar)0x2CCF;
            else if (input == 0x2CD0)
                return cast(dchar)0x2CD1;
            else if (input == 0x2CD2)
                return cast(dchar)0x2CD3;
            else if (input == 0x2CD4)
                return cast(dchar)0x2CD5;
            else if (input == 0x2CD6)
                return cast(dchar)0x2CD7;
            else if (input == 0x2CD8)
                return cast(dchar)0x2CD9;
            else if (input == 0x2CDA)
                return cast(dchar)0x2CDB;
            else if (input == 0x2CDC)
                return cast(dchar)0x2CDD;
            else if (input == 0x2CDE)
                return cast(dchar)0x2CDF;
            else if (input == 0x2CE0)
                return cast(dchar)0x2CE1;
            else if (input == 0x2CE2)
                return cast(dchar)0x2CE3;
            else if (input == 0x2CEB)
                return cast(dchar)0x2CEC;
            else if (input == 0x2CED)
                return cast(dchar)0x2CEE;
            else if (input == 0x2CF2)
                return cast(dchar)0x2CF3;
        } else if (input >= 0xA640) {
            if (input == 0xA640)
                return cast(dchar)0xA641;
            else if (input == 0xA642)
                return cast(dchar)0xA643;
            else if (input == 0xA644)
                return cast(dchar)0xA645;
            else if (input == 0xA646)
                return cast(dchar)0xA647;
            else if (input == 0xA648)
                return cast(dchar)0xA649;
            else if (input == 0xA64A)
                return cast(dchar)0xA64B;
            else if (input == 0xA64C)
                return cast(dchar)0xA64D;
            else if (input == 0xA64E)
                return cast(dchar)0xA64F;
            else if (input == 0xA650)
                return cast(dchar)0xA651;
            else if (input == 0xA652)
                return cast(dchar)0xA653;
            else if (input == 0xA654)
                return cast(dchar)0xA655;
            else if (input == 0xA656)
                return cast(dchar)0xA657;
            else if (input == 0xA658)
                return cast(dchar)0xA659;
            else if (input == 0xA65A)
                return cast(dchar)0xA65B;
            else if (input == 0xA65C)
                return cast(dchar)0xA65D;
            else if (input == 0xA65E)
                return cast(dchar)0xA65F;
            else if (input == 0xA660)
                return cast(dchar)0xA661;
            else if (input == 0xA662)
                return cast(dchar)0xA663;
            else if (input == 0xA664)
                return cast(dchar)0xA665;
            else if (input == 0xA666)
                return cast(dchar)0xA667;
            else if (input == 0xA668)
                return cast(dchar)0xA669;
            else if (input == 0xA66A)
                return cast(dchar)0xA66B;
            else if (input == 0xA66C)
                return cast(dchar)0xA66D;
            else if (input == 0xA680)
                return cast(dchar)0xA681;
            else if (input == 0xA682)
                return cast(dchar)0xA683;
            else if (input == 0xA684)
                return cast(dchar)0xA685;
            else if (input == 0xA686)
                return cast(dchar)0xA687;
            else if (input == 0xA688)
                return cast(dchar)0xA689;
            else if (input == 0xA68A)
                return cast(dchar)0xA68B;
            else if (input == 0xA68C)
                return cast(dchar)0xA68D;
            else if (input == 0xA68E)
                return cast(dchar)0xA68F;
            else if (input == 0xA690)
                return cast(dchar)0xA691;
            else if (input == 0xA692)
                return cast(dchar)0xA693;
            else if (input == 0xA694)
                return cast(dchar)0xA695;
            else if (input == 0xA696)
                return cast(dchar)0xA697;
            else if (input == 0xA698)
                return cast(dchar)0xA699;
            else if (input == 0xA69A)
                return cast(dchar)0xA69B;
            else if (input == 0xA722)
                return cast(dchar)0xA723;
            else if (input == 0xA724)
                return cast(dchar)0xA725;
            else if (input == 0xA726)
                return cast(dchar)0xA727;
            else if (input == 0xA728)
                return cast(dchar)0xA729;
            else if (input == 0xA72A)
                return cast(dchar)0xA72B;
            else if (input == 0xA72C)
                return cast(dchar)0xA72D;
            else if (input == 0xA72E)
                return cast(dchar)0xA72F;
            else if (input == 0xA732)
                return cast(dchar)0xA733;
            else if (input == 0xA734)
                return cast(dchar)0xA735;
            else if (input == 0xA736)
                return cast(dchar)0xA737;
            else if (input == 0xA738)
                return cast(dchar)0xA739;
            else if (input == 0xA73A)
                return cast(dchar)0xA73B;
            else if (input == 0xA73C)
                return cast(dchar)0xA73D;
            else if (input == 0xA73E)
                return cast(dchar)0xA73F;
            else if (input == 0xA740)
                return cast(dchar)0xA741;
            else if (input == 0xA742)
                return cast(dchar)0xA743;
            else if (input == 0xA744)
                return cast(dchar)0xA745;
            else if (input == 0xA746)
                return cast(dchar)0xA747;
            else if (input == 0xA748)
                return cast(dchar)0xA749;
            else if (input == 0xA74A)
                return cast(dchar)0xA74B;
            else if (input == 0xA74C)
                return cast(dchar)0xA74D;
            else if (input == 0xA74E)
                return cast(dchar)0xA74F;
            else if (input == 0xA750)
                return cast(dchar)0xA751;
            else if (input == 0xA752)
                return cast(dchar)0xA753;
            else if (input == 0xA754)
                return cast(dchar)0xA755;
            else if (input == 0xA756)
                return cast(dchar)0xA757;
            else if (input == 0xA758)
                return cast(dchar)0xA759;
            else if (input == 0xA75A)
                return cast(dchar)0xA75B;
            else if (input == 0xA75C)
                return cast(dchar)0xA75D;
            else if (input == 0xA75E)
                return cast(dchar)0xA75F;
            else if (input == 0xA760)
                return cast(dchar)0xA761;
            else if (input == 0xA762)
                return cast(dchar)0xA763;
            else if (input == 0xA764)
                return cast(dchar)0xA765;
            else if (input == 0xA766)
                return cast(dchar)0xA767;
            else if (input == 0xA768)
                return cast(dchar)0xA769;
            else if (input == 0xA76A)
                return cast(dchar)0xA76B;
            else if (input == 0xA76C)
                return cast(dchar)0xA76D;
            else if (input == 0xA76E)
                return cast(dchar)0xA76F;
            else if (input == 0xA779)
                return cast(dchar)0xA77A;
            else if (input == 0xA77B)
                return cast(dchar)0xA77C;
            else if (input >= 0xA77D && input <= 0xA77E)
                return cast(dchar)LUT_25074147[cast(size_t)(547 + (input - 0xA77D))];
            else if (input == 0xA780)
                return cast(dchar)0xA781;
            else if (input == 0xA782)
                return cast(dchar)0xA783;
            else if (input == 0xA784)
                return cast(dchar)0xA785;
            else if (input == 0xA786)
                return cast(dchar)0xA787;
            else if (input == 0xA78B)
                return cast(dchar)0xA78C;
            else if (input == 0xA78D)
                return cast(dchar)0x265;
            else if (input == 0xA790)
                return cast(dchar)0xA791;
            else if (input == 0xA792)
                return cast(dchar)0xA793;
            else if (input == 0xA796)
                return cast(dchar)0xA797;
            else if (input == 0xA798)
                return cast(dchar)0xA799;
            else if (input == 0xA79A)
                return cast(dchar)0xA79B;
            else if (input == 0xA79C)
                return cast(dchar)0xA79D;
            else if (input == 0xA79E)
                return cast(dchar)0xA79F;
            else if (input == 0xA7A0)
                return cast(dchar)0xA7A1;
            else if (input == 0xA7A2)
                return cast(dchar)0xA7A3;
            else if (input == 0xA7A4)
                return cast(dchar)0xA7A5;
            else if (input == 0xA7A6)
                return cast(dchar)0xA7A7;
            else if (input == 0xA7A8)
                return cast(dchar)0xA7A9;
            else if (input >= 0xA7AA && input <= 0xA7B4)
                return cast(dchar)LUT_25074147[cast(size_t)(549 + (input - 0xA7AA))];
            else if (input == 0xA7B6)
                return cast(dchar)0xA7B7;
            else if (input == 0xA7B8)
                return cast(dchar)0xA7B9;
            else if (input == 0xA7BA)
                return cast(dchar)0xA7BB;
            else if (input == 0xA7BC)
                return cast(dchar)0xA7BD;
            else if (input == 0xA7BE)
                return cast(dchar)0xA7BF;
            else if (input == 0xA7C0)
                return cast(dchar)0xA7C1;
            else if (input == 0xA7C2)
                return cast(dchar)0xA7C3;
            else if (input >= 0xA7C4 && input <= 0xA7C7)
                return cast(dchar)LUT_25074147[cast(size_t)(560 + (input - 0xA7C4))];
            else if (input == 0xA7C9)
                return cast(dchar)0xA7CA;
            else if (input == 0xA7D0)
                return cast(dchar)0xA7D1;
            else if (input == 0xA7D6)
                return cast(dchar)0xA7D7;
            else if (input == 0xA7D8)
                return cast(dchar)0xA7D9;
            else if (input == 0xA7F5)
                return cast(dchar)0xA7F6;
            else if (input >= 0xAB70 && input <= 0xABBF)
                return cast(dchar)LUT_25074147[cast(size_t)(564 + (input - 0xAB70))];
            else if (input >= 0xFF21)
                return cast(dchar)LUT_25074147[cast(size_t)(644 + (input - 0xFF21))];
        }
    } else if (input >= 0x10400 && input <= 0x1E921) {
        if (input <= 0x16E5F) {
            if (input <= 0x10427)
                return cast(dchar)LUT_25074147[cast(size_t)(670 + (input - 0x10400))];
            else if (input >= 0x104B0 && input <= 0x104D3)
                return cast(dchar)LUT_25074147[cast(size_t)(710 + (input - 0x104B0))];
            else if (input >= 0x10570 && input <= 0x10595)
                return cast(dchar)LUT_25074147[cast(size_t)(746 + (input - 0x10570))];
            else if (input >= 0x10C80 && input <= 0x10CB2)
                return cast(dchar)LUT_25074147[cast(size_t)(784 + (input - 0x10C80))];
            else if (input >= 0x118A0 && input <= 0x118BF)
                return cast(dchar)LUT_25074147[cast(size_t)(835 + (input - 0x118A0))];
            else if (input >= 0x16E40)
                return cast(dchar)LUT_25074147[cast(size_t)(867 + (input - 0x16E40))];
        } else if (input >= 0x1E900) {
            return cast(dchar)LUT_25074147[cast(size_t)(899 + (input - 0x1E900))];
        }
    }
    return input;
}
private {
    static immutable LUT_25074147 = [0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xD7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF, 0x17A, 0x253, 0x183, 0x254, 0x188, 0x188, 0x256, 0x257, 0x18C, 0x18C, 0x18D, 0x1DD, 0x259, 0x25B, 0x192, 0x192, 0x260, 0x263, 0x195, 0x269, 0x268, 0x199, 0x199, 0x19A, 0x19B, 0x26F, 0x272, 0x19E, 0x275, 0x1A1, 0x280, 0x1A8, 0x288, 0x1B0, 0x1B0, 0x28A, 0x28B, 0x1B4, 0x292, 0x1B9, 0x195, 0x1BF, 0x1F9, 0x2C65, 0x23C, 0x23C, 0x19A, 0x2C66, 0x180, 0x289, 0x28C, 0x247, 0x3AD, 0x3AE, 0x3AF, 0x3CD, 0x3CE, 0x390, 0x3B1, 0x3B2, 0x3B3, 0x3B4, 0x3B5, 0x3B6, 0x3B7, 0x3B8, 0x3B9, 0x3BA, 0x3BB, 0x3BC, 0x3BD, 0x3BE, 0x3BF, 0x3C0, 0x3C1, 0x3A2, 0x3C3, 0x3C4, 0x3C5, 0x3C6, 0x3C7, 0x3C8, 0x3C9, 0x3CA, 0x3CB, 0x3D7, 0x3B2, 0x3B8, 0x3D2, 0x3D3, 0x3D4, 0x3C6, 0x3C0, 0x3BA, 0x3C1, 0x3F2, 0x3F3, 0x3B8, 0x3B5, 0x3F2, 0x3FB, 0x3FB, 0x3FC, 0x37B, 0x37C, 0x37D, 0x450, 0x451, 0x452, 0x453, 0x454, 0x455, 0x456, 0x457, 0x458, 0x459, 0x45A, 0x45B, 0x45C, 0x45D, 0x45E, 0x45F, 0x430, 0x431, 0x432, 0x433, 0x434, 0x435, 0x436, 0x437, 0x438, 0x439, 0x43A, 0x43B, 0x43C, 0x43D, 0x43E, 0x43F, 0x440, 0x441, 0x442, 0x443, 0x444, 0x445, 0x446, 0x447, 0x448, 0x449, 0x44A, 0x44B, 0x44C, 0x44D, 0x44E, 0x44F, 0x4CF, 0x4C2, 0x561, 0x562, 0x563, 0x564, 0x565, 0x566, 0x567, 0x568, 0x569, 0x56A, 0x56B, 0x56C, 0x56D, 0x56E, 0x56F, 0x570, 0x571, 0x572, 0x573, 0x574, 0x575, 0x576, 0x577, 0x578, 0x579, 0x57A, 0x57B, 0x57C, 0x57D, 0x57E, 0x57F, 0x580, 0x581, 0x582, 0x583, 0x584, 0x585, 0x586, 0x2D00, 0x2D01, 0x2D02, 0x2D03, 0x2D04, 0x2D05, 0x2D06, 0x2D07, 0x2D08, 0x2D09, 0x2D0A, 0x2D0B, 0x2D0C, 0x2D0D, 0x2D0E, 0x2D0F, 0x2D10, 0x2D11, 0x2D12, 0x2D13, 0x2D14, 0x2D15, 0x2D16, 0x2D17, 0x2D18, 0x2D19, 0x2D1A, 0x2D1B, 0x2D1C, 0x2D1D, 0x2D1E, 0x2D1F, 0x2D20, 0x2D21, 0x2D22, 0x2D23, 0x2D24, 0x2D25, 0x13F0, 0x13F1, 0x13F2, 0x13F3, 0x13F4, 0x13F5, 0x432, 0x434, 0x43E, 0x441, 0x442, 0x442, 0x44A, 0x463, 0xA64B, 0x10D0, 0x10D1, 0x10D2, 0x10D3, 0x10D4, 0x10D5, 0x10D6, 0x10D7, 0x10D8, 0x10D9, 0x10DA, 0x10DB, 0x10DC, 0x10DD, 0x10DE, 0x10DF, 0x10E0, 0x10E1, 0x10E2, 0x10E3, 0x10E4, 0x10E5, 0x10E6, 0x10E7, 0x10E8, 0x10E9, 0x10EA, 0x10EB, 0x10EC, 0x10ED, 0x10EE, 0x10EF, 0x10F0, 0x10F1, 0x10F2, 0x10F3, 0x10F4, 0x10F5, 0x10F6, 0x10F7, 0x10F8, 0x10F9, 0x10FA, 0x1CBB, 0x1CBC, 0x10FD, 0x10FE, 0x10FF, 0x1F00, 0x1F01, 0x1F02, 0x1F03, 0x1F04, 0x1F05, 0x1F06, 0x1F07, 0x1F10, 0x1F11, 0x1F12, 0x1F13, 0x1F14, 0x1F15, 0x1F20, 0x1F21, 0x1F22, 0x1F23, 0x1F24, 0x1F25, 0x1F26, 0x1F27, 0x1F30, 0x1F31, 0x1F32, 0x1F33, 0x1F34, 0x1F35, 0x1F36, 0x1F37, 0x1F40, 0x1F41, 0x1F42, 0x1F43, 0x1F44, 0x1F45, 0x1F60, 0x1F61, 0x1F62, 0x1F63, 0x1F64, 0x1F65, 0x1F66, 0x1F67, 0x1F80, 0x1F81, 0x1F82, 0x1F83, 0x1F84, 0x1F85, 0x1F86, 0x1F87, 0x1F90, 0x1F91, 0x1F92, 0x1F93, 0x1F94, 0x1F95, 0x1F96, 0x1F97, 0x1FA0, 0x1FA1, 0x1FA2, 0x1FA3, 0x1FA4, 0x1FA5, 0x1FA6, 0x1FA7, 0x1FB0, 0x1FB1, 0x1F70, 0x1F71, 0x1FB3, 0x1F72, 0x1F73, 0x1F74, 0x1F75, 0x1FC3, 0x1FD0, 0x1FD1, 0x1F76, 0x1F77, 0x1FE0, 0x1FE1, 0x1F7A, 0x1F7B, 0x1FE5, 0x1F78, 0x1F79, 0x1F7C, 0x1F7D, 0x1FF3, 0x6B, 0xE5, 0x2170, 0x2171, 0x2172, 0x2173, 0x2174, 0x2175, 0x2176, 0x2177, 0x2178, 0x2179, 0x217A, 0x217B, 0x217C, 0x217D, 0x217E, 0x217F, 0x24D0, 0x24D1, 0x24D2, 0x24D3, 0x24D4, 0x24D5, 0x24D6, 0x24D7, 0x24D8, 0x24D9, 0x24DA, 0x24DB, 0x24DC, 0x24DD, 0x24DE, 0x24DF, 0x24E0, 0x24E1, 0x24E2, 0x24E3, 0x24E4, 0x24E5, 0x24E6, 0x24E7, 0x24E8, 0x24E9, 0x2C30, 0x2C31, 0x2C32, 0x2C33, 0x2C34, 0x2C35, 0x2C36, 0x2C37, 0x2C38, 0x2C39, 0x2C3A, 0x2C3B, 0x2C3C, 0x2C3D, 0x2C3E, 0x2C3F, 0x2C40, 0x2C41, 0x2C42, 0x2C43, 0x2C44, 0x2C45, 0x2C46, 0x2C47, 0x2C48, 0x2C49, 0x2C4A, 0x2C4B, 0x2C4C, 0x2C4D, 0x2C4E, 0x2C4F, 0x2C50, 0x2C51, 0x2C52, 0x2C53, 0x2C54, 0x2C55, 0x2C56, 0x2C57, 0x2C58, 0x2C59, 0x2C5A, 0x2C5B, 0x2C5C, 0x2C5D, 0x2C5E, 0x2C5F, 0x26B, 0x1D7D, 0x27D, 0x251, 0x271, 0x250, 0x252, 0x23F, 0x240, 0x2C81, 0x1D79, 0xA77F, 0x266, 0x25C, 0x261, 0x26C, 0x26A, 0xA7AF, 0x29E, 0x287, 0x29D, 0xAB53, 0xA7B5, 0xA794, 0x282, 0x1D8E, 0xA7C8, 0x13A0, 0x13A1, 0x13A2, 0x13A3, 0x13A4, 0x13A5, 0x13A6, 0x13A7, 0x13A8, 0x13A9, 0x13AA, 0x13AB, 0x13AC, 0x13AD, 0x13AE, 0x13AF, 0x13B0, 0x13B1, 0x13B2, 0x13B3, 0x13B4, 0x13B5, 0x13B6, 0x13B7, 0x13B8, 0x13B9, 0x13BA, 0x13BB, 0x13BC, 0x13BD, 0x13BE, 0x13BF, 0x13C0, 0x13C1, 0x13C2, 0x13C3, 0x13C4, 0x13C5, 0x13C6, 0x13C7, 0x13C8, 0x13C9, 0x13CA, 0x13CB, 0x13CC, 0x13CD, 0x13CE, 0x13CF, 0x13D0, 0x13D1, 0x13D2, 0x13D3, 0x13D4, 0x13D5, 0x13D6, 0x13D7, 0x13D8, 0x13D9, 0x13DA, 0x13DB, 0x13DC, 0x13DD, 0x13DE, 0x13DF, 0x13E0, 0x13E1, 0x13E2, 0x13E3, 0x13E4, 0x13E5, 0x13E6, 0x13E7, 0x13E8, 0x13E9, 0x13EA, 0x13EB, 0x13EC, 0x13ED, 0x13EE, 0x13EF, 0xFF41, 0xFF42, 0xFF43, 0xFF44, 0xFF45, 0xFF46, 0xFF47, 0xFF48, 0xFF49, 0xFF4A, 0xFF4B, 0xFF4C, 0xFF4D, 0xFF4E, 0xFF4F, 0xFF50, 0xFF51, 0xFF52, 0xFF53, 0xFF54, 0xFF55, 0xFF56, 0xFF57, 0xFF58, 0xFF59, 0xFF5A, 0x10428, 0x10429, 0x1042A, 0x1042B, 0x1042C, 0x1042D, 0x1042E, 0x1042F, 0x10430, 0x10431, 0x10432, 0x10433, 0x10434, 0x10435, 0x10436, 0x10437, 0x10438, 0x10439, 0x1043A, 0x1043B, 0x1043C, 0x1043D, 0x1043E, 0x1043F, 0x10440, 0x10441, 0x10442, 0x10443, 0x10444, 0x10445, 0x10446, 0x10447, 0x10448, 0x10449, 0x1044A, 0x1044B, 0x1044C, 0x1044D, 0x1044E, 0x1044F, 0x104D8, 0x104D9, 0x104DA, 0x104DB, 0x104DC, 0x104DD, 0x104DE, 0x104DF, 0x104E0, 0x104E1, 0x104E2, 0x104E3, 0x104E4, 0x104E5, 0x104E6, 0x104E7, 0x104E8, 0x104E9, 0x104EA, 0x104EB, 0x104EC, 0x104ED, 0x104EE, 0x104EF, 0x104F0, 0x104F1, 0x104F2, 0x104F3, 0x104F4, 0x104F5, 0x104F6, 0x104F7, 0x104F8, 0x104F9, 0x104FA, 0x104FB, 0x10597, 0x10598, 0x10599, 0x1059A, 0x1059B, 0x1059C, 0x1059D, 0x1059E, 0x1059F, 0x105A0, 0x105A1, 0x1057B, 0x105A3, 0x105A4, 0x105A5, 0x105A6, 0x105A7, 0x105A8, 0x105A9, 0x105AA, 0x105AB, 0x105AC, 0x105AD, 0x105AE, 0x105AF, 0x105B0, 0x105B1, 0x1058B, 0x105B3, 0x105B4, 0x105B5, 0x105B6, 0x105B7, 0x105B8, 0x105B9, 0x10593, 0x105BB, 0x105BC, 0x10CC0, 0x10CC1, 0x10CC2, 0x10CC3, 0x10CC4, 0x10CC5, 0x10CC6, 0x10CC7, 0x10CC8, 0x10CC9, 0x10CCA, 0x10CCB, 0x10CCC, 0x10CCD, 0x10CCE, 0x10CCF, 0x10CD0, 0x10CD1, 0x10CD2, 0x10CD3, 0x10CD4, 0x10CD5, 0x10CD6, 0x10CD7, 0x10CD8, 0x10CD9, 0x10CDA, 0x10CDB, 0x10CDC, 0x10CDD, 0x10CDE, 0x10CDF, 0x10CE0, 0x10CE1, 0x10CE2, 0x10CE3, 0x10CE4, 0x10CE5, 0x10CE6, 0x10CE7, 0x10CE8, 0x10CE9, 0x10CEA, 0x10CEB, 0x10CEC, 0x10CED, 0x10CEE, 0x10CEF, 0x10CF0, 0x10CF1, 0x10CF2, 0x118C0, 0x118C1, 0x118C2, 0x118C3, 0x118C4, 0x118C5, 0x118C6, 0x118C7, 0x118C8, 0x118C9, 0x118CA, 0x118CB, 0x118CC, 0x118CD, 0x118CE, 0x118CF, 0x118D0, 0x118D1, 0x118D2, 0x118D3, 0x118D4, 0x118D5, 0x118D6, 0x118D7, 0x118D8, 0x118D9, 0x118DA, 0x118DB, 0x118DC, 0x118DD, 0x118DE, 0x118DF, 0x16E60, 0x16E61, 0x16E62, 0x16E63, 0x16E64, 0x16E65, 0x16E66, 0x16E67, 0x16E68, 0x16E69, 0x16E6A, 0x16E6B, 0x16E6C, 0x16E6D, 0x16E6E, 0x16E6F, 0x16E70, 0x16E71, 0x16E72, 0x16E73, 0x16E74, 0x16E75, 0x16E76, 0x16E77, 0x16E78, 0x16E79, 0x16E7A, 0x16E7B, 0x16E7C, 0x16E7D, 0x16E7E, 0x16E7F, 0x1E922, 0x1E923, 0x1E924, 0x1E925, 0x1E926, 0x1E927, 0x1E928, 0x1E929, 0x1E92A, 0x1E92B, 0x1E92C, 0x1E92D, 0x1E92E, 0x1E92F, 0x1E930, 0x1E931, 0x1E932, 0x1E933, 0x1E934, 0x1E935, 0x1E936, 0x1E937, 0x1E938, 0x1E939, 0x1E93A, 0x1E93B, 0x1E93C, 0x1E93D, 0x1E93E, 0x1E93F, 0x1E940, 0x1E941, 0x1E942, 0x1E943, ];
}

export extern(C) immutable(size_t) sidero_utf_lut_lengthOfCaseFolding(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x41 && input <= 0xFF3A) {
        if (input <= 0x2CF2) {
            if (input <= 0x5A)
                return cast(size_t)1;
            else if (input == 0xB5)
                return cast(size_t)1;
            else if (input >= 0xC0 && input <= 0xD6)
                return cast(size_t)1;
            else if (input >= 0xD8 && input <= 0xDF)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(0 + (input - 0xD8))];
            else if (input >= 0x100 && input <= 0x12E)
                return cast(size_t)1;
            else if (input == 0x130)
                return cast(size_t)2;
            else if (input >= 0x132 && input <= 0x147)
                return cast(size_t)1;
            else if (input == 0x149)
                return cast(size_t)2;
            else if (input >= 0x14A && input <= 0x1EE)
                return cast(size_t)1;
            else if (input == 0x1F0)
                return cast(size_t)2;
            else if (input >= 0x1F1 && input <= 0x24E)
                return cast(size_t)1;
            else if (input == 0x345)
                return cast(size_t)1;
            else if (input >= 0x370 && input <= 0x376)
                return cast(size_t)1;
            else if (input == 0x37F)
                return cast(size_t)1;
            else if (input >= 0x386 && input <= 0x38C)
                return cast(size_t)1;
            else if (input >= 0x38E && input <= 0x390)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(8 + (input - 0x38E))];
            else if (input >= 0x391 && input <= 0x3AB)
                return cast(size_t)1;
            else if (input == 0x3B0)
                return cast(size_t)3;
            else if (input == 0x3C2)
                return cast(size_t)1;
            else if (input >= 0x3CF && input <= 0x42F)
                return cast(size_t)1;
            else if (input >= 0x460 && input <= 0x480)
                return cast(size_t)1;
            else if (input >= 0x48A && input <= 0x556)
                return cast(size_t)1;
            else if (input == 0x587)
                return cast(size_t)2;
            else if (input >= 0x10A0 && input <= 0x10CD)
                return cast(size_t)1;
            else if (input >= 0x13F8 && input <= 0x13FD)
                return cast(size_t)1;
            else if (input >= 0x1C80 && input <= 0x1C88)
                return cast(size_t)1;
            else if (input >= 0x1C90 && input <= 0x1CBF)
                return cast(size_t)1;
            else if (input >= 0x1E00 && input <= 0x1E94)
                return cast(size_t)1;
            else if (input >= 0x1E96 && input <= 0x1E9A)
                return cast(size_t)2;
            else if (input == 0x1E9B)
                return cast(size_t)1;
            else if (input == 0x1E9E)
                return cast(size_t)2;
            else if (input >= 0x1EA0 && input <= 0x1F4D)
                return cast(size_t)1;
            else if (input == 0x1F50)
                return cast(size_t)2;
            else if (input >= 0x1F52 && input <= 0x1F56)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(11 + (input - 0x1F52))];
            else if (input >= 0x1F59 && input <= 0x1F5F)
                return cast(size_t)1;
            else if (input >= 0x1F68 && input <= 0x1F6F)
                return cast(size_t)1;
            else if (input >= 0x1F80 && input <= 0x1FB4)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(16 + (input - 0x1F80))];
            else if (input >= 0x1FB6 && input <= 0x1FBC)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(69 + (input - 0x1FB6))];
            else if (input == 0x1FBE)
                return cast(size_t)1;
            else if (input >= 0x1FC2 && input <= 0x1FC4)
                return cast(size_t)2;
            else if (input >= 0x1FC6 && input <= 0x1FCC)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(76 + (input - 0x1FC6))];
            else if (input >= 0x1FD2 && input <= 0x1FD3)
                return cast(size_t)3;
            else if (input >= 0x1FD6 && input <= 0x1FD7)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(83 + (input - 0x1FD6))];
            else if (input >= 0x1FD8 && input <= 0x1FDB)
                return cast(size_t)1;
            else if (input >= 0x1FE2 && input <= 0x1FE7)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(85 + (input - 0x1FE2))];
            else if (input >= 0x1FE8 && input <= 0x1FEC)
                return cast(size_t)1;
            else if (input >= 0x1FF2 && input <= 0x1FF4)
                return cast(size_t)2;
            else if (input >= 0x1FF6 && input <= 0x1FFC)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(91 + (input - 0x1FF6))];
            else if (input >= 0x2126 && input <= 0x212B)
                return cast(size_t)1;
            else if (input == 0x2132)
                return cast(size_t)1;
            else if (input >= 0x2160 && input <= 0x216F)
                return cast(size_t)1;
            else if (input == 0x2183)
                return cast(size_t)1;
            else if (input >= 0x24B6 && input <= 0x24CF)
                return cast(size_t)1;
            else if (input >= 0x2C00 && input <= 0x2C2F)
                return cast(size_t)1;
            else if (input >= 0x2C60 && input <= 0x2C75)
                return cast(size_t)1;
            else if (input >= 0x2C7E)
                return cast(size_t)1;
        } else if (input >= 0xA640) {
            if (input <= 0xA66C)
                return cast(size_t)1;
            else if (input >= 0xA680 && input <= 0xA69A)
                return cast(size_t)1;
            else if (input >= 0xA722 && input <= 0xA7F5)
                return cast(size_t)1;
            else if (input >= 0xAB70 && input <= 0xABBF)
                return cast(size_t)1;
            else if (input >= 0xFB00 && input <= 0xFB06)
                return cast(size_t)LUT_E95E25E4[cast(size_t)(98 + (input - 0xFB00))];
            else if (input >= 0xFB13 && input <= 0xFB17)
                return cast(size_t)2;
            else if (input >= 0xFF21)
                return cast(size_t)1;
        }
    } else if (input >= 0x10400 && input <= 0x1E921) {
        if (input <= 0x16E5F) {
            if (input <= 0x10427)
                return cast(size_t)1;
            else if (input >= 0x104B0 && input <= 0x104D3)
                return cast(size_t)1;
            else if (input >= 0x10570 && input <= 0x10595)
                return cast(size_t)1;
            else if (input >= 0x10C80 && input <= 0x10CB2)
                return cast(size_t)1;
            else if (input >= 0x118A0 && input <= 0x118BF)
                return cast(size_t)1;
            else if (input >= 0x16E40)
                return cast(size_t)1;
        } else if (input >= 0x1E900) {
            return cast(size_t)1;
        }
    }
    return typeof(return).init;
}
private {
    static immutable LUT_E95E25E4 = [1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 3, 3, 1, 3, 1, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 2, 3, 1, 1, 1, 1, 2, 2, 3, 1, 1, 1, 1, 2, 2, 3, 3, 3, 2, 1, 2, 3, 2, 3, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 2, 2, ];
}

export extern(C) immutable(size_t) sidero_utf_lut_lengthOfCaseFoldingTurkic(dchar input) @trusted nothrow @nogc pure {
    if (input == 0x49)
        return cast(size_t)1;
    else if (input == 0x130)
        return cast(size_t)1;
    return typeof(return).init;
}

