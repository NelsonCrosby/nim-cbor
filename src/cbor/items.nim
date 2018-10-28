

type
  CborItemKind* = enum
    cbPositive = 0, cbNegative = 1,
    cbByteString = 2, cbTextString = 3,
    cbArray = 4, cbTable = 5,
    cbTag = 6, cbSimple = 7,
    cbBoolean,
    cbNull, cbUndefined,
    cbFloat16, cbFloat32, cbFloat64,
    cbBreak,
    cbInvalid

  CborItem* = object
    case kind*: CborItemKind:
    of cbPositive, cbNegative:
      valueInt*: uint64
    of cbByteString, cbTextString:
      countBytes*: uint64
    of cbArray, cbTable:
      bound*: bool
      countItems*: uint64
    of cbTag:
      valueTag*: uint64
    of cbSimple:
      valueSimple*: uint64
    of cbBoolean:
      valueBool*: bool
    of cbNull, cbUndefined:
      discard
    of cbFloat16, cbFloat32:
      valueFloat32*: float32
    of cbFloat64:
      valueFloat64*: float64
    of cbBreak: discard
    of cbInvalid:
      invalidKind*: CborItemKind
      invalidInfo*: uint8


var cborJumpTable: array[byte, tuple[item: CborItem, remaining: int]] = [
  # ### KIND 0: POSITIVE INTEGER ### #
  (CborItem(kind: cbPositive, valueInt: 0), 0),                                   # 0_00
  (CborItem(kind: cbPositive, valueInt: 1), 0),                                   # 0_01
  (CborItem(kind: cbPositive, valueInt: 2), 0),                                   # 0_02
  (CborItem(kind: cbPositive, valueInt: 3), 0),                                   # 0_03
  (CborItem(kind: cbPositive, valueInt: 4), 0),                                   # 0_04
  (CborItem(kind: cbPositive, valueInt: 5), 0),                                   # 0_05
  (CborItem(kind: cbPositive, valueInt: 6), 0),                                   # 0_06
  (CborItem(kind: cbPositive, valueInt: 7), 0),                                   # 0_07
  (CborItem(kind: cbPositive, valueInt: 8), 0),                                   # 0_08
  (CborItem(kind: cbPositive, valueInt: 9), 0),                                   # 0_09
  (CborItem(kind: cbPositive, valueInt: 10), 0),                                  # 0_0A
  (CborItem(kind: cbPositive, valueInt: 11), 0),                                  # 0_0B
  (CborItem(kind: cbPositive, valueInt: 12), 0),                                  # 0_0C
  (CborItem(kind: cbPositive, valueInt: 13), 0),                                  # 0_0D
  (CborItem(kind: cbPositive, valueInt: 14), 0),                                  # 0_0E
  (CborItem(kind: cbPositive, valueInt: 15), 0),                                  # 0_0F
  (CborItem(kind: cbPositive, valueInt: 16), 0),                                  # 0_10
  (CborItem(kind: cbPositive, valueInt: 17), 0),                                  # 0_11
  (CborItem(kind: cbPositive, valueInt: 18), 0),                                  # 0_12
  (CborItem(kind: cbPositive, valueInt: 19), 0),                                  # 0_13
  (CborItem(kind: cbPositive, valueInt: 20), 0),                                  # 0_14
  (CborItem(kind: cbPositive, valueInt: 21), 0),                                  # 0_15
  (CborItem(kind: cbPositive, valueInt: 22), 0),                                  # 0_16
  (CborItem(kind: cbPositive, valueInt: 23), 0),                                  # 0_17
  (CborItem(kind: cbPositive, valueInt: 0), 1),                                   # 0_18
  (CborItem(kind: cbPositive, valueInt: 0), 2),                                   # 0_19
  (CborItem(kind: cbPositive, valueInt: 0), 4),                                   # 0_1A
  (CborItem(kind: cbPositive, valueInt: 0), 8),                                   # 0_1B
  (CborItem(kind: cbInvalid, invalidKind: cbPositive, invalidInfo: 28), 0),       # 0_1C
  (CborItem(kind: cbInvalid, invalidKind: cbPositive, invalidInfo: 29), 0),       # 0_1D
  (CborItem(kind: cbInvalid, invalidKind: cbPositive, invalidInfo: 30), 0),       # 0_1E
  (CborItem(kind: cbInvalid, invalidKind: cbPositive, invalidInfo: 31), 0),       # 0_1F

  # ### KIND 1: NEGATIVE INTEGER ### #
  (CborItem(kind: cbNegative, valueInt: 0), 0),                                   # 1_00
  (CborItem(kind: cbNegative, valueInt: 1), 0),                                   # 1_01
  (CborItem(kind: cbNegative, valueInt: 2), 0),                                   # 1_02
  (CborItem(kind: cbNegative, valueInt: 3), 0),                                   # 1_03
  (CborItem(kind: cbNegative, valueInt: 4), 0),                                   # 1_04
  (CborItem(kind: cbNegative, valueInt: 5), 0),                                   # 1_05
  (CborItem(kind: cbNegative, valueInt: 6), 0),                                   # 1_06
  (CborItem(kind: cbNegative, valueInt: 7), 0),                                   # 1_07
  (CborItem(kind: cbNegative, valueInt: 8), 0),                                   # 1_08
  (CborItem(kind: cbNegative, valueInt: 9), 0),                                   # 1_09
  (CborItem(kind: cbNegative, valueInt: 10), 0),                                  # 1_0A
  (CborItem(kind: cbNegative, valueInt: 11), 0),                                  # 1_0B
  (CborItem(kind: cbNegative, valueInt: 12), 0),                                  # 1_0C
  (CborItem(kind: cbNegative, valueInt: 13), 0),                                  # 1_0D
  (CborItem(kind: cbNegative, valueInt: 14), 0),                                  # 1_0E
  (CborItem(kind: cbNegative, valueInt: 15), 0),                                  # 1_0F
  (CborItem(kind: cbNegative, valueInt: 16), 0),                                  # 1_10
  (CborItem(kind: cbNegative, valueInt: 17), 0),                                  # 1_11
  (CborItem(kind: cbNegative, valueInt: 18), 0),                                  # 1_12
  (CborItem(kind: cbNegative, valueInt: 19), 0),                                  # 1_13
  (CborItem(kind: cbNegative, valueInt: 20), 0),                                  # 1_14
  (CborItem(kind: cbNegative, valueInt: 21), 0),                                  # 1_15
  (CborItem(kind: cbNegative, valueInt: 22), 0),                                  # 1_16
  (CborItem(kind: cbNegative, valueInt: 23), 0),                                  # 1_17
  (CborItem(kind: cbNegative, valueInt: 0), 1),                                   # 1_18
  (CborItem(kind: cbNegative, valueInt: 0), 2),                                   # 1_19
  (CborItem(kind: cbNegative, valueInt: 0), 4),                                   # 1_1A
  (CborItem(kind: cbNegative, valueInt: 0), 8),                                   # 1_1B
  (CborItem(kind: cbInvalid, invalidKind: cbNegative, invalidInfo: 28), 0),       # 1_1C
  (CborItem(kind: cbInvalid, invalidKind: cbNegative, invalidInfo: 29), 0),       # 1_1D
  (CborItem(kind: cbInvalid, invalidKind: cbNegative, invalidInfo: 30), 0),       # 1_1E
  (CborItem(kind: cbInvalid, invalidKind: cbNegative, invalidInfo: 31), 0),       # 1_1F

  # ### KIND 2: BYTE STRING ### #
  (CborItem(kind: cbByteString, countBytes: 0), 0),                               # 2_00
  (CborItem(kind: cbByteString, countBytes: 1), 0),                               # 2_01
  (CborItem(kind: cbByteString, countBytes: 2), 0),                               # 2_02
  (CborItem(kind: cbByteString, countBytes: 3), 0),                               # 2_03
  (CborItem(kind: cbByteString, countBytes: 4), 0),                               # 2_04
  (CborItem(kind: cbByteString, countBytes: 5), 0),                               # 2_05
  (CborItem(kind: cbByteString, countBytes: 6), 0),                               # 2_06
  (CborItem(kind: cbByteString, countBytes: 7), 0),                               # 2_07
  (CborItem(kind: cbByteString, countBytes: 8), 0),                               # 2_08
  (CborItem(kind: cbByteString, countBytes: 9), 0),                               # 2_09
  (CborItem(kind: cbByteString, countBytes: 10), 0),                              # 2_0A
  (CborItem(kind: cbByteString, countBytes: 11), 0),                              # 2_0B
  (CborItem(kind: cbByteString, countBytes: 12), 0),                              # 2_0C
  (CborItem(kind: cbByteString, countBytes: 13), 0),                              # 2_0D
  (CborItem(kind: cbByteString, countBytes: 14), 0),                              # 2_0E
  (CborItem(kind: cbByteString, countBytes: 15), 0),                              # 2_0F
  (CborItem(kind: cbByteString, countBytes: 16), 0),                              # 2_10
  (CborItem(kind: cbByteString, countBytes: 17), 0),                              # 2_11
  (CborItem(kind: cbByteString, countBytes: 18), 0),                              # 2_12
  (CborItem(kind: cbByteString, countBytes: 19), 0),                              # 2_13
  (CborItem(kind: cbByteString, countBytes: 20), 0),                              # 2_14
  (CborItem(kind: cbByteString, countBytes: 21), 0),                              # 2_15
  (CborItem(kind: cbByteString, countBytes: 22), 0),                              # 2_16
  (CborItem(kind: cbByteString, countBytes: 23), 0),                              # 2_17
  (CborItem(kind: cbByteString, countBytes: 0), 1),                               # 2_18
  (CborItem(kind: cbByteString, countBytes: 0), 2),                               # 2_19
  (CborItem(kind: cbByteString, countBytes: 0), 4),                               # 2_1A
  (CborItem(kind: cbByteString, countBytes: 0), 8),                               # 2_1B
  (CborItem(kind: cbInvalid, invalidKind: cbByteString, invalidInfo: 28), 0),     # 2_1C
  (CborItem(kind: cbInvalid, invalidKind: cbByteString, invalidInfo: 29), 0),     # 2_1D
  (CborItem(kind: cbInvalid, invalidKind: cbByteString, invalidInfo: 30), 0),     # 2_1E
  (CborItem(kind: cbInvalid, invalidKind: cbByteString, invalidInfo: 31), 0),     # 2_1F

  # ### KIND 3: TEXT STRING ### #
  (CborItem(kind: cbTextString, countBytes: 0), 0),                               # 3_00
  (CborItem(kind: cbTextString, countBytes: 1), 0),                               # 3_01
  (CborItem(kind: cbTextString, countBytes: 2), 0),                               # 3_02
  (CborItem(kind: cbTextString, countBytes: 3), 0),                               # 3_03
  (CborItem(kind: cbTextString, countBytes: 4), 0),                               # 3_04
  (CborItem(kind: cbTextString, countBytes: 5), 0),                               # 3_05
  (CborItem(kind: cbTextString, countBytes: 6), 0),                               # 3_06
  (CborItem(kind: cbTextString, countBytes: 7), 0),                               # 3_07
  (CborItem(kind: cbTextString, countBytes: 8), 0),                               # 3_08
  (CborItem(kind: cbTextString, countBytes: 9), 0),                               # 3_09
  (CborItem(kind: cbTextString, countBytes: 10), 0),                              # 3_0A
  (CborItem(kind: cbTextString, countBytes: 11), 0),                              # 3_0B
  (CborItem(kind: cbTextString, countBytes: 12), 0),                              # 3_0C
  (CborItem(kind: cbTextString, countBytes: 13), 0),                              # 3_0D
  (CborItem(kind: cbTextString, countBytes: 14), 0),                              # 3_0E
  (CborItem(kind: cbTextString, countBytes: 15), 0),                              # 3_0F
  (CborItem(kind: cbTextString, countBytes: 16), 0),                              # 3_10
  (CborItem(kind: cbTextString, countBytes: 17), 0),                              # 3_11
  (CborItem(kind: cbTextString, countBytes: 18), 0),                              # 3_12
  (CborItem(kind: cbTextString, countBytes: 19), 0),                              # 3_13
  (CborItem(kind: cbTextString, countBytes: 20), 0),                              # 3_14
  (CborItem(kind: cbTextString, countBytes: 21), 0),                              # 3_15
  (CborItem(kind: cbTextString, countBytes: 22), 0),                              # 3_16
  (CborItem(kind: cbTextString, countBytes: 23), 0),                              # 3_17
  (CborItem(kind: cbTextString, countBytes: 0), 1),                               # 3_18
  (CborItem(kind: cbTextString, countBytes: 0), 2),                               # 3_19
  (CborItem(kind: cbTextString, countBytes: 0), 4),                               # 3_1A
  (CborItem(kind: cbTextString, countBytes: 0), 8),                               # 3_1B
  (CborItem(kind: cbInvalid, invalidKind: cbTextString, invalidInfo: 28), 0),     # 3_1C
  (CborItem(kind: cbInvalid, invalidKind: cbTextString, invalidInfo: 29), 0),     # 3_1D
  (CborItem(kind: cbInvalid, invalidKind: cbTextString, invalidInfo: 30), 0),     # 3_1E
  (CborItem(kind: cbInvalid, invalidKind: cbTextString, invalidInfo: 31), 0),     # 3_1F

  # ### KIND 4: ARRAY ### #
  (CborItem(kind: cbArray, bound: true, countItems: 0), 0),                       # 4_00
  (CborItem(kind: cbArray, bound: true, countItems: 1), 0),                       # 4_01
  (CborItem(kind: cbArray, bound: true, countItems: 2), 0),                       # 4_02
  (CborItem(kind: cbArray, bound: true, countItems: 3), 0),                       # 4_03
  (CborItem(kind: cbArray, bound: true, countItems: 4), 0),                       # 4_04
  (CborItem(kind: cbArray, bound: true, countItems: 5), 0),                       # 4_05
  (CborItem(kind: cbArray, bound: true, countItems: 6), 0),                       # 4_06
  (CborItem(kind: cbArray, bound: true, countItems: 7), 0),                       # 4_07
  (CborItem(kind: cbArray, bound: true, countItems: 8), 0),                       # 4_08
  (CborItem(kind: cbArray, bound: true, countItems: 9), 0),                       # 4_09
  (CborItem(kind: cbArray, bound: true, countItems: 10), 0),                      # 4_0A
  (CborItem(kind: cbArray, bound: true, countItems: 11), 0),                      # 4_0B
  (CborItem(kind: cbArray, bound: true, countItems: 12), 0),                      # 4_0C
  (CborItem(kind: cbArray, bound: true, countItems: 13), 0),                      # 4_0D
  (CborItem(kind: cbArray, bound: true, countItems: 14), 0),                      # 4_0E
  (CborItem(kind: cbArray, bound: true, countItems: 15), 0),                      # 4_0F
  (CborItem(kind: cbArray, bound: true, countItems: 16), 0),                      # 4_10
  (CborItem(kind: cbArray, bound: true, countItems: 17), 0),                      # 4_11
  (CborItem(kind: cbArray, bound: true, countItems: 18), 0),                      # 4_12
  (CborItem(kind: cbArray, bound: true, countItems: 19), 0),                      # 4_13
  (CborItem(kind: cbArray, bound: true, countItems: 20), 0),                      # 4_14
  (CborItem(kind: cbArray, bound: true, countItems: 21), 0),                      # 4_15
  (CborItem(kind: cbArray, bound: true, countItems: 22), 0),                      # 4_16
  (CborItem(kind: cbArray, bound: true, countItems: 23), 0),                      # 4_17
  (CborItem(kind: cbArray, bound: true, countItems: 0), 1),                       # 4_18
  (CborItem(kind: cbArray, bound: true, countItems: 0), 2),                       # 4_19
  (CborItem(kind: cbArray, bound: true, countItems: 0), 4),                       # 4_1A
  (CborItem(kind: cbArray, bound: true, countItems: 0), 8),                       # 4_1B
  (CborItem(kind: cbInvalid, invalidKind: cbArray, invalidInfo: 28), 0),          # 4_1C
  (CborItem(kind: cbInvalid, invalidKind: cbArray, invalidInfo: 29), 0),          # 4_1D
  (CborItem(kind: cbInvalid, invalidKind: cbArray, invalidInfo: 30), 0),          # 4_1E
  (CborItem(kind: cbArray, bound: false), 0),                                     # 4_1F

  # ### KIND 5: TABLE/MAP ### #
  (CborItem(kind: cbTable, bound: true, countItems: 0), 0),                       # 5_00
  (CborItem(kind: cbTable, bound: true, countItems: 1), 0),                       # 5_01
  (CborItem(kind: cbTable, bound: true, countItems: 2), 0),                       # 5_02
  (CborItem(kind: cbTable, bound: true, countItems: 3), 0),                       # 5_03
  (CborItem(kind: cbTable, bound: true, countItems: 4), 0),                       # 5_04
  (CborItem(kind: cbTable, bound: true, countItems: 5), 0),                       # 5_05
  (CborItem(kind: cbTable, bound: true, countItems: 6), 0),                       # 5_06
  (CborItem(kind: cbTable, bound: true, countItems: 7), 0),                       # 5_07
  (CborItem(kind: cbTable, bound: true, countItems: 8), 0),                       # 5_08
  (CborItem(kind: cbTable, bound: true, countItems: 9), 0),                       # 5_09
  (CborItem(kind: cbTable, bound: true, countItems: 10), 0),                      # 5_0A
  (CborItem(kind: cbTable, bound: true, countItems: 11), 0),                      # 5_0B
  (CborItem(kind: cbTable, bound: true, countItems: 12), 0),                      # 5_0C
  (CborItem(kind: cbTable, bound: true, countItems: 13), 0),                      # 5_0D
  (CborItem(kind: cbTable, bound: true, countItems: 14), 0),                      # 5_0E
  (CborItem(kind: cbTable, bound: true, countItems: 15), 0),                      # 5_0F
  (CborItem(kind: cbTable, bound: true, countItems: 16), 0),                      # 5_10
  (CborItem(kind: cbTable, bound: true, countItems: 17), 0),                      # 5_11
  (CborItem(kind: cbTable, bound: true, countItems: 18), 0),                      # 5_12
  (CborItem(kind: cbTable, bound: true, countItems: 19), 0),                      # 5_13
  (CborItem(kind: cbTable, bound: true, countItems: 20), 0),                      # 5_14
  (CborItem(kind: cbTable, bound: true, countItems: 21), 0),                      # 5_15
  (CborItem(kind: cbTable, bound: true, countItems: 22), 0),                      # 5_16
  (CborItem(kind: cbTable, bound: true, countItems: 23), 0),                      # 5_17
  (CborItem(kind: cbTable, bound: true, countItems: 0), 1),                       # 5_18
  (CborItem(kind: cbTable, bound: true, countItems: 0), 2),                       # 5_19
  (CborItem(kind: cbTable, bound: true, countItems: 0), 4),                       # 5_1A
  (CborItem(kind: cbTable, bound: true, countItems: 0), 8),                       # 5_1B
  (CborItem(kind: cbInvalid, invalidKind: cbTable, invalidInfo: 28), 0),          # 5_1C
  (CborItem(kind: cbInvalid, invalidKind: cbTable, invalidInfo: 29), 0),          # 5_1D
  (CborItem(kind: cbInvalid, invalidKind: cbTable, invalidInfo: 30), 0),          # 5_1E
  (CborItem(kind: cbTable, bound: false), 0),                                     # 5_1F

  # ### KIND 6: TAG ### #
  (CborItem(kind: cbTag, valueTag: 0), 0),                                        # 6_00
  (CborItem(kind: cbTag, valueTag: 1), 0),                                        # 6_01
  (CborItem(kind: cbTag, valueTag: 2), 0),                                        # 6_02
  (CborItem(kind: cbTag, valueTag: 3), 0),                                        # 6_03
  (CborItem(kind: cbTag, valueTag: 4), 0),                                        # 6_04
  (CborItem(kind: cbTag, valueTag: 5), 0),                                        # 6_05
  (CborItem(kind: cbTag, valueTag: 6), 0),                                        # 6_06
  (CborItem(kind: cbTag, valueTag: 7), 0),                                        # 6_07
  (CborItem(kind: cbTag, valueTag: 8), 0),                                        # 6_08
  (CborItem(kind: cbTag, valueTag: 9), 0),                                        # 6_09
  (CborItem(kind: cbTag, valueTag: 10), 0),                                       # 6_0A
  (CborItem(kind: cbTag, valueTag: 11), 0),                                       # 6_0B
  (CborItem(kind: cbTag, valueTag: 12), 0),                                       # 6_0C
  (CborItem(kind: cbTag, valueTag: 13), 0),                                       # 6_0D
  (CborItem(kind: cbTag, valueTag: 14), 0),                                       # 6_0E
  (CborItem(kind: cbTag, valueTag: 15), 0),                                       # 6_0F
  (CborItem(kind: cbTag, valueTag: 16), 0),                                       # 6_10
  (CborItem(kind: cbTag, valueTag: 17), 0),                                       # 6_11
  (CborItem(kind: cbTag, valueTag: 18), 0),                                       # 6_12
  (CborItem(kind: cbTag, valueTag: 19), 0),                                       # 6_13
  (CborItem(kind: cbTag, valueTag: 20), 0),                                       # 6_14
  (CborItem(kind: cbTag, valueTag: 21), 0),                                       # 6_15
  (CborItem(kind: cbTag, valueTag: 22), 0),                                       # 6_16
  (CborItem(kind: cbTag, valueTag: 23), 0),                                       # 6_17
  (CborItem(kind: cbTag, valueTag: 0), 1),                                        # 6_18
  (CborItem(kind: cbTag, valueTag: 0), 2),                                        # 6_19
  (CborItem(kind: cbTag, valueTag: 0), 4),                                        # 6_1A
  (CborItem(kind: cbTag, valueTag: 0), 8),                                        # 6_1B
  (CborItem(kind: cbInvalid, invalidKind: cbTag, invalidInfo: 28), 0),            # 6_1C
  (CborItem(kind: cbInvalid, invalidKind: cbTag, invalidInfo: 29), 0),            # 6_1D
  (CborItem(kind: cbInvalid, invalidKind: cbTag, invalidInfo: 30), 0),            # 6_1E
  (CborItem(kind: cbInvalid, invalidKind: cbTag, invalidInfo: 31), 0),            # 6_1F

  # ### KIND 7: SIMPLE ### #
  (CborItem(kind: cbSimple, valueSimple: 0), 0),                                  # 7_00
  (CborItem(kind: cbSimple, valueSimple: 1), 0),                                  # 7_01
  (CborItem(kind: cbSimple, valueSimple: 2), 0),                                  # 7_02
  (CborItem(kind: cbSimple, valueSimple: 3), 0),                                  # 7_03
  (CborItem(kind: cbSimple, valueSimple: 4), 0),                                  # 7_04
  (CborItem(kind: cbSimple, valueSimple: 5), 0),                                  # 7_05
  (CborItem(kind: cbSimple, valueSimple: 6), 0),                                  # 7_06
  (CborItem(kind: cbSimple, valueSimple: 7), 0),                                  # 7_07
  (CborItem(kind: cbSimple, valueSimple: 8), 0),                                  # 7_08
  (CborItem(kind: cbSimple, valueSimple: 9), 0),                                  # 7_09
  (CborItem(kind: cbSimple, valueSimple: 10), 0),                                 # 7_0A
  (CborItem(kind: cbSimple, valueSimple: 11), 0),                                 # 7_0B
  (CborItem(kind: cbSimple, valueSimple: 12), 0),                                 # 7_0C
  (CborItem(kind: cbSimple, valueSimple: 13), 0),                                 # 7_0D
  (CborItem(kind: cbSimple, valueSimple: 14), 0),                                 # 7_0E
  (CborItem(kind: cbSimple, valueSimple: 15), 0),                                 # 7_0F
  (CborItem(kind: cbSimple, valueSimple: 16), 0),                                 # 7_10
  (CborItem(kind: cbSimple, valueSimple: 17), 0),                                 # 7_11
  (CborItem(kind: cbSimple, valueSimple: 18), 0),                                 # 7_12
  (CborItem(kind: cbSimple, valueSimple: 19), 0),                                 # 7_13
  (CborItem(kind: cbBoolean, valueBool: false), 0),                               # 7_14
  (CborItem(kind: cbBoolean, valueBool: true), 0),                                # 7_15
  (CborItem(kind: cbNull), 0),                                                    # 7_16
  (CborItem(kind: cbUndefined), 0),                                               # 7_17
  (CborItem(kind: cbSimple, valueSimple: 0), 1),                                  # 7_18
  (CborItem(kind: cbFloat16), 2),                                                 # 7_19
  (CborItem(kind: cbFloat32), 4),                                                 # 7_1A
  (CborItem(kind: cbFloat64), 8),                                                 # 7_1B
  (CborItem(kind: cbInvalid, invalidKind: cbSimple, invalidInfo: 28), 0),         # 7_1C
  (CborItem(kind: cbInvalid, invalidKind: cbSimple, invalidInfo: 29), 0),         # 7_1D
  (CborItem(kind: cbInvalid, invalidKind: cbSimple, invalidInfo: 30), 0),         # 7_1E
  (CborItem(kind: cbBreak), 0),                                                   # 7_1F
]


proc cborItem*(src: string, offset: int = 0): tuple[item: CborItem, length: int] =
  var available = src.len - offset

  if available < 1:
    result.length = 0
    return

  var remaining: int
  (result.item, remaining) = cborJumpTable[byte(src[offset])]
  result.length = remaining + 1

  if remaining == 0:
    # No data remaining, so we have the complete item already.
    return

  if available <= remaining:
    result.length = (available - 1) - remaining
    return

  var infoValue = uint64(src[offset + 1])
  if remaining >= 2:
    infoValue = (infoValue shl 8) + uint64(src[offset + 2])
  if remaining >= 4:
    infoValue = (infoValue shl 16) +
      (uint64(src[offset + 3]) shl 8) +
      (uint64(src[offset + 4]))
  if remaining >= 8:
    infoValue = (infoValue shl 32) +
      (uint64(src[offset + 5]) shl 24) +
      (uint64(src[offset + 6]) shl 16) +
      (uint64(src[offset + 7]) shl 8) +
      (uint64(src[offset + 8]))

  case result.item.kind:
    of cbPositive, cbNegative:
      result.item.valueInt = infoValue
    of cbByteString, cbTextString:
      result.item.countBytes = infoValue
    of cbArray, cbTable:
      result.item.countItems = infoValue
    of cbTag:
      result.item.valueTag = infoValue
    of cbSimple:
      result.item.valueSimple = infoValue
    of cbFloat16:
      assert false, "TODO: 16-bit float"
    of cbFloat32:
      result.item.valueFloat32 = cast[float32](infoValue)
    of cbFloat64:
      result.item.valueFloat64 = cast[float64](infoValue)
    else:
      discard   # The rest of the kinds don't have extra info

proc encode*(item: CborItem): string =
  var
    cbKind = uint8(item.kind)
    info = -1
    infoValue = 0'u64
    extraLen: int

  case item.kind:
    of cbPositive, cbNegative:
      infoValue = item.valueInt
    of cbByteString, cbTextString:
      infoValue = item.countBytes
    of cbArray, cbTable:
      if not item.bound:
        info = 31
      else:
        infoValue = item.countItems
    of cbTag:
      infoValue = item.valueTag
    of cbSimple:
      infoValue = item.valueSimple

    of cbBoolean:
      cbKind = uint8(cbSimple)
      info =
        if item.valueBool: 21
        else: 20
    of cbNull:
      cbKind = uint8(cbSimple)
      info = 22
    of cbUndefined:
      cbKind = uint8(cbSimple)
      info = 23

    of cbFloat16:
      cbKind = uint8(cbSimple)
      assert false, "TODO: 16-bit float"
    of cbFloat32:
      cbKind = uint8(cbSimple)
      extraLen = 4
      info = 26
      infoValue = uint64(cast[uint32](item.valueFloat32))
    of cbFloat64:
      cbKind = uint8(cbSimple)
      extraLen = 8
      info = 27
      infoValue = cast[uint64](item.valueFloat64)

    of cbBreak:
      cbKind = uint8(cbSimple)
      info = 31

    of cbInvalid:
      # What are you doing??
      cbKind = uint8(item.invalidKind)
      info = int(item.invalidInfo)

  if info < 0:
    if infoValue < 24:
      info = int(infoValue)
    elif infoValue <= 0xFF'u64:
      extraLen = 1
      info = 24
    elif infoValue <= 0xFFFF'u64:
      extraLen = 2
      info = 25
    elif infoValue <= 0xFFFF_FFFF'u64:
      extraLen = 4
      info = 26
    elif infoValue <= 0xFFFF_FFFF_FFFF_FFFF'u64:
      extraLen = 8
      info = 27

  let lead = (cbKind shl 5) + uint8(info and 0x1F)

  result = newStringOfCap(extraLen + 1)
  result.add char(lead)

  case extraLen:
    of 0:
      return
    of 1:
      result.add char(infoValue)
    of 2:
      result.add char(infoValue shr 8 and 0xFF)
      result.add char(infoValue and 0xFF)
    of 4:
      result.add char(infoValue shr 24 and 0xFF)
      result.add char(infoValue shr 16 and 0xFF)
      result.add char(infoValue shr 8 and 0xFF)
      result.add char(infoValue and 0xFF)
    of 8:
      result.add char(infoValue shr 56 and 0xFF)
      result.add char(infoValue shr 48 and 0xFF)
      result.add char(infoValue shr 40 and 0xFF)
      result.add char(infoValue shr 32 and 0xFF)
      result.add char(infoValue shr 24 and 0xFF)
      result.add char(infoValue shr 16 and 0xFF)
      result.add char(infoValue shr 8 and 0xFF)
      result.add char(infoValue and 0xFF)
    else:
      discard
