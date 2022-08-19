import std/unittest
import QRgen/private/[DrawedQRCode, EncodedQRCode, QRCode, Drawing, qrTypes]

test "Finder patterns":
  var qr = newDrawedQRCode(encode(newQRCode("Hello World")))
  qr.drawFinderPatterns

  qr.drawing.print dpTerminal

test "Alignment patterns":
  var qr1 = newQRCode("Hello World", version = 2).encode.newDrawedQRCode
  qr1.drawFinderPatterns
  qr1.drawAlignmentPatterns 2
  qr1.drawing.print dpTerminal

  var qr2 = newQRCode("Hello World", version = 7).encode.newDrawedQRCode
  qr2.drawFinderPatterns
  qr2.drawAlignmentPatterns 7
  qr2.drawing.print dpTerminal

  var qr3 = newQRCode("Hello World", version = 14).encode.newDrawedQRCode
  qr3.drawFinderPatterns
  qr3.drawAlignmentPatterns 14
  qr3.drawing.print dpTerminal

test "Timing patterns":
  var qr1 = newQRCode("Hello World", version = 1).encode.newDrawedQRCode
  qr1.drawFinderPatterns
  qr1.drawAlignmentPatterns 1
  qr1.drawTimingPatterns
  qr1.drawing.print dpTerminal

  var qr2 = newQRCode("Hello World", version = 7).encode.newDrawedQRCode
  qr2.drawFinderPatterns
  qr2.drawAlignmentPatterns 7
  qr2.drawTimingPatterns
  qr2.drawing.print dpTerminal

  var qr3 = newQRCode("Hello World", version = 14).encode.newDrawedQRCode
  qr3.drawFinderPatterns
  qr3.drawAlignmentPatterns 14
  qr3.drawTimingPatterns
  qr3.drawing.print dpTerminal

test "Dark module":
  var qr1 = newQRCode("Hello World", version = 1).encode.newDrawedQRCode
  qr1.drawFinderPatterns
  qr1.drawAlignmentPatterns 1
  qr1.drawTimingPatterns
  qr1.drawDarkModule
  qr1.drawing.print dpTerminal

  var qr2 = newQRCode("Hello World", version = 7).encode.newDrawedQRCode
  qr2.drawFinderPatterns
  qr2.drawAlignmentPatterns 7
  qr2.drawTimingPatterns
  qr2.drawDarkModule
  qr2.drawing.print dpTerminal

  var qr3 = newQRCode("Hello World", version = 14).encode.newDrawedQRCode
  qr3.drawFinderPatterns
  qr3.drawAlignmentPatterns 14
  qr3.drawTimingPatterns
  qr3.drawDarkModule
  qr3.drawing.print dpTerminal

test "Fill all data modules":
  var qr = newEncodedQRCode(7, qrEccL)
  for i in 0..<qr.encodedData.data.len:
    qr.encodedData.data[i] = 0xFF

  check qr.drawOnly.drawing.matrix == @[
    254'u8,127,255,255,195,252,19,255,255,254,16,110,159,255,255,240,187,116,
    255,255,255,133,219,167,255,255,252,46,193,63,252,127,225,7,250,170,170,
    170,175,224,15,255,31,255,0,2,127,255,255,248,7,239,255,255,255,255,255,
    255,255,255,255,255,251,255,255,255,255,255,255,255,255,255,255,254,255,
    255,255,255,255,255,255,255,255,255,255,191,255,255,255,255,255,255,255,
    255,255,255,239,255,255,255,255,255,255,255,255,255,255,251,255,255,255,
    255,255,255,255,255,255,255,252,127,252,127,252,127,235,255,235,255,235,
    255,31,255,31,255,31,255,255,255,255,255,255,239,255,255,255,255,255,255,
    255,255,255,255,251,255,255,255,255,255,255,255,255,255,255,254,255,255,
    255,255,255,255,255,255,255,255,255,191,255,255,255,255,255,255,255,255,
    255,255,239,255,255,255,255,192,255,255,255,255,254,3,255,255,255,255,240,
    63,255,255,255,255,128,127,252,127,252,127,249,255,235,255,235,240,79,255,
    31,255,31,186,127,255,255,255,253,211,255,255,255,255,238,159,255,255,255,
    255,4,255,255,255,255,255,231,255,255,255,255,128
  ]

  var qr2 = newEncodedQRCode(2, qrEccL)
  for i in 0..<qr2.encodedData.data.len:
    qr2.encodedData.data[i] = 0xFF

  check qr2.drawOnly.drawing.matrix == @[
    254'u8,127,191,193,63,208,110,159,235,183,79,245,219,167,250,236,19,253,7,
    250,170,254,0,255,0,2,127,128,126,255,255,255,255,255,255,191,255,255,255,
    255,251,239,255,252,255,255,254,123,255,255,63,255,255,128,127,199,255,159,
    235,240,79,241,251,167,255,253,211,255,254,233,255,255,4,255,255,254,127,
    255,128
  ]

  var qr3 = newEncodedQRCode(1, qrEccL)
  for i in 0..<qr3.encodedData.data.len:
    qr3.encodedData.data[i] = 0xFF

  check qr3.drawOnly.drawing.matrix == @[
    254'u8,123,252,19,208,110,158,187,116,245,219,167,174,193,61,7,250,175,224,
    15,0,2,120,7,239,255,255,255,255,251,255,255,255,255,128,127,255,249,255,
    240,79,255,186,127,253,211,255,238,159,255,4,255,255,231,255,128
  ]

test "Drawing data":
  let qr = newQRCode("Hello World", version = 2).encode

  qr.drawOnly.drawing.print dpTerminal
