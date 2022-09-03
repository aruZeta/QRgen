import
  "."/[type, utils],
  ".."/[BitArray, qrCapacities]

proc calcEcBlockPositions(self: EncodedQRCode): seq[uint16] =
  result = newSeqOfCap[uint16](group1Blocks[self] + group2Blocks[self])
  result.setLen(group1Blocks[self] + group2Blocks[self])
  for i in 0'u8..<group1Blocks[self]+group2Blocks[self]:
    result[i] = cast[uint16](blockECCodewords[self]) * i

proc interleaveECCodewords*(self: var EncodedQRCode) =
  let
    firstEcBlockPos: uint16 = self.calcEcStart
    positions: seq[uint16] = self.calcEcBlockPositions
  var
    dataCopy: seq[uint8] = self.data[firstEcBlockPos..^1]
    n: uint16 = firstEcBlockPos
  for i in 0'u8..<blockECCodewords[self]:
    for j in positions:
      self.data[n] = dataCopy[j+i]
      n.inc
