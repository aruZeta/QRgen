import
  "."/[calcPenalty, type],
  ".."/[Drawing, qrCapacities]

type MaskProc = proc(x,y: uint8): bool

template mask0*(x, y: uint8): bool =
  # No need to make y a uint16 since using mod 2:
  # 255 mod 2 = 1, 256 -> 0 mod 2 = 0, correct
  (y + x) mod 2 == 0

template mask1*(x, y: uint8): bool =
  y mod 2 == 0

template mask2*(x, y: uint8): bool =
  x mod 3 == 0

template mask3*(x, y: uint8): bool =
  # Need to make y a uint16 since using mod 3:
  # 255 mod 3 = 0, 256 mod 3 = 1 -> 0 mod 3 = 0, incorrect
  (cast[uint16](y) + x) mod 3 == 0

template mask4*(x, y: uint8): bool =
  ((y div 2) + (x div 3)) mod 2 == 0

template mask5*(x, y: uint8): bool =
  (((cast[uint16](y) * x) mod 2) +
   ((cast[uint16](y) * x) mod 3)) == 0

template mask6*(x, y: uint8): bool =
  (((cast[uint16](y) * x) mod 2) +
   ((cast[uint16](y) * x) mod 3)) mod 2 == 0

template mask7*(x, y: uint8): bool =
  (((cast[uint16](y) + x) mod 2) +
   ((cast[uint16](y) * x) mod 3)) mod 2 == 0

proc calcAlignmentPatternBounds(self: DrawedQRCode): set[uint8] =
  if alignmentPatternLocations[self.version].len > 1:
    result.incl {4'u8..8'u8}
  for pos in alignmentPatternLocations[self.version]:
    result.incl {pos-2..pos+2}

template isReservedArea(x, y: uint8, bounds: set[uint8]): bool =
  (x in 0'u8..8'u8 and y in {0'u8..8'u8, size-8..size-1}) or
  (x in size-8..size-1 and y in 0'u8..8'u8) or
  (x in 9'u8..size-9 and y == 6) or
  (x == 6 and y in 9'u8..size-9) or
  (self.version >= 7 and
    ((x in 0'u8..5'u8 and y in size-11..size-9) or
    (x in size-11..size-9 and y in 0'u8..5'u8))
  ) or
  (not ((x in 4'u8..8'u8 and y == size-9) or
        (x == size-9 and y in 4'u8..8'u8)) and
   x in bounds and
   y in bounds)

proc applyMaskPattern*(self: var DrawedQRCode, mask: Mask) =
  template size: uint8 = self.drawing.size
  let alignmentPatternBounds = self.calcAlignmentPatternBounds
  template drawMask(canApplyMask: untyped) {.dirty.} =
    for x in 0'u8..<size:
      for y in 0'u8..<size:
        if canApplyMask and not isReservedArea(x, y, alignmentPatternBounds):
          self.drawing.flipPoint(x, y)
  case mask
  of 0: drawMask mask0(x,y)
  of 1: drawMask mask1(x,y)
  of 2: drawMask mask2(x,y)
  of 3: drawMask mask3(x,y)
  of 4: drawMask mask4(x,y)
  of 5: drawMask mask5(x,y)
  of 6: drawMask mask6(x,y)
  of 7: drawMask mask7(x,y)

proc applyBestMaskPattern*(self: var DrawedQRCode) =
  var
    bestPenalty: uint16 = uint16.high
    bestMask: Mask
  for i in Mask.low..Mask.high:
    var copy = self
    copy.applyMaskPattern i
    let penalty = copy.calcPenalty
    if penalty < bestPenalty:
      bestPenalty = penalty
      bestMask = i
      self.mask = cast[uint8](i)
  self.applyMaskPattern bestMask
