## # Bit array implementation
##
## This module implements a simple `BitArray` object which consists of a
## regular `seq[uint8]` and a `pos`.
##
## There are 2 main procedures, one to add more bits to the BitArray,
## `add<#add%2CBitArray%2CSomeUnsignedInt%2Cuint8>`_,
## and another to skip to the next byte,
## `nextByte<#nextByte%2CBitArray>`_.
##
## For ease of use there are some templates to help write less code, like
## `[]<#[].t%2CBitArray%2CSomeInteger>`_,
## so instead of writing `myBitArray.data[i]` you would write `myBitArray[i]`,
## as if `BitArray` was a regular `seq[uint8]`.

type
  BitArray* = object
    ## A BitArray object used by `EncodedQRCode<EncodedQRCode.html>`_.
    ##
    ## `pos` is used to keep track of where new bits will be placed.
    pos*: uint16
    data*: seq[uint8]

func newBitArray*(size: uint16): BitArray =
  ## Creates a new `BitArray` object whose `data` will have a cap of `size`
  ## and it's len will also be set to `size`.
  result = BitArray(pos: 0, data: newSeqOfCap[uint8](size))
  result.data.setLen(size)

template `[]`*(self: BitArray, i: SomeInteger): uint8 =
  ## Get the value of `data` in index `i`.
  self.data[i]

template `[]`*[T,S](self: BitArray, i: HSlice[T,S]): seq[uint8] =
  ## Get the values of `data` in the slice `i`.
  self.data[i]

template `[]=`*(self: var BitArray, i: SomeInteger, val: uint8) =
  ## Set the value of `data` in index `i` to `val`.
  self.data[i] = val

func nextByte*(self: var BitArray): uint8 =
  ## Moves `pos` to the next byte, unless it is pointing to the start of an
  ## empty byte.
  ##
  ## **Example**:
  ##
  ## .. code::
  ##    myBitArray.data:
  ##    0101_0110, 1010_0000, 0000_0000
  ##                    ^ pos points here
  ##
  ##    after using nextByte():
  ##
  ##    myBitArray.data:
  ##    0101_0110, 1010_0000, 0000_0000
  ##                          ^ pos points here
  let bytePos: uint8 = cast[uint8](self.pos mod 8)
  result =
    if bytePos > 0: 8 - bytePos
    else: 0'u8
  self.pos += result

func add*(self: var BitArray, val: SomeUnsignedInt, len: uint8) =
  ## Add `len` amount of bits from `val` starting from the rightmost bit.
  runnableExamples:
    var myBitArray = newBitArray(1)
    myBitArray.add 0b110011'u8, 4 # should add 0011, not 110011
    assert myBitArray[0] == 0b0011_0000
    #                              ^ pos will be here
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

template unsafeAdd*(self: var BitArray, val: uint8) =
  ## Add `val` to the end of `data`.
  ##
  ## .. warning:: This is unsafe since, by default, `data`'s len
  ##    is set to it's max capacity and `pos` is not updated.
  self.data.add val

template unsafeDelete*(self: var BitArray, pos: uint16) =
  ## Remove the value from `data` in position `pos`.
  ##
  ## .. warning:: This is unsafe since `pos` is not updated.
  self.data.delete pos

template unsafeSet*(
  self: var BitArray,
  pos: uint16 | BackwardsIndex,
  val: uint8
) =
  ## Sets the value from `data` in position `pos` to `val`.
  ##
  ## .. warning:: This is unsafe since you may be setting the value of bits
  ##    not yet reached by `pos`, which would then be overwritten.
  self.data[pos] = val

template len*(self: BitArray): int =
  ## Get the len of `self.data`.
  ## Used nstead of writing `data.data.len` in other modules.
  self.data.len
