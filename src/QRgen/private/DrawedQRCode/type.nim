import
  ".."/[Drawing, EncodedQRCode/EncodedQRCode, qrTypes]

type
  DrawedQRCode* = object
    version*: QRVersion
    ecLevel*: QRECLevel
    mask*: range[0'u8..7'u8]
    drawing*: Drawing

proc newDrawedQRCode*(version: QRVersion,
                      ecLevel: QRECLevel = qrECL
                     ): DrawedQRCode =
  DrawedQRCode(version: version,
               ecLevel: ecLevel,
               drawing: newDrawing((version - 1) * 4 + 21))

proc newDrawedQRCode*(qr: EncodedQRCode): DrawedQRCode =
  DrawedQRCode(version: qr.version,
               ecLevel: qr.ecLevel,
               drawing: newDrawing((qr.version - 1) * 4 + 21))
