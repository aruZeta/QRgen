import
  # Outter modules
  ../BitArray, ../QRCode, ../qrCapacities, ../qrTypes

type
  EncodedQRCode* = object
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QRECLevel
    data*: BitArray

proc newEncodedQRCode*(version: QRVersion,
                       ecLevel: QRECLevel = qrECL,
                       mode: QRMode = qrByteMode
                      ): EncodedQRCode =
  template get[T](self: QRCapacity[T]): T = self[ecLevel][version]
  template dataSize: uint16 = totalDataCodewords.get
  template eccSize: uint16 =
    cast[uint16](group1Blocks.get + group2Blocks.get) * blockECCodewords.get
  EncodedQRCode(mode: mode,
                version: version,
                ecLevel: ecLevel,
                data: newBitArray(dataSize + eccSize))

proc newEncodedQRCode*(qr: QRCode): EncodedQRCode =
  template dataSize: uint16 = totalDataCodewords[qr]
  template eccSize: uint16 =
    cast[uint16](group1Blocks[qr] + group2Blocks[qr]) * blockECCodewords[qr]
  EncodedQRCode(mode: qr.mode,
                version: qr.version,
                ecLevel: qr.ecLevel,
                data: newBitArray(dataSize + eccSize))
