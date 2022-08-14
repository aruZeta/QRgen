import qrTypes, qrCharacters, qrCapacities
import std/options

type
  QRCode* = object
    mode*: QRMode
    version*: QRVersion
    eccLevel*: QRErrorCorrectionLevel
    data*: string

  DataSizeDefect = object of Defect

proc getCapacities(mode: QRMode): QRCapacity[uint16] =
  case mode
  of qrNumericMode:      numericModeCapacities
  of qrAlphanumericMode: alphanumericModeCapacities
  of qrByteMode:         byteModeCapacities

proc calcMostEfficientMode(data: string): QRMode =
  result = qrNumericMode
  for c in data:
    if c notin alphaNumericValues:
      result = qrByteMode
      return
    elif result != qrAlphanumericMode and c notin numericValues:
      result = qrAlphanumericMode

proc calcSmallestVersion(mode: QRMode,
                         eccLevel: QRErrorCorrectionLevel,
                         data: string): QRVersion =
  for i, version in getCapacities(mode)[eccLevel]:
    if cast[uint16](data.len) <= version:
      return i

  result = high(QRVersion)
  raise newException(
    DataSizeDefect,
    "The data can't fit in any QR code version"
  )

proc newQRCode*(data: string,
                mode: Option[QRMode] = none(QRMode),
                version: Option[QRVersion] = none(QRVersion),
                eccLevel: QRErrorCorrectionLevel = qrEccL
               ): QRCode =
  let
    mode: QRMode =
      if mode.isNone: calcMostEfficientMode data
      else: get mode
    version: QRVersion =
      if version.isNone: calcSmallestVersion mode, eccLevel, data
      else: get version

  QRCode(mode: mode, version: version, eccLevel: eccLevel, data: data)

# The same as the calc procs but meant to be used in var QRCode
proc setMostEfficientMode*(qr: var QRCode) =
  qr.mode = qrNumericMode
  for c in qr.data:
    if c notin alphaNumericValues:
      qr.mode = qrByteMode
      return
    elif qr.mode != qrAlphanumericMode and c notin numericValues:
      qr.mode = qrAlphanumericMode

proc setSmallestVersion*(qr: var QRCode) =
  for i, version in getCapacities(qr.mode)[qr.eccLevel]:
    if cast[uint16](qr.data.len) < version:
      qr.version = i
      return
