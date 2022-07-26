type
  BitArray* = object
    pos*: uint32
    data*: seq[uint8]

proc newBitArray*(): BitArray =
  BitArray(pos: 0, data: @[])

proc add*[T: uint8](b: var BitArray, val: T, len: uint8) =
  let tSize: uint8 = 8 * sizeof(T)
  if len > tSize:
    raise newException(
      RangeDefect,
      "len can't be bigger than " & $tSize & " in a " & $T
    )

  let
    arrPos: uint32 = b.pos div 8
    bytePos: uint8 = cast[uint8](b.pos mod 8)
    bitsLeft: uint8 = 8 - bytePos

  if bitsLeft < len:
    b.data.add(val shl bitsLeft)
    b.data[arrPos] += val shr bytePos
  else:
    if arrPos == cast[uint32](b.data.len): b.data.add 0'u8
    b.data[arrPos] += val shl (bitsLeft - len)

  b.pos += len
