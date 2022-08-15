import std/unittest
import QRgen/private/[QRCode, EncodedQRCode, qrTypes]

test "Encoding QRCode":
  let encodedQr1 = encodeOnly newQRCode("8675309")

  check encodedQr1.encodedData.data == @[0b00010000'u8,
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


  let encodedQr2 = encodeOnly newQRCode("HELLO WORLD", eccLevel = qrEccQ)

  check encodedQr2.encodedData.data == @[0b00100000'u8,
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

  let encodedQr3 = encodeOnly newQRCode("Hello, world!")

  check encodedQr3.encodedData.data == @[0b01000000'u8,
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
  var encodedQr1 = newEncodedQRCode(5)

  encodedQr1.encodedData.data = @[
    67'u8,85,70,134,87,38,85,194,119,50,6,18,6,103,38,246,246,66,7,118,134,242,
    7,38,86,22,198,199,146,6,182,230,247,119,50,7,118,134,87,38,82,6,134,151,
    50,7,70,247,118,86,194,6,151,50,16,236,17,236,17,236,17,236
  ]

  encodedQr1.interleaveData qrEccQ

  check encodedQr1.encodedData.data == @[
    67'u8,246,182,70,85,246,230,247,70,66,247,118,134,7,119,86,87,118,50,194,
    38,134,7,6,85,242,118,151,194,7,134,50,119,38,87,16,50,86,38,236,6,22,82,
    17,18,198,6,236,6,199,134,17,103,146,151,236,38,6,50,17,7,236
  ]