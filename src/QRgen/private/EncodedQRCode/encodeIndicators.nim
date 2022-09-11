import
  "."/[type],
  ".."/[BitArray, qrTypes]

func encodeModeIndicator*(self: var EncodedQRCode) =
  ## Encodes the mode indicator according to the specified
  ## `mode<../qrTypes.html#QRMode>`_
  self.data.add cast[uint8](self.mode), 4

func encodeCharCountIndicator*(self: var EncodedQRCode, data: string) =
  ## Encodes the character count indicator, which is the length of `data`.
  ## Depending on the mode and version, the indicator will be more or less
  ## bits long.
  template modeCases(numericVal, alphanumericVal, byteVal: uint8): uint8 =
    case self.mode
    of qrNumericMode: numericVal
    of qrAlphanumericMode: alphanumericVal
    of qrByteMode: byteVal
  self.data.add(cast[uint16](data.len), (
    if self.version <= 9:    modeCases 10, 9, 8
    elif self.version >= 27: modeCases 14, 13, 16
    else:                    modeCases 12, 11, 16
  ))
