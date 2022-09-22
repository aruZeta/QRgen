import
  "."/private/[DrawedQRCode/DrawedQRCode, Drawing],
  pkg/[pixie]

proc render(
  self: DrawedQRCode,
  pixelSize = 512,
  light: ColorRGB = rgb(255, 255, 255),
  dark: ColorRGB = rgb(0,0,0),
  centerImage: Image = newImage(0,0),
  centerImageBlendMode = NormalBlend
): Image =
  let ss = (pixelSize div self.drawing.size.int).float32
  let wh = vec2(ss.float, ss.float)
  let tmpPixelSize = (ss * self.drawing.size.float).ceil().int
  # var image = newImage(pixelSize, pixelSize)
  var image = newImage(tmpPixelSize, tmpPixelSize)
  image.fill(light)
  let ctx = newContext(image)
  ctx.fillStyle = dark
  ctx.strokeStyle = dark
  for yy in 0 ..< self.drawing.size.int:
    for xx in 0 ..< self.drawing.size.int:
      if self.drawing[xx.uint8, yy.uint8]:
        let pos = vec2((xx.float * ss).float, (yy.float * ss).float)
        ctx.fillRect(rect(pos, wh))
        # circles just for fun:
        # let re = rect(pos, wh)
        # ctx.fillCircle(Circle(pos: pos, radius: (ss.float / 1.5 ).float))
  var outputImg = newImage(pixelSize, pixelSize)
  outputImg.draw(image, scale(vec2( pixelSize / tmpPixelSize, pixelSize / tmpPixelSize )))
  if centerImage.width > 0 and centerImage.height > 0:
    let cpos = vec2(
      ((pixelSize / 2) - (centerImage.width / 2).float),
      ((pixelSize / 2) - (centerImage.height / 2).float),
    )
    outputImg.draw(centerImage, transform = translate(cpos), blendMode = centerImageBlendMode)
  return outputImg
