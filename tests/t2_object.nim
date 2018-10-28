import unittest
import strutils
import cbor


template tt(strs: seq[string], xdone: bool, xkind: CborObjectKind) =
  var
    parser = newCborObjectParser()
    obj {.inject.}: CborObject
    done {.inject.}: bool
  for i in 0..<strs.len:
    parser.add(strs[i].parseHexStr())
    (obj, done) = parser.next()
    when xdone:
      let shouldBeDone = (i == strs.high)
      require done == shouldBeDone
    else:
      require not done
  when xdone:
    require obj.kind == xkind


suite "CborObject decode":
  test "#2{ h'020456': null, 12: undefined, \"time\": 1(1363896240) }":
    @["A343020456F60CF76474696D65C11A514B67B0"].tt true, cboTable
    require obj.table.len == 3

    require obj.table[0].key.kind == cboString
    require obj.table[0].key.isText == false
    require obj.table[0].key.data.toHex() == "020456"
    require obj.table[0].value.kind == cboNull

    require obj.table[1].key.kind == cboInteger
    require obj.table[1].key.valueInt == 12
    require obj.table[1].value.kind == cboUndefined

    require obj.table[2].key.kind == cboString
    require obj.table[2].key.isText == true
    require obj.table[2].key.data == "time"
    require obj.table[2].value.tags.isNil == false
    require obj.table[2].value.tags.len == 1
    require obj.table[2].value.tags[0] == 1
    require obj.table[2].value.kind == cboInteger
    require obj.table[2].value.valueInt == 1363896240

  test "#2{ h'020456': null, 12: undefined } (broken)":
    @["A2", "43", "0204", "56F6", "0CF7"].tt true, cboTable

    require obj.table[0].key.kind == cboString
    require obj.table[0].key.isText == false
    require obj.table[0].key.data.toHex() == "020456"
    require obj.table[0].value.kind == cboNull

    require obj.table[1].key.kind == cboInteger
    require obj.table[1].key.valueInt == 12
    require obj.table[1].value.kind == cboUndefined

  test "#3[ 1, 2, #2[ 1, -2, \"three\" ] ]":
    @["830102830121657468726565"].tt true, cboArray

    require obj.items[0].kind == cboInteger
    require obj.items[0].valueInt == 1
    require obj.items[1].kind == cboInteger
    require obj.items[1].valueInt == 2

    require obj.items[2].kind == cboArray
    require obj.items[2].items[0].kind == cboInteger
    require obj.items[2].items[0].valueInt == 1
    require obj.items[2].items[1].kind == cboInteger
    require obj.items[2].items[1].valueInt == -2
    require obj.items[2].items[2].kind == cboString
    require obj.items[2].items[2].isText == true
    require obj.items[2].items[2].data == "three"


suite "CborObject encode":
  test "#2{ h'020456': null, 12: undefined, \"time\": 1(1363896240) }":
    var item = CborObject(
      kind: cboTable,
      table: @{
        CborObject(kind: cboString, isText: false, data: "020456".parseHexStr()):
          CborObject(kind: cboNull),
        CborObject(kind: cboInteger, valueInt: 12):
          CborObject(kind: cboUndefined),
        CborObject(kind: cboString, isText: true, data: "time"):
          CborObject(tags: @[CborTagDateTimeEpoch], kind: cboInteger, valueInt: 1363896240)
      }
    )
    require item.encode().toHex() == "A343020456F60CF76474696D65C11A514B67B0"


suite "diagnostic encoder":
  test "[ Infinity, -Infinity, NaN ]":
    var item = CborObject(
      kind: cboArray,
      items: @[
        CborObject(kind: cboFloat32, valueFloat32: Inf),
        CborObject(kind: cboFloat64, valueFloat64: NegInf),
        CborObject(kind: cboFloat64, valueFloat64: NaN),
      ]
    )
    require item.diagnostic() == "[Infinity, -Infinity, NaN]"

  test "{ h'020456': null, 12: undefined, \"time\": 1(1363896240) }":
    var item = CborObject(
      kind: cboTable,
      table: @{
        CborObject(kind: cboString, isText: false, data: "020456".parseHexStr()):
          CborObject(kind: cboNull),
        CborObject(kind: cboInteger, valueInt: 12):
          CborObject(kind: cboUndefined),
        CborObject(kind: cboString, isText: true, data: "time"):
          CborObject(tags: @[CborTagDateTimeEpoch], kind: cboInteger, valueInt: 1363896240)
      }
    )
    let expect = "{h'020456': null, 12: undefined, \"time\": 1(1363896240)}"
    let actual = item.diagnostic()
    require actual.len == expect.len
    require actual == expect

  test "[ 1, 2, [ 1, -2, \"three\" ] ]":
    var item = CborObject(
      kind: cboArray,
      items: @[
        CborObject(kind: cboInteger, valueInt: 1),
        CborObject(kind: cboInteger, valueInt: 2),
        CborObject(kind: cboArray, items: @[
          CborObject(kind: cboInteger, valueInt: 1),
          CborObject(kind: cboInteger, valueInt: -2),
          CborObject(kind: cboString, isText: true, data: "three"),
        ])
      ]
    )
    require item.diagnostic() == "[1, 2, [1, -2, \"three\"]]"

  test "simple values":
    var item = CborObject(kind: cboInvalid, invalidItem: CborItem(
      kind: cbSimple, valueSimple: 255
    ))
    require item.diagnostic() == "simple(255)"
