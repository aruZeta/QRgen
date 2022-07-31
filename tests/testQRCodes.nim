import unittest
import QRgen
import QRgen/private/types

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
