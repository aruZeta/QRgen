import myTestSuite
import QRgen/private/BitArray

benchmarkTest "Simple bit array":
  var b = newBitArray(1)
  b.add 12'u8, 8
  check b.data[0] == 12

benchmarkTest "Complex bit array":
  var b = newBitArray(3)
  b.add 12'u8, 8
  b.add 24'u8, 8
  b.add 0b101'u8, 3
  check b.data[0] == 12
  check b.data[1] == 24
  check b.data[2] == 160

benchmarkTest "Passing different uint types to bit array":
  var b = newBitArray(9)
  b.add 0b101'u8, 3
  b.add 0b1000010101'u16, 10
  b.add 0b100101010011100101'u32, 18
  b.add 0b10010101010101100010111011001110010'u64, 35
  check b.data == @[0b10110000'u8,0b10101100,0b10101001,0b11001011,0b00101010,0b10101100,0b01011101,0b10011100,0b10000000]

benchmarkTest "Passing types bigger than needed":
  var b = newBitArray(9)
  b.add 0b101'u64, 3
  b.add 0b1000010101'u64, 10
  b.add 0b100101010011100101'u64, 18
  b.add 0b10010101010101100010111011001110010'u64, 35
  check b.data == @[0b10110000'u8,0b10101100,0b10101001,0b11001011,0b00101010,0b10101100,0b01011101,0b10011100,0b10000000]

benchmarkTest "Test which didn't pass before":
  var b = newBitArray(3)
  b.add 0b0001'u8, 4
  b.add 0b0000000100'u16, 10
  b.add 0b0001100'u8, 7

  check b.data == @[0b00010000'u8,0b00010000,0b01100000]

benchmarkTest "Test masking":
  var b = newBitArray(4)
  b.add 0b0001'u8, 4
  b.add 0b0000000100'u16, 10
  b.add 0b0001100'u8, 7
  b.add 0b110011'u8, 4 # should add 0011, not 110011

  check b.data == @[0b00010000'u8,0b00010000,0b01100001,0b10000000]

benchmarkTest "Moving to next byte":
  var b = newBitArray(2)
  b.add 0b1'u8, 1
  discard b.nextByte
  b.add 0b1'u8, 1

  check b.data == @[0b10000000'u8,0b10000000]

benchmarkTest "Adding 0 bits":
  var b = newBitArray(1)
  b.add 0b11111111'u8, 8
  b.add 0b00000000'u8, 0

  check b.data == @[0b11111111'u8]
