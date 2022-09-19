import
  "."/[type],
  ".."/[Drawing, qrTypes],
  std/[strformat]

when defined(js):
  import
    std/[jsconsole]

template size: uint8 =
  ## Helper template to get the size of the passed `DrawedQRCode`'s `drawing`.
  self.drawing.size

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
  """ x="{x.float32+moSepPx:<3}" y="{y.float32+moSepPx}"""" &
  """ width="{1-moSepPx*2}"""" &
  """ height="{1-moSepPx*2}"""" &
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

const svgEmbedStart: string =
  """<image""" &
  """ x="{svgImgCoords.x}"""" &
  """ y="{svgImgCoords.y}"""" &
  """ width="{svgImgCoords.w}"""" &
  """ height="{svgImgCoords.h}"""" &
  """ href="data:image/svg+xml,"""

const svgEmbedEnd: string =
  """"/>"""

type
  Percentage = range[0f32..100f32]
    ## A value between `0` and `100` (inclusive).

func genDefaultCoords(self: DrawedQRCode): tuple[x,y,w,h: uint8] =
  let size: uint8 = (self.drawing.size div (
    case self.ecLevel
    of qrECL: 24
    of qrECM: 12
    of qrECQ: 6
    of qrECH: 3
  ) div 2) * 2 + 1
  let margin: uint8 = (self.drawing.size - size) div 2
  result = (
    x: margin,
    y: margin,
    w: size,
    h: size
  )

func encodeSvgEmbed(result: var string, svgImg: string) =
  for i in 0..<svgImg.len:
    case svgImg[i]
    of '<': result.add "%3c"
    of '>': result.add "%3e"
    of '"': result.add '\''
    of '\'': result.add "%27"
    of '#': result.add "%23"
    of ',': result.add "%2c"
    of ';': result.add "%3b"
    of ' ':
      if svgImg[i-1] != ' ':
        result.add ' '
    of '\c', '\l': discard
    else: result.add svgImg[i]

func printSvg*(
  self: DrawedQRCode,
  light = "#ffffff",
  dark = "#000000",
  alRad: Percentage = 0,
  moRad: Percentage = 0,
  moSep: Percentage = 25,
  class: string = "qrCode",
  id: string = "",
  forceUseRect: bool = false,
  svgImg: string = "",
  svgImgCoords: tuple[x, y, w, h: uint8] = self.genDefaultCoords
): string =
  ## Print a `DrawedQRCode` in SVG format (returned as a `string`).
  ##
  ## .. note:: You can pass the hexadecimal color values light and dark,
  ##    which represent the background color and the dark module's color,
  ##    respectively. By default light is white (`#ffffff`) and dark is black
  ##    (`#000000`).
  ##
  ## .. note:: You can make the alignment patterns circles by passing `alRad`,
  ##    and the modules by passing `moRad`. These values are a `Percentage`, a
  ##    value between `0` and `100` (inclusive) which determines the roundness,
  ##    `0` being a square and `100` a perfect circle. By default these are set
  ##    to `0`.
  ##
  ## .. note:: When the roundness of both alignment patterns and modules is
  ##    `0`, both will be drawed in the same `<path>`; if only the modules
  ##    roundness is set `0`, those will be drawed in a `<path>` and the
  ##    alignment patterns with a `<rect>`; if both are not `0` then both will
  ##    be drawed using `<rect>`. If you want to draw both with `<rect>` even
  ##    if they have roundness set to `0`, you need to set `forceUseRect` to
  ##    `true`.
  ##
  ## .. note:: Modules drawed as a rect have a separation from each other
  ##    specified by `moSep`, which is a `Percentage`, a value between `0`
  ##    and `100` (inclusive) which determines the separation, `0` being no
  ##    separation and `100` making the modules minuscule. By default it is
  ##    `25` (0.1 separation on a 1 width module, making it have 0.8 width).
  ##
  ## .. note:: You can pass a custom id and class to set to `<svg>`, by default
  ##    the class is `qrCode`, depending on the color a tag will have `qrLight`
  ##    or `qrDark`, `<rect>` will have `qrRounded`, a tag drawing modules
  ##    `qrModules`, a tag drawing alignment patterns `qrAlPatterns`.
  ##
  ## .. note:: `<rect>` will be grouped inside a `<g>` which will set the
  ##    classes and fill color.
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
  let moSepPx: float32 = 0.4 * moSep / 100
  if moRad > 0 or forceUseRect:
    let moRadPx: float32 = (0.5 - moSepPx) * moRad / 100
    result.add fmt(moRectGroupStart)
    drawQRModulesOnly moRect
    result.add moRectGroupEnd
  else:
    result.add fmt(moPathStart)
    if alRad > 0:
      drawQRModulesOnly moPath
    else:
      drawRegion 0'u8, size, 0'u8, size, moPath
    result.add fmt(moPathEnd)
  if alRad > 0 or forceUseRect:
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
  if svgImg.len > 0:
    result.add fmt(svgEmbedStart)
    result.encodeSvgEmbed svgImg
    result.add svgEmbedEnd
  result.add svgEnd
