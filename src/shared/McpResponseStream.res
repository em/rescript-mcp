// src/shared/McpResponseStream.res
// Concern: inspect and collect task-aware async response streams returned by experimental APIs.
type t<'result>
type message<'result>
type kind = [#taskCreated | #taskStatus | #result | #error]

@module("@modelcontextprotocol/server")
external toArray: t<'result> => promise<array<message<'result>>> = "toArrayAsync"

@module("@modelcontextprotocol/server")
external takeResult: t<'result> => promise<'result> = "takeResult"

@get
external kindString: message<'result> => string = "type"

let kind = message =>
  switch kindString(message) {
  | "taskCreated" => #taskCreated
  | "taskStatus" => #taskStatus
  | "result" => #result
  | "error" => #error
  | other => JsError.throwWithMessage("Unsupported MCP response stream message type: " ++ other)
  }

@return(nullable)
@get
external task: message<'result> => option<McpTask.t> = "task"

@return(nullable)
@get
external result: message<'result> => option<'result> = "result"

@return(nullable)
@get
external error: message<'result> => option<unknown> = "error"
