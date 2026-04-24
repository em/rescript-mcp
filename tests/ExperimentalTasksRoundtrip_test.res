open Vitest
module S = RescriptSchema.S
module Json = Mcp.Protocol.JsonValue

@schema
type taskArgs = {message: string}

@schema
type taskOutput = {message: string}

@val external queueMicrotask: (unit => unit) => unit = "queueMicrotask"

let taskSchema = taskArgsSchema->McpStandardSchema.fromRescriptSchema
let taskOutputStandardSchema = taskOutputSchema->McpStandardSchema.fromRescriptSchema

let taskOptions = McpTaskCreationParams.make(~ttl=60000, ~pollInterval=1, ())

describe("experimental task roundtrip", () => {
  testAsync("task tool registration and client experimental task APIs roundtrip through the live SDK", async t => {
    let expect = value => t->expect(value)
    let taskStore = McpTaskStore.makeInMemory()
    let serverCapabilities =
      Dict.fromArray([
        (
          "tasks",
          Dict.fromArray([
            ("taskStore", taskStore->McpTestBindings.toUnknown),
            ("defaultTaskPollInterval", 1->McpTestBindings.intToUnknown),
            ("list", Dict.fromArray([])->McpTestBindings.dictToUnknown),
            ("cancel", Dict.fromArray([])->McpTestBindings.dictToUnknown),
            (
              "requests",
              Dict.fromArray([
                (
                  "tools",
                  Dict.fromArray([("call", Dict.fromArray([])->McpTestBindings.dictToUnknown)])
                  ->McpTestBindings.dictToUnknown,
                ),
              ])
              ->McpTestBindings.dictToUnknown,
            ),
          ])
          ->McpTestBindings.dictToUnknown,
        ),
      ])
    let client = McpClient.make(McpTestBindings.makeImplementation("loopback-task-client", "1.0.0"))
    let server =
      McpServer.makeWithOptions(
        McpTestBindings.makeImplementation("loopback-task-server", "1.0.0"),
        McpServerOptions.make(~capabilities=serverCapabilities, ()),
      )
    let pair = McpTestBindings.makeLoopbackTransportPair("task-loopback")
    let serverTransport = pair->McpTestBindings.loopbackServerTransport
    let clientTransport = pair->McpTestBindings.loopbackClientTransport
    let timeoutOptions = McpRequestOptions.make(~timeout=5000, ())
    let taskRequestOptions = McpRequestOptions.make(~timeout=5000, ~task=taskOptions, ())
    let completedTaskIds = ref([])
    let typedRetrievedMessage = ref(None)

    server
    ->McpServer.experimentalTasks
    ->McpServerExperimentalTasks.registerToolTask(
      "echo-task",
      McpTaskTool.makeConfig(
        ~title="Echo Task",
        ~inputSchema=taskSchema,
        ~outputSchema=taskOutputStandardSchema,
        ~execution=McpTaskTool.makeExecution(~taskSupport=#required, ()),
        (),
      ),
      McpTaskTool.makeHandler(
        ~createTask=async ((args: taskArgs), ctx) => {
          let taskContext = ctx->McpServerContext.task->McpTestBindings.getSome
          let store = taskContext->McpTaskContext.store
          let task =
            await store->McpRequestTaskStore.createTask(
              McpCreateTaskOptions.make(~ttl=60000, ~pollInterval=1, ()),
            )
          await store->McpRequestTaskStore.updateTaskStatus(
            task->McpTask.taskId,
            #working,
            ~statusMessage="working",
          )
          queueMicrotask(() => {
            let _promise = (async () => {
              let ttlText =
                taskContext
                ->McpTaskContext.requestedTtl
                ->Option.map(value => value->Int.toString)
                ->Option.getOr("missing")
              let finalResult =
                McpCallToolResult.make(
                  ~content=[McpContentBlock.text(`task:${args.message}:${ttlText}`)],
                  ~structuredContent={message: args.message},
                  (),
                )
              await store->McpRequestTaskStore.storeTaskResult(
                task->McpTask.taskId,
                #completed,
                finalResult,
                taskOutputStandardSchema,
              )
              let typedResult =
                await store
                ->McpRequestTaskStore.getTaskResult(task->McpTask.taskId, taskOutputStandardSchema)
              typedRetrievedMessage :=
                typedResult->McpCallToolResult.structuredContent->Option.map(output => output.message)
              completedTaskIds := [task->McpTask.taskId, ...completedTaskIds.contents]
            })()
            ()
          })
          let workingTask = await store->McpRequestTaskStore.getTask(task->McpTask.taskId)
          McpCreateTaskResult.make(~task=workingTask, ())
        },
        ~getTask=async ((_args: taskArgs), ctx) => {
          let taskContext = ctx->McpServerContext.task->McpTestBindings.getSome
          let taskId = taskContext->McpTaskContext.id->McpTestBindings.getSome
          let task = await taskContext->McpTaskContext.store->McpRequestTaskStore.getTask(taskId)
          McpGetTaskResult.ofTask(task)
        },
        ~getTaskResult=async ((_args: taskArgs), ctx) => {
          let taskContext = ctx->McpServerContext.task->McpTestBindings.getSome
          let taskId = taskContext->McpTaskContext.id->McpTestBindings.getSome
          await taskContext
          ->McpTaskContext.store
          ->McpRequestTaskStore.getTaskResult(taskId, taskOutputStandardSchema)
        },
        (),
      ),
    )
    ->ignore

    server
    ->McpServer.experimentalTasks
    ->McpServerExperimentalTasks.registerToolTaskRaw0(
      "stall-task",
      McpTaskTool.makeRawConfig(
        ~title="Stall Task",
        ~execution=McpTaskTool.makeExecution(~taskSupport=#required, ()),
        (),
      ),
      McpTaskTool.makeRawHandler0(
        ~createTask=async ctx => {
          let taskContext = ctx->McpServerContext.task->McpTestBindings.getSome
          let store = taskContext->McpTaskContext.store
          let task =
            await store->McpRequestTaskStore.createTask(
              McpCreateTaskOptions.make(~ttl=60000, ~pollInterval=1, ()),
            )
          await store->McpRequestTaskStore.updateTaskStatus(
            task->McpTask.taskId,
            #working,
            ~statusMessage="waiting",
          )
          let workingTask = await store->McpRequestTaskStore.getTask(task->McpTask.taskId)
          McpCreateTaskResult.make(~task=workingTask, ())
        },
        ~getTask=async ctx => {
          let taskContext = ctx->McpServerContext.task->McpTestBindings.getSome
          let taskId = taskContext->McpTaskContext.id->McpTestBindings.getSome
          let task = await taskContext->McpTaskContext.store->McpRequestTaskStore.getTask(taskId)
          McpGetTaskResult.ofTask(task)
        },
        ~getTaskResult=_ctx =>
          Promise.resolve(
            McpCallToolResult.makeRaw(~content=[McpContentBlock.text("unreachable")], ()),
          ),
        (),
      ),
    )
    ->ignore

    await server->McpServer.connect(serverTransport)
    await client->McpClient.connectWithOptions(clientTransport, timeoutOptions)

    (await client->McpClient.listTools)->ignore

    let stream =
      client
      ->McpClient.experimentalTasks
      ->McpClientExperimentalTasks.callToolStreamRawWithOptions(
          Dict.fromArray([
            ("name", "echo-task"->McpTestBindings.stringToUnknown),
            (
              "arguments",
              Dict.fromArray([("message", "hello"->McpTestBindings.stringToUnknown)])
              ->McpTestBindings.dictToUnknown,
            ),
          ]),
          taskRequestOptions,
        )
    let messages = await stream->McpResponseStream.toArray
    let taskId =
      messages
      ->Belt.Array.keepMap(message => message->McpResponseStream.task->Option.map(McpTask.taskId))
      ->Array.get(0)
      ->McpTestBindings.getSome
    let finalResult =
      messages
      ->Belt.Array.keepMap(McpResponseStream.result)
      ->Array.get(0)
      ->McpTestBindings.getSome

    let completedTask = await client->McpClient.experimentalTasks->McpClientExperimentalTasks.getTask(taskId)
    let completedTaskResult =
      await client
      ->McpClient.experimentalTasks
      ->McpClientExperimentalTasks.getTaskResultRawWithOptions(taskId, timeoutOptions)
    let listedTasks =
      await client
      ->McpClient.experimentalTasks
      ->McpClientExperimentalTasks.listTasksWithOptions(timeoutOptions)
    let stallMessagesPromise =
      client
      ->McpClient.experimentalTasks
      ->McpClientExperimentalTasks.callToolStreamRawWithOptions(
          Dict.fromArray([("name", "stall-task"->McpTestBindings.stringToUnknown)]),
          taskRequestOptions,
        )
      ->McpResponseStream.toArray
    await Promise.resolve()
    let stalledTaskId =
      (await client->McpClient.experimentalTasks->McpClientExperimentalTasks.listTasksWithOptions(timeoutOptions))
      ->McpListTasksResult.tasks
      ->Belt.Array.keepMap(task =>
          if task->McpTask.status == #working && task->McpTask.taskId != taskId {
            Some(task->McpTask.taskId)
          } else {
            None
          }
        )
      ->Array.get(0)
      ->McpTestBindings.getSome
    let cancelledTask =
      await client
      ->McpClient.experimentalTasks
      ->McpClientExperimentalTasks.cancelTaskWithOptions(stalledTaskId, timeoutOptions)
    let stallMessages = await stallMessagesPromise

    (
      messages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #result),
      messages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #taskCreated),
      finalResult->McpTestBindings.toolResultTextsUnknown,
      completedTask->McpGetTaskResult.status,
      completedTaskResult->McpTestBindings.toolResultTextsUnknown,
      typedRetrievedMessage.contents,
      listedTasks
      ->McpListTasksResult.tasks
      ->Array.map(McpTask.taskId)
      ->Belt.Array.some(value => value == taskId),
      completedTaskIds.contents->Belt.Array.some(value => value == taskId),
      stallMessages->Array.map(McpResponseStream.kind)->Belt.Array.some(kind => kind == #taskCreated),
      cancelledTask->McpCancelTaskResult.status,
    )
    ->expect
    ->Expect.toEqual((
      true,
      true,
      ["task:hello:60000"],
      #completed,
      ["task:hello:60000"],
      Some("hello"),
      true,
      true,
      true,
      #cancelled,
    ))

    await client->McpClient.close
    await server->McpServer.close
  })
})
