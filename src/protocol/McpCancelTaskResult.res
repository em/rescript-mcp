// src/protocol/McpCancelTaskResult.res
// Concern: construct and inspect `tasks/cancel` results returned by the MCP SDK.
type t

@obj
external makeRaw: (
  ~taskId: string,
  ~status: string,
  ~ttl: int=?,
  ~createdAt: string,
  ~lastUpdatedAt: string,
  ~pollInterval: int=?,
  ~statusMessage: string=?,
  (),
) => t = ""

let make = (~taskId, ~status, ~ttl=?, ~createdAt, ~lastUpdatedAt, ~pollInterval=?, ~statusMessage=?, ()) =>
  makeRaw(
    ~taskId,
    ~status=status->McpTaskStatus.toString,
    ~ttl?,
    ~createdAt,
    ~lastUpdatedAt,
    ~pollInterval?,
    ~statusMessage?,
    (),
  )

let ofTask = task =>
  {
    let ttl = task->McpTask.ttl
    let pollInterval = task->McpTask.pollInterval
    let statusMessage = task->McpTask.statusMessage
  make(
    ~taskId=task->McpTask.taskId,
    ~status=task->McpTask.status,
    ~ttl?,
    ~createdAt=task->McpTask.createdAt,
    ~lastUpdatedAt=task->McpTask.lastUpdatedAt,
    ~pollInterval?,
    ~statusMessage?,
    (),
  )
  }

@get
external taskId: t => string = "taskId"

@get
external statusString: t => string = "status"

let status = result => result->statusString->McpTaskStatus.fromString

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
