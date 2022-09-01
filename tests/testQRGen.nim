import myTestSuite
import QRgen

benchmarkTest "Minimal test":
  let qr = newQR("Hello world!")
  qr.printTerminal

benchmarkTest "Testing svg":
  let qr = newQR("Hello world!")
  echo qr.printSvg
