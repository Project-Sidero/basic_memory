module sidero.base.internal.cldr.windowszones;

// Generated do not modify

private enum {
    FNV_Prime_32 = (2 ^^ 24) + (2 ^^ 8) + 0x93,
    FNV_Offset_Basis_32 = 0x811c9dc5,
}
uint fnv_32_1a(scope const(ubyte)[] data, uint start = FNV_Offset_Basis_32) @safe nothrow @nogc pure {
    uint hash = start;

    foreach (b; data) {
        hash ^= b;
        hash *= FNV_Prime_32;
    }

    return hash;
}
export extern(C) string windowsToIANA(scope string windows, scope string territory) @trusted nothrow @nogc pure {
    uint windowsHash = fnv_32_1a(cast(ubyte[])windows);
    uint territoryHash = fnv_32_1a(cast(ubyte[])territory);
    switch(windowsHash) {
        case 3374382045:
            switch(territoryHash) {
                case 3838523700:
                    return `Australia/Hobart`;
                case 936719067:
                    return `Australia/Hobart Australia/Currie Antarctica/Macquarie`;
                default:
                    return null;
            }
        case 2457674051:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Indianapolis`;
                case 1710461017:
                    return `America/Indianapolis America/Indiana/Marengo America/Indiana/Vevay`;
                default:
                    return null;
            }
        case 26092569:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Ulaanbaatar`;
                case 1088409186:
                    return `Asia/Ulaanbaatar Asia/Choibalsan`;
                default:
                    return null;
            }
        case 2082145625:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Miquelon`;
                case 603976806:
                    return `America/Miquelon`;
                default:
                    return null;
            }
        case 2160709580:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Magadan`;
                case 1745149088:
                    return `Asia/Magadan`;
                default:
                    return null;
            }
        case 3158156588:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Bahia`;
                case 786264949:
                    return `America/Bahia`;
                default:
                    return null;
            }
        case 3314765666:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Hebron`;
                case 1040194900:
                    return `Asia/Hebron Asia/Gaza`;
                default:
                    return null;
            }
        case 2648239296:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Pyongyang`;
                case 921618734:
                    return `Asia/Pyongyang`;
                default:
                    return null;
            }
        case 2740620345:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Kaliningrad`;
                case 1745149088:
                    return `Europe/Kaliningrad`;
                default:
                    return null;
            }
        case 1915392146:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Baku`;
                case 886386210:
                    return `Asia/Baku`;
                default:
                    return null;
            }
        case 3846576078:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Volgograd`;
                case 1745149088:
                    return `Europe/Volgograd`;
                default:
                    return null;
            }
        case 1124892034:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Calcutta`;
                case 1625881374:
                    return `Asia/Calcutta`;
                default:
                    return null;
            }
        case 1080132707:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Port_Moresby`;
                case 704642520:
                    return `Pacific/Port_Moresby`;
                case 1003829543:
                    return `Antarctica/DumontDUrville`;
                case 853522520:
                    return `Pacific/Saipan`;
                case 1808861065:
                    return `Pacific/Guam`;
                case 2144560540:
                    return `Pacific/Truk`;
                default:
                    return null;
            }
        case 2748328705:
            switch(territoryHash) {
                case 535733497:
                    return `Pacific/Tarawa`;
                case 2146679111:
                    return `Pacific/Wake`;
                case 987743472:
                    return `Pacific/Majuro Pacific/Kwajalein`;
                case 955762352:
                    return `Pacific/Wallis`;
                case 652632377:
                    return `Pacific/Nauru`;
                case 720728591:
                    return `Pacific/Funafuti`;
                default:
                    return null;
            }
        case 4003448889:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Omsk`;
                case 1745149088:
                    return `Asia/Omsk`;
                default:
                    return null;
            }
        case 2482612422:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Cairo`;
                case 432802117:
                    return `Africa/Cairo`;
                default:
                    return null;
            }
        case 3525075834:
            switch(territoryHash) {
                case 1827904350:
                    return `Asia/Tashkent Asia/Samarkand`;
                case 753842544:
                    return `Asia/Oral Asia/Aqtau Asia/Aqtobe Asia/Atyrau`;
                case 1003829543:
                    return `Antarctica/Mawson`;
                case 452286687:
                    return `Indian/Kerguelen`;
                case 603285258:
                    return `Asia/Ashgabat`;
                case 3838523700:
                    return `Asia/Tashkent`;
                case 954188234:
                    return `Indian/Maldives`;
                case 519397163:
                    return `Asia/Dushanbe`;
                default:
                    return null;
            }
        case 3172475483:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Chita`;
                case 1745149088:
                    return `Asia/Chita`;
                default:
                    return null;
            }
        case 2589420880:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Windhoek`;
                case 870741424:
                    return `Africa/Windhoek`;
                default:
                    return null;
            }
        case 798897963:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Fiji`;
                case 2127782921:
                    return `Pacific/Fiji`;
                default:
                    return null;
            }
        case 3230897006:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Auckland`;
                case 786853329:
                    return `Pacific/Auckland`;
                case 1003829543:
                    return `Antarctica/McMurdo`;
                default:
                    return null;
            }
        case 3577982992:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Astrakhan`;
                case 1745149088:
                    return `Europe/Astrakhan Europe/Ulyanovsk`;
                default:
                    return null;
            }
        case 1246430693:
            switch(territoryHash) {
                case 3838523700:
                    return `Etc/GMT+12`;
                case 924325685:
                    return `Etc/GMT+12`;
                default:
                    return null;
            }
        case 2082209999:
            switch(territoryHash) {
                case 3838523700:
                    return `Australia/Darwin`;
                case 936719067:
                    return `Australia/Darwin`;
                default:
                    return null;
            }
        case 2435963802:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Colombo`;
                case 1575107232:
                    return `Asia/Colombo`;
                default:
                    return null;
            }
        case 3610469414:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Almaty`;
                case 703509687:
                    return `Asia/Bishkek`;
                case 2161779444:
                    return `Asia/Urumqi`;
                case 1003829543:
                    return `Antarctica/Vostok`;
                case 1642658993:
                    return `Indian/Chagos`;
                case 753842544:
                    return `Asia/Almaty Asia/Qostanay`;
                default:
                    return null;
            }
        case 466358966:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Khartoum`;
                case 1526892946:
                    return `Africa/Khartoum`;
                default:
                    return null;
            }
        case 1339305663:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Kabul`;
                case 685054782:
                    return `Asia/Kabul`;
                default:
                    return null;
            }
        case 207930774:
            switch(territoryHash) {
                case 3838523700:
                    return `Australia/Sydney`;
                case 936719067:
                    return `Australia/Sydney Australia/Melbourne`;
                default:
                    return null;
            }
        case 2245746734:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Santiago`;
                case 2195334682:
                    return `America/Santiago`;
                default:
                    return null;
            }
        case 3265065823:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Singapore`;
                case 1510115327:
                    return `Asia/Singapore`;
                case 1458105184:
                    return `Asia/Makassar`;
                case 736079187:
                    return `Asia/Kuala_Lumpur Asia/Kuching`;
                case 687864901:
                    return `Asia/Manila`;
                case 584933521:
                    return `Asia/Brunei`;
                default:
                    return null;
            }
        case 2625489696:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Norfolk`;
                case 988184757:
                    return `Pacific/Norfolk`;
                default:
                    return null;
            }
        case 2588022751:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Juba`;
                case 1711446755:
                    return `Africa/Juba`;
                default:
                    return null;
            }
        case 1281359074:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Havana`;
                case 1809449445:
                    return `America/Havana`;
                default:
                    return null;
            }
        case 522048870:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Punta_Arenas`;
                case 2195334682:
                    return `America/Punta_Arenas`;
                default:
                    return null;
            }
        case 4134040719:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Yerevan`;
                case 534056211:
                    return `Asia/Yerevan`;
                default:
                    return null;
            }
        case 2150979068:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Tripoli`;
                case 1877104374:
                    return `Africa/Tripoli`;
                default:
                    return null;
            }
        case 2875261238:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Los_Angeles`;
                case 2010780873:
                    return `America/Vancouver`;
                case 924325685:
                    return `PST8PDT`;
                case 1710461017:
                    return `America/Los_Angeles`;
                default:
                    return null;
            }
        case 3228456573:
            switch(territoryHash) {
                case 3838523700:
                    return `Etc/UTC`;
                case 924325685:
                    return `Etc/UTC Etc/GMT`;
                default:
                    return null;
            }
        case 3285761134:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Easter`;
                case 2195334682:
                    return `Pacific/Easter`;
                default:
                    return null;
            }
        case 3717081904:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Moscow`;
                case 1945347683:
                    return `Europe/Simferopol`;
                case 1745149088:
                    return `Europe/Moscow Europe/Kirov`;
                default:
                    return null;
            }
        case 1350088626:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Caracas`;
                case 1744457540:
                    return `America/Caracas`;
                default:
                    return null;
            }
        case 4199612719:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Whitehorse`;
                case 2010780873:
                    return `America/Whitehorse America/Dawson`;
                default:
                    return null;
            }
        case 1357945353:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Amman`;
                case 1106319638:
                    return `Asia/Amman`;
                default:
                    return null;
            }
        case 2222333840:
            switch(territoryHash) {
                case 2010780873:
                    return `America/Coral_Harbour`;
                case 1072764400:
                    return `America/Jamaica`;
                case 365691641:
                    return `America/Guayaquil`;
                case 738197758:
                    return `America/Lima`;
                case 3838523700:
                    return `America/Bogota`;
                case 924325685:
                    return `Etc/GMT+5`;
                case 805308234:
                    return `America/Panama`;
                case 804175401:
                    return `America/Cayman`;
                case 786264949:
                    return `America/Rio_Branco America/Eirunepe`;
                case 2178557063:
                    return `America/Bogota`;
                default:
                    return null;
            }
        case 325126273:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Dubai`;
                case 2212803849:
                    return `Asia/Muscat`;
                case 668277163:
                    return `Asia/Dubai`;
                default:
                    return null;
            }
        case 1822362400:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Bougainville`;
                case 704642520:
                    return `Pacific/Bougainville`;
                default:
                    return null;
            }
        case 4241278284:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Yekaterinburg`;
                case 1745149088:
                    return `Asia/Yekaterinburg`;
                default:
                    return null;
            }
        case 1733617688:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Araguaina`;
                case 786264949:
                    return `America/Araguaina`;
                default:
                    return null;
            }
        case 517095253:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Vladivostok`;
                default:
                    return null;
            }
        case 3594877312:
            switch(territoryHash) {
                case 3838523700:
                    return `America/St_Johns`;
                case 2010780873:
                    return `America/St_Johns`;
                default:
                    return null;
            }
        case 1281920657:
            switch(territoryHash) {
                case 3838523700:
                    return `Atlantic/Azores`;
                case 1657862494:
                    return `America/Scoresbysund`;
                case 1023417281:
                    return `Atlantic/Azores`;
                default:
                    return null;
            }
        case 3744622920:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Regina`;
                case 2010780873:
                    return `America/Regina America/Swift_Current`;
                default:
                    return null;
            }
        case 2613349132:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Samara`;
                case 1745149088:
                    return `Europe/Samara`;
                default:
                    return null;
            }
        case 491243012:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Denver`;
                case 2010780873:
                    return `America/Edmonton America/Cambridge_Bay America/Inuvik America/Yellowknife`;
                case 924325685:
                    return `MST7MDT`;
                case 1710461017:
                    return `America/Denver America/Boise`;
                case 719301568:
                    return `America/Ojinaga`;
                default:
                    return null;
            }
        case 2170484790:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Rangoon`;
                case 1977225635:
                    return `Indian/Cocos`;
                case 1071631567:
                    return `Asia/Rangoon`;
                default:
                    return null;
            }
        case 2731551086:
            switch(territoryHash) {
                case 535733497:
                    return `Pacific/Enderbury`;
                case 502619544:
                    return `Pacific/Fakaofo`;
                default:
                    return null;
            }
        case 1755282380:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Anchorage`;
                case 1710461017:
                    return `America/Anchorage America/Juneau America/Metlakatla America/Nome America/Sitka America/Yakutat`;
                default:
                    return null;
            }
        case 3673150401:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Honolulu`;
                case 924325685:
                    return `Etc/GMT+10`;
                case 721420139:
                    return `Pacific/Tahiti`;
                case 2146679111:
                    return `Pacific/Johnston`;
                case 1710461017:
                    return `Pacific/Honolulu`;
                case 2111446587:
                    return `Pacific/Rarotonga`;
                default:
                    return null;
            }
        case 2749703478:
            switch(territoryHash) {
                case 517278592:
                    return `Europe/Tirane`;
                case 1826227064:
                    return `Europe/Prague`;
                case 1845814802:
                    return `Europe/Belgrade`;
                case 3838523700:
                    return `Europe/Budapest`;
                case 1577225803:
                    return `Europe/Bratislava`;
                case 1810582278:
                    return `Europe/Budapest`;
                case 1205852519:
                    return `Europe/Podgorica`;
                case 1610781041:
                    return `Europe/Ljubljana`;
                default:
                    return null;
            }
        case 1545775931:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Seoul`;
                case 888063496:
                    return `Asia/Seoul`;
                default:
                    return null;
            }
        case 1911460652:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Krasnoyarsk`;
                case 1745149088:
                    return `Asia/Krasnoyarsk Asia/Novokuznetsk`;
                default:
                    return null;
            }
        case 1155179530:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Phoenix`;
                case 2010780873:
                    return `America/Creston America/Dawson_Creek America/Fort_Nelson`;
                case 924325685:
                    return `Etc/GMT+7`;
                case 1710461017:
                    return `America/Phoenix`;
                case 719301568:
                    return `America/Hermosillo`;
                default:
                    return null;
            }
        case 609834107:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Beirut`;
                case 1726105803:
                    return `Asia/Beirut`;
                default:
                    return null;
            }
        case 30574508:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Chicago`;
                case 2010780873:
                    return `America/Winnipeg America/Rainy_River America/Rankin_Inlet America/Resolute`;
                case 924325685:
                    return `CST6CDT`;
                case 1710461017:
                    return `America/Chicago America/Indiana/Knox America/Indiana/Tell_City America/Menominee America/North_Dakota/Beulah America/North_Dakota/Center America/North_Dakota/New_Salem`;
                case 719301568:
                    return `America/Matamoros`;
                default:
                    return null;
            }
        case 1854934765:
            switch(territoryHash) {
                case 1661113898:
                    return `Africa/Freetown`;
                case 887077758:
                    return `Africa/Nouakchott`;
                case 1624307256:
                    return `Africa/Conakry`;
                case 1657862494:
                    return `America/Danmarkshavn`;
                case 1994547707:
                    return `Africa/Monrovia`;
                case 435509068:
                    return `Africa/Lome`;
                case 1775305827:
                    return `Africa/Bissau`;
                case 3838523700:
                    return `Atlantic/Reykjavik`;
                case 1674640113:
                    return `Africa/Banjul`;
                case 1627558660:
                    return `Africa/Dakar`;
                case 1054853948:
                    return `Africa/Bamako`;
                case 1594003422:
                    return `Atlantic/St_Helena`;
                case 450712569:
                    return `Africa/Ouagadougou`;
                case 2145001825:
                    return `Africa/Abidjan`;
                case 1724972970:
                    return `Africa/Accra`;
                case 1843990421:
                    return `Atlantic/Reykjavik`;
                default:
                    return null;
            }
        case 823182354:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Sakhalin`;
                case 1745149088:
                    return `Asia/Sakhalin`;
                default:
                    return null;
            }
        case 2146929942:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Apia`;
                case 771208543:
                    return `Pacific/Apia`;
                default:
                    return null;
            }
        case 1879004297:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Minsk`;
                case 870153044:
                    return `Europe/Minsk`;
                default:
                    return null;
            }
        case 1685374176:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Adak`;
                case 1710461017:
                    return `America/Adak`;
                default:
                    return null;
            }
        case 2497778470:
            switch(territoryHash) {
                case 1778704326:
                    return `Africa/Kigali`;
                case 2061113730:
                    return `Africa/Lubumbashi`;
                case 739771876:
                    return `Africa/Johannesburg`;
                case 1828890088:
                    return `Africa/Mbabane`;
                case 970965853:
                    return `Africa/Blantyre`;
                case 538440448:
                    return `Africa/Lusaka`;
                case 3838523700:
                    return `Africa/Johannesburg`;
                case 974658542:
                    return `Africa/Harare`;
                case 752856806:
                    return `Africa/Maputo`;
                case 702376854:
                    return `Africa/Gaborone`;
                case 1977770088:
                    return `Africa/Maseru`;
                case 601711140:
                    return `Africa/Bujumbura`;
                default:
                    return null;
            }
        case 899952579:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Asuncion`;
                case 939529186:
                    return `America/Asuncion`;
                default:
                    return null;
            }
        case 1372257304:
            switch(territoryHash) {
                case 2077450064:
                    return `Europe/Helsinki`;
                case 2061658183:
                    return `Europe/Riga`;
                case 3838523700:
                    return `Europe/Kiev`;
                case 2095213421:
                    return `Europe/Vilnius`;
                case 1945347683:
                    return `Europe/Kiev Europe/Uzhgorod Europe/Zaporozhye`;
                case 852830972:
                    return `Europe/Mariehamn`;
                case 399246879:
                    return `Europe/Tallinn`;
                case 433934950:
                    return `Europe/Sofia`;
                default:
                    return null;
            }
        case 1105410782:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Shanghai`;
                case 2161779444:
                    return `Asia/Shanghai`;
                case 2246800372:
                    return `Asia/Hong_Kong`;
                case 1105186805:
                    return `Asia/Macau`;
                default:
                    return null;
            }
        case 2468546549:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Damascus`;
                case 1879222945:
                    return `Asia/Damascus`;
                default:
                    return null;
            }
        case 2947888810:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Dhaka`;
                case 685599235:
                    return `Asia/Thimphu`;
                case 417157331:
                    return `Asia/Dhaka`;
                default:
                    return null;
            }
        case 2762826421:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Yakutsk`;
                case 1745149088:
                    return `Asia/Yakutsk Asia/Khandyga`;
                default:
                    return null;
            }
        case 3813674997:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Tbilisi`;
                case 1540419161:
                    return `Asia/Tbilisi`;
                default:
                    return null;
            }
        case 145068483:
            switch(territoryHash) {
                case 1490086304:
                    return `America/Cayenne`;
                case 1694669136:
                    return `America/Paramaribo`;
                case 1003829543:
                    return `Antarctica/Rothera Antarctica/Palmer`;
                case 3838523700:
                    return `America/Cayenne`;
                case 924325685:
                    return `Etc/GMT+3`;
                case 2111005302:
                    return `Atlantic/Stanley`;
                case 786264949:
                    return `America/Fortaleza America/Belem America/Maceio America/Recife America/Santarem`;
                default:
                    return null;
            }
        case 842727289:
            switch(territoryHash) {
                case 3838523700:
                    return `America/New_York`;
                case 2010780873:
                    return `America/Toronto America/Iqaluit America/Montreal America/Nipigon America/Pangnirtung America/Thunder_Bay`;
                case 769487330:
                    return `America/Nassau`;
                case 1710461017:
                    return `America/New_York America/Detroit America/Indiana/Petersburg America/Indiana/Vincennes America/Indiana/Winamac America/Kentucky/Monticello America/Louisville`;
                case 924325685:
                    return `EST5EDT`;
                default:
                    return null;
            }
        case 2676105602:
            switch(territoryHash) {
                case 3838523700:
                    return `Atlantic/Cape_Verde`;
                case 1759116588:
                    return `Atlantic/Cape_Verde`;
                case 924325685:
                    return `Etc/GMT+1`;
                default:
                    return null;
            }
        case 185155547:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Chatham`;
                case 786853329:
                    return `Pacific/Chatham`;
                default:
                    return null;
            }
        case 87600649:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Istanbul`;
                case 653618115:
                    return `Europe/Istanbul`;
                default:
                    return null;
            }
        case 4184322340:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Karachi`;
                case 637532044:
                    return `Asia/Karachi`;
                default:
                    return null;
            }
        case 2380472163:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Taipei`;
                case 703950972:
                    return `Asia/Taipei`;
                default:
                    return null;
            }
        case 2723589158:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Qyzylorda`;
                case 753842544:
                    return `Asia/Qyzylorda`;
                default:
                    return null;
            }
        case 1600884409:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Kamchatka`;
                case 1745149088:
                    return `Asia/Kamchatka Asia/Anadyr`;
                default:
                    return null;
            }
        case 1069043033:
            switch(territoryHash) {
                case 1206985352:
                    return `Europe/Jersey`;
                case 1609103755:
                    return `Europe/Isle_of_Man`;
                case 1557196780:
                    return `Europe/London`;
                case 1506863923:
                    return `Europe/Guernsey`;
                case 1474882803:
                    return `Europe/Dublin`;
                case 3838523700:
                    return `Europe/London`;
                case 2178115778:
                    return `Atlantic/Faeroe`;
                case 1023417281:
                    return `Europe/Lisbon Atlantic/Madeira`;
                case 634133545:
                    return `Atlantic/Canary`;
                default:
                    return null;
            }
        case 1113817726:
            switch(territoryHash) {
                case 3838523700:
                    return `Indian/Mauritius`;
                case 937410615:
                    return `Indian/Mauritius`;
                case 2013590992:
                    return `Indian/Reunion`;
                case 1443004851:
                    return `Indian/Mahe`;
                default:
                    return null;
            }
        case 1656660487:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Casablanca`;
                case 1138742043:
                    return `Africa/Casablanca`;
                case 449579736:
                    return `Africa/El_Aaiun`;
                default:
                    return null;
            }
        case 1173458179:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Kiritimati`;
                case 535733497:
                    return `Pacific/Kiritimati`;
                default:
                    return null;
            }
        case 483972799:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Guadalcanal`;
                case 904296662:
                    return `Pacific/Noumea`;
                case 1426227232:
                    return `Pacific/Guadalcanal`;
                case 1003829543:
                    return `Antarctica/Casey`;
                case 2012899444:
                    return `Pacific/Efate`;
                case 2144560540:
                    return `Pacific/Ponape Pacific/Kosrae`;
                default:
                    return null;
            }
        case 1023329976:
            switch(territoryHash) {
                case 2196467515:
                    return `America/Tegucigalpa`;
                case 1004962376:
                    return `America/Managua`;
                case 365691641:
                    return `Pacific/Galapagos`;
                case 1692006112:
                    return `America/Costa_Rica`;
                case 920485901:
                    return `America/Belize`;
                case 3838523700:
                    return `America/Guatemala`;
                case 924325685:
                    return `Etc/GMT+6`;
                case 1792083446:
                    return `America/Guatemala`;
                case 1761779612:
                    return `America/El_Salvador`;
                default:
                    return null;
            }
        case 781334487:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Baghdad`;
                case 1810435183:
                    return `Asia/Baghdad`;
                default:
                    return null;
            }
        case 56786667:
            switch(territoryHash) {
                case 1859782302:
                    return `Indian/Christmas`;
                case 1660569445:
                    return `Asia/Saigon`;
                case 1003829543:
                    return `Antarctica/Davis`;
                case 3838523700:
                    return `Asia/Bangkok`;
                case 518955878:
                    return `Asia/Phnom_Penh`;
                case 1458105184:
                    return `Asia/Jakarta Asia/Pontianak`;
                case 552952401:
                    return `Asia/Bangkok`;
                case 1742883422:
                    return `Asia/Vientiane`;
                default:
                    return null;
            }
        case 2712710035:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Saratov`;
                case 1745149088:
                    return `Europe/Saratov`;
                default:
                    return null;
            }
        case 4440161:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Irkutsk`;
                case 1745149088:
                    return `Asia/Irkutsk`;
                default:
                    return null;
            }
        case 1584106790:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Srednekolymsk`;
                case 1745149088:
                    return `Asia/Srednekolymsk`;
                default:
                    return null;
            }
        case 521361787:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Marquesas`;
                case 721420139:
                    return `Pacific/Marquesas`;
                default:
                    return null;
            }
        case 4129021416:
            switch(territoryHash) {
                case 3838523700:
                    return `Pacific/Tongatapu`;
                case 569730020:
                    return `Pacific/Tongatapu`;
                default:
                    return null;
            }
        case 3916038841:
            switch(territoryHash) {
                case 1859193922:
                    return `America/Guadeloupe`;
                case 1104053972:
                    return `America/Santo_Domingo`;
                case 1775894207:
                    return `America/Curacao`;
                case 601166687:
                    return `America/Anguilla`;
                case 1523641542:
                    return `America/Grenada`;
                case 1710902302:
                    return `America/St_Vincent`;
                case 551378283:
                    return `America/St_Barthelemy`;
                case 568155902:
                    return `America/La_Paz`;
                case 3838523700:
                    return `America/La_Paz`;
                case 754283829:
                    return `America/Port_of_Spain`;
                case 701832401:
                    return `America/Antigua`;
                case 1137609210:
                    return `America/Dominica`;
                case 1862445326:
                    return `America/Lower_Princes`;
                case 1709328184:
                    return `America/St_Lucia`;
                case 1222630138:
                    return `America/Marigot`;
                case 735932092:
                    return `America/Kralendijk`;
                case 1778012778:
                    return `America/Tortola`;
                case 903855377:
                    return `America/Montserrat`;
                case 924325685:
                    return `Etc/GMT+4`;
                case 1543126112:
                    return `America/St_Thomas`;
                case 786264949:
                    return `America/Manaus America/Boa_Vista America/Porto_Velho`;
                case 517823045:
                    return `America/Barbados`;
                case 2010192493:
                    return `America/Guyana`;
                case 870300139:
                    return `America/Martinique`;
                case 970274305:
                    return `America/Aruba`;
                case 552511116:
                    return `America/St_Kitts`;
                case 1056972519:
                    return `America/Puerto_Rico`;
                default:
                    return null;
            }
        case 1795993801:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Warsaw`;
                case 620754425:
                    return `Europe/Warsaw`;
                case 1860915135:
                    return `Europe/Zagreb`;
                case 467490188:
                    return `Europe/Sarajevo`;
                case 1038076329:
                    return `Europe/Skopje`;
                default:
                    return null;
            }
        case 40970471:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Riyadh`;
                case 971951591:
                    return `Asia/Kuwait`;
                case 940662019:
                    return `Asia/Aden`;
                case 1476560089:
                    return `Asia/Riyadh`;
                case 618488759:
                    return `Asia/Bahrain`;
                case 2348598919:
                    return `Asia/Qatar`;
                default:
                    return null;
            }
        case 1433856611:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Halifax`;
                case 534600664:
                    return `Atlantic/Bermuda`;
                case 2010780873:
                    return `America/Halifax America/Glace_Bay America/Goose_Bay America/Moncton`;
                case 1657862494:
                    return `America/Thule`;
                default:
                    return null;
            }
        case 1524402007:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Katmandu`;
                case 619077139:
                    return `Asia/Katmandu`;
                default:
                    return null;
            }
        case 3862269364:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Paris`;
                case 634133545:
                    return `Europe/Madrid Africa/Ceuta`;
                case 1993561969:
                    return `Europe/Paris`;
                case 1036943496:
                    return `Europe/Copenhagen`;
                case 400379712:
                    return `Europe/Brussels`;
                default:
                    return null;
            }
        case 3263679090:
            switch(territoryHash) {
                case 3838523700:
                    return `Europe/Bucharest`;
                case 1876559921:
                    return `Asia/Nicosia Asia/Famagusta`;
                case 1825638684:
                    return `Europe/Athens`;
                case 2181367182:
                    return `Europe/Bucharest`;
                default:
                    return null;
            }
        case 3638570227:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Montevideo`;
                case 1811126731:
                    return `America/Montevideo`;
                default:
                    return null;
            }
        case 451681703:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Tomsk`;
                case 1745149088:
                    return `Asia/Tomsk`;
                default:
                    return null;
            }
        case 2637784983:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Godthab`;
                case 1657862494:
                    return `America/Godthab`;
                default:
                    return null;
            }
        case 1173715463:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Tokyo`;
                case 620062877:
                    return `Asia/Dili`;
                case 1022431543:
                    return `Asia/Tokyo`;
                case 973084424:
                    return `Pacific/Palau`;
                case 1458105184:
                    return `Asia/Jayapura`;
                default:
                    return null;
            }
        case 4214403753:
            switch(territoryHash) {
                case 3838523700:
                    return `Australia/Lord_Howe`;
                case 936719067:
                    return `Australia/Lord_Howe`;
                default:
                    return null;
            }
        case 352956009:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Grand_Turk`;
                case 368398592:
                    return `America/Grand_Turk`;
                default:
                    return null;
            }
        case 1113718987:
            switch(territoryHash) {
                case 3838523700:
                    return `Africa/Sao_Tome`;
                case 1795334850:
                    return `Africa/Sao_Tome`;
                default:
                    return null;
            }
        case 138222780:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Barnaul`;
                case 1745149088:
                    return `Asia/Barnaul`;
                default:
                    return null;
            }
        case 3920261128:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Buenos_Aires`;
                case 1020607162:
                    return `America/Buenos_Aires America/Argentina/La_Rioja America/Argentina/Rio_Gallegos America/Argentina/Salta America/Argentina/San_Juan America/Argentina/San_Luis America/Argentina/Tucuman America/Argentina/Ushuaia America/Catamarca America/Cordoba America/Jujuy America/Mendoza`;
                default:
                    return null;
            }
        case 821022106:
            switch(territoryHash) {
                case 3838523700:
                    return `America/Cuiaba`;
                case 786264949:
                    return `America/Cuiaba America/Campo_Grande`;
                default:
                    return null;
            }
        case 720411819:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Jerusalem`;
                case 1592326136:
                    return `Asia/Jerusalem`;
                default:
                    return null;
            }
        case 2610914779:
            switch(territoryHash) {
                case 3838523700:
                    return `Asia/Tehran`;
                case 1827212802:
                    return `Asia/Tehran`;
                default:
                    return null;
            }
        default:
            return null;
    }
}
export extern(C) string ianaToWindows(scope string iana) @trusted nothrow @nogc pure {
    uint ianaHash = fnv_32_1a(cast(ubyte[])iana);
    switch(ianaHash) {
        case 2700496891:
            return "Easter Island Standard Time";
        case 2364551358:
            return "FLE Standard Time";
        case 2833003010:
            return "West Asia Standard Time";
        case 3204213819:
            return "Arab Standard Time";
        case 3040424833:
            return "China Standard Time";
        case 127287388:
            return "Eastern Standard Time";
        case 331757971:
            return "Russia Time Zone 3";
        case 679517143:
            return "West Pacific Standard Time";
        case 4264149754:
            return "Central Pacific Standard Time";
        case 3411184730:
            return "Venezuela Standard Time";
        case 2889984685:
            return "Russia Time Zone 11";
        case 1217353464:
            return "Korea Standard Time";
        case 3955798531:
            return "SA Western Standard Time";
        case 119618426:
            return "SA Pacific Standard Time";
        case 1208244866:
            return "GMT Standard Time";
        case 856732277:
            return "Sao Tome Standard Time";
        case 555616872:
            return "New Zealand Standard Time";
        case 2679126032:
            return "SA Western Standard Time";
        case 2570616020:
            return "Pacific Standard Time";
        case 2521770939:
            return "India Standard Time";
        case 3642723914:
            return "West Asia Standard Time";
        case 924126800:
            return "Cape Verde Standard Time";
        case 1239250046:
            return "SE Asia Standard Time";
        case 3228407202:
            return "Hawaiian Standard Time";
        case 3617863675:
            return "Central Europe Standard Time";
        case 2970194949:
            return "Marquesas Standard Time";
        case 3615354523:
            return "Atlantic Standard Time";
        case 2315030508:
            return "UTC";
        case 1556375339:
            return "Lord Howe Standard Time";
        case 3818852439:
            return "Russia Time Zone 11";
        case 848658002:
            return "South Africa Standard Time";
        case 472906037:
            return "Magadan Standard Time";
        case 2323269704:
            return "Greenwich Standard Time";
        case 3989352735:
            return "Greenwich Standard Time";
        case 3036473696:
            return "Vladivostok Standard Time";
        case 156046654:
            return "SA Pacific Standard Time";
        case 2637478482:
            return "Astrakhan Standard Time";
        case 222493823:
            return "West Pacific Standard Time";
        case 137307315:
            return "Central Pacific Standard Time";
        case 2740263968:
            return "Tasmania Standard Time";
        case 651202456:
            return "Greenwich Standard Time";
        case 4127925939:
            return "UTC+12";
        case 1480345237:
            return "UTC+12";
        case 2465674218:
            return "Belarus Standard Time";
        case 1369127586:
            return "Mauritius Standard Time";
        case 3380958978:
            return "Greenwich Standard Time";
        case 2098894182:
            return "Central America Standard Time";
        case 860496105:
            return "Sakhalin Standard Time";
        case 971360445:
            return "SE Asia Standard Time";
        case 8525148:
            return "Russian Standard Time";
        case 404917260:
            return "Central Pacific Standard Time";
        case 336225824:
            return "SA Pacific Standard Time";
        case 3476551753:
            return "Aleutian Standard Time";
        case 219778418:
            return "Central America Standard Time";
        case 3322320427:
            return "Greenwich Standard Time";
        case 2465805222:
            return "Central Europe Standard Time";
        case 1513074250:
            return "FLE Standard Time";
        case 1133580414:
            return "Jordan Standard Time";
        case 3075776433:
            return "Eastern Standard Time";
        case 658707050:
            return "Greenwich Standard Time";
        case 3565708578:
            return "Central Standard Time";
        case 1751684047:
            return "SA Western Standard Time";
        case 3167789631:
            return "South Africa Standard Time";
        case 1781327982:
            return "Newfoundland Standard Time";
        case 2820659404:
            return "Myanmar Standard Time";
        case 3900564427:
            return "SA Western Standard Time";
        case 2635732942:
            return "Central Standard Time";
        case 3447230823:
            return "SA Western Standard Time";
        case 3812678917:
            return "Central America Standard Time";
        case 3186815883:
            return "South Africa Standard Time";
        case 2703015794:
            return "FLE Standard Time";
        case 3999519897:
            return "Eastern Standard Time";
        case 907312187:
            return "Turks And Caicos Standard Time";
        case 1409753730:
            return "GMT Standard Time";
        case 1798267085:
            return "Arabian Standard Time";
        case 1783373845:
            return "FLE Standard Time";
        case 3326794860:
            return "Central Asia Standard Time";
        case 2700255026:
            return "Central Europe Standard Time";
        case 2104134023:
            return "SA Western Standard Time";
        case 4223099349:
            return "SA Western Standard Time";
        case 3696618852:
            return "FLE Standard Time";
        case 2194753814:
            return "FLE Standard Time";
        case 3365847555:
            return "Syria Standard Time";
        case 757077816:
            return "Yakutsk Standard Time";
        case 1326957920:
            return "South Sudan Standard Time";
        case 3600545458:
            return "SA Eastern Standard Time";
        case 738662459:
            return "South Africa Standard Time";
        case 822968381:
            return "UTC+12";
        case 4205793671:
            return "Afghanistan Standard Time";
        case 1486294486:
            return "Hawaiian Standard Time";
        case 3839527065:
            return "Mountain Standard Time";
        case 2617592208:
            return "Taipei Standard Time";
        case 3202559804:
            return "Yakutsk Standard Time";
        case 66266819:
            return "South Africa Standard Time";
        case 357352675:
            return "SA Western Standard Time";
        case 3633014052:
            return "Tokyo Standard Time";
        case 2916488251:
            return "West Pacific Standard Time";
        case 1652478072:
            return "Tasmania Standard Time";
        case 764517257:
            return "Greenwich Standard Time";
        case 1823299126:
            return "Central Pacific Standard Time";
        case 2415232109:
            return "Atlantic Standard Time";
        case 1158214532:
            return "SA Western Standard Time";
        case 2220219919:
            return "Chatham Islands Standard Time";
        case 2968926749:
            return "Tokyo Standard Time";
        case 2105410741:
            return "West Asia Standard Time";
        case 995303010:
            return "North Korea Standard Time";
        case 278982698:
            return "West Bank Standard Time";
        case 16754194:
            return "Iran Standard Time";
        case 3586756429:
            return "Pakistan Standard Time";
        case 3935110780:
            return "Egypt Standard Time";
        case 3247060437:
            return "West Asia Standard Time";
        case 1416355795:
            return "Greenwich Standard Time";
        case 2445136889:
            return "Central Standard Time";
        case 226556240:
            return "US Mountain Standard Time";
        case 407790710:
            return "Georgian Standard Time";
        case 598893307:
            return "SA Western Standard Time";
        case 2781884546:
            return "SA Western Standard Time";
        case 3588500963:
            return "GMT Standard Time";
        case 3810321767:
            return "West Asia Standard Time";
        case 309158836:
            return "Atlantic Standard Time";
        case 3433803006:
            return "Central Asia Standard Time";
        case 2744684553:
            return "SA Pacific Standard Time";
        case 821516526:
            return "SA Western Standard Time";
        case 1685811478:
            return "GMT Standard Time";
        case 2517463618:
            return "Samoa Standard Time";
        case 1813173314:
            return "Yukon Standard Time";
        case 2735489461:
            return "Greenwich Standard Time";
        case 901913695:
            return "SA Western Standard Time";
        case 1548690898:
            return "Arab Standard Time";
        case 879352378:
            return "Myanmar Standard Time";
        case 3494211012:
            return "GTB Standard Time";
        case 3153148591:
            return "Namibia Standard Time";
        case 1295543377:
            return "Sri Lanka Standard Time";
        case 2247647086:
            return "SA Western Standard Time";
        case 2647451522:
            return "West Pacific Standard Time";
        case 3955538665:
            return "Arabian Standard Time";
        case 1496990557:
            return "Astrakhan Standard Time";
        case 955879570:
            return "UTC+13";
        case 3141446371:
            return "UTC+12";
        case 4153589291:
            return "Cuba Standard Time";
        case 2974478361:
            return "Argentina Standard Time";
        case 3673542748:
            return "Central Europe Standard Time";
        case 19177823:
            return "Central Asia Standard Time";
        case 343464342:
            return "Tonga Standard Time";
        case 24467419:
            return "Ulaanbaatar Standard Time";
        case 3619131634:
            return "Paraguay Standard Time";
        case 440436624:
            return "GMT Standard Time";
        case 458642004:
            return "West Bank Standard Time";
        case 3189249063:
            return "Bangladesh Standard Time";
        case 1977517921:
            return "SE Asia Standard Time";
        case 1456513318:
            return "Cape Verde Standard Time";
        case 463575128:
            return "Tokyo Standard Time";
        case 1641759805:
            return "Arab Standard Time";
        case 1050750403:
            return "SA Western Standard Time";
        case 3303949175:
            return "Central Europe Standard Time";
        case 1982633640:
            return "Kaliningrad Standard Time";
        case 3690979653:
            return "Azerbaijan Standard Time";
        case 3194851964:
            return "Dateline Standard Time";
        case 2252800745:
            return "Eastern Standard Time";
        case 1534033918:
            return "Russian Standard Time";
        case 2717519923:
            return "South Africa Standard Time";
        case 3222828519:
            return "SA Western Standard Time";
        case 2599579798:
            return "China Standard Time";
        case 3642850851:
            return "GTB Standard Time";
        case 1866676257:
            return "China Standard Time";
        case 3004678079:
            return "US Mountain Standard Time";
        case 566343486:
            return "Canada Central Standard Time";
        case 472498334:
            return "SA Western Standard Time";
        case 3476145573:
            return "Greenland Standard Time";
        case 692350945:
            return "Magallanes Standard Time";
        case 3205096819:
            return "Greenwich Standard Time";
        case 3663377074:
            return "Singapore Standard Time";
        case 325560181:
            return "SA Eastern Standard Time";
        case 3153673759:
            return "Alaskan Standard Time";
        case 2206774244:
            return "Alaskan Standard Time";
        case 3470288316:
            return "Central America Standard Time";
        case 2357931103:
            return "Qyzylorda Standard Time";
        case 2760833236:
            return "Russian Standard Time";
        case 2808943893:
            return "Arab Standard Time";
        case 261162130:
            return "South Africa Standard Time";
        case 3527935022:
            return "Omsk Standard Time";
        case 1913005334:
            return "UTC+12";
        case 3192550788:
            return "Central Asia Standard Time";
        case 1944739000:
            return "Romance Standard Time";
        case 1751867740:
            return "Mountain Standard Time";
        case 3795707485:
            return "Russia Time Zone 10";
        case 4255224249:
            return "SA Pacific Standard Time";
        case 354309513:
            return "SA Pacific Standard Time";
        case 1336883198:
            return "SA Western Standard Time";
        case 1720322342:
            return "South Africa Standard Time";
        case 3039485671:
            return "Sudan Standard Time";
        case 2741021311:
            return "SA Eastern Standard Time";
        case 990081796:
            return "Central America Standard Time";
        case 1777889563:
            return "Nepal Standard Time";
        case 660011101:
            return "SE Asia Standard Time";
        case 3246638409:
            return "Central Asia Standard Time";
        case 3724642335:
            return "Middle East Standard Time";
        case 3154337901:
            return "Singapore Standard Time";
        case 1540401413:
            return "SA Western Standard Time";
        case 2867499402:
            return "Pacific SA Standard Time";
        case 1547045081:
            return "UTC";
        case 1986996262:
            return "Central Brazilian Standard Time";
        case 2905251793:
            return "Romance Standard Time";
        case 2397791102:
            return "Tokyo Standard Time";
        case 2577497954:
            return "West Pacific Standard Time";
        case 1201792382:
            return "Greenwich Standard Time";
        case 1739567360:
            return "Canada Central Standard Time";
        case 2493319562:
            return "SE Asia Standard Time";
        case 2358979970:
            return "Mauritius Standard Time";
        case 1792139228:
            return "Greenwich Standard Time";
        case 3348020006:
            return "Line Islands Standard Time";
        case 3395964507:
            return "Volgograd Standard Time";
        case 3617592624:
            return "Hawaiian Standard Time";
        case 1112663984:
            return "Pacific Standard Time";
        case 4125590834:
            return "GMT Standard Time";
        case 3636856728:
            return "GMT Standard Time";
        case 82989757:
            return "AUS Central Standard Time";
        case 2599400844:
            return "Morocco Standard Time";
        case 2880844587:
            return "Central America Standard Time";
        case 3695461223:
            return "Singapore Standard Time";
        case 645795175:
            return "US Eastern Standard Time";
        case 1422868943:
            return "Central European Standard Time";
        case 2778883243:
            return "FLE Standard Time";
        case 1933162224:
            return "North Asia Standard Time";
        case 2144708594:
            return "AUS Eastern Standard Time";
        case 1539134088:
            return "Central America Standard Time";
        case 2065647415:
            return "Yukon Standard Time";
        case 2851287739:
            return "Central Europe Standard Time";
        case 3423436429:
            return "Mountain Standard Time";
        case 2410865919:
            return "Hawaiian Standard Time";
        case 420200453:
            return "Transbaikal Standard Time";
        case 3322542634:
            return "Hawaiian Standard Time";
        case 2091318347:
            return "Pacific Standard Time";
        case 2923301723:
            return "Central European Standard Time";
        case 722623413:
            return "FLE Standard Time";
        case 3070507813:
            return "UTC+13";
        case 30858156:
            return "North Asia Standard Time";
        case 1523623794:
            return "SA Pacific Standard Time";
        case 1207357484:
            return "Saint Pierre Standard Time";
        case 2063304110:
            return "SA Pacific Standard Time";
        case 1405167450:
            return "SA Western Standard Time";
        case 2440680101:
            return "SA Western Standard Time";
        case 2490627539:
            return "Central European Standard Time";
        case 2416580664:
            return "Ulaanbaatar Standard Time";
        case 79321075:
            return "Libya Standard Time";
        case 4231276194:
            return "Romance Standard Time";
        case 728008424:
            return "Singapore Standard Time";
        case 2756484979:
            return "Argentina Standard Time";
        case 3860318744:
            return "Azores Standard Time";
        case 1668111868:
            return "Greenwich Standard Time";
        case 3560305841:
            return "Greenwich Standard Time";
        case 4267577999:
            return "SA Western Standard Time";
        case 1422958080:
            return "SA Eastern Standard Time";
        case 24141117:
            return "South Africa Standard Time";
        case 2346980826:
            return "Tomsk Standard Time";
        case 3783662874:
            return "SA Eastern Standard Time";
        case 2638665941:
            return "Morocco Standard Time";
        case 349197589:
            return "UTC+12";
        case 430981158:
            return "West Asia Standard Time";
        case 2827747020:
            return "US Mountain Standard Time";
        case 3649035651:
            return "West Asia Standard Time";
        case 1093353129:
            return "Bangladesh Standard Time";
        case 2839627341:
            return "SE Asia Standard Time";
        case 2329910453:
            return "Bahia Standard Time";
        case 3815991167:
            return "Mountain Standard Time";
        case 1489268849:
            return "Eastern Standard Time";
        case 1077287080:
            return "Azores Standard Time";
        case 3829601497:
            return "GTB Standard Time";
        case 274105005:
            return "SA Western Standard Time";
        case 3103778142:
            return "Israel Standard Time";
        case 808598189:
            return "SA Western Standard Time";
        case 539089156:
            return "SA Eastern Standard Time";
        case 714895209:
            return "SE Asia Standard Time";
        case 1734505048:
            return "Ekaterinburg Standard Time";
        case 1868880648:
            return "Singapore Standard Time";
        case 3769278047:
            return "North Asia East Standard Time";
        case 1346226359:
            return "Arabic Standard Time";
        case 4061067078:
            return "SA Pacific Standard Time";
        case 3196075854:
            return "GMT Standard Time";
        case 3717382837:
            return "Fiji Standard Time";
        case 1845133199:
            return "Romance Standard Time";
        case 243842761:
            return "Mauritius Standard Time";
        case 3508921748:
            return "AUS Eastern Standard Time";
        case 1165459888:
            return "Montevideo Standard Time";
        case 3122412401:
            return "US Eastern Standard Time";
        case 655282957:
            return "Arab Standard Time";
        case 142287442:
            return "Turkey Standard Time";
        case 3020131174:
            return "Bougainville Standard Time";
        case 1490068556:
            return "US Mountain Standard Time";
        case 617549878:
            return "Saratov Standard Time";
        case 4005611095:
            return "Mountain Standard Time";
        case 2133049520:
            return "Central Europe Standard Time";
        case 976392934:
            return "Atlantic Standard Time";
        case 2877326243:
            return "Central Asia Standard Time";
        case 4248626852:
            return "Central European Standard Time";
        case 911434708:
            return "Central Standard Time";
        case 171807745:
            return "SA Western Standard Time";
        case 2301981053:
            return "Tocantins Standard Time";
        case 1036744127:
            return "West Asia Standard Time";
        case 3010120993:
            return "Central Pacific Standard Time";
        case 2834432631:
            return "Central Brazilian Standard Time";
        case 550497745:
            return "Altai Standard Time";
        case 4099251223:
            return "South Africa Standard Time";
        case 2713093043:
            return "Greenwich Standard Time";
        case 2687905440:
            return "South Africa Standard Time";
        case 475368294:
            return "Norfolk Standard Time";
        case 1016457943:
            return "Central Standard Time";
        case 1575912215:
            return "SA Western Standard Time";
        case 1506846175:
            return "Central America Standard Time";
        case 157998199:
            return "New Zealand Standard Time";
        case 2834364976:
            return "Caucasus Standard Time";
        default:
            return null;
    }
}
