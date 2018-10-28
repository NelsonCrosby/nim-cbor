import unittest
import strutils
import cbor/objects


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
  test "#2{ h'020456': null, 12: undefined }":
    @["A243020456F60CF7"].tt true, cboTable

    require obj.table[0].key.kind == cboString
    require obj.table[0].key.isText == false
    require obj.table[0].key.data.toHex() == "020456"
    require obj.table[0].value.kind == cboNull

    require obj.table[1].key.kind == cboInteger
    require obj.table[1].key.valueInt == 12
    require obj.table[1].value.kind == cboUndefined

  test "#2{ h'020456': null, 12: undefined } (broken)":
    @["A2", "43", "0204", "56F6", "0CF7"].tt true, cboTable

    require obj.table[0].key.kind == cboString
    require obj.table[0].key.isText == false
    require obj.table[0].key.data.toHex() == "020456"
    require obj.table[0].value.kind == cboNull

    require obj.table[1].key.kind == cboInteger
    require obj.table[1].key.valueInt == 12
    require obj.table[1].value.kind == cboUndefined
  
  test "#3[ 1, 2, #2[ 1, 2 ] ]":
    @["830102820102"].tt true, cboArray

    require obj.items[0].kind == cboInteger
    require obj.items[0].valueInt == 1
    require obj.items[1].kind == cboInteger
    require obj.items[1].valueInt == 2
    
    require obj.items[2].kind == cboArray
    require obj.items[2].items[0].kind == cboInteger
    require obj.items[2].items[0].valueInt == 1
    require obj.items[2].items[1].kind == cboInteger
    require obj.items[2].items[1].valueInt == 2
