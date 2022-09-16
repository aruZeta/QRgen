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
    qr.printSvg("#1d2021", "#98971a", alRad = 100, moRad = 100)
  )

benchmarkTest "Testing separation":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingSeparation.svg",
    qr.printSvg(
      "#1d2021", "#98971a",
      alRad = 100,
      moRad = 0,
      forceUseRect = true,
      moSep = 12.5
    )
  )
  writeFile(
    "build" / "testingSeparation2.svg",
    qr.printSvg(
      "#1d2021", "#98971a",
      alRad = 100,
      moRad = 50,
      moSep = 12.5
    )
  )
  writeFile(
    "build" / "testingSeparation3.svg",
    qr.printSvg(
      "#1d2021", "#98971a",
      alRad = 100,
      moRad = 100,
      moSep = 12.5
    )
  )
  writeFile(
    "build" / "testingSeparation4.svg",
    qr.printSvg(
      "#1d2021", "#98971a",
      alRad = 100,
      moRad = 100,
      moSep = 50
    )
  )
  writeFile(
    "build" / "testingSeparation5.svg",
    qr.printSvg(
      "#1d2021", "#98971a",
      alRad = 100,
      moRad = 100,
      moSep = 100
    )
  )
