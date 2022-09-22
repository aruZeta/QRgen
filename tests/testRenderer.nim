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

benchmarkTest "Testing rounded alignment patterns":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg("#1d2021", "#98971a", alRad = 100),
    "build" / "testingRoundedAlPatterns.png"
  )

benchmarkTest "Testing rounded modules":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg("#1d2021", "#98971a", moRad = 100),
    "build" / "testingRoundedModulesPng.png"
  )

benchmarkTest "Testing very rounded png":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg("#1d2021", "#98971a", alRad = 100, moRad = 100),
    "build" / "testingVeryRoundedPng.png"
  )

benchmarkTest "Testing separation":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  writeFile(
    qr.renderImg("#1d2021", "#98971a", moRad = 100, moSep = 50),
    "build" / "testingSeparationPng.png"
  )
