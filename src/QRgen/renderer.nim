import
  "."/private/[
    DrawedQRCode/DrawedQRCode,
    DrawedQRCode/print,
    Drawing,
    qrTypes
  ],
  pkg/[pixie]

template size: uint8 =
  ## Helper template to get the size of the passed `DrawedQRCode`'s `drawing`.
  self.drawing.size

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

proc renderImg*(
  self: DrawedQRCode,
  light: string = "#ffffff",
  dark: string = "#000000",
  pixels: uint32 = 512,
  alRad: Percentage = 0,
  moRad: Percentage = 0,
  moSep: Percentage = 25,
  img: Image = Image(width: 0, height: 0),
  imgCoords: tuple[x, y, w, h: uint8] = self.genDefaultCoords
): Image =
  let
    modules: uint8 = self.drawing.size + 10
    modulePixels: uint16 = (pixels div modules).uint16
    pixelsMargin: uint16 = (pixels mod modules).uint16 div 2 + modulePixels*5
    actualSize: uint32 = modulePixels.uint32*(modules-10) + (pixelsMargin+1)*2
  let pixels: uint32 =
    if actualSize < pixels: actualSize
    else: pixels
  result = newImage(pixels.int, pixels.int)
  result.fill(light)
  let ctx: Context = result.newContext
  ctx.fillStyle = dark
  ctx.strokeStyle = dark
  template calcPos(modulePos: uint8): float32 =
    (pixelsMargin + modulePos * modulePixels).float32
  template drawRegion(ax, bx, ay, by: uint8, f: untyped) {.dirty.} =
    for y in ay..<by:
      for x in ax..<bx:
        if self.drawing[x, y]:
          let pos = vec2(x.calcPos + moSepPx, y.calcPos + moSepPx)
          f
  template drawQRModulesOnly(f: untyped) {.dirty.} =
    drawRegion 0'u8, size, 7'u8, size-7, f
    drawRegion 7'u8, size-7, 0'u8, 7'u8, f
    drawRegion 7'u8, size, size-7, size, f
  if moRad > 0:
    let
      moSepPx: float32 = modulePixels.float32 * 0.4 * moSep / 100
      s: Vec2 = vec2(
        modulePixels.float32 - moSepPx*2,
        modulePixels.float32 - moSepPx*2
      )
      moRadPx: float32 = (modulePixels.float32 / 2 - moSepPx) * moRad / 100
    drawQRModulesOnly ctx.fillRoundedRect(rect(pos, s), moRadPx)
  else:
    let
      moSepPx: float32 = 0
      s: Vec2 = vec2(
        modulePixels.float32,
        modulePixels.float32
      )
    if alRad > 0:
      drawQRModulesOnly ctx.fillRect(rect(pos, s))
    else:
      drawRegion 0'u8, size, 0'u8, size, ctx.fillRect(rect(pos, s))
  if alRad > 0 or moRad > 0:
    let alRadPx: float32 = modulePixels.float32 * 3.5 * alRad / 100
    template innerRadius(lvl: static range[0'i8..2'i8]): float32 =
      when lvl == 0: alRadPx
      else:
        if alRadPx == 0: 0f
        elif alRadPx-lvl <= 0: 1f / (lvl * 2)
        else: alRadPx-lvl
    template drawAlPatterns(lvl: range[0'i8..2'i8], c: untyped) {.dirty.} =
      template s1: float32 = ((7-lvl*2) * modulePixels).float32
      template s: Vec2 {.dirty.} = vec2(s1, s1)
      template r: float32 = innerRadius(lvl)
      template vec2F(a, b: untyped): Vec2 = vec2(a.calcPos, b.calcPos)
      when c == "light":
        ctx.fillStyle = light
        ctx.strokeStyle = light
      ctx.fillRoundedRect rect(vec2F(0'u8+lvl, 0'u8+lvl), s), r
      ctx.fillRoundedRect rect(vec2F(size-7'u8+lvl, 0'u8+lvl), s), r
      ctx.fillRoundedRect rect(vec2F(0'u8+lvl, size-7+lvl), s), r
      when c == "light":
        ctx.fillStyle = dark
        ctx.strokeStyle = dark
    drawAlPatterns 0, "dark"
    drawAlPatterns 1, "light"
    drawAlPatterns 2, "dark"
  if img.width > 0 and img.height > 0:
    template calc(n: uint8): float32 = (n * modulePixels).float32
    ctx.drawImage(
      img,
      (calc imgCoords.x) + pixelsMargin.float32,
      (calc imgCoords.y) + pixelsMargin.float32,
      calc imgCoords.w,
      calc imgCoords.h
    )
