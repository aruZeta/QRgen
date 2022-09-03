import
  "."/[calcPenalty, type],
  ".."/[Drawing, qrCapacities]

type MaskProc = proc(x,y: uint8): bool

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

proc applyMaskPattern*(self: var DrawedQRCode, maskProc: MaskProc) =
  template size: uint8 = self.drawing.size
  var
    alignmentPatternBoundsX: set[uint8]
    alignmentPatternBoundsY: set[uint8]
  if alignmentPatternLocations[self.version].len > 1:
    alignmentPatternBoundsX.incl {4'u8..8'u8}
    alignmentPatternBoundsY.incl {4'u8..8'u8}
  for pos in alignmentPatternLocations[self.version]:
    alignmentPatternBoundsX.incl {pos-2..pos+2}
    alignmentPatternBoundsY.incl {pos-2..pos+2}
  for x in 0'u8..<size:
    for y in 0'u8..<size:
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

proc applyBestMaskPattern*(self: var DrawedQRCode) =
  var
    bestPenalty: uint16 = uint16.high
    bestMask: MaskProc
  for i, mask in [mask0, mask1, mask2, mask3, mask4, mask5, mask6, mask7]:
    var copy = self
    copy.applyMaskPattern mask
    let penalty = copy.calcPenalty
    if penalty < bestPenalty:
      bestPenalty = penalty
      bestMask = mask
      self.mask = cast[uint8](i)
  self.applyMaskPattern bestMask
