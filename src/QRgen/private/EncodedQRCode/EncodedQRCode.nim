## # EncodedQRCode implementation
##
## This module implements an object to hold the result of encoding a
## `QRCode`'s `data`.
##
## The main procedures are spread around all the modules in this directory,
## which you can find in the `import section<#6>`_.

import
  "."/[encodeDataCodewords, encodeECCodewords, encodeIndicators,
       interleaveDataCodewords, interleaveECCodewords, type
  ],
  ".."/[QRCode]

export
  type

proc encode*(qr: QRCode): EncodedQRCode =
  ## Return an `EncodedQRCode` from the passed `QRCode`.
  result = newEncodedQRCode qr
  result.encodeModeIndicator
  result.encodeCharCountIndicator qr.data
  result.encodeDataCodewords qr.data
  result.finishDataEncoding
  result.encodeECCodewords
  result.interleaveDataCodewords
  result.interleaveECCodewords

proc encodeOnly*(qr: QRCode): EncodedQRCode =
  ## The same as `encode` but without interleaving.
  ## Meant for testing.
  result = newEncodedQRCode qr
  result.encodeModeIndicator
  result.encodeCharCountIndicator qr.data
  result.encodeDataCodewords qr.data
  result.finishDataEncoding
  result.encodeECCodewords
