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
  """ fill="{dark}" x="{float(x)+0.1}" y="{float(y)+0.1}"""" &
  """ width="0.8" height="0.8" rx="{moRadPx:<.3}"></rect>"""

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

func roundedRect(x, y, w, h: uint8, r: float, m, c: string): string =
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

func printSvg*(
  self: DrawedQRCode,
  light: string = "#ffffff",
  dark: string = "#000000",
  class: string = "qrCode",
  id: string = ""
): string =
  ## Print a `DrawedQRCode` to svg format (returned as a string).
  ##
  ## .. note:: You can pass the hexadecimal color values `light` and `dark`,
  ##    which represent the background color and the dark module's color,
  ##    respectively. By default `light` is white (`#ffffff`) and `dark`
  ##    is black (`#000000`).
  ##
  ## .. note:: By default the `<svg>` tag class will be `qrCode`, this can be
  ##    changed by setting the `class` parameter; the `id` can also be set.
  ##    This makes it possible to change properties of the SVG via css.
  ##    The colors can also be changed with the classes `qrLight` and `qrDark`.
  result = fmt(svgHeader)
  result.add fmt(modulePathStart)
  drawRegion 0'u8, size, 0'u8, size, modulePath
  result.add fmt(modulePathEnd)
  result.add svgEnd

func printSvg*(
  self: DrawedQRCode,
  light = "#ffffff",
  dark = "#000000",
  alRad: range[0f32..100f32],
  class: string = "qrCode",
  id: string = ""
): string =
  ## Same as `print<#printSvg%2CDrawedQRCode%2Cstring%2Cstring>`_
  ## but with rounded alignment patterns determined by `alRad` which
  ## is a percentage (from `0.0` to `100.0`), being `0.0` a square and `100.0`
  ## a perfect circle.
  ##
  ## .. note:: The alignment pattern will be drawn using a `<rect>` with
  ##    classes `qrRounded` and `qrAlignment`. The rect will also have
  ##    `qrLight` or `qrDark` depending on it's background color.
  result = fmt(svgHeader)
  let alRadPx: float32 = 3.5 * alRad / 100
  result.add fmt(modulePathStart)
  drawRegionWithoutAlPatterns modulePath
  result.add fmt(modulePathEnd)
  drawRoundedAlignmentPatterns
  result.add svgEnd

func printSvg*(
  self: DrawedQRCode,
  light = "#ffffff",
  dark = "#000000",
  alRad: range[0f32..100f32],
  moRad: range[0f32..100f32],
  class: string = "qrCode",
  id: string = ""
): string =
  ## Same as `print<#printSvg%2CDrawedQRCode%2Cstring%2Cstring%2Crange[]>`_
  ## but with rounded modules determined by `moRad` which is a percentage
  ## (from `0.0` to `100.0`), being `0.0` a square and `100.0` a perfect circle.
  ##
  ## .. note:: The modules will be drawn using a `<rect>` with
  ##    classes `qrRounded` and `qrModule`. The rect will also have
  ##    `qrLight` or `qrDark` depending on it's background color.
  result = fmt(svgHeader)
  let
    alRadPx: float32 = 3.5 * alRad / 100
    moRadPx: float32 = 0.4 * moRad / 100
  drawRegionWithoutAlPatterns moduleRect
  drawRoundedAlignmentPatterns
  result.add svgEnd
