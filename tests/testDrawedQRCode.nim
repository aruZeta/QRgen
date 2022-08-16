import std/unittest
import QRgen/private/[DrawedQRCode, EncodedQRCode, QRCode, Drawing]

test "Finder patterns":
  var qr = newDrawedQRCode(encode(newQRCode("Hello World")))
  qr.drawFinderPatterns

  qr.drawing.print dpTerminal

test "Alignment patterns":
  var qr1 = newQRCode("Hello World", version = 2).encode.newDrawedQRCode
  qr1.drawFinderPatterns
  qr1.drawAlignmentPatterns
  qr1.drawing.print dpTerminal

  var qr2 = newQRCode("Hello World", version = 7).encode.newDrawedQRCode
  qr2.drawFinderPatterns
  qr2.drawAlignmentPatterns
  qr2.drawing.print dpTerminal

  var qr3 = newQRCode("Hello World", version = 14).encode.newDrawedQRCode
  qr3.drawFinderPatterns
  qr3.drawAlignmentPatterns
  qr3.drawing.print dpTerminal

test "Timing patterns":
  var qr1 = newQRCode("Hello World", version = 1).encode.newDrawedQRCode
  qr1.drawFinderPatterns
  qr1.drawAlignmentPatterns
  qr1.drawTimingPatterns
  qr1.drawing.print dpTerminal

  var qr2 = newQRCode("Hello World", version = 7).encode.newDrawedQRCode
  qr2.drawFinderPatterns
  qr2.drawAlignmentPatterns
  qr2.drawTimingPatterns
  qr2.drawing.print dpTerminal

  var qr3 = newQRCode("Hello World", version = 14).encode.newDrawedQRCode
  qr3.drawFinderPatterns
  qr3.drawAlignmentPatterns
  qr3.drawTimingPatterns
  qr3.drawing.print dpTerminal
