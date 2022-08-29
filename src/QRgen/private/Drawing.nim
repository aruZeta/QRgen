## # Drawing implementation
##
## This module implements a simple `Drawing` object which consists of a
## 2D matrix stored in a regular `seq[uint8]` and it's `size`.
##
## The main procedures consist of `[]` and `[]=`, the first one is used to
## check if the module at position `x,y` is dark (`true`) or light (`false`),
## while the latter sets the module at position `x,y` to dark or light.
##
## For ease of use there are some templates which help understand what the
## code is actually doing, they are `fillPoint`, `flipPoint` and
## `fillRectangle`.

type
  Drawing* = object
    ## A Drawing object used by `DrawedQRCode<DrawedQRCode.html>`_.
    ##
    ## .. note:: A `Drawing` is always a square, hence it's `size` is both
    ##    it's width and it's height.
    matrix: seq[uint8]
    size: uint8

  DrawingPrint* = enum
    ## Used by `print<#print%2CDrawing%2CDrawingPrint>`_ to draw the QR code
    ## in the specified format.
    dpTerminal

proc newDrawing*(size: uint8): Drawing =
  ## Creates a new `Drawing` object with the size `size`, `matrix` will have
  ## a cap and len set to the number of bytes required to store all it's
  ## modules.
  let matrixSize: uint16 = (cast[uint16](size) * size) div 8 + 1
  result = Drawing(matrix: newSeqOfCap[uint8](matrixSize), size: size)
  result.matrix.setLen(matrixSize)

proc `[]`*(self: Drawing, x, y: uint8): bool =
  ## Returns true if the module at position `x,y` is dark, else
  ## (if it was light) returns false.
  let bitPos: uint16 = cast[uint16](y) * self.size + x
  ((self.matrix[bitPos div 8] shr (7 - (bitPos mod 8))) and 0x01) == 0x01

proc `[]`*(self: Drawing, x: Slice[uint8], y: uint8): uint16 =
  ## Returns a `uint16` with the bits in the range `x` with y `y`.
  ##
  ## .. warning:: If the length of `x` is greater than 16, only the last
  ##    16 bits will be returned.
  let bitPosY: uint16 = cast[uint16](y) * self.size
  for b in (bitPosY + x.a)..(bitPosY + x.b):
    result = result shl 1 +
             ((self.matrix[b div 8] shr (7 - (b mod 8))) and 0x01)

proc `[]`*(self: Drawing, x: uint8, y: Slice[uint8]): uint16 =
  ## Returns a `uint16` with the bits in the range `y` with x `x`.
  ##
  ## .. warning:: If the length of `y` is greater than 16, only the last
  ##    16 bits will be returned.
  for y in y:
    let b: uint16 =  cast[uint16](self.size) * y + x
    result = result shl 1 +
             ((self.matrix[b div 8] shr (7 - (b mod 8))) and 0x01)

proc `[]=`*(self: var Drawing, x, y: uint8, val: bool) =
  ## Sets the module at position `x,y` to dark if `val` is true and to light
  ## if it's false.
  let bitPos: uint16 = cast[uint16](y) * self.size + x
  template arrPos: uint16 = bitPos div 8
  template bytePos: uint16 = bitPos mod 8
  self.matrix[arrPos] =
    if val:
      self.matrix[arrPos] or (0x01'u8 shl (7 - bytePos))
    else:
      self.matrix[arrPos] and (0xFF'u8 xor (0x01'u8 shl (7 - bytePos)))

template fillPoint*(self: var Drawing, x, y: uint8) =
  ## A helper template to set the module at position `x,y` to dark.
  self[x, y] = true

template flipPoint*(self: var Drawing, x, y: uint8) =
  ## A helper template to flip the state of the module at position `x,y`.
  ## If it is ligth set it to dark, if it is dark set it to light.
  self[x, y] = not self[x, y]

proc fillRectangle*(self: var Drawing, xRange, yRange: Slice[uint8]) =
  ## A helper template to set all the modules where
  ## `x` is in `xRange` and y is `yRange` to dark.
  for y in yRange:
    for x in xRange:
      self.fillPoint x, y

template fillRectangle*(self: var Drawing, xRange: Slice[uint8], y: uint8) =
  ## A helper template to set all the modules where
  ## `x` is in `xRange` and y is `y` to dark.
  self.fillRectangle xRange, y..y

template fillRectangle*(self: var Drawing, x: uint8, yRange: Slice[uint8]) =
  ## A helper template to set all the modules where
  ## `y` is in `yRange` and x is `x` to dark.
  self.fillRectangle x..x, yRange

template fillRectangle*(self: var Drawing, xyRange: Slice[uint8]) =
  ## A helper template to set all the modules where
  ## both x and y are in `xyRange` to dark.
  self.fillRectangle xyRange, xyRange

template printTerminal(self: Drawing) =
  ## Print a `DrawedQRCode` in your terminal.
  stdout.write "\n\n\n\n\n"
  for y in 0'u8..<self.size:
    stdout.write "          "
    for x in 0'u8..<self.size:
      stdout.write(
        if self[x, y]: "██"
        else:          "  "
      )
    stdout.write "\n"
  stdout.write "\n\n\n\n\n"

proc print*(self: Drawing, output: DrawingPrint) =
  ## Print a `DrawedQRCode` with the format specified by `output`.
  case output
  of dpTerminal: printTerminal self

# Getters/setters section

proc `[]`*(self: Drawing, i: SomeInteger): uint8 =
  self.matrix[i]

proc size*(self: Drawing): uint8 =
  self.size

proc len*(self: Drawing): int =
  self.matrix.len

# - Used only in tests:

proc matrix*(self: Drawing): seq[uint8] =
  self.matrix

proc `matrix=`*(self: var Drawing, val: seq[uint8]) =
  self.matrix = val
