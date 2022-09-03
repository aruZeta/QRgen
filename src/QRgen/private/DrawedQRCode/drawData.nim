import
  "."/[type],
  ".."/[BitArray, Drawing, qrCapacities]

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
  template size: uint8 = self.drawing.size
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
  for module in 0..<data.len*8:
    if ((data[module div 8] shr (7 - (module mod 8))) and 0x01) == 0x01:
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
