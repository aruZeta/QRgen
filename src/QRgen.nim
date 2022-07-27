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

proc encode*(qr: QRCode) =
  const zero: uint8  = cast[uint8]('0')

  # Mode indicator
  qr.encodedData.add cast[uint8](qr.mode), 4

  # Character count indicator
  qr.encodedData.add cast[uint16](qr.data.len), qr.characterCountIndicatorLen

  case qr.mode
  of qrNumericMode:
    let
      groups:           uint16 = cast[uint16](qr.data.len div 3)
      charsLeft:        uint8  = cast[uint8](qr.data.len mod 3)
      modeAndCountBits: uint16 = cast[uint16](qr.encodedData.pos)

    # Encoded data
    for i in 0'u16..<groups:
      let
        c1: uint16 = cast[uint8](qr.data[i*3]) - zero
        c2: uint16 = cast[uint8](qr.data[i*3+1]) - zero
        c3: uint16 = cast[uint8](qr.data[i*3+2]) - zero

      qr.encodedData.add(
        c1 * 100 + c2 * 10 + c3,
        (if c1 == 0:
           if c2 == 0: 0
           else: 3
         else: 6) + 4'u8
      )
      echo c1 * 100 + c2 * 10 + c3

    if charsLeft == 1:
      let c1: uint16 = cast[uint8](qr.data[qr.data.len-1]) - zero
      qr.encodedData.add c1, 4
    elif charsLeft == 2:
      let
        c1: uint16 = cast[uint8](qr.data[qr.data.len-2]) - zero
        c2: uint16 = cast[uint8](qr.data[qr.data.len-1]) - zero
      qr.encodedData.add c1 * 10 + c2, 7

    let missingBits: uint16 = cast[uint8](
      (eccCodewords[qr.eccLevel][qr.version] * 8) -
      (cast[uint16](qr.encodedData.pos) - modeAndCountBits)
    )

    # Terminator
    qr.encodedData.add 0b0000'u8, (if missingBits > 4: 4'u8
                                   else: cast[uint8](missingBits))

    # Fill the last byte
    qr.encodedData.nextByte
  of qrAlphanumericMode:
    discard
  of qrByteMode:
    discard
