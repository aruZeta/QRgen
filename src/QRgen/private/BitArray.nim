type
  BitArray* = object
    pos*: uint16
    data*: seq[uint8]

proc newBitArray*(size: uint16): BitArray =
  result = BitArray(pos: 0, data: newSeqOfCap[uint8](size))
  result.data.setLen(size)

template `[]`*(self: BitArray, i: SomeInteger): uint8 =
  self.data[i]

template `[]`*(self: BitArray, i: Slice[SomeInteger]): seq[uint8] =
  self.data[i]

template `[]=`*(self: BitArray, i: SomeInteger, val: uint8) =
  self.data[i] = val

proc nextByte*(self: var BitArray): uint8 =
  let bytePos: uint8 = cast[uint8](self.pos mod 8)
  result =
    if bytePos > 0: 8 - bytePos
    else: 0'u8
  self.pos += result

proc add*(self: var BitArray, val: SomeUnsignedInt, len: uint8) =
  if len == 0: return
  template castU8(expr: untyped): uint8 =
    when val isnot uint8: cast[uint8](expr)
    else: expr
  let
    arrPos: uint16 = self.pos div 8
    bitsLeft: uint8 = 8 - cast[uint8](self.pos mod 8)
  if len <= bitsLeft:
    self[arrPos] += castU8(
      (val and (0xFF'u8 shr (8 - len))) shl (bitsLeft - len)
    )
  else:
    let
      bytes: uint8 = (len - bitsLeft) div 8
      remBits: uint8 = (len - bitsLeft) mod 8
    if remBits > 0:
      self[arrPos + bytes + 1] = castU8(val shl (8 - remBits))
    var val = val shr remBits
    for i in 0'u8..<bytes:
      self[arrPos + bytes - i] = castU8(val)
      val = val shr 8
    self[arrPos] += castU8(val and (0xFF'u8 shr (8 - bitsLeft)))
  self.pos += len
