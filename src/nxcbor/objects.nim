import lists
import items


proc append[T](list: var SinglyLinkedList[T], node: SinglyLinkedNode[T]) =
  var tail = list.tail
  if tail.isNil:
    list.head = node
    list.tail = node
  else:
    tail.next = node
    list.tail = node

proc append[T](list: var SinglyLinkedList[T], value: T) =
  list.append(newSinglyLinkedNode(value))

proc pop[T](list: var DoublyLinkedList[T]): T {.discardable.} =
  let node = list.tail
  list.tail = node.prev
  if list.tail != nil:
    list.tail.next = nil
  if list.head == node:
    list.head = nil
  node.prev = nil
  result = node.value

proc pop[T](list: var SinglyLinkedList[T]): T {.discardable.} =
  let node = list.head
  list.head = node.next
  if node.next.isNil:
    list.tail = nil
  return node.value

proc insert[T](after: var DoublyLinkedNode[T], node: DoublyLinkedNode[T]) =
  node.prev = after
  node.next = after.next
  after.next = node

proc insert[T](after: var DoublyLinkedNode[T], value: T) =
  after.insert(newDoublyLinkedNode(value))


type
  CborObjectParseError* = object of Exception
    invalidItem*: CborItem

proc newParseError(item: CborItem, msg: string): ref CborObjectParseError =
  result = newException(CborObjectParseError, msg)
  result.invalidItem = item


type
  CborObjectKind* = enum
    cboInteger,
    cboString,
    cboArray,
    cboTable,
    cboSimple,
    cboBoolean,
    cboNull, cboUndefined,
    cboFloat32, cboFloat64,

  CborObject* = object
    tags*: seq[uint64]
    case kind*: CborObjectKind:
    of cboInteger:
      valueInt*: int64
    of cboString:
      isText*: bool
      data*: string
    of cboArray:
      items*: seq[CborObject]
    of cboTable:
      table*: seq[tuple[key, value: CborObject]]
    of cboSimple:
      valueSimple*: uint64
    of cboBoolean:
      isSet*: bool
    of cboNull, cboUndefined: discard
    of cboFloat32:
      valueFloat32*: float32
    of cboFloat64:
      valueFloat64*: float64

  CborObjectParser* = ref object
    buffer: string
    itemQueue: SinglyLinkedList[CborParserItem]
    depthStack: DoublyLinkedList[CborParserDepthEntry]

  CborParserItemKind = enum ikItem, ikRaw
  CborParserItem = object
    case kind: CborParserItemKind:
    of ikItem:
      item: CborItem
      needChildren: int
      needRaw: int
    of ikRaw:
      data: string

  CborParserDepthEntry = object
    node: SinglyLinkedNode[CborParserItem]


const
  CborTagDateTimeStd* = 0'u64
  CborTagDateTimeEpoch* = 1'u64
  CborTagBignumPositive* = 2'u64
  CborTagBignumNegative* = 3'u64
  CborTagDecimalFraction* = 4'u64
  CborTagBigfloat* = 5'u64
  CborTagXConvertBase64Url* = 21'u64
  CborTagXConvertBase64* = 22'u64
  CborTagXConvertBase16* = 23'u64
  CborTagCborItem* = 24'u64
  CborTagUri* = 32'u64
  CborTagBase64Url* = 33'u64
  CborTagBase64* = 34'u64
  CborTagRegExp* = 35'u64
  CborTagMimeMessage* = 36'u64
  CborTagSelfDescribe* = 55799'u64


proc newCborObjectParser*(): CborObjectParser =
  new(result)
  result.buffer = ""
  result.itemQueue = initSinglyLinkedList[CborParserItem]()
  result.depthStack = initDoublyLinkedList[CborParserDepthEntry]()

proc add*(parser: CborObjectParser, data: string) =
  var
    buffer: string
    offset: int = 0
  if parser.buffer.len == 0:
    buffer = data
  else:
    buffer = parser.buffer & data

  template item(n: DoublyLinkedNode[CborParserDepthEntry]): CborItem =
    n.value.node.value.item
  template needChildren(n: DoublyLinkedNode[CborParserDepthEntry]): int =
    n.value.node.value.needChildren
  template needRaw(n: DoublyLinkedNode[CborParserDepthEntry]): int =
    n.value.node.value.needRaw

  while true:
    var done = false
    if not parser.depthStack.tail.isNil and parser.depthStack.tail.needRaw > 0:
      var need = parser.depthStack.tail.needRaw
      var tailIndex = offset + need
      if tailIndex > buffer.len:
        # Run out of data for string content
        break
      else:
        parser.itemQueue.append(CborParserItem(
          kind: ikRaw, data: buffer[offset..<tailIndex]
        ))
        offset = tailIndex
        parser.depthStack.tail.value.node.value.needRaw = 0
        done = true

    else:
      var (item, length) = buffer.cborItem(offset)
      if length <= 0:
        # Run out of data for next item
        break

      offset += length

      var node = newSinglyLinkedNode(CborParserItem(
        kind: ikItem, item: item, needChildren: 0, needRaw: 0
      ))
      parser.itemQueue.append(node)

      if item.kind == cbByteString or item.kind == cbTextString:
        if item.boundStr:
          node.value.needRaw = int(item.countBytes)
        else:
          node.value.needRaw = 0
          node.value.needChildren = -1
        parser.depthStack.append(CborParserDepthEntry(node: node))
        done = item.countBytes == 0
      elif item.kind == cbArray:
        if item.bound:
          node.value.needChildren = int(item.countItems)
        else:
          node.value.needChildren = -1
        parser.depthStack.append(CborParserDepthEntry(node: node))
        done = item.countItems == 0
      elif item.kind == cbTable:
        if item.bound:
          node.value.needChildren = int(item.countItems) * 2
        else:
          node.value.needChildren = -2
        parser.depthStack.append(CborParserDepthEntry(node: node))
        done = item.countItems == 0
      elif item.kind == cbBreak:
        if not parser.depthStack.tail.isNil and
            parser.depthStack.tail.needChildren < 0:
          parser.depthStack.tail.value.node.value.needChildren = 0
        done = true
      else:
        done = true

    while done and not parser.depthStack.tail.isNil:
      var dtail = parser.depthStack.tail
      if dtail.item.kind != cbTag and dtail.needChildren > 0:
        dtail.needChildren -= 1
      if dtail.needChildren == 0 and dtail.needRaw == 0:
        parser.depthStack.pop()
      else:
        done = false

  # Stop if run out of data

  # Save remaining data
  if offset >= buffer.len:
    parser.buffer = ""
  else:
    parser.buffer = buffer[offset..^1]

proc next*(parser: CborObjectParser): tuple[obj: CborObject, done: bool] =
  result.done = false
  var head = parser.itemQueue.head
  if head.isNil:
    return
  assert head.value.kind == ikItem, "internal consistency error"
  if head.value.needChildren == 0 and head.value.needRaw == 0:
    let item = parser.itemQueue.pop().item
    case item.kind:
      of cbPositive:
        result.obj.kind = cboInteger
        result.obj.valueInt = int64(item.valueInt)
      of cbNegative:
        result.obj.kind = cboInteger
        result.obj.valueInt = -1'i64 - int64(item.valueInt)

      of cbByteString, cbTextString:
        var data: string
        if not item.boundStr:
          while true:
            var chld = parser.itemQueue.pop().item
            if chld.kind == cbBreak:
              break
            elif chld.kind != item.kind or not chld.boundStr:
              raise newParseError(
                chld, "unexpected " & $chld.kind &
                " item not of " & $item.kind & " in unbound string"
              )
            elif not chld.boundStr:
              raise newParseError(
                chld, "expected bound " & $chld.kind & " in unbound string"
              )
            else:
              data.add(parser.itemQueue.pop().data)
        elif item.countBytes == 0:
          data = ""
        else:
          assert parser.itemQueue.head.value.kind == ikRaw, "internal consistency error"
          data = parser.itemQueue.pop().data
        result.obj.kind = cboString
        result.obj.isText = item.kind == cbTextString
        result.obj.data = data

      of cbArray:
        result.obj.kind = cboArray

        if item.bound:
          var
            done: bool
            n = int(item.countItems)
          result.obj.items.newSeq(n)
          for i in 0..<n:
            (result.obj.items[i], done) = parser.next()
            assert done, "internal consistency error"
        else:
          result.obj.items = @[]
          var
            obj: CborObject
            done: bool
          while true:
            if parser.itemQueue.head.value.item.kind == cbBreak:
              parser.itemQueue.pop()
              break
            (obj, done) = parser.next()
            assert done, "internal consistency error"
            result.obj.items.add(obj)

      of cbTable:
        result.obj.kind = cboTable

        if item.bound:
          var
            done: bool
            n = int(item.countItems)
          result.obj.table.newSeq(n)
          for i in 0..<n:
            (result.obj.table[i].key, done) = parser.next()
            assert done, "internal consistency error"
            (result.obj.table[i].value, done) = parser.next()
            assert done, "internal consistency error"
        else:
          result.obj.table = @[]
          var
            key, value: CborObject
            done: bool
          while true:
            if parser.itemQueue.head.value.item.kind == cbBreak:
              parser.itemQueue.pop()
              break
            (key, done) = parser.next()
            assert done, "internal consistency error"
            (value, done) = parser.next()
            assert done, "internal consistency error"
            result.obj.table.add((key, value))

      of cbTag:
        var done: bool
        (result.obj, done) = parser.next()
        assert done, "internal consistency error"
        result.obj.tags.insert(item.valueTag)

      of cbSimple:
        result.obj.kind = cboSimple
        result.obj.valueSimple = item.valueSimple

      of cbBoolean:
        result.obj.kind = cboBoolean
        result.obj.isSet = item.valueBool

      of cbNull:
        result.obj.kind = cboNull
      of cbUndefined:
        result.obj.kind = cboUndefined

      of cbFloat16, cbFloat32:
        result.obj.kind = cboFloat32
        result.obj.valueFloat32 = item.valueFloat32
      of cbFloat64:
        result.obj.kind = cboFloat64
        result.obj.valueFloat64 = item.valueFloat64

      of cbBreak:
        raise newParseError(item, "unexpected break")

      of cbInvalid:
        raise newParseError(item, "invalid item")

    result.done = true


proc item*(obj: CborObject): CborItem =
  case obj.kind:
    of cboInteger:
      if obj.valueInt < 0:
        result.kind = cbNegative
        result.valueInt = uint64(obj.valueInt + 1)
      else:
        result.kind = cbPositive
        result.valueInt = uint64(obj.valueInt)

    of cboString:
      result.kind =
        if obj.isText: cbTextString
        else: cbByteString
      result.countBytes = uint64(obj.data.len)

    of cboArray:
      result.kind = cbArray
      result.bound = true
      result.countItems = uint64(obj.items.len)

    of cboTable:
      result.kind = cbTable
      result.bound = true
      result.countItems = uint64(obj.table.len)
    
    of cboSimple:
      result.kind = cbSimple
      result.valueSimple = obj.valueSimple

    of cboBoolean:
      result.kind = cbBoolean
      result.valueBool = obj.isSet

    of cboNull:
      result.kind = cbNull
    of cboUndefined:
      result.kind = cbUndefined

    of cboFloat32:
      result.kind = cbFloat32
      result.valueFloat32 = obj.valueFloat32
    of cboFloat64:
      result.kind = cbFloat64
      result.valueFloat64 = obj.valueFloat64

proc encode*(obj: CborObject): string =
  result = ""
  for tag in obj.tags:
    result.add(CborItem(kind: cbTag, valueTag: tag).encode())

  result.add(obj.item.encode())

  if obj.kind == cboString:
    result.add(obj.data)
  elif obj.kind == cboArray:
    for entry in obj.items:
      result.add(entry.encode())
  elif obj.kind == cboTable:
    for entry in obj.table:
      result.add(entry.key.encode())
      result.add(entry.value.encode())
