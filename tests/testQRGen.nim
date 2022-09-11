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
    "build" / "testingSvg.svg",
    qr.printSvg("#1d2021", "#98971a")
  )

benchmarkTest "Testing rounded svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingRoundedSvg.svg",
    qr.printSvg("#1d2021", "#98971a", alRad = 2)
  )

benchmarkTest "Testing very rounded svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingVeryRoundedSvg.svg",
    qr.printSvg("#1d2021", "#98971a", alRad = 3.5, moRad = 0.4)
  )

