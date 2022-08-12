const
  numericValues*      = {'0'..'9'}
  alphaValues*        = {'A'..'Z'}
  specialValues*      = {' ', '$', '%', '*', '+', '-', '.', '/', ':'}
  alphaNumericValues* = specialValues + numericValues + alphaValues

const specialValuesArr = [' ', '$', '%', '*', '+', '-', '.', '/', ':']

proc getSpecialValue(c: char): uint8 =
  for i, val in specialValuesArr:
    if val == c:
      return cast[uint8](i) + 36

proc getAlphanumericValue*(c: char): uint8 =
  if c in numericValues:
    cast[uint8](c) - cast[uint8]('0')
  elif c in alphaValues:
    cast[uint8](c) - cast[uint8]('A') + 10
  elif c in specialValues:
    getSpecialValue c
  else:
    0xFF
