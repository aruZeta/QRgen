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

proc add*[T: uint16 | uint32 | uint64](b: var BitArray, val: T, len: uint8) =
  let tSize: uint8 = 8 * sizeof(T)
  if len > tSize:
    raise newException(
      RangeDefect,
      "len can't be bigger than " & $tSize & " in a " & $T
    )

  template checkLen(size: uint8, uintType: typedesc) =
    if tSize > size and len <= size:
      b.add cast[uintType](val), len
      return

  checkLen 8, uint8
  checkLen 16, uint16
  checkLen 32, uint32

  let
    arrPos:        uint32 = b.pos div 8
    bytePos:       uint8  = cast[uint8](b.pos mod 8)
    bitsLeft:      uint8  = 8 - bytePos
    bytes:         uint8  = (len - bitsLeft) div 8
    remainingBits: uint8  = (len - bitsLeft) mod 8

  if arrPos == cast[uint32](b.data.len): b.data.add 0'u8

  for _ in 1'u8..bytes: b.data.add 0'u8

  if remainingBits > 0:
    b.data.add cast[uint8](val shl (8 - remainingBits))

  var val = val shr remainingBits

  for i in 0'u8..<bytes:
    b.data[arrPos + bytes - i] = cast[uint8](val)
    val = val shr 8

  b.data[arrPos] += cast[uint8](val)
  b.pos += len
