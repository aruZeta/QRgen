import
  "."/[type],
  ".."/[BitArray, qrTypes]

proc encodeModeIndicator*(self: var EncodedQRCode) =
  self.data.add cast[uint8](self.mode), 4

proc encodeCharCountIndicator*(self: var EncodedQRCode, data: string) =
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
