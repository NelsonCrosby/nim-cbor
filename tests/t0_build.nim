import nxcbor

let result = "\0".cborItem
assert result.length == 1
assert result.item.kind == cbPositive
assert result.item.valueInt == 0
