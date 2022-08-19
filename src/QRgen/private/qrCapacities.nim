from qrTypes import QRErrorCorrectionLevel, QRVersion

type
  QRCapacity*[T: uint8 | uint16] = array[
    QRErrorCorrectionLevel,
    array[QRVersion, T]
  ]

const
  numericModeCapacities*: QRCapacity[uint16] = [
    [ # ECC L
      41'u16, 77, 127, 187, 255, 322, 370, 461, 552, 652, 772, 883, 1022, 1101,
      1250, 1408, 1548, 1725, 1903, 2061, 2232, 2409, 2620, 2812, 3057, 3283,
      3517, 3669, 3909, 4158, 4417, 4686, 4965, 5253, 5529, 5836, 6153, 6479,
      6743, 7089
    ],
    [ # ECC M
      34'u16, 63, 101, 149, 202, 255, 293, 365, 432, 513, 604, 691, 796, 871,
      991, 1082, 1212, 1346, 1500, 1600, 1708, 1872, 2059, 2188, 2395, 2544,
      2701, 2857, 3035, 3289, 3486, 3693, 3909, 4134, 4343, 4588, 4775, 5039,
      5313, 5596
    ],
    [ # ECC Q
      27'u16, 48, 77, 111, 144, 178, 207, 259, 312, 364, 427, 489, 580, 621,
      703, 775, 876, 948, 1063, 1159, 1224, 1358, 1468, 1588, 1718, 1804, 1933,
      2085, 2181, 2358, 2473, 2670, 2805, 2949, 3081, 3244, 3417, 3599, 3791,
      3993
    ],
    [ # ECC H
      17'u16, 34, 58, 82, 106, 139, 154, 202, 235, 288, 331, 374, 427, 468,
      530, 602, 674, 746, 813, 919, 969, 1056, 1108, 1228, 1286, 1425, 1501,
      1581, 1677, 1782, 1897, 2022, 2157, 2301, 2361, 2524, 2625, 2735, 2927,
      3057
    ]
  ]

  alphanumericModeCapacities*: QRCapacity[uint16] = [
    [ # ECC L
      25'u16, 47, 77, 114, 154, 195, 224, 279, 335, 395, 468, 535, 619, 667,
      758, 854, 938, 1046, 1153, 1249, 1352, 1460, 1588, 1704, 1853, 1990, 2132,
      2223, 2369, 2520, 2677, 2840, 3009, 3183, 3351, 3537, 3729, 3927, 4087,
      4296
    ],
    [ # ECC M
      20'u16, 38, 61, 90, 122, 154, 178, 221, 262, 311, 366, 419, 483, 528, 600,
      656, 734, 816, 909, 970, 1035, 1134, 1248, 1326, 1451, 1542, 1637, 1732,
      1839, 1994, 2113, 2238, 2369, 2506, 2632, 2780, 2894, 3054, 3220, 3391
    ],
    [ # ECC Q
      16'u16, 29, 47, 67, 87, 108, 125, 157, 189, 221, 259, 296, 352, 376, 426,
      470, 531, 574, 644, 702, 742, 823, 890, 963, 1041, 1094, 1172, 1263, 1322,
      1429, 1499, 1618, 1700, 1787, 1867, 1966, 2071, 2181, 2298, 2420
    ],
    [ # ECC H
      10'u16, 20, 35, 50, 64, 84, 93, 122, 143, 174, 200, 227, 259, 283, 321,
      365, 408, 452, 493, 557, 587, 640, 672, 744, 779, 864, 910, 958, 1016,
      1080, 1150, 1226, 1307, 1394, 1431, 1530, 1591, 1658, 1774, 1852
    ]
  ]

  byteModeCapacities*: QRCapacity[uint16] = [
    [ # ECC L
      17'u16, 32, 53, 78, 106, 134, 154, 192, 230, 271, 321, 367, 425, 458, 520,
      586, 644, 718, 792, 858, 929, 1003, 1091, 1171, 1273, 1367, 1465, 1528,
      1628, 1732, 1840, 1952, 2068, 2188, 2303, 2431, 2563, 2699, 2809, 2953
    ],
    [ # ECC M
      14'u16, 26, 42, 62, 84, 106, 122, 152, 180, 213, 251, 287, 331, 362, 412,
      450, 504, 560, 624, 666, 711, 779, 857, 911, 997, 1059, 1125, 1190, 1264,
      1370, 1452, 1538, 1628, 1722, 1809, 1911, 1989, 2099, 2213, 2331
    ],
    [ # ECC Q
      11'u16, 20, 32, 46, 60, 74, 86, 108, 130, 151, 177, 203, 241, 258, 292,
      322, 364, 394, 442, 482, 509, 565, 611, 661, 715, 751, 805, 868, 908, 982,
      1030, 1112, 1168, 1228, 1283, 1351, 1423, 1499, 1579, 1663
    ],
    [ # ECC H
      7'u16, 14, 24, 34, 44, 58, 64, 84, 98, 119, 137, 155, 177, 194, 220, 250,
      280, 310, 338, 382, 403, 439, 461, 511, 535, 593, 625, 658, 698, 742, 790,
      842, 898, 958, 983, 1051, 1093, 1139, 1219, 1273
    ]
  ]

  totalDataCodewords*: QRCapacity[uint16] = [
    [ # ECC L
      19'u16, 34, 55, 80, 108, 136, 156, 194, 232, 274, 324, 370, 428, 461,
      523, 589, 647, 721, 795, 861, 932, 1006, 1094, 1174, 1276, 1370, 1468,
      1531, 1631, 1735, 1843, 1955, 2071, 2191, 2306, 2434, 2566, 2702, 2812,
      2956
    ],
    [ # ECC M
      16'u16, 28, 44, 64, 86, 108, 124, 154, 182, 216, 254, 290, 334, 365, 415,
      453, 507, 563, 627, 669, 714, 782, 860, 914, 1000, 1062, 1128, 1193,
      1267, 1373, 1455, 1541, 1631, 1725, 1812, 1914, 1992, 2102, 2216, 2334
    ],
    [ # ECC Q
      13'u16, 22, 34, 48, 62, 76, 88, 110, 132, 154, 180, 206, 244, 261, 295,
      325, 367, 397, 445, 485, 512, 568, 614, 664, 718, 754, 808, 871, 911,
      985, 1033, 1115, 1171, 1231, 1286, 1354, 1426, 1502, 1582, 1666
    ],
    [ # ECC H
      9'u16, 16, 26, 36, 46, 60, 66, 86, 100, 122, 140, 158, 180, 197, 223,
      253, 283, 313, 341, 385, 406, 442, 464, 514, 538, 596, 628, 661, 701,
      745, 793, 845, 901, 961, 986, 1054, 1096, 1142, 1222, 1276
    ]
  ]

  group1Blocks*: QRCapacity[uint8] = [
    [ # ECC L
      1'u8, 1, 1, 1, 1, 2, 2, 2, 2, 2, 4, 2, 4, 3, 5, 5, 1, 5, 3, 3, 4, 2, 4,
      6, 8, 10, 8, 3, 7, 5, 13, 17, 17, 13, 12, 6, 17, 4, 20, 19
    ],
    [ # ECC M
      1'u8, 1, 1, 2, 2, 4, 4, 2, 3, 4, 1, 6, 8, 4, 5, 7, 10, 9, 3, 3, 17, 17,
      4, 6, 8, 19, 22, 3, 21, 19, 2, 10, 14, 14, 12, 6, 29, 13, 40, 18
    ],
    [ # ECC Q
      1'u8, 1, 2, 2, 2, 4, 2, 4, 4, 6, 4, 4, 8, 11, 5, 15, 1, 17, 17, 15, 17,
      7, 11, 11, 7, 28, 8, 4, 1, 15, 42, 10, 29, 44, 39, 46, 49, 48, 43, 34
    ],
    [ # ECC H
      1'u8, 1, 2, 4, 2, 4, 4, 4, 4, 6, 3, 7, 12, 11, 11, 3, 2, 2, 9, 15, 19,
      34, 16, 30, 22, 33, 12, 11, 19, 23, 23, 19, 11, 59, 22, 2, 24, 42, 10,
      20
    ]
  ]

  group1BlockDataCodewords*: QRCapacity[uint8] = [
    [
      19'u8, 34, 55, 80, 108, 68, 78, 97, 116, 68, 81, 92, 107, 115, 87, 98,
      107, 120, 113, 107, 116, 111, 121, 117, 106, 114, 122, 117, 116, 115,
      115, 115, 115, 115, 121, 121, 122, 122, 117, 118
    ],
    [
      16'u8, 28, 44, 32, 43, 27, 31, 38, 36, 43, 50, 36, 37, 40, 41, 45, 46,
      43, 44, 41, 42, 46, 47, 45, 47, 46, 45, 45, 45, 47, 46, 46, 46, 46, 47,
      47, 46, 46, 47, 47
    ],
    [
      13'u8, 22, 17, 24, 15, 19, 14, 18, 16, 19, 22, 20, 20, 16, 24, 19, 22,
      22, 21, 24, 22, 24, 24, 24, 24, 22, 23, 24, 23, 24, 24, 24, 24, 24, 24,
      24, 24, 24, 24, 24
    ],
    [
      9'u8, 16, 13, 9, 11, 15, 13, 14, 12, 15, 12, 14, 11, 12, 12, 15, 14, 14,
      13, 15, 16, 13, 15, 16, 15, 16, 15, 15, 15, 15, 15, 15, 15, 16, 15, 15,
      15, 15, 15, 15
    ]
  ]

  group2Blocks*: QRCapacity[uint8] = [
    [
      0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 1, 1, 1, 5, 1, 4, 5, 4, 7, 5,
      4, 4, 2, 4, 10, 7, 10, 3, 0, 1, 6, 7, 14, 4, 18, 4, 6
    ],
    [
      0'u8, 0, 0, 0, 0, 0, 0, 2, 2, 1, 4, 2, 1, 5, 5, 3, 1, 4, 11, 13, 0, 0,
      14, 14, 13, 4, 3, 23, 7, 10, 29, 23, 21, 23, 26, 34, 14, 32, 7, 31
    ],
    [
      0'u8, 0, 0, 0, 2, 0, 4, 2, 4, 2, 4, 6, 4, 5, 7, 2, 15, 1, 4, 5, 6, 16,
      14, 16, 22, 6, 26, 31, 37, 25, 1, 35, 19, 7, 14, 10, 10, 14, 22, 34
    ],
    [
      0'u8, 0, 0, 0, 2, 0, 1, 2, 4, 2, 8, 4, 4, 5, 7, 13, 17, 19, 16, 10, 6, 0,
      14, 2, 13, 4, 28, 31, 26, 25, 28, 35, 46, 1, 41, 64, 46, 32, 67, 61
    ]
  ]

  group2BlockDataCodewords*: QRCapacity[uint8] = [
    [
      0'u8, 0, 0, 0, 0, 0, 0, 0, 0, 69, 0, 93, 0, 116, 88, 99, 108, 121, 114,
      108, 117, 112, 122, 118, 107, 115, 123, 118, 117, 116, 116, 0, 116, 116,
      122, 122, 123, 123, 118, 119
    ],
    [
      0'u8, 0, 0, 0, 0, 0, 0, 39, 37, 44, 51, 37, 38, 41, 42, 46, 47, 44, 45,
      42, 0, 0, 48, 46, 48, 47, 46, 46, 46, 48, 47, 47, 47, 47, 48, 48, 47, 47,
      48, 48
    ],
    [
      0'u8, 0, 0, 0, 16, 0, 15, 19, 17, 20, 23, 21, 21, 17, 25, 20, 23, 23, 22,
      25, 23, 25, 25, 25, 25, 23, 24, 25, 24, 25, 25, 25, 25, 25, 25, 25, 25,
      25, 25, 25
    ],
    [
      0'u8, 0, 0, 0, 12, 0, 14, 15, 13, 16, 13, 15, 12, 13, 13, 16, 15, 15, 14,
      16, 17, 0, 16, 17, 16, 17, 16, 16, 16, 16, 16, 16, 16, 17, 16, 16, 16,
      16, 16, 16
    ]
  ]

  blockECCodewords*: QRCapacity[uint8] = [
    [
      7'u8, 10, 15, 20, 26, 18, 20, 24, 30, 18, 20, 24, 26, 30, 22, 24, 28, 30,
      28, 28, 28, 28, 30, 30, 26, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30
    ],
    [
      10'u8, 16, 26, 18, 24, 16, 18, 22, 22, 26, 30, 22, 22, 24, 24, 28, 28,
      26, 26, 26, 26, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
      28, 28, 28, 28, 28
    ],
    [
      13'u8, 22, 18, 26, 18, 24, 18, 22, 20, 24, 28, 26, 24, 20, 30, 24, 28,
      28, 26, 30, 28, 30, 30, 30, 30, 28, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30
    ],
    [
      17'u8, 28, 22, 16, 22, 28, 26, 26, 24, 28, 24, 28, 22, 24, 24, 30, 28,
      28, 26, 28, 30, 24, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30
    ]
  ]

  alignmentPatternLocations*: array[QRVersion, seq[uint8]] = [
    @[],
    @[18'u8],
    @[22'u8],
    @[26'u8],
    @[30'u8],
    @[34'u8],
    @[22'u8, 38],
    @[24'u8, 42],
    @[26'u8, 46],
    @[28'u8, 50],
    @[30'u8, 54],
    @[32'u8, 58],
    @[34'u8, 62],
    @[26'u8, 46, 66],
    @[26'u8, 48, 70],
    @[26'u8, 50, 74],
    @[30'u8, 54, 78],
    @[30'u8, 56, 82],
    @[30'u8, 58, 86],
    @[34'u8, 62, 90],
    @[28'u8, 50, 72, 94],
    @[26'u8, 50, 74, 98],
    @[30'u8, 54, 78, 102],
    @[28'u8, 54, 80, 106],
    @[32'u8, 58, 84, 110],
    @[30'u8, 58, 86, 114],
    @[34'u8, 62, 90, 118],
    @[26'u8, 50, 74, 098, 122],
    @[30'u8, 54, 78, 102, 126],
    @[26'u8, 52, 78, 104, 130],
    @[30'u8, 56, 82, 108, 134],
    @[34'u8, 60, 86, 112, 138],
    @[30'u8, 58, 86, 114, 142],
    @[34'u8, 62, 90, 118, 146],
    @[30'u8, 54, 78, 102, 126, 150],
    @[24'u8, 50, 76, 102, 128, 154],
    @[28'u8, 54, 80, 106, 132, 158],
    @[32'u8, 58, 84, 110, 136, 162],
    @[26'u8, 54, 82, 110, 138, 166],
    @[30'u8, 58, 86, 114, 142, 170]
  ]
