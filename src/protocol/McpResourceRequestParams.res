// src/protocol/McpResourceRequestParams.res
// Concern: construct the installed resource request params object used by read and subscription methods.
type t

@obj
external make: (~uri: string, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external uri: t => string = "uri"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
