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

test "Passing types bigger than needed":
  var b = newBitArray()
  b.add 0b101'u64, 3
  b.add 0b1000010101'u64, 10
  b.add 0b100101010011100101'u64, 18
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

test "Test which didn't pass before":
  var b = newBitArray()
  b.add 0b0001'u8, 4
  b.add 0b0000000100'u16, 10
  b.add 0b0001100'u8, 7

  check b.data == @[0b00010000'u8,
                    0b00010000'u8,
                    0b01100000'u8]

test "Test masking":
  var b = newBitArray()
  b.add 0b0001'u8, 4
  b.add 0b0000000100'u16, 10
  b.add 0b0001100'u8, 7
  b.add 0b110011'u8, 4 # should add 0011, not 110011

  check b.data == @[0b00010000'u8,
                    0b00010000'u8,
                    0b01100001'u8,
                    0b10000000'u8]
