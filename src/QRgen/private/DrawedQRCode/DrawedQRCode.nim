import
  "."/[applyMaskPattern,
       drawData,
       drawFunctionPatterns,
       drawInformation,
       type],
  ".."/[EncodedQRCode/EncodedQRCode]

export
  type

proc draw*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr
  result.drawFinderPatterns
  result.drawAlignmentPatterns
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.data
  result.applyBestMaskPattern
  result.drawFormatInformation
  result.drawVersionInformation

proc drawOnly*(qr: EncodedQRCode): DrawedQRCode =
  result = newDrawedQRCode qr
  result.drawFinderPatterns
  result.drawAlignmentPatterns
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.data
