import
  "."/[type],
  ".."/[Drawing],
  std/[strformat]

proc printTerminal*(self: DrawedQRCode) =
  ## Print a `DrawedQRCode` to the terminal using `stdout`.
  stdout.write "\n\n\n\n\n"
  for y in 0'u8..<self.drawing.size:
    stdout.write "          "
    for x in 0'u8..<self.drawing.size:
      stdout.write(
        if self.drawing[x, y]: "██"
        else: "  "
      )
    stdout.write "\n"
  stdout.write "\n\n\n\n\n"

const svgHeader: string =
  # SVG tag start
  """<svg class="QRcode" version="1.1"""" &
  """ xmlns="http://www.w3.org/2000/svg"""" &
  """ viewBox="-5 -5 {tSize} {tSize}">""" &
  # Background of the SVG
  """<path class="QRlight" fill="{light}"""" &
  """ d="M-5,-5h{tSize}v{tSize}h-{tSize}Z"></path>"""

const modulePath: string =
  """M{x},{y}h1v1h-1Z"""

const moduleRect: string =
  """<rect class="QRdark QRrounded QRmodule"""" &
  """ fill="{dark}" x="{float(x)+0.1}" y="{float(y)+0.1}"""" &
  """ width="0.8" height="0.8" rx="{moRad:<.3}"></rect>"""

const alignmentPatternRect: string =
  """<rect class="QR{m} QRrounded QRalignment"""" &
  """ fill="{c}" x="{x}" y="{y}" width="{w}" height="{h}"""" &
  """ rx="{r:<.3}"></rect>"""

proc printSvg*(self: DrawedQRCode,
               light: string = "#ffffff",
               dark: string = "#000000"
              ): string =
  ## Print a `DrawedQRCode` to svg format (returned as a string).
  ##
  ## .. note:: You can pass the hexadecimal color values `light` and `dark`,
  ##    which represent the background color and the dark module's color,
  ##    respectively. By default `light` is white (`#ffffff`) and `dark`
  ##    is black (`#000000`).
  ##
  ## .. note:: The svg can be changed via css with the class `QRcode`, while
  ##    the colors can also be changed with the classes `QRlight` and `QRdark`.
  template tSize: uint8 = self.drawing.size + 10
  result = fmt(svgHeader)
  # Path drawing the dark modules
  result.add fmt"""<path class="QRdark" fill="{dark}" d=""""
  for y in 0'u8..<self.drawing.size:
    for x in 0'u8..<self.drawing.size:
      if self.drawing[x, y]: result.add fmt(modulePath)
  # Close the dark modules path and svg tag
  result.add "\"></path></svg>"

proc printSvg*(self: DrawedQRCode,
               light = "#ffffff",
               dark = "#000000",
               alRad: range[0f32..3.5f32]
              ): string =
  ## Same as `print<#printSvg%2CDrawedQRCode%2Cstring%2Cstring>`_
  ## but with rounded alignment patterns determined by `alRad` which
  ## can be from `0` (a square) up to `3.5`, which would make it a perfect
  ## circle.
  template tSize: uint8 = self.drawing.size + 10
  result = fmt(svgHeader)
  # Path drawing the dark modules
  result.add fmt"""<path class="QRdark" fill="{dark}" d=""""
  template drawRegion(ax, bx, ay, by: uint8) {.dirty.} =
    for y in ay..<by:
      for x in ax..<bx:
        if self.drawing[x, y]:
          result.add fmt(modulePath)
  drawRegion 0'u8, self.drawing.size, 7'u8, self.drawing.size-7
  drawRegion 7'u8, self.drawing.size-7, 0'u8, 7'u8
  drawRegion 7'u8, self.drawing.size, self.drawing.size-7, self.drawing.size
  result.add "\"></path>"
  proc roundedRect(x, y, w, h: uint8, r: float, m, c: string): string =
    fmt(alignmentPatternRect)
  template checkRadius(lvl: range[1'i8..2'i8]): float =
    if alRad == 0: 0f
    elif alRad-lvl <= 0: 1f / (lvl * 2)
    else: alRad-lvl
  template roundedAlignmentPattern(x, y: uint8): string =
    roundedRect(x, y, 7'u8, 7'u8, alRad, "dark", dark) &
    roundedRect(x+1, y+1, 5'u8, 5'u8, checkRadius 1, "light", light) &
    roundedRect(x+2, y+2, 3'u8, 3'u8, checkRadius 2, "dark", dark)
  result.add roundedAlignmentPattern(0'u8, 0'u8)
  result.add roundedAlignmentPattern(self.drawing.size-7, 0'u8)
  result.add roundedAlignmentPattern(0'u8, self.drawing.size-7)
  result.add "</svg>"

proc printSvg*(self: DrawedQRCode,
               light = "#ffffff",
               dark = "#000000",
               alRad: range[0f32..3.5f32],
               moRad: range[0f32..0.4f32]
              ): string =
  ## Same as `print<#printSvg%2CDrawedQRCode%2Cstring%2Cstring%2Crange[]>`_
  ## but with with rounded modules determined by `moRad` which can be
  ## from `0` (a square) up to `0.4`, which would make it a perfect circle.
  template tSize: uint8 = self.drawing.size + 10
  result = fmt(svgHeader)
  # Path drawing the dark modules
  template drawRegion(ax, bx, ay, by: uint8) {.dirty.} =
    for y in ay..<by:
      for x in ax..<bx:
        if self.drawing[x, y]:
          result.add fmt(moduleRect)
  drawRegion 0'u8, self.drawing.size, 7'u8, self.drawing.size-7
  drawRegion 7'u8, self.drawing.size-7, 0'u8, 7'u8
  drawRegion 7'u8, self.drawing.size, self.drawing.size-7, self.drawing.size
  proc roundedRect(x, y, w, h: uint8, r: float, m, c: string): string =
    fmt(alignmentPatternRect)
  template checkRadius(lvl: range[1'i8..2'i8]): float =
    if alRad == 0: 0f
    elif alRad-lvl <= 0: 1f / (lvl * 2)
    else: alRad-lvl
  template roundedAlignmentPattern(x, y: uint8): string =
    roundedRect(x, y, 7'u8, 7'u8, alRad, "dark", dark) &
    roundedRect(x+1, y+1, 5'u8, 5'u8, checkRadius 1, "light", light) &
    roundedRect(x+2, y+2, 3'u8, 3'u8, checkRadius 2, "dark", dark)
  result.add roundedAlignmentPattern(0'u8, 0'u8)
  result.add roundedAlignmentPattern(self.drawing.size-7, 0'u8)
  result.add roundedAlignmentPattern(0'u8, self.drawing.size-7)
  result.add "</svg>"
