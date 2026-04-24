open Vitest

module S = RescriptSchema.S

@get external queuedMessagePayload: unknown => unknown = "message"
@get external jsonRpcMethod: unknown => string = "method"

@schema
type storedOutput = {message: string}

let storedOutputStandardSchema = storedOutputSchema->McpStandardSchema.fromRescriptSchema

let queuedMessageKind = message =>
  message
  ->McpTestBindings.unknownToDict
  ->Dict.get("type")
  ->Option.map(McpTestBindings.unknownToString)
  ->McpTestBindings.getSome

let makeJsonRpcRequest = methodName =>
  Dict.fromArray([
    ("jsonrpc", McpTypes.jsonRpcVersion->McpTestBindings.stringToUnknown),
    ("id", 17->McpTestBindings.intToUnknown),
    ("method", methodName->McpTestBindings.stringToUnknown),
    ("params", Dict.fromArray([])->McpTestBindings.dictToUnknown),
  ])
  ->McpTestBindings.dictToUnknown

let makeQueuedNotification = methodName =>
  Dict.fromArray([
    ("type", "notification"->McpTestBindings.stringToUnknown),
    (
      "message",
      Dict.fromArray([
        ("jsonrpc", McpTypes.jsonRpcVersion->McpTestBindings.stringToUnknown),
        ("method", methodName->McpTestBindings.stringToUnknown),
        ("params", Dict.fromArray([])->McpTestBindings.dictToUnknown),
      ])
      ->McpTestBindings.dictToUnknown,
    ),
  ])
  ->McpTestBindings.dictToUnknown

describe("task storage surface", () => {
  testAsync("custom task stores and task message queues dispatch through the bound runtime methods", async t => {
    let expect = value => t->expect(value)
    let baseStore = McpTaskStore.makeInMemory()
    let createCalls = ref(0)
    let getCalls = ref(0)
    let storeResultCalls = ref(0)
    let getResultCalls = ref(0)
    let updateCalls = ref(0)
    let listCalls = ref(0)
    let customStore =
      McpTaskStore.make(
        ~createTask=(taskParams, requestId, request, sessionId) => {
          createCalls := createCalls.contents + 1
          switch sessionId {
          | Some(sessionId) =>
            baseStore->McpTaskStore.createTaskWithSessionId(taskParams, requestId, request, sessionId)
          | None => baseStore->McpTaskStore.createTask(taskParams, requestId, request)
          }
        },
        ~getTask=(taskId, sessionId) => {
          getCalls := getCalls.contents + 1
          switch sessionId {
          | Some(sessionId) => baseStore->McpTaskStore.getTaskWithSessionId(taskId, sessionId)
          | None => baseStore->McpTaskStore.getTask(taskId)
          }
        },
        ~storeTaskResult=(taskId, status, result, sessionId) => {
          storeResultCalls := storeResultCalls.contents + 1
          switch sessionId {
          | Some(sessionId) =>
            baseStore->McpTaskStore.storeTaskResultRawWithSessionId(taskId, status, result, sessionId)
          | None => baseStore->McpTaskStore.storeTaskResultRaw(taskId, status, result)
          }
        },
        ~getTaskResult=(taskId, sessionId) => {
          getResultCalls := getResultCalls.contents + 1
          switch sessionId {
          | Some(sessionId) => baseStore->McpTaskStore.getTaskResultRawWithSessionId(taskId, sessionId)
          | None => baseStore->McpTaskStore.getTaskResultRaw(taskId)
          }
        },
        ~updateTaskStatus=(taskId, status, statusMessage, sessionId) => {
          updateCalls := updateCalls.contents + 1
          switch sessionId {
          | Some(sessionId) =>
            baseStore
            ->McpTaskStore.updateTaskStatusWithSessionId(taskId, status, ~statusMessage?, sessionId)
          | None => baseStore->McpTaskStore.updateTaskStatus(taskId, status, ~statusMessage?, ())
          }
        },
        ~listTasks=(cursor, sessionId) => {
          listCalls := listCalls.contents + 1
          switch (cursor, sessionId) {
          | (Some(cursor), Some(sessionId)) =>
            baseStore->McpTaskStore.listTasksWithCursorAndSessionId(cursor, sessionId)
          | (Some(cursor), None) => baseStore->McpTaskStore.listTasksWithCursor(cursor)
          | (None, Some(sessionId)) => baseStore->McpTaskStore.listTasksWithSessionId(sessionId)
          | (None, None) => baseStore->McpTaskStore.listTasks
          }
        },
        (),
      )
    let createdTask =
      await customStore->McpTaskStore.createTask(
        McpCreateTaskOptions.make(~ttl=5000, ~pollInterval=50, ()),
        1->McpTestBindings.intToRequestId,
        makeJsonRpcRequest("tools/call"),
      )
    let missingTask = await customStore->McpTaskStore.getTask("missing-task")
    let sessionTask =
      await customStore->McpTaskStore.createTaskWithSessionId(
        McpCreateTaskOptions.make(~ttl=5000, ~pollInterval=25, ()),
        2->McpTestBindings.intToRequestId,
        makeJsonRpcRequest("sampling/createMessage"),
        "session-a",
      )

    await customStore->McpTaskStore.updateTaskStatus(createdTask->McpTask.taskId, #working, ~statusMessage="running", ())
    await customStore->McpTaskStore.storeTaskResult(
      createdTask->McpTask.taskId,
      #completed,
      McpCallToolResult.make(
        ~content=[McpContentBlock.text("stored result")],
        ~structuredContent={message: "stored result"},
        (),
      ),
      storedOutputStandardSchema,
    )
    await customStore->McpTaskStore.updateTaskStatusWithSessionId(
      sessionTask->McpTask.taskId,
      #working,
      ~statusMessage="session-running",
      "session-a",
    )
    await customStore->McpTaskStore.storeTaskResultRawWithSessionId(
      sessionTask->McpTask.taskId,
      #failed,
      Dict.fromArray([("error", "session-failed"->McpTestBindings.stringToUnknown)])
      ->McpTestBindings.dictToUnknown,
      "session-a",
    )

    let fetchedTask = await customStore->McpTaskStore.getTask(createdTask->McpTask.taskId)
    let fetchedTaskResult =
      await customStore->McpTaskStore.getTaskResult(
        createdTask->McpTask.taskId,
        storedOutputStandardSchema,
      )
    let sameSessionTask =
      await customStore->McpTaskStore.getTaskWithSessionId(sessionTask->McpTask.taskId, "session-a")
    let wrongSessionTask =
      await customStore->McpTaskStore.getTaskWithSessionId(sessionTask->McpTask.taskId, "session-b")
    let sessionResult =
      await customStore->McpTaskStore.getTaskResultRawWithSessionId(sessionTask->McpTask.taskId, "session-a")
    let listedTasks = await customStore->McpTaskStore.listTasks

    let baseQueue = McpTaskMessageQueue.makeInMemory()
    let enqueueCalls = ref(0)
    let dequeueCalls = ref(0)
    let dequeueAllCalls = ref(0)
    let customQueue =
      McpTaskMessageQueue.make(
        ~enqueue=(taskId, message, sessionId, maxSize) => {
          enqueueCalls := enqueueCalls.contents + 1
          baseQueue->McpTaskMessageQueue.enqueue(taskId, message, ~sessionId?, ~maxSize?, ())
        },
        ~dequeue=(taskId, sessionId) => {
          dequeueCalls := dequeueCalls.contents + 1
          baseQueue->McpTaskMessageQueue.dequeue(taskId, ~sessionId?, ())
        },
        ~dequeueAll=(taskId, sessionId) => {
          dequeueAllCalls := dequeueAllCalls.contents + 1
          baseQueue->McpTaskMessageQueue.dequeueAll(taskId, ~sessionId?, ())
        },
        (),
      )

    await customQueue->McpTaskMessageQueue.enqueue(
      createdTask->McpTask.taskId,
      makeQueuedNotification("notifications/message"),
      (),
    )
    await customQueue->McpTaskMessageQueue.enqueue(
      createdTask->McpTask.taskId,
      makeQueuedNotification("notifications/progress"),
      ~sessionId="session-a",
      ~maxSize=2,
      (),
    )
    let firstQueuedMessage = await customQueue->McpTaskMessageQueue.dequeue(createdTask->McpTask.taskId, ())
    let remainingQueuedMessages =
      await customQueue->McpTaskMessageQueue.dequeueAll(
        createdTask->McpTask.taskId,
        ~sessionId="session-a",
        (),
      )

    (
      missingTask == None,
      fetchedTask->McpTestBindings.getSome->McpTask.status,
      fetchedTaskResult->McpTestBindings.toolResultTexts,
      fetchedTaskResult->McpCallToolResult.structuredContent->Option.map(output => output.message),
      sameSessionTask->Option.map(McpTask.status),
      wrongSessionTask == None,
      sessionResult
      ->McpTestBindings.unknownToDict
      ->Dict.get("error")
      ->Option.map(McpTestBindings.unknownToString),
      listedTasks
      ->McpListTasksResult.tasks
      ->Array.map(McpTask.taskId)
      ->Belt.Array.some(taskId => taskId == createdTask->McpTask.taskId),
      createCalls.contents,
      getCalls.contents,
      storeResultCalls.contents,
      getResultCalls.contents,
      updateCalls.contents,
      listCalls.contents,
      firstQueuedMessage->Option.map(queuedMessageKind),
      firstQueuedMessage->Option.map(message => message->queuedMessagePayload->jsonRpcMethod),
      remainingQueuedMessages->Array.map(queuedMessageKind),
      remainingQueuedMessages->Array.map(message => message->queuedMessagePayload->jsonRpcMethod),
      enqueueCalls.contents,
      dequeueCalls.contents,
      dequeueAllCalls.contents,
    )
    ->expect
    ->Expect.toEqual((
      true,
      #completed,
      ["stored result"],
      Some("stored result"),
      Some(#failed),
      true,
      Some("session-failed"),
      true,
      2,
      4,
      2,
      2,
      2,
      1,
      Some("notification"),
      Some("notifications/message"),
      ["notification"],
      ["notifications/progress"],
      2,
      1,
      1,
    ))
  })
})
