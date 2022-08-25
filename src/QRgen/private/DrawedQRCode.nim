import Drawing, EncodedQRCode, BitArray, qrTypes, qrCapacities

type
  DrawedQRCode* = object
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QREcLevel
    drawing*: Drawing

proc drawFinderPatterns*(self: var DrawedQRCode) =
  template drawFinderPattern(x, y: uint8) =
    self.drawing.fillRectangle x..x+6,   y
    self.drawing.fillRectangle x..x+6,   y+6
    self.drawing.fillRectangle x,        y+1..y+5
    self.drawing.fillRectangle x+6,      y+1..y+5
    self.drawing.fillRectangle x+2..x+4, y+2..y+4
  drawFinderPattern 0'u8, 0'u8
  drawFinderPattern self.drawing.size - 7'u8, 0'u8
  drawFinderPattern 0'u8, self.drawing.size - 7'u8

iterator alignmentPatternCoords(version: QRVersion): tuple[x, y: uint8] =
  let locations = alignmentPatternLocations[version]
  for i, pos in locations:
    if i < locations.len - 1:
      yield (x: 6'u8, y: pos)
      yield (x: pos, y: 6'u8)
    for pos2 in locations[i..<locations.len]:
      yield (x: pos, y: pos2)
      if pos != pos2:
        yield (x: pos2, y: pos)

proc drawAlignmentPatterns*(self: var DrawedQRCode) =
  if self.version == 1:
    return
  for x, y in alignmentPatternCoords(self.version):
    self.drawing.fillPoint     x,        y
    self.drawing.fillRectangle x-2..x+2, y-2
    self.drawing.fillRectangle x-2..x+2, y+2
    self.drawing.fillRectangle x-2,      y-1..y+1
    self.drawing.fillRectangle x+2,      y-1..y+1

iterator step(start, stop: uint8, step: int): uint8 =
  var x = start
  while x <= stop:
    yield x
    x.inc step

proc drawTimingPatterns*(self: var DrawedQRCode) =
  const margin: uint8 = 7 + 1
  for pos in step(margin, self.drawing.size-margin, 2):
    self.drawing.fillPoint pos, 6'u8
    self.drawing.fillPoint 6'u8, pos

proc drawDarkModule*(self: var DrawedQRCode) =
  self.drawing.fillPoint 8'u8, (self.drawing.size - 8)

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

proc drawData*(self: var DrawedQRCode, data: BitArray) =
  let size: uint8 = self.drawing.size
  var pos = Position(x: size-1,
                     y: size-1,
                     direction: dLeft,
                     orientation: oUpwards,
                     repeat: 0)
  var
    alignmentPatternBoundsX: set[uint8]
    alignmentPatternUpperBoundsY: set[uint8]
    alignmentPatternLowerBoundsY: set[uint8]
  if alignmentPatternLocations[self.version].len > 1:
    alignmentPatternBoundsX.incl {4'u8..8'u8}
    alignmentPatternUpperBoundsY.incl {4'u8}
    alignmentPatternLowerBoundsY.incl {8'u8}
  for pos in alignmentPatternLocations[self.version]:
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
      self.drawing.fillPoint pos.x, pos.y
    # Avoiding stuff, changing orientation in borders, etc block
    case pos.direction
    of dUpRight:
      if pos.y == 0:
        changeOrientation oDownwards
      elif pos.y == 7:
        if self.version >= 7 and pos.x == size-10:
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
           (self.version >= 7 and pos.y == size-12 and pos.x in 0'u8..5'u8) or
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
        pos.direction =
          case pos.orientation
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

type MaskProc = proc(x,y: uint8): bool

proc applyMaskPattern*(self: var DrawedQRCode, maskProc: MaskProc) =
  let size: uint8 = self.drawing.size
  var
    alignmentPatternBoundsX: set[uint8]
    alignmentPatternBoundsY: set[uint8]
  if alignmentPatternLocations[self.version].len > 1:
    alignmentPatternBoundsX.incl {4'u8..8'u8}
    alignmentPatternBoundsY.incl {4'u8..8'u8}
  for pos in alignmentPatternLocations[self.version]:
    alignmentPatternBoundsX.incl {pos-2..pos+2}
    alignmentPatternBoundsY.incl {pos-2..pos+2}
  for x in 0'u8..<self.drawing.size:
    for y in 0'u8..<self.drawing.size:
      if not ((x in 0'u8..8'u8 and y in {0'u8..8'u8, size-8..size-1}) or
              (x in size-8..size-1 and y in 0'u8..8'u8) or
              (x in 9'u8..size-9 and y == 6) or
              (x == 6 and y in 9'u8..size-9) or
              (self.version >= 7 and
               ((x in 0'u8..5'u8 and y in size-11..size-9) or
                (x in size-11..size-9 and y in 0'u8..5'u8))
              ) or
              (not ((x in 4'u8..8'u8 and y == size-9) or
                    (x == size-9 and y in 4'u8..8'u8)) and
               x in alignmentPatternBoundsX and y in alignmentPatternBoundsY)
             ):
        if maskProc(x, y):
          self.drawing.flipPoint(x, y)

proc mask0*(x, y: uint8): bool =
  # No need to make y a uint16 since using mod 2:
  # 255 mod 2 = 1, 256 -> 0 mod 2 = 0, correct
  (y + x) mod 2 == 0

proc mask1*(x, y: uint8): bool =
  y mod 2 == 0

proc mask2*(x, y: uint8): bool =
  x mod 3 == 0

proc mask3*(x, y: uint8): bool =
  # Need to make y a uint16 since using mod 3:
  # 255 mod 3 = 0, 256 mod 3 = 1 -> 0 mod 3 = 0, incorrect
  let y = cast[uint16](y)
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

proc evaluateCondition1*(self: DrawedQRCode): uint =
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
  for i in 0'u8..<self.drawing.size:
    stateRow = self.drawing[0, i]
    countRow = 1
    stateCol = self.drawing[i, 0]
    countCol = 1
    for j in 1'u8..<self.drawing.size:
      check stateRow, countRow, self.drawing[j, i]
      check stateCol, countCol, self.drawing[i, j]
    mayAddPenalty stateRow, countRow
    mayAddPenalty stateCol, countCol

proc evaluateCondition2*(self: DrawedQRCode): uint =
  result = 0
  for i in 0'u8..<self.drawing.size-1:
    for j in 0'u8..<self.drawing.size-1:
      let actual = self.drawing[j, i]
      if not ((actual xor self.drawing[j+1, i]) or
              (actual xor self.drawing[j, i+1]) or
              (actual xor self.drawing[j+1, i+1])):
        result += 3

proc evaluateCondition3*(self: DrawedQRCode): uint =
  result = 0
  for i in 0'u8..<self.drawing.size:
    for j in 0'u8..<self.drawing.size-10:
      if self.drawing[j..j+10, i] in {0b10111010000'u16, 0b00001011101}:
        result += 40
      if self.drawing[i, j..j+10] in {0b10111010000'u16, 0b00001011101}:
        result += 40

proc evaluateCondition4*(self: DrawedQRCode): uint =
  var darkModules: uint32 = 0
  for i in 0..<self.drawing.matrix.len:
    var b = self.drawing.matrix[i]
    while b > 0:
      darkModules += 1
      b = b and (b - 1)
  case ((darkModules * 100) div
        (cast[uint16](self.drawing.size) * self.drawing.size))
  of 45..54: 0
  of 40..44, 55..59: 10
  of 35..39, 60..64: 20
  of 30..34, 65..69: 30
  of 25..29, 70..74: 40
  of 20..24, 75..79: 50
  of 15..19, 80..84: 60
  of 10..14, 85..89: 70
  of 05..09, 90..94: 80
  of 00..04, 95..99: 90
  else: 0 # Should not be reached

proc newDrawedQRCode*(version: QRVersion,
                      mode: QRMode = qrByteMode,
                      ecLevel: QREcLevel = qrEcL
                     ): DrawedQRCode =
  DrawedQRCode(mode: mode,
               version: version,
               ecLevel: ecLevel,
               drawing: newDrawing((version - 1) * 4 + 21))

proc newDrawedQRCode*(qr: EncodedQRCode): DrawedQRCode =
  DrawedQRCode(mode: qr.mode,
               version: qr.version,
               ecLevel: qr.ecLevel,
    drawing: newDrawing((qr.version - 1) * 4 + 21))

proc draw*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr

  result.drawFinderPatterns
  result.drawAlignmentPatterns
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.encodedData

proc drawOnly*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr

  result.drawFinderPatterns
  result.drawAlignmentPatterns
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.encodedData
