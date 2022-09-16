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

func getMostEfficientMode*(data: string): QRMode =
  result = qrNumericMode
  for c in data:
    if c notin alphaNumericValues:
      result = qrByteMode
      return
    elif result != qrAlphanumericMode and c notin numericValues:
      result = qrAlphanumericMode

proc getSmallestVersion*(
  data: string,
  mode: QRMode,
  ecLevel: QRECLevel
): QRVersion =
  result = 1
  for version in getCapacities(mode)[ecLevel]:
    if cast[uint16](data.len) < version:
      return result
    result.inc
  raise newException(
    DataSizeDefect,
    "The data can't fit in any QR code version with the specified ecLevel"
  )

proc newQRCode*(
  data: string,
  ecLevel: QRECLevel = qrECL,
  mode: QRMode = data.getMostEfficientMode,
  version: QRVersion = data.getSmallestVersion(mode, ecLevel),
): QRCode =
  ## Creates a new `QRCode` object with the specified `data`, `ecLevel`, `mode`
  ## and `version`.
  ##
  ## .. note:: By default `mode` will be the most efficient mode to encode
  ##    `data`, `version` will be the smallest QR version where `data` can
  ##    fit, and `version` will be the lowest level.
  ##
  ## .. note:: Only the size will be checked.
  result = QRCode(mode: mode, version: version, ecLevel: ecLevel, data: data)
  if cast[uint16](result.data.len) > getCapacities(result.mode)[result]:
    raise newException(
      DataSizeDefect,
      "The data can't fit in the specified QR code version"
    )
