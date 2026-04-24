// src/protocol/McpCreateTaskResult.res
// Concern: construct and inspect task creation results returned by task-based tool handlers.
type t

@obj
external make: (~task: McpTask.t, ()) => t = ""

@get
external task: t => McpTask.t = "task"
