import
  "."/[type],
  ".."/[Drawing],
  std/[strformat]

when defined(js):
  import
    std/[jsconsole]

template size: uint8 = self.drawing.size

proc printTerminal*(self: DrawedQRCode) =
  ## Print a `DrawedQRCode` to the terminal using `stdout`.
  template log(s: string) =
    when defined(js):
      console.log s
    else:
      stdout.write s
  log "\n\n\n\n\n"
  for y in 0'u8..<size:
    log "          "
    for x in 0'u8..<size:
      log(
        if self.drawing[x, y]: "██"
        else: "  "
      )
    log "\n"
  log "\n\n\n\n\n"

const svgHeader: string =
  # SVG tag start
  """<svg class="{class}" id="{id}" version="1.1"""" &
  """ xmlns="http://www.w3.org/2000/svg"""" &
  """ viewBox="-5 -5 {size+10} {size+10}">""" &
  # Background of the SVG
  """<path class="qrLight" fill="{light}"""" &
  """ d="M-5,-5h{size+10}v{size+10}h-{size+10}Z"></path>"""

const svgEnd: string = "</svg>"

const modulePath: string =
  """M{x},{y}h1v1h-1Z"""

const modulePathStart: string =
  """<path class="qrDark" fill="{dark}" d=""""

const modulePathEnd: string =
  "\"></path>"

const moduleRect: string =
  """<rect class="qrDark qrRounded qrModule"""" &
  """ fill="{dark}" x="{x.float32+moSep}" y="{y.float32+moSep}"""" &
  """ width="{1-moSep*2:<.3}"""" &
  """ height="{1-moSep*2:<.3}"""" &
  """ rx="{moRadPx:<.3}"""" &
  """></rect>"""

const alignmentPatternRect: string =
  """<rect class="qr{m} qrRounded qrAlignment"""" &
  """ fill="{c}" x="{x}" y="{y}" width="{w}" height="{h}"""" &
  """ rx="{r:<.3}"></rect>"""

template drawRegion(ax, bx, ay, by: uint8, s: string) {.dirty.} =
  for y in ay..<by:
    for x in ax..<bx:
      if self.drawing[x, y]:
        result.add fmt(s)

template drawRegionWithoutAlPatterns(s: string) {.dirty.} =
  drawRegion 0'u8, size, 7'u8, size-7, s
  drawRegion 7'u8, size-7, 0'u8, 7'u8, s
  drawRegion 7'u8, size, size-7, size, s

func roundedRect(x, y, w, h: uint8, r: float32, m, c: string): string =
  fmt(alignmentPatternRect)

template checkRadius(lvl: range[1'i8..2'i8]): float32 =
  if alRadPx == 0: 0f
  elif alRadPx-lvl <= 0: 1f / (lvl * 2)
  else: alRadPx-lvl

template drawRoundedAlignmentPattern(x, y: uint8): string =
  roundedRect(x, y, 7'u8, 7'u8, alRadPx, "dark", dark) &
  roundedRect(x+1, y+1, 5'u8, 5'u8, checkRadius 1, "light", light) &
  roundedRect(x+2, y+2, 3'u8, 3'u8, checkRadius 2, "dark", dark)

template drawRoundedAlignmentPatterns {.dirty.} =
  result.add drawRoundedAlignmentPattern(0'u8, 0'u8)
  result.add drawRoundedAlignmentPattern(size-7, 0'u8)
  result.add drawRoundedAlignmentPattern(0'u8, size-7)

proc checkParamInRange(
  name: static string,
  val: float32,
  r1: static float32,
  r2: static float32
) {.inline.} =
  const err =
    name & "must be a value between " & $r1 & " and " & $r2
  if val notin r1..r2: raise newException(RangeDefect, err)

func getMoSep(moRad: float32, forceUseRect: bool): float32 =
  if moRad > 0 or forceUseRect: 0.1
  else: 0

proc printSvg*(
  self: DrawedQRCode,
  light = "#ffffff",
  dark = "#000000",
  alRad: float32 = 0,
  moRad: float32 = 0,
  forceUseRect: bool = false,
  moSep: float32 = getMoSep(moRad, forceUseRect),
  class: string = "qrCode",
  id: string = "",
): string =
  checkParamInRange "alRad", alRad, 0f32, 100f32
  checkParamInRange "moRad", moRad, 0f32, 100f32
  checkParamInRange "moSep", moSep, 0f32, 0.4f32
  result = fmt(svgHeader)
  if moRad > 0 or forceUseRect:
    let moRadPx: float32 = (0.5 - moSep) * moRad / 100
    drawRegionWithoutAlPatterns moduleRect
  else:
    result.add fmt(modulePathStart)
    if alRad > 0:
      drawRegionWithoutAlPatterns modulePath
    else:
      drawRegion 0'u8, size, 0'u8, size, modulePath
    result.add fmt(modulePathEnd)
  if alRad > 0 or forceUseRect:
    let alRadPx: float32 = 3.5 * alRad / 100
    drawRoundedAlignmentPatterns
  result.add svgEnd
