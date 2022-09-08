import
  "."/[type],
  ".."/[Drawing, qrTypes]

proc calcLen[T: uint16 | uint32](bits: T): uint8 =
  ## Returns the length of the bit string `bits`. 
  ##
  ## `0000000001101010` would have length `7`.
  const maxLen: uint8 = sizeof(T) * 8
  const initialMask: T =
    when T is uint16: 0b1000_0000_0000_0000'u16
    elif T is uint32: 0b1000_0000_0000_0000_0000_0000_0000_0000'u32
  result = maxLen
  while result > 0:
    let mask: T = initialMask shr (maxLen - result)
    if (bits and mask) == mask:
      return result
    result.dec

proc drawFormatInformation*(self: var DrawedQRCode) =
  ## Draws the format information of the drawing.
  var bits: uint16 = ((
    case self.ecLevel
    of qrECL: 0b01'u16
    of qrECM: 0b00'u16
    of qrECQ: 0b11'u16
    of qrECH: 0b10'u16
  ) shl 3) + self.mask
  const
    gPolynomial: uint16 = 0b101_0011_0111'u16
    polynomialLen: uint8 = gPolynomial.calcLen
  var
    ecBits: uint16 = bits shl 10
    ecBitsLen: uint8 = ecBits.calcLen
  while ecBitsLen > 10:
    let polynomial: uint16 = gPolynomial shl (ecBitsLen - polynomialLen)
    ecBits = ecBits xor polynomial
    ecBitsLen = ecBits.calcLen
  bits = (bits shl 11) or (ecBits shl 1)
  bits = bits xor 0b10_101_00000100100'u16
  template check(i: uint8): bool = ((bits shr (15 - i)) and 0x01) == 0x01
  for i in 0'u8..5'u8:
    if check i:
      self.drawing.fillPoint i, 8'u8
      self.drawing.fillPoint 8'u8, self.drawing.size-1-i
  if check 6'u8:
    self.drawing.fillPoint 7'u8, 8'u8
    self.drawing.fillPoint 8'u8, self.drawing.size-7
  if check 7'u8:
    self.drawing.fillPoint 8'u8, 8'u8
    self.drawing.fillPoint self.drawing.size-8, 8'u8
  if check 8'u8:
    self.drawing.fillPoint 8'u8, 7'u8
    self.drawing.fillPoint self.drawing.size-7, 8'u8
  for i in 9'u8..14'u8:
    if check i:
      self.drawing.fillPoint 8'u8, 14-i
      self.drawing.fillPoint self.drawing.size-15+i, 8'u8

proc drawVersionInformation*(self: var DrawedQRCode) =
  ## Draws the version information of drawings with a `version` equal to or
  ## greater than 7.
  if self.version < 7:
    return
  var bits: uint32 = cast[uint32](self.version)
  const
    gPolynomial: uint32 = 0b1_1111_0010_0101'u32
    polynomialLen: uint8 = gPolynomial.calcLen
  var
    ecBits: uint32 = bits shl 12
    ecBitsLen: uint8 = ecBits.calcLen
  while ecBitsLen > 12:
    let polynomial: uint32 = gPolynomial shl (ecBitsLen - polynomialLen)
    ecBits = ecBits xor polynomial
    ecBitsLen = ecBits.calcLen
  bits = (bits shl 26) or (ecBits shl 14)
  template check(i: uint8): bool = ((bits shr (31 - i)) and 0x01) == 0x01
  for i in 0'u8..17'u8:
    if check i:
      self.drawing.fillPoint 5 - i div 3, self.drawing.size-9-(i mod 3)
      self.drawing.fillPoint self.drawing.size-9-(i mod 3), 5 - i div 3
