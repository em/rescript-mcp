type t

let requestStreamRaw: (t, McpMethod.request, dict<unknown>) => McpResponseStream.t<unknown>
let requestStreamRawWithOptions: (
  t,
  McpMethod.request,
  dict<unknown>,
  McpRequestOptions.t,
) => McpResponseStream.t<unknown>
let createMessageStreamRaw: (t, dict<unknown>) => McpResponseStream.t<unknown>
let createMessageStreamRawWithOptions: (
  t,
  dict<unknown>,
  McpRequestOptions.t,
) => McpResponseStream.t<unknown>
let elicitInputStreamRaw: (t, dict<unknown>) => McpResponseStream.t<unknown>
let elicitInputStreamRawWithOptions: (
  t,
  dict<unknown>,
  McpRequestOptions.t,
) => McpResponseStream.t<unknown>
let getTask: (t, string) => promise<McpGetTaskResult.t>
let getTaskWithOptions: (t, string, McpRequestOptions.t) => promise<McpGetTaskResult.t>
let getTaskResultRaw: (t, string) => promise<unknown>
let getTaskResultRawWithOptions: (t, string, McpRequestOptions.t) => promise<unknown>
let listTasks: t => promise<McpListTasksResult.t>
let listTasksWithCursor: (t, string) => promise<McpListTasksResult.t>
let listTasksWithOptions: (t, McpRequestOptions.t) => promise<McpListTasksResult.t>
let listTasksWithCursorAndOptions: (t, string, McpRequestOptions.t) => promise<McpListTasksResult.t>
let cancelTask: (t, string) => promise<McpCancelTaskResult.t>
let cancelTaskWithOptions: (t, string, McpRequestOptions.t) => promise<McpCancelTaskResult.t>
