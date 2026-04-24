// src/protocol/McpPaginatedParams.res
// Concern: construct the shared installed paginated request params object used by list methods.
type t

@obj
external make: (~cursor: string=?, ~_meta: dict<unknown>=?, ()) => t = ""

@return(nullable)
@get
external cursor: t => option<string> = "cursor"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
