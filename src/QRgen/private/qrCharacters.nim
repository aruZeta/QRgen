const
  numericValues*      = {'0'..'9'}
  alphaValues*        = {'A'..'Z'}
  specialValues*      = {' ', '$', '%', '*', '+', '-', '.', '/', ':'}
  alphaNumericValues* = specialValues + numericValues + alphaValues

iterator pairs[T](a: set[T]): tuple[key: uint8, val: T] =
  var x: uint8 = 0'u8
  for c in a:
    yield (key: x, val: c)
    inc x

proc getSpecialValue(c: char): uint8 =
  for i, val in specialValues:
    if val == c:
      return i + 36'u8

proc getAlphanumericValue*(c: char): uint8 =
  const
    firstNumericPos: uint8 = cast[uint8]('0')
    firstAlphaPos: uint8 = cast[uint8]('A') - 10
  case c
  of numericValues: cast[uint8](c) - firstNumericPos
  of alphaValues: cast[uint8](c) - firstAlphaPos
  of specialValues: getSpecialValue c
  else: 0xFF
