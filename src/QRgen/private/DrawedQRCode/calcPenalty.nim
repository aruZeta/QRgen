import
  "."/[type],
  ".."/[Drawing]

proc evaluateCondition1*(self: DrawedQRCode): uint16 =
  ## Evaluates the penalty of the applied mask using the
  ## `condition1 algorithm<https://www.thonky.com/qr-code-tutorial/data-masking#evaluation-condition-1>`_.
  result = 0
  var
    stateCol: bool
    countCol: uint16
    stateRow: bool
    countRow: uint16
  template mayAddPenalty(state, count: untyped) =
    if   count == 5: result += 3
    elif count >= 5: result += count - 2
  template check(state, count, getter: untyped) =
    if not (state xor getter):
      count += 1
    else:
      mayAddPenalty state, count
      state = not state
      count = 1
  for i in 0'u8..<self.drawing.size:
    stateRow = self.drawing[0, i]
    countRow = 1
    stateCol = self.drawing[i, 0]
    countCol = 1
    for j in 1'u8..<self.drawing.size:
      check stateRow, countRow, self.drawing[j, i]
      check stateCol, countCol, self.drawing[i, j]
    mayAddPenalty stateRow, countRow
    mayAddPenalty stateCol, countCol

proc evaluateCondition2*(self: DrawedQRCode): uint16 =
  ## Evaluates the penalty of the applied mask using the
  ## `condition2 algorithm<https://www.thonky.com/qr-code-tutorial/data-masking#evaluation-condition-2>`_.
  result = 0
  for i in 0'u8..<self.drawing.size-1:
    for j in 0'u8..<self.drawing.size-1:
      let actual = self.drawing[j, i]
      if not ((actual xor self.drawing[j+1, i]) or
              (actual xor self.drawing[j, i+1]) or
              (actual xor self.drawing[j+1, i+1])):
        result += 3

proc evaluateCondition3*(self: DrawedQRCode): uint16 =
  ## Evaluates the penalty of the applied mask using the
  ## `condition3 algorithm<https://www.thonky.com/qr-code-tutorial/data-masking#evaluation-condition-3>`_.
  result = 0
  for i in 0'u8..<self.drawing.size:
    for j in 0'u8..<self.drawing.size-10:
      if self.drawing[j..j+10, i] in {0b10111010000'u16, 0b00001011101}:
        result += 40
      if self.drawing[i, j..j+10] in {0b10111010000'u16, 0b00001011101}:
        result += 40

proc evaluateCondition4*(self: DrawedQRCode): uint16 = ##
  ## Evaluates the penalty of the applied mask using the
  ## `condition4 algorithm<https://www.thonky.com/qr-code-tutorial/data-masking#evaluation-condition-4>`_.
  var darkModules: uint32 = 0
  for i in 0..<self.drawing.len:
    var b: uint8 = self.drawing[i]
    while b > 0:
      darkModules += 1
      b = b and (b - 1)
  case
    ((darkModules * 100) div
    (cast[uint16](self.drawing.size) * self.drawing.size))
  of 45..54: 0
  of 40..44, 55..59: 10
  of 35..39, 60..64: 20
  of 30..34, 65..69: 30
  of 25..29, 70..74: 40
  of 20..24, 75..79: 50
  of 15..19, 80..84: 60
  of 10..14, 85..89: 70
  of 05..09, 90..94: 80
  of 00..04, 95..99: 90
  else: 0 # Should not be reached

template calcPenalty*(self: DrawedQRCode): uint16 =
  ## Helper template to sum the result of the 4 condition
  ## algorithms.
  self.evaluateCondition1 +
  self.evaluateCondition2 +
  self.evaluateCondition3 +
  self.evaluateCondition4
