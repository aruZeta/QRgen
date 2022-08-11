type
  QRMode* {.size: sizeof(uint8).} = enum
    qrNumericMode      = 0b0001,
    qrAlphanumericMode = 0b0010,
    qrByteMode         = 0b0100,
    # qrECIMode   = 0b0111 (Extended Channel Interpretation) not supported
    # qrKanjiMode = 0b1000                                   not supported

  QRErrorCorrectionLevel* = enum
    qrEccL, #  7% data recovery
    qrEccM, # 15% data recovery
    qrEccQ, # 25% data recovery
    qrEccH  # 30% data recovery

  QRVersion* = range[1..40]

  QRModeCapacity*[T: uint8 | uint16] = array[
    qrEccL..qrEccH,
    array[QRVersion, T]
  ]
