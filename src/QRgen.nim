import QRgen/private/[QRCode, EncodedQRCode, DrawedQRCode, Drawing, qrTypes]

export QRCode.DataSizeDefect
export DrawedQRCode.DrawedQRCode
export Drawing.DrawingPrint
export qrTypes

proc newQR*(data: string,
            mode: QRMode,
            version: QRVersion,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  newQRCode(data, mode, version, ecLevel).encode.draw

proc newQR*(data: string,
            version: QRVersion,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  newQRCode(data, version, ecLevel).encode.draw

proc newQR*(data: string,
            mode: QRMode,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  newQRCode(data, mode, ecLevel).encode.draw

proc newQR*(data: string,
            ecLevel: QRECLevel = qrECL
           ): DrawedQRCode =
  newQRCode(data, ecLevel).encode.draw

proc print*(self: DrawedQRCode, output: DrawingPrint) =
  self.drawing.print output
