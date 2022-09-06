import
  "."/[type, utils],
  ".."/[BitArray, qrCapacities]

proc calcEcBlockPositions(self: EncodedQRCode): seq[uint16] =
  ## Returns a `seq` with all the first positions of ECC blocks in `self`.
  result = newSeqOfCap[uint16](group1Blocks[self] + group2Blocks[self])
  result.setLen(group1Blocks[self] + group2Blocks[self])
  for i in 0'u8..<group1Blocks[self]+group2Blocks[self]:
    result[i] = cast[uint16](blockECCodewords[self]) * i

proc interleaveECCodewords*(self: var EncodedQRCode) =
  ## Interleaves the ECC codewords of `self`.
  ##
  ## .. code::
  ##    # Block 1  | Block 2
  ##    # 12 21 23 | 09 78 65
  ##    # After interleave:
  ##    # 12 09 21 78 23 65
  ##
  ## As you can see the order is, 1st ECC from B1, then 1st from B2, 2nd from
  ## B1, 2nd from B2, etc.
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
