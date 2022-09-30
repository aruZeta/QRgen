import
  "."/[myTestSuite],
  QRgen,
  std/[os]

template mayPrintTerminal(self: DrawedQRCode) =
  when not defined(benchmark):
    self.printTerminal

benchmarkTest "Minimal test":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  qr.mayPrintTerminal

benchmarkTest "Emojis in byte mode (utf-8)":
  let qr = newQR("https://github.com/aruZeta/QRgen 😀")
  qr.mayPrintTerminal

benchmarkTest "Testing svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingSvg.svg",
    qr.printSvg
  )

benchmarkTest "Testing custom class and id svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingCustomClassIdSvg.svg",
    qr.printSvg(class = "myCustomQR", id = "qr1")
  )

benchmarkTest "Testing svg with colors":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingColoredSvg.svg",
    qr.printSvg("#1d2021", "#98971a")
  )

benchmarkTest "Testing rounded svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingRoundedSvg.svg",
    qr.printSvg("#1d2021", "#98971a", alRad = 60)
  )

benchmarkTest "Testing very rounded svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingVeryRoundedSvg.svg",
    qr.printSvg("#1d2021", "#98971a", 100, 100, 25)
  )

benchmarkTest "Testing separation":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingSeparation.svg",
    qr.printSvg("#1d2021", "#98971a", alRad = 100, moSep = 12.5)
  )
  writeFile(
    "build" / "testingSeparation2.svg",
    qr.printSvg("#1d2021", "#98971a", 100, 50, 12.5)
  )
  writeFile(
    "build" / "testingSeparation3.svg",
    qr.printSvg("#1d2021", "#98971a", 100, 100, 12.5)
  )
  writeFile(
    "build" / "testingSeparation4.svg",
    qr.printSvg("#1d2021", "#98971a", 100, 100, 50)
  )
  writeFile(
    "build" / "testingSeparation5.svg",
    qr.printSvg("#1d2021", "#98971a", 100, 100, 100)
  )
  writeFile(
    "build" / "testingSeparation6.svg",
    qr.printSvg("#1d2021", "#98971a", forceUseRect = true)
  )

benchmarkTest "Testing svg insertion":
  let qr = newQR("https://github.com/aruZeta/QRgen", ecLevel = qrECH)
  writeFile(
    "build" / "testingSvgInsertion.svg",
    qr.printSvg(
      "#1d2021", "#fabd2f",
      100, 100, 25,
      svgImg = readFile("tests" / "testSvgInsert.svg")
    )
  )
  let qr2 = newQR("https://github.com/aruZeta/QRgen", ecLevel = qrECQ)
  writeFile(
    "build" / "testingSvgInsertion2.svg",
    qr2.printSvg(
      "#1d2021", "#fabd2f",
      100, 100, 25,
      svgImg = readFile("tests" / "testSvgInsert.svg")
    )
  )
  let qr3 = newQR("https://github.com/aruZeta/QRgen", ecLevel = qrECM)
  writeFile(
    "build" / "testingSvgInsertion3.svg",
    qr3.printSvg(
      "#1d2021", "#fabd2f",
      100, 100, 25,
      svgImg = readFile("tests" / "testSvgInsert.svg")
    )
  )
  let qr4 = newQR("https://github.com/aruZeta/QRgen", ecLevel = qrECL)
  writeFile(
    "build" / "testingSvgInsertion4.svg",
    qr4.printSvg(
      "#1d2021", "#fabd2f",
      100, 100, 25,
      svgImg = readFile("tests" / "testSvgInsert.svg")
    )
  )
