import QRgen/types
import QRgen/capacities
import QRgen/bitArray

type
  QRCode* = ref object
    mode*: QRMode
    eccLevel*: QRErrorCorrectionLevel
    data*: string
    sideSize*: uint8 # The QR code is a square, all sides have the same size
    version*: QRVersion
    encodedData*: BitArray

const
  numericValues = {'0'..'9'}
  alphaNumericValues = {
    ' ', '$', '%', '*', '+', '-', '.', '/', ':', '0'..'9', 'A'..'Z'
  }

proc newQRCode*(data: string,
                version: QRVersion = 1,
                eccLevel: QRErrorCorrectionLevel = qrEccL
               ): QRCode =
  QRCode(data: data,
         version: version,
         eccLevel: eccLevel,
         encodedData: newBitArray())

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

proc characterCountIndicatorLen*(qr: QRCode): uint8 =
  template qrCases(numericVal, alphanumericVal, byteVal: uint8) =
    case qr.mode
    of qrNumericMode:      result = numericVal
    of qrAlphanumericMode: result = alphanumericVal
    of qrByteMode:         result = byteVal

  if qr.version <= 9:
    qrCases 10, 9, 8
  elif qr.version >= 27:
    qrCases 14, 13, 16
  else:
    qrCases 12, 11, 16
