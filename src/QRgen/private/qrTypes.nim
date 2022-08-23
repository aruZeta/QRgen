type
  QRMode* {.size: sizeof(uint8).} = enum
    qrNumericMode      = 0b0001,
    qrAlphanumericMode = 0b0010,
    qrByteMode         = 0b0100,
    # qrECIMode   = 0b0111 (Extended Channel Interpretation) not supported
    # qrKanjiMode = 0b1000                                   not supported

  QREcLevel* {.size: sizeof(uint8).} = enum
    qrEcL, #  7% data recovery
    qrEcM, # 15% data recovery
    qrEcQ, # 25% data recovery
    qrEcH  # 30% data recovery

  QRVersion* = range[1'u8..40'u8]
