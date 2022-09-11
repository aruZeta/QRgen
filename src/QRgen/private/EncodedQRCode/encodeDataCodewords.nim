import
  "."/[type, utils],
  ".."/[BitArray, qrCapacities, qrCharacters, qrTypes]

template getVal8(c: char): uint8 =
  ## Helper template to get the alphanumeric value of `c` as a uint8.
  getAlphanumericValue c

template getVal16(c: char): uint16 =
  ## Helper template to get the alphanumeric value of `c` as a uint16.
  (getVal8 c).uint16

template encodeNumericModeData(self: var EncodedQRCode, data: string) =
  ## Encodes `data` via the numeric mode encoding algorithm.
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
  ## Encodes `data` via the alphanumeric mode encoding algorithm.
  for i in step(0, data.len, 2):
    self.data.add getVal16(data[i]) * 45 + getVal8(data[i+1]), 11
  if (data.len mod 2) == 1:
    self.data.add getVal8(data[^1]), 6

template encodeByteModeData(self: var EncodedQRCode, data: string) =
  ## Encodes `data` via the byte mode encoding algorithm.
  for c in data:
    self.data.add cast[uint8](c), 8

func encodeDataCodewords*(self: var EncodedQRCode, data: string) =
  ## Depending on `self.mode`, the data will be encoded using 
  ## `numeric mode<#encodeNumericModeData.t%2CEncodedQRCode%2Cstring>`_ or
  ## `alphanumeric mode<#encodeAlphanumericModeData.t%2CEncodedQRCode%2Cstring>`_
  ## or `byte mode<#encodeByteModeData.t%2CEncodedQRCode%2Cstring>`_ encoding
  ## algorithms.
  case self.mode
  of qrNumericMode:      encodeNumericModeData self, data
  of qrAlphanumericMode: encodeAlphanumericModeData self, data
  of qrByteMode:         encodeByteModeData self, data

proc finishDataEncoding*(self: var EncodedQRCode) =
  ## Adds the terminator bits and missing bits, and if there are more bytes
  ## unfilled, fills them with `0b11101100` and `0b00010001`.
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
