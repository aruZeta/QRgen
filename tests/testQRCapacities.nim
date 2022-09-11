import
  "."/[myTestSuite],
  QRgen/private/[qrCapacities, qrTypes]

test "G1 codewords < G2 codewords":
  for l in QRECLevel:
    for v in QRVersion.low..QRVersion.high:
      if group2Blocks[l][v] > 0:
        check group1BlockDataCodewords[l][v] < group2BlockDataCodewords[l][v]

test "G2 codewords - G1 codewords == 1":
  for l in QRECLevel:
    for v in QRVersion.low..QRVersion.high:
      if group2Blocks[l][v] > 0:
        check group2BlockDataCodewords[l][v] - group1BlockDataCodewords[l][v] == 1
