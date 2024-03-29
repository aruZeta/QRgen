## # The main QRgen API
##
## The main QRgen API provides a single procedure to create qr codes, `newQR`
## and another procedure to print them to an output format, `print`.
##
## It does also provide the required Types and Defects you may need to
## store the result of both procedures or to pass them arguments.
## You can find those in the `export section<#19>`_.
##
## Check
## `the print module<QRgen/private/DrawedQRCode/print.html#12>`_
## to learn about all print options.
##
## Check
## `the renderer module<QRgen/renderer.html#12>`_
## to learn about rendering QR codes into pixie's `Image` objectsn which can
## be rendered to PNG and other formats.
##
## # Usage example
##
## Here is a basic example to generate a QR code of an URL and show it
## in your terminal:

runnableExamples:
  let urlQR = newQR("https://my-url.domain")
  urlQR.printTerminal

import
  QRgen/private/[
    DrawedQRCode/DrawedQRCode,
    DrawedQRCode/print,
    EncodedQRCode/EncodedQRCode,
    QRCode,
    qrTypes
  ]

export
  DrawedQRCode.DrawedQRCode,
  print,
  QRCode.DataSizeDefect,
  qrTypes

proc newQR*(
  data: string,
  ecLevel: QRECLevel = qrECL,
  mode: QRMode = data.getMostEfficientMode,
  version: QRVersion = data.getSmallestVersion(mode, ecLevel),
): DrawedQRCode =
  ## Creates a new `DrawedQRCode` object with the specified `data`, `ecLevel`,
  ## `mode` and `version`.
  ##
  ## .. note:: By default `mode` will be the most efficient mode to encode
  ##    `data`, `version` will be the smallest QR version where `data` can
  ##    fit, and `version` will be the lowest level.
  newQRCode(data, ecLevel, mode, version).encode.draw
