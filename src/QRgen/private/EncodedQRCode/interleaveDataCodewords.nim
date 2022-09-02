import ./EncodedQRCode,
       ./utils
import ../BitArray,
       ../qrCapacities

iterator g1BlockPositions(self: EncodedQRCode): uint16 {.inline.} =
  var pos: uint16 = 0
  var b: uint8 = 0
  while b < group1Blocks[self]:
    yield pos
    pos += group1BlockDataCodewords[self]
    b.inc

iterator g2BlockPositions(self: EncodedQRCode): uint16 {.inline.} =
  var pos: uint16 =
    cast[uint16](group1Blocks[self]) * group1BlockDataCodewords[self]
  var b: uint8 = 0
  while b < group2Blocks[self]:
    yield pos
    pos += group2BlockDataCodewords[self]
    b.inc

proc interleaveDataCodewords*(self: var EncodedQRCode) =
  if group1Blocks[self] == 1 and group2Blocks[self] == 0:
    return
  var
    dataCopy: seq[uint8] = self.data[0..self.calcEcStart-1]
    n: uint16 = 0
  template setData(pos: uint16) =
    self.data[n] = dataCopy[pos]
    n.inc
  for i in 0'u8..<group1BlockDataCodewords[self]:
    for j in self.g1BlockPositions: setData j+i
    for j in self.g2BlockPositions: setData j+i
  if group2Blocks[self] > 0:
    for j in self.g2BlockPositions: setData j+group2BlockDataCodewords[self]-1
