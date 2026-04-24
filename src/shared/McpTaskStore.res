// src/shared/McpTaskStore.res
// Concern: bind pluggable task stores and the installed in-memory task store on the public package surface.
// Source: `@modelcontextprotocol/{client,server}` TaskStore and InMemoryTaskStore plus `src/shared/McpTaskStoreSupport.mjs`.
// Boundary: status strings are classified into finite unions, typed tool results round-trip through `McpStandardSchema`, and original request payloads stay open at `unknown`.
// Why this shape: upstream task stores mix typed task lifecycle control with open protocol payload storage, so the binding narrows the honest finite parts and leaves the protocol seams explicit.
// Coverage: tests/TaskStorageSurface_test.res, tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
type t

@module("./McpTaskStoreSupport.mjs")
external makeRaw: (
  ~createTask: @uncurry (McpCreateTaskOptions.t, McpTypes.requestId, unknown, option<string>) =>
    promise<McpTask.t>,
  ~getTask: @uncurry (string, option<string>) => promise<option<McpTask.t>>,
  ~storeTaskResult: @uncurry (string, string, unknown, option<string>) => promise<unit>,
  ~getTaskResult: @uncurry (string, option<string>) => promise<unknown>,
  ~updateTaskStatus: @uncurry (string, string, option<string>, option<string>) => promise<unit>,
  ~listTasks: @uncurry (option<string>, option<string>) => promise<McpListTasksResult.t>,
  (),
) => t = "makeTaskStore"

@module("@modelcontextprotocol/server")
@new
external makeInMemory: unit => t = "InMemoryTaskStore"

let make = (~createTask, ~getTask, ~storeTaskResult, ~getTaskResult, ~updateTaskStatus, ~listTasks, ()) =>
  makeRaw(
    ~createTask,
    ~getTask,
    ~storeTaskResult=(taskId, status, result, sessionId) =>
      storeTaskResult(taskId, status->McpTaskResultStatus.fromString, result, sessionId),
    ~getTaskResult,
    ~updateTaskStatus=(taskId, status, statusMessage, sessionId) =>
      updateTaskStatus(taskId, status->McpTaskStatus.fromString, statusMessage, sessionId),
    ~listTasks,
    (),
  )

@send
external createTaskRaw: (t, McpCreateTaskOptions.t, McpTypes.requestId, unknown, option<string>) => promise<
  McpTask.t,
> = "createTask"

let createTask = (store, taskParams, requestId, request) =>
  store->createTaskRaw(taskParams, requestId, request, None)

let createTaskWithSessionId = (store, taskParams, requestId, request, sessionId) =>
  store->createTaskRaw(taskParams, requestId, request, Some(sessionId))

// The in-memory store returns `null` for a missing task, so the JS shim normalizes
// that to `undefined` before this public `option` boundary sees it.
@module("./McpTaskStoreSupport.mjs")
external getTask: (t, string) => promise<option<McpTask.t>> = "getTask"

@module("./McpTaskStoreSupport.mjs")
external getTaskWithSessionId: (t, string, string) => promise<option<McpTask.t>> =
  "getTaskWithSessionId"

@send
external storeTaskResultTypedInternal: (
  t,
  string,
  string,
  McpCallToolResult.raw,
  option<string>,
) => promise<unit> =
  "storeTaskResult"

@send
external storeTaskResultInternal: (t, string, string, unknown, option<string>) => promise<unit> =
  "storeTaskResult"

let storeTaskResult = (store, taskId, status, result, outputSchema) =>
  store->storeTaskResultTypedInternal(
    taskId,
    status->McpTaskResultStatus.toString,
    result->McpCallToolResultInternal.toRaw(outputSchema),
    None,
  )

let storeTaskResultWithSessionId = (store, taskId, status, result, outputSchema, sessionId) =>
  store->storeTaskResultTypedInternal(
    taskId,
    status->McpTaskResultStatus.toString,
    result->McpCallToolResultInternal.toRaw(outputSchema),
    Some(sessionId),
  )

let storeTaskResultRaw = (store, taskId, status, result) =>
  store->storeTaskResultInternal(taskId, status->McpTaskResultStatus.toString, result, None)

let storeTaskResultRawWithSessionId = (store, taskId, status, result, sessionId) =>
  store->storeTaskResultInternal(taskId, status->McpTaskResultStatus.toString, result, Some(sessionId))

@send
external getTaskResultRaw: (t, string) => promise<unknown> = "getTaskResult"

@send
external getTaskResultRawWithSessionId: (t, string, string) => promise<unknown> = "getTaskResult"

@send
external getTaskResultTypedInternal: (t, string) => promise<McpCallToolResult.raw> = "getTaskResult"

@send
external getTaskResultTypedInternalWithSessionId: (t, string, string) => promise<McpCallToolResult.raw> =
  "getTaskResult"

let getTaskResult = async (store, taskId, outputSchema) => {
  let result = await store->getTaskResultTypedInternal(taskId)
  result->McpCallToolResultInternal.fromRaw(outputSchema)
}

let getTaskResultWithSessionId = async (store, taskId, outputSchema, sessionId) => {
  let result = await store->getTaskResultTypedInternalWithSessionId(taskId, sessionId)
  result->McpCallToolResultInternal.fromRaw(outputSchema)
}

@send
external updateTaskStatusRaw: (t, string, string, option<string>, option<string>) => promise<unit> =
  "updateTaskStatus"

let updateTaskStatus = (store, taskId, status, ~statusMessage=?, ()) =>
  store->updateTaskStatusRaw(taskId, status->McpTaskStatus.toString, statusMessage, None)

let updateTaskStatusWithSessionId = (store, taskId, status, ~statusMessage=?, sessionId) =>
  store->updateTaskStatusRaw(taskId, status->McpTaskStatus.toString, statusMessage, Some(sessionId))

@send
external listTasksRaw: (t, option<string>, option<string>) => promise<McpListTasksResult.t> =
  "listTasks"

let listTasks = store => store->listTasksRaw(None, None)
let listTasksWithCursor = (store, cursor) => store->listTasksRaw(Some(cursor), None)
let listTasksWithSessionId = (store, sessionId) => store->listTasksRaw(None, Some(sessionId))
let listTasksWithCursorAndSessionId = (store, cursor, sessionId) =>
  store->listTasksRaw(Some(cursor), Some(sessionId))
