module sidero.base.internal.unicode.unicodedataCCC;

// Generated do not modify
export extern(C) immutable(ubyte) sidero_utf_lut_getCCC(dchar input) @trusted nothrow @nogc pure {
    if (input >= 0x0 && input <= 0x309A) {
        if (input <= 0x3A1) {
            if (input <= 0x2FF)
                return cast(ubyte)0;
            else if (input >= 0x300 && input <= 0x314)
                return cast(ubyte)230;
            else if (input >= 0x315 && input <= 0x328)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(0 + (input - 0x315))];
            else if (input >= 0x329 && input <= 0x333)
                return cast(ubyte)220;
            else if (input >= 0x334 && input <= 0x33C)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(20 + (input - 0x334))];
            else if (input >= 0x33D && input <= 0x344)
                return cast(ubyte)230;
            else if (input >= 0x345 && input <= 0x362)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(29 + (input - 0x345))];
            else if (input >= 0x363 && input <= 0x36F)
                return cast(ubyte)230;
            else if (input >= 0x370)
                return cast(ubyte)0;
        } else if (input >= 0x3A3 && input <= 0x58F) {
            if (input <= 0x487)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(59 + (input - 0x3A3))];
            else if (input >= 0x488)
                return cast(ubyte)0;
        } else if (input >= 0x591 && input <= 0x5C7) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(288 + (input - 0x591))];
        } else if (input >= 0x5D0 && input <= 0x5F4) {
            return cast(ubyte)0;
        } else if (input >= 0x600 && input <= 0x74A) {
            if (input <= 0x60F)
                return cast(ubyte)0;
            else if (input >= 0x610 && input <= 0x617)
                return cast(ubyte)230;
            else if (input >= 0x618 && input <= 0x65F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(343 + (input - 0x618))];
            else if (input >= 0x660 && input <= 0x66F)
                return cast(ubyte)0;
            else if (input >= 0x670 && input <= 0x6ED)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(415 + (input - 0x670))];
            else if (input >= 0x6EE && input <= 0x710)
                return cast(ubyte)0;
            else if (input >= 0x711)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(541 + (input - 0x711))];
        } else if (input >= 0x74D && input <= 0x7B1) {
            return cast(ubyte)0;
        } else if (input >= 0x7C0 && input <= 0x82D) {
            if (input <= 0x7F3)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(599 + (input - 0x7C0))];
            else if (input >= 0x7F4 && input <= 0x7FC)
                return cast(ubyte)0;
            else if (input >= 0x7FD && input <= 0x81A)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(651 + (input - 0x7FD))];
            else if (input >= 0x81B && input <= 0x823)
                return cast(ubyte)230;
            else if (input >= 0x824)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(681 + (input - 0x824))];
        } else if (input >= 0x830 && input <= 0x83E) {
            return cast(ubyte)0;
        } else if (input >= 0x840 && input <= 0x85B) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(691 + (input - 0x840))];
        } else if (input >= 0x85E && input <= 0x86A) {
            return cast(ubyte)0;
        } else if (input >= 0x870 && input <= 0x891) {
            return cast(ubyte)0;
        } else if (input >= 0x897 && input <= 0x9B9) {
            if (input <= 0x89F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(719 + (input - 0x897))];
            else if (input >= 0x8A0 && input <= 0x8C9)
                return cast(ubyte)0;
            else if (input >= 0x8CA && input <= 0x8D3)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(728 + (input - 0x8CA))];
            else if (input >= 0x8D4 && input <= 0x8E1)
                return cast(ubyte)230;
            else if (input >= 0x8E2 && input <= 0x8FF)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(738 + (input - 0x8E2))];
            else if (input >= 0x900 && input <= 0x93B)
                return cast(ubyte)0;
            else if (input >= 0x93C && input <= 0x954)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(768 + (input - 0x93C))];
            else if (input >= 0x955)
                return cast(ubyte)0;
        } else if (input >= 0x9BC && input <= 0x9C4) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(793 + (input - 0x9BC))];
        } else if (input >= 0x9C7 && input <= 0x9C8) {
            return cast(ubyte)0;
        } else if (input >= 0x9CB && input <= 0x9CE) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(802 + (input - 0x9CB))];
        } else if (input >= 0x9D7 && input <= 0x9E3) {
            return cast(ubyte)0;
        } else if (input >= 0x9E6 && input <= 0x9FE) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(806 + (input - 0x9E6))];
        } else if (input >= 0xA01 && input <= 0xA39) {
            return cast(ubyte)0;
        } else if (input == 0xA3C) {
            return cast(ubyte)7;
        } else if (input >= 0xA3E && input <= 0xA48) {
            return cast(ubyte)0;
        } else if (input >= 0xA4B && input <= 0xA4D) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(831 + (input - 0xA4B))];
        } else if (input == 0xA51) {
            return cast(ubyte)0;
        } else if (input >= 0xA59 && input <= 0xA5E) {
            return cast(ubyte)0;
        } else if (input >= 0xA66 && input <= 0xA76) {
            return cast(ubyte)0;
        } else if (input >= 0xA81 && input <= 0xAB9) {
            return cast(ubyte)0;
        } else if (input >= 0xABC && input <= 0xAC5) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(834 + (input - 0xABC))];
        } else if (input >= 0xAC7 && input <= 0xAC9) {
            return cast(ubyte)0;
        } else if (input >= 0xACB && input <= 0xACD) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(844 + (input - 0xACB))];
        } else if (input == 0xAD0) {
            return cast(ubyte)0;
        } else if (input >= 0xAE0 && input <= 0xAF1) {
            return cast(ubyte)0;
        } else if (input >= 0xAF9 && input <= 0xB39) {
            return cast(ubyte)0;
        } else if (input >= 0xB3C && input <= 0xB44) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(847 + (input - 0xB3C))];
        } else if (input >= 0xB47 && input <= 0xB48) {
            return cast(ubyte)0;
        } else if (input >= 0xB4B && input <= 0xB4D) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(856 + (input - 0xB4B))];
        } else if (input >= 0xB55 && input <= 0xB77) {
            return cast(ubyte)0;
        } else if (input >= 0xB82 && input <= 0xBC8) {
            return cast(ubyte)0;
        } else if (input >= 0xBCA && input <= 0xBCD) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(859 + (input - 0xBCA))];
        } else if (input >= 0xBD0 && input <= 0xBD7) {
            if (input == 0xBD0)
                return cast(ubyte)0;
            else if (input == 0xBD7)
                return cast(ubyte)0;
        } else if (input >= 0xBE6 && input <= 0xBFA) {
            return cast(ubyte)0;
        } else if (input >= 0xC00 && input <= 0xC39) {
            return cast(ubyte)0;
        } else if (input >= 0xC3C && input <= 0xC44) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(863 + (input - 0xC3C))];
        } else if (input >= 0xC46 && input <= 0xC48) {
            return cast(ubyte)0;
        } else if (input >= 0xC4A && input <= 0xC4D) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(872 + (input - 0xC4A))];
        } else if (input >= 0xC55 && input <= 0xC56) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(876 + (input - 0xC55))];
        } else if (input >= 0xC58 && input <= 0xC6F) {
            return cast(ubyte)0;
        } else if (input >= 0xC77 && input <= 0xCB9) {
            return cast(ubyte)0;
        } else if (input >= 0xCBC && input <= 0xCC4) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(878 + (input - 0xCBC))];
        } else if (input >= 0xCC6 && input <= 0xCC8) {
            return cast(ubyte)0;
        } else if (input >= 0xCCA && input <= 0xCCD) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(887 + (input - 0xCCA))];
        } else if (input >= 0xCD5 && input <= 0xCD6) {
            return cast(ubyte)0;
        } else if (input >= 0xCDD && input <= 0xCF3) {
            return cast(ubyte)0;
        } else if (input >= 0xD00 && input <= 0xD10) {
            return cast(ubyte)0;
        } else if (input >= 0xD12 && input <= 0xD48) {
            if (input <= 0xD3C)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(891 + (input - 0xD12))];
            else if (input >= 0xD3D)
                return cast(ubyte)0;
        } else if (input >= 0xD4A && input <= 0xD4F) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(934 + (input - 0xD4A))];
        } else if (input >= 0xD54 && input <= 0xDC6) {
            return cast(ubyte)0;
        } else if (input == 0xDCA) {
            return cast(ubyte)9;
        } else if (input >= 0xDCF && input <= 0xDDF) {
            return cast(ubyte)0;
        } else if (input >= 0xDE6 && input <= 0xDF4) {
            return cast(ubyte)0;
        } else if (input >= 0xE01 && input <= 0xE5B) {
            if (input <= 0xE3A)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(940 + (input - 0xE01))];
            else if (input >= 0xE3B && input <= 0xE47)
                return cast(ubyte)0;
            else if (input >= 0xE48 && input <= 0xE4B)
                return cast(ubyte)107;
            else if (input >= 0xE4C)
                return cast(ubyte)0;
        } else if (input >= 0xE81 && input <= 0xEA5) {
            return cast(ubyte)0;
        } else if (input >= 0xEA7 && input <= 0xEBD) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(998 + (input - 0xEA7))];
        } else if (input >= 0xEC0 && input <= 0xEC6) {
            return cast(ubyte)0;
        } else if (input >= 0xEC8 && input <= 0xECE) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1021 + (input - 0xEC8))];
        } else if (input >= 0xED0 && input <= 0xEDF) {
            return cast(ubyte)0;
        } else if (input >= 0xF00 && input <= 0xF47) {
            if (input <= 0xF19)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1028 + (input - 0xF00))];
            else if (input >= 0xF1A && input <= 0xF34)
                return cast(ubyte)0;
            else if (input >= 0xF35)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1054 + (input - 0xF35))];
        } else if (input >= 0xF49 && input <= 0xF6C) {
            return cast(ubyte)0;
        } else if (input >= 0xF71 && input <= 0xFBC) {
            if (input <= 0xF87)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1073 + (input - 0xF71))];
            else if (input >= 0xF88)
                return cast(ubyte)0;
        } else if (input >= 0xFBE && input <= 0xFCC) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1096 + (input - 0xFBE))];
        } else if (input >= 0xFCE && input <= 0xFDA) {
            return cast(ubyte)0;
        } else if (input >= 0x1000 && input <= 0x10C5) {
            if (input <= 0x103A)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1111 + (input - 0x1000))];
            else if (input >= 0x103B && input <= 0x108C)
                return cast(ubyte)0;
            else if (input >= 0x108D)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1170 + (input - 0x108D))];
        } else if (input == 0x10C7) {
            return cast(ubyte)0;
        } else if (input >= 0x10CD && input <= 0x135A) {
            return cast(ubyte)0;
        } else if (input >= 0x135D && input <= 0x16F8) {
            if (input <= 0x135F)
                return cast(ubyte)230;
            else if (input >= 0x1360)
                return cast(ubyte)0;
        } else if (input >= 0x1700 && input <= 0x1715) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1227 + (input - 0x1700))];
        } else if (input >= 0x171F && input <= 0x1736) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1249 + (input - 0x171F))];
        } else if (input >= 0x1740 && input <= 0x1753) {
            return cast(ubyte)0;
        } else if (input >= 0x1760 && input <= 0x1773) {
            return cast(ubyte)0;
        } else if (input >= 0x1780 && input <= 0x17DD) {
            if (input <= 0x17D2)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1273 + (input - 0x1780))];
            else if (input >= 0x17D3 && input <= 0x17DC)
                return cast(ubyte)0;
            else if (input == 0x17DD)
                return cast(ubyte)230;
        } else if (input >= 0x17E0 && input <= 0x17E9) {
            return cast(ubyte)0;
        } else if (input >= 0x17F0 && input <= 0x17F9) {
            return cast(ubyte)0;
        } else if (input >= 0x1800 && input <= 0x1819) {
            return cast(ubyte)0;
        } else if (input >= 0x1820 && input <= 0x1878) {
            return cast(ubyte)0;
        } else if (input >= 0x1880 && input <= 0x18AA) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1356 + (input - 0x1880))];
        } else if (input >= 0x18B0 && input <= 0x192B) {
            return cast(ubyte)0;
        } else if (input >= 0x1930 && input <= 0x193B) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1399 + (input - 0x1930))];
        } else if (input >= 0x1940 && input <= 0x1974) {
            return cast(ubyte)0;
        } else if (input >= 0x1980 && input <= 0x19DA) {
            return cast(ubyte)0;
        } else if (input >= 0x19DE && input <= 0x1A1B) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1411 + (input - 0x19DE))];
        } else if (input >= 0x1A1E && input <= 0x1A5E) {
            return cast(ubyte)0;
        } else if (input >= 0x1A60 && input <= 0x1A89) {
            if (input <= 0x1A74)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1473 + (input - 0x1A60))];
            else if (input >= 0x1A75 && input <= 0x1A7C)
                return cast(ubyte)230;
            else if (input >= 0x1A7D && input <= 0x1A7F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1494 + (input - 0x1A7D))];
            else if (input >= 0x1A80)
                return cast(ubyte)0;
        } else if (input >= 0x1A90 && input <= 0x1A99) {
            return cast(ubyte)0;
        } else if (input >= 0x1AA0 && input <= 0x1AAD) {
            return cast(ubyte)0;
        } else if (input >= 0x1AB0 && input <= 0x1ACE) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1497 + (input - 0x1AB0))];
        } else if (input >= 0x1B00 && input <= 0x1C37) {
            if (input <= 0x1B34)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1528 + (input - 0x1B00))];
            else if (input >= 0x1B35 && input <= 0x1B43)
                return cast(ubyte)0;
            else if (input >= 0x1B44 && input <= 0x1B73)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1581 + (input - 0x1B44))];
            else if (input >= 0x1B74 && input <= 0x1BA9)
                return cast(ubyte)0;
            else if (input >= 0x1BAA && input <= 0x1BAB)
                return cast(ubyte)9;
            else if (input >= 0x1BAC && input <= 0x1BE5)
                return cast(ubyte)0;
            else if (input >= 0x1BE6 && input <= 0x1BF3)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1629 + (input - 0x1BE6))];
            else if (input >= 0x1BF4 && input <= 0x1C36)
                return cast(ubyte)0;
            else if (input == 0x1C37)
                return cast(ubyte)7;
        } else if (input >= 0x1C3B && input <= 0x1CC7) {
            return cast(ubyte)0;
        } else if (input >= 0x1CD0 && input <= 0x20C0) {
            if (input <= 0x1CF9)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1643 + (input - 0x1CD0))];
            else if (input >= 0x1CFA && input <= 0x1DBF)
                return cast(ubyte)0;
            else if (input >= 0x1DC0 && input <= 0x1DD0)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1685 + (input - 0x1DC0))];
            else if (input >= 0x1DD1 && input <= 0x1DF5)
                return cast(ubyte)230;
            else if (input >= 0x1DF6 && input <= 0x1DFF)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(1702 + (input - 0x1DF6))];
            else if (input >= 0x1E00)
                return cast(ubyte)0;
        } else if (input >= 0x20D0 && input <= 0x20F0) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1712 + (input - 0x20D0))];
        } else if (input >= 0x2100 && input <= 0x2B95) {
            return cast(ubyte)0;
        } else if (input >= 0x2B97 && input <= 0x2CF3) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(1745 + (input - 0x2B97))];
        } else if (input >= 0x2CF9 && input <= 0x2D70) {
            return cast(ubyte)0;
        } else if (input >= 0x2D7F && input <= 0x2D96) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2094 + (input - 0x2D7F))];
        } else if (input >= 0x2DA0 && input <= 0x2DDE) {
            return cast(ubyte)0;
        } else if (input >= 0x2DE0 && input <= 0x2E5D) {
            if (input <= 0x2DFF)
                return cast(ubyte)230;
            else if (input >= 0x2E00)
                return cast(ubyte)0;
        } else if (input >= 0x2E80 && input <= 0x2FD5) {
            return cast(ubyte)0;
        } else if (input >= 0x2FF0 && input <= 0x3096) {
            if (input <= 0x302F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2118 + (input - 0x2FF0))];
            else if (input >= 0x3030)
                return cast(ubyte)0;
        } else if (input >= 0x3099) {
            return cast(ubyte)8;
        }
    } else if (input >= 0x309B && input <= 0xA62B) {
        return cast(ubyte)0;
    } else if (input >= 0xA640 && input <= 0xABF9) {
        if (input <= 0xA6F7) {
            if (input <= 0xA673)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2182 + (input - 0xA640))];
            else if (input >= 0xA674 && input <= 0xA67D)
                return cast(ubyte)230;
            else if (input >= 0xA67E && input <= 0xA69F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2234 + (input - 0xA67E))];
            else if (input >= 0xA6A0 && input <= 0xA6EF)
                return cast(ubyte)0;
            else if (input >= 0xA6F0)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2268 + (input - 0xA6F0))];
        } else if (input >= 0xA700 && input <= 0xA7DC) {
            return cast(ubyte)0;
        } else if (input >= 0xA7F2 && input <= 0xA82C) {
            if (input <= 0xA806)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2276 + (input - 0xA7F2))];
            else if (input >= 0xA807 && input <= 0xA82B)
                return cast(ubyte)0;
            else if (input == 0xA82C)
                return cast(ubyte)9;
        } else if (input >= 0xA830 && input <= 0xA839) {
            return cast(ubyte)0;
        } else if (input >= 0xA840 && input <= 0xA877) {
            return cast(ubyte)0;
        } else if (input >= 0xA880 && input <= 0xA8C5) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2297 + (input - 0xA880))];
        } else if (input >= 0xA8CE && input <= 0xA8D9) {
            return cast(ubyte)0;
        } else if (input >= 0xA8E0 && input <= 0xA953) {
            if (input <= 0xA8F1)
                return cast(ubyte)230;
            else if (input >= 0xA8F2 && input <= 0xA92A)
                return cast(ubyte)0;
            else if (input >= 0xA92B && input <= 0xA92D)
                return cast(ubyte)220;
            else if (input >= 0xA92E && input <= 0xA952)
                return cast(ubyte)0;
            else if (input == 0xA953)
                return cast(ubyte)9;
        } else if (input >= 0xA95F && input <= 0xA97C) {
            return cast(ubyte)0;
        } else if (input >= 0xA980 && input <= 0xA9CD) {
            if (input <= 0xA9B3)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2367 + (input - 0xA980))];
            else if (input >= 0xA9B4 && input <= 0xA9BF)
                return cast(ubyte)0;
            else if (input >= 0xA9C0)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2419 + (input - 0xA9C0))];
        } else if (input >= 0xA9CF && input <= 0xAA59) {
            return cast(ubyte)0;
        } else if (input >= 0xAA5C && input <= 0xAAC2) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2433 + (input - 0xAA5C))];
        } else if (input >= 0xAADB && input <= 0xAAF6) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2536 + (input - 0xAADB))];
        } else if (input >= 0xAB01 && input <= 0xAB16) {
            return cast(ubyte)0;
        } else if (input >= 0xAB20 && input <= 0xAB6B) {
            return cast(ubyte)0;
        } else if (input >= 0xAB70 && input <= 0xABED) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2564 + (input - 0xAB70))];
        } else if (input >= 0xABF0) {
            return cast(ubyte)0;
        }
    } else if (input >= 0xAC00 && input <= 0xFAD9) {
        return cast(ubyte)0;
    } else if (input >= 0xFB00 && input <= 0x11FF1) {
        if (input <= 0xFB06) {
            return cast(ubyte)0;
        } else if (input >= 0xFB13 && input <= 0xFB17) {
            return cast(ubyte)0;
        } else if (input >= 0xFB1D && input <= 0xFB36) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2690 + (input - 0xFB1D))];
        } else if (input >= 0xFB38 && input <= 0xFDCF) {
            return cast(ubyte)0;
        } else if (input >= 0xFDF0 && input <= 0xFE19) {
            return cast(ubyte)0;
        } else if (input >= 0xFE20 && input <= 0x1005D) {
            if (input <= 0xFE2F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2716 + (input - 0xFE20))];
            else if (input >= 0xFE30)
                return cast(ubyte)0;
        } else if (input >= 0x10080 && input <= 0x101A0) {
            return cast(ubyte)0;
        } else if (input >= 0x101D0 && input <= 0x101FD) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2732 + (input - 0x101D0))];
        } else if (input >= 0x10280 && input <= 0x102D0) {
            return cast(ubyte)0;
        } else if (input >= 0x102E0 && input <= 0x102FB) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2778 + (input - 0x102E0))];
        } else if (input >= 0x10300 && input <= 0x10323) {
            return cast(ubyte)0;
        } else if (input >= 0x1032D && input <= 0x1034A) {
            return cast(ubyte)0;
        } else if (input >= 0x10350 && input <= 0x1037A) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2806 + (input - 0x10350))];
        } else if (input >= 0x10380 && input <= 0x103D5) {
            return cast(ubyte)0;
        } else if (input >= 0x10400 && input <= 0x107BA) {
            return cast(ubyte)0;
        } else if (input >= 0x10800 && input <= 0x108AF) {
            return cast(ubyte)0;
        } else if (input >= 0x108E0 && input <= 0x108F5) {
            return cast(ubyte)0;
        } else if (input >= 0x108FB && input <= 0x1093F) {
            return cast(ubyte)0;
        } else if (input >= 0x10980 && input <= 0x10A06) {
            return cast(ubyte)0;
        } else if (input >= 0x10A0C && input <= 0x10A13) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2849 + (input - 0x10A0C))];
        } else if (input >= 0x10A15 && input <= 0x10A35) {
            return cast(ubyte)0;
        } else if (input >= 0x10A38 && input <= 0x10A48) {
            if (input <= 0x10A3F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2857 + (input - 0x10A38))];
            else if (input >= 0x10A40)
                return cast(ubyte)0;
        } else if (input >= 0x10A50 && input <= 0x10A58) {
            return cast(ubyte)0;
        } else if (input >= 0x10A60 && input <= 0x10A9F) {
            return cast(ubyte)0;
        } else if (input >= 0x10AC0 && input <= 0x10AE6) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2865 + (input - 0x10AC0))];
        } else if (input >= 0x10AEB && input <= 0x10AF6) {
            return cast(ubyte)0;
        } else if (input >= 0x10B00 && input <= 0x10BAF) {
            return cast(ubyte)0;
        } else if (input >= 0x10C00 && input <= 0x10C48) {
            return cast(ubyte)0;
        } else if (input >= 0x10C80 && input <= 0x10CB2) {
            return cast(ubyte)0;
        } else if (input >= 0x10CC0 && input <= 0x10CF2) {
            return cast(ubyte)0;
        } else if (input >= 0x10CFA && input <= 0x10D27) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2904 + (input - 0x10CFA))];
        } else if (input >= 0x10D30 && input <= 0x10D39) {
            return cast(ubyte)0;
        } else if (input >= 0x10D40 && input <= 0x10D65) {
            return cast(ubyte)0;
        } else if (input >= 0x10D69 && input <= 0x10D85) {
            if (input <= 0x10D6D)
                return cast(ubyte)230;
            else if (input >= 0x10D6E)
                return cast(ubyte)0;
        } else if (input >= 0x10D8E && input <= 0x10D8F) {
            return cast(ubyte)0;
        } else if (input >= 0x10E60 && input <= 0x10EA9) {
            return cast(ubyte)0;
        } else if (input >= 0x10EAB && input <= 0x10EAD) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2950 + (input - 0x10EAB))];
        } else if (input >= 0x10EB0 && input <= 0x10EB1) {
            return cast(ubyte)0;
        } else if (input >= 0x10EC2 && input <= 0x10EC4) {
            return cast(ubyte)0;
        } else if (input >= 0x10EFC && input <= 0x10F59) {
            if (input <= 0x10EFF)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2953 + (input - 0x10EFC))];
            else if (input >= 0x10F00 && input <= 0x10F45)
                return cast(ubyte)0;
            else if (input >= 0x10F46 && input <= 0x10F50)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2957 + (input - 0x10F46))];
            else if (input >= 0x10F51)
                return cast(ubyte)0;
        } else if (input >= 0x10F70 && input <= 0x10F89) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(2968 + (input - 0x10F70))];
        } else if (input >= 0x10FB0 && input <= 0x10FCB) {
            return cast(ubyte)0;
        } else if (input >= 0x10FE0 && input <= 0x10FF6) {
            return cast(ubyte)0;
        } else if (input >= 0x11000 && input <= 0x110C2) {
            if (input <= 0x11046)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(2994 + (input - 0x11000))];
            else if (input >= 0x11047 && input <= 0x1106F)
                return cast(ubyte)0;
            else if (input >= 0x11070 && input <= 0x1107F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3065 + (input - 0x11070))];
            else if (input >= 0x11080 && input <= 0x110B8)
                return cast(ubyte)0;
            else if (input >= 0x110B9)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3081 + (input - 0x110B9))];
        } else if (input >= 0x110CD && input <= 0x110E8) {
            return cast(ubyte)0;
        } else if (input >= 0x110F0 && input <= 0x110F9) {
            return cast(ubyte)0;
        } else if (input >= 0x11100 && input <= 0x11134) {
            if (input <= 0x11102)
                return cast(ubyte)230;
            else if (input >= 0x11103 && input <= 0x11132)
                return cast(ubyte)0;
            else if (input >= 0x11133)
                return cast(ubyte)9;
        } else if (input >= 0x11136 && input <= 0x11147) {
            return cast(ubyte)0;
        } else if (input >= 0x11150 && input <= 0x11176) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3091 + (input - 0x11150))];
        } else if (input >= 0x11180 && input <= 0x111DF) {
            if (input <= 0x111C0)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3130 + (input - 0x11180))];
            else if (input >= 0x111C1 && input <= 0x111C9)
                return cast(ubyte)0;
            else if (input >= 0x111CA)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3195 + (input - 0x111CA))];
        } else if (input >= 0x111E1 && input <= 0x111F4) {
            return cast(ubyte)0;
        } else if (input >= 0x11200 && input <= 0x11211) {
            return cast(ubyte)0;
        } else if (input >= 0x11213 && input <= 0x11241) {
            if (input <= 0x11236)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3217 + (input - 0x11213))];
            else if (input >= 0x11237)
                return cast(ubyte)0;
        } else if (input >= 0x11280 && input <= 0x112A9) {
            return cast(ubyte)0;
        } else if (input >= 0x112B0 && input <= 0x112EA) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3253 + (input - 0x112B0))];
        } else if (input >= 0x112F0 && input <= 0x112F9) {
            return cast(ubyte)0;
        } else if (input >= 0x11300 && input <= 0x11339) {
            return cast(ubyte)0;
        } else if (input >= 0x1133B && input <= 0x11348) {
            if (input <= 0x1133C)
                return cast(ubyte)7;
            else if (input >= 0x1133D)
                return cast(ubyte)0;
        } else if (input >= 0x1134B && input <= 0x1134D) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3312 + (input - 0x1134B))];
        } else if (input >= 0x11350 && input <= 0x11357) {
            if (input == 0x11350)
                return cast(ubyte)0;
            else if (input == 0x11357)
                return cast(ubyte)0;
        } else if (input >= 0x1135D && input <= 0x11363) {
            return cast(ubyte)0;
        } else if (input >= 0x11366 && input <= 0x11374) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3315 + (input - 0x11366))];
        } else if (input >= 0x11380 && input <= 0x113CA) {
            return cast(ubyte)0;
        } else if (input >= 0x113CC && input <= 0x113D5) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3330 + (input - 0x113CC))];
        } else if (input >= 0x113D7 && input <= 0x113D8) {
            return cast(ubyte)0;
        } else if (input >= 0x113E1 && input <= 0x113E2) {
            return cast(ubyte)0;
        } else if (input >= 0x11400 && input <= 0x11461) {
            if (input <= 0x11446)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3340 + (input - 0x11400))];
            else if (input >= 0x11447 && input <= 0x1145D)
                return cast(ubyte)0;
            else if (input >= 0x1145E)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3411 + (input - 0x1145E))];
        } else if (input >= 0x11480 && input <= 0x114C7) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3415 + (input - 0x11480))];
        } else if (input >= 0x114D0 && input <= 0x114D9) {
            return cast(ubyte)0;
        } else if (input >= 0x11580 && input <= 0x115B5) {
            return cast(ubyte)0;
        } else if (input >= 0x115B8 && input <= 0x115DD) {
            if (input <= 0x115C0)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3487 + (input - 0x115B8))];
            else if (input >= 0x115C1)
                return cast(ubyte)0;
        } else if (input >= 0x11600 && input <= 0x11644) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3496 + (input - 0x11600))];
        } else if (input >= 0x11650 && input <= 0x11659) {
            return cast(ubyte)0;
        } else if (input >= 0x11660 && input <= 0x1166C) {
            return cast(ubyte)0;
        } else if (input >= 0x11680 && input <= 0x116B9) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3565 + (input - 0x11680))];
        } else if (input >= 0x116C0 && input <= 0x116C9) {
            return cast(ubyte)0;
        } else if (input >= 0x116D0 && input <= 0x116E3) {
            return cast(ubyte)0;
        } else if (input >= 0x11700 && input <= 0x1171A) {
            return cast(ubyte)0;
        } else if (input >= 0x1171D && input <= 0x1172B) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3623 + (input - 0x1171D))];
        } else if (input >= 0x11730 && input <= 0x11746) {
            return cast(ubyte)0;
        } else if (input >= 0x11800 && input <= 0x1183B) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3638 + (input - 0x11800))];
        } else if (input >= 0x118A0 && input <= 0x11938) {
            return cast(ubyte)0;
        } else if (input >= 0x1193B && input <= 0x11946) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3698 + (input - 0x1193B))];
        } else if (input >= 0x11950 && input <= 0x11959) {
            return cast(ubyte)0;
        } else if (input >= 0x119A0 && input <= 0x119D7) {
            return cast(ubyte)0;
        } else if (input >= 0x119DA && input <= 0x119E4) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3710 + (input - 0x119DA))];
        } else if (input >= 0x11A00 && input <= 0x11AA2) {
            if (input <= 0x11A34)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3721 + (input - 0x11A00))];
            else if (input >= 0x11A35 && input <= 0x11A46)
                return cast(ubyte)0;
            else if (input >= 0x11A47 && input <= 0x11A99)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3774 + (input - 0x11A47))];
            else if (input >= 0x11A9A)
                return cast(ubyte)0;
        } else if (input >= 0x11AB0 && input <= 0x11B09) {
            return cast(ubyte)0;
        } else if (input >= 0x11BC0 && input <= 0x11BE1) {
            return cast(ubyte)0;
        } else if (input >= 0x11BF0 && input <= 0x11BF9) {
            return cast(ubyte)0;
        } else if (input >= 0x11C00 && input <= 0x11C36) {
            return cast(ubyte)0;
        } else if (input >= 0x11C38 && input <= 0x11C45) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3857 + (input - 0x11C38))];
        } else if (input >= 0x11C50 && input <= 0x11CB6) {
            return cast(ubyte)0;
        } else if (input >= 0x11D00 && input <= 0x11D3D) {
            return cast(ubyte)0;
        } else if (input >= 0x11D3F && input <= 0x11D47) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3871 + (input - 0x11D3F))];
        } else if (input >= 0x11D50 && input <= 0x11D59) {
            return cast(ubyte)0;
        } else if (input >= 0x11D60 && input <= 0x11D91) {
            return cast(ubyte)0;
        } else if (input >= 0x11D93 && input <= 0x11D98) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3880 + (input - 0x11D93))];
        } else if (input >= 0x11DA0 && input <= 0x11DA9) {
            return cast(ubyte)0;
        } else if (input >= 0x11EE0 && input <= 0x11EF8) {
            return cast(ubyte)0;
        } else if (input >= 0x11F00 && input <= 0x11F3A) {
            return cast(ubyte)0;
        } else if (input >= 0x11F3E && input <= 0x11F5A) {
            if (input <= 0x11F42)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3886 + (input - 0x11F3E))];
            else if (input >= 0x11F43)
                return cast(ubyte)0;
        } else if (input == 0x11FB0) {
            return cast(ubyte)0;
        } else if (input >= 0x11FC0) {
            return cast(ubyte)0;
        }
    } else if (input >= 0x11FFF && input <= 0x14646) {
        if (input <= 0x12399) {
            return cast(ubyte)0;
        } else if (input >= 0x12400 && input <= 0x12543) {
            return cast(ubyte)0;
        } else if (input >= 0x12F90) {
            return cast(ubyte)0;
        }
    } else if (input >= 0x16100 && input <= 0x18D08) {
        if (input <= 0x16139) {
            if (input <= 0x1612F)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3891 + (input - 0x16100))];
            else if (input >= 0x16130)
                return cast(ubyte)0;
        } else if (input >= 0x16800 && input <= 0x16AED) {
            return cast(ubyte)0;
        } else if (input >= 0x16AF0 && input <= 0x16AF5) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(3939 + (input - 0x16AF0))];
        } else if (input >= 0x16B00 && input <= 0x16B45) {
            if (input <= 0x16B36)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(3945 + (input - 0x16B00))];
            else if (input >= 0x16B37)
                return cast(ubyte)0;
        } else if (input >= 0x16B50 && input <= 0x16B8F) {
            return cast(ubyte)0;
        } else if (input >= 0x16D40 && input <= 0x16D79) {
            return cast(ubyte)0;
        } else if (input >= 0x16E40 && input <= 0x16E9A) {
            return cast(ubyte)0;
        } else if (input >= 0x16F00 && input <= 0x16F9F) {
            return cast(ubyte)0;
        } else if (input >= 0x16FE0 && input <= 0x16FE4) {
            return cast(ubyte)0;
        } else if (input >= 0x16FF0 && input <= 0x16FF1) {
            return cast(ubyte)6;
        } else if (input >= 0x17000 && input <= 0x18CD5) {
            return cast(ubyte)0;
        } else if (input >= 0x18CFF) {
            return cast(ubyte)0;
        }
    } else if (input >= 0x1AFF0 && input <= 0x1DF2A) {
        if (input <= 0x1B2FB) {
            return cast(ubyte)0;
        } else if (input >= 0x1BC00 && input <= 0x1BC99) {
            return cast(ubyte)0;
        } else if (input >= 0x1BC9C && input <= 0x1BCA3) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(4000 + (input - 0x1BC9C))];
        } else if (input >= 0x1CC00 && input <= 0x1CEB3) {
            return cast(ubyte)0;
        } else if (input >= 0x1CF00 && input <= 0x1CFC3) {
            return cast(ubyte)0;
        } else if (input >= 0x1D000 && input <= 0x1D126) {
            return cast(ubyte)0;
        } else if (input >= 0x1D129 && input <= 0x1D245) {
            if (input <= 0x1D172)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4008 + (input - 0x1D129))];
            else if (input >= 0x1D173 && input <= 0x1D17A)
                return cast(ubyte)0;
            else if (input >= 0x1D17B && input <= 0x1D18B)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4082 + (input - 0x1D17B))];
            else if (input >= 0x1D18C && input <= 0x1D1A9)
                return cast(ubyte)0;
            else if (input >= 0x1D1AA && input <= 0x1D1AD)
                return cast(ubyte)230;
            else if (input >= 0x1D1AE && input <= 0x1D241)
                return cast(ubyte)0;
            else if (input >= 0x1D242)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4099 + (input - 0x1D242))];
        } else if (input >= 0x1D2C0 && input <= 0x1D2D3) {
            return cast(ubyte)0;
        } else if (input >= 0x1D2E0 && input <= 0x1D2F3) {
            return cast(ubyte)0;
        } else if (input >= 0x1D300 && input <= 0x1D378) {
            return cast(ubyte)0;
        } else if (input >= 0x1D400 && input <= 0x1DAAF) {
            return cast(ubyte)0;
        } else if (input >= 0x1DF00) {
            return cast(ubyte)0;
        }
    } else if (input >= 0x1E000 && input <= 0x1FBF9) {
        if (input <= 0x1E02A) {
            if (input <= 0x1E007)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4103 + (input - 0x1E000))];
            else if (input >= 0x1E008 && input <= 0x1E018)
                return cast(ubyte)230;
            else if (input >= 0x1E019)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4111 + (input - 0x1E019))];
        } else if (input >= 0x1E030 && input <= 0x1E06D) {
            return cast(ubyte)0;
        } else if (input == 0x1E08F) {
            return cast(ubyte)230;
        } else if (input >= 0x1E100 && input <= 0x1E12C) {
            return cast(ubyte)0;
        } else if (input >= 0x1E130 && input <= 0x1E13D) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(4129 + (input - 0x1E130))];
        } else if (input >= 0x1E140 && input <= 0x1E14F) {
            return cast(ubyte)0;
        } else if (input >= 0x1E290 && input <= 0x1E2AE) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(4143 + (input - 0x1E290))];
        } else if (input >= 0x1E2C0 && input <= 0x1E2F9) {
            if (input <= 0x1E2EF)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4174 + (input - 0x1E2C0))];
            else if (input >= 0x1E2F0)
                return cast(ubyte)0;
        } else if (input == 0x1E2FF) {
            return cast(ubyte)0;
        } else if (input >= 0x1E4D0 && input <= 0x1E4F9) {
            if (input <= 0x1E4EF)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4222 + (input - 0x1E4D0))];
            else if (input >= 0x1E4F0)
                return cast(ubyte)0;
        } else if (input >= 0x1E5D0 && input <= 0x1E5FF) {
            if (input <= 0x1E5EF)
                return cast(ubyte)LUT_76F37D63[cast(size_t)(4254 + (input - 0x1E5D0))];
            else if (input >= 0x1E5F0)
                return cast(ubyte)0;
        } else if (input >= 0x1E7E0 && input <= 0x1E8C4) {
            return cast(ubyte)0;
        } else if (input >= 0x1E8C7 && input <= 0x1E8D6) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(4286 + (input - 0x1E8C7))];
        } else if (input >= 0x1E900 && input <= 0x1E94B) {
            return cast(ubyte)LUT_76F37D63[cast(size_t)(4302 + (input - 0x1E900))];
        } else if (input >= 0x1E950 && input <= 0x1E95F) {
            return cast(ubyte)0;
        } else if (input >= 0x1EC71 && input <= 0x1ECB4) {
            return cast(ubyte)0;
        } else if (input >= 0x1ED01 && input <= 0x1ED3D) {
            return cast(ubyte)0;
        } else if (input >= 0x1EE00 && input <= 0x1EEBB) {
            return cast(ubyte)0;
        } else if (input >= 0x1EEF0 && input <= 0x1EEF1) {
            return cast(ubyte)0;
        } else if (input >= 0x1F000 && input <= 0x1F1AD) {
            return cast(ubyte)0;
        } else if (input >= 0x1F1E6 && input <= 0x1F202) {
            return cast(ubyte)0;
        } else if (input >= 0x1F210 && input <= 0x1F251) {
            return cast(ubyte)0;
        } else if (input >= 0x1F260 && input <= 0x1F265) {
            return cast(ubyte)0;
        } else if (input >= 0x1F300 && input <= 0x1F8C1) {
            return cast(ubyte)0;
        } else if (input >= 0x1F900) {
            return cast(ubyte)0;
        }
    } else if (input >= 0x20000 && input <= 0x2A6DF) {
        return cast(ubyte)0;
    } else if (input >= 0x2A700 && input <= 0x2EE5D) {
        return cast(ubyte)0;
    } else if (input >= 0x2F800 && input <= 0x2FA1D) {
        return cast(ubyte)0;
    } else if (input >= 0x30000 && input <= 0x323AF) {
        return cast(ubyte)0;
    } else if (input >= 0xE0001 && input <= 0xE01EF) {
        if (input == 0xE0001) {
            return cast(ubyte)0;
        } else if (input >= 0xE0020 && input <= 0xE007F) {
            return cast(ubyte)0;
        } else if (input >= 0xE0100) {
            return cast(ubyte)0;
        }
    } else if (input >= 0xF0000 && input <= 0x10FFFD) {
        return cast(ubyte)0;
    }
    return typeof(return).init;
}
private {
    static immutable LUT_76F37D63 = [232, 220, 220, 220, 220, 232, 216, 220, 220, 220, 220, 220, 202, 202, 220, 220, 220, 220, 202, 202, 1, 1, 1, 1, 1, 220, 220, 220, 220, 240, 230, 220, 220, 220, 230, 230, 230, 220, 220, 0, 230, 230, 230, 220, 220, 220, 220, 230, 232, 220, 220, 230, 233, 234, 234, 233, 234, 234, 233, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 220, 230, 230, 230, 230, 220, 230, 230, 230, 222, 220, 230, 230, 230, 230, 230, 230, 220, 220, 220, 220, 220, 220, 230, 230, 220, 230, 230, 222, 228, 230, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 19, 20, 21, 22, 0, 23, 0, 24, 25, 0, 230, 220, 0, 18, 30, 31, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 27, 28, 29, 30, 31, 32, 33, 34, 230, 230, 220, 220, 230, 230, 230, 230, 230, 220, 230, 230, 220, 35, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 230, 230, 0, 0, 230, 230, 230, 230, 220, 230, 0, 0, 230, 230, 0, 220, 230, 230, 220, 36, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 220, 230, 230, 220, 230, 230, 220, 220, 220, 230, 220, 220, 230, 220, 230, 230, 230, 220, 230, 220, 230, 220, 230, 220, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 230, 230, 220, 230, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 0, 0, 230, 230, 230, 0, 230, 230, 230, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 220, 220, 220, 230, 230, 220, 220, 220, 230, 230, 230, 230, 230, 230, 230, 230, 230, 220, 220, 220, 220, 220, 0, 220, 230, 230, 220, 230, 230, 220, 230, 230, 230, 220, 220, 220, 27, 28, 29, 230, 230, 230, 220, 230, 230, 220, 220, 230, 230, 230, 230, 230, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 230, 220, 230, 230, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 84, 91, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 103, 103, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 118, 118, 9, 0, 0, 0, 122, 122, 122, 122, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 220, 220, 220, 0, 220, 0, 216, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 129, 130, 0, 132, 0, 0, 0, 0, 0, 130, 130, 130, 130, 0, 0, 130, 0, 230, 230, 9, 0, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 9, 9, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 228, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 222, 230, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 220, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 220, 230, 230, 230, 230, 230, 220, 220, 220, 220, 220, 220, 230, 230, 220, 0, 220, 220, 230, 230, 220, 220, 230, 230, 230, 230, 230, 220, 230, 230, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 220, 230, 230, 230, 230, 230, 230, 230, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 230, 230, 230, 0, 1, 220, 220, 220, 220, 220, 230, 230, 220, 220, 220, 220, 230, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 220, 0, 0, 0, 0, 0, 0, 230, 0, 0, 0, 230, 230, 230, 230, 220, 230, 230, 230, 230, 230, 230, 230, 220, 230, 230, 234, 214, 220, 202, 232, 228, 228, 220, 218, 230, 233, 220, 230, 220, 230, 230, 1, 1, 230, 230, 230, 230, 1, 1, 1, 230, 230, 0, 0, 0, 0, 230, 0, 0, 0, 1, 1, 230, 220, 230, 1, 1, 220, 220, 220, 220, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 218, 228, 232, 222, 224, 224, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 0, 230, 230, 220, 0, 0, 230, 230, 0, 0, 0, 0, 0, 230, 230, 0, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 230, 230, 220, 220, 220, 220, 220, 220, 220, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 220, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 0, 220, 0, 230, 0, 0, 0, 0, 230, 1, 220, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 230, 0, 0, 220, 220, 220, 220, 220, 230, 230, 230, 220, 230, 220, 220, 220, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 220, 230, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 9, 0, 0, 9, 230, 230, 230, 230, 230, 230, 230, 0, 0, 0, 230, 230, 230, 230, 230, 0, 0, 9, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 7, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 7, 0, 0, 0, 9, 9, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 9, 9, 0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 230, 230, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 216, 216, 1, 1, 1, 0, 0, 0, 226, 216, 216, 216, 216, 216, 220, 220, 220, 220, 220, 220, 220, 220, 0, 0, 230, 230, 230, 230, 230, 220, 220, 230, 230, 230, 0, 230, 230, 230, 230, 230, 230, 230, 0, 0, 0, 230, 230, 230, 230, 230, 230, 230, 0, 230, 230, 0, 230, 230, 230, 230, 230, 230, 230, 230, 230, 230, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 232, 232, 220, 230, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 220, 220, 220, 220, 220, 220, 220, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 230, 230, 230, 230, 230, 230, 7, 0, ];
}

