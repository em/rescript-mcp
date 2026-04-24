open Vitest
module S = RescriptSchema.S
module Json = Mcp.Protocol.JsonValue

@schema
type typedOutput = {message: string}

@obj
external makeTaskFixture: (
  ~taskId: string,
  ~status: string,
  ~ttl: int=?,
  ~createdAt: string,
  ~lastUpdatedAt: string,
  ~pollInterval: int=?,
  ~statusMessage: string=?,
  (),
) => McpTask.t = ""

@obj
external makeServerContextFixture: (
  ~mcpReq: unknown,
  ~task: McpTaskContext.t=?,
  (),
) => McpServerContext.t = ""

@obj
external makeServerContextMcpReqFixture: (
  ~id: McpTypes.requestId,
  ~method: string,
  ~signal: Webapi.Fetch.signal,
  (),
) => unknown = ""

@obj
external makeRequestTaskStoreFixture: (
  ~createTask: unknown,
  ~getTask: unknown,
  ~storeTaskResult: unknown,
  ~getTaskResult: unknown,
  ~updateTaskStatus: unknown,
  ~listTasks: unknown,
  (),
) => McpRequestTaskStore.t = ""

@obj
external makeToolRegistered: (
  ~enable: unit => unit,
  ~disable: unit => unit,
  ~update: unknown => unit,
  ~remove: unit => unit,
  (),
) => McpTool.registered = ""

@obj
external makeTransportFixture: (
  ~start: unknown,
  ~close: unknown,
  ~send: unknown,
  ~sessionId: string=?,
  (),
) => McpTransport.t = ""

@obj
external makeResponseMessageFixture: (
  @as("type") ~kind: string,
  ~task: McpTask.t=?,
  ~result: unknown=?,
  ~error: unknown=?,
  (),
) => McpResponseStream.message<unknown> = ""

@obj
external makeStreamFixture: (
  ~label: string,
  (),
) => McpResponseStream.t<unknown> = ""

@obj
external makeClientExperimentalTasksFixture: (
  ~callToolStream: unknown,
  ~requestStream: unknown,
  ~getTask: unknown,
  ~getTaskResult: unknown,
  ~listTasks: unknown,
  ~cancelTask: unknown,
  (),
) => McpClientExperimentalTasks.t = ""

@obj
external makeServerExperimentalTasksFixture: (
  ~requestStream: unknown,
  ~createMessageStream: unknown,
  ~elicitInputStream: unknown,
  ~getTask: unknown,
  ~getTaskResult: unknown,
  ~listTasks: unknown,
  ~cancelTask: unknown,
  (),
) => McpLowLevelServerExperimentalTasks.t = ""

@return(nullable)
@get
external toolUpdateCallback: McpTool.updates<string, typedOutput> => option<
  (string, McpServerContext.t) => promise<McpCallToolResult.raw>,
> = "callback"

@return(nullable)
@get
external toolUpdate0Callback: McpTool.updates0<typedOutput> => option<
  McpServerContext.t => promise<McpCallToolResult.raw>,
> = "callback"

@return(nullable)
@get
external rawToolUpdateCallback: McpTool.rawUpdates<string> => option<
  (string, McpServerContext.t) => promise<McpCallToolResult.raw>,
> = "callback"

@return(nullable)
@get
external rawToolUpdate0Callback: McpTool.rawUpdates0 => option<
  McpServerContext.t => promise<McpCallToolResult.raw>,
> = "callback"

@get
external taskHandlerCreateTask: McpTaskTool.handler<string, typedOutput> => (
  string,
  McpServerContext.t,
) => promise<McpCreateTaskResult.t> = "createTask"

@get
external taskHandlerGetTask: McpTaskTool.handler<string, typedOutput> => (
  string,
  McpServerContext.t,
) => promise<McpGetTaskResult.t> = "getTask"

@get
external taskHandlerGetTaskResult: McpTaskTool.handler<string, typedOutput> => (
  string,
  McpServerContext.t,
) => promise<McpCallToolResult.t<typedOutput>> = "getTaskResult"

@get
external rawTaskHandlerGetTaskResult: McpTaskTool.rawHandler<string> => (
  string,
  McpServerContext.t,
) => promise<McpCallToolResult.raw> = "getTaskResult"

@get
external taskHandler0GetTaskResult: McpTaskTool.handler0<typedOutput> => McpServerContext.t => promise<
  McpCallToolResult.t<typedOutput>,
> = "getTaskResult"

@get
external rawTaskHandler0GetTaskResult: McpTaskTool.rawHandler0 => McpServerContext.t => promise<
  McpCallToolResult.raw,
> = "getTaskResult"

@get
external requestMethod: unknown => string = "method"

let outputSchema = typedOutputSchema->McpStandardSchema.fromRescriptSchema

let meta = Dict.fromArray([("_owner", "coverage"->McpTestBindings.stringToUnknown)])

let encodeCursor = cursor =>
  switch cursor {
  | Some(value) => value
  | None => "<none>"
  }

let encodePresence = option =>
  switch option {
  | Some(_) => "<some>"
  | None => "<none>"
  }

let rawStructuredMessage = (result: McpCallToolResult.raw) =>
  result
  ->McpCallToolResult.structuredContentRaw
  ->Option.flatMap(dict =>
      dict->Dict.get("message")->Option.flatMap(value =>
        switch value {
        | Json.String(text) => Some(text)
        | _ => None
        }
      )
    )

let stringField = (value, field) =>
  value->McpTestBindings.toDict->Dict.get(field)->Option.map(McpTestBindings.unknownToString)

describe("public wrapper coverage", () => {
  test("protocol builders preserve public typed fields", t => {
    let expect = value => t->expect(value)
    let workingTask = makeTaskFixture(
      ~taskId="task-1",
      ~status="working",
      ~ttl=5000,
      ~createdAt="2026-04-24T00:00:00Z",
      ~lastUpdatedAt="2026-04-24T00:00:10Z",
      ~pollInterval=250,
      ~statusMessage="running",
      (),
    )
    let cancelledTask = makeTaskFixture(
      ~taskId="task-2",
      ~status="cancelled",
      ~createdAt="2026-04-24T00:01:00Z",
      ~lastUpdatedAt="2026-04-24T00:01:10Z",
      (),
    )
    let completeArgument = McpCompleteParams.makeArgument(~name="topic", ~value="bindings", ())
    let completeContext =
      McpCompleteParams.makeContext(~argumentValues=Dict.fromArray([("extra", "context")]), ())
    let completePrompt =
      McpCompleteParams.makeWithPrompt(
        ~ref=McpCompleteParams.promptReference("review"),
        ~argument=completeArgument,
        ~context=completeContext,
        ~_meta=meta,
        (),
      )
    let completeResource =
      McpCompleteParams.makeWithResource(
        ~ref=McpCompleteParams.resourceReference("memo://alpha"),
        ~argument=completeArgument,
        (),
      )
    let callParams =
      McpCallToolParams.make(
        ~name="echo",
        ~argumentValues=Dict.fromArray([("message", Json.string("hello"))]),
        ~task=McpCreateTaskOptions.make(~ttl=60, ~pollInterval=5, ()),
        ~_meta=meta,
        (),
      )
    let promptParams =
      McpGetPromptParams.make(
        ~name="summary",
        ~argumentValues=Dict.fromArray([("topic", "bindings")]),
        ~_meta=meta,
        (),
      )
    let resourceParams = McpResourceRequestParams.make(~uri="memo://alpha", ~_meta=meta, ())
    let icon =
      McpIcon.make(
        ~src="icon.svg",
        ~mimeType="image/svg+xml",
        ~sizes=["16x16", "32x32"],
        ~theme=#dark,
        (),
      )
    let promptMessage = McpPromptMessage.make(~role=#assistant, ~content=McpContentBlock.text("inspect"))
    let promptText = McpPromptMessage.text(~role=#user, ~text="review")
    let textContents =
      McpResourceContents.text(~uri="memo://alpha", ~text="alpha", ~mimeType="text/plain", ())
    let blobContents = McpResourceContents.blob(~uri="memo://beta", ~blob="YmV0YQ==", ())
    let createTaskResult = McpCreateTaskResult.make(~task=workingTask, ())
    let getTaskResult =
      McpGetTaskResult.make(
        ~taskId="task-1",
        ~status=#working,
        ~ttl=5000,
        ~createdAt="2026-04-24T00:00:00Z",
        ~lastUpdatedAt="2026-04-24T00:00:10Z",
        ~pollInterval=250,
        ~statusMessage="running",
        (),
      )
    let getTaskResultFromTask = McpGetTaskResult.ofTask(workingTask)
    let cancelTaskResult =
      McpCancelTaskResult.make(
        ~taskId="task-2",
        ~status=#cancelled,
        ~createdAt="2026-04-24T00:01:00Z",
        ~lastUpdatedAt="2026-04-24T00:01:10Z",
        (),
      )
    let cancelTaskResultFromTask = McpCancelTaskResult.ofTask(cancelledTask)
    let listTasksResult = McpListTasksResult.make(~tasks=[workingTask, cancelledTask], ~nextCursor="cursor-2", ())

    (
      completePrompt->McpCompleteParams.argumentValue->McpCompleteParams.argumentName,
      completePrompt->McpCompleteParams.argumentValue->McpCompleteParams.argumentCurrentValue,
      completePrompt
      ->McpCompleteParams.contextValue
      ->Option.flatMap(context => context->McpCompleteParams.contextArguments->Option.flatMap(args => args->Dict.get("extra"))),
      completePrompt
      ->McpCompleteParams.meta
      ->Option.flatMap(meta => meta->Dict.get("_owner")->Option.map(McpTestBindings.unknownToString)),
      completePrompt
      ->McpTestBindings.toDict
      ->Dict.get("ref")
      ->Option.flatMap(ref =>
          ref
          ->McpTestBindings.toDict
          ->Dict.get("type")
          ->Option.map(McpTestBindings.unknownToString)
        ),
      completeResource
      ->McpTestBindings.toDict
      ->Dict.get("ref")
      ->Option.flatMap(ref =>
          ref
          ->McpTestBindings.toDict
          ->Dict.get("uri")
          ->Option.map(McpTestBindings.unknownToString)
        ),
      callParams->McpCallToolParams.name,
      callParams->McpCallToolParams.argumentValues->Option.flatMap(args =>
        args->Dict.get("message")->Option.flatMap(value =>
          switch value {
          | Json.String(text) => Some(text)
          | _ => None
          }
        )
      ),
      callParams->McpCallToolParams.task != None,
      callParams
      ->McpCallToolParams.meta
      ->Option.flatMap(meta => meta->Dict.get("_owner")->Option.map(McpTestBindings.unknownToString)),
      promptParams->McpGetPromptParams.name,
      promptParams->McpGetPromptParams.argumentValues->Option.flatMap(args => args->Dict.get("topic")),
      promptParams
      ->McpGetPromptParams.meta
      ->Option.flatMap(meta => meta->Dict.get("_owner")->Option.map(McpTestBindings.unknownToString)),
      resourceParams->McpResourceRequestParams.uri,
      resourceParams
      ->McpResourceRequestParams.meta
      ->Option.flatMap(meta => meta->Dict.get("_owner")->Option.map(McpTestBindings.unknownToString)),
      icon->McpIcon.src,
      icon->McpIcon.mimeType,
      icon->McpIcon.sizes->Option.map(Array.length),
      icon->McpIcon.theme,
      promptMessage->McpPromptMessage.role,
      promptMessage->McpPromptMessage.content->McpContentBlock.textValue,
      promptText->McpPromptMessage.role,
      promptText->McpPromptMessage.content->McpContentBlock.textValue,
      textContents->McpResourceContents.kind,
      textContents->McpResourceContents.textValue,
      blobContents->McpResourceContents.kind,
      blobContents->McpResourceContents.blobValue,
      createTaskResult->McpCreateTaskResult.task->McpTask.taskId,
      getTaskResult->McpGetTaskResult.status,
      getTaskResult->McpGetTaskResult.ttl,
      getTaskResult->McpGetTaskResult.pollInterval,
      getTaskResultFromTask->McpGetTaskResult.statusMessage,
      cancelTaskResult->McpCancelTaskResult.status,
      cancelTaskResultFromTask->McpCancelTaskResult.status,
      listTasksResult->McpListTasksResult.tasks->Array.map(McpTask.taskId),
      listTasksResult->McpListTasksResult.nextCursor,
      workingTask->McpTask.status,
      workingTask->McpTask.statusMessage,
      #inputRequired->McpTaskStatus.toString,
      "completed"->McpTaskStatus.fromString,
      #completed->McpTaskStatus.isTerminal,
      #working->McpTaskStatus.isTerminal,
      #failed->McpTaskResultStatus.toString,
      "completed"->McpTaskResultStatus.fromString,
    )
    ->expect
    ->Expect.toEqual((
      "topic",
      "bindings",
      Some("context"),
      Some("coverage"),
      Some("ref/prompt"),
      Some("memo://alpha"),
      "echo",
      Some("hello"),
      true,
      Some("coverage"),
      "summary",
      Some("bindings"),
      Some("coverage"),
      "memo://alpha",
      Some("coverage"),
      "icon.svg",
      Some("image/svg+xml"),
      Some(2),
      Some(#dark),
      #assistant,
      Some("inspect"),
      #user,
      Some("review"),
      #text,
      Some("alpha"),
      #blob,
      Some("YmV0YQ=="),
      "task-1",
      #working,
      Some(5000),
      Some(250),
      Some("running"),
      #cancelled,
      #cancelled,
      ["task-1", "task-2"],
      Some("cursor-2"),
      #working,
      Some("running"),
      "input_required",
      #completed,
      true,
      false,
      "failed",
      #completed,
    ))
  })

  testAsync("typed tool and task-tool wrappers keep typed output on the public path", async t => {
    let expect = value => t->expect(value)
    let abortController = Webapi.Fetch.AbortController.make()
    let serverContext =
      makeServerContextFixture(
        ~mcpReq=makeServerContextMcpReqFixture(
          ~id=1->McpTestBindings.intToRequestId,
          ~method="tools/call",
          ~signal=abortController->Webapi.Fetch.AbortController.signal,
          (),
        ),
        (),
      )
    let workingTask = makeTaskFixture(
      ~taskId="task-typed",
      ~status="working",
      ~createdAt="2026-04-24T00:02:00Z",
      ~lastUpdatedAt="2026-04-24T00:02:10Z",
      (),
    )
    let toolConfig = McpTool.makeConfig(~title="Echo", ~outputSchema, ~_meta=meta, ())
    let rawToolConfig = McpTool.makeRawConfig(~title="Raw Echo", ~_meta=meta, ())
    let typedUpdates =
      McpTool.makeUpdates(
        ~name="echo",
        ~outputSchema,
        ~_meta=meta,
        ~callback=((value: string), _ctx) =>
          Promise.resolve(
            McpCallToolResult.make(
              ~content=[McpContentBlock.text(`typed:${value}`)],
              ~structuredContent={message: value},
              (),
            ),
          ),
        (),
      )
    let typedUpdates0 =
      McpTool.makeUpdates0(
        ~name="echo0",
        ~outputSchema,
        ~callback=(_ctx =>
          Promise.resolve(
            McpCallToolResult.make(
              ~content=[McpContentBlock.text("typed:zero")],
              ~structuredContent={message: "zero"},
              (),
            ),
          )),
        (),
      )
    let rawUpdates =
      McpTool.makeRawUpdates(
        ~name="raw",
        ~callback=((value: string), _ctx) =>
          Promise.resolve(
            McpCallToolResult.makeRaw(
              ~content=[McpContentBlock.text(`raw:${value}`)],
              ~structuredContent=Dict.fromArray([("message", Json.string(value))]),
              (),
            ),
          ),
        (),
      )
    let rawUpdates0 =
      McpTool.makeRawUpdates0(
        ~name="raw0",
        ~callback=(_ctx =>
          Promise.resolve(
            McpCallToolResult.makeRaw(
              ~content=[McpContentBlock.text("raw:zero")],
              ~structuredContent=Dict.fromArray([("message", Json.string("zero"))]),
              (),
            ),
          )),
        (),
      )
    let typedUpdate = typedUpdates->toolUpdateCallback->McpTestBindings.getSome
    let typedUpdate0 = typedUpdates0->toolUpdate0Callback->McpTestBindings.getSome
    let rawUpdate = rawUpdates->rawToolUpdateCallback->McpTestBindings.getSome
    let rawUpdate0 = rawUpdates0->rawToolUpdate0Callback->McpTestBindings.getSome
    let typedUpdateResult = await typedUpdate("hello", serverContext)
    let typedUpdate0Result = await typedUpdate0(serverContext)
    let rawUpdateResult = await rawUpdate("raw-hello", serverContext)
    let rawUpdate0Result = await rawUpdate0(serverContext)
    let toolCounts = ref((0, 0, 0, 0))
    let registered =
      makeToolRegistered(
        ~enable=() => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e + 1, d, u, r) },
        ~disable=() => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e, d + 1, u, r) },
        ~update=_ => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e, d, u + 1, r) },
        ~remove=() => toolCounts := switch toolCounts.contents { | (e, d, u, r) => (e, d, u, r + 1) },
        (),
      )

    registered->McpTool.enable
    registered->McpTool.disable
    registered->McpTool.update(typedUpdates)
    registered->McpTool.updateRaw(rawUpdates)
    registered->McpTool.update0(typedUpdates0)
    registered->McpTool.updateRaw0(rawUpdates0)
    registered->McpTool.remove

    let execution = McpTaskTool.makeExecution(~taskSupport=#required, ())
    let taskToolConfig =
      McpTaskTool.makeConfig(~title="Task Echo", ~outputSchema, ~execution, ~_meta=meta, ())
    let rawTaskToolConfig = McpTaskTool.makeRawConfig(~title="Raw Task Echo", ~execution, ~_meta=meta, ())
    let taskHandler =
      McpTaskTool.makeHandler(
        ~createTask=((_value: string, _ctx) =>
          Promise.resolve(McpCreateTaskResult.make(~task=workingTask, ()))
        ),
        ~getTask=((_value: string, _ctx) => Promise.resolve(McpGetTaskResult.ofTask(workingTask))),
        ~getTaskResult=((value: string, _ctx) =>
          Promise.resolve(
            McpCallToolResult.make(
              ~content=[McpContentBlock.text(`task:${value}`)],
              ~structuredContent={message: value},
              (),
            ),
          )
        ),
        (),
      )
    let rawTaskHandler =
      McpTaskTool.makeRawHandler(
        ~createTask=((_value: string, _ctx) =>
          Promise.resolve(McpCreateTaskResult.make(~task=workingTask, ()))
        ),
        ~getTask=((_value: string, _ctx) => Promise.resolve(McpGetTaskResult.ofTask(workingTask))),
        ~getTaskResult=((value: string, _ctx) =>
          Promise.resolve(
            McpCallToolResult.makeRaw(
              ~content=[McpContentBlock.text(`raw-task:${value}`)],
              ~structuredContent=Dict.fromArray([("message", Json.string(value))]),
              (),
            ),
          )
        ),
        (),
      )
    let taskHandler0 =
      McpTaskTool.makeHandler0(
        ~createTask=(_ctx => Promise.resolve(McpCreateTaskResult.make(~task=workingTask, ()))),
        ~getTask=(_ctx => Promise.resolve(McpGetTaskResult.ofTask(workingTask))),
        ~getTaskResult=(_ctx =>
          Promise.resolve(
            McpCallToolResult.make(
              ~content=[McpContentBlock.text("task:zero")],
              ~structuredContent={message: "zero-task"},
              (),
            ),
          )),
        (),
      )
    let rawTaskHandler0 =
      McpTaskTool.makeRawHandler0(
        ~createTask=(_ctx => Promise.resolve(McpCreateTaskResult.make(~task=workingTask, ()))),
        ~getTask=(_ctx => Promise.resolve(McpGetTaskResult.ofTask(workingTask))),
        ~getTaskResult=(_ctx =>
          Promise.resolve(
            McpCallToolResult.makeRaw(
              ~content=[McpContentBlock.text("raw-task:zero")],
              ~structuredContent=Dict.fromArray([("message", Json.string("zero-raw"))]),
              (),
            ),
          )),
        (),
      )
    let createTask = taskHandler->taskHandlerCreateTask
    let getTask = taskHandler->taskHandlerGetTask
    let getTaskResult = taskHandler->taskHandlerGetTaskResult
    let getRawTaskResult = rawTaskHandler->rawTaskHandlerGetTaskResult
    let getTaskResult0 = taskHandler0->taskHandler0GetTaskResult
    let getRawTaskResult0 = rawTaskHandler0->rawTaskHandler0GetTaskResult
    let taskCreateResult = await createTask("ignored", serverContext)
    let taskGetResult = await getTask("ignored", serverContext)
    let taskTypedResult = await getTaskResult("typed-task", serverContext)
    let taskRawResult = await getRawTaskResult("raw-task", serverContext)
    let taskTyped0Result = await getTaskResult0(serverContext)
    let taskRaw0Result = await getRawTaskResult0(serverContext)

    (
      toolConfig->McpTestBindings.toDict->Dict.get("outputSchema") != None,
      rawToolConfig->McpTestBindings.toDict->Dict.get("outputSchema") == None,
      typedUpdateResult->rawStructuredMessage,
      typedUpdate0Result->rawStructuredMessage,
      rawUpdateResult->rawStructuredMessage,
      rawUpdate0Result->rawStructuredMessage,
      toolCounts.contents,
      execution->stringField("taskSupport"),
      taskToolConfig->McpTestBindings.toDict->Dict.get("outputSchema") != None,
      rawTaskToolConfig->McpTestBindings.toDict->Dict.get("outputSchema") == None,
      taskCreateResult->McpCreateTaskResult.task->McpTask.taskId,
      taskGetResult->McpGetTaskResult.status,
      taskTypedResult->McpCallToolResult.structuredContent->Option.map(value => value.message),
      taskRawResult->rawStructuredMessage,
      taskTyped0Result->McpCallToolResult.structuredContent->Option.map(value => value.message),
      taskRaw0Result->rawStructuredMessage,
    )
    ->expect
    ->Expect.toEqual((
      true,
      true,
      Some("hello"),
      Some("zero"),
      Some("raw-hello"),
      Some("zero"),
      (1, 1, 4, 1),
      Some("required"),
      true,
      true,
      "task-typed",
      #working,
      Some("typed-task"),
      Some("raw-task"),
      Some("zero-task"),
      Some("zero-raw"),
    ))
  })

  testAsync("task-store transport and response-stream wrappers dispatch through runtime objects", async t => {
    let expect = value => t->expect(value)
    let storeTask = makeTaskFixture(
      ~taskId="stored-task",
      ~status="working",
      ~ttl=1200,
      ~createdAt="2026-04-24T00:03:00Z",
      ~lastUpdatedAt="2026-04-24T00:03:01Z",
      ~pollInterval=20,
      ~statusMessage="queued",
      (),
    )
    let listResult = McpListTasksResult.make(~tasks=[storeTask], ~nextCursor="next-store", ())
    let storedStatuses = ref([])
    let storedMessages = ref([])
    let listCursors = ref([])
    let store =
      makeRequestTaskStoreFixture(
        ~createTask=((_params: McpCreateTaskOptions.t) => Promise.resolve(storeTask))->McpTestBindings.toUnknown,
        ~getTask=((_taskId: string) => Promise.resolve(storeTask))->McpTestBindings.toUnknown,
        ~storeTaskResult=((_taskId: string, status: string, result: unknown) => {
          storedStatuses := [status, ...storedStatuses.contents]
          storedMessages := [
            result->McpTestBindings.rawCallToolResult->rawStructuredMessage->Option.getOr("missing"),
            ...storedMessages.contents,
          ]
          Promise.resolve()
        })->McpTestBindings.toUnknown,
        ~getTaskResult=((_taskId: string) =>
          Promise.resolve(
            McpCallToolResult.makeRaw(
              ~content=[McpContentBlock.text("stored")],
              ~structuredContent=Dict.fromArray([("message", Json.string("stored"))]),
              (),
            ),
          ))->McpTestBindings.toUnknown,
        ~updateTaskStatus=((_taskId: string, _status: string, _statusMessage: string) =>
          Promise.resolve()
        )->McpTestBindings.toUnknown,
        ~listTasks=((cursor: option<string>) => {
          listCursors := [cursor->encodeCursor, ...listCursors.contents]
          Promise.resolve(listResult)
        })->McpTestBindings.toUnknown,
        (),
      )
    let typedResult =
      await store
      ->McpRequestTaskStore.getTaskResult("stored-task", outputSchema)
    let rawStoredResult =
      await store->McpRequestTaskStore.getTaskResultRaw("stored-task")

    let _ =
      await store->McpRequestTaskStore.createTask(McpCreateTaskOptions.make(~ttl=1200, ~pollInterval=20, ()))
    let _ = await store->McpRequestTaskStore.getTask("stored-task")
    await store->McpRequestTaskStore.storeTaskResult(
      "stored-task",
      #completed,
      McpCallToolResult.make(
        ~content=[McpContentBlock.text("typed-store")],
        ~structuredContent={message: "typed-store"},
        (),
      ),
      outputSchema,
    )
    await store->McpRequestTaskStore.storeTaskResultRaw(
      "stored-task",
      #failed,
      McpCallToolResult.makeRaw(
        ~content=[McpContentBlock.text("raw-store")],
        ~structuredContent=Dict.fromArray([("message", Json.string("raw-store"))]),
        (),
      )->McpTestBindings.toUnknown,
    )
    await store->McpRequestTaskStore.updateTaskStatus("stored-task", #working, ~statusMessage="running")
    let listed = await store->McpRequestTaskStore.listTasks
    let listedWithCursor = await store->McpRequestTaskStore.listTasksWithCursor("cursor-1")

    let transportCalls = ref((0, 0))
    let sendKinds = ref([])
    let sendOptions = ref([])
    let transport =
      makeTransportFixture(
        ~start=(() => {
          transportCalls := switch transportCalls.contents { | (startCount, closeCount) => (startCount + 1, closeCount) }
          Promise.resolve()
        })->McpTestBindings.toUnknown,
        ~close=(() => {
          transportCalls := switch transportCalls.contents { | (startCount, closeCount) => (startCount, closeCount + 1) }
          Promise.resolve()
        })->McpTestBindings.toUnknown,
        ~send=((payload: unknown, options: option<McpTransportSendOptions.t>) => {
          sendKinds := [
            payload
            ->McpTestBindings.toDict
            ->Dict.get("kind")
            ->Option.map(McpTestBindings.unknownToString)
            ->Option.getOr("missing"),
            ...sendKinds.contents,
          ]
          sendOptions := [options->encodePresence, ...sendOptions.contents]
          Promise.resolve()
        })->McpTestBindings.toUnknown,
        ~sessionId="transport-session",
        (),
      )

    await transport->McpTransport.start
    await transport->McpTransport.send(
      Dict.fromArray([("kind", "plain"->McpTestBindings.stringToUnknown)])->McpTestBindings.dictToUnknown,
    )
    await transport->McpTransport.sendWithOptions(
      Dict.fromArray([("kind", "with-options"->McpTestBindings.stringToUnknown)])->McpTestBindings.dictToUnknown,
      Mcp.Protocol.TransportSendOptions.make(~resumptionToken="resume-1", ()),
    )
    await transport->McpTransport.close

    let taskCreatedMessage = makeResponseMessageFixture(~kind="taskCreated", ~task=storeTask, ())
    let taskStatusMessage = makeResponseMessageFixture(~kind="taskStatus", ~task=storeTask, ())
    let resultMessage =
      makeResponseMessageFixture(
        ~kind="result",
        ~result="stream-result"->McpTestBindings.stringToUnknown,
        (),
      )
    let errorMessage =
      makeResponseMessageFixture(
        ~kind="error",
        ~error="stream-error"->McpTestBindings.stringToUnknown,
        (),
      )

    (
      typedResult->McpCallToolResult.structuredContent->Option.map(value => value.message),
      rawStoredResult->McpTestBindings.rawCallToolResult->rawStructuredMessage,
      storedStatuses.contents,
      storedMessages.contents,
      listed->McpListTasksResult.nextCursor,
      listedWithCursor->McpListTasksResult.tasks->Array.map(McpTask.taskId),
      listCursors.contents,
      transport->McpTransport.sessionId,
      transportCalls.contents,
      sendKinds.contents,
      sendOptions.contents,
      [
        taskCreatedMessage->McpResponseStream.kind,
        taskStatusMessage->McpResponseStream.kind,
        resultMessage->McpResponseStream.kind,
        errorMessage->McpResponseStream.kind,
      ],
      taskCreatedMessage->McpResponseStream.task->Option.map(McpTask.taskId),
      resultMessage->McpResponseStream.result->Option.map(McpTestBindings.unknownToString),
      errorMessage->McpResponseStream.error->Option.map(McpTestBindings.unknownToString),
    )
    ->expect
    ->Expect.toEqual((
      Some("stored"),
      Some("stored"),
      ["failed", "completed"],
      ["raw-store", "typed-store"],
      Some("next-store"),
      ["stored-task"],
      ["cursor-1", "<none>"],
      Some("transport-session"),
      (1, 1),
      ["with-options", "plain"],
      ["<some>", "<none>"],
      [#taskCreated, #taskStatus, #result, #error],
      Some("stored-task"),
      Some("stream-result"),
      Some("stream-error"),
    ))
  })

  testAsync("experimental task wrappers dispatch through the installed public task methods", async t => {
    let expect = value => t->expect(value)
    let workingTask = makeTaskFixture(
      ~taskId="exp-task",
      ~status="working",
      ~createdAt="2026-04-24T00:04:00Z",
      ~lastUpdatedAt="2026-04-24T00:04:01Z",
      (),
    )
    let cancelledTask = makeTaskFixture(
      ~taskId="exp-cancelled",
      ~status="cancelled",
      ~createdAt="2026-04-24T00:04:10Z",
      ~lastUpdatedAt="2026-04-24T00:04:11Z",
      (),
    )
    let listResult = McpListTasksResult.make(~tasks=[workingTask], ~nextCursor="exp-next", ())
    let clientStream = makeStreamFixture(~label="client-stream", ())
    let serverStream = makeStreamFixture(~label="server-stream", ())
    let options = McpRequestOptions.make(~timeout=1000, ())
    let clientCallNames = ref([])
    let clientRequestMethods = ref([])
    let clientListCursors = ref([])
    let serverRequestMethods = ref([])
    let serverCreateKinds = ref([])
    let serverElicitKinds = ref([])
    let serverListCursors = ref([])

    let clientTasks =
      makeClientExperimentalTasksFixture(
        ~callToolStream=((params: dict<unknown>, _options: option<McpRequestOptions.t>) => {
          clientCallNames := [
            params->Dict.get("name")->Option.map(McpTestBindings.unknownToString)->Option.getOr("missing"),
            ...clientCallNames.contents,
          ]
          clientStream
        })->McpTestBindings.toUnknown,
        ~requestStream=((request: unknown, _options: option<McpRequestOptions.t>) => {
          clientRequestMethods := [request->requestMethod, ...clientRequestMethods.contents]
          clientStream
        })->McpTestBindings.toUnknown,
        ~getTask=((_taskId: string, _options: option<McpRequestOptions.t>) =>
          Promise.resolve(McpGetTaskResult.ofTask(workingTask)))->McpTestBindings.toUnknown,
        ~getTaskResult=((_taskId: string, _options: option<McpRequestOptions.t>) =>
          Promise.resolve("client-raw"->McpTestBindings.stringToUnknown))->McpTestBindings.toUnknown,
        ~listTasks=((cursor: option<string>, _options: option<McpRequestOptions.t>) => {
          clientListCursors := [cursor->encodeCursor, ...clientListCursors.contents]
          Promise.resolve(listResult)
        })->McpTestBindings.toUnknown,
        ~cancelTask=((_taskId: string, _options: option<McpRequestOptions.t>) =>
          Promise.resolve(McpCancelTaskResult.ofTask(cancelledTask)))->McpTestBindings.toUnknown,
        (),
      )

    let serverTasks =
      makeServerExperimentalTasksFixture(
        ~requestStream=((request: unknown, _options: option<McpRequestOptions.t>) => {
          serverRequestMethods := [request->requestMethod, ...serverRequestMethods.contents]
          serverStream
        })->McpTestBindings.toUnknown,
        ~createMessageStream=((params: dict<unknown>, _options: option<McpRequestOptions.t>) => {
          serverCreateKinds := [
            params->Dict.get("kind")->Option.map(McpTestBindings.unknownToString)->Option.getOr("missing"),
            ...serverCreateKinds.contents,
          ]
          serverStream
        })->McpTestBindings.toUnknown,
        ~elicitInputStream=((params: dict<unknown>, _options: option<McpRequestOptions.t>) => {
          serverElicitKinds := [
            params->Dict.get("kind")->Option.map(McpTestBindings.unknownToString)->Option.getOr("missing"),
            ...serverElicitKinds.contents,
          ]
          serverStream
        })->McpTestBindings.toUnknown,
        ~getTask=((_taskId: string, _options: option<McpRequestOptions.t>) =>
          Promise.resolve(McpGetTaskResult.ofTask(workingTask)))->McpTestBindings.toUnknown,
        ~getTaskResult=((_taskId: string, _options: option<McpRequestOptions.t>) =>
          Promise.resolve("server-raw"->McpTestBindings.stringToUnknown))->McpTestBindings.toUnknown,
        ~listTasks=((cursor: option<string>, _options: option<McpRequestOptions.t>) => {
          serverListCursors := [cursor->encodeCursor, ...serverListCursors.contents]
          Promise.resolve(listResult)
        })->McpTestBindings.toUnknown,
        ~cancelTask=((_taskId: string, _options: option<McpRequestOptions.t>) =>
          Promise.resolve(McpCancelTaskResult.ofTask(cancelledTask)))->McpTestBindings.toUnknown,
        (),
      )

    clientTasks
    ->McpClientExperimentalTasks.callToolStreamRaw(
        Dict.fromArray([("name", "echo"->McpTestBindings.stringToUnknown)]),
      )
    ->ignore
    clientTasks
    ->McpClientExperimentalTasks.callToolStreamRawWithOptions(
        Dict.fromArray([("name", "echo"->McpTestBindings.stringToUnknown)]),
        options,
      )
    ->ignore
    clientTasks
    ->McpClientExperimentalTasks.requestStreamRaw(
        #toolsCall,
        Dict.fromArray([("kind", "client"->McpTestBindings.stringToUnknown)]),
      )
    ->ignore
    clientTasks
    ->McpClientExperimentalTasks.requestStreamRawWithOptions(
        #rootsList,
        Dict.fromArray([("kind", "client"->McpTestBindings.stringToUnknown)]),
        options,
      )
    ->ignore
    let clientTask = await clientTasks->McpClientExperimentalTasks.getTask("exp-task")
    let clientTaskWithOptions = await clientTasks->McpClientExperimentalTasks.getTaskWithOptions("exp-task", options)
    let clientRaw = await clientTasks->McpClientExperimentalTasks.getTaskResultRaw("exp-task")
    let clientRawWithOptions =
      await clientTasks->McpClientExperimentalTasks.getTaskResultRawWithOptions("exp-task", options)
    let _ = await clientTasks->McpClientExperimentalTasks.listTasks
    let _ = await clientTasks->McpClientExperimentalTasks.listTasksWithCursor("cursor-client-1")
    let _ = await clientTasks->McpClientExperimentalTasks.listTasksWithOptions(options)
    let _ =
      await clientTasks->McpClientExperimentalTasks.listTasksWithCursorAndOptions(
        "cursor-client-2",
        options,
      )
    let clientCancelled = await clientTasks->McpClientExperimentalTasks.cancelTask("exp-cancelled")
    let clientCancelledWithOptions =
      await clientTasks->McpClientExperimentalTasks.cancelTaskWithOptions("exp-cancelled", options)

    serverTasks
    ->McpLowLevelServerExperimentalTasks.requestStreamRaw(
        #samplingCreateMessage,
        Dict.fromArray([("kind", "server"->McpTestBindings.stringToUnknown)]),
      )
    ->ignore
    serverTasks
    ->McpLowLevelServerExperimentalTasks.requestStreamRawWithOptions(
        #tasksList,
        Dict.fromArray([("kind", "server"->McpTestBindings.stringToUnknown)]),
        options,
      )
    ->ignore
    serverTasks
    ->McpLowLevelServerExperimentalTasks.createMessageStreamRaw(
        Dict.fromArray([("kind", "create"->McpTestBindings.stringToUnknown)]),
      )
    ->ignore
    serverTasks
    ->McpLowLevelServerExperimentalTasks.createMessageStreamRawWithOptions(
        Dict.fromArray([("kind", "create-with-options"->McpTestBindings.stringToUnknown)]),
        options,
      )
    ->ignore
    serverTasks
    ->McpLowLevelServerExperimentalTasks.elicitInputStreamRaw(
        Dict.fromArray([("kind", "elicit"->McpTestBindings.stringToUnknown)]),
      )
    ->ignore
    serverTasks
    ->McpLowLevelServerExperimentalTasks.elicitInputStreamRawWithOptions(
        Dict.fromArray([("kind", "elicit-with-options"->McpTestBindings.stringToUnknown)]),
        options,
      )
    ->ignore
    let serverTask = await serverTasks->McpLowLevelServerExperimentalTasks.getTask("exp-task")
    let serverTaskWithOptions =
      await serverTasks->McpLowLevelServerExperimentalTasks.getTaskWithOptions("exp-task", options)
    let serverRaw = await serverTasks->McpLowLevelServerExperimentalTasks.getTaskResultRaw("exp-task")
    let serverRawWithOptions =
      await serverTasks->McpLowLevelServerExperimentalTasks.getTaskResultRawWithOptions("exp-task", options)
    let _ = await serverTasks->McpLowLevelServerExperimentalTasks.listTasks
    let _ = await serverTasks->McpLowLevelServerExperimentalTasks.listTasksWithCursor("cursor-server-1")
    let _ = await serverTasks->McpLowLevelServerExperimentalTasks.listTasksWithOptions(options)
    let _ =
      await serverTasks->McpLowLevelServerExperimentalTasks.listTasksWithCursorAndOptions(
        "cursor-server-2",
        options,
      )
    let serverCancelled = await serverTasks->McpLowLevelServerExperimentalTasks.cancelTask("exp-cancelled")
    let serverCancelledWithOptions =
      await serverTasks->McpLowLevelServerExperimentalTasks.cancelTaskWithOptions("exp-cancelled", options)

    (
      clientCallNames.contents,
      clientRequestMethods.contents,
      clientListCursors.contents,
      clientTask->McpGetTaskResult.status,
      clientTaskWithOptions->McpGetTaskResult.status,
      clientRaw->McpTestBindings.unknownToString,
      clientRawWithOptions->McpTestBindings.unknownToString,
      clientCancelled->McpCancelTaskResult.status,
      clientCancelledWithOptions->McpCancelTaskResult.status,
      serverRequestMethods.contents,
      serverCreateKinds.contents,
      serverElicitKinds.contents,
      serverListCursors.contents,
      serverTask->McpGetTaskResult.status,
      serverTaskWithOptions->McpGetTaskResult.status,
      serverRaw->McpTestBindings.unknownToString,
      serverRawWithOptions->McpTestBindings.unknownToString,
      serverCancelled->McpCancelTaskResult.status,
      serverCancelledWithOptions->McpCancelTaskResult.status,
    )
    ->expect
    ->Expect.toEqual((
      ["echo", "echo"],
      ["roots/list", "tools/call"],
      ["cursor-client-2", "<none>", "cursor-client-1", "<none>"],
      #working,
      #working,
      "client-raw",
      "client-raw",
      #cancelled,
      #cancelled,
      ["tasks/list", "sampling/createMessage"],
      ["create-with-options", "create"],
      ["elicit-with-options", "elicit"],
      ["cursor-server-2", "<none>", "cursor-server-1", "<none>"],
      #working,
      #working,
      "server-raw",
      "server-raw",
      #cancelled,
      #cancelled,
    ))
  })
})
