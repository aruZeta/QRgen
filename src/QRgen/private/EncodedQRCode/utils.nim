## This module contains some utilities used in this directory's modules.

import
  "."/[type],
  ".."/[qrCapacities]

template `[]`*[T](self: QRCapacity[T], qr: EncodedQRCode): T =
  ## A helper template to get the value stored in `self` from the `ecLevel` and
  ## `version` of `qr`.
  self[qr.ecLevel][qr.version]

template `^=`*(self: untyped, expr: untyped) =
  ## A helper template operator like the one found in C, where `self` is xored
  ## with `expr` and assigned to `self`.
  self = self xor expr

iterator step*(start, stop, step: int): int =
  ## A simple iterator to iterate starting from `start`, increising by `step`
  ## until `stop` is reached.
  var x = start
  while x <= stop - step:
    yield x
    x.inc step

proc calcEcStart*(self: EncodedQRCode): uint16 =
  ## Returns the position of the first block of ECC in `self`. 
  group1Blocks[self].uint16 * group1BlockDataCodewords[self] +
  group2Blocks[self].uint16 * group2BlockDataCodewords[self]
