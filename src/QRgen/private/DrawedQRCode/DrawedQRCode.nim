## # DrawedQRCode implementation
##
## This module implements an object to hold the result of drawing an
## `EncodedQRCode`'s (encoded) `data`.
##
## The main procedures are spread around all the modules in this directory,
## which you can find in the `import section<#6>`_.

import
  "."/[
    applyMaskPattern,
    drawData,
    drawFunctionPatterns,
    drawInformation,
    type
  ],
  ".."/[EncodedQRCode/EncodedQRCode]

export
  type

proc draw*(qr: EncodedQRCode): DrawedQRCode =
  ## Return a `DrawedQRCode` from the passed `EncodedQRCode`.
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
  ## The same as `draw` but without applying masks nor adding information.
  ## Meant for testing.
  result = newDrawedQRCode qr
  result.drawFinderPatterns
  result.drawAlignmentPatterns
  result.drawTimingPatterns
  result.drawDarkModule
  result.drawData qr.data
