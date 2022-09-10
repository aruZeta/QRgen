import
  "."/[myTestSuite],
  QRgen,
  std/[os]

benchmarkTest "Minimal test":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  qr.printTerminal

benchmarkTest "Emojis in byte mode (utf-8)":
  let qr = newQR("https://github.com/aruZeta/QRgen 😀")
  qr.printTerminal

benchmarkTest "Testing svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingSvg.svg",
    qr.printSvg
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
    qr.printSvg("#1d2021", "#98971a", alRad = 60)
  )

benchmarkTest "Testing very rounded svg":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    "build" / "testingVeryRoundedSvg.svg",
    qr.printSvg("#1d2021", "#98971a", alRad = 100, moRad = 100)
  )
