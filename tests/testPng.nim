import
  "."/[myTestSuite],
  QRgen,
  QRgen/png,
  std/[os],
  pkg/[pixie]

benchmarkTest "Testing png":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  qr.renderImg().writeFile("build" / "testingPng.png")

benchmarkTest "Testing png with colors":
  let qr = newQR("https://github.com/aruZeta/QRgen")
  qr.renderImg("#1d2021", "#98971a").writeFile("build" / "testingColoredPng.png")
