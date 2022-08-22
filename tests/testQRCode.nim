import myTestSuite
import QRgen/private/[QRCode, qrTypes]

benchmarkTest "newQRCode()":
  let qr1 = newQRCode("0123456789")
  check qr1.mode == qrNumericMode

  let qr2 = newQRCode("0 TEST ALPHANUMERIC 9")
  check qr2.mode == qrAlphanumericMode

  let qr3 = newQRCode("Tésting byté modé")
  check qr3.mode == qrByteMode

  let qr4 = newQRCode("0123", eccLevel = qrEccH)
  check qr4.version == 1

  let qr5 = newQRCode("0 TEST ALPHANUMERIC 9", eccLevel = qrEccQ)
  check qr5.version == 2

  let qr6 = newQRCode("012 Tésting byté modé 789", eccLevel = qrEccH)
  check qr6.version == 4 # The accented characters count by 2
