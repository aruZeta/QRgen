## # QRCode implementation
##
## This module implements an object to hold the initial data of a `QRCode`,
## being the string wanted to be used to create a QRCode with. This string is
## also used to know which size the QR code will need to be to hold that data
## and in which mode it will be encoded.
##
## The main procedures consist of the functions mentioned earlier,
## `setMostEfficientMode` to set the best mode to encode the data and
## `setSmallestVersion` to set the smallest QR code size where the data can
## fit.

import
  "."/[
    qrCapacities,
    qrCharacters,
    qrTypes
  ]

type
  QRCode* = object
    ## An object holding the data string to encode, `data`, the mode in which
    ## it will be encoded, `mode`, the size the QR code will need to hold the
    ## data, `version`, and the error correction level used to generate the
    ## generate the error correction codewords, `ecLevel`.
    mode*: QRMode
    version*: QRVersion
    ecLevel*: QRECLevel
    data*: string

  DataSizeDefect* = object of Defect
    ## Defect emitted by `setSmallestVersion<#setSmallestVersion%2CQRCode>`_
    ## when `data` can't fit in any QR code version with the specified `mode`
    ## and `ecLevel` or by `checkSize<#checkSize.t%2CQRCode>`_ when `data`
    ## can't fit in the specified `version`, `mode` and `ecLevel`.

template `[]`*[T](self: QRCapacity[T], qr: QRCode): T =
  ## A helper template to get the value stored in `self` from the `ecLevel` and
  ## `version` of `qr`.
  self[qr.ecLevel][qr.version]

template getCapacities(mode: QRMode): QRCapacity[uint16] =
  ## A helper template to get `mode`'s capacities.
  case mode
  of qrNumericMode: numericModeCapacities
  of qrAlphanumericMode: alphanumericModeCapacities
  of qrByteMode: byteModeCapacities

proc setMostEfficientMode(self: var QRCode) =
  ## Set's `self.mode` to the most efficient mode by checking all of it's
  ## characters.
  ##
  ## If all it's characters are numbers (`0..9`), then the mode will be
  ## `qrNumericMode`.
  ##
  ## If all its characters are in the
  ## `alphaNumericValues set<qrCharacters.html#alphaNumericValues>`_, then
  ## the mode will be `qrAlphanumericMode`.
  ##
  ## Else the mode will be `qrByteMode`.
  self.mode = qrNumericMode
  for c in self.data:
    if c notin alphaNumericValues:
      self.mode = qrByteMode
      return
    elif self.mode != qrAlphanumericMode and c notin numericValues:
      self.mode = qrAlphanumericMode

proc setSmallestVersion(self: var QRCode) =
  ## Set's `self.version` to the smallest version where `self.data` can fit.
  ##
  ## .. note:: If `self.data` can't fit in any of the versions with specified
  ##    `mode`, `version` and `ecLevel`, a `DataSizeDefect` will be raised.
  for i, version in getCapacities(self.mode)[self.ecLevel]:
    if cast[uint16](self.data.len) < version:
      self.version = i
      return
  raise newException(
    DataSizeDefect,
    "The data can't fit in any QR code version with the specified ecLevel"
  )

template checkSize(self: QRCode) =
  ## Helper template to check if `self.data` fits in the specified `version`.
  ##
  ## .. note:: If `self.data` can't fit in any of the versions with specified
  ##    `mode`, `version` and `ecLevel`, a `DataSizeDefect` will be raised.
  ##
  ## .. note:: When `setSmallestVersion<#setSmallestVersion%2CQRCode>`_ is
  ##    used, there is no to use this.
  if cast[uint16](self.data.len) > getCapacities(self.mode)[self]:
    raise newException(
      DataSizeDefect,
      "The data can't fit in the specified QR code version"
    )

proc newQRCode*(
  data: string,
  mode: QRMode,
  version: QRVersion,
  ecLevel: QRECLevel = qrECL
): QRCode =
  ## Creates a new `QRCode` object with the specified `data`, `mode`, `version`
  ## and `ecLevel`.
  ##
  ## .. note:: `ecLevel` will be `qrECL` by default.
  ##
  ## .. note:: `checkSize<#checkSize.t%2CQRCode>`_ will be used.
  result = QRCode(mode: mode, version: version, ecLevel: ecLevel, data: data)
  result.checkSize

proc newQRCode*(
  data: string,
  version: QRVersion,
  ecLevel: QRECLevel = qrECL
): QRCode =
  ## Creates a new `QRCode` object with the specified `data`, `version`
  ## and `ecLevel`.
  ##
  ## .. note:: `ecLevel` will be `qrECL` by default.
  ##
  ## .. note:: `setMostEfficientMode<#setMostEfficientMode%2CQRCode>`_ will
  ##    be used.
  ##
  ## .. note:: `checkSize<#checkSize.t%2CQRCode>`_ will be used.
  result = QRCode(version: version, ecLevel: ecLevel, data: data)
  result.setMostEfficientMode
  result.checkSize

proc newQRCode*(
  data: string,
  mode: QRMode,
  ecLevel: QRECLevel = qrECL
): QRCode =
  ## Creates a new `QRCode` object with the specified `data`, `version`
  ## and `ecLevel`.
  ##
  ## .. note:: `ecLevel` will be `qrECL` by default.
  ##
  ## .. note:: `setSmallestVersion<#setSmallestVersion%2CQRCode>`_ will
  ##    be used.
  result = QRCode(mode: mode, version: 1, ecLevel: ecLevel, data: data)
  result.setSmallestVersion

proc newQRCode*(
  data: string,
  ecLevel: QRECLevel = qrECL
): QRCode =
  ## Creates a new `QRCode` object with the specified `data` and `ecLevel`.
  ##
  ## .. note:: `ecLevel` will be `qrECL` by default.
  ##
  ## .. note:: `setMostEfficientMode<#setMostEfficientMode%2CQRCode>`_ will
  ##    be used.
  ##
  ## .. note:: `setSmallestVersion<#setSmallestVersion%2CQRCode>`_ will
  ##    be used.
  result = QRCode(version: 1, ecLevel: ecLevel, data: data)
  result.setMostEfficientMode
  result.setSmallestVersion
