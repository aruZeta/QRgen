import QRgen/private/[QRCode, EncodedQRCode, DrawedQRCode, Drawing, qrTypes]

export QRCode.QRCode
export EncodedQRCode.EncodedQRCode
export DrawedQRCode.DrawedQRCode
export Drawing.Drawing, Drawing.DrawingPrint
export qrTypes

proc newQR*(data: string,
            mode: QRMode,
            version: QRVersion,
            ecLevel: QREcLevel = qrEcL
           ): DrawedQRCode =
  newQRCode(data, mode, version, ecLevel).encode.draw

proc newQR*(data: string,
            version: QRVersion,
            ecLevel: QREcLevel = qrEcL
           ): DrawedQRCode =
  newQRCode(data, version, ecLevel).encode.draw

proc newQR*(data: string,
            mode: QRMode,
            ecLevel: QREcLevel = qrEcL
           ): DrawedQRCode =
  newQRCode(data, mode, ecLevel).encode.draw

proc newQR*(data: string,
            ecLevel: QREcLevel = qrEcL
           ): DrawedQRCode =
  newQRCode(data, ecLevel).encode.draw

proc print*(self: DrawedQRCode, output: DrawingPrint) =
  self.drawing.print output
