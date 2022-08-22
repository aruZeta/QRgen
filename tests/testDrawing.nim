import myTestSuite
import QRgen/private/Drawing

benchmarkTest "Simple square":
  var drawing: Drawing = newDrawing(10)
  drawing.fillRectangle 1'u8..8'u8

  print drawing, dpTerminal

benchmarkTest "Simple finder pattern":
  var drawing: Drawing = newDrawing(7)
  drawing.fillRectangle 0'u8..6'u8, 0'u8
  drawing.fillRectangle 0'u8..6'u8, 6'u8
  drawing.fillRectangle 0'u8,       0'u8..6'u8
  drawing.fillRectangle 6'u8,       0'u8..6'u8
  drawing.fillRectangle 2'u8..4'u8

  print drawing, dpTerminal
