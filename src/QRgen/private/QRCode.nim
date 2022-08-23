import qrTypes, qrCharacters, qrCapacities

type
  QRCode* = object
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QREcLevel
    data*: string

  DataSizeDefect* = object of Defect

template `[]`*[T](self: QRCapacity[T], qr: QRCode): T =
  self[qr.ecLevel][qr.version]

template getCapacities(mode: QRMode): QRCapacity[uint16] =
  case mode
  of qrNumericMode: numericModeCapacities
  of qrAlphanumericMode: alphanumericModeCapacities
  of qrByteMode: byteModeCapacities

proc setMostEfficientMode*(self: var QRCode) =
  self.mode = qrNumericMode
  for c in self.data:
    if c notin alphaNumericValues:
      self.mode = qrByteMode
      return
    elif self.mode != qrAlphanumericMode and c notin numericValues:
      self.mode = qrAlphanumericMode

proc setSmallestVersion*(self: var QRCode) =
  for i, version in getCapacities(self.mode)[self.ecLevel]:
    if cast[uint16](self.data.len) < version:
      self.version = i
      return

proc newQRCode*(data: string,
                mode: QRMode,
                version: QRVersion,
                ecLevel: QREcLevel = qrEcL
               ): QRCode =
  if cast[uint16](data.len) > getCapacities(mode)[ecLevel][version]:
    raise newException(
      DataSizeDefect,
      "The data can't fit in the specified QR code version"
    )
  QRCode(mode: mode, version: version, ecLevel: ecLevel, data: data)

proc newQRCode*(data: string,
                version: QRVersion,
                ecLevel: QREcLevel = qrEcL
               ): QRCode =
  result = QRCode(version: version, ecLevel: ecLevel, data: data)
  result.setMostEfficientMode

proc newQRCode*(data: string,
                mode: QRMode,
                ecLevel: QREcLevel = qrEcL
               ): QRCode =
  result = QRCode(mode: mode, version: 1, ecLevel: ecLevel, data: data)
  result.setSmallestVersion

proc newQRCode*(data: string,
                ecLevel: QREcLevel = qrEcL
               ): QRCode =
  result = QRCode(version: 1, ecLevel: ecLevel, data: data)
  result.setMostEfficientMode
  result.setSmallestVersion
