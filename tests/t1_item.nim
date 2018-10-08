import unittest
import strutils
import cbor


proc parse(str: string): tuple[item: CborItem, length: int] =
  result = str.parseHexStr.cborItem

template tt(str: string, xlength: int) =
  var
    item {.inject.}: CborItem
    length {.inject.}: int
  (item, length) = str.parse
  require length == xlength

suite "CborItem decode integers":
  test "0":
    "00".tt 1
    require item.kind == cbPositive
    require item.valueInt == 0
  test "-1":
    "20".tt 1
    require item.kind == cbNegative
    require item.valueInt == 0
  test "0x449A522B":
    "1A449A522B".tt 5
    require item.kind == cbPositive
    require item.valueInt == 0x449A522B'u64

suite "CborItem decode strings":
  test "bytes(8)":
    "48".tt 1
    require item.kind == cbByteString
    require item.countBytes == 8
  test "str(32)":
    "7820".tt 2
    require item.kind == cbTextString
    require item.countBytes == 32

suite "CborItem decode arrays/maps":
  test "[](0)":
    "80".tt 1
    require item.kind == cbArray
    require item.bound == true
    require item.countItems == 0
  test "[":
    "9F".tt 1
    require item.kind == cbArray
    require item.bound == false
  test "{}(16)":
    "B0".tt 1
    require item.kind == cbTable
    require item.bound == true
    require item.countItems == 16
  test "{":
    "BF".tt 1
    require item.kind == cbTable
    require item.bound == false

suite "CborItem decode tags":
  test "/18":
    "D2".tt 1
    require item.kind == cbTag
    require item.valueTag == 18
  test "/43":
    "D82B".tt 2
    require item.kind == cbTag
    require item.valueTag == 43

suite "CborItem decode simple values":
  test "false":
    "F4".tt 1
    require item.kind == cbBoolean
    require item.valueBool == false
  test "true":
    "F5".tt 1
    require item.kind == cbBoolean
    require item.valueBool == true
  test "null":
    "F6".tt 1
    require item.kind == cbNull
  test "undefined":
    "F7".tt 1
    require item.kind == cbUndefined

  test "f32(1234.5678)":
    "FA449A522B".tt 5
    require item.kind == cbFloat32
    require item.valueFloat32 == 1234.5678'f32
  test "f64(0)":
    "FB0000000000000000".tt 9
    require item.kind == cbFloat64
    require item.valueFloat64 == 0.0


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
  test "[](0)":
    var value = CborItem(kind: cbArray, bound: true, countItems: 0).encode()
    require value.len == 1
    require value.toHex == "80"
  test "[":
    var value = CborItem(kind: cbArray, bound: false).encode()
    require value.len == 1
    require value.toHex == "9F"
  test "{}(16)":
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
