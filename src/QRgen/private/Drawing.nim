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

proc `[]=`(d: var Drawing, y, x: uint8, val: bool) =
  let
    bitPos:  uint16 = cast[uint16](y) * d.size + x
    arrPos:  uint16 = bitPos div 8
    bytePos: uint8  = cast[uint8](bitPos mod 8)

  if val:
    d.matrix[arrPos] = d.matrix[arrPos] or
                       (0x01'u8 shl (7 - bytePos))
  else:
    d.matrix[arrPos] = d.matrix[arrPos] and
                       (0xFF'u8 xor (0x01'u8 shl (7 - bytePos)))

proc fillRectangle*(d: var Drawing, width, height: Slice[uint8]) =
  for y in height:
    for x in width:
      d[y, x] = true

template fillRectangle*(d: var Drawing, width: Slice[uint8], height: uint8) =
  fillRectangle(d, width, height..height)

template fillRectangle*(d: var Drawing, width: uint8, height: Slice[uint8]) =
  fillRectangle(d, width..width, height)

template fillRectangle*(d: var Drawing, size: Slice[uint8]) =
  fillRectangle(d, size, size)

template fillPoint*(d: var Drawing, width, height: uint8) =
  fillRectangle(d, width..width, height..height)

template fillRow*(d: var Drawing, row: uint8) =
  fillRectangle(d, 0'u8..d.size-1, row..row)

template fillColumn*(d: var Drawing, column: uint8) =
  fillRectangle(d, column..column, 0'u8..d.size-1)

proc printTerminal*(d: Drawing) =
  for y in 0'u8..<d.size:
    for x in 0'u8..<d.size:
      let
        bitPos:  uint16 = cast[uint16](y) * d.size + x
        arrPos:  uint16 = bitPos div 8
        bytePos: uint8  = cast[uint8](bitPos mod 8)
      if ((d.matrix[arrPos] shr (7 - bytePos)) and 1'u8) == 1'u8:
        stdout.write "██"
      else:
        stdout.write "  "
    stdout.write "\n"

proc print*(d: Drawing, output: DrawingPrint) =
  case output
  of dpTerminal:
    printTerminal d
