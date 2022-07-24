import QRgen/types
import QRgen/capacities

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

proc newQRCode*(data: string,
                version: QRVersion = 1,
                eccLevel: QRErrorCorrectionLevel = qrEccL
               ): QRCode =
  QRCode(data: data, version: version, eccLevel: eccLevel)

proc setMostEfficientMode*(qr: QRCode) =
  qr.mode = qrNumericMode
  for c in qr.data:
    if c notin alphaNumericValues:
      qr.mode = qrByteMode
      return
    elif qr.mode != qrAlphanumericMode and c notin numericValues:
      qr.mode = qrAlphanumericMode

proc setSmallestVersion*(qr: QRCode) =
  for i, version in (case qr.mode
                     of qrNumericMode:
                       numericModeCapacities[qr.eccLevel]
                     of qrAlphanumericMode:
                       alphanumericModeCapacities[qr.eccLevel]
                     of qrByteMode:
                       byteModeCapacities[qr.eccLevel]):
    if cast[uint16](qr.data.len) < version:
      qr.version = i
      return

  # else the string is too long to fit inside a qr code
