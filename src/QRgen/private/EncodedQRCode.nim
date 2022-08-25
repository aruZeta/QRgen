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
  # Calculate ECC codewords and add them
  result.interleaveData

proc encodeOnly*(qr: QRCode): EncodedQRCode =
  ## The same as `encode` but without interleaving.
  ## Meant for testing
  result = newEncodedQRCode qr
  result.encodeModeIndicator
  result.encodeCharCountIndicator qr.data
  result.encodeData qr.data
  result.finishEncoding
  # Calculate ECC codewords and add them
