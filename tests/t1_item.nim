import unittest
import strutils
import cbor


template tt(str: string, xlength: int, xkind: CborItemKind) =
  var
    it {.inject.}: CborItem
    length {.inject.}: int
  (it, length) = str.parseHexStr().cborItem
  require length == xlength
  require it.kind == xkind

template tv(str: string, offset: int, xlength: int, xkind: CborItemKind) =
  (it, length) = str.parseHexStr().cborItem(offset)
  require length == xlength
  require it.kind == xkind

suite "CborItem decode integers":
  test "0":
    "00".tt 1, cbPositive
    require it.valueInt == 0
  test "-1":
    "20".tt 1, cbNegative
    require it.valueInt == 0
  test "0x449A522B":
    "1A449A522B".tt 5, cbPositive
    require it.valueInt == 0x449A522B'u64

suite "CborItem decode strings":
  test "bytes(8)":
    "48".tt 1, cbByteString
    require it.countBytes == 8
  test "str(32)":
    "7820".tt 2, cbTextString
    require it.countBytes == 32

suite "CborItem decode arrays/maps":
  test "#4[0, -2, null, str(8)]":
    var data = "840021F668"
    data.tt 1, cbArray
    require it.bound == true
    require it.countItems == 4
    data.tv 1, 1, cbPositive
    require it.valueInt == 0
    data.tv 2, 1, cbNegative
    require it.valueInt == 1
    data.tv 3, 1, cbNull
    data.tv 4, 1, cbTextString
    require it.countBytes == 8
  test "[":
    "9F".tt 1, cbArray
    require it.bound == false
  test "#16{}":
    "B0".tt 1, cbTable
    require it.bound == true
    require it.countItems == 16
  test "{":
    "BF".tt 1, cbTable
    require it.bound == false

suite "CborItem decode tags":
  test "/18":
    "D2".tt 1, cbTag
    require it.valueTag == 18
  test "/43":
    "D82B".tt 2, cbTag
    require it.valueTag == 43

suite "CborItem decode simple values":
  test "false":
    "F4".tt 1, cbBoolean
    require it.valueBool == false
  test "true":
    "F5".tt 1, cbBoolean
    require it.valueBool == true
  test "null":
    "F6".tt 1, cbNull
  test "undefined":
    "F7".tt 1, cbUndefined

  test "f32(1234.5678)":
    "FA449A522B".tt 5, cbFloat32
    require it.valueFloat32 == 1234.5678'f32
  test "f64(0)":
    "FB0000000000000000".tt 9, cbFloat64
    require it.valueFloat64 == 0.0


suite "CborItem encode integer":
  test "0":
    var value = CborItem(kind: cbPositive, valueInt: 0).encode()
    require value.len == 1
    require value.toHex == "00"
  test "-1":
    var value = CborItem(kind: cbNegative, valueInt: 0).encode()
    require value.len == 1
    require value.toHex == "20"
  test "0x449A522B":
    var value = CborItem(kind: cbPositive, valueInt: 0x449A522B'u64).encode()
    require value.len == 5
    require value.toHex == "1A449A522B"

suite "CborItem encode strings":
  test "bytes(8)":
    var value = CborItem(kind: cbByteString, countBytes: 8).encode()
    require value.len == 1
    require value.toHex == "48"
  test "str(32)":
    var value = CborItem(kind: cbTextString, countBytes: 32).encode()
    require value.len == 2
    require value.toHex == "7820"

suite "CborItem encode arrays/maps":
  test "#0[]":
    var value = CborItem(kind: cbArray, bound: true, countItems: 0).encode()
    require value.len == 1
    require value.toHex == "80"
  test "[":
    var value = CborItem(kind: cbArray, bound: false).encode()
    require value.len == 1
    require value.toHex == "9F"
  test "#16{}":
    var value = CborItem(kind: cbTable, bound: true, countItems: 16).encode()
    require value.len == 1
    require value.toHex == "B0"
  test "{":
    var value = CborItem(kind: cbTable, bound: false).encode()
    require value.len == 1
    require value.toHex == "BF"

suite "CborItem encode tags":
  test "/18":
    var value = CborItem(kind: cbTag, valueTag: 18).encode()
    require value.len == 1
    require value.toHex == "D2"
  test "/43":
    var value = CborItem(kind: cbTag, valueTag: 43).encode()
    require value.len == 2
    require value.toHex == "D82B"

suite "CborItem encode simple values":
  test "false":
    var value = CborItem(kind: cbBoolean, valueBool: false).encode()
    require value.len == 1
    require value.toHex == "F4"
  test "true":
    var value = CborItem(kind: cbBoolean, valueBool: true).encode()
    require value.len == 1
    require value == "F5".parseHexStr
  test "null":
    var value = CborItem(kind: cbNull).encode()
    require value.len == 1
    require value == "F6".parseHexStr
  test "undefined":
    var value = CborItem(kind: cbUndefined).encode()
    require value.len == 1
    require value == "F7".parseHexStr

  test "f32(1234.5678)":
    var value = CborItem(kind: cbFloat32, valueFloat32: 1234.5678'f32).encode()
    require value.len == 5
    require value.toHex == "FA449A522B"
  test "f64(0)":
    var value = CborItem(kind: cbFloat64, valueFloat64: 0.0'f64).encode()
    require value.len == 9
    require value.toHex == "FB0000000000000000"
