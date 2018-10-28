import math
import strutils
import items
import objects


proc diagnostic*(obj: CborObject): string =
  case obj.kind:
    of cboInteger:
      result = $obj.valueInt
    of cboString:
      if obj.isText:
        result = "\""
        for c in obj.data:
          case c:
            of '"':
              result.add "\\\""
            of '\\':
              result.add "\\\\"
            of '\b':
              result.add "\\b"
            of '\f':
              result.add "\\f"
            of '\L':
              result.add "\\n"
            of '\c':
              result.add "\\r"
            of '\t':
              result.add "\\t"
            else:
              result.add c
        result.add('"')
      else:
        result = "h'" & obj.data.toHex() & "'"
    of cboArray:
      result = "["
      for entry in obj.items:
        result.add(entry.diagnostic())
        result.add(", ")
      result[^2] = ']'
      result = result[0..^2]
    of cboTable:
      result = "{"
      for entry in obj.table:
        result.add(entry.key.diagnostic())
        result.add(": ")
        result.add(entry.value.diagnostic())
        result.add(", ")
      result[^2] = '}'
      result = result[0..^2]
    of cboBoolean:
      result = $obj.isSet
    of cboNull:
      result = "null"
    of cboUndefined:
      result = "undefined"
    of cboFloat32:
      result = case obj.valueFloat32.classify:
        of fcInf: "Infinity"
        of fcNegInf: "-Infinity"
        of fcNaN: "NaN"
        else: $obj.valueFloat32
    of cboFloat64:
      result = case obj.valueFloat64.classify:
        of fcInf: "Infinity"
        of fcNegInf: "-Infinity"
        of fcNaN: "NaN"
        else: $obj.valueFloat64

    of cboInvalid:
      let item = obj.invalidItem
      case item.kind:
        of cbSimple:
          result = "simple(" & $item.valueSimple & ")"
        else:
          result = (
            "!!!(" &
            "kind: " & $item.invalidKind &
            ", info: " & $item.invalidInfo &
            ")"
          )

  if not obj.tags.isNil:
    for i in countdown(obj.tags.high, obj.tags.low):
      result = $obj.tags[i] & "(" & result & ")"
