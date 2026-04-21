// src/core/McpRequestInfo.res
// Concern: construct and read request metadata passed through SDK request context objects.
type t

@obj
external make: (~headers: dict<unknown>, ~url: Webapi.Url.t=?, ()) => t = ""

@get
external headers: t => dict<unknown> = "headers"

@return(nullable)
@get
external url: t => option<Webapi.Url.t> = "url"
