module sidero.base.internal.unicode.proplist;

// Generated do not modify
import sidero.base.containers.set.interval;

static immutable dchar[] Table_sidero_utf_lut_isMemberOfWhite_Space = cast(dchar[])x"000000090000000D00000020000000200000008500000085000000A0000000A00000168000001680000020000000200A00002028000020290000202F0000202F0000205F0000205F0000300000003000";

export extern(C) bool sidero_utf_lut_isMemberOfWhite_Space(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfWhite_Space.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfWhite_Space[mid << 1], end = Table_sidero_utf_lut_isMemberOfWhite_Space[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfWhite_Space_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfWhite_Space);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfBidi_Control = cast(dchar[])x"0000061C0000061C0000200E0000200F0000202A0000202E0000206600002069";

export extern(C) bool sidero_utf_lut_isMemberOfBidi_Control(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfBidi_Control.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfBidi_Control[mid << 1], end = Table_sidero_utf_lut_isMemberOfBidi_Control[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfBidi_Control_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfBidi_Control);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfJoin_Control = cast(dchar[])x"0000200C0000200D";

export extern(C) bool sidero_utf_lut_isMemberOfJoin_Control(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfJoin_Control.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfJoin_Control[mid << 1], end = Table_sidero_utf_lut_isMemberOfJoin_Control[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfJoin_Control_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfJoin_Control);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfDash = cast(dchar[])x"0000002D0000002D0000058A0000058A000005BE000005BE00001400000014000000180600001806000020100000201500002053000020530000207B0000207B0000208B0000208B000022120000221200002E1700002E1700002E1A00002E1A00002E3A00002E3B00002E4000002E4000002E5D00002E5D0000301C0000301C0000303000003030000030A0000030A00000FE310000FE320000FE580000FE580000FE630000FE630000FF0D0000FF0D00010D6E00010D6E00010EAD00010EAD";

export extern(C) bool sidero_utf_lut_isMemberOfDash(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfDash.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfDash[mid << 1], end = Table_sidero_utf_lut_isMemberOfDash[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfDash_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfDash);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfHyphen = cast(dchar[])x"0000002D0000002D000000AD000000AD0000058A0000058A0000180600001806000020100000201100002E1700002E17000030FB000030FB0000FE630000FE630000FF0D0000FF0D0000FF650000FF65";

export extern(C) bool sidero_utf_lut_isMemberOfHyphen(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfHyphen.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfHyphen[mid << 1], end = Table_sidero_utf_lut_isMemberOfHyphen[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfHyphen_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfHyphen);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfQuotation_Mark = cast(dchar[])x"00000022000000220000002700000027000000AB000000AB000000BB000000BB000020180000201F000020390000203A00002E4200002E420000300C0000300F0000301D0000301F0000FE410000FE440000FF020000FF020000FF070000FF070000FF620000FF63";

export extern(C) bool sidero_utf_lut_isMemberOfQuotation_Mark(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfQuotation_Mark.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfQuotation_Mark[mid << 1], end = Table_sidero_utf_lut_isMemberOfQuotation_Mark[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfQuotation_Mark_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfQuotation_Mark);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfTerminal_Punctuation = cast(dchar[])x"00000021000000210000002C0000002C0000002E0000002E0000003A0000003B0000003F0000003F0000037E0000037E00000387000003870000058900000589000005C3000005C30000060C0000060C0000061B0000061B0000061D0000061F000006D4000006D4000007000000070A0000070C0000070C000007F8000007F90000083000000835000008370000083E0000085E0000085E000009640000096500000E5A00000E5B00000F0800000F0800000F0D00000F120000104A0000104B00001361000013680000166E0000166E000016EB000016ED0000173500001736000017D4000017D6000017DA000017DA00001802000018050000180800001809000019440000194500001AA800001AAB00001B4E00001B4F00001B5A00001B5B00001B5D00001B5F00001B7D00001B7F00001C3B00001C3F00001C7E00001C7F00002024000020240000203C0000203D000020470000204900002CF900002CFB00002E2E00002E2E00002E3C00002E3C00002E4100002E4100002E4C00002E4C00002E4E00002E4F00002E5300002E5400003001000030020000A4FE0000A4FF0000A60D0000A60F0000A6F30000A6F70000A8760000A8770000A8CE0000A8CF0000A92F0000A92F0000A9C70000A9C90000AA5D0000AA5F0000AADF0000AADF0000AAF00000AAF10000ABEB0000ABEB0000FE120000FE120000FE150000FE160000FE500000FE520000FE540000FE570000FF010000FF010000FF0C0000FF0C0000FF0E0000FF0E0000FF1A0000FF1B0000FF1F0000FF1F0000FF610000FF610000FF640000FF640001039F0001039F000103D0000103D000010857000108570001091F0001091F00010A5600010A5700010AF000010AF500010B3A00010B3F00010B9900010B9C00010F5500010F5900010F8600010F89000110470001104D000110BE000110C10001114100011143000111C5000111C6000111CD000111CD000111DE000111DF000112380001123C000112A9000112A9000113D4000113D50001144B0001144D0001145A0001145B000115C2000115C5000115C9000115D700011641000116420001173C0001173E0001194400011944000119460001194600011A4200011A4300011A9B00011A9C00011AA100011AA200011C4100011C4300011C7100011C7100011EF700011EF800011F4300011F44000124700001247400016A6E00016A6F00016AF500016AF500016B3700016B3900016B4400016B4400016D6E00016D6F00016E9700016E980001BC9F0001BC9F0001DA870001DA8A";

export extern(C) bool sidero_utf_lut_isMemberOfTerminal_Punctuation(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfTerminal_Punctuation.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfTerminal_Punctuation[mid << 1], end = Table_sidero_utf_lut_isMemberOfTerminal_Punctuation[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfTerminal_Punctuation_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfTerminal_Punctuation);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_Math = cast(dchar[])x"0000005E0000005E000003D0000003D2000003D5000003D5000003F0000003F1000003F4000003F500002016000020160000203200002034000020400000204000002061000020640000207D0000207E0000208D0000208E000020D0000020DC000020E1000020E1000020E5000020E6000020EB000020EF000021020000210200002107000021070000210A000021130000211500002115000021190000211D000021240000212400002128000021290000212C0000212D0000212F0000213100002133000021380000213C0000213F000021450000214900002195000021990000219C0000219F000021A1000021A2000021A4000021A5000021A7000021A7000021A9000021AD000021B0000021B1000021B6000021B7000021BC000021CD000021D0000021D1000021D3000021D3000021D5000021DB000021DD000021DD000021E4000021E5000023080000230B000023B4000023B5000023B7000023B7000023D0000023D0000023E2000023E2000025A0000025A1000025AE000025B6000025BC000025C0000025C6000025C7000025CA000025CB000025CF000025D3000025E2000025E2000025E4000025E4000025E7000025EC00002605000026060000264000002640000026420000264200002660000026630000266D0000266E000027C5000027C6000027E6000027EF0000298300002998000029D8000029DB000029FC000029FD0000FE610000FE610000FE630000FE630000FE680000FE680000FF3C0000FF3C0000FF3E0000FF3E0001D4000001D4540001D4560001D49C0001D49E0001D49F0001D4A20001D4A20001D4A50001D4A60001D4A90001D4AC0001D4AE0001D4B90001D4BB0001D4BB0001D4BD0001D4C30001D4C50001D5050001D5070001D50A0001D50D0001D5140001D5160001D51C0001D51E0001D5390001D53B0001D53E0001D5400001D5440001D5460001D5460001D54A0001D5500001D5520001D6A50001D6A80001D6C00001D6C20001D6DA0001D6DC0001D6FA0001D6FC0001D7140001D7160001D7340001D7360001D74E0001D7500001D76E0001D7700001D7880001D78A0001D7A80001D7AA0001D7C20001D7C40001D7CB0001D7CE0001D7FF0001EE000001EE030001EE050001EE1F0001EE210001EE220001EE240001EE240001EE270001EE270001EE290001EE320001EE340001EE370001EE390001EE390001EE3B0001EE3B0001EE420001EE420001EE470001EE470001EE490001EE490001EE4B0001EE4B0001EE4D0001EE4F0001EE510001EE520001EE540001EE540001EE570001EE570001EE590001EE590001EE5B0001EE5B0001EE5D0001EE5D0001EE5F0001EE5F0001EE610001EE620001EE640001EE640001EE670001EE6A0001EE6C0001EE720001EE740001EE770001EE790001EE7C0001EE7E0001EE7E0001EE800001EE890001EE8B0001EE9B0001EEA10001EEA30001EEA50001EEA90001EEAB0001EEBB";

export extern(C) bool sidero_utf_lut_isMemberOfOther_Math(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_Math.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_Math[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_Math[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Math_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_Math);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfHex_Digit = cast(dchar[])x"0000003000000039000000410000004600000061000000660000FF100000FF190000FF210000FF260000FF410000FF46";

export extern(C) bool sidero_utf_lut_isMemberOfHex_Digit(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfHex_Digit.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfHex_Digit[mid << 1], end = Table_sidero_utf_lut_isMemberOfHex_Digit[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfHex_Digit_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfHex_Digit);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfASCII_Hex_Digit = cast(dchar[])x"000000300000003900000041000000460000006100000066";

export extern(C) bool sidero_utf_lut_isMemberOfASCII_Hex_Digit(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfASCII_Hex_Digit.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfASCII_Hex_Digit[mid << 1], end = Table_sidero_utf_lut_isMemberOfASCII_Hex_Digit[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfASCII_Hex_Digit_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfASCII_Hex_Digit);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_Alphabetic = cast(dchar[])x"0000034500000345000003630000036F000005B0000005BD000005BF000005BF000005C1000005C2000005C4000005C5000005C7000005C7000006100000061A0000064B00000657000006590000065F0000067000000670000006D6000006DC000006E1000006E4000006E7000006E8000006ED000006ED0000071100000711000007300000073F000007A6000007B000000816000008170000081B000008230000082500000827000008290000082C0000089700000897000008D4000008DF000008E3000008E9000008F0000009030000093A0000093B0000093E0000094C0000094E0000094F000009550000095700000962000009630000098100000983000009BE000009C4000009C7000009C8000009CB000009CC000009D7000009D7000009E2000009E300000A0100000A0300000A3E00000A4200000A4700000A4800000A4B00000A4C00000A5100000A5100000A7000000A7100000A7500000A7500000A8100000A8300000ABE00000AC500000AC700000AC900000ACB00000ACC00000AE200000AE300000AFA00000AFC00000B0100000B0300000B3E00000B4400000B4700000B4800000B4B00000B4C00000B5600000B5700000B6200000B6300000B8200000B8200000BBE00000BC200000BC600000BC800000BCA00000BCC00000BD700000BD700000C0000000C0400000C3E00000C4400000C4600000C4800000C4A00000C4C00000C5500000C5600000C6200000C6300000C8100000C8300000CBE00000CC400000CC600000CC800000CCA00000CCC00000CD500000CD600000CE200000CE300000CF300000CF300000D0000000D0300000D3E00000D4400000D4600000D4800000D4A00000D4C00000D5700000D5700000D6200000D6300000D8100000D8300000DCF00000DD400000DD600000DD600000DD800000DDF00000DF200000DF300000E3100000E3100000E3400000E3A00000E4D00000E4D00000EB100000EB100000EB400000EB900000EBB00000EBC00000ECD00000ECD00000F7100000F8300000F8D00000F9700000F9900000FBC0000102B0000103600001038000010380000103B0000103E00001056000010590000105E000010600000106200001064000010670000106D0000107100001074000010820000108D0000108F0000108F0000109A0000109D0000171200001713000017320000173300001752000017530000177200001773000017B6000017C80000188500001886000018A9000018A9000019200000192B000019300000193800001A1700001A1B00001A5500001A5E00001A6100001A7400001ABF00001AC000001ACC00001ACE00001B0000001B0400001B3500001B4300001B8000001B8200001BA100001BA900001BAC00001BAD00001BE700001BF100001C2400001C3600001DD300001DF4000024B6000024E900002DE000002DFF0000A6740000A67B0000A69E0000A69F0000A8020000A8020000A80B0000A80B0000A8230000A8270000A8800000A8810000A8B40000A8C30000A8C50000A8C50000A8FF0000A8FF0000A9260000A92A0000A9470000A9520000A9800000A9830000A9B40000A9BF0000A9E50000A9E50000AA290000AA360000AA430000AA430000AA4C0000AA4D0000AA7B0000AA7D0000AAB00000AAB00000AAB20000AAB40000AAB70000AAB80000AABE0000AABE0000AAEB0000AAEF0000AAF50000AAF50000ABE30000ABEA0000FB1E0000FB1E000103760001037A00010A0100010A0300010A0500010A0600010A0C00010A0F00010D2400010D2700010D6900010D6900010EAB00010EAC00010EFC00010EFC0001100000011002000110380001104500011073000110740001108000011082000110B0000110B8000110C2000110C20001110000011102000111270001113200011145000111460001118000011182000111B3000111BF000111CE000111CF0001122C0001123400011237000112370001123E0001123E0001124100011241000112DF000112E800011300000113030001133E0001134400011347000113480001134B0001134C00011357000113570001136200011363000113B8000113C0000113C2000113C2000113C5000113C5000113C7000113CA000113CC000113CD00011435000114410001144300011445000114B0000114C1000115AF000115B5000115B8000115BE000115DC000115DD000116300001163E0001164000011640000116AB000116B50001171D0001172A0001182C00011838000119300001193500011937000119380001193B0001193C00011940000119400001194200011942000119D1000119D7000119DA000119DF000119E4000119E400011A0100011A0A00011A3500011A3900011A3B00011A3E00011A5100011A5B00011A8A00011A9700011C2F00011C3600011C3800011C3E00011C9200011CA700011CA900011CB600011D3100011D3600011D3A00011D3A00011D3C00011D3D00011D3F00011D4100011D4300011D4300011D4700011D4700011D8A00011D8E00011D9000011D9100011D9300011D9600011EF300011EF600011F0000011F0100011F0300011F0300011F3400011F3A00011F3E00011F400001611E0001612E00016F4F00016F4F00016F5100016F8700016F8F00016F9200016FF000016FF10001BC9E0001BC9E0001E0000001E0060001E0080001E0180001E01B0001E0210001E0230001E0240001E0260001E02A0001E08F0001E08F0001E9470001E9470001F1300001F1490001F1500001F1690001F1700001F189";

export extern(C) bool sidero_utf_lut_isMemberOfOther_Alphabetic(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_Alphabetic.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_Alphabetic[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_Alphabetic[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Alphabetic_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_Alphabetic);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfIdeographic = cast(dchar[])x"00003006000030070000302100003029000030380000303A0000340000004DBF00004E0000009FFF0000F9000000FA6D0000FA700000FAD900016FE400016FE400017000000187F70001880000018CD500018CFF00018D080001B1700001B2FB000200000002A6DF0002A7000002B7390002B7400002B81D0002B8200002CEA10002CEB00002EBE00002EBF00002EE5D0002F8000002FA1D000300000003134A00031350000323AF";

export extern(C) bool sidero_utf_lut_isMemberOfIdeographic(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfIdeographic.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfIdeographic[mid << 1], end = Table_sidero_utf_lut_isMemberOfIdeographic[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIdeographic_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfIdeographic);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfDiacritic = cast(dchar[])x"0000005E0000005E0000006000000060000000A8000000A8000000AF000000AF000000B4000000B4000000B7000000B8000002B00000034E00000350000003570000035D0000036200000374000003750000037A0000037A00000384000003850000048300000487000005590000055900000591000005A1000005A3000005BD000005BF000005BF000005C1000005C2000005C4000005C40000064B000006520000065700000658000006DF000006E0000006E5000006E6000006EA000006EC000007300000074A000007A6000007B0000007EB000007F50000081800000819000008980000089F000008C9000008D2000008E3000008FE0000093C0000093C0000094D0000094D00000951000009540000097100000971000009BC000009BC000009CD000009CD00000A3C00000A3C00000A4D00000A4D00000ABC00000ABC00000ACD00000ACD00000AFD00000AFF00000B3C00000B3C00000B4D00000B4D00000B5500000B5500000BCD00000BCD00000C3C00000C3C00000C4D00000C4D00000CBC00000CBC00000CCD00000CCD00000D3B00000D3C00000D4D00000D4D00000DCA00000DCA00000E3A00000E3A00000E4700000E4C00000E4E00000E4E00000EBA00000EBA00000EC800000ECC00000F1800000F1900000F3500000F3500000F3700000F3700000F3900000F3900000F3E00000F3F00000F8200000F8400000F8600000F8700000FC600000FC60000103700001037000010390000103A0000106300001064000010690000106D000010870000108D0000108F0000108F0000109A0000109B0000135D0000135F00001714000017150000173400001734000017C9000017D3000017DD000017DD000019390000193B00001A6000001A6000001A7500001A7C00001A7F00001A7F00001AB000001ABE00001AC100001ACB00001B3400001B3400001B4400001B4400001B6B00001B7300001BAA00001BAB00001BE600001BE600001BF200001BF300001C3600001C3700001C7800001C7D00001CD000001CE800001CED00001CED00001CF400001CF400001CF700001CF900001D2C00001D6A00001DC400001DCF00001DF500001DFF00001FBD00001FBD00001FBF00001FC100001FCD00001FCF00001FDD00001FDF00001FED00001FEF00001FFD00001FFE00002CEF00002CF100002E2F00002E2F0000302A0000302F000030990000309C000030FC000030FC0000A66F0000A66F0000A67C0000A67D0000A67F0000A67F0000A69C0000A69D0000A6F00000A6F10000A7000000A7210000A7880000A78A0000A7F80000A7F90000A8060000A8060000A82C0000A82C0000A8C40000A8C40000A8E00000A8F10000A92B0000A92E0000A9530000A9530000A9B30000A9B30000A9C00000A9C00000A9E50000A9E50000AA7B0000AA7D0000AABF0000AAC20000AAF60000AAF60000AB5B0000AB5F0000AB690000AB6B0000ABEC0000ABED0000FB1E0000FB1E0000FE200000FE2F0000FF3E0000FF3E0000FF400000FF400000FF700000FF700000FF9E0000FF9F0000FFE30000FFE3000102E0000102E0000107800001078500010787000107B0000107B2000107BA00010A3800010A3A00010A3F00010A3F00010AE500010AE600010D2200010D2700010D4E00010D4E00010D6900010D6D00010EFD00010EFF00010F4600010F5000010F8200010F8500011046000110460001107000011070000110B9000110BA00011133000111340001117300011173000111C0000111C0000111CA000111CC0001123500011236000112E9000112EA0001133B0001133C0001134D0001134D000113660001136C0001137000011374000113CE000113D0000113D2000113D3000113E1000113E200011442000114420001144600011446000114C2000114C3000115BF000115C00001163F0001163F000116B6000116B70001172B0001172B000118390001183A0001193D0001193E0001194300011943000119E0000119E000011A3400011A3400011A4700011A4700011A9900011A9900011C3F00011C3F00011D4200011D4200011D4400011D4500011D9700011D9700011F4100011F4200011F5A00011F5A00013447000134550001612F0001612F00016AF000016AF400016B3000016B3600016D6B00016D6C00016F8F00016F9F00016FF000016FF10001AFF00001AFF30001AFF50001AFFB0001AFFD0001AFFE0001CF000001CF2D0001CF300001CF460001D1670001D1690001D16D0001D1720001D17B0001D1820001D1850001D18B0001D1AA0001D1AD0001E0300001E06D0001E1300001E1360001E2AE0001E2AE0001E2EC0001E2EF0001E5EE0001E5EF0001E8D00001E8D60001E9440001E9460001E9480001E94A";

export extern(C) bool sidero_utf_lut_isMemberOfDiacritic(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfDiacritic.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfDiacritic[mid << 1], end = Table_sidero_utf_lut_isMemberOfDiacritic[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfDiacritic_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfDiacritic);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfExtender = cast(dchar[])x"000000B7000000B7000002D0000002D10000064000000640000007FA000007FA00000A7100000A7100000AFB00000AFB00000B5500000B5500000E4600000E4600000EC600000EC60000180A0000180A000018430000184300001AA700001AA700001C3600001C3600001C7B00001C7B000030050000300500003031000030350000309D0000309E000030FC000030FE0000A0150000A0150000A60C0000A60C0000A9CF0000A9CF0000A9E60000A9E60000AA700000AA700000AADD0000AADD0000AAF30000AAF40000FF700000FF70000107810001078200010D4E00010D4E00010D6A00010D6A00010D6F00010D6F00011237000112370001135D0001135D000113D2000113D3000115C6000115C800011A9800011A9800016B4200016B4300016FE000016FE100016FE300016FE30001E13C0001E13D0001E5EF0001E5EF0001E9440001E946";

export extern(C) bool sidero_utf_lut_isMemberOfExtender(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfExtender.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfExtender[mid << 1], end = Table_sidero_utf_lut_isMemberOfExtender[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfExtender_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfExtender);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_Lowercase = cast(dchar[])x"000000AA000000AA000000BA000000BA000002B0000002B8000002C0000002C1000002E0000002E400000345000003450000037A0000037A000010FC000010FC00001D2C00001D6A00001D7800001D7800001D9B00001DBF00002071000020710000207F0000207F000020900000209C000021700000217F000024D0000024E900002C7C00002C7D0000A69C0000A69D0000A7700000A7700000A7F20000A7F40000A7F80000A7F90000AB5C0000AB5F0000AB690000AB690001078000010780000107830001078500010787000107B0000107B2000107BA0001E0300001E06D";

export extern(C) bool sidero_utf_lut_isMemberOfOther_Lowercase(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_Lowercase.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_Lowercase[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_Lowercase[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Lowercase_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_Lowercase);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_Uppercase = cast(dchar[])x"000021600000216F000024B6000024CF0001F1300001F1490001F1500001F1690001F1700001F189";

export extern(C) bool sidero_utf_lut_isMemberOfOther_Uppercase(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_Uppercase.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_Uppercase[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_Uppercase[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Uppercase_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_Uppercase);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfNoncharacter_Code_Point = cast(dchar[])x"0000FDD00000FDEF0000FFFE0000FFFF0001FFFE0001FFFF0002FFFE0002FFFF0003FFFE0003FFFF0004FFFE0004FFFF0005FFFE0005FFFF0006FFFE0006FFFF0007FFFE0007FFFF0008FFFE0008FFFF0009FFFE0009FFFF000AFFFE000AFFFF000BFFFE000BFFFF000CFFFE000CFFFF000DFFFE000DFFFF000EFFFE000EFFFF000FFFFE000FFFFF0010FFFE0010FFFF";

export extern(C) bool sidero_utf_lut_isMemberOfNoncharacter_Code_Point(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfNoncharacter_Code_Point.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfNoncharacter_Code_Point[mid << 1], end = Table_sidero_utf_lut_isMemberOfNoncharacter_Code_Point[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfNoncharacter_Code_Point_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfNoncharacter_Code_Point);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_Grapheme_Extend = cast(dchar[])x"000009BE000009BE000009D7000009D700000B3E00000B3E00000B5700000B5700000BBE00000BBE00000BD700000BD700000CC000000CC000000CC200000CC200000CC700000CC800000CCA00000CCB00000CD500000CD600000D3E00000D3E00000D5700000D5700000DCF00000DCF00000DDF00000DDF0000171500001715000017340000173400001B3500001B3500001B3B00001B3B00001B3D00001B3D00001B4300001B4400001BAA00001BAA00001BF200001BF30000200C0000200C0000302E0000302F0000A9530000A9530000A9C00000A9C00000FF9E0000FF9F000111C0000111C000011235000112350001133E0001133E0001134D0001134D0001135700011357000113B8000113B8000113C2000113C2000113C5000113C5000113C7000113C9000113CF000113CF000114B0000114B0000114BD000114BD000115AF000115AF000116B6000116B600011930000119300001193D0001193D00011F4100011F4100016FF000016FF10001D1650001D1660001D16D0001D172000E0020000E007F";

export extern(C) bool sidero_utf_lut_isMemberOfOther_Grapheme_Extend(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_Grapheme_Extend.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_Grapheme_Extend[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_Grapheme_Extend[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Grapheme_Extend_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_Grapheme_Extend);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfIDS_Binary_Operator = cast(dchar[])x"00002FF000002FF100002FF400002FFD000031EF000031EF";

export extern(C) bool sidero_utf_lut_isMemberOfIDS_Binary_Operator(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfIDS_Binary_Operator.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfIDS_Binary_Operator[mid << 1], end = Table_sidero_utf_lut_isMemberOfIDS_Binary_Operator[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIDS_Binary_Operator_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfIDS_Binary_Operator);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfIDS_Trinary_Operator = cast(dchar[])x"00002FF200002FF3";

export extern(C) bool sidero_utf_lut_isMemberOfIDS_Trinary_Operator(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfIDS_Trinary_Operator.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfIDS_Trinary_Operator[mid << 1], end = Table_sidero_utf_lut_isMemberOfIDS_Trinary_Operator[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIDS_Trinary_Operator_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfIDS_Trinary_Operator);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfIDS_Unary_Operator = cast(dchar[])x"00002FFE00002FFF";

export extern(C) bool sidero_utf_lut_isMemberOfIDS_Unary_Operator(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfIDS_Unary_Operator.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfIDS_Unary_Operator[mid << 1], end = Table_sidero_utf_lut_isMemberOfIDS_Unary_Operator[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfIDS_Unary_Operator_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfIDS_Unary_Operator);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfRadical = cast(dchar[])x"00002E8000002E9900002E9B00002EF300002F0000002FD5";

export extern(C) bool sidero_utf_lut_isMemberOfRadical(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfRadical.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfRadical[mid << 1], end = Table_sidero_utf_lut_isMemberOfRadical[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfRadical_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfRadical);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfUnified_Ideograph = cast(dchar[])x"0000340000004DBF00004E0000009FFF0000FA0E0000FA0F0000FA110000FA110000FA130000FA140000FA1F0000FA1F0000FA210000FA210000FA230000FA240000FA270000FA29000200000002A6DF0002A7000002B7390002B7400002B81D0002B8200002CEA10002CEB00002EBE00002EBF00002EE5D000300000003134A00031350000323AF";

export extern(C) bool sidero_utf_lut_isMemberOfUnified_Ideograph(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfUnified_Ideograph.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfUnified_Ideograph[mid << 1], end = Table_sidero_utf_lut_isMemberOfUnified_Ideograph[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfUnified_Ideograph_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfUnified_Ideograph);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point = cast(dchar[])x"0000034F0000034F0000115F00001160000017B4000017B5000020650000206500003164000031640000FFA00000FFA00000FFF00000FFF8000E0000000E0000000E0002000E001F000E0080000E00FF000E01F0000E0FFF";

export extern(C) bool sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_Default_Ignorable_Code_Point);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfDeprecated = cast(dchar[])x"0000014900000149000006730000067300000F7700000F7700000F7900000F79000017A3000017A40000206A0000206F000023290000232A000E0001000E0001";

export extern(C) bool sidero_utf_lut_isMemberOfDeprecated(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfDeprecated.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfDeprecated[mid << 1], end = Table_sidero_utf_lut_isMemberOfDeprecated[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfDeprecated_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfDeprecated);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfSoft_Dotted = cast(dchar[])x"000000690000006A0000012F0000012F000002490000024900000268000002680000029D0000029D000002B2000002B2000003F3000003F30000045600000456000004580000045800001D6200001D6200001D9600001D9600001DA400001DA400001DA800001DA800001E2D00001E2D00001ECB00001ECB0000207100002071000021480000214900002C7C00002C7C0001D4220001D4230001D4560001D4570001D48A0001D48B0001D4BE0001D4BF0001D4F20001D4F30001D5260001D5270001D55A0001D55B0001D58E0001D58F0001D5C20001D5C30001D5F60001D5F70001D62A0001D62B0001D65E0001D65F0001D6920001D6930001DF1A0001DF1A0001E04C0001E04D0001E0680001E068";

export extern(C) bool sidero_utf_lut_isMemberOfSoft_Dotted(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfSoft_Dotted.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfSoft_Dotted[mid << 1], end = Table_sidero_utf_lut_isMemberOfSoft_Dotted[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfSoft_Dotted_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfSoft_Dotted);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfLogical_Order_Exception = cast(dchar[])x"00000E4000000E4400000EC000000EC4000019B5000019B7000019BA000019BA0000AAB50000AAB60000AAB90000AAB90000AABB0000AABC";

export extern(C) bool sidero_utf_lut_isMemberOfLogical_Order_Exception(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfLogical_Order_Exception.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfLogical_Order_Exception[mid << 1], end = Table_sidero_utf_lut_isMemberOfLogical_Order_Exception[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfLogical_Order_Exception_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfLogical_Order_Exception);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_ID_Start = cast(dchar[])x"000018850000188600002118000021180000212E0000212E0000309B0000309C";

export extern(C) bool sidero_utf_lut_isMemberOfOther_ID_Start(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_ID_Start.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_ID_Start[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_ID_Start[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_ID_Start_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_ID_Start);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfOther_ID_Continue = cast(dchar[])x"000000B7000000B700000387000003870000136900001371000019DA000019DA0000200C0000200D000030FB000030FB0000FF650000FF65";

export extern(C) bool sidero_utf_lut_isMemberOfOther_ID_Continue(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfOther_ID_Continue.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfOther_ID_Continue[mid << 1], end = Table_sidero_utf_lut_isMemberOfOther_ID_Continue[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfOther_ID_Continue_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfOther_ID_Continue);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfSentence_Terminal = cast(dchar[])x"00000021000000210000002E0000002E0000003F0000003F00000589000005890000061D0000061F000006D4000006D40000070000000702000007F9000007F9000008370000083700000839000008390000083D0000083E00000964000009650000104A0000104B000013620000136200001367000013680000166E0000166E0000173500001736000017D4000017D500001803000018030000180900001809000019440000194500001AA800001AAB00001B4E00001B4F00001B5A00001B5B00001B5E00001B5F00001B7D00001B7F00001C3B00001C3C00001C7E00001C7F00002024000020240000203C0000203D000020470000204900002CF900002CFB00002E2E00002E2E00002E3C00002E3C00002E5300002E5400003002000030020000A4FF0000A4FF0000A60E0000A60F0000A6F30000A6F30000A6F70000A6F70000A8760000A8770000A8CE0000A8CF0000A92F0000A92F0000A9C80000A9C90000AA5D0000AA5F0000AAF00000AAF10000ABEB0000ABEB0000FE120000FE120000FE150000FE160000FE520000FE520000FE560000FE570000FF010000FF010000FF0E0000FF0E0000FF1F0000FF1F0000FF610000FF6100010A5600010A5700010F5500010F5900010F8600010F890001104700011048000110BE000110C10001114100011143000111C5000111C6000111CD000111CD000111DE000111DF00011238000112390001123B0001123C000112A9000112A9000113D4000113D50001144B0001144C000115C2000115C3000115C9000115D700011641000116420001173C0001173E0001194400011944000119460001194600011A4200011A4300011A9B00011A9C00011C4100011C4200011EF700011EF800011F4300011F4400016A6E00016A6F00016AF500016AF500016B3700016B3800016B4400016B4400016D6E00016D6F00016E9800016E980001BC9F0001BC9F0001DA880001DA88";

export extern(C) bool sidero_utf_lut_isMemberOfSentence_Terminal(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfSentence_Terminal.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfSentence_Terminal[mid << 1], end = Table_sidero_utf_lut_isMemberOfSentence_Terminal[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfSentence_Terminal_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfSentence_Terminal);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfVariation_Selector = cast(dchar[])x"0000180B0000180D0000180F0000180F0000FE000000FE0F000E0100000E01EF";

export extern(C) bool sidero_utf_lut_isMemberOfVariation_Selector(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfVariation_Selector.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfVariation_Selector[mid << 1], end = Table_sidero_utf_lut_isMemberOfVariation_Selector[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfVariation_Selector_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfVariation_Selector);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfPattern_White_Space = cast(dchar[])x"000000090000000D000000200000002000000085000000850000200E0000200F0000202800002029";

export extern(C) bool sidero_utf_lut_isMemberOfPattern_White_Space(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfPattern_White_Space.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfPattern_White_Space[mid << 1], end = Table_sidero_utf_lut_isMemberOfPattern_White_Space[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfPattern_White_Space_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfPattern_White_Space);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfPattern_Syntax = cast(dchar[])x"000000210000002F0000003A000000400000005B0000005E00000060000000600000007B0000007E000000A1000000A7000000A9000000A9000000AB000000AC000000AE000000AE000000B0000000B1000000B6000000B6000000BB000000BB000000BF000000BF000000D7000000D7000000F7000000F70000201000002027000020300000203E0000204100002053000020550000205E000021900000245F00002500000027750000279400002BFF00002E0000002E7F0000300100003003000030080000302000003030000030300000FD3E0000FD3F0000FE450000FE46";

export extern(C) bool sidero_utf_lut_isMemberOfPattern_Syntax(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfPattern_Syntax.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfPattern_Syntax[mid << 1], end = Table_sidero_utf_lut_isMemberOfPattern_Syntax[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfPattern_Syntax_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfPattern_Syntax);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark = cast(dchar[])x"0000060000000605000006DD000006DD0000070F0000070F0000089000000891000008E2000008E2000110BD000110BD000110CD000110CD";

export extern(C) bool sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark[mid << 1], end = Table_sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfPrepended_Concatenation_Mark);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfRegional_Indicator = cast(dchar[])x"0001F1E60001F1FF";

export extern(C) bool sidero_utf_lut_isMemberOfRegional_Indicator(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfRegional_Indicator.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfRegional_Indicator[mid << 1], end = Table_sidero_utf_lut_isMemberOfRegional_Indicator[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfRegional_Indicator_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfRegional_Indicator);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfID_Compat_Math_Start = cast(dchar[])x"000022020000220200002207000022070000221E0000221E0001D6C10001D6C10001D6DB0001D6DB0001D6FB0001D6FB0001D7150001D7150001D7350001D7350001D74F0001D74F0001D76F0001D76F0001D7890001D7890001D7A90001D7A90001D7C30001D7C3";

export extern(C) bool sidero_utf_lut_isMemberOfID_Compat_Math_Start(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfID_Compat_Math_Start.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfID_Compat_Math_Start[mid << 1], end = Table_sidero_utf_lut_isMemberOfID_Compat_Math_Start[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfID_Compat_Math_Start_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfID_Compat_Math_Start);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfID_Compat_Math_Continue = cast(dchar[])x"000000B2000000B3000000B9000000B90000207000002070000020740000207E000020800000208E000022020000220200002207000022070000221E0000221E0001D6C10001D6C10001D6DB0001D6DB0001D6FB0001D6FB0001D7150001D7150001D7350001D7350001D74F0001D74F0001D76F0001D76F0001D7890001D7890001D7A90001D7A90001D7C30001D7C3";

export extern(C) bool sidero_utf_lut_isMemberOfID_Compat_Math_Continue(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfID_Compat_Math_Continue.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfID_Compat_Math_Continue[mid << 1], end = Table_sidero_utf_lut_isMemberOfID_Compat_Math_Continue[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfID_Compat_Math_Continue_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfID_Compat_Math_Continue);
    return cast(IntervalSet!dchar)Set;
}

static immutable dchar[] Table_sidero_utf_lut_isMemberOfModifier_Combining_Mark = cast(dchar[])x"00000654000006550000065800000658000006DC000006DC000006E3000006E3000006E7000006E8000008CA000008CB000008CD000008CF000008D3000008D3000008F3000008F3";

export extern(C) bool sidero_utf_lut_isMemberOfModifier_Combining_Mark(dchar against) @trusted nothrow @nogc pure {
    ptrdiff_t low, high = Table_sidero_utf_lut_isMemberOfModifier_Combining_Mark.length / 2;

    while(low < high) {
        const mid = low + (high - low) / 2;
        const start = Table_sidero_utf_lut_isMemberOfModifier_Combining_Mark[mid << 1], end = Table_sidero_utf_lut_isMemberOfModifier_Combining_Mark[(mid << 1) | 1];

        if (against >= start && against <= end)
            return true;
        else if (against > end)
            low = mid + 1;
        else if (against < start)
            high = mid;
    }

    return false;
}
export extern(C) IntervalSet!dchar sidero_utf_lut_isMemberOfModifier_Combining_Mark_Set() @trusted nothrow @nogc {
    static IntervalSet!dchar Set = IntervalSet!dchar.constructCTFE(cast(dstring)Table_sidero_utf_lut_isMemberOfModifier_Combining_Mark);
    return cast(IntervalSet!dchar)Set;
}
