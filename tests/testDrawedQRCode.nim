import std/unittest
import QRgen/private/[DrawedQRCode, EncodedQRCode, QRCode, Drawing]

test "Finder patterns":
  var qr = newDrawedQRCode(encode(newQRCode("Hello World")))
  qr.drawFinderPatterns

  qr.drawing.print dpTerminal
