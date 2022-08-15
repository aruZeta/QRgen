import std/unittest
import QRgen/private/Drawing

test "Simple square":
  var drawing: Drawing = newDrawing(10)
  drawing.fillRectangle 1'u8..8'u8, 1'u8..8'u8

  print drawing, dpTerminal

test "Simple finder pattern":
  var drawing: Drawing = newDrawing(7)
  drawing.fillRow 0'u8
  drawing.fillRow 6'u8
  drawing.fillColumn 0'u8
  drawing.fillColumn 6'u8
  drawing.fillRectangle 2'u8..4'u8, 2'u8..4'u8

  print drawing, dpTerminal
