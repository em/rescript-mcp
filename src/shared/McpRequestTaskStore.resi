type t

let createTask: (t, McpCreateTaskOptions.t) => promise<McpTask.t>
let getTask: (t, string) => promise<McpTask.t>
let storeTaskResult: (
  t,
  string,
  McpTaskResultStatus.t,
  McpCallToolResult.t<'output>,
  McpStandardSchema.t<'output>,
) => promise<unit>
let storeTaskResultRaw: (t, string, McpTaskResultStatus.t, unknown) => promise<unit>
let getTaskResult: (t, string, McpStandardSchema.t<'output>) => promise<McpCallToolResult.t<'output>>
let getTaskResultRaw: (t, string) => promise<unknown>
let updateTaskStatus: (t, string, McpTaskStatus.t, ~statusMessage: string=?) => promise<unit>
let listTasks: t => promise<McpListTasksResult.t>
let listTasksWithCursor: (t, string) => promise<McpListTasksResult.t>
