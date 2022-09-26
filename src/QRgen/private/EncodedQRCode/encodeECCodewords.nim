import
  "."/[type, utils],
  ".."/[BitArray, qrCapacities]

func gf256Mod285Multiply(x, y: uint8): uint8 =
  ## Returns the multiplication of `x` and `y` using Galois Field 256 and
  ## modulo 285.
  result = 0
  for i in 0'u8..7'u8:
    result = cast[uint8]((result shl 1) xor ((result shr 7) * 0x11D))
    result ^= ((y shr (7 - i)) and 0x01) * x

proc calcGeneratorPolynomial(self: EncodedQRCode): seq[uint8] =
  ## Calculates the generator polynomial used to generate the ECC.
  let degree: uint8 = blockECCodewords[self]
  result = newSeqOfCap[uint8](degree)
  result.setLen(degree)
  result[^1] = 1
  var root: uint8 = 1
  template mult(pos: uint8 | BackwardsIndex) =
    result[pos] = gf256Mod285Multiply(result[pos], root)
  for _ in 0'u8..<degree:
    for i in 0'u8..<degree-1:
      mult(i)
      result[i] ^= result[i+1]
    mult(^1)
    root = gf256Mod285Multiply(root, 0x02)

proc calcBlockPositions(self: EncodedQRCode): seq[uint16] =
  ## Returns the positions of all data blocks and the last item is where
  ## the ECC blocks start.
  result = newSeqOfCap[uint16](group1Blocks[self] + group2Blocks[self] + 1)
  result.setLen(group1Blocks[self] + group2Blocks[self] + 1)
  result[0] = 0
  for i in 1'u8..group1Blocks[self]+group2Blocks[self]:
    result[i] = result[i-1] + (
      if i <= group1Blocks[self]: group1BlockDataCodewords[self]
      else: group2BlockDataCodewords[self]
    )

proc encodeECCodewords*(self: var EncodedQRCode) =
  ## Encodes the ECC codewords by calculating them using the generator
  ## polynomial and the data codewords.
  let
    positions: seq[uint16] = self.calcBlockPositions
    generator: seq[uint8] = self.calcGeneratorPolynomial
    degree: uint8 = cast[uint8](generator.len)
  for i in 0'u8..<cast[uint8](positions.len)-1:
    for j in positions[i]..<positions[i+1]:
      let actualEcPos: uint16 =
        positions[^1] + (blockECCodewords[self].uint16 * i)
      let factor = self.data[j] xor self.data[actualEcPos]
      when not defined(js):
        moveMem(
         self.data[actualECPos].addr,
         self.data[actualEcPos+1].addr,
         cast[uint16](self.data.len) - actualEcPos - 1'u8
        )
        self.data.unsafeSet ^1, 0'u8
      else:
        self.data.unsafeDelete actualEcPos
        self.data.unsafeAdd 0
      for k in 0'u8..<degree:
        self.data[actualEcPos+k] ^= (gf256Mod285Multiply(generator[k], factor))
