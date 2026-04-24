// src/client/McpClientExperimentalTasks.res
// Concern: bind the client experimental task APIs exposed through `Client.experimental.tasks`.
type t
type request

@obj
external makeRequest: (~method: string, ~params: dict<unknown>=?, ()) => request = ""

@send
external callToolStreamRaw: (t, dict<unknown>) => McpResponseStream.t<unknown> = "callToolStream"

@send
external callToolStreamRawWithOptions: (
  t,
  dict<unknown>,
  McpRequestOptions.t,
) => McpResponseStream.t<unknown> = "callToolStream"

@send
external requestStream: (t, request) => McpResponseStream.t<unknown> = "requestStream"

@send
external requestStreamWithOptions: (t, request, McpRequestOptions.t) => McpResponseStream.t<unknown> =
  "requestStream"

let requestStreamRaw = (tasks, method_, params) =>
  tasks->requestStream(makeRequest(~method=method_->McpMethod.requestToString, ~params, ()))

let requestStreamRawWithOptions = (tasks, method_, params, options) =>
  tasks
  ->requestStreamWithOptions(makeRequest(~method=method_->McpMethod.requestToString, ~params, ()), options)

@send
external getTask: (t, string) => promise<McpGetTaskResult.t> = "getTask"

@send
external getTaskWithOptions: (t, string, McpRequestOptions.t) => promise<McpGetTaskResult.t> = "getTask"

@send
external getTaskResultRaw: (t, string) => promise<unknown> = "getTaskResult"

@send
external getTaskResultRawWithOptions: (t, string, McpRequestOptions.t) => promise<unknown> =
  "getTaskResult"

@send
external listTasks: t => promise<McpListTasksResult.t> = "listTasks"

@send
external listTasksWithCursor: (t, string) => promise<McpListTasksResult.t> = "listTasks"

@send
external listTasksWithCursorAndOptions: (
  t,
  string,
  McpRequestOptions.t,
) => promise<McpListTasksResult.t> = "listTasks"

@module("./McpClientExperimentalTasksSupport.mjs")
external listTasksWithOptions: (t, McpRequestOptions.t) => promise<McpListTasksResult.t> =
  "listTasksWithOptions"

@send
external cancelTask: (t, string) => promise<McpCancelTaskResult.t> = "cancelTask"

@send
external cancelTaskWithOptions: (t, string, McpRequestOptions.t) => promise<McpCancelTaskResult.t> =
  "cancelTask"
