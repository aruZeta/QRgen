import DrawedQRCode, EncodedQRCode, QRCode, Drawing, qrCapacities
import strutils
import os

let qr = newQRCode("Hello World", version = 8).encode
var a: seq[string] = @[]
for b in qr.encodedData.data: a.add(toBin(cast[int](b), 8))
echo a

var d = newDrawedQRCode qr
d.drawFinderPatterns
d.drawAlignmentPatterns qr.version
d.drawTimingPatterns
d.drawDarkModule

#[
for i in 0..<qr.encodedData.data.len:
  for j in 0..<8:
    if ((qr.encodedData.data[i] shr (7 - j)) and 0x01) == 0x01:
      d.drawing.fillPoint x, y
]#

type
  DirectionKind = enum
    dLeft,
    dUpRight,
    dUp,
    dDownRight,
    dDown
  OrientationKind = enum
    upwards,
    downwards

var
  direction: DirectionKind = dLeft
  orientation: OrientationKind = upwards
  repeat: uint8 = 0
  x: uint8 = d.drawing.size - 1
  y: uint8 = x

let y8BoundsX: set[uint8] = {0'u8..8'u8, d.drawing.size-8..d.drawing.size-1}

var
  alignmentPatternBoundsX: set[uint8]
  alignmentPatternBoundsY: set[uint8]
  corner2BoundsX: set[uint8] # Top right
  corner2BoundsY: set[uint8]
  corner3BoundsX: set[uint8] # Bottom left
  corner3BoundsY: set[uint8]

if alignmentPatternLocations[qr.version].len > 1:
  alignmentPatternBoundsX.incl {4'u8..8'u8}
  alignmentPatternBoundsY.incl {4'u8, 8'u8}

  let lastLocation = alignmentPatternLocations[qr.version][^1]

  corner2BoundsX.incl {lastLocation-2}
  corner2BoundsY.incl {4'u8, 8'u8}

  corner3BoundsX.incl {4'u8..5'u8}
  corner3BoundsY.incl {lastLocation-2}

#[
also could make them into upper bound and lower bound,
upper for dUpRight and lower for dDownRight
]#

for pos in alignmentPatternLocations[qr.version]:
  alignmentPatternBoundsX.incl {pos-2..pos+2}
  alignmentPatternBoundsY.incl {pos-2, pos+2}

if qr.version >= 7:
  discard

echo alignmentPatternBoundsX
echo alignmentPatternBoundsY
echo corner2BoundsX
echo corner2BoundsY
echo corner3BoundsX
echo corner3BoundsY

var
  aX: uint8 = x
  aY: uint8 = y
  pD: DirectionKind

d.drawing.fillPoint x, y
#if ((qr.encodedData.data[0] shr (7)) and 0x01) == 0x01:
  #d.drawing.fillPoint x, y

for module in 1..<qr.encodedData.data.len * 8 + qr.eccCodewords.data.len * 8:
  pD = direction
  case direction
  of dLeft:
    x -= 1
    if repeat > 0: repeat -= 1
    else: direction = if orientation == upwards: dUpRight
                      else: dDownRight
  of dUpRight:
    x += 1
    y -= 1
    direction = dLeft
  of dUp:
    y -= 1
    if repeat > 0: repeat -= 1
    else: direction = dUpRight
  of dDownRight:
    y += 1
    x += 1
    direction = dLeft
  of dDown:
    y += 1
    if repeat > 0: repeat -= 1
    else: direction = dDownRight

  if true: #module > 1600:
    # sleep 200
    discard stdin.readLine # Advance pressing Enter key
    d.drawing.print dpTerminal
    echo "Actual x: ", aX, " y: ", aY
    echo "Next x: ", x, " y: ", y
    echo "Direction: ", pD

  d.drawing.fillPoint x, y
  #let
    #arrPos = module div 8
    #bytePos = module mod 8
  #if ((qr.encodedData.data[arrPos] shr (7 - bytePos)) and 0x01) == 0x01:
    #d.drawing.fillPoint x, y

  aX = x
  aY = y

  if direction == dUpRight:
    if y == 9 and x in y8BoundsX:
      direction = dLeft
      orientation = downwards
      repeat = 1
      if x == 7:
        x -= 1
    elif y == 0:
      direction = dLeft
      orientation = downwards
      repeat = 1
    elif y == 7:
      y -= 1
    elif x+1 in alignmentPatternBoundsX and
         y-1 in alignmentPatternBoundsY and
         not (x+1 in corner2BoundsX and y-1 in corner2BoundsY):
      if x notin alignmentPatternBoundsX:
        direction = dUp
        repeat = 4
      else:
        y -= 5
  elif direction == dDownRight:
    if y == d.drawing.size-1 or (y == d.drawing.size-9 and x < 6):
      direction = dLeft
      orientation = upwards
      repeat = 1
      if x == 9:
        y -= 8
    elif y == 5:
      y += 1
    elif x+1 in alignmentPatternBoundsX and
         y+1 in alignmentPatternBoundsY and
         not (x+1 in corner3BoundsX and y+1 in corner3BoundsY):
      if x notin alignmentPatternBoundsX:
        direction = dDown
        repeat = 4
      else:
        y += 5
  elif direction == dDown:
    if y == 5:
      y += 1
      if repeat > 0: repeat -= 1

d.drawing.print dpTerminal
