import
  "."/[EncodedQRCode, utils],
  ".."/[BitArray, qrCapacities, qrCharacters, qrTypes],
  std/[encodings]

template getVal16(c: char): uint16 = cast[uint16](getAlphanumericValue c)
template getVal8(c: char): uint8 = getAlphanumericValue c

template encodeNumericModeData(self: var EncodedQRCode, data: string) =
  for i in step(0, data.len, 3):
    self.data.add(
      getVal16(data[i]) * 100 + getVal16(data[i+1]) * 10 + getVal8(data[i+2]),
      (if data[i] == '0':
         if data[i+1] == '0': 4'u8
         else: 7'u8
       else: 10'u8)
    )
  case (data.len mod 3)
  of 1: self.data.add getVal8(data[^1]), 4
  of 2: self.data.add getVal16(data[^2]) * 10 + getVal8(data[^1]), 7
  else: discard

template encodeAlphanumericModeData(self: var EncodedQRCode, data: string) =
  for i in step(0, data.len, 2):
    self.data.add getVal16(data[i]) * 45 + getVal8(data[i+1]), 11
  if (data.len mod 2) == 1:
    self.data.add getVal8(data[^1]), 6

template encodeByteModeData(self: var EncodedQRCode, data: string) =
  for c in convert(data, "ISO 8859-1", "UTF-8"):
    self.data.add cast[uint8](c), 8

proc encodeDataCodewords*(self: var EncodedQRCode, data: string) =
  case self.mode
  of qrNumericMode:      encodeNumericModeData self, data
  of qrAlphanumericMode: encodeAlphanumericModeData self, data
  of qrByteMode:         encodeByteModeData self, data

proc finishDataEncoding*(self: var EncodedQRCode) =
  var missingBits: uint16 =
    (totalDataCodewords[self] * 8) - self.data.pos
  let terminatorBits: uint8 =
    if missingBits > 4: 4'u8
    else: cast[uint8](missingBits)
  self.data.add 0b0000'u8, terminatorBits
  missingBits -= terminatorBits + self.data.nextByte
  let missingBytes: uint16 = missingBits div 8
  for _ in 1'u16..(missingBytes div 2):
    self.data.add 0b11101100'u8, 8
    self.data.add 0b00010001'u8, 8
  if (missingBytes mod 2) == 1:
    self.data.add 0b11101100'u8, 8
