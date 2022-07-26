import unittest
import QRgen/bitArray

test "Simple bit array":
  var b = newBitArray()
  b.add 12'u8, 8
  check b.data[0] == 12

test "Complex bit array":
  var b = newBitArray()
  b.add 12'u8, 8
  b.add 24'u8, 8
  b.add 0b101'u8, 3
  check b.data[0] == 12
  check b.data[1] == 24
  check b.data[2] == 160

test "Passing different uint types to bit array":
  var b = newBitArray()
  b.add 0b101'u8, 3
  b.add 0b1000010101'u16, 10
  b.add 0b100101010011100101'u32, 18
  b.add 0b10010101010101100010111011001110010'u64, 35
  check b.data == @[0b10110000'u8,
                    0b10101100'u8,
                    0b10101001'u8,
                    0b11001011'u8,
                    0b00101010'u8,
                    0b10101100'u8,
                    0b01011101'u8,
                    0b10011100'u8,
                    0b10000000'u8]
