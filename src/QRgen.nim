import QRgen/types

type
  QRCode* = ref object
    mode*: QRMode
    eccLevel*: QRErrorCorrectionLevel
    data*: string
    sideSize*: uint8 # The QR code is a square, all sides have the same size
    version*: QRVersion

const
  numericValues = {'0'..'9'}
  alphaNumericValues = {
    ' ', '$', '%', '*', '+', '-', '.', '/', ':', '0'..'9', 'A'..'Z'
  }

proc setMostEfficientMode*(qr: QRCode) =
  qr.mode = qrNumericMode
  for c in qr.data:
    if c notin alphaNumericValues:
      qr.mode = qrByteMode
      return
    elif qr.mode != qrAlphanumericMode and c notin numericValues:
      qr.mode = qrAlphanumericMode
