import QRgen
import QRgen/private/Drawing
import pixie
import print
import std/math
import options
# func rr(ff: float): float =


proc render(dr: DrawedQRCode, pixelSize = 512, light: string | ColorRGB = rgb(255, 255, 255),
    dark: string | ColorRGB = rgb(0,0,0), centerImage: Option[Image] = none[Image](), centerImageBlendMode = NormalBlend): Image =
  let ss = (pixelSize div dr.drawing.size.int).float32 # <- `div` = no lines but smaller img,   `/` = lines but good size
  let wh = vec2(ss.float, ss.float)
  print(pixelSize, dr.drawing.size, ss, wh)

  let tmpPixelSize = (ss * dr.drawing.size.float).ceil().int
  # var image = newImage(pixelSize, pixelSize)
  var image = newImage(tmpPixelSize, tmpPixelSize)


  image.fill(light)
  let ctx = newContext(image)
  ctx.fillStyle = dark
  ctx.strokeStyle = dark
  for yy in 0 ..< dr.drawing.size.int:
    for xx in 0 ..< dr.drawing.size.int:
      if dr.drawing[xx.uint8, yy.uint8]:
        let pos = vec2((xx.float * ss).float, (yy.float * ss).float)
        ctx.fillRect(rect(pos, wh))
        # circles just for fun:
        # let re = rect(pos, wh)
        # ctx.fillCircle(Circle(pos: pos, radius: (ss.float / 1.5 ).float))

  var outputImg = newImage(pixelSize, pixelSize)
  outputImg.draw(image, scale(vec2( pixelSize / tmpPixelSize, pixelSize / tmpPixelSize )))

  if isSome(centerImage):
    let cpos = vec2(
      ((pixelSize / 2) - (centerImage.get().width / 2).float),
      ((pixelSize / 2) - (centerImage.get().height / 2).float),
    )
    outputImg.draw(centerImage.get(), transform = translate(cpos), blendMode = centerImageBlendMode)
  return outputImg

when isMainModule:
  import os
  block:
    let urlQR = newQR("hallöäд")
    block:
      let img = urlQR.render()
      img.writeFile(getAppDir() / "img.png")
    block:
      let img = urlQR.render(64)
      img.writeFile(getAppDir() / "img2.png")

  block:
    let urlQR = newQR("https://nim-lang.org")
    block:
      let img = urlQR.render(light = "blue", dark = "#131313")
      img.writeFile(getAppDir() / "nl.png")
    block:
      let img = urlQR.render(64, light = "blue", dark = "#131313")
      img.writeFile(getAppDir() / "nl2.png")

  block:
    let urlQR = newQR("https://nim-lang.org")
    let centerImg = readImage(getAppDir() / ".." / "tests" / "pixie" / "QRgen_logo_small.png")
    let img = urlQR.render(centerImage = some(centerImg))
    img.writeFile(getAppDir() / "img_withImg.png")

  block:
    let urlQR = newQR("https://nim-lang.org")
    let centerImg = readImage(getAppDir() / ".." / "tests" / "pixie" / "QRgen_logo_small_white.png")
    let img = urlQR.render(centerImage = some(centerImg))
    img.writeFile(getAppDir() / "img_withImg2.png")

  block:
    let urlQR = newQR("https://nim-lang.org")
    let centerImg = readImage(getAppDir() / ".." / "tests" / "pixie" / "nimBadger.png")
    let img = urlQR.render(centerImage = some(centerImg))
    img.writeFile(getAppDir() / "img_withImg3.png")

  block:
    let urlQR = newQR("https://nim-lang.org", ecLevel = qrECH)
    let centerImg = readImage(getAppDir() / ".." / "tests" / "pixie" / "nimBadger.png")
    for bm in BlendMode:
      let img = urlQR.render(centerImage = some(centerImg), centerImageBlendMode = bm, light = "white", dark = "#FF0000")
      img.writeFile(getAppDir() / "img_withImg4_" & $bm & ".png")

  # import strutils
  # block:
  #   for idx in 500..510:
  #     let urlQR = newQR("a".repeat(idx))
  #     let centerImg = readImage(getAppDir() / ".." / "tests" / "pixie" / "nimBadger.png")
  #     let img = urlQR.render(centerImage = some(centerImg))
  #     img.writeFile(getAppDir() / "img_withImg5_" & $idx & ".png")
