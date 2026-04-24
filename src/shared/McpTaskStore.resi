type t

let make: (
  ~createTask: @uncurry (McpCreateTaskOptions.t, McpTypes.requestId, unknown, option<string>) =>
    promise<McpTask.t>,
  ~getTask: @uncurry (string, option<string>) => promise<option<McpTask.t>>,
  ~storeTaskResult: @uncurry (string, McpTaskResultStatus.t, unknown, option<string>) =>
    promise<unit>,
  ~getTaskResult: @uncurry (string, option<string>) => promise<unknown>,
  ~updateTaskStatus: @uncurry (string, McpTaskStatus.t, option<string>, option<string>) =>
    promise<unit>,
  ~listTasks: @uncurry (option<string>, option<string>) => promise<McpListTasksResult.t>,
  unit,
) => t
let makeInMemory: unit => t
let createTask: (t, McpCreateTaskOptions.t, McpTypes.requestId, unknown) => promise<McpTask.t>
let createTaskWithSessionId: (t, McpCreateTaskOptions.t, McpTypes.requestId, unknown, string) => promise<
  McpTask.t,
>
let getTask: (t, string) => promise<option<McpTask.t>>
let getTaskWithSessionId: (t, string, string) => promise<option<McpTask.t>>
let storeTaskResult: (
  t,
  string,
  McpTaskResultStatus.t,
  McpCallToolResult.t<'output>,
  McpStandardSchema.t<'output>,
) => promise<unit>
let storeTaskResultWithSessionId: (
  t,
  string,
  McpTaskResultStatus.t,
  McpCallToolResult.t<'output>,
  McpStandardSchema.t<'output>,
  string,
) => promise<unit>
let storeTaskResultRaw: (t, string, McpTaskResultStatus.t, unknown) => promise<unit>
let storeTaskResultRawWithSessionId: (t, string, McpTaskResultStatus.t, unknown, string) => promise<
  unit,
>
let getTaskResult: (t, string, McpStandardSchema.t<'output>) => promise<McpCallToolResult.t<'output>>
let getTaskResultWithSessionId: (
  t,
  string,
  McpStandardSchema.t<'output>,
  string,
) => promise<McpCallToolResult.t<'output>>
let getTaskResultRaw: (t, string) => promise<unknown>
let getTaskResultRawWithSessionId: (t, string, string) => promise<unknown>
let updateTaskStatus: (t, string, McpTaskStatus.t, ~statusMessage: string=?, unit) => promise<unit>
let updateTaskStatusWithSessionId: (
  t,
  string,
  McpTaskStatus.t,
  ~statusMessage: string=?,
  string,
) => promise<unit>
let listTasks: t => promise<McpListTasksResult.t>
let listTasksWithCursor: (t, string) => promise<McpListTasksResult.t>
let listTasksWithSessionId: (t, string) => promise<McpListTasksResult.t>
let listTasksWithCursorAndSessionId: (t, string, string) => promise<McpListTasksResult.t>
