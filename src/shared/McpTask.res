// src/shared/McpTask.res
// Concern: inspect task records returned by the MCP SDK task store and task APIs.
type t

@get
external taskId: t => string = "taskId"

@get
external statusString: t => string = "status"

let status = task => task->statusString->McpTaskStatus.fromString

@return(nullable)
@get
external ttl: t => option<int> = "ttl"

@get
external createdAt: t => string = "createdAt"

@get
external lastUpdatedAt: t => string = "lastUpdatedAt"

@return(nullable)
@get
external pollInterval: t => option<int> = "pollInterval"

@return(nullable)
@get
external statusMessage: t => option<string> = "statusMessage"
