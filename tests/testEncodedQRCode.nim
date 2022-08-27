import myTestSuite
import QRgen/private/[BitArray, QRCode, EncodedQRCode, qrTypes]

benchmarkTest "encodeCharCountIndicator()":
  var text1 = "0123"
  var qr1 = newEncodedQRCode(newQRCode(text1, version = 28))
  qr1.encodeCharCountIndicator text1
  check qr1.encodedData.pos == 14'u8

  var text2 = "0 TEST ALPHANUMERIC 9"
  var qr2 = newEncodedQRCode(newQRCode(text2, version = 15))
  qr2.encodeCharCountIndicator text2
  check qr2.encodedData.pos == 11'u8

  var text3 = "012 Tésting byté modé 789"
  var qr3 = newEncodedQRCode(newQRCode(text3, version = 6))
  qr3.encodeCharCountIndicator text3
  check qr3.encodedData.pos == 8'u8

benchmarkTest "encodeOnly()":
  let qr1 = encodeOnly newQRCode("8675309")

  check qr1.encodedData[0..18] == @[0b00010000'u8,0b00011111,0b01100011,0b10000100,0b10100100,0b00000000,0b11101100,0b00010001,0b11101100,0b00010001,0b11101100,0b00010001,0b11101100,0b00010001,0b11101100,0b00010001,0b11101100,0b00010001,0b11101100]

  let qr2 = encodeOnly newQRCode("HELLO WORLD", ecLevel = qrEcQ)

  check qr2.encodedData[0..12] == @[0b00100000'u8,0b01011011,0b00001011,0b01111000,0b11010001,0b01110010,0b11011100,0b01001101,0b01000011,0b01000000,0b11101100,0b00010001,0b11101100]

  let qr3 = encodeOnly newQRCode("Hello, world!")

  check qr3.encodedData[0..18] == @[0b01000000'u8,0b11010100,0b10000110,0b01010110,0b11000110,0b11000110,0b11110010,0b11000010,0b00000111,0b01110110,0b11110111,0b00100110,0b11000110,0b01000010,0b00010000,0b11101100,0b00010001,0b11101100,0b00010001]

benchmarkTest "interleaveData()":
  var qr1 = newEncodedQRCode(5, ecLevel = qrEcQ)

  qr1.encodedData.data = @[67'u8,85,70,134,87,38,85,194,119,50,6,18,6,103,38,246,246,66,7,118,134,242,7,38,86,22,198,199,146,6,182,230,247,119,50,7,118,134,87,38,82,6,134,151,50,7,70,247,118,86,194,6,151,50,16,236,17,236,17,236,17,236]

  qr1.interleaveData

  check qr1.encodedData.data == @[67'u8,246,182,70,85,246,230,247,70,66,247,118,134,7,119,86,87,118,50,194,38,134,7,6,85,242,118,151,194,7,134,50,119,38,87,16,50,86,38,236,6,22,82,17,18,198,6,236,6,199,134,17,103,146,151,236,38,6,50,17,7,236]

benchmarkTest "interleaveData() not touching ecc codewords":
  var qr1 = encodeOnly newQRCode("Hello, world!", version = 3, ecLevel = qrEcQ)
  qr1.interleaveData

  check qr1.encodedData.data[34..69] == @[135'u8,92,231,244,155,101,127,60,162,188,37,72,136,36,55,77,65,44,105,32,214,166,21,0,169,197,123,43,92,124,82,170,23,172,216,71]

benchmarkTest "encodeEcCodewords()":
  var qr1 = encodeOnly newQRCode("HELLO WORLD", ecLevel = qrEcM)

  check qr1.encodedData.data[16..25] == @[196'u8,35,39,119,235,215,231,226,93,23]
