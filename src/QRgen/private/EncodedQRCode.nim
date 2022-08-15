import QRCode, BitArray, qrTypes, qrCapacities, qrCharacters
import std/encodings

type
  EncodedQRCode* = object
    version*: QRVersion # Needed for drawing the QR code
    encodedData*: BitArray
    # Yet to implement the algorithm to generate them
    eccCodewords*: BitArray
    remainderBits*: uint8

proc encodeModeIndicator(qr: var EncodedQRCode, mode: QRMode) =
  qr.encodedData.add cast[uint8](mode), 4

proc charCountIndicatorLen*(mode: QRMode, version: QRVersion): uint8 =
  template qrCases(numericVal, alphanumericVal, byteVal: uint8): uint8 =
    case mode
    of qrNumericMode:      numericVal
    of qrAlphanumericMode: alphanumericVal
    of qrByteMode:         byteVal

  if version <= 9:    qrCases 10, 9, 8
  elif version >= 27: qrCases 14, 13, 16
  else:                qrCases 12, 11, 16

proc encodeCharCountIndicator*(qr: var EncodedQRCode,
                               mode: QRMode,
                               data: string) =
  qr.encodedData.add(
    cast[uint16](data.len),
    charCountIndicatorLen(mode, qr.version)
  )

proc encodeNumericModeData(qr: var EncodedQRCode, data: string) =
  let
    groups:    uint16 = cast[uint16](data.len div 3)
    charsLeft: uint8  = cast[uint8](data.len mod 3)

  for i in 0'u16..<groups:
    let
      c1: uint16 = getAlphanumericValue data[i*3]
      c2: uint16 = getAlphanumericValue data[i*3+1]
      c3: uint16 = getAlphanumericValue data[i*3+2]

    qr.encodedData.add(
      c1 * 100 + c2 * 10 + c3,
      (if c1 == 0:
         if c2 == 0: 0
         else: 3
       else: 6) + 4'u8
    )
  if charsLeft == 1:
    let c1: uint16 = getAlphanumericValue data[data.len-1]
    qr.encodedData.add c1, 4
  elif charsLeft == 2:
    let
      c1: uint16 = getAlphanumericValue data[data.len-2]
      c2: uint16 = getAlphanumericValue data[data.len-1]
    qr.encodedData.add c1 * 10 + c2, 7

proc encodeAlphanumericModeData(qr: var EncodedQRCode, data: string) =
  let
    groups:    uint16 = cast[uint16](data.len div 2)
    charsLeft: uint8  = cast[uint8](data.len mod 2)

  for i in 0'u16..<groups:
    let
      c1: uint8 = getAlphanumericValue data[i*2]
      c2: uint8 = getAlphanumericValue data[i*2+1]

    qr.encodedData.add c1 * 45'u16 + c2, 11
  if charsLeft == 1:
    qr.encodedData.add getAlphanumericValue(data[data.len-1]), 6

proc encodeByteModeData(qr: var EncodedQRCode, data: string) =
  for c in convert(data, "ISO 8859-1", "UTF-8"):
    qr.encodedData.add cast[uint8](c), 8

proc encodeData(qr: var EncodedQRCode, mode: QRMode, data: string) =
  case mode
  of qrNumericMode:      encodeNumericModeData qr, data
  of qrAlphanumericMode: encodeAlphanumericModeData qr, data
  of qrByteMode:         encodeByteModeData qr, data

proc finishEncoding(qr: var EncodedQRCode, eccLevel: QRErrorCorrectionLevel) =
  var missingBits: uint16 =
    (totalDataCodewords[eccLevel][qr.version] * 8) - qr.encodedData.pos

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

proc interleaveData*(qr: var EncodedQRCode, eccLevel: QRErrorCorrectionLevel) =
  let
    g1b: uint8 = group1Blocks[eccLevel][qr.version]
    g2b: uint8 = group2Blocks[eccLevel][qr.version]
    g1c: uint8 = group1BlockDataCodewords[eccLevel][qr.version]
    g2c: uint8 = group2BlockDataCodewords[eccLevel][qr.version]

  if g1b == 1 and g2b == 0:
    return

  # What a mess
  iterator codewordPositions: uint16 {.inline.} =
    for i in 0'u8..<max(g1c, g2c):
      if i < g1c:
        for j in 0'u8..<g1b:
          yield j * g1c + i

      if i < g2c:
        for j in 0'u8..<g2b:
          yield g1b * g1c + j * g2c + i

  var
    dataCopy: seq[uint8] = qr.encodedData.data
    i: int16 = 0

  for pos in codewordPositions():
    qr.encodedData.data[i] = dataCopy[pos]
    inc i

proc calcRemainderBits(qr: var EncodedQRCode) =
  qr.remainderBits = remainderBits[qr.version]

proc newEncodedQRCode*(version:  QRVersion,
                       eccLevel: QRErrorCorrectionLevel
                      ): EncodedQRCode =
  let
    dataSize: uint16 = totalDataCodewords[eccLevel][version]
    eccSize:  uint16 = (0'u16 +
                        group1Blocks[eccLevel][version] +
                        group2Blocks[eccLevel][version]) *
                       blockECCodewords[eccLevel][version]

  EncodedQRCode(version: version,
                encodedData: newBitArray(dataSize),
                eccCodewords: newBitArray(eccSize))

proc newEncodedQRCode*(qr: QRCode): EncodedQRCode =
  let
    dataSize: uint16 = totalDataCodewords[qr.eccLevel][qr.version]
    eccSize:  uint16 = (0'u16 +
                        group1Blocks[qr.eccLevel][qr.version] +
                        group2Blocks[qr.eccLevel][qr.version]) *
                       blockECCodewords[qr.eccLevel][qr.version]

  EncodedQRCode(version: qr.version,
                encodedData: newBitArray(dataSize),
                eccCodewords: newBitArray(eccSize))

proc encode*(qr: QRCode): EncodedQRCode =
  result = newEncodedQRCode(qr.version, qr.eccLevel)

  result.encodeModeIndicator qr.mode
  result.encodeCharCountIndicator qr.mode, qr.data
  result.encodeData qr.mode, qr.data
  result.finishEncoding qr.eccLevel
  # Calculate ECC codewords and add them
  result.interleaveData qr.eccLevel
  result.calcRemainderBits

proc encodeOnly*(qr: QRCode): EncodedQRCode =
  ## The same as `encode` but without interleaving.
  ## Meant for testing
  result = newEncodedQRCode(qr.version, qr.eccLevel)

  result.encodeModeIndicator qr.mode
  result.encodeCharCountIndicator qr.mode, qr.data
  result.encodeData qr.mode, qr.data
  result.finishEncoding qr.eccLevel
  # Calculate ECC codewords and add them
  result.calcRemainderBits
