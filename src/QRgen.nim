## # The main QRgen API
##
## The main QRgen API provides a single procedure to create qr codes, `newQR`
## and another procedure to print them to an output format, `print`.
##
## It does also provide the required Types and Defects you may need to
## store the result of both procedures or to pass them arguments.
## You can find those in the `export section<#19>`_.
##
## # Usage example
##
## Here is a basic example to generate a QR code of an URL and show it
## in your terminal:

runnableExamples:
  let urlQR = newQR("https://my-url.domain")
  urlQR.printTerminal

import QRgen/private/[QRCode, EncodedQRCode, DrawedQRCode, Drawing, qrTypes]

export QRCode.DataSizeDefect
export DrawedQRCode.DrawedQRCode
export qrTypes

proc newQR*(data: string,
            mode: QRMode,
            version: QRVersion,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  ## Create a new DrawedQRCode with the specified `mode`, `version` and
  ## `ecLevel` (`qrECL` by default).
  ##
  ## .. note:: The mode is not checked so make sure to use the correct one.
  ##    It's recommended to use another proc which sets the mode automatically
  ##    unless you know what you are doing.
  ##
  ## .. note:: The data size is checked to see if it fits in the specified
  ##    version and ecLevel.
  newQRCode(data, mode, version, ecLevel).encode.draw

proc newQR*(data: string,
            version: QRVersion,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  ## Create a new DrawedQRCode with the specified `version` and `ecLevel`
  ## (`qrECL` by default).
  ##
  ## .. note:: The data size is checked to see if it fits in the specified
  ##    version and ecLevel.
  newQRCode(data, version, ecLevel).encode.draw

proc newQR*(data: string,
            mode: QRMode,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  ## Create a new DrawedQRCode with the specified `mode` and `ecLevel`
  ## (`qrECL` by default).
  ##
  ## .. note:: The mode is not checked so make sure to use the correct one.
  ##    It's recommended to use another proc which sets the mode automatically
  ##    unless you know what you are doing.
  newQRCode(data, mode, ecLevel).encode.draw

proc newQR*(data: string,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  ## Create a new DrawedQRCode with the specified `ecLevel`
  ## (`qrECL` by default).
  newQRCode(data, ecLevel).encode.draw

proc printTerminal*(self: DrawedQRCode) =
  ## Print a `DrawedQRCode` to the terminal using `stdout`.
  self.drawing.printTerminal

proc printSvg*(self: DrawedQRCode,
               light = "#ffffff",
               dark = "#000000"
              ): string =
  ## Print a `DrawedQRCode` to svg format (returned as a string).
  ##
  ## .. note:: You can pass the hexadecimal color values `light` and `dark`,
  ##    which represent the background color and the dark module's color,
  ##    respectively. By default `light` is white (#ffffff) and `dark`
  ##    is black (#000000).
  ##
  ## .. note:: The svg can be changed via css with the class `QRcode`, while
  ##    the colors can also be changed with the classes `QRlight` and `QRdark`.
  self.drawing.printSvg light, dark

proc printRoundedSvg*(self: DrawedQRCode,
                      light = "#ffffff",
                      dark = "#000000",
                      radius: range[0f..3.5f] = 3f
                     ): string =
  ## Same as `DrawedQRCode<#printSvg%2CDrawing%2Cstring%2Cstring>`_
  ## but with rounded alignment patterns determined by `radius` which
  ## can be from `0` (a square) up to `3.5`, which would make it a perfect
  ## circle.
  self.drawing.printRoundedSvg light, dark, radius
