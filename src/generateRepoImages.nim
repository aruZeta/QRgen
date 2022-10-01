# This file just generates images used in the README and logo

import
  "."/[QRgen, QRgen/renderer],
  std/[os],
  pkg/[pixie]

let qrL = newQR("https://github.com/aruZeta/QRgen")
let qrH = newQR("https://github.com/aruZeta/QRgen", ecLevel = qrECH)

func sharePath(p: string): string = "share" / "img" / p
func testsPath(p: string): string = "tests" / p
proc saveSvg(p: string, svg: string) = writeFile(sharePath p, svg)
proc savePng(p: string, img: Image) = writeFile(img, sharePath p)

## # Readme

## ## Svgs

saveSvg "svg-example.svg",qrL.printSvg()
saveSvg "svg-colors-example.svg",qrL.printSvg("#1d2021","#98971a")
saveSvg "svg-rounded-example.svg",qrL.printSvg("#1d2021","#98971a",60)
saveSvg "svg-very-rounded-example.svg",qrL.printSvg("#1d2021","#98971a",100,100,25)
saveSvg "svg-separation-example.svg",qrL.printSvg("#1d2021","#98971a",100,100,50)
saveSvg "svg-embed-example.svg",qrH.printSvg(
  "#1d2021","#fabd2f",100,100,25,
  svgImg=readFile(testsPath "testSvgInsert.svg")
)

## ## Pngs

savePng "png-example.png",qrL.renderImg()
savePng "png-colors-example.png",qrL.renderImg("#1d2021","#98971a")
savePng "png-rounded-example.png",qrL.renderImg("#1d2021","#98971a",60)
savePng "png-very-rounded-example.png",qrL.renderImg("#1d2021","#98971a",100,100,25)
savePng "png-separation-example.png",qrL.renderImg("#1d2021","#98971a",100,100,50)
savePng "png-embed-example.png",qrH.renderImg(
  "#1d2021","#fabd2f",100,100,25,
  img=readImage(testsPath "testPngInsert.png")
)

## # Logo

saveSvg "logo.svg", qrH.printSvg(
  "#1d2021","#fabd2f",100,100,25,
  svgImg=readFile(sharePath "logo-embed.svg")
)

let logoPng = qrH.renderImg(
  "#1d2021","#fabd2f",100,100,25,
  pixels=3840,
  img=readImage(sharePath "logo-embed.png")
)

savePng "logo.png", logoPng

var logoPngExtended = newImage(1280, 640)
logoPngExtended.fill("#1d2021")

logoPngExtended.newContext.drawImage(
  logoPng,
  640f32 / 2,
  0f32,
  640f32,
  640f32
)

savePng "logo-extended.png", logoPngExtended
