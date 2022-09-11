import
  ".."/[BitArray, QRCode, qrCapacities, qrTypes]

type
  EncodedQRCode* = object
    ## An object holding the encode data of a `QRCode`, `data`, and the rest
    ## of it's information: `mode`, `version` and `ecLevel`.
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QRECLevel
    data*: BitArray

proc newEncodedQRCode*(
  version: QRVersion,
  ecLevel: QRECLevel = qrECL,
  mode: QRMode = qrByteMode
): EncodedQRCode =
  ## Creates a new `EncodedQRCode` object with the specified `mode`, `version`
  ## and `ecLevel`.
  template get[T](self: QRCapacity[T]): T = self[ecLevel][version]
  template dataSize: uint16 = totalDataCodewords.get
  template eccSize: uint16 =
    (group1Blocks.get + group2Blocks.get).uint16 * blockECCodewords.get
  EncodedQRCode(mode: mode,
                version: version,
                ecLevel: ecLevel,
                data: newBitArray(dataSize + eccSize))

proc newEncodedQRCode*(qr: QRCode): EncodedQRCode =
  ## Creates a new `EncodedQRCode` from an exisiting `QRCode` object.
  template dataSize: uint16 = totalDataCodewords[qr]
  template eccSize: uint16 =
    (group1Blocks[qr] + group2Blocks[qr]).uint16 * blockECCodewords[qr]
  EncodedQRCode(mode: qr.mode,
                version: qr.version,
                ecLevel: qr.ecLevel,
                data: newBitArray(dataSize + eccSize))
