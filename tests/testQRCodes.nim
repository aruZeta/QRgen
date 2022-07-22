import unittest
import QRgen

test "Set efficient mode":
  let qr1 = QRCode(data: "0123456789")
  qr1.setMostEfficientMode
  check qr1.mode == qrNumericMode

  let qr2 = QRCode(data: "0 TEST ALPHANUMERIC 9")
  qr2.setMostEfficientMode
  check qr2.mode == qrAlphanumericMode

  let qr3 = QRCode(data: "Tésting byté modé")
  qr3.setMostEfficientMode
  check qr3.mode == qrByteMode
