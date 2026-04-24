// src/protocol/McpListRootsParams.res
// Concern: construct the installed `roots/list` request params object.
type t

@obj
external make: (~_meta: dict<unknown>=?, ()) => t = ""

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
