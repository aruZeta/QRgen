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

const svgEnd: string =
  """</svg>"""

const moPath: string =
  """M{x},{y}h1v1h-1Z"""

const moPathStart: string =
  """<path class="qrDark" fill="{dark}" d=""""

const moPathEnd: string =
  "\"></path>"

const moRect: string =
  """<rect""" &
  """ x="{x.float32+moSep:<3}" y="{y.float32+moSep}"""" &
  """ width="{1-moSep*2}"""" &
  """ height="{1-moSep*2}"""" &
  """ rx="{moRadPx}"""" &
  """></rect>"""

const moRectGroupStart: string =
  """<g fill="{dark}" class="qrDark qrRounded qrModules">"""

const moRectGroupEnd: string =
  """</g>"""

const alRect: string =
  """<rect""" &
  """ x="{x}" y="{y}" width="{s}" height="{s}"""" &
  """ rx="{r}"></rect>"""

const alRectGroupStart: string =
  """<g class="qrRounded qrAlPatterns">"""

const alRectGroupEnd: string =
  """</g>"""

const alRectDarkGroupStart: string =
  """<g class="qrDark" fill="{dark}">"""

const alRectDarkGroupEnd: string =
  """</g>"""

const alRectLightGroupStart: string =
  """<g class="qrLight" fill="{light}">"""

const alRectLightGroupEnd: string =
  """</g>"""

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
    result.add fmt(moRectGroupStart)
    drawQRModulesOnly moRect
    result.add moRectGroupEnd
  else:
    result.add fmt(moPathStart)
    if alRad:
      drawQRModulesOnly moPath
    else:
      drawRegion 0'u8, size, 0'u8, size, moPath
    result.add fmt(moPathEnd)
  if alRad or forceUseRect:
    let alRadPx: float32 = 3.5 * alRad / 100
    template innerRadius(lvl: static range[0'i8..2'i8]): float32 =
      when lvl == 0: alRadPx
      else:
        if alRadPx == 0: 0f
        elif alRadPx-lvl <= 0: 1f / (lvl * 2)
        else: alRadPx-lvl
    func drawRoundedRect(x, y: uint8, s, r: float32): string = fmt(alRect)
    template drawAlPatterns(lvl: range[0'i8..2'i8], c: untyped) {.dirty.} =
      template s: float32 = 7-lvl*2
      template r: float32 = innerRadius(lvl)
      result.add fmt(`alRect c GroupStart`)
      result.add drawRoundedRect(0'u8+lvl, 0'u8+lvl, s, r)
      result.add drawRoundedRect(size-7'u8+lvl, 0'u8+lvl, s, r)
      result.add drawRoundedRect(0'u8+lvl, size-7+lvl, s, r)
      result.add `alRect c GroupEnd`
    result.add alRectGroupStart
    drawAlPatterns 0, dark
    drawAlPatterns 1, light
    drawAlPatterns 2, dark
    result.add alRectGroupEnd
  result.add svgEnd
