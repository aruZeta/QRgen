import
  "."/[myTestSuite],
  QRgen,
  QRgen/renderer,
  std/[os],
  pkg/[pixie]

benchmarkTest "Testing png":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg(),
    "build" / "testingPng.png"
  )

benchmarkTest "Testing png with less pixels":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg(pixels = 100),
    "build" / "testingPng2.png"
  )

benchmarkTest "Testing png with colors":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg("#1d2021", "#98971a"),
    "build" / "testingColoredPng.png"
  )

benchmarkTest "Testing rounded modules":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg("#1d2021", "#98971a", moRad = 100),
    "build" / "testingRoundedModulesPng.png"
  )
