import
  "."/[type, utils],
  ".."/[BitArray, qrCapacities]

iterator g1BlockPositions(self: EncodedQRCode): uint16 {.inline.} =
  ## Iterates over every starting position of the blocks in group 1.
  var pos: uint16 = 0
  var b: uint8 = 0
  while b < group1Blocks[self]:
    yield pos
    pos += group1BlockDataCodewords[self]
    b.inc

iterator g2BlockPositions(self: EncodedQRCode): uint16 {.inline.} =
  ## Iterates over every starting position of the blocks in group 2.
  var pos: uint16 =
    cast[uint16](group1Blocks[self]) * group1BlockDataCodewords[self]
  var b: uint8 = 0
  while b < group2Blocks[self]:
    yield pos
    pos += group2BlockDataCodewords[self]
    b.inc

proc interleaveDataCodewords*(self: var EncodedQRCode) =
  ## Interleaves the data codewords of `self`.
  ##
  ## .. code::
  ##    # Block 1  | Block 2
  ##    # 12 21 23 | 09 78 65
  ##    # After interleave:
  ##    # 12 09 21 78 23 65
  ##
  ## As you can see the order is, 1st data codeword from B1, then 1st from B2,
  ## 2nd from B1, 2nd from B2, etc.
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
