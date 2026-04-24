// src/protocol/McpResourceUpdatedParams.res
// Concern: bind notifications/resources/updated params as a typed protocol object.
type t

@obj
external make: (~uri: string, ~_meta: dict<unknown>=?, ()) => t = ""

@get
external uri: t => string = "uri"

@return(nullable)
@get
external meta: t => option<dict<unknown>> = "_meta"
