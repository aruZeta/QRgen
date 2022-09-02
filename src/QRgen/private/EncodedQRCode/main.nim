import
  "."/[EncodedQRCode, encodeDataCodewords, encodeECCodewords,
       encodeIndicators, interleaveDataCodewords, interleaveECCodewords],
  ".."/[QRCode]

export
  EncodedQRCode

proc encode*(qr: QRCode): EncodedQRCode =
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
  ## Meant for testing
  result = newEncodedQRCode qr
  result.encodeModeIndicator
  result.encodeCharCountIndicator qr.data
  result.encodeDataCodewords qr.data
  result.finishDataEncoding
  result.encodeECCodewords
