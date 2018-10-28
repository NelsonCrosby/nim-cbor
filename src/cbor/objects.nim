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
  return node.value

proc insert[T](after: var DoublyLinkedNode[T], node: DoublyLinkedNode[T]) =
  node.prev = after
  node.next = after.next
  after.next = node

proc insert[T](after: var DoublyLinkedNode[T], value: T) =
  after.insert(newDoublyLinkedNode(value))


type
  CborObjectParseError* = object of Exception

  CborObjectKind* = enum
    cboInteger,
    cboString,
    cboArray,
    cboTable,
    cboBoolean,
    cboNull, cboUndefined,
    cboFloat32, cboFloat64,
    cboInvalid

  CborObject* = object
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
    of cboBoolean:
      isSet*: bool
    of cboNull, cboUndefined: discard
    of cboFloat32:
      valueFloat32*: float32
    of cboFloat64:
      valueFloat64*: float64
    of cboInvalid:
      invalidItem*: CborItem

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
    if not parser.depthStack.tail.isNil and (
      parser.depthStack.tail.item.kind == cbByteString or
      parser.depthStack.tail.item.kind == cbTextString
    ):
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
        node.value.needRaw = int(item.countBytes)
        parser.depthStack.append(CborParserDepthEntry(node: node))
        done = item.countBytes == 0
      elif item.kind == cbArray:
        node.value.needChildren = int(item.countItems)
        parser.depthStack.append(CborParserDepthEntry(node: node))
        done = item.countItems == 0
      elif item.kind == cbTable:
        node.value.needChildren = int(item.countItems) * 2
        parser.depthStack.append(CborParserDepthEntry(node: node))
        done = item.countItems == 0
      else:
        done = true

    while done and not parser.depthStack.tail.isNil:
      var dtail = parser.depthStack.tail
      dtail.needChildren -= 1
      if dtail.needChildren <= 0 and dtail.needRaw <= 0:
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
  assert head.value.kind == ikItem, "internal consistency error"
  if head.value.needChildren <= 0 and head.value.needRaw <= 0:
    let item = parser.itemQueue.pop().item
    case item.kind:
      of cbPositive:
        result.obj.kind = cboInteger
        result.obj.valueInt = int64(item.valueInt)
      of cbNegative:
        result.obj.kind = cboInteger
        result.obj.valueInt = -1'i64 - int64(item.valueInt)

      of cbByteString, cbTextString:
        result.obj.kind = cboString
        result.obj.isText = item.kind == cbTextString
        assert parser.itemQueue.head.value.kind == ikRaw, "internal consistency error"
        result.obj.data = parser.itemQueue.pop().data

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
        result.obj.kind = cboInvalid
        result.obj.invalidItem = item

      of cbSimple:
        result.obj.kind = cboInvalid
        result.obj.invalidItem = item

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

      of cbBreak, cbInvalid:
        result.obj.kind = cboInvalid
        result.obj.invalidItem = item

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

    of cboInvalid:
      result = obj.invalidItem

proc encode*(obj: CborObject): string =
  result = obj.item.encode()
  if obj.kind == cboString:
    result.add(obj.data)
  elif obj.kind == cboArray:
    for entry in obj.items:
      result.add(entry.encode())
  elif obj.kind == cboTable:
    for entry in obj.table:
      result.add(entry.key.encode())
      result.add(entry.value.encode())
