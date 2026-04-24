// src/protocol/McpListTasksResult.res
// Concern: construct and inspect `tasks/list` results returned by the MCP SDK.
type t

@obj
external make: (
  ~tasks: array<McpTask.t>,
  ~nextCursor: string=?,
  (),
) => t = ""

@get
external tasks: t => array<McpTask.t> = "tasks"

@return(nullable)
@get
external nextCursor: t => option<string> = "nextCursor"
