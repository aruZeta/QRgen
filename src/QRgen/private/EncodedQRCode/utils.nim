import
  "."/[type],
  ".."/[qrCapacities]

template `[]`*[T](self: QRCapacity[T], qr: EncodedQRCode): T =
  self[qr.ecLevel][qr.version]

template `^=`*(self: untyped, expr: untyped) =
  self = self xor expr

iterator step*(start, stop, step: int): int =
  var x = start
  while x <= stop - step:
    yield x
    x.inc step

proc calcEcStart*(self: EncodedQRCode): uint16 =
  (cast[uint16](group1Blocks[self]) * group1BlockDataCodewords[self]) +
  (cast[uint16](group2Blocks[self]) * group2BlockDataCodewords[self])
