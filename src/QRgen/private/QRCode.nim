import qrTypes, qrCharacters, qrCapacities

type
  QRCode* = object
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QRECLevel
    data*: string

  DataSizeDefect* = object of Defect

template `[]`*[T](self: QRCapacity[T], qr: QRCode): T =
  self[qr.ecLevel][qr.version]

template getCapacities(mode: QRMode): QRCapacity[uint16] =
  case mode
  of qrNumericMode: numericModeCapacities
  of qrAlphanumericMode: alphanumericModeCapacities
  of qrByteMode: byteModeCapacities

proc setMostEfficientMode(self: var QRCode) =
  self.mode = qrNumericMode
  for c in self.data:
    if c notin alphaNumericValues:
      self.mode = qrByteMode
      return
    elif self.mode != qrAlphanumericMode and c notin numericValues:
      self.mode = qrAlphanumericMode

proc setSmallestVersion(self: var QRCode) =
  for i, version in getCapacities(self.mode)[self.ecLevel]:
    if cast[uint16](self.data.len) < version:
      self.version = i
      return
  raise newException(
    DataSizeDefect,
    "The data can't fit in any QR code version with the specified ecLevel"
  )

template checkSize(self: QRCode) =
  if cast[uint16](self.data.len) > getCapacities(self.mode)[self]:
    raise newException(
      DataSizeDefect,
      "The data can't fit in the specified QR code version"
    )

proc newQRCode*(data: string,
                mode: QRMode,
                version: QRVersion,
                ecLevel: QRECLevel = qrECL
               ): QRCode =
  result = QRCode(mode: mode, version: version, ecLevel: ecLevel, data: data)
  result.checkSize

proc newQRCode*(data: string,
                version: QRVersion,
                ecLevel: QRECLevel = qrECL
               ): QRCode =
  result = QRCode(version: version, ecLevel: ecLevel, data: data)
  result.setMostEfficientMode
  result.checkSize

proc newQRCode*(data: string,
                mode: QRMode,
                ecLevel: QRECLevel = qrECL
               ): QRCode =
  result = QRCode(mode: mode, version: 1, ecLevel: ecLevel, data: data)
  result.setSmallestVersion

proc newQRCode*(data: string,
                ecLevel: QRECLevel = qrECL
               ): QRCode =
  result = QRCode(version: 1, ecLevel: ecLevel, data: data)
  result.setMostEfficientMode
  result.setSmallestVersion
