type
  Drawing* = object
    matrix*: seq[uint8]
    size*: uint8

  DrawingPrint* = enum
    dpTerminal

proc newDrawing*(size: uint8): Drawing =
  let matrixSize: uint16 = (cast[uint16](size) * size) div 8 + 1
  result = Drawing(matrix: newSeqOfCap[uint8](matrixSize), size: size)
  result.matrix.setLen(matrixSize)

proc `[]`*(self: Drawing, x, y: uint8): bool =
  let bitPos: uint16 = cast[uint16](y) * self.size + x
  ((self.matrix[bitPos div 8] shr (7 - (bitPos mod 8))) and 0x01) == 0x01

proc `[]`*(self: Drawing, x: Slice[uint8], y: uint8): uint16 =
  let bitPosY: uint16 = cast[uint16](y) * self.size
  for b in (bitPosY + x.a)..(bitPosY + x.b):
    result = result shl 1 +
             ((self.matrix[b div 8] shr (7 - (b mod 8))) and 0x01)

proc `[]`*(self: Drawing, x: uint8, y: Slice[uint8]): uint16 =
  let size: uint16 = cast[uint16](self.size)
  for y in y:
    let b: uint16 = size * y + x
    result = result shl 1 +
             ((self.matrix[b div 8] shr (7 - (b mod 8))) and 0x01)

proc `[]=`*(self: var Drawing, x, y: uint8, val: bool) =
  let bitPos: uint16 = cast[uint16](y) * self.size + x
  template arrPos: uint16 = bitPos div 8
  template bytePos: uint16 = bitPos mod 8
  self.matrix[arrPos] =
    if val:
      self.matrix[arrPos] or (0x01'u8 shl (7 - bytePos))
    else:
      self.matrix[arrPos] and (0xFF'u8 xor (0x01'u8 shl (7 - bytePos)))

template fillPoint*(self: var Drawing, x, y: uint8) =
  self[x, y] = true

template flipPoint*(self: var Drawing, x, y: uint8) =
  self[x, y] = not self[x, y]

proc fillRectangle*(self: var Drawing, xRange, yRange: Slice[uint8]) =
  for y in yRange:
    for x in xRange:
      self.fillPoint x, y

template fillRectangle*(self: var Drawing, xRange: Slice[uint8], y: uint8) =
  self.fillRectangle xRange, y..y

template fillRectangle*(self: var Drawing, x: uint8, yRange: Slice[uint8]) =
  self.fillRectangle x..x, yRange

template fillRectangle*(self: var Drawing, xyRange: Slice[uint8]) =
  self.fillRectangle xyRange, xyRange

proc printTerminal*(self: Drawing) =
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
  case output
  of dpTerminal:
    printTerminal self
