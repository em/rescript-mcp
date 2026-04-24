// src/protocol/McpEmptyResult.res
// Concern: expose SDK result objects that carry only optional MCP metadata.
type t

@obj
external make: (~_meta: dict<unknown>=?, ()) => t = ""

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
