import
  "."/private/[DrawedQRCode/DrawedQRCode, Drawing],
  pkg/[pixie]

proc renderImg*(
  self: DrawedQRCode,
  light: string = "#ffffff",
  dark: string = "#000000",
  pixels: uint32 = 512,
  centerImage: Image = Image(width: 0, height: 0),
  centerImageBlendMode = NormalBlend
): Image =
  result = newImage(pixels.int, pixels.int)
  result.fill(light)
  let
    modules: uint8 = self.drawing.size + 10
    modulePixels: uint16 = (pixels div modules).uint16
    pixelsMargin: uint16 = (pixels mod modules).uint16 mod 2 + modulePixels * 5
    ctx = result.newContext
  ctx.fillStyle = dark
  ctx.strokeStyle = dark
  for y in 0'u8..<self.drawing.size:
    for x in 0'u8..<self.drawing.size:
      if self.drawing[x, y]:
        let pos = vec2(
          (pixelsMargin + x * modulePixels).float,
          (pixelsMargin + y * modulePixels).float
        )
        let size = vec2(modulePixels.float, modulePixels.float)
        ctx.fillRect(rect(pos, size))
        # circles just for fun:
        # let re = rect(pos, wh)
        # ctx.fillCircle(Circle(pos: pos, radius: (ss.float / 1.5 ).float))
  #var outputImg = newImage(pixels, pixelSize)
  #outputImg.draw(image, scale(vec2( pixels / tmpPixelSize, pixelSize / tmpPixelSize )))
  #if centerImage.width > 0 and centerImage.height > 0:
    #let cpos = vec2(
      #((pixels / 2) - (centerImage.width / 2).float),
      #((pixels / 2) - (centerImage.height / 2).float),
    #)
    #outputImg.draw(centerImage, transform = translate(cpos), blendMode = centerImageBlendMode)
  #return outputImg
