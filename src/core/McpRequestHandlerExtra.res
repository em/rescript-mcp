// src/core/McpRequestHandlerExtra.res
// Concern: read the schema-independent request context fields exposed to low-level request handlers.
type t

@return(nullable)
@get
external authInfo: t => option<McpAuthInfo.t> = "authInfo"

@return(nullable)
@get
external sessionId: t => option<string> = "sessionId"

@get
external requestId: t => unknown = "requestId"

@return(nullable)
@get
external taskId: t => option<string> = "taskId"

@return(nullable)
@get
external requestInfo: t => option<McpRequestInfo.t> = "requestInfo"

@return(nullable)
@get
external closeSSEStream: t => option<unit => unit> = "closeSSEStream"

@return(nullable)
@get
external closeStandaloneSSEStream: t => option<unit => unit> = "closeStandaloneSSEStream"
