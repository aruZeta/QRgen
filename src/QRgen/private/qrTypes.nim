type
  QRMode* {.size: sizeof(uint8).} = enum
    qrNumericMode      = 0b0001,
    qrAlphanumericMode = 0b0010,
    qrByteMode         = 0b0100,
    # qrECIMode   = 0b0111 (Extended Channel Interpretation) not supported
    # qrKanjiMode = 0b1000                                   not supported

  QRECLevel* {.size: sizeof(uint8).} = enum
    qrECL, #  7% data recovery
    qrECM, # 15% data recovery
    qrECQ, # 25% data recovery
    qrECH  # 30% data recovery

  QRVersion* = range[1'u8..40'u8]
