import myTestSuite
import QRgen

benchmarkTest "Minimal test":
  let qr = newQR("Hello world!")
  qr.print dpTerminal
