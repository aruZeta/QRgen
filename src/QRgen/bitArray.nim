type
  BitArray* = object
    pos*: uint32
    data*: seq[uint8]

proc newBitArray*(): BitArray =
  BitArray(pos: 0, data: @[])
