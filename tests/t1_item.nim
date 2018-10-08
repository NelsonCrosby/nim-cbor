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

suite "CborItem integers":
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

suite "CborItem strings":
  test "bytes(8)":
    "48".tt 1
    require item.kind == cbByteString
    require item.countBytes == 8
  test "str(32)":
    "7820".tt 2
    require item.kind == cbTextString
    require item.countBytes == 32

suite "CborItems arrays/maps":
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

suite "CborItems tags":
  test "/18":
    "D2".tt 1
    require item.kind == cbTag
    require item.valueTag == 18
  test "/43":
    "D82B".tt 2
    require item.kind == cbTag
    require item.valueTag == 43

suite "CborItems simple values":
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
