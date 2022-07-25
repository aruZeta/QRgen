import unittest
import QRgen
import QRgen/types

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
