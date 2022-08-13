import QRgen/private/[qrTypes, qrCapacities, bitArray, qrCharacters]
import std/encodings

type
  QRCode* = ref object
    mode*: QRMode
    eccLevel*: QRErrorCorrectionLevel
    data*: string
    sideSize*: uint8 # The QR code is a square, all sides have the same size
    version*: QRVersion
    encodedData*: BitArray

template `[]`[T: uint8 | uint16](capacity: QRCapacity[T], qr: QRCode): T =
  capacity[qr.eccLevel][qr.version]

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
  # Mode indicator
  qr.encodedData.add cast[uint8](qr.mode), 4

  # Character count indicator
  qr.encodedData.add cast[uint16](qr.data.len), qr.characterCountIndicatorLen

  # Mode specific data encoding
  case qr.mode
  of qrNumericMode:
    let
      groups:    uint16 = cast[uint16](qr.data.len div 3)
      charsLeft: uint8  = cast[uint8](qr.data.len mod 3)

    # Encoded data
    for i in 0'u16..<groups:
      let
        c1: uint16 = getAlphanumericValue qr.data[i*3]
        c2: uint16 = getAlphanumericValue qr.data[i*3+1]
        c3: uint16 = getAlphanumericValue qr.data[i*3+2]

      qr.encodedData.add(
        c1 * 100 + c2 * 10 + c3,
        (if c1 == 0:
           if c2 == 0: 0
           else: 3
         else: 6) + 4'u8
      )
    if charsLeft == 1:
      let c1: uint16 = getAlphanumericValue qr.data[qr.data.len-1]
      qr.encodedData.add c1, 4
    elif charsLeft == 2:
      let
        c1: uint16 = getAlphanumericValue qr.data[qr.data.len-2]
        c2: uint16 = getAlphanumericValue qr.data[qr.data.len-1]
      qr.encodedData.add c1 * 10 + c2, 7
  of qrAlphanumericMode:
    let
      groups:    uint16 = cast[uint16](qr.data.len div 2)
      charsLeft: uint8  = cast[uint8](qr.data.len mod 2)

    # Encoded data
    for i in 0'u16..<groups:
      let
        c1: uint8 = getAlphanumericValue qr.data[i*2]
        c2: uint8 = getAlphanumericValue qr.data[i*2+1]

      qr.encodedData.add c1 * 45'u16 + c2, 11
    if charsLeft == 1:
      qr.encodedData.add getAlphanumericValue(qr.data[qr.data.len-1]), 6
  of qrByteMode:
    for c in convert(qr.data, "ISO 8859-1", "UTF-8"):
      qr.encodedData.add cast[uint8](c), 8

  var missingBits: uint16 =
    (totalDataCodewords[qr] * 8) - qr.encodedData.pos

  # Terminator
  let terminatorBits: uint8 = if missingBits > 4: 4'u8
                              else: cast[uint8](missingBits)
  qr.encodedData.add 0b0000'u8, terminatorBits
  missingBits -= terminatorBits

  # Fill the last byte
  missingBits -= qr.encodedData.nextByte

  # Add pad bytes to fill the missing bits
  for _ in 1'u16..((missingBits div 8) div 2):
    qr.encodedData.add 0b11101100'u8, 8
    qr.encodedData.add 0b00010001'u8, 8

  if ((missingBits div 8) mod 2) == 1:
    qr.encodedData.add 0b11101100'u8, 8

proc interleave*(qr: QRCode) =
  if group1Blocks[qr] == 1 and group2Blocks[qr] == 0:
    return

  # What a mess
  iterator codewordPositions: uint16 {.inline.} =
    for i in 0'u8..<max(group1BlockDataCodewords[qr],
                        group2BlockDataCodewords[qr]):
      if i < group1BlockDataCodewords[qr]:
        for j in 0'u8..<group1Blocks[qr]:
          yield j * group1BlockDataCodewords[qr] + i

      if i < group2BlockDataCodewords[qr]:
        for j in 0'u8..<group2Blocks[qr]:
          yield group1Blocks[qr] * group1BlockDataCodewords[qr] +
            j * group2BlockDataCodewords[qr] + i

  var
    dataCopy: seq[uint8] = qr.encodedData.data
    i: int16 = 0

  for pos in codewordPositions():
    qr.encodedData.data[i] = dataCopy[pos]
    inc i

export qrTypes
