type
  BitArray* = object
    pos*: uint16
    data*: seq[uint8]

proc newBitArray*(size: uint16): BitArray =
  result = BitArray(pos: 0, data: newSeqOfCap[uint8](size))
  result.data.setLen(size)

proc nextByte*(b: var BitArray, evenIfBlank: bool = false): uint8 =
  let bytePos: uint8 = cast[uint8](b.pos mod 8)
  result = (if bytePos > 0: 8 - bytePos
            elif evenIfBlank: 8'u8
            else: 0'u8)
  b.pos += result

proc add*[T: uint8 | uint16 | uint32 | uint64
         ](b: var BitArray, val: T, len: uint8) =
  template tSize: int = 8 * sizeof(T)

  if len > tSize:
    raise newException(
      RangeDefect,
      "len can't be bigger than " & $tSize & " in a " & $T
    )
  elif len == 0:
    return

  template castU8(expr: untyped): uint8 =
    ## If T is not u8, cast val to u8 when putting it in the BitArray
    when T isnot uint8: cast[uint8](expr)
    else:               expr

  let
    arrPos:   uint16 = b.pos div 8
    bitsLeft: uint8  = 8 - cast[uint8](b.pos mod 8)

  if len <= bitsLeft:
    b.data[arrPos] += castU8(
      (val and (0xFF'u8 shr (8 - len))) shl (bitsLeft - len)
    )
  else:
    let
      bytes:   uint8  = (len - bitsLeft) div 8
      remBits: uint8  = (len - bitsLeft) mod 8

    if remBits > 0:
      b.data[arrPos + bytes + 1] = castU8(val shl (8 - remBits))

    var val = val shr remBits

    for i in 0'u8..<bytes:
      b.data[arrPos + bytes - i] = castU8(val)
      val = val shr 8

    b.data[arrPos] += castU8(val and (0xFF'u8 shr (8 - bitsLeft)))

  b.pos += len
