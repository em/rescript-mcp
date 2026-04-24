// src/shared/McpRequestTaskStore.res
// Concern: bind the request-scoped task-store object available from task-aware server contexts.
// Source: `@modelcontextprotocol/{client,server}` request task-store runtime surface.
// Boundary: typed tool-result storage and retrieval require `McpStandardSchema`, while raw heterogeneous task payloads stay explicit through `storeTaskResultRaw` and `getTaskResultRaw`.
// Why this shape: request-scoped task stores carry both typed tool-task results and open non-tool task payloads, so the binding keeps the typed 99% path separate from the raw seam.
// Coverage: tests/ExperimentalTasksRoundtrip_test.res, tests/PublicWrapperCoverage_test.res
type t

@send
external createTask: (t, McpCreateTaskOptions.t) => promise<McpTask.t> = "createTask"

@send
external getTask: (t, string) => promise<McpTask.t> = "getTask"

@send
external storeTaskResultTypedInternal: (t, string, string, McpCallToolResult.raw) => promise<unit> =
  "storeTaskResult"

@send
external storeTaskResultInternal: (t, string, string, unknown) => promise<unit> = "storeTaskResult"

let storeTaskResult = (store, taskId, status, result, outputSchema) =>
  store->storeTaskResultTypedInternal(
    taskId,
    status->McpTaskResultStatus.toString,
    result->McpCallToolResultInternal.toRaw(outputSchema),
  )

let storeTaskResultRaw = (store, taskId, status, result) =>
  store->storeTaskResultInternal(taskId, status->McpTaskResultStatus.toString, result)

@send
external getTaskResultRaw: (t, string) => promise<unknown> = "getTaskResult"

@send
external getTaskResultTypedInternal: (t, string) => promise<McpCallToolResult.raw> = "getTaskResult"

let getTaskResult = async (store, taskId, outputSchema) => {
  let result = await store->getTaskResultTypedInternal(taskId)
  result->McpCallToolResultInternal.fromRaw(outputSchema)
}

@send
external updateTaskStatusRaw: (t, string, string) => promise<unit> = "updateTaskStatus"

@send
external updateTaskStatusRawWithMessage: (t, string, string, string) => promise<unit> =
  "updateTaskStatus"

let updateTaskStatus = (store, taskId, status, ~statusMessage=?) =>
  switch statusMessage {
  | Some(message) =>
    store->updateTaskStatusRawWithMessage(taskId, status->McpTaskStatus.toString, message)
  | None => store->updateTaskStatusRaw(taskId, status->McpTaskStatus.toString)
  }

@send
external listTasks: t => promise<McpListTasksResult.t> = "listTasks"

@send
external listTasksWithCursor: (t, string) => promise<McpListTasksResult.t> = "listTasks"
