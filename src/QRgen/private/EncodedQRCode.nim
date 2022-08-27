import QRCode, BitArray, qrTypes, qrCapacities, qrCharacters
import std/encodings

type
  EncodedQRCode* = object
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QREcLevel
    encodedData*: BitArray

template `[]`*[T](self: QRCapacity[T], qr: EncodedQRCode): T =
  self[qr.ecLevel][qr.version]

template `[]`*(self: EncodedQRCode, i: SomeInteger): uint8 =
  self.encodedData[i]

template `[]=`*(self: EncodedQRCode, i: SomeInteger, val: uint8) =
  self.encodedData[i] = val

proc encodeModeIndicator*(self: var EncodedQRCode) =
  self.encodedData.add cast[uint8](self.mode), 4

proc encodeCharCountIndicator*(self: var EncodedQRCode, data: string) =
  template modeCases(numericVal, alphanumericVal, byteVal: uint8): uint8 =
    case self.mode
    of qrNumericMode: numericVal
    of qrAlphanumericMode: alphanumericVal
    of qrByteMode: byteVal
  self.encodedData.add(cast[uint16](data.len), (
      if self.version <= 9:    modeCases 10, 9, 8
      elif self.version >= 27: modeCases 14, 13, 16
      else:                    modeCases 12, 11, 16
  ))

iterator step(start, stop, step: int): int =
  var x = start
  while x <= stop - step:
    yield x
    x.inc step

template getVal(c: char): uint16 = cast[uint16](getAlphanumericValue c)
template getVal8(c: char): uint8 = getAlphanumericValue c

template encodeNumericModeData(self: var EncodedQRCode, data: string) =
  for i in step(0, data.len, 3):
    self.encodedData.add(
      getVal(data[i]) * 100 + getVal(data[i+1]) * 10 + getVal(data[i+2]),
      (if data[i] == '0':
         if data[i+1] == '0': 4'u8
         else: 7'u8
       else: 10'u8)
    )
  case (data.len mod 3)
  of 1: self.encodedData.add getVal8(data[^1]), 4
  of 2: self.encodedData.add getVal8(data[^2]) * 10 + getVal8(data[^1]), 7
  else: discard

template encodeAlphanumericModeData(self: var EncodedQRCode, data: string) =
  for i in step(0, data.len, 2):
    self.encodedData.add getVal(data[i]) * 45'u16 + getVal(data[i+1]), 11
  if (data.len mod 2) == 1:
    self.encodedData.add getVal8(data[^1]), 6

template encodeByteModeData(self: var EncodedQRCode, data: string) =
  for c in convert(data, "ISO 8859-1", "UTF-8"):
    self.encodedData.add cast[uint8](c), 8

proc encodeData*(self: var EncodedQRCode, data: string) =
  case self.mode
  of qrNumericMode:      encodeNumericModeData self, data
  of qrAlphanumericMode: encodeAlphanumericModeData self, data
  of qrByteMode:         encodeByteModeData self, data

proc finishEncoding*(self: var EncodedQRCode) =
  var missingBits: uint16 =
    (totalDataCodewords[self] * 8) - self.encodedData.pos
  let terminatorBits: uint8 =
    if missingBits > 4: 4'u8
    else: cast[uint8](missingBits)
  self.encodedData.add 0b0000'u8, terminatorBits
  missingBits -= terminatorBits + self.encodedData.nextByte
  let missingBytes: uint16 = missingBits div 8
  for _ in 1'u16..(missingBytes div 2):
    self.encodedData.add 0b11101100'u8, 8
    self.encodedData.add 0b00010001'u8, 8
  if (missingBytes mod 2) == 1:
    self.encodedData.add 0b11101100'u8, 8

proc gf256Mod285Multiply(x, y: uint8): uint8 =
  result = 0
  for i in 0'u8..7'u8:
    result = cast[uint8]((result shl 1) xor ((result shr 7) * 0x11D))
    result = result xor (((y shr (7 - i)) and 0x01) * x)

proc calcGeneratorPolynomial(self: EncodedQRCode): seq[uint8] =
  let degree: uint8 = blockECCodewords[self.ecLevel][self.version]
  result = newSeqOfCap[uint8](degree)
  result.setLen(degree)
  result[^1] = 1
  var root: uint8 = 1
  template mult(pos: uint8 | BackwardsIndex) =
    result[pos] = gf256Mod285Multiply(result[pos], root)
  for _ in 0'u8..<degree:
    for i in 0'u8..<degree-1:
      mult(i)
      result[i] = result[i] xor result[i+1]
    mult(^1)
    root = gf256Mod285Multiply(root, 0x02)

proc calcBlockPositions*(self: EncodedQRCode): seq[uint16] =
  result = newSeqOfCap[uint16](group1Blocks[self] + group2Blocks[self] + 1)
  result.setLen(group1Blocks[self] + group2Blocks[self] + 1)
  result[0] = 0
  for i in 1'u8..group1Blocks[self]+group2Blocks[self]:
    result[i] = result[i-1] + (
      if i <= group1Blocks[self]: group1BlockDataCodewords[self]
      else: group2BlockDataCodewords[self]
    )

proc encodeEcCodewords*(self: var EncodedQRCode) =
  let
    positions: seq[uint16] = self.calcBlockPositions
    generator: seq[uint8] = self.calcGeneratorPolynomial
    degree: uint8 = cast[uint8](generator.len)
  for i in 0'u8..<cast[uint8](positions.len)-1:
    for j in positions[i]..<positions[i+1]:
      let actualEcPos: uint16 = positions[^1]+blockECCodewords[self]*i
      let factor = self[j] xor self[actualEcPos]
      self.encodedData.data.delete actualEcPos
      self.encodedData.data.add 0
      for k in 0'u8..<degree:
        self[actualEcPos+k] =
          self[actualEcPos+k] xor (gf256Mod285Multiply(generator[k], factor))

proc interleaveData*(self: var EncodedQRCode) =
  if group1Blocks[self] == 1 and group2Blocks[self] == 0:
    return
  let
    g1b: uint16 = cast[uint16](group1Blocks[self])
    g2b: uint16 = cast[uint16](group2Blocks[self])
    g1c: uint16 = cast[uint16](group1BlockDataCodewords[self])
    g2c: uint16 = cast[uint16](group2BlockDataCodewords[self])
  iterator codewordPositions: uint16 {.inline.} =
    let g2bStart = g1b * g1c
    for i in 0'u16..<max(g1c, g2c):
      if i < g1c:
        for j in 0'u16..<g1b:
          yield j * g1c + i
      if i < g2c:
        for j in 0'u16..<g2b:
          yield g2bStart + j * g2c + i
  var
    dataCopy: seq[uint8] = self.encodedData.data
    i: int16 = 0
  for pos in codewordPositions():
    self.encodedData[i] = dataCopy[pos]
    i.inc

proc calcEcBlockPositions*(self: EncodedQRCode): seq[uint16] =
  result = newSeqOfCap[uint16](group1Blocks[self] + group2Blocks[self])
  result.setLen(group1Blocks[self] + group2Blocks[self])
  for i in 0'u8..<group1Blocks[self]+group2Blocks[self]:
    result[i] = cast[uint16](blockECCodewords[self]) * i

proc interleaveEcCodewords(self: var EncodedQRCode) =
  let
    firstEcBlockPos: uint16 =
      (cast[uint16](group1Blocks[self]) * group1BlockDataCodewords[self]) +
      (cast[uint16](group2Blocks[self]) * group2BlockDataCodewords[self])
    positions: seq[uint16] = self.calcEcBlockPositions
  var
    dataCopy: seq[uint8] = self.encodedData.data[firstEcBlockPos..^1]
    n: uint16 = firstEcBlockPos
  for i in 0'u8..<blockECCodewords[self]:
    for j in positions:
      self[n] = dataCopy[j+i]
      n.inc

proc newEncodedQRCode*(version: QRVersion,
                       ecLevel: QREcLevel = qrEcL,
                       mode: QRMode = qrByteMode
                      ): EncodedQRCode =
  template dataSize: uint16 = totalDataCodewords[ecLevel][version]
  template eccSize: uint16 =
    cast[uint16](
      group1Blocks[ecLevel][version] +
      group2Blocks[ecLevel][version]
    ) * blockECCodewords[ecLevel][version]
  EncodedQRCode(mode: mode,
                version: version,
                ecLevel: ecLevel,
                encodedData: newBitArray(dataSize + eccSize))

proc newEncodedQRCode*(qr: QRCode): EncodedQRCode =
  template dataSize: uint16 = totalDataCodewords[qr.ecLevel][qr.version]
  template eccSize: uint16 =
    cast[uint16](group1Blocks[qr] + group2Blocks[qr]) * blockECCodewords[qr]
  EncodedQRCode(mode: qr.mode,
                version: qr.version,
                ecLevel: qr.ecLevel,
                encodedData: newBitArray(dataSize + eccSize))

proc encode*(qr: QRCode): EncodedQRCode =
  result = newEncodedQRCode qr
  result.encodeModeIndicator
  result.encodeCharCountIndicator qr.data
  result.encodeData qr.data
  result.finishEncoding
  result.encodeEcCodewords
  result.interleaveData
  result.interleaveEcCodewords

proc encodeOnly*(qr: QRCode): EncodedQRCode =
  ## The same as `encode` but without interleaving.
  ## Meant for testing
  result = newEncodedQRCode qr
  result.encodeModeIndicator
  result.encodeCharCountIndicator qr.data
  result.encodeData qr.data
  result.finishEncoding
  result.encodeEcCodewords
