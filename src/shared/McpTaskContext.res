// src/shared/McpTaskContext.res
// Concern: inspect task context attached to server handler contexts when task storage is configured.
type t

@return(nullable)
@get
external id: t => option<string> = "id"

@get
external store: t => McpRequestTaskStore.t = "store"

@return(nullable)
@get
external requestedTtl: t => option<int> = "requestedTtl"
