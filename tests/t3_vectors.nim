import strutils
import sequtils
import tables
import json
import cbor


type
  Entry = object
    hex: string
    obj: CborObject
    roundtrip: bool
    decoded: JsonNode
    diagnostic: string


proc loadVectors(path: string): seq[Entry] =
  var json = parseFile(path)
  assert json.kind == JArray

  result.newSeq(json.elems.len)
  for i in 0..<json.elems.len:
    var node = json.elems[i]
    assert node.kind == JObject
    result[i].hex = node["hex"].str
    result[i].roundtrip = node["roundtrip"].bval
    if node.hasKey("decoded"):
      result[i].decoded = node["decoded"]
    if node.hasKey("diagnostic"):
      result[i].diagnostic = node["diagnostic"].str


proc `==`(c: CborObject, j: JsonNode): bool =
  case j.kind:
    of JString:
      result = c.kind == cboString and c.isText and c.data == j.str
    of JInt:
      result = c.kind == cboInteger and c.valueInt == j.num
    of JFloat:
      if c.kind == cboFloat32:
        result = c.valueFloat32 == j.fnum
      elif c.kind == cboFloat64:
        result = c.valueFloat64 == j.fnum
      else:
        result = false
    of JBool:
      result = c.kind == cboBoolean and c.isSet == j.bval
    of JNull:
      result = c.kind == cboNull
    of JArray:
      result = c.kind == cboArray and c.items.len == j.elems.len
      if result:
        for i in 0..<j.elems.len:
          if c.items[i] != j.elems[i]:
            result = false
            break
    of JObject:
      result = c.kind == cboTable and c.table.len == j.fields.len
      if result:
        var cTable: seq[tuple[key: string, value: CborObject]]
        for entry in c.table:
          result = entry.key.kind == cboString and entry.key.isText
          if not result:
            result = false
            return
          cTable.add((entry.key.data, entry.value))
        var cTableMap = cTable.newTable()
        for key, value in j.fields:
          if not (cTableMap.hasKey(key)) or cTableMap[key] != value:
            result = false
            return


proc print(exc: ref Exception) =
  echo "Traceback (most recent call last)"
  echo exc.getStackTrace(), exc.name, ": ", exc.msg


var vectors = loadVectors("tests/vectors/appendix_a.json")
vectors = vectors.filter do (e: Entry) -> bool: e.hex.len > 0

echo "RUNNING ", vectors.len, " VECTORS"

var nPassed, nFailed: int

for vector in vectors.mitems:
  var
    parser = newCborObjectParser()
    done: bool

  try:
    parser.add(vector.hex.parseHexStr())
    (vector.obj, done) = parser.next()
  except AssertionError:
    echo "FAILED ", vector.hex, ": Assertion"
    echo "  ", getCurrentExceptionMsg()
    continue
  except:
    nFailed += 1
    echo "FAILED ", vector.hex, ": Exception"
    getCurrentException().print()
    echo()
    continue

  if not done:
    nFailed += 1
    echo "FAILED ", vector.hex, ": not done"
    continue

  if not vector.decoded.isNil:
    if vector.obj != vector.decoded:
      nFailed += 1
      echo "FAILED ", vector.hex, ": doesn't equal JSON"
      echo "  expect: ", vector.decoded
      echo "  actual: ", vector.obj.diagnostic()
      continue

  if vector.diagnostic.len > 0:
    var dg = vector.obj.diagnostic()
    if dg != vector.diagnostic:
      nFailed += 1
      echo "FAILED ", vector.hex, ": diagnostic failed"
      echo "  expect: ", vector.diagnostic
      echo "  actual: ", dg
      continue

  nPassed += 1

echo "DONE"

if nFailed > 0:
  echo nPassed, " passed"
  echo nFailed, " failed"
  quit(1)
else:
  echo "all passed"
