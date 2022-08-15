import std/unittest
import QRgen/private/[QRCode, qrTypes]

test "Set most efficient mode":
  let qr1 = newQRCode("0123456789")
  check qr1.mode == qrNumericMode

  let qr2 = newQRCode("0 TEST ALPHANUMERIC 9")
  check qr2.mode == qrAlphanumericMode

  let qr3 = newQRCode("Tésting byté modé")
  check qr3.mode == qrByteMode

test "Set smallest version":
  let qr1 = newQRCode("0123", eccLevel = qrEccH)
  check qr1.version == 1

  let qr2 = newQRCode("0 TEST ALPHANUMERIC 9", eccLevel = qrEccQ)
  check qr2.version == 2

  let qr3 = newQRCode("012 Tésting byté modé 789", eccLevel = qrEccH)
  check qr3.version == 4 # The accented characters count by 2