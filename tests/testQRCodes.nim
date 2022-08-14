import std/unittest
import QRgen

test "Set most efficient mode":
  let qr1 = newQRCode("0123456789")
  qr1.setMostEfficientMode
  check qr1.mode == qrNumericMode

  let qr2 = newQRCode("0 TEST ALPHANUMERIC 9")
  qr2.setMostEfficientMode
  check qr2.mode == qrAlphanumericMode

  let qr3 = newQRCode("Tésting byté modé")
  qr3.setMostEfficientMode
  check qr3.mode == qrByteMode

test "Set smallest version":
  let qr1 = newQRCode("0123",
                      eccLevel = qrEccH)
  qr1.setMostEfficientMode
  qr1.setSmallestVersion
  check qr1.version == 1

  let qr2 = newQRCode("0 TEST ALPHANUMERIC 9",
                      eccLevel = qrEccQ)
  qr2.setMostEfficientMode
  qr2.setSmallestVersion
  check qr2.version == 2

  let qr3 = newQRCode("012 Tésting byté modé 789",
                      eccLevel = qrEccH)
  qr3.setMostEfficientMode
  qr3.setSmallestVersion
  check qr3.version == 4 # The accented characters count by 2

test "Character count indicator len":
  let qr1 = newQRCode("0123")
  qr1.setMostEfficientMode
  qr1.version = 28
  check qr1.characterCountIndicatorLen() == 14

  let qr2 = newQRCode("0 TEST ALPHANUMERIC 9")
  qr2.setMostEfficientMode
  qr2.version = 15
  check qr2.characterCountIndicatorLen() == 11

  let qr3 = newQRCode("012 Tésting byté modé 789")
  qr3.setMostEfficientMode
  qr3.version = 6
  check qr3.characterCountIndicatorLen() == 8

test "Encoding":
  let qr1 = newQRCode("8675309")
  qr1.setMostEfficientMode
  qr1.setSmallestVersion
  qr1.encode

  check qr1.encodedData.data == @[0b00010000'u8,
                                  0b00011111'u8,
                                  0b01100011'u8,
                                  0b10000100'u8,
                                  0b10100100'u8,
                                  0b00000000'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8]

  let qr2 = newQRCode("HELLO WORLD", eccLevel = qrEccQ)
  qr2.setMostEfficientMode
  qr2.setSmallestVersion
  qr2.encode

  check qr2.encodedData.data == @[0b00100000'u8,
                                  0b01011011'u8,
                                  0b00001011'u8,
                                  0b01111000'u8,
                                  0b11010001'u8,
                                  0b01110010'u8,
                                  0b11011100'u8,
                                  0b01001101'u8,
                                  0b01000011'u8,
                                  0b01000000'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8]

  let qr3 = newQRCode("Hello, world!")
  qr3.setMostEfficientMode
  qr3.setSmallestVersion
  qr3.encode

  check qr3.encodedData.data == @[0b01000000'u8,
                                  0b11010100'u8,
                                  0b10000110'u8,
                                  0b01010110'u8,
                                  0b11000110'u8,
                                  0b11000110'u8,
                                  0b11110010'u8,
                                  0b11000010'u8,
                                  0b00000111'u8,
                                  0b01110110'u8,
                                  0b11110111'u8,
                                  0b00100110'u8,
                                  0b11000110'u8,
                                  0b01000010'u8,
                                  0b00010000'u8,
                                  0b11101100'u8,
                                  0b00010001'u8,
                                  0b11101100'u8,
                                  0b00010001'u8]

test "Interleaving":
  let qr1 = newQRCode("")
  qr1.version = 5
  qr1.eccLevel = qrEccQ

  qr1.encodedData.data = @[
    67'u8,85,70,134,87,38,85,194,119,50,6,18,6,103,38,246,246,66,7,118,134,242,
    7,38,86,22,198,199,146,6,182,230,247,119,50,7,118,134,87,38,82,6,134,151,
    50,7,70,247,118,86,194,6,151,50,16,236,17,236,17,236,17,236
  ]

  qr1.interleave

  check qr1.encodedData.data == @[
    67'u8,246,182,70,85,246,230,247,70,66,247,118,134,7,119,86,87,118,50,194,
    38,134,7,6,85,242,118,151,194,7,134,50,119,38,87,16,50,86,38,236,6,22,82,
    17,18,198,6,236,6,199,134,17,103,146,151,236,38,6,50,17,7,236
  ]

test "Remainder bits":
  let qr1 = newQRCode("")
  qr1.version = 5
  qr1.eccLevel = qrEccQ

  qr1.encodedData.data = @[
    67'u8,85,70,134,87,38,85,194,119,50,6,18,6,103,38,246,246,66,7,118,134,242,
    7,38,86,22,198,199,146,6,182,230,247,119,50,7,118,134,87,38,82,6,134,151,
    50,7,70,247,118,86,194,6,151,50,16,236,17,236,17,236,17,236
  ]

  qr1.interleave

  # Since I didn't use the add proc, the pos was not updated
  qr1.encodedData.pos = cast[uint16](qr1.encodedData.data.len) * 8

  qr1.addRemainderBits

  check qr1.encodedData.data == @[
    67'u8,246,182,70,85,246,230,247,70,66,247,118,134,7,119,86,87,118,50,194,
    38,134,7,6,85,242,118,151,194,7,134,50,119,38,87,16,50,86,38,236,6,22,82,
    17,18,198,6,236,6,199,134,17,103,146,151,236,38,6,50,17,7,236,0
  ]

  # 7 bits were added
  check qr1.encodedData.pos mod 8 == 7
