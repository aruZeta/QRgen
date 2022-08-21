import Drawing, EncodedQRCode, BitArray, qrTypes, qrCapacities

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

iterator alignmentPatternCoords*(version: QRVersion): tuple[x, y: uint8] =
  let locations = alignmentPatternLocations[version]
  for i, pos in locations:
    if i < locations.len - 1:
      yield (x: 6'u8, y: pos)
      yield (x: pos, y: 6'u8)

    for pos2 in locations[i..<locations.len]:
      yield (x: pos, y: pos2)
      if pos != pos2:
        yield (x: pos2, y: pos)

proc drawAlignmentPatterns*(d: var DrawedQRCode, version: QRVersion) =
  if version == 1:
    return

  for x, y in alignmentPatternCoords(version):
    d.drawing.fillPoint     x,        y
    d.drawing.fillRectangle x-2..x+2, y-2
    d.drawing.fillRectangle x-2..x+2, y+2
    d.drawing.fillRectangle x-2,      y-1..y+1
    d.drawing.fillRectangle x+2,      y-1..y+1

proc drawTimingPatterns*(d: var DrawedQRCode) =
  const
    margin: uint8 = 7 + 1
  for pos in 0'u8..((d.drawing.size - margin * 2) div 2 + 1):
    d.drawing.fillPoint (margin + pos * 2), 6'u8
    d.drawing.fillPoint 6'u8, (margin + pos * 2)

proc drawDarkModule*(d: var DrawedQRCode) =
  d.drawing.fillPoint 8'u8, (d.drawing.size - 8)

type
  DirectionKind = enum
    dLeft, dUpRight, dUp, dDownRight, dDown

  OrientationKind = enum
    oUpwards, oDownwards

  Position = object
    x: uint8
    y: uint8
    direction: DirectionKind
    orientation: OrientationKind
    repeat: uint8

proc drawData*(d: var DrawedQRCode, data: BitArray, version: QRVersion) =
  let size: uint8 = d.drawing.size

  var pos = Position(x: size-1,
                     y: size-1,
                     direction: dLeft,
                     orientation: oUpwards,
                     repeat: 0)

  var
    alignmentPatternBoundsX: set[uint8]
    alignmentPatternUpperBoundsY: set[uint8]
    alignmentPatternLowerBoundsY: set[uint8]

  if alignmentPatternLocations[version].len > 1:
    alignmentPatternBoundsX.incl {4'u8..8'u8}
    alignmentPatternUpperBoundsY.incl {4'u8}
    alignmentPatternLowerBoundsY.incl {8'u8}

  for pos in alignmentPatternLocations[version]:
    alignmentPatternBoundsX.incl {pos-2..pos+2}
    alignmentPatternUpperBoundsY.incl {pos-2}
    alignmentPatternLowerBoundsY.incl {pos+2}

  template changeOrientation(o: OrientationKind) =
    pos.direction = dLeft
    pos.repeat = 1
    pos.orientation = o

  template checkRepeat(elseBody: untyped) =
    if pos.repeat > 0:
      pos.repeat -= 1
    else:
      elseBody

  for module in 0..<data.data.len * 8:
    if ((data.data[module div 8] shr (7 - (module mod 8))) and 0x01) == 0x01:
      d.drawing.fillPoint pos.x, pos.y

    # Avoiding stuff, changing orientation in borders, etc block
    case pos.direction
    of dUpRight:
      if pos.y == 0:
        changeOrientation oDownwards

      elif pos.y == 7:
        if version >= 7 and pos.x == size-10:
          pos.x -= 2
          pos.y = 0xFF # No negatives in here sir (will be turned to 0 below)
          pos.direction = dDown
          pos.orientation = oDownwards
          pos.repeat = 5
        else:
          pos.y -= 1 # Avoid top timing pattern

      elif pos.y == 9 and pos.x in {0'u8..8'u8, size-8..size-1}:
        changeOrientation oDownwards
        if pos.x == 7:
          pos.x -= 1 # Avoid left timing pattern

      elif not (pos.x == size-10 and pos.y == 9) and
           pos.x+1 in alignmentPatternBoundsX and
           pos.y-1 in alignmentPatternLowerBoundsY:
        if pos.x notin alignmentPatternBoundsX:
          pos.direction = dUp
          pos.repeat = 4
        else:
          pos.y -= 5

    of dDownRight:
      if pos.y == 5:
        pos.y += 1

      elif pos.y == size-1 or
           (version >= 7 and pos.y == size-12 and pos.x in {0'u8..5'u8}) or
           (pos.y == size-9 and pos.x in 0'u8..6'u8):
        changeOrientation oUpwards
        if pos.x == 9:
          pos.y -= 8 # Start from above the dark module

      elif not (pos.x == 4 and pos.y == size-10) and
           pos.x+1 in alignmentPatternBoundsX and
           pos.y+1 in alignmentPatternUpperBoundsY:
        if pos.x notin alignmentPatternBoundsX:
          pos.direction = dDown
          pos.repeat = 4
        else:
          pos.y += 5

    of dDown:
      if pos.y == 5:
        pos.y += 1
        if pos.repeat > 0: pos.repeat -= 1

    of dUp:
      if pos.y == 7:
        pos.y -= 1
        if pos.repeat > 0: pos.repeat -= 1

    else: discard
    # End of the block

    # Applying the direction block
    case pos.direction
    of dLeft:
      pos.x -= 1
      checkRepeat:
        pos.direction = case pos.orientation
                        of oUpwards: dUpRight
                        of oDownwards: dDownRight

    of dUpRight:
      pos.x += 1
      pos.y -= 1
      checkRepeat:
        pos.direction = dLeft

    of dUp:
      pos.y -= 1
      checkRepeat:
        pos.direction = dUpRight

    of dDownRight:
      pos.x += 1
      pos.y += 1
      checkRepeat:
        pos.direction = dLeft

    of dDown:
      pos.y += 1
      checkRepeat:
        pos.direction = dDownRight
    # End of the block

proc applyMaskPattern*(qr: var DrawedQRCode,
                       version: QRVersion,
                       maskProc: proc(x,y: uint8): bool) =
  let size: uint8 = qr.drawing.size

  var
    alignmentPatternBoundsX: set[uint8]
    alignmentPatternBoundsY: set[uint8]

  if alignmentPatternLocations[version].len > 1:
    alignmentPatternBoundsX.incl {4'u8..8'u8}
    alignmentPatternBoundsY.incl {4'u8..8'u8}

  for pos in alignmentPatternLocations[version]:
    alignmentPatternBoundsX.incl {pos-2..pos+2}
    alignmentPatternBoundsY.incl {pos-2..pos+2}

  for x in 0'u8..<qr.drawing.size:
    for y in 0'u8..<qr.drawing.size:
      if not ((x in 0'u8..8'u8 and y in {0'u8..8'u8, size-8..size-1}) or
              (x in size-8..size-1 and y in 0'u8..8'u8) or
              (x in 9'u8..size-9 and y == 6) or
              (x == 6 and y in 9'u8..size-9) or
              (version >= 7 and
               ((x in 0'u8..5'u8 and y in size-11..size-9) or
                (x in size-11..size-9 and y in 0'u8..5'u8))
              ) or
              (not ((x in 4'u8..8'u8 and y == size-9) or
                    (x == size-9 and y in 4'u8..8'u8)) and
               x in alignmentPatternBoundsX and y in alignmentPatternBoundsY)
             ):
        if maskProc(x, y):
          qr.drawing.flipPoint(x, y)

proc mask0*(x, y: uint8): bool =
  (y + x) mod 2 == 0

proc mask1*(x, y: uint8): bool =
  y mod 2 == 0

proc mask2*(x, y: uint8): bool =
  x mod 3 == 0

proc mask3*(x, y: uint8): bool =
  (y + x) mod 3 == 0

proc mask4*(x, y: uint8): bool =
  ((y div 2) + (x div 3)) mod 2 == 0

proc mask5*(x, y: uint8): bool =
  let y = cast[uint16](y)
  (((y * x) mod 2) +
   ((y * x) mod 3)) == 0

proc mask6*(x, y: uint8): bool =
  let y = cast[uint16](y)
  (((y * x) mod 2) +
   ((y * x) mod 3)) mod 2 == 0

proc mask7*(x, y: uint8): bool =
  let y = cast[uint16](y)
  (((y + x) mod 2) +
   ((y * x) mod 3)) mod 2 == 0

proc evaluateCondition1*(qr: DrawedQRCode): uint =
  result = 0

  var
    stateCol: bool
    countCol: uint
    stateRow: bool
    countRow: uint

  template mayAddPenalty(state, count: untyped) =
    if   count == 5: result += 3
    elif count >= 5: result += count - 2

  template check(state, count, getter: untyped) =
    if not (state xor getter):
      count += 1
    else:
      mayAddPenalty state, count
      state = not state
      count = 1

  for i in 0'u8..<qr.drawing.size:
    stateRow = qr.drawing[0, i]
    countRow = 1
    stateCol = qr.drawing[i, 0]
    countCol = 1

    for j in 1'u8..<qr.drawing.size:
      check stateRow, countRow, qr.drawing[j, i]
      check stateCol, countCol, qr.drawing[i, j]

    mayAddPenalty stateRow, countRow
    mayAddPenalty stateCol, countCol

proc evaluateCondition2*(qr: DrawedQRCode): uint =
  result = 0
  for i in 0'u8..<qr.drawing.size-1:
    for j in 0'u8..<qr.drawing.size-1:
      let actual = qr.drawing[j, i]
      if not ((actual xor qr.drawing[j+1, i]) or
              (actual xor qr.drawing[j, i+1]) or
              (actual xor qr.drawing[j+1, i+1])):
        result += 3

proc newDrawedQRCode*(version: QRVersion): DrawedQRCode =
  DrawedQRCode(drawing: newDrawing((version - 1) * 4 + 21))

proc newDrawedQRCode*(qr: EncodedQRCode): DrawedQRCode =
  DrawedQRCode(drawing: newDrawing((qr.version - 1) * 4 + 21))

proc draw*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr.version

  result.drawFinderPatterns
  result.drawAlignmentPatterns qr.version
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.encodedData, qr.version

proc drawOnly*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr.version

  result.drawFinderPatterns
  result.drawAlignmentPatterns qr.version
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.encodedData, qr.version
