import Drawing, EncodedQRCode, qrTypes, qrCapacities

type
  DrawedQRCode* = object
    drawing*: Drawing

proc drawFinderPatterns*(d: var DrawedQRCode) =
  template drawFinderPattern(x, y: uint8) =
    d.drawing.fillRectangle x..x+6,   y
    d.drawing.fillRectangle x..x+6,   y+6
    d.drawing.fillRectangle x,        y+1..y+5
    d.drawing.fillRectangle x+6,      y+1..y+5
    d.drawing.fillRectangle x+2..x+4, y+2..y+4

  drawFinderPattern 0'u8, 0'u8
  drawFinderPattern d.drawing.size - 7'u8, 0'u8
  drawFinderPattern 0'u8, d.drawing.size - 7'u8

proc calcVersion(size: uint8): QRVersion =
  (size - 21'u8) div 4'u8 + 1'u8

proc drawAlignmentPatterns*(d: var DrawedQRCode) =
  const version2Size: uint8 = 1 * 4 + 21
  if d.drawing.size < version2Size:
    return

  template drawFinderPattern(x, y: uint8) =
    d.drawing.fillPoint     x,        y
    d.drawing.fillRectangle x-2..x+2, y-2
    d.drawing.fillRectangle x-2..x+2, y+2
    d.drawing.fillRectangle x-2,      y-1..y+1
    d.drawing.fillRectangle x+2,      y-1..y+1

  let locations = alignmentPatternLocations[calcVersion d.drawing.size]
  for i, pos in locations:
    if i < locations.len - 1:
      drawFinderPattern 6'u8, pos
      drawFinderPattern pos, 6'u8

    for pos2 in locations[i..<locations.len]:
      drawFinderPattern pos, pos2
      if pos != pos2:
        drawFinderPattern pos2, pos

proc newDrawedQRCode*(version: QRVersion): DrawedQRCode =
  DrawedQRCode(drawing: newDrawing((version - 1) * 4 + 21))

proc newDrawedQRCode*(qr: EncodedQRCode): DrawedQRCode =
  DrawedQRCode(drawing: newDrawing((qr.version - 1) * 4 + 21))

proc draw*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr.version

  result.drawFinderPatterns
  result.drawAlignmentPatterns
