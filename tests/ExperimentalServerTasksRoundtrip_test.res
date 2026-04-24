open Vitest

@val external queueMicrotask: (unit => unit) => unit = "queueMicrotask"
@return(nullable) @get external rawTaskContext: unknown => option<McpTaskContext.t> = "task"
@get external requestParams: unknown => unknown = "params"
@get external requestMessages: unknown => array<unknown> = "messages"
@get external requestMessageContent: unknown => unknown = "content"
@get external textContentText: unknown => string = "text"
@get external samplingModel: unknown => string = "model"
@get external samplingRole: unknown => string = "role"
@get external samplingContent: unknown => unknown = "content"
@get external elicitationAction: unknown => string = "action"
@return(nullable) @get external elicitationContent: unknown => option<dict<unknown>> = "content"

let samplingText = request =>
  request
  ->requestParams
  ->requestMessages
  ->Array.get(0)
  ->McpTestBindings.getSome
  ->requestMessageContent
  ->textContentText

let makeSamplingResult = text =>
  Dict.fromArray([
    ("model", "task-model"->McpTestBindings.stringToUnknown),
    ("role", "assistant"->McpTestBindings.stringToUnknown),
    ("content", McpTestBindings.makeTextContent(text)),
  ])
  ->McpTestBindings.dictToUnknown

let makeElicitationResult = code =>
  Dict.fromArray([
    ("action", "accept"->McpTestBindings.stringToUnknown),
    (
      "content",
      Dict.fromArray([("code", code->McpTestBindings.stringToUnknown)])
      ->McpTestBindings.dictToUnknown,
    ),
  ])
  ->McpTestBindings.dictToUnknown

describe("experimental server task roundtrip", () => {
  testAsync("low-level server task streams roundtrip through client task handlers", async t => {
    let expect = value => t->expect(value)
    let clientTaskStore = McpTaskStore.makeInMemory()
    let clientCapabilities =
      Dict.fromArray([
        ("sampling", Dict.fromArray([])->McpTestBindings.dictToUnknown),
        (
          "elicitation",
          Dict.fromArray([("form", Dict.fromArray([])->McpTestBindings.dictToUnknown)])
          ->McpTestBindings.dictToUnknown,
        ),
        (
          "tasks",
          Dict.fromArray([
            ("taskStore", clientTaskStore->McpTestBindings.toUnknown),
            ("defaultTaskPollInterval", 1->McpTestBindings.intToUnknown),
            ("list", Dict.fromArray([])->McpTestBindings.dictToUnknown),
            ("cancel", Dict.fromArray([])->McpTestBindings.dictToUnknown),
            (
              "requests",
              Dict.fromArray([
                (
                  "sampling",
                  Dict.fromArray([("createMessage", Dict.fromArray([])->McpTestBindings.dictToUnknown)])
                  ->McpTestBindings.dictToUnknown,
                ),
                (
                  "elicitation",
                  Dict.fromArray([("create", Dict.fromArray([])->McpTestBindings.dictToUnknown)])
                  ->McpTestBindings.dictToUnknown,
                ),
              ])
              ->McpTestBindings.dictToUnknown,
            ),
          ])
          ->McpTestBindings.dictToUnknown,
        ),
      ])
    let client = McpClient.makeWithOptions(
      McpTestBindings.makeImplementation("stream-client", "1.0.0"),
      McpClientOptions.make(~capabilities=clientCapabilities, ()),
    )
    let server = McpLowLevelServer.make(McpTestBindings.makeImplementation("stream-server", "1.0.0"))
    let pair = McpTestBindings.makeLoopbackTransportPair("stream-task-session")
    let serverTransport = pair->McpTestBindings.loopbackServerTransport
    let clientTransport = pair->McpTestBindings.loopbackClientTransport
    let timeoutOptions = McpRequestOptions.make(~timeout=5000, ())
    let taskOptions =
      McpRequestOptions.make(
        ~timeout=5000,
        ~task=McpTaskCreationParams.make(~ttl=60000, ~pollInterval=1, ()),
        (),
      )

    client->McpTestBindings.setClientRequestHandlerRaw(
      #samplingCreateMessage,
      (request, ctx) => {
        let requestedText = request->samplingText
        let taskContext = ctx->rawTaskContext->McpTestBindings.getSome
        let store = taskContext->McpTaskContext.store

        let run: unit => promise<unknown> = async () => {
          let task =
            await store->McpRequestTaskStore.createTask(
              McpCreateTaskOptions.make(~ttl=60000, ~pollInterval=1, ()),
            )
          await store->McpRequestTaskStore.updateTaskStatus(
            task->McpTask.taskId,
            #working,
            ~statusMessage="sampling",
          )
          if requestedText != "stall" {
            queueMicrotask(() => {
              let _promise = (async () => {
                await store->McpRequestTaskStore.storeTaskResultRaw(
                  task->McpTask.taskId,
                  #completed,
                  makeSamplingResult(requestedText ++ "-response"),
                )
              })()
              ()
            })
          }
          let workingTask = await store->McpRequestTaskStore.getTask(task->McpTask.taskId)
          McpCreateTaskResult.make(~task=workingTask, ())->McpTestBindings.toUnknown
        }

        run()
      },
    )

    client->McpTestBindings.setClientRequestHandlerRaw(
      #elicitationCreate,
      (_request, ctx) => {
        let taskContext = ctx->rawTaskContext->McpTestBindings.getSome
        let store = taskContext->McpTaskContext.store

        let run: unit => promise<unknown> = async () => {
          let task =
            await store->McpRequestTaskStore.createTask(
              McpCreateTaskOptions.make(~ttl=60000, ~pollInterval=1, ()),
            )
          await store->McpRequestTaskStore.updateTaskStatus(
            task->McpTask.taskId,
            #working,
            ~statusMessage="elicitation",
          )
          queueMicrotask(() => {
            let _promise = (async () => {
              await store->McpRequestTaskStore.storeTaskResultRaw(
                task->McpTask.taskId,
                #completed,
                makeElicitationResult("42"),
              )
            })()
            ()
          })
          let workingTask = await store->McpRequestTaskStore.getTask(task->McpTask.taskId)
          McpCreateTaskResult.make(~task=workingTask, ())->McpTestBindings.toUnknown
        }

        run()
      },
    )

    await server->McpLowLevelServer.connect(serverTransport)
    await client->McpClient.connectWithOptions(clientTransport, timeoutOptions)

    let genericMessages =
      await server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.requestStreamRawWithOptions(
          #samplingCreateMessage,
          McpTestBindings.makeSamplingRequestParams(~text="generic", ~maxTokens=16),
          taskOptions,
        )
      ->McpResponseStream.toArray
    let genericTaskId =
      genericMessages
      ->Belt.Array.keepMap(message => message->McpResponseStream.task->Option.map(McpTask.taskId))
      ->Array.get(0)
      ->McpTestBindings.getSome
    let genericResult =
      genericMessages
      ->Belt.Array.keepMap(McpResponseStream.result)
      ->Array.get(0)
      ->McpTestBindings.getSome
    let genericTask =
      await server->McpLowLevelServer.experimentalTasks->McpLowLevelServerExperimentalTasks.getTask(genericTaskId)
    let genericTaskResult =
      await server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.getTaskResultRawWithOptions(genericTaskId, timeoutOptions)

    let createMessageMessages =
      await server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.createMessageStreamRawWithOptions(
          McpTestBindings.makeSamplingRequestParams(~text="direct", ~maxTokens=16),
          taskOptions,
        )
      ->McpResponseStream.toArray
    let createMessageResult =
      createMessageMessages
      ->Belt.Array.keepMap(McpResponseStream.result)
      ->Array.get(0)
      ->McpTestBindings.getSome

    let elicitationMessages =
      await server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.elicitInputStreamRawWithOptions(
          McpTestBindings.makeCodeElicitationRequestParams("Provide a code"),
          taskOptions,
        )
      ->McpResponseStream.toArray
    let elicitationResult =
      elicitationMessages
      ->Belt.Array.keepMap(McpResponseStream.result)
      ->Array.get(0)
      ->McpTestBindings.getSome

    let stalledMessagesPromise =
      server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.createMessageStreamRawWithOptions(
          McpTestBindings.makeSamplingRequestParams(~text="stall", ~maxTokens=16),
          taskOptions,
        )
      ->McpResponseStream.toArray
    await Promise.resolve()
    let listedTasks =
      await server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.listTasksWithOptions(timeoutOptions)
    let stalledTaskId =
      listedTasks
      ->McpListTasksResult.tasks
      ->Belt.Array.keepMap(task =>
          if task->McpTask.status == #working {
            Some(task->McpTask.taskId)
          } else {
            None
          }
        )
      ->Array.get(0)
      ->McpTestBindings.getSome
    let cancelledTask =
      await server
      ->McpLowLevelServer.experimentalTasks
      ->McpLowLevelServerExperimentalTasks.cancelTaskWithOptions(stalledTaskId, timeoutOptions)
    let stalledMessages = await stalledMessagesPromise

    (
      genericMessages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #taskCreated),
      genericMessages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #result),
      genericResult->samplingModel,
      genericResult->samplingRole,
      genericResult->samplingContent->textContentText,
      genericTask->McpGetTaskResult.status,
      genericTaskResult->samplingContent->textContentText,
      createMessageMessages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #taskCreated),
      createMessageResult->samplingContent->textContentText,
      elicitationMessages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #taskCreated),
      elicitationResult->elicitationAction,
      elicitationResult
      ->elicitationContent
      ->Option.flatMap(content => content->Dict.get("code")->Option.map(McpTestBindings.unknownToString)),
      listedTasks
      ->McpListTasksResult.tasks
      ->Array.map(McpTask.taskId)
      ->Belt.Array.some(taskId => taskId == genericTaskId),
      stalledMessages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #taskCreated),
      cancelledTask->McpCancelTaskResult.status,
    )
    ->expect
    ->Expect.toEqual((
      true,
      true,
      "task-model",
      "assistant",
      "generic-response",
      #completed,
      "generic-response",
      true,
      "direct-response",
      true,
      "accept",
      Some("42"),
      true,
      true,
      #cancelled,
    ))

    await TestSupport.settle([
      client->McpTestBindings.closeClient->TestSupport.closeIgnore,
      server->McpTestBindings.closeLowLevelServer->TestSupport.closeIgnore,
      serverTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
      clientTransport->McpTestBindings.transportClose->TestSupport.closeIgnore,
    ])
  })
})
