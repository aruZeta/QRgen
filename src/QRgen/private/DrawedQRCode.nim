import Drawing, EncodedQRCode, qrTypes

type
  DrawedQRCode* = object
    drawing*: Drawing

proc drawFinderPatterns*(d: var DrawedQRCode) =
  template drawFinderPattern(x, y: uint8) =
    d.drawing.fillRectangle x+0'u8..x+6'u8, y+0'u8
    d.drawing.fillRectangle x+0'u8..x+6'u8, y+6'u8
    d.drawing.fillRectangle x+0'u8,         y+1'u8..y+5'u8
    d.drawing.fillRectangle x+6'u8,         y+1'u8..y+5'u8
    d.drawing.fillRectangle x+2'u8..x+4'u8, y+2'u8..y+4'u8

  drawFinderPattern 0'u8, 0'u8
  drawFinderPattern d.drawing.size - 8'u8, 0'u8
  drawFinderPattern 0'u8, d.drawing.size - 8'u8

proc newDrawedQRCode*(version: QRVersion): DrawedQRCode =
  DrawedQRCode(drawing: newDrawing((version - 1) * 4 + 21))

proc newDrawedQRCode*(qr: EncodedQRCode): DrawedQRCode =
  DrawedQRCode(drawing: newDrawing((qr.version - 1) * 4 + 21))

proc draw*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr.version

  result.drawFinderPatterns
