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
  """ fill="{dark}" x="{x.float32+moSep:<3}" y="{y.float32+moSep}"""" &
  """ width="{1-moSep*2}"""" &
  """ height="{1-moSep*2}"""" &
  """ rx="{moRadPx}"""" &
  """></rect>"""

const alignmentPatternRect: string =
  """<rect class="qr{m} qrRounded qrAlignment"""" &
  """ fill="{c}" x="{x}" y="{y}" width="{size}" height="{size}"""" &
  """ rx="{r}"></rect>"""

type
  Percentage = range[0f32..100f32]
  Separation = range[0f32..0.4f32]

converter toBool(self: Percentage): bool =
  self > Percentage.low

func printSvg*(
  self: DrawedQRCode,
  light = "#ffffff",
  dark = "#000000",
  alRad: Percentage = 0,
  moRad: Percentage = 0,
  moSep: Separation = 0.1,
  class: string = "qrCode",
  id: string = "",
  forceUseRect: bool = false
): string =
  result = fmt(svgHeader)
  template drawRegion(ax, bx, ay, by: uint8, s: static string) {.dirty.} =
    for y in ay..<by:
      for x in ax..<bx:
        if self.drawing[x, y]:
          result.add fmt(s)
  template drawQRModulesOnly(s: static string) {.dirty.} =
    drawRegion 0'u8, size, 7'u8, size-7, s
    drawRegion 7'u8, size-7, 0'u8, 7'u8, s
    drawRegion 7'u8, size, size-7, size, s
  if moRad or forceUseRect:
    let moRadPx: float32 = (0.5 - moSep) * moRad / 100
    drawQRModulesOnly moduleRect
  else:
    result.add fmt(modulePathStart)
    if alRad:
      drawQRModulesOnly modulePath
    else:
      drawRegion 0'u8, size, 0'u8, size, modulePath
    result.add fmt(modulePathEnd)
  if alRad or forceUseRect:
    let alRadPx: float32 = 3.5 * alRad / 100
    template innerRadius(lvl: range[1'i8..2'i8]): float32 =
      if alRadPx == 0: 0f
      elif alRadPx-lvl <= 0: 1f / (lvl * 2)
      else: alRadPx-lvl
    func drawRoundedRect(x, y, size: uint8, r: float32, m, c: string): string =
      fmt(alignmentPatternRect)
    template drawRoundedAlPattern(x, y: uint8): string =
      drawRoundedRect(x, y, 7'u8, alRadPx, "dark", dark) &
      drawRoundedRect(x+1, y+1, 5'u8, innerRadius 1, "light", light) &
      drawRoundedRect(x+2, y+2, 3'u8, innerRadius 2, "dark", dark)
    result.add drawRoundedAlPattern(0'u8, 0'u8)
    result.add drawRoundedAlPattern(size-7, 0'u8)
    result.add drawRoundedAlPattern(0'u8, size-7)
  result.add svgEnd
