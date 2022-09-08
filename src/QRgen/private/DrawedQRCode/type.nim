import
  ".."/[Drawing, EncodedQRCode/EncodedQRCode, qrTypes]

type
  Mask* = range[0'u8..7'u8]

  DrawedQRCode* = object
    ## An object holding the drawing of a `EncodedQRCode`, `drawing`, the
    ## rest of it's information: `version` and `ecLevel`, and the mask which
    ## was used to draw it `mask`.
    version*: QRVersion
    ecLevel*: QRECLevel
    mask*: Mask
    drawing*: Drawing

proc newDrawedQRCode*(version: QRVersion,
                      ecLevel: QRECLevel = qrECL
                     ): DrawedQRCode =
  ## Creates a new `DrawedQRCode` object with the specified `version` and
  ## `ecLevel`.
  DrawedQRCode(version: version,
               ecLevel: ecLevel,
               drawing: newDrawing((version - 1) * 4 + 21))

proc newDrawedQRCode*(qr: EncodedQRCode): DrawedQRCode =
  ## Creates a new `DrawedQRCode` from an exisiting `EncodedQRCode` object.
  DrawedQRCode(version: qr.version,
               ecLevel: qr.ecLevel,
               drawing: newDrawing((qr.version - 1) * 4 + 21))
