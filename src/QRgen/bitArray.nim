type
  BitArray* = object
    pos*: uint32
    data*: seq[uint8]

proc newBitArray*(): BitArray =
  BitArray(pos: 0, data: @[])

proc add*[T: uint8 | uint16 | uint32 | uint64](b: var BitArray, val: T, len: uint8) =
  let tSize: uint8 = 8 * sizeof(T)
  if len > tSize:
    raise newException(
      RangeDefect,
      "len can't be bigger than " & $tSize & " in a " & $T
    )

  let
    arrPos:        uint32 = b.pos div 8
    bytePos:       uint8  = cast[uint8](b.pos mod 8)
    bitsLeft:      uint8  = 8 - bytePos
    bytes:         uint8  = if len <= bitsLeft: 0'u8
                            else: (len - bitsLeft) div 8
    remainingBits: uint8  = if len <= bitsLeft: 0'u8
                            else: (len - bitsLeft) mod 8

  if arrPos == cast[uint32](b.data.len): b.data.add 0'u8

  for _ in 1'u8..bytes: b.data.add 0'u8

  if remainingBits > 0:
    b.data.add cast[uint8](val shl (8 - remainingBits))

  var val = val shr remainingBits

  for i in 0'u8..<bytes:
    b.data[arrPos + bytes - i] = cast[uint8](val)
    val = val shr 8

  if len <= bitsLeft:
    b.data[arrPos] += cast[uint8](val shl (bitsLeft - len))
  else:
    b.data[arrPos] += cast[uint8](val)

  b.pos += len
